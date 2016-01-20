
<#
.DESCRIPTION
Installs Posh-SSH as this is a depandancy.

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

	Import-Module -Name Posh-SSH
}

<#
.DESCRIPTION
Creates a new session to the loadbalancer, meaning multible sessions could be created
each connected to seperate loadbalancers.

.PARAMETER server
Specifies the server to connect to.

.PARAMETER username
Specifies the username to connect with when connecting to the server.

.PARAMETER password
Specifies the password to connect with when connecting to the server.

.EXAMPLE
New-LoadBalancerSession -Server "192.168.1.100" -Username "root" -Password "loadbalancer"
#>
function New-LoadBalancerSession
{
	param (
		[Parameter(Mandatory=$true)]
		[string]$server,

		[Parameter(Mandatory=$true)]
		[string]$username,

		[string]$password
	)

	$serverCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$password

	return New-SSHSession -ComputerName $server -Credential $serverCredential -AcceptKey
}

<#
.DESCRIPTION
Sets the selected node to halted.

.PARAMETER session
Specifies the loadbalancer session used when running the command.

.PARAMETER vip
Specifies the vIP name that will be selected when halting the node.

.PARAMETER rip
Specifies the rIP name that will be selected when halting the node.

.EXAMPLE
Halt-Server -Session $session -vip "External Website" -rip "Node 1"
#>
function Halt-Server
{
	param (
		[Parameter(Mandatory=$true)]
		[object]$session,

		[Parameter(Mandatory=$true)]
		[string]$vip,

		[Parameter(Mandatory=$true)]
		[string]$rip
	)

	return Invoke-SSHCommand -SSHSession $session -Command $("lbcli --action halt --vip " + $vip + " --rip " + $rip)
}

<#
.DESCRIPTION
Sets the selected node to drained.

.PARAMETER session
Specifies the loadbalancer session used when running the command.

.PARAMETER vip
Specifies the vIP name that will be selected when draning the node.

.PARAMETER rip
Specifies the rIP name that will be selected when draning the node.

.EXAMPLE
Drain-Server -Session $session -vip "External Website" -rip "Node 1"
#>
function Drain-Server
{
	param (
		[Parameter(Mandatory=$true)]
		[object]$session,

		[Parameter(Mandatory=$true)]
		[string]$vip,
		
		[Parameter(Mandatory=$true)]
		[string]$rip
	)

	return Invoke-SSHCommand -SSHSession $session -Command $("lbcli --action drain --vip " + $vip + " --rip " + $rip)
}

<#
.DESCRIPTION
Sets the selected node to online.

.PARAMETER session
Specifies the loadbalancer session used when running the command.

.PARAMETER vip
Specifies the vIP name that will be selected when onlining the node.

.PARAMETER rip
Specifies the rIP name that will be selected when onlining the node.

.EXAMPLE
Online-Server -Session $session -vip "External Website" -rip "Node 1"
#>
function Online-Server
{
	param (
		[Parameter(Mandatory=$true)]
		[object]$session,

		[Parameter(Mandatory=$true)]
		[string]$vip,
		
		[Parameter(Mandatory=$true)]
		[string]$rip
	)

	return Invoke-SSHCommand -SSHSession $session -Command $("lbcli --action online --vip " + $vip + " --rip " + $rip)
}



