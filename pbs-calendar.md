write me gc and prune jobs for good backup retention for an 1tb datastore. i've got 3 vms on my main pve instance, os drives of which i plan backing up.

---

**pbs - Proxmox Backup Server**

`pbs:8007/#pbsStorageAndDiskPanel`

---

For a 1TB datastore with 3 VMs where you're backing up OS drives, you generally want a  **daily incremental schedule**  combined with  **weekly and monthly full backups**  to balance storage efficiency with recoverability. Below are recommended  **Garbage Collection (GC)**  and  **Prune**  job settings tailored to your setup.

----------

## 🧹 Garbage Collection (GC) Jobs

Garbage Collection cleans up orphaned or unreferenced data chunks in your datastore. For a 1TB volume with moderate backup activity:

### Recommended GC Job Settings

-   **Schedule:**  Weekly, every Sunday at 03:00
-   **Run Manually:**  Optional, after major pruning or restores
-   **Priority:**  Medium (don’t block backup jobs)
-   **Log Retention:**  Keep logs for 30 days

text

Copy

```
Schedule: 0 3 * * 0
Command (PVE shell):
  pct backup <vmid> --storage xeonback --mode stop
  # (optional manual trigger only if needed)
```

**Note:**  Proxmox VE automatically runs GC after backup jobs if configured. You can also add a manual GC job triggered by a cron-like schedule.

----------

## ✂️ Prune Jobs (Retention Policy)

Prune removes old backups based on retention rules. The goal is to keep a good mix of recent and historical restore points without overfilling storage.

### Suggested Retention Policy for 1TB

```
Hourly

1 hour

24

~100–150 GB

Daily

1 day

7

~200–300 GB

Weekly

1 week

4

~100–150 GB

Monthly

1 month

12

~300–400 GB
```

**Total Estimated Usage:**  ~600–1,000 GB (leaving headroom for growth)

### Prune Job Configuration

```
Job Name: VM-OS-Prune
Namespace: All VMs
Max Depth: 3 layers (hourly/daily/weekly/monthly)
Schedule: Daily at 02:00
Keep:
  - Last 24 hourly backups
  - Last 7 daily backups
  - Last 4 weekly backups
  - Last 12 monthly backups
```

----------

## 🔍 Best Practices

-   **Verify Backups:**  Schedule a  **Verify Job**  monthly to ensure backup integrity.
-   **Monitor Storage:**  If you approach 80% capacity, consider:
    -   Reducing hourly retention
    -   Offloading monthly backups to external S3 or tape
-   **Encryption & Access:**  Ensure your backups are encrypted and access-controlled, especially for OS drives.

----------

There is no single "correct" backup frequency for Proxmox, as it depends entirely on your **Recovery Point Objective (RPO)**—how much data loss your organization can tolerate. However, industry best practices and user consensus suggest the following schedules based on workload criticality:

### Recommended Backup Frequencies by Workload Tier

| Workload Tier | Recommended Frequency | Typical Schedule | RPO (Data Loss Tolerance) |
| :--- | :--- | :--- | :--- |
| **Critical** (DBs, Auth, Core Infra) | **Every 4–6 hours** | Multiple times daily (e.g., 2 AM, 8 AM, 2 PM, 8 PM) | 4–6 hours |
| **Standard Production** | **Daily** | Once daily, usually at 2:00 AM | 24 hours |
| **Non-Critical / Internal Tools** | **Daily or Every 2 Days** | Every 24–48 hours | 24–48 hours |
| **Dev / Test / Lab** | **Weekly** | Once a week (e.g., Sunday) | 1 week |

### Key Configuration Best Practices

**1. Use the Right Backup Mode**
*   **Snapshot Mode:** This is the standard for **production** VMs. It allows the VM to stay online during the backup. **Crucial:** For database consistency (MySQL, PostgreSQL, etc.), you **must** install the **QEMU Guest Agent** inside the VM. Without it, you risk a "crash-consistent" backup that may fail to mount or corrupt data upon restore https://www.zmanda.com/blog/proxmox-backup-vm-guide/ https://pve.proxmox.com/wiki/Backup_and_Restore.
*   **Stop Mode:** Shuts down the VM before backing up. Use this only for non-critical systems where downtime is acceptable, as it guarantees the cleanest state https://www.zmanda.com/blog/proxmox-backup-vm-guide/.
*   **Suspend Mode:** Suspends the VM to preserve memory state. Generally less efficient than snapshot mode and causes a brief freeze https://www.zmanda.com/blog/proxmox-backup-vm-guide/.

**2. Implement Tiered Retention (The "Grandfather-Father-Son" Model)**
Don't just keep daily backups forever. A common production baseline is:
*   **Keep Daily:** 7 backups (1 week)
*   **Keep Weekly:** 4 backups (1 month)
*   **Keep Monthly:** 3–6 backups (3–6 months)
*   *Note:* If you use **Proxmox Backup Server (PBS)**, you can leverage incremental backups and deduplication, making longer retention much cheaper in terms of storage space https://www.zmanda.com/blog/proxmox-backup-vm-guide/ https://www.zmanda.com/blog/proxmox-backup-and-restore-best-practices/.

**3. Follow the 3-2-1 Rule**
*   **3** copies of your data.
*   **2** different storage media (e.g., local disk + NAS or PBS).
*   **1** offsite copy (e.g., cloud storage or a remote server).
*   *Advanced:* For ransomware protection, make the offsite copy **immutable** (Write Once, Read Many) so it cannot be deleted or encrypted https://www.zmanda.com/blog/proxmox-backup-and-restore-best-practices/ https://nimbus.rdem-systems.com/en/blog/complete-proxmox-backup-guide/.

**4. Verify and Test**
A backup is only a hypothesis until you restore it.
*   **Automated Verify:** Run PBS verify jobs weekly to check data integrity https://www.zmanda.com/blog/proxmox-backup-and-restore-best-practices/.
*   **Manual Restore Test:** Perform a full restore test to an isolated VM **monthly** to ensure the application boots and functions correctly https://www.zmanda.com/blog/proxmox-backup-and-restore-best-practices/.

### Summary
For most small-to-mid-sized production environments, a **daily backup at 2:00 AM** using **snapshot mode** with a **7-day daily / 4-weekly / 3-monthly retention** policy is the standard starting point. Adjust the frequency upward for critical databases and downward for development servers based on your specific RPO needs https://www.zmanda.com/blog/proxmox-backup-vm-guide/ https://www.zmanda.com/blog/proxmox-backup-and-restore-best-practices/.

> Written with [StackEdit](https://stackedit.io/).
