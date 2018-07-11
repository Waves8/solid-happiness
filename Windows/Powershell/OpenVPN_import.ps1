# Path to OpenVPN installation directory, also where profiles will be dropped
$ovpnpath = "\path\to\ovpn"

# If statement to check if the OpenVPN Client folder exists
if (test-path -path $ovpnpath)
  {

<#
# Looks like I was able to do it via invoke-expression, and a friend was able to get it to read the variable via "&"
# So now I have a way I can "get it to work", but I have to do a lame set-location hop
# and I also know that I might be able to get it to work via "&"
$profiles = get-childitem -path "\path\to\ovpnfiles" *vpn.ovpn | select Name
# If the folder exists, then for each .ovpn file...
     foreach($profile in $profiles.name)
       {
# For each .ovpn file that exists do...
# Import the profile
         $profilepath = "\path\to\ovpnfiles\$profile"
         write-host "Attempting to import profile $profilepath"
         set-location -path "\path\to\capicli.exe"
         invoke-expression './capicli.exe -f $profilepath importprofilefromfile'
#>

<#
# Actually I did "crack" how to do it, see below

# Properly looping...
# If the folder exists, then for each .ovpn file...
     foreach($profile in $profiles.name)
       {
#          copy-item "\path\to\ovpn\profiles\$_" -destination '\path\to\ovpn\install\OpenVPN Technologies\OpenVPN Client\core'
# For each .ovpn file that exists do...
# Import the profile
         $profilepath = "\path\to\ovpn\profiles\$profile"
         write-host "Attempting to import profile $profilepath"
         set-location -path "\path\to\ovpn\install\OpenVPN Technologies\OpenVPN Client\core"
         invoke-expression './capicli.exe -f $profilepath importprofilefromfile'
         <#
         $profilepath = '\path\to\ovpn\profiles\$profile'
         $arg1 = '-f'
         $arg2 = $profilepath
         $arg3 = 'importprofilefromfile'
         & "\path\to\ovpn\install\OpenVPN Technologies\OpenVPN Client\core\capicli.exe" $arg1 $arg2 $arg3
         #>
       }

  }

  
  else
    {
      write-host "$ovpnpath does not exist"
    }
#>

# Individual If statements since I haven't cracked how to pass a variable to Call Operator so that capicli.exe does not reference variable as literal string
# Each If statement will attempt to import a profile after successfully confirming it exists
    if (test-path -path "\path\to\avpn.ovpn")
      {
        & '\path\to\capicli.exe' '-f' '\path\to\avpn.ovpn' 'importprofilefromfile'
      }
      else
        {
          write-host "$profile does not exist."
        }
    if (test-path -path "\path\to\bvpn.ovpn")
      {
        & '\path\to\capicli.exe' '-f' '\path\to\bvpn.ovpn' 'importprofilefromfile'
      }
      else
        {
          write-host "$profile does not exist."
        }
    if (test-path -path "\path\to\cvpn.ovpn")
      {
        & '\path\to\capicli.exe' '-f' '\path\to\cvpn.ovpn' 'importprofilefromfile'
      }
      else
        {
          write-host "$profile does not exist."
        }
    if (test-path -path "\path\to\dvpn.ovpn")
      {
        & '\path\to\capicli.exe' '-f' '\path\to\dvpn.ovpn' 'importprofilefromfile'
      }
      else
        {
          write-host "$profile does not exist."
        }
  }
  
  else
    {
      write-host "$ovpnpath does not exist"
    }
