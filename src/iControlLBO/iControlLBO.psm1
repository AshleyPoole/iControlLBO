
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

.EXAMPLE
New-LBConnection -Appliance "192.168.1.100" -Username "root" -Password "loadbalancer"
#>
function New-LBConnection
{
	param (
		[Parameter(Mandatory=$true)]
		[string]$appliance,

		[Parameter(Mandatory=$true)]
		[string]$username,

		[string]$password
	)

	if ($password -eq $null)
	{
		$serverCredential = Get-Credential -Username $username
	} else {
		$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
		$serverCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$securePassword
	}

	return New-SSHSession -ComputerName $appliance -Credential $serverCredential -AcceptKey
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

Export-ModuleMember -function *
