
<#
.DESCRIPTION
Installs Posh-SSH as this is a dependency.

.EXAMPLE
Install-Dependencies
#>
function Install-Dependencies
{
	if (!(Get-Module -ListAvailable -Name Posh-SSH))
	{
		if ($PSVersionTable.PSVersion.Major -ge 5)
		{
			Install-Module -Name Posh-SSH
		}
		else
		{
			iex (New-Object Net.WebClient).DownloadString("https://gist.github.com/darkoperator/6152630/raw/c67de4f7cd780ba367cccbc2593f38d18ce6df89/instposhsshdev")
		}
	}

	Import-Module -Name Posh-SSH -ErrorAction Stop
}

<#
.DESCRIPTION
Creates a new session to the load balancer, meaning multiple sessions could be created
each connected to separate load balancers.

.PARAMETER appliance
Specifies the appliance (server) address to connect to.

.PARAMETER username
Specifies the username to connect with when connecting to the server.

.PARAMETER password
Specifies the password to connect with when connecting to the server.
Specifies the password for the private key, if a private key is used.

.PARAMETER key
Specifies the private key to connect with when connecting to the server.

.EXAMPLE
Connect to the load balancer with a username and password.

New-LBConnection -Appliance "192.168.1.100" -Username "root" -Password "loadbalancer"

.EXAMPLE
Connect to the load balancer with a public/private keypair.

New-LBConnection -Appliance "192.168.1.100" -Username "root" -Password "loadbalancer" -key "C:\Users\User\id_rsa"
#>
function New-LBConnection
{
	param (
		[Parameter(Mandatory=$true)]
		[string]$appliance,

		[Parameter(Mandatory=$true)]
		[string]$username,

		[string]$password,

		[string]$key
	)

	if ([string]::IsNullOrEmpty($password))
	{
		if ($key -eq $null)
		{
			$message = "Enter ${username}'s ssh password"
		}
		else
		{
			$message = "Enter ${username}'s private key password"
		}

		$serverCredential = Get-Credential -Username $username -Message $message
	}
	else
	{
		$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
		$serverCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$securePassword
	}

	if ($key -eq $null)
	{
		return New-SSHSession -ComputerName $appliance -Credential $serverCredential -AcceptKey
	}
	else
	{
		return New-SSHSession -ComputerName $appliance -Credential $serverCredential -AcceptKey -Key $key
	}
}

<#
.DESCRIPTION
Sets the selected node to halted.

.PARAMETER connection
Specifies the load balancer connection to be used when running the command.

.PARAMETER vip
Specifies the VIP name that the RIP belongs too.

.PARAMETER rip
Specifies the RIP name.

.EXAMPLE
Invoke-LBRipHalt -Connection $connection -Vip "PROD-EXTERNAL-WEBSITES" -Rip "PROD-RIP-1"
#>
function Invoke-LBRipHalt
{
	param (
		[Parameter(Mandatory=$true)]
		[object]$connection,

		[Parameter(Mandatory=$true)]
		[string]$vip,

		[Parameter(Mandatory=$true)]
		[string]$rip
	)

	return Invoke-SSHCommand -SSHSession $connection -Command $("lbcli --action halt --vip " + $vip + " --rip " + $rip)
}

<#
.DESCRIPTION
Sets the selected node to drained.

.PARAMETER connection
Specifies the load balancer connection to be used when running the command.

.PARAMETER vip
Specifies the VIP name that the RIP belongs too.

.PARAMETER rip
Specifies the RIP name.

.EXAMPLE
Invoke-LBRipDrain -Connection $connection -Vip "PROD-EXTERNAL-WEBSITES" -Rip "PROD-RIP-1"
#>
function Invoke-LBRipDrain
{
	param (
		[Parameter(Mandatory=$true)]
		[object]$connection,

		[Parameter(Mandatory=$true)]
		[string]$vip,

		[Parameter(Mandatory=$true)]
		[string]$rip
	)

	return Invoke-SSHCommand -SSHSession $connection -Command $("lbcli --action drain --vip " + $vip + " --rip " + $rip)
}

<#
.DESCRIPTION
Sets the selected node to online.

.PARAMETER connection
Specifies the load balancer connection to be used when running the command.

.PARAMETER vip
Specifies the VIP name that the RIP belongs too.

.PARAMETER rip
Specifies the RIP name.

.EXAMPLE
Invoke-LBRipOnline -Connection $connection -Vip "PROD-EXTERNAL-WEBSITES" -Rip "PROD-RIP-1"
#>
function Invoke-LBRipOnline
{
	param (
		[Parameter(Mandatory=$true)]
		[object]$connection,

		[Parameter(Mandatory=$true)]
		[string]$vip,

		[Parameter(Mandatory=$true)]
		[string]$rip
	)

	return Invoke-SSHCommand -SSHSession $connection -Command $("lbcli --action online --vip " + $vip + " --rip " + $rip)
}

<#
.DESCRIPTION
Allows for a custom command to be executed on the load balancer.

.PARAMETER connection
Specifies the load balancer connection to be used when running the command.

.PARAMETER command
Specifies the command to execute.

.EXAMPLE
Invoke-LBCustomCommand -Connection $connection -Command "df -h | grep /dev/sda1"
#>
function Invoke-LBCustomCommand
{
	param (
		[Parameter(Mandatory=$true)]
		[object]$connection,

		[Parameter(Mandatory=$true)]
		[string]$command
	)

	return Invoke-SSHCommand -SSHSession $connection -Command $command
}

<#
.DESCRIPTION
Closes the ssh connection to the load balancer.

.PARAMETER connection
Specifies the load balancer connection to be closed.

.EXAMPLE
Remove-LBSession -Connection $connection
#>

function Remove-LBSession
{
	param (
		[Parameter(Mandatory=$true)]
		[object]$connection
	)

	return Remove-SSHSession -SessionId $connection.SessionId
}

Export-ModuleMember -function *
