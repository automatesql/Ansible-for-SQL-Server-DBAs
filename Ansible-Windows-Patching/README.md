# Quick and easy examples of using the win_updates module to update SQL Server on Windows.


## Virtual Lab Environment using VMware Workstation Pro.  All VMs use Windows Server 2022 Standard Evaluation Edition.
- Windows Domain - DC1 (HOMELAB.LOCAL)
- SRV1 & SRV2 (SQL Server target)
  - Create 3 additional disks in VMware Workstation for each of these VMs.
    - Disk 1 - Tempdb
    - Disk 2 - Data
    - Disk 3 - Log
- SRV3 (Ansible Controller)
  - Windows Subsystem for Linux with Ubuntu Distribution
  - Visual Studio Code with Ansible extension


### 1. If you're using WSL with an Ubuntu distribution, make sure Kerberos is configured.

https://ubuntu.com/server/docs/how-to-set-up-basic-workstation-authentication
--Kerberos support
`
sudo apt install -y krb5-user sssd-krb5
`
`
sudo dpkg-reconfigure krb5-config
`

### 2. Inventory
- hosts.ini
