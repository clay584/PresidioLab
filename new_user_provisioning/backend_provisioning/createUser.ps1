# Get command arguments and assign to variables
[CmdletBinding()]
Param (
    [string]$Username,
    [string]$Department,
    [string]$ManagerFN,
    [string]$ManagerLN,
    [string]$FirstName,
    [string]$LastName,
    [string]$EmailAddress
)

$NumOfParams = 7
# Test to see if the script should exit..
If (($PSBoundParameters.values | Measure-Object | Select-Object -ExpandProperty Count) -lt $NumOfParams) {
    Write-Host "Not enough parameters given...exiting."
    exit
}

Import-Module ActiveDirectory

function New-SWRandomPassword {
    [CmdletBinding(DefaultParameterSetName='FixedLength',ConfirmImpact='None')]
    [OutputType([String])]
    Param
    (
        # Specifies minimum password length
        [Parameter(Mandatory=$false,
                   ParameterSetName='RandomLength')]
        [ValidateScript({$_ -gt 0})]
        [Alias('Min')] 
        [int]$MinPasswordLength = 8,
        
        # Specifies maximum password length
        [Parameter(Mandatory=$false,
                   ParameterSetName='RandomLength')]
        [ValidateScript({
                if($_ -ge $MinPasswordLength){$true}
                else{Throw 'Max value cannot be lesser than min value.'}})]
        [Alias('Max')]
        [int]$MaxPasswordLength = 12,

        # Specifies a fixed password length
        [Parameter(Mandatory=$false,
                   ParameterSetName='FixedLength')]
        [ValidateRange(1,2147483647)]
        [int]$PasswordLength = 8,
        
        # Specifies an array of strings containing charactergroups from which the password will be generated.
        # At least one char from each group (string) will be used.
        [String[]]$InputStrings = @('abcdefghijkmnpqrstuvwxyz', 'ABCEFGHJKLMNPQRSTUVWXYZ', '23456789', '!"#%&'),

        # Specifies a string containing a character group from which the first character in the password will be generated.
        # Useful for systems which requires first char in password to be alphabetic.
        [String] $FirstChar,
        
        # Specifies number of passwords to generate.
        [ValidateRange(1,2147483647)]
        [int]$Count = 1
    )
    Begin {
        Function Get-Seed{
            # Generate a seed for randomization
            $RandomBytes = New-Object -TypeName 'System.Byte[]' 4
            $Random = New-Object -TypeName 'System.Security.Cryptography.RNGCryptoServiceProvider'
            $Random.GetBytes($RandomBytes)
            [BitConverter]::ToUInt32($RandomBytes, 0)
        }
    }
    Process {
        For($iteration = 1;$iteration -le $Count; $iteration++){
            $Password = @{}
            # Create char arrays containing groups of possible chars
            [char[][]]$CharGroups = $InputStrings

            # Create char array containing all chars
            $AllChars = $CharGroups | ForEach-Object {[Char[]]$_}

            # Set password length
            if($PSCmdlet.ParameterSetName -eq 'RandomLength')
            {
                if($MinPasswordLength -eq $MaxPasswordLength) {
                    # If password length is set, use set length
                    $PasswordLength = $MinPasswordLength
                }
                else {
                    # Otherwise randomize password length
                    $PasswordLength = ((Get-Seed) % ($MaxPasswordLength + 1 - $MinPasswordLength)) + $MinPasswordLength
                }
            }

            # If FirstChar is defined, randomize first char in password from that string.
            if($PSBoundParameters.ContainsKey('FirstChar')){
                $Password.Add(0,$FirstChar[((Get-Seed) % $FirstChar.Length)])
            }
            # Randomize one char from each group
            Foreach($Group in $CharGroups) {
                if($Password.Count -lt $PasswordLength) {
                    $Index = Get-Seed
                    While ($Password.ContainsKey($Index)){
                        $Index = Get-Seed                        
                    }
                    $Password.Add($Index,$Group[((Get-Seed) % $Group.Count)])
                }
            }

            # Fill out with chars from $AllChars
            for($i=$Password.Count;$i -lt $PasswordLength;$i++) {
                $Index = Get-Seed
                While ($Password.ContainsKey($Index)){
                    $Index = Get-Seed                        
                }
                $Password.Add($Index,$AllChars[((Get-Seed) % $AllChars.Count)])
            }
            Write-Output -InputObject $(-join ($Password.GetEnumerator() | Sort-Object -Property Name | Select-Object -ExpandProperty Value))
        }
    }
}

If ($Department -ceq "SecureNetworks") {
    $Template = "sntemp"
    $DepartmentDescription = "SN"
}
elseIf ($Department -ceq "Mobility") {
    $Template = "mobtemp"
    $DepartmentDescription = "MOB"
}
elseIf ($Department -ceq "DataCenter") {
    $Template = "dctemp"
    $DepartmentDescription = "DC"
}
elseIf ($Department -ceq "Collaboration") {
    $Template = "cltemp"
    $DepartmentDescription = "CL"
}

$TemplateUser = Get-AdUser -Identity $Template -Properties memberOf
$DN = $TemplateUser.distinguishedName
$OldUser = [ADSI]"LDAP://$DN"
$Parent = $OldUser.Parent
$OU = [ADSI]$Parent
$OUDN = $OU.distinguishedName
$FullName = "$FirstName $LastName"
$UPN = ("{0}@presidiolab.local" -f $Username)
$Manager = "$ManagerFN$ManagerLN"
$Date = Get-Date
$Description = ("{0}/{1}/{2} - {3} - {4}" -f $Date.Month,$Date.Day,$Date.Year,$DepartmentDescription,$Manager)
$RawPassword = New-SWRandomPassword
$Password = ConvertTo-SecureString -String $RawPassword -asplaintext -force


New-ADUser -SamAccountName $Username -UserPrincipalName $UPN -EmailAddress $EmailAddress -DisplayName $FullName -Name $FullName -GivenName $firstname -Surname $lastname -Instance $DN -Path "$OUDN" -ChangePasswordAtLogon $false -PasswordNeverExpires $true -Enabled $true -Description $Description -AccountPassword $Password

$TemplateUser | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $Username

Write-Host "User: $Username created successfully."

$emailBody = @"
<!DOCTYPE html>
<html>
 <head>
  <meta charset="UTF-8">
  <title>Welcome to the Presidio Engineering Lab</title>
 </head>
 <body>
    <p>Welcome to the Presidio Engineering Lab.  Please use the link below to reset your password and then take a look at the Lab Wiki site for more information on using the lab.<br>

    </p>
    <table style="height: 200px; float: left;" border="1" width="800" cellspacing="0">
    <tbody>
    <tr>
    <td>First Name</td>
    <td>${FirstName}</td>
    </tr>
    <tr>
    <td>Last Name</td>
    <td>${LastName}</td>
    </tr>
    <tr>
    <td>Username</td>
    <td>${Username}</td>
    </tr>
    <tr>
    <td>Password</td>
    <td>${RawPassword}</td>
    </tr>
    <tr>
    <td>Initial Password Reset</td>
    <td>
    <p><a href="https://password.presidiolab.com:9000/pwm">Password Self-Service Portal</a></p>
    </td>
    </tr>
    <tr>
    <td>Getting Started Guide</td>
    <td>
    <p><a href="http://orl-wiki.presidiolab.local/doku.php">Lab Wiki Site</a></p>
    </td>
    </tr>
    </tbody>
    </table>
 </body>
</html>
"@

$smtpServer = "orl-tasker.presidiolab.local"
$To = "${FirstName} ${LastName} <${EmailAddress}>"
$From = "Presidio Engineering Lab <no-reply@presidiolab.com>"
$Subject = "Welcome to the Presidio Engineering Lab" 

send-MailMessage -SmtpServer $smtpServer -To $To -From $From -Subject $Subject -Body $emailBody -BodyAsHtml
