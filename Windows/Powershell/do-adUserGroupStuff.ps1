#Not really a script, just a collection of things

#From a list of usernames, output to a gridview the AD account and value for enabled (true/false)
$users = get-content "PATH\TO\FILE"
$test = foreach ($user in $users){
Get-ADUser -Identity $user | Select-Object samaccountname,enabled
}
$test | Out-GridView

#Add users to a group GROUPNAME from a list of usernames
$users = get-content "PATH\TO\FILE"
$test = foreach ($user in $users) {
Add-ADGroupMember -Identity $GroupName -Members $user
}

#Get members of AD group and output in sort reverse order
Get-ADGroupMember -Identity $GroupName | Select-Object samaccountname | Sort-Object samaccountname -Descending
