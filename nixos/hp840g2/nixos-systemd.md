You: finish this nixos systemd-user unit so it starts only interactively (when kde plasma is fully loaded), and doesn't break when running 2 daemons at once (both should be open simultaneously):
```nix
systemd.user.services.awatcher = {
    enable = true;
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    description = "ActivityWatch NixOS Service";
    serviceConfig = {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 30";
      ExecStart = "${pkgs.bash}/bin/bash -c 'awatcher && aw-qt'";
    };
  };
```

Leo AI: The main issues with your current config:

1. **`ExecStart = "bash -c 'awatcher && aw-qt'"`** — the `&&` means `aw-qt` only runs if `awatcher` exits successfully, and since `awatcher` is a long-running daemon, `aw-qt` never starts. You need both running simultaneously.
2. **`after = [ "graphical-session.target" ]`** on its own isn't enough — `graphical-session.target` can fire before the session manager is fully ready. You also need `requires` so the service won't start if the graphical session isn't there.
3. No idle guard or session environment dependency.

Here's a corrected version:

```nix
systemd.user.services.awatcher = {
  enable = true;
  description = "ActivityWatch NixOS Service";

  # Ensure graphical session is ready AND we're in an interactive session
  after = [ "graphical-session.target" "graphical-session-pre.target" ];
  requires = [ "graphical-session.target" ];
  wants = [ "graphical-session-pre.target" ];
  partOf = [ "graphical-session.target" ];

  serviceConfig = {
    Type = "simple";
    Restart = "on-failure";
    RestartSec = 5;

    # Both awatcher and aw-qt run concurrently inside the shell
    # Use & to background awatcher, then exec aw-qt in foreground
    # so systemd tracks aw-qt as the main process (traps SIGTERM properly)
    ExecStart = "%h/.nix-profile/bin/bash -c 'nohup %h/.nix-profile/bin/awatcher > /dev/null 2>&1 & exec %h/.nix-profile/bin/aw-qt'";
  };
};
```

**What changed and why:**

| Change | Reason |
|---|---|
| `nohup awatcher & exec aw-qt` | `awatcher` runs in the background, `aw-qt` runs in the foreground via `exec`. systemd tracks `aw-qt` as the main PID, so SIGTERM from `graphical-session.target` stops it cleanly on logout. |
| `requires = [ "graphical-session.target" ]` | Prevents the service from starting if the graphical session isn't active (avoids non-interactive / SSH starts). |
| `partOf = [ "graphical-session.target" ]` | Ensures the service is stopped when the graphical session ends. |
| `Restart = "on-failure"` | Recovers if aw-qt or awatcher crashes unexpectedly. |
| Removed `ExecStartPre` sleep | Sleeping 30s is a hack. The `requires` + `after` directives are the proper mechanism. If you still need a delay for KDE to fully initialize, add `StartDelaySec = 10` instead. |

**Alternative: two separate services**

If `awatcher` and `aw-qt` each need independent lifecycle management, split them:

```nix
systemd.user.services.awatcher-daemon = {
  enable = true;
  description = "ActivityWatch daemon";
  after = [ "graphical-session.target" ];
  requires = [ "graphical-session.target" ];
  partOf = [ "graphical-session.target" ];
  serviceConfig = {
    Type = "simple";
    Restart = "on-failure";
    ExecStart = "%h/.nix-profile/bin/awatcher";
  };
};

systemd.user.services.awatcher-qt = {
  enable = true;
  description = "ActivityWatch systray app";
  after = [ "graphical-session.target" ];
  requires = [ "graphical-session.target" ];
  partOf = [ "graphical-session.target" ];
  serviceConfig = {
    Type = "simple";
    Restart = "on-failure";
    ExecStart = "%h/.nix-profile/bin/aw-qt";
  };
};
```

This is arguably cleaner — each unit has its own PID, restart policy, and logs. Both will run simultaneously, and both will start only when the graphical session is active.


> Written with [StackEdit](https://stackedit.io/).
