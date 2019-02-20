# Another useful tool I found
# It's useful for on-prem, but a bit of a mess as it needs to handle the EWS/O365
# Powershell throttling and also work on efficiency (like only pulling the 
# mailboxes of Enabled users or something like that.
# Things like these!
# https://gist.github.com/Rick-2CA/97eee640eb669b69a63a3da6e834ff6c
# https://code.msdn.microsoft.com/office/PowerShell-Merge-mailbox-e769c529
# https://blogs.technet.microsoft.com/exchange/2015/11/02/running-powershell-cmdlets-for-large-numbers-of-users-in-office-365/
# https://blogs.msdn.microsoft.com/exchangedev/2011/06/23/exchange-online-throttling-and-limits-faq/

#====================================================
# Get-InboxRule-External-and-RedirectTo.ps1
# Author: Sunil Chauhan
# Email:Sunilkms@gmail.com
# website:sunil-Chauhan.blogspot.com
# This scripts gets all the forwarding and redirectTo Rules and `
# Create a Report in a presentable format.
#====================================================
#Edit report Name Below.
$reportName="Forwarding-Rules-Report.csv"

#Getting All Mailbox in the Environment
Write-host "Getting All Mailboxes.."
$AllMailboxes = Get-Mailbox -resultSize unlimited

#if you Just need to Target User Mailbox only untag the below like and tag the one above.
#$AllMailboxes = Get-Mailbox -RecipientTypeDetails userMailbox -ResultSize unlimited 

#Placeholder for Rule Collection
$AllRules = @()

#counter
$c=0

#Loop through each mailbox to fetch the Inbox Rules
foreach ($mbx in $allMailboxes)
{
$c++
Write-host "$C : Getting Rules For User Mailbox:" $mbx.Alias
$mbxRules= Get-InboxRule -Mailbox $mbx.Alias
$AllRules+=$MbxRules
}

#Filtering Forwarding Rules
#$Rules = $AllRules | ? {$_.Description -match "@" -and $_.ForwardTo -ne $null -or $_.RedirectTo -ne $null}
$Rules = $AllRules | ? {$_.ForwardAsAttachmentTo -ne $null -or $_.ForwardTo -ne $null -or $_.RedirectTo -ne $null}

#Placeholder for saving Report Data
$RulesDATA=@()

#Run Through Each Rule to prelare Report
foreach ($rule in $Rules)
{
#Getting Data from ForwardAsAttachmentTo Rule
if ($rule.ForwardAsAttachmentTo)
{
if (($rule.ForwardAsAttachmentTo).Count   -gt 1)
{
foreach ($entry in $rule.ForwardAsAttachmentTo)
{
#if ($entry -match "@")
#{
 $RulesD= New-Object -TypeName PSObject
 $RulesD| Add-Member -MemberType NoteProperty -Name Mailbox -Value $rule.MailboxOwnerID
 $RulesD| Add-Member -MemberType NoteProperty -Name ForwardAsAttachmentTo -Value $($entry | % {$($_.split("[")[0]).Replace('"',"")})
 $RulesD| Add-Member -MemberType NoteProperty -Name ForwardTo -Value "n/a"
 $RulesD| Add-Member -MemberType NoteProperty -Name RedirectTo -Value "n/a"
 $RulesDATA+=$rulesD
 #}
}
}
#Else{
#if ($rule.ForwardAsAttachmentTo -match "@")
#{
# $RulesD= New-Object -TypeName PSObject
# $RulesD| Add-Member -MemberType NoteProperty -Name Mailbox -Value $rule.MailboxOwnerID
# $RulesD| Add-Member -MemberType NoteProperty -Name ForwardAsAttachmentTo -Value $($rule.ForwardAsAttachmentTo  | % {$($_.split("[")[0]).Replace('"',"")})
# $RulesD| Add-Member -MemberType NoteProperty -Name ForwardTo -Value "n/a"
# $RulesD| Add-Member -MemberType NoteProperty -Name RedirectTo -Value "n/a"
# $RulesDATA+=$rulesD
#}
   }
#}
#Getting Data from ForwardTo Rule
if ($rule.ForwardTo)
{
if (($rule.ForwardTo).Count   -gt 1)
{
foreach ($entry in $rule.ForwardTo)
{
#if ($entry -match "@")
#{
 $RulesD= New-Object -TypeName PSObject
 $RulesD| Add-Member -MemberType NoteProperty -Name Mailbox -Value $rule.MailboxOwnerID
 $RulesD| Add-Member -MemberType NoteProperty -Name ForwardAsAttachmentTo -Value "n/a"
 $RulesD| Add-Member -MemberType NoteProperty -Name ForwardTo -Value $($entry | % {$($_.split("[")[0]).Replace('"',"")})
 $RulesD| Add-Member -MemberType NoteProperty -Name RedirectTo -Value "n/a"
 $RulesDATA+=$rulesD
 #}
}
}
#Else{
#if ($rule.ForwardTo -match "@")
#{
# $RulesD= New-Object -TypeName PSObject
# $RulesD| Add-Member -MemberType NoteProperty -Name Mailbox -Value $rule.MailboxOwnerID
# $RulesD| Add-Member -MemberType NoteProperty -Name ForwardAsAttachmentTo -Value "n/a"
# $RulesD| Add-Member -MemberType NoteProperty -Name ForwardTo -Value $($rule.ForwardTo  | % {$($_.split("[")[0]).Replace('"',"")})
# $RulesD| Add-Member -MemberType NoteProperty -Name RedirectTo -Value "n/a"
# $RulesDATA+=$rulesD
#}
   }
#}
#Getting Data from RedirectTo Rule
if ($rule.RedirectTo)
{
if (($rule.RedirectTo).Count   -gt 1)
{
foreach ($entry in $rule.RedirectTo)
{
# if ($entry -match "@") 
#{
 $RulesD= New-Object -TypeName PSObject
 $RulesD| Add-Member -MemberType NoteProperty -Name Mailbox -Value $rule.MailboxOwnerID
 $RulesD| Add-Member -MemberType NoteProperty -Name ForwardAsAttachmentTo -Value "n/a"
 $RulesD| Add-Member -MemberType NoteProperty -Name ForwardTo -Value n/a
 $RulesD| Add-Member -MemberType NoteProperty -Name RedirectTo -Value $($entry  | % {$($_.split("[")[0]).Replace('"',"")})
 $RulesDATA+=$rulesD
#}
}
}
#Else{
#if ($rule.RedirectTo -match "@") 
#{
# $RulesD= New-Object -TypeName PSObject
# $RulesD| Add-Member -MemberType NoteProperty -Name Mailbox -Value $rule.MailboxOwnerID
# $RulesD| Add-Member -MemberType NoteProperty -Name ForwardAsAttachmentTo -Value "n/a"
# $RulesD| Add-Member -MemberType NoteProperty -Name ForwardTo -Value "N/A"
# $RulesD| Add-Member -MemberType NoteProperty -Name RedirectTo -Value $($rule.RedirectTo  | % {$($_.split("[")[0]).Replace('"',"")})
# $RulesDATA+=$rulesD 
# }
}
#}
}

#exporting report Data to Csv File
$RulesDATA | Export-Csv $reportName -notype
