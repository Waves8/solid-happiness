#quick and dirty script to add a user to the local admin group
#experimenting with different ways of trying to create a powershell session with RunAs and via separate credentials
#like it says, it is quick and dirty - I'd prefer to set up parameters, prompts, try/catch/finally, logging, etc

# Just in case we do this via parameters and calling the script

# Some sort of format like ./script -userToAdd USERNAME
param (
[string]$userToAdd
)

clear-host
if ($userToAdd -eq "")
{
Write-Warning "Are you running the script from the new Administrator session? (y/n)"
Write-Host "Choose N if this is the initial run."
Write-Host "Choose Y if this is the Administrator session window."
$scriptRun = Read-Host
}
else
{
    $scriptRun = "y"
}

if ($scriptRun -eq "y")
{
    Write-Host "Script running from elevated window as $(whoami)." -ForegroundColor Cyan
    if ($userToAdd -eq "")
    {
        While ($userConfirm -ne "y")
        {
            # Get the user to be added
            Write-Host "Please type username to be added to Local Administrators(ex: LastnaF)"
            $userToAdd = Read-Host
        
            # Confirm the username typed correctly
            $userConfirm = Read-Host -Prompt "You entered $userToAdd. Correct? (y/n)"
        
            if ($userConfirm -ne "y")
                {
                    $bailOut = Read-Host -Prompt "Would you like to try again? (y/n)"
                    
                    if ($bailOut -eq "n")
                        {
                            Write-Host "Exiting script."
                            break
                        }
                }
        }    
    }
    else
            {
                Write-Host "Continuing with user to be added: $userToAdd"
            }
    

    Write-Host "Attempting to add $userToAdd to Local Administrators..." -ForegroundColor Cyan
    Add-localGroupMember -Group "administrators" -member "$userToAdd"
    Write-Host "Please review the members of Administrators group." -ForegroundColor Green
    Write-Host "If user has been added to group, script can be deleted." -ForegroundColor Green
    Get-LocalGroupMember -Group "administrators"
    Write-Host "Please remember to delete me: $PSCommandPath" -ForegroundColor Red
    Read-Host -Prompt "Press ENTER to exit"
}

else
{
    # Notify Support person executing script they will be prompted for credential
    Clear-Host
    Write-Host "Please enter the appropriate credential to add a user."
    Write-Host "Press ENTER to continue..."
    Read-Host
    
    # Obtain credential
    $userCredential = Get-Credential

    Clear-Host
    Write-Host "Please ask the user to accept the UAC prompt that appears." -ForegroundColor Green
#    Write-Host "Launch this script from the new Administrator window."
    Write-Host "Press ENTER to continue"
    Read-Host
    Start-Process powershell -Credential $userCredential -ArgumentList '-noprofile -command &{Start-Process powershell.exe -verb runas}'
}

#Invoke-Command -Credential $userCredential -ScriptBlock {Add-LocalGroupMember -Group "administrators" -member $userToAdd -whatif} -
#Start-Process powershell -Credential $userCredential -NoNewWindow -ArgumentList "start-process powershell.exe -nonewwindow -verb runas"
#Add-localGroupMember -Group "administrators" -member "$userToAdd"
#write-host "Use the following command in the new window to add the user."
#write-host "Add-localGroupMember -Group "administrators" -member "$userToAdd""

# Command to Add the user to the group
#net localgroup administrators /add domain\$userToAdd

# Elevate existing window
#Start-Process "powershell.exe -verb runAs" -Credential $userCredential -NoNewWindow
#Start-Process powershell -Credential $userCredential -NoNewWindow -ArgumentList '-noprofile -command &{Start-Process "powershell.exe" -verb runas}'

# Add the user
#Invoke-Command -Credential $userCredential -ScriptBlock {net localgroup administrators /add domain\$userToAdd}
#Invoke-Command -ScriptBlock {net localgroup administrators /add domain\$userToAdd}
