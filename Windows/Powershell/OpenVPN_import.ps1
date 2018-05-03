# Path to OpenVPN installation directory, also where profiles will be dropped
$ovpnpath = "C:\Program Files (x86)\OpenVPN Technologies\OpenVPN Client"

# If statement to check if the OpenVPN Client folder exists
if (test-path -path $ovpnpath)
  {

# Individual If statements since I haven't cracked how to pass a variable to Call Operator so that capicli.exe does not reference variable as literal string
# Each If statement will attempt to import a profile after successfully confirming it exists
    if (test-path -path "C:\Program Files (x86)\OpenVPN Technologies\OpenVPN Client\bvevpn.ovpn")
      {
        & 'C:\Program Files (x86)\OpenVPN Technologies\OpenVPN Client\core\capicli.exe' '-f' 'C:\Program Files (x86)\OpenVPN Technologies\OpenVPN Client\bvevpn.ovpn' 'importprofilefromfile'
      }
      else
        {
          write-host "$profile does not exist."
        }
    if (test-path -path "C:\Program Files (x86)\OpenVPN Technologies\OpenVPN Client\lonvpn.ovpn")
      {
        & 'C:\Program Files (x86)\OpenVPN Technologies\OpenVPN Client\core\capicli.exe' '-f' 'C:\Program Files (x86)\OpenVPN Technologies\OpenVPN Client\lonvpn.ovpn' 'importprofilefromfile'
      }
      else
        {
          write-host "$profile does not exist."
        }
    if (test-path -path "C:\Program Files (x86)\OpenVPN Technologies\OpenVPN Client\mlyvpn.ovpn")
      {
        & 'C:\Program Files (x86)\OpenVPN Technologies\OpenVPN Client\core\capicli.exe' '-f' 'C:\Program Files (x86)\OpenVPN Technologies\OpenVPN Client\mlyvpn.ovpn' 'importprofilefromfile'
      }
      else
        {
          write-host "$profile does not exist."
        }
    if (test-path -path "C:\Program Files (x86)\OpenVPN Technologies\OpenVPN Client\melvpn.ovpn")
      {
        & 'C:\Program Files (x86)\OpenVPN Technologies\OpenVPN Client\core\capicli.exe' '-f' 'C:\Program Files (x86)\OpenVPN Technologies\OpenVPN Client\melvpn.ovpn' 'importprofilefromfile'
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
