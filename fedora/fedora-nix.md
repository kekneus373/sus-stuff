1. remove previous installation, if any: `/nix/nix-installer uninstall`

2. get nix on your system

```
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
sh -s -- install
```

3. `vim ~/.config/nix/nix.conf`

```nix
experimental-features = nix-command flakes
```

4. forgot what this does, but run: `nix flake show nixpkgs`

5. install your apps: `nix profile add nixpkgs#telegram-desktop`
