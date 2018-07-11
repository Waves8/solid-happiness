#Not really a script, just a collection of things

#From a list of usernames, output to a gridview the AD account and value for enabled (true/false)
$users = get-content "PATH\TO\FILE"
$test = foreach ($user in $users){
get-aduser -identity $user | select-object samaccountname, enabled
}
$test | Out-GridView

#Add users to a group GROUPNAME from a list of usernames
$users = get-content "PATH\TO\FILE"
$test = foreach ($user in $users){
add-adgroupmember -identity GROUPNAME -members $user
}


#Get members of AD group and output in sort reverse order
get-adgroupmember -Identity GROUPNAME | select samaccountname | sort-object samaccountname -Descending
