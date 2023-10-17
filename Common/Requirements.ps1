If (-Not (Get-AdministrativeAccess)) {
  Write-Error "This script requires administrative privileges to install modules."
  Exit 1
}

# Required PowerShell modules
[String[]] $RequiredModules = @(
  "Carbon.Windows.Installer",
  "Carbon.Cryptography",
  "Carbon.Core",
  "Carbon.Windows.HttpServer",
  "Carbon.IIS",
  "Carbon.Registry",
  "Carbon.FileSystem",
  "Carbon.Windows"
)

# Iterate through the required modules and install if missing
ForEach ($Module in $RequiredModules) {
  If ($Null -Eq (Get-Module -Name $Module -ListAvailable)) {
    Write-Warning "The required module '$Module' is not installed. Attempting to install..."
    Try {
      Install-Module -Name $Module -AllowClobber -Force -Scope AllUsers
      Write-Host "Module '$Module' installed."
    }
    Catch {
      Write-Error "The module '$Module' failed to install."
      Exit 1
    }
  }
}

