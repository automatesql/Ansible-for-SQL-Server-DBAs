Role Name
=========

sql_ag_patch - Role is used to patch instances participating in a specific Availability Group.

Requirements
------------

This role depends on the SqlServer PowerShell module.  Use the playbook_DSCResources.yml to download and extract it to the Ansible control node (unzip required on the ansible control node).


Role Variables
--------------

Review the pre-set variables in the defaults/main.yml file.  Change these to match your environment.


Dependencies
------------

PowerShell Module - SqlServer


Example Playbook
----------------

Example playbook.

---
- name: Patch SQL Server Availability Group
  hosts: sqlservers
  gather_facts: true
  any_errors_fatal: true
 
  tasks:
    - name: Import the sql_ag_patch role
      ansible.builtin.import_role:
        name: sql_ag_patch



Author Information
------------------
This project was created by Luke Campbell - https://www.automatesql.com - as an example for patching SQL Server AGs with Ansible.