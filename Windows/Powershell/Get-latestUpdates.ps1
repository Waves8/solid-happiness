# Alas I do not recall where I got this. Untested by me
# Actually, there are at least a couple different versions, both were in the same sub-Reddit post.
# https://www.reddit.com/r/PowerShell/comments/34u4aq/no_native_way_for_powershell_to_list_available/
# https://www.reddit.com/r/PowerShell/comments/9in5vc/how_do_you_automate_windows_updates_without_wsus/
# Here's one from Boe Prox
# https://gallery.technet.microsoft.com/scriptcenter/0dbfc125-b855-4058-87ec-930268f03285

param([Parameter(Mandatory=$true,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)][string[]] $ComputerName,
      [int] $NumJobs = 5,
      [switch] $PSRemoting,
      [switch] $NoPing,
      [switch] $CloseRunspacePool
     )

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$StartTime = Get-Date

function ql { $args }

$LastUpdates      = @{}
$LastUpdateErrors = @{}

$ScriptBlock = {
    
    param($Computer, $PSRemoting, $NoPing)
    
    # Do a ping check unless $NoPing is specified.
    if (-not $NoPing) {
        if (-not (Test-Connection -Count 1 -Quiet $Computer)) {
            $LastUpdateErrors.$Computer = 'No ping reply.'
            return
        }
    }

    # Use "local COM" (well, local, but remote via PS) and Invoke-Command if PSRemoting is specified.
    if ($PSRemoting) {
        
        try {
            
            $Result = Invoke-Command -ComputerName $Computer -ErrorAction Stop -ScriptBlock {
                
                [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.Update.Session') | Out-Null
                $Session = New-Object -ComObject Microsoft.Update.Session
                
                try {
                    
                    $UpdateSearcher   = $Session.CreateUpdateSearcher()
                    $NumUpdates       = $UpdateSearcher.GetTotalHistoryCount()
                    $InstalledUpdates = $UpdateSearcher.QueryHistory(1, $NumUpdates)
                    
                    if ($?) {
                        
                        $LastInstalledUpdate = $InstalledUpdates | Sort-Object -Property Date -Descending | Select-Object -First 1 Title, Date
                        # Return a collection/array. Later it is assumed that an array type indicates success.
                        # Errors are of the class [System.String]. -- Well, that didn't work so well in retrospect.
                        $LastInstalledUpdate.Title, $LastInstalledUpdate.Date
                        
                    }
                    
                    else {
                        
                        "Error. Win update search query failed: $($Error[0] -replace '[\r\n]+')"
                        
                    }
                    
                } # end of inner try block
                
                catch {
                    
                    $LastUpdateErrors.$Computer = "Error (terminating): $($Error[0] -replace '[\r\n]+')"
                    continue
                    
                }
                
            } # end of Invoke-Command
            
        } # end of outer try block
        
        # Catch the Invoke-Command errors here
        catch {
            
            $LastUpdateErrors.$Computer = "Error with Invoke-Command: $($Error[0] -replace '[\r\n]+')"
            continue
            
        }
        
        # $Result here is what's returned from the invoke-command call.
        # I can't populate the data hashes inside the Invoke-Command due to variable scoping.
        if (-not $Result -is [array]) {
            
            $LastUpdateErrors.$Computer = $Result
            
        }
        
        else {
            
            $Title, $Date = $Result[0,1]
            
            $LastUpdates.$Computer = New-Object PSObject -Property @{
                
                'Title' = $Title
                'Date'  = $Date
                
            }
            
        }
        
    }
    
    # If -PSRemoting isn't provided as an argument, try remote COM.
    else {
        
        try {
            
            [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.Update.Session')
            $Session = [activator]::CreateInstance([type]::GetTypeFromProgID("Microsoft.Update.Session", $Computer))
        
            $UpdateSearcher   = $Session.CreateUpdateSearcher()
            $NumUpdates       = $UpdateSearcher.GetTotalHistoryCount()
            $InstalledUpdates = $UpdateSearcher.QueryHistory(1, $NumUpdates)
            
            if ($?) {
                
                $LastInstalledUpdate   = $InstalledUpdates | Sort-Object -Property Date -Descending | Select-Object -First 1 Title, Date
                $LastUpdates.$Computer = New-Object PSObject -Property @{
                    
                    'Title' = $LastInstalledUpdate.Title
                    'Date'  = $LastInstalledUpdate.Date
                    
                }
                
            }
            
            else {
                
                $LastUpdateErrors.$Computer = "Error. Win update search query failed: $($Error[0].ToString())"
                
            }
            
        }
        
        catch {
            
            $LastUpdateErrors.$Computer = "Terminating error: $($Error[0].ToString())"
            
        }
        
    }

} # end of script block

# Set up runspace stuff.
$SessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
$SessionState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry ‘LastUpdates’, $LastUpdates, ''))
$SessionState.Variables.Add((New-Object System.Management.Automation.Runspaces.SessionStateVariableEntry ‘LastUpdateErrors’, $LastUpdateErrors, ''))
$RunspacePool = [runspacefactory]::CreateRunspacePool(1, $NumJobs, $SessionState, $Host)
$RunspacePool.ApartmentState = "STA"
$RunspacePool.ThreadOptions = "ReuseThread"
$RunspacePool.Open()

#$RunspacePool.SessionStateProxy.SetVariable("Data", $Data)

'Starting jobs... ' + (Get-Date)

$Jobs = foreach ($Computer in $ComputerName) {
    
    $Job = [powershell]::Create().AddScript($ScriptBlock).AddArgument($Computer).AddArgument($PSRemoting).AddArgument($NoPing)
    $Job.RunspacePool = $RunspacePool
    
    New-Object psobject -Property @{
        Object = $Job
        Result = $Job.BeginInvoke()
    }

} # end of computers foreach

'Finished starting jobs. ' + (Get-Date)

$Ctr = 0
Write-Host -Fore Green -NoNewline "Waiting for jobs to finish."

while (@($Jobs | %{ $_.Result.IsCompleted }) -contains $false) {
    
    Start-Sleep -Seconds 5
    if (++$Ctr -eq 6) {
        if (-not ($Host.Name -like '*PowerShell ISE*')) {
            Write-Host -Fore Green -NoNewline ("`b" * 5)
            Write-Host -Fore Green -NoNewline (' ' * 5)
            Write-Host -Fore Green -NoNewline ("`b" * 5)
        }
        $Ctr = 0
    }
    else {
        write-Host -Fore Green -NoNewline '.'
    }

}

''; 'Jobs should have finished. ' + (Get-Date)

# "Export" data to a global hash.
'Exporting global variables $LastUpdates and $LastUpdateErrors to the host.'
$Global:LastUpdates = $LastUpdates
$Global:LastUpdateErrors = $LastUpdateErrors

foreach ($Job in $Jobs) {
    
    $Job.Object.EndInvoke($Job.Result)
    $Job.Object.Dispose()
    $Job.Object = $null

}

'Disposed job objects. ' + (Get-Date)

# It seems to hang here sometimes, so I made it optional.
if ($CloseRunspacePool) {
    'Trying to close runspace pool. ' + (Get-Date)
    $RunspacePool.Close()
    'Closed runspace pool. ' + (Get-Date)
}

<#
foreach ($Computer in $ComputerName | Where { $_ -match '\S' }) {
    
    Write-Host -NoNewline -Fore Green "`rProcessing ${Computer}...                          "
    
    $script:ContinueFlag = $false
    
    if ( -not (Test-Connection -Quiet -Count 1 -ComputerName $Computer) ) {
        
        $LastUpdateErrors.$Computer = 'Error: No ping reply'
        continue
        
    }
    
}
#>

# Define properties for use with Select-Object
$Properties = 
    @{n='Server'; e={$_.Name}},
    @{n='Date';   e={$_.Value.Date}},
    @{n='Title';  e={$_.Value.Title}}

$Global:LastUpdateProperties = $Properties

# Create HTML header used for both HTML reports.
$HtmlHead = @"
<title>Last Update Report ($(Get-Date -uformat %Y-%m-%d))</title>
<style type='text/css'>
    
    table        { width: 100%; border-collapse: collapse }
    td, th       { color: black; padding: 2px; }
    tr:nth-child(odd)  { background-color: #FFF }
    tr:nth-child(even) { background-color: #CCC }
    th           { background-color: #C7C7C7; text-align: left }
    td           { background-color: #F7F7F7; text-align: left }
    
</style>
"@

$StartHtml = @"
Error count:   $($LastUpdateErrors.Values.Count)
Success count: $($LastUpdates.Values.Count)
Total count:   $([int] $LastUpdateErrors.Values.Count + $LastUpdates.Values.Count)
"@

## Create HTML data
# Create HTML body for updates report (successfully processed hosts)
$HtmlBody = $StartHtml
$HtmlBody += $LastUpdates.GetEnumerator() | Sort -Property @{Expression={$_.Value.Date}; Ascending=$false},@{Expression={$_.Name}; Ascending=$true} |
    Select-Object -Property $Properties | ConvertTo-Html -Fragment
ConvertTo-Html -Head $HtmlHead -Body $HtmlBody | Set-Content last-updates.html

# Creating new HTML Body for hosts with errors.
Clear-Variable HtmlBody
$HtmlBody = $StartHtml
$HtmlBody += $LastUpdateErrors.GetEnumerator() | Sort -Property Name | Select-Object Name,Value | ConvertTo-Html -Fragment
ConvertTo-Html -Head $HtmlHead -Body $HtmlBody | Set-Content last-updates-errors.html

## Create CSV data
# Create last update CSV file
$LastUpdates.GetEnumerator() | Sort -Property @{Expression={$_.Value.Date}; Ascending=$false},@{Expression={$_.Name}; Ascending=$true} |
    Select-Object -Property $Properties | ConvertTo-Csv | Set-Content last-updates.csv

# Create error CSV file
$LastUpdateErrors.GetEnumerator() | Sort -Property Name | Select-Object Name,Value |
    ConvertTo-Csv | Set-Content last-updates-errors.csv


@"

Error count:   $($LastUpdateErrors.Values.Count)
Success count: $($LastUpdates.Values.Count)
Total count:   $([int] $LastUpdateErrors.Values.Count + $LastUpdates.Values.Count)

Script start time: $StartTime
Script end time::  $(Get-Date)
HTML Output files: last-updates.html, last-updates-errors.html
CSV Output files:  last-updates.csv,  last-updates-errors.csv
Variables:         `$LastUpdates, `$LastUpdateErrors, `$LastUpdateProperties

"@
