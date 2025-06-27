[CmdletBinding()]
      param(
        [Parameter(Mandatory=$true)]
        [string]$PsPathAgPrimary,

        [Parameter(Mandatory=$true)]
        [string]$DesiredSqlVersion,

        [Parameter(Mandatory=$true)]
        [string]$AgName
      )
      Import-Module SqlServer
      
      # Log the input parameters
      Write-Output "PsPathAgPrimary: '$PsPathAgPrimary'"
      Write-Output "DesiredSqlVersion: '$DesiredSqlVersion'"
      Write-Output "AgName: '$AgName'"
    

      # Find replicas that are synchronous, secondary, and synchronized
      $Replicas = Get-ChildItem $PsPathAgPrimary |
        Where-Object {
          $_.AvailabilityMode -eq "SynchronousCommit" -and
          $_.Role -eq "Secondary" -and
          $_.RollupSynchronizationState -eq "Synchronized"
        }

      foreach ($replica in $Replicas) {
        try {
          $actualVersion = (Get-SqlInstance -ServerInstance $replica.Name -ErrorAction Stop).Version.ToString()
        }
        catch {
          # If retrieving version fails, skip this replica
          continue
        }

        # Check if the replica is at the desired SQL version
        if ($actualVersion -ne $DesiredSqlVersion) {
          Write-Output "Actual version '$actualVersion' does not match the desired version '$DesiredSqlVersion'."
          $Ansible.Failed = $true
          return
          }
       
        # Since the version matches, handle default vs. named instance for the new primary path
        if ($replica.Name -like '*\*') {
          $newPrimary = $replica.Name
        }
        else {
          $newPrimary = "$($replica.Name)\DEFAULT"
        }
    

         # Write-Host "Failing over AG '$AgName' to replica: $($replica.Name)"
          Switch-SqlAvailabilityGroup -Path "SQLSERVER:\Sql\$newPrimary\AvailabilityGroups\$AgName" -ErrorAction Stop

          # Return the new primary replica name in stdout
          write-host $newPrimary
          $Ansible.Changed = $true

          # Exit after the first suitable replica is found and the failover is done
          return
    }
      