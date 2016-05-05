# iControlLBO
PowerShell module for interacting and controlling LoadBalancer.Org appliances

## Usage

### Import module
```powershell
if (!(Get-Module iControlLBO)) {
  Import-Module iControlLBO
}
```

### View available commands from module
```powershell
Get-Command -Module iControlLBO
```

This shows for example:

```powershell
CommandType     Name                                               ModuleName
-----------     ----                                               ----------
Function        Install-Dependencies                               iControlLBO
Function        Invoke-LBRipDrain                                  iControlLBO
Function        Invoke-LBRipHalt                                   iControlLBO
Function        Invoke-LBRipOnline                                 iControlLBO
Function        New-LBConnection                                   iControlLBO
```

### Install pre-requisites
```powershell
Install-Dependencies
```

If for some reason there's a naming conflict with the `Install-Dependencies`
function and another module, run `iControlLBO\Install-Dependencies` instead.

### Establish connection to LB
Create the connection and save it to a variable:
```powershell
$ssh_con = New-LBConnection
```

`New-LBConnection` will prompt you for any missing fields, e.g. username,
password, hostname.

#### Establish connection with username/password
```powershell
$ssh_con = New-LBConnection -appliance $hostname -username $username -password $password
```

#### Establish connection with public/private keypair without passphrase on private key
```powershell
$ssh_con = New-LBConnection -appliance $hostname -username $username -key "C:\full\path\to\my\key"
```
It will prompt you for a password, simply hit enter.

#### Establish connection with public/private keypair with passphrase on private key
```powershell
$ssh_con = New-LBConnection -appliance $hostname -username $username -key "C:\full\path\to\my\key"
```

Enter password at prompt, or as a command line argument with `-password $password`

### Start/halt/drain a RIP

#### Start RIP
```powershell
Invoke-LBRipOnline -connection $ssh_con -vip web -rip web1
```

```
Host       : hostname
Output     : {, , CLI: online web1 web1 completed}
ExitStatus : 0
```

#### Drain RIP
```powershell
Invoke-LBRipDrain -connection $ssh_con -vip web -rip web1
```

```
Host       : hostname
Output     : {, , CLI: drain web1 web1 completed}
ExitStatus : 0
```

#### Halt RIP
```powershell
Invoke-LBRipHalt -connection $ssh_con -vip web -rip web1
```

```
Host       : hostname
Output     : {, , CLI: halt web1 web1 completed}
ExitStatus : 0
```

### Other

#### Custom Commands
```powershell
Invoke-LBCustomCommand -connection $ssh_con -command "df -h | grep /dev/sda1"
```

```
Host       : hostname
Output     : {/dev/sda1       2.6G  1.1G  1.3G  46% /}
ExitStatus : 0
```

