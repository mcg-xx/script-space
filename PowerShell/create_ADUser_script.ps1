Get-Module ImportExcel
Get-Module ActiveDirectory

(Get-ADDomainController).Name

#region prep work
# Import spreadsheet
$SpreadSheet = 'C:\path\to\file.xlsx'
$Data = Import-Excel $SpreadSheet

# Check the data
$Data | Format-Table

# Correlate fields
$expectedProperties = @{
    Name = 'Full Name'
    GivenName = 'First Name'
    Surname = 'Last Name'
    Title = 'Job Title'
    Department = 'Department'
    OfficePhone = 'Phone Number'
}

# Correlate 'Manager' field
Get-Help New-ADUser -Parameter Manager


Get-ADUser $Data[0].Manager

Get-ADUser $Data[0].Manager.Replace(' ', '.')

# Manager
$Data[0].Manager.Replace(' ', '.')

# SamAccountName
"$($Data[0].'First Name').$($Data[0].'Last Name')"

# Create a single user
$user = $Data[0]
$params = @{}
ForEach($property in $expectedProperties.GetEnumerator()){
    # If the new user has the property
    If($user."$($property.value)".Length -gt 0){
        # Add it to the splat
        $params["$($property.Name)"] = $user."$($property.value)"
    }
}

If($user.Manager.length -gt 0){
    $params['Manager'] = $user.Manager.Replace(' ', '.')
}
$params['SamAccountName'] = "$($user.$($expectedProperties['GivenName'])).$($user.$($expectedProperties['Surname']))"
# Create the user
New-ADUser @params

# Did it work
Get-ADUser $params.SamAccountName 

#endregion

#region Create a function
Function Import-ADUsersFromSpreadsheet {
    [cmdletbinding()]
    Param(
        [ValidatePattern('.*\.xlsx$')]
        [ValidateNotNullOrEmpty()]
        [string]$PathToSpreadsheet
    )
    
    # Hashtable to correlate properties
    $expectedProperties = @{
        Name        = 'Full Name'
        GivenName   = 'First Name'
        Surname     = 'Last Name'
        Title       = 'Job Title'
        Department  = 'Department'
        OfficePhone = 'Phone Number'
    }
    
    # Import the required module for Import-Excel function
    Import-Module ImportExcel -ErrorAction Stop
    
    # Make sure the xlsx exists
    If(Test-Path $PathToSpreadsheet) {
        $data = Import-Excel $PathToSpreadsheet
        ForEach($user in $data) {
            # Build a splat
            $params = @{}
            ForEach($property in $expectedProperties.GetEnumerator()) {
                # If the new user has the property
                If($user."$($property.Value)".Length -gt 0) {
                    # Add it to the splat
                    $params["$($property.Name)"] = $user."$($property.Value)"
                }
            }
            # Deal with other values
            If($user.Manager.Length -gt 0) {
                $params['Manager'] = $user.Manager.Replace(' ', '.')
            }
            $params['SamAccountName'] = "$($user.$($expectedProperties['GivenName'])).$($user.$($expectedProperties['Surname']))"
            New-ADUser @params
        }
    }
    else {
        Write-Error "The file path '$PathToSpreadsheet' does not exist."
    }
}

# Usage
Import-ADUsersFromSpreadsheet -PathToSpreadsheet '.\FILE.xlsx'

# Verify
$data = Import-Excel '.\FILE.xlsx'
ForEach($user in $data) {
    Get-ADUser "$($user.'First Name').$($user.'Last Name')" | Select-Object Name
}