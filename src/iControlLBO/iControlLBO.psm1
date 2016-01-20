<#
	My Function
#>
function Get-Function {

}


function Install-Dependencies {
	if (Get-Module -ListAvailable -Name Posh-SSH) {
		Write-Host "Module exists"
		Import-Module -Name Posh-SSH
	} else {
		if ($psversiontable.PSVersion -ge "5")
		{
			try
			{
				Install-Module -Name Posh-SSH
			}
			catch
			{
				Write-Error "Failed to installled required module: Posh-SSH"
			}
		}
		else
		{
			iex (New-Object Net.WebClient).DownloadString("https://gist.github.com/darkoperator/6152630/raw/c67de4f7cd780ba367cccbc2593f38d18ce6df89/instposhsshdev")
		}
	}
}

function New-LoadBalancerSession {
	PARAM (
		[string]$server,
		[string]$username,
		[string]$password
	)

	$serverCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$securePassword

	return New-SSHSession -ComputerName $server -Credential $serverCredential -AcceptKey
}

function Halt-Server {
	PARAM (
		[object]$session,
		[string]$vip,
		[string]$rip
	)

	Invoke-SSHCommand -SSHSession $session -Command ("lbcli --action halt --vip " + $vip + " --rip " + $rip)
}