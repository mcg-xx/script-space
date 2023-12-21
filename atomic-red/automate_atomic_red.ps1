# INFO: Run the following script as an Administrator, otherwise it wont execute

# Check if the script is running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    # When not executed as admin, restart the script again as administrator
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $($MyInvocation.MyCommand.Path)" -Verb RunAs
    exit
}

# Set execution policy to Bypass
Set-ExecutionPolicy Bypass -Scope Process -Force

# Import the module "Invoke-AtomicRedteam"
Import-Module "C:\AtomicRedTeam\invoke-atomicredteam\Invoke-AtomicRedTeam.psd1" -Force

# Path to main folder with (sub-)techniques
$mainFolder = "C:\AtomicRedTeam\atomics"

# Get all subfolders from the main folder
$subfolders = Get-ChildItem -Path $mainFolder -Directory

# Execute every technique (Based on subfolder name)
foreach ($folder in $subfolders) {
    $folderName = $folder.Name
    $command_exec = "Invoke-AtomicTest $folderName"
    $command_cleanup = "Invoke-AtomicTest $folderName -Cleanup"
    # Show the technique which is currently used
    
    # Execute commands
    Write-Host "!!! EXECUTE THE FOLLOWING TECHNIQUE: $folderName"
    Invoke-Expression -Command $command_exec
    Write-Host "!!! CLEANUP AFTER THE FOLLOWING TECHNIQUE: $folderName"
    Invoke-Expression -Command $command_cleanup
}
