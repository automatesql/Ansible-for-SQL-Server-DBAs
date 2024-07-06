Role Name
=========

mssql - Role is used to install and configure SQL Server 2022 Developer Edition on Windows.

Requirements
------------

This role depends on the ComputerManagementDsc and SqlServerDsc PowerShell DSC resources.  Use the playbook_DSCResources.yml to download and extract both to the Ansible control node (unzip required on the ansible control node).

The example environment consists of hosts which have virtual machines having 3 uninitialized disks.  These disks are initialized, partitioned, and formatted using the tasks/diskPrep.yml task.

Role Variables
--------------

Review the pre-set variables in the defaults/main.yml file.  Change these to match your environment.

The vars/main.yml should contain the following two variables.

rl_mssql_sapwd: "YoursaPassword"
rl_mssql_sysadminaccount: "YourDomain\\YourUserName"

Once set, encrypt using ansible-vault.

Set the rl_mssql_share variable, located in defaults/main.yml to the location of the SQL Server 2022 Developer Edition ISO. 
Set the rl_mssql_update_source variable to the name of the latest SQL Server 2022 update (must be downloaded and placed in the ISO/SQL2022 directory)

Dependencies
------------

PowerShell DSC resources
ComputerManagementDsc
SqlServerDsc

SQL Server 2022 Developer Edition ISO - Set the rl_mssql_share variable, located in defaults/main.yml to the location of the ISO. 
SQL Server 2022 Update - Download the latest update and place in the ISO/SQL2022 directory.

Example Playbook
----------------

Example playbook.

---
- name: Install SQL Server using mssql role
  hosts: sqlservers
  gather_facts: true

  tasks:
   - name: Import the mssql role
     ansible.builtin.import_role:
      name: mssql


Author Information
------------------
This project was created by Luke Campbell - https://www.automatesql.com - as an example for installing SQL Server on Windows using Ansible.

