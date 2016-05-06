<#
EXAMPLE

In this example we drain and halt a node on our intranet VIP, We can then run our automated tasks and then online the node once complete.

#>

$internalLB = New-LBConnection -appliance "192.168.1.40" -username "root" -password "Passw0rd"

#Drain Intranet (Node 1)
Invoke-LBRipDrain -connection $internalLB -vip "VIP-INTRANET" -rip "RIP-INTRANET-NODE1"

#Wait 5 Minutes
Start-Sleep (60 * 5)

#Halt Intranet (Node 1)
Invoke-LBRipHalt -connection $internalLB -vip "VIP-INTRANET" -rip "RIP-INTRANET-NODE1"

#Maintinence Window
#=========================================


<# Run Commands in here #>


#=========================================

#Online Intranet (Node 1)
Invoke-LBRipOnline -connection $internalLB -vip "VIP-INTRANET" -rip "RIP-INTRANET-NODE1"
