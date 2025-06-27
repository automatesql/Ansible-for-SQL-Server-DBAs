[CmdletBinding()]
      param(
        [Parameter(Mandatory=$true)]
        [string]$ServerInstance
      )
      import-module SqlServer
      (Get-SqlInstance -ServerInstance "$ServerInstance" -ErrorAction Stop ).Version.ToString()

      $Ansible.Changed = $false