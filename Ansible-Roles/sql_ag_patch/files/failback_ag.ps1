[CmdletBinding()]
param (
  [Parameter(Mandatory = $true)]
  [string]$AgCurrentPrimary,

  [Parameter(Mandatory = $true)]
  [string]$AgName,

  [Parameter(Mandatory = $true)]
  [string]$DesiredSqlVersion,

  [Parameter(Mandatory = $true)]
  [string]$NewPrimary
)
Import-Module SqlServer
# Log the input parameters
Write-Output "AgCurrentPrimary: '$AgCurrentPrimary'"
Write-Output "NewPrimary: '$NewPrimary'"
Write-Output "AgName: '$AgName'"
Write-Output "DesiredSqlVersion: '$DesiredSqlVersion'"

# Build the Replica name for a default vs. named instance
if ($AgCurrentPrimary -like '*\*') {
  $Replica = $AgCurrentPrimary
}
else {
  $Replica = "$AgCurrentPrimary\DEFAULT"
}
# Encode the replica name if it's a named instance
$EncodedSqlName = ConvertTo-EncodedSqlName -SqlName $AgCurrentPrimary

try {
  $actualVersion = (Get-SqlInstance -ServerInstance $AgCurrentPrimary -ErrorAction Stop).Version.ToString()
  $state = (Test-SqlAvailabilityReplica `
   -Path "SQLSERVER:\Sql\$Replica\AvailabilityGroups\$AgName\AvailabilityReplicas\$EncodedSqlName" -ErrorAction Stop).HealthState
}
catch {
  Write-Warning "Failed to retrieve health state for replica $Replica. Unable to fail back."
  $Ansible.Failed = $true
  return
}

Write-Output "Current primary replica: '$AgCurrentPrimary'"
Write-Output "Replica state: '$state' / Version: '$actualVersion'"

# If version and health are as expected, fail over
if ($actualVersion -eq $DesiredSqlVersion -and $state -eq 'Healthy') {
  Write-Output "Failing over AG '$AgName' from '$NewPrimary' to '$AgCurrentPrimary'..."
  Switch-SqlAvailabilityGroup -Path "SQLSERVER:\Sql\$Replica\AvailabilityGroups\$AgName" -ErrorAction Stop
  $Ansible.Changed = $true
}
else {
  Write-Host "No failover performed. Either version or health state does not match."
  $Ansible.Failed = $true
 }