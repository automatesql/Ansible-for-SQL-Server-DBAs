[CmdletBinding()]
param()

function Get-PendingReboot {
    $pendingReboot = $false

    # Windows Update: reboot required flag
    if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") {
        $pendingReboot = $true
    }

    # Pending file rename operations
    $pendingRenames = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -ErrorAction SilentlyContinue).PendingFileRenameOperations
    if ($pendingRenames) {
        $pendingReboot = $true
    }

    # Component-Based Servicing: pending reboot
    if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending") {
        $pendingReboot = $true
    }

    # UpdateExeVolatile key (used by some updates)
    if (Test-Path "HKLM:\SOFTWARE\Microsoft\Updates\UpdateExeVolatile") {
        $pendingReboot = $true
    }

    return $pendingReboot
}

if (Get-PendingReboot) {
    Write-Output "Pending reboot detected"
    $Ansible.Changed = $true
    Restart-Computer -Force
}
else {
    Write-Output "No pending reboot"
    $Ansible.Changed = $false
}