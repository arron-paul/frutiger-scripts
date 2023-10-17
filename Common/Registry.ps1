
Function Update-Registry {
  param (
    [String]$Path,
    [String]$Name,
    [String]$Type,
    $Value
  )

  If (-Not (Test-CRegistryKeyValue -Path $Path -Name $Name)) {
    # If the registry path/key doesn't exist, ignore
    Return
  }

  $CurrentValue = Get-CRegistryKeyValue -Path $Path -Name $Name

  If (-Not ($Value -Eq $CurrentValue)) {
    Switch ($Type) {
      'String' {
        Set-CRegistryKeyValue -Path $Path -Name $Name -String $Value
      }
      'DWord' {
        Set-CRegistryKeyValue -Path $Path -Name $Name -DWord $Value
      }
      'UDWord' {
        Set-CRegistryKeyValue -Path $Path -Name $Name -UDWord $Value
      }
      'QWord' {
        Set-CRegistryKeyValue -Path $Path -Name $Name -QWord $Value
      }
      'UQWord' {
        Set-CRegistryKeyValue -Path $Path -Name $Name -UQWord $Value
      }
      'Binary' {
        Set-CRegistryKeyValue -Path $Path -Name $Name -Binary $Value
      }
      Default {
        Write-Error "Unsupported registry type: $Type"
        Exit 1
      }
    }
  }

}
