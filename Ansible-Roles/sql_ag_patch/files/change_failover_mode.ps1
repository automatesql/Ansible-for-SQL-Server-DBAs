[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$SqlInstanceName,

    [Parameter(Mandatory=$true)]
    [string]$AgName,

    [Parameter(Mandatory=$true)]
    [string]$AgCurrentPrimary,

    [Parameter(Mandatory=$true)]
    [string]$NewPrimary,

    [Parameter(Mandatory=$true)]
    [string]$HostName,

    [Parameter(Mandatory=$true)]
    [ValidateSet("Manual", "Automatic")]
    [string]$TargetMode
)

# Import the SQL Server module
Import-Module SqlServer -ErrorAction Stop

# Determine which primary to use: if $NewPrimary has been updated from its default value, use it; otherwise, use $AgCurrentPrimary.
if ($NewPrimary -and $NewPrimary -ne "default_value") {
    $primaryCandidate = $NewPrimary
} else {
    $primaryCandidate = $AgCurrentPrimary
}

# Build the Primary replica name based on whether it's a default or named instance.
if ($primaryCandidate -like '*\*') {
    $PrimaryReplica = $primaryCandidate
} else {
    $PrimaryReplica = "$primaryCandidate\DEFAULT"
}

Write-Output "Using primary replica: $PrimaryReplica"

# Build the Secondary replica name for a default vs. named instance.
# For named instances, use ConvertTo-EncodedSqlName.
if ($SqlInstanceName -eq 'DEFAULT') {
    $SecondaryReplica = $HostName
} else {
    $SecondaryReplica = ConvertTo-EncodedSqlName -SqlName "$HostName\$SqlInstanceName"
}

# Set the PowerShell provider path using the chosen primary replica.
$PrimaryPSPath = "SQLSERVER:\Sql\$PrimaryReplica\AvailabilityGroups\$AgName\AvailabilityReplicas\"

# Verify that this path is connected to the primary replica by checking for an object with Role "Primary"
$agReplicas = Get-ChildItem $PrimaryPSPath
$primaryReplicaObject = $agReplicas | Where-Object { $_.Role -eq "Primary" }
if ($null -eq $primaryReplicaObject) {
    Write-Output "The path $PrimaryPSPath does not appear to be connected to the primary replica."
    $Ansible.Failed = $true
    return
}

# Retrieve the secondary replica object based on its display name.
$replica = $agReplicas | Where-Object { $_.DisplayName -eq $SecondaryReplica }
if ($null -eq $replica) {
    Write-Output "Replica $SecondaryReplica not found at path $PrimaryPSPath"
    $Ansible.Failed = $true
    return
}

# If the replica's current failover mode is not the target, update it.
if ($replica.FailoverMode -ne $TargetMode) {
    Set-SqlAvailabilityReplica -Path $replica.PSPath -FailoverMode $TargetMode
    Write-Output "Replica $SecondaryReplica failover mode changed to $TargetMode."
    $Ansible.Changed = $true
} else {
    Write-Output "Replica $SecondaryReplica is already set to $TargetMode. No changes made."
    $Ansible.Changed = $false
}