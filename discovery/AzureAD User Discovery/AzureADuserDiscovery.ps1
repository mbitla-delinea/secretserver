$azureappclientid = $args[0]
$azureappclientsecret = $args[1]
$azuretenantname  =  $args[2] 
$targetdomain =  $args[3]  
 
<## comment if this is not required
Import-Module azuread


$encpassword = ConvertTo-SecureString $azureadminpassword -AsPlainText -Force
$cred  = New-Object System.Management.Automation.PSCredential ($azureadminusername, $encpassword)
#$cred= Get-Credential

Connect-AzureAD -TenantId $azuretenantid -Credential $cred
$users = Get-AzureADUser
#>



$ReqTokenBody = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    client_Id     = $azureappclientid
    Client_Secret = $azureappclientsecret
} 
$TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$azuretenantname/oauth2/v2.0/token" -Method POST -Body $ReqTokenBody
$apiUrl = 'https://graph.microsoft.com/v1.0/Users/'
$apiGroupUrl = 'https://graph.microsoft.com/v1.0/Users/'
$Data = Invoke-RestMethod -Headers @{Authorization = "Bearer $($Tokenresponse.access_token)"} -Uri $apiUrl -Method Get
$users = ($Data | select-object Value).Value

$accounts = New-Object System.Collections.ArrayList
foreach($user in $users){
       $info = New-Object PSObject
       if($user.Mail -ne $null){
        $info | Add-Member Noteproperty Username $user.Mail
       }else{
        $info | Add-Member Noteproperty Username $user.UserPrincipalName     
       }
       $info | Add-Member Noteproperty ObjectId $user.id
       $info | Add-Member Noteproperty DisplayName $user.DisplayName       
       #$info | Add-Member Noteproperty UserType $user.UserType
       #$info | Add-Member Noteproperty Domain $targetdomain
        $id = $accounts.Add($info)               
}

return $accounts
