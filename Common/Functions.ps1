Function Get-AdministrativeAccess {
  # Returns $False if not running as administrator
  [Boolean] $Admin = (`
    [System.Security.Principal.WindowsPrincipal] `
    [System.Security.Principal.WindowsIdentity]::GetCurrent()
  ).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
  return $Admin
}
