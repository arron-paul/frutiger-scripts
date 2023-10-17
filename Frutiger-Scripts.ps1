<#
.SYNOPSIS
Collection of Windows-centric scripts.

.DESCRIPTION
An entrypoint to run scripts in an unsupervised ‘Scheduled’ mode and an on-demand ‘Single’ mode.
Scheduled mode iterates and executes all valid scripts in the Scripts directory and works
well when integrated into a Scheduled Task.

Single mode executes one or more tasks that are defined in the -Script parameter.
Whilst a single task could be directly executed, invoking it through this entrypoint
allows the task to have context of shared helper functions and utility methods.

.PARAMETER Mode
The mode of operation (Scheduled or Single). Default is Scheduled.

.PARAMETER Script
List of script names to be executed.
The script name is the filename of the script without the .ps1 extension.

.PARAMETER Exclude
List of script names to be excluded from running.
Useful when combined with -Mode Scheduled
#>

Param (
  [Parameter(Mandatory = $False)]
  [ValidateSet("Scheduled", "Single")]
  [String] $Mode = "Scheduled",

  [Parameter(Mandatory = $False)]
  [String[]] $Scripts,

  [Parameter(Mandatory = $False)]
  [String[]] $Excludes
)

. $PSScriptRoot/Common/Bootstrap.ps1

# Validate no -Scripts defined when -Mode is Scheduled
If ($Mode -Eq "Scheduled" -And $Null -Ne $Scripts) {
  Write-Error "No need to define -Scripts as all scripts will run on Scheduled mode"
  Exit 1
}

# Validate one or more items in -Scripts when -Mode is Single
If ($Mode -Eq "Single" -And $Scripts.Count -Eq 0) {
  Write-Error "One or more -Scripts must be defined on Single mode"
  Exit 1
}

# Find the script directory
[System.IO.DirectoryInfo] $ScriptsDirectory = [System.IO.DirectoryInfo]::new(
  (Join-Path -Path $PSScriptRoot -ChildPath "Scripts")
)

# Find all scripts within $ScriptsDirectory
[System.IO.FileInfo[]] $ScriptFiles = `
  Get-ChildItem -Path $ScriptsDirectory -Filter "*.ps1" -File -Recurse

# Activate Lo-fi PowerShell progress bar
Write-Progress -Id 0 -Activity "Frutiger Scripts"

Function Invoke-Script {
  Param (
    [Parameter(Mandatory = $True)]
    [String] $ScriptName,

    [Parameter(Mandatory = $True)]
    [System.IO.DirectoryInfo] $ScriptPath
  )
  Try {
    . $ScriptPath
    Write-Progress -Id 0 $ScriptName -Activity "Frutiger Scripts"
    . "Invoke-$ScriptName" -ErrorAction SilentlyContinue > $Null 2>&1
  }
  Catch {
    Write-Error "Error executing script: $ScriptPath"
    Write-Error $_.Exception.Message
  }
}

ForEach ($ScriptFile In $ScriptFiles) {

  [String] $ScriptName = [System.IO.Path]::GetFileNameWithoutExtension((Split-Path -Path $ScriptFile -Leaf))

  # Skip script if specified in -Excludes
  If ($ScriptName -Contains $Excludes) {
    Write-Host "Skipping script $ScriptName"
    Continue
  }

  Switch ($Mode) {
    "Single" {
      ForEach ($Script In $Scripts) {
        If ($Script -Eq $ScriptName) {
          Invoke-Script -ScriptName $ScriptName -ScriptPath $ScriptFile.FullName
        }
      }
    }
    "Scheduled" {
      Invoke-Script -ScriptName $ScriptName -ScriptPath $ScriptFile.FullName
    }
  }

}

Exit 0
