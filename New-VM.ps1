$vCenterServer="172.23.32.55"
$vCenterUser="administrator@vsphere.local"
$vCenterPassword="JSFeb.&3B"

$csvfile="C:\Users\jichengxi\Desktop\test.csv"

$NewVMs=Import-Csv $csvfile
$NewVMs=$NewVMs |Where-Object {$_.name -ne ""}
[INT]$VMsCount=($NewVMs).count
Write-Host -ForegroundColor Yellow "New VMs to create: $VMsCount"
if ($VMsCount -lt 1)
{
    Write-Host -ForegroundColor Yellow "Error: No entries found in DeployVM.csv"
    Write-Host -ForegroundColor Yellow "Exiting..."
    Exit
}

Try {
	Write-Host "Connecting to vCenter-vCenter" 
	Connect-VIServer $vCenterServer -user $vCenterUser -password $vCenterPassword -EA Stop | Out-Null
} Catch {
    Write-Host -ForegroundColor Yellow "Unable to connect to MIX-vCenter"
    Write-Host -ForegroundColor Yellow "Exiting..."
    Exit
}

$taskTab = @{}
foreach ($VM in $NewVMs)
{
    $error.Clear()
    $Name=$VM.VMName
    $vmname=$VM.VMName

    Get-OSCustomizationSpec -Name $VM.Spec |New-OSCustomizationSpec -Name temp-$vmname -Type NonPersistent
    Get-OSCustomizationNicMapping -Spec temp-$vmname |Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $VM.IpAddress1 -SubnetMask "255.255.255.0" -DefaultGateway $VM.GateWay1 |Out-Null
    $taskTab[(New-VM -Name $vmname -vmhost $VM.ResourcePool -Location $VM.Location -Datastore $VM.ResourcePool -DiskStorageFormat $VM.DiskStorageFormat -Template $VM.Template -OSCustomizationSpec temp-$vmname -RunAsync -EA SilentlyContinue).Id] = $Name
    Remove-OSCustomizationSpec -OSCustomizationSpec temp-$vmname -Confirm:$false
}

while ("1" -eq "1")
{
    $RunningTasks=(Get-Task -Status running).count
    if ($RunningTasks -eq 0)
    {
        foreach($task in $taskTab.keys)
        {
            if((Get-Task -Id $task).state -eq "Success")
            {
                $VM=$taskTab.$task
                $VMconfig=$NewVMs |Where-Object {$_.VMName -eq $VM}
                Set-VM -VM $VMconfig.VMName -NumCpu $VMconfig.CPU -MemoryGB $VMconfig.RAM -Confirm:$false | Out-Null
                
                $VDPortGroup1=Get-VDPortgroup -Name $VMconfig.VDPortgroup1
                $VDPortGroup2=Get-VDPortgroup -Name $VMconfig.VDPortgroup2
                Get-VM $VMconfig.VMName |Get-NetworkAdapter |Where-Object {$_.Name -like "????? 1"}|Set-NetworkAdapter -Portgroup $VDPortGroup1 -Confirm:$false | Out-Null
                Get-VM $VMconfig.VMName |Get-NetworkAdapter |Where-Object {$_.Name -like "????? 2"}|Set-NetworkAdapter -Portgroup $VDPortGroup2 -Confirm:$false | Out-Null
                # Boot VM
                if ($VMconfig.Boot -match "true")
                {
                    Get-VM $VMconfig.VMName |Start-VM -EA SilentlyContinue | Out-Null
                    
                    Start-Sleep -Seconds 10
                    $DelNet2GayWay="sed -i '/^GATEWAY/'d /etc/sysconfig/network-scripts/ifcfg-ens224"
                    Invoke-VMScript -VM $VMconfig.VMName -ScriptType Bash -GuestUser root -GuestPassword "Bestpay!2016" -ScriptText $DelNet2GayWay -Confirm:$false | Out-Null
                                    
                    $Net2IP="$VMconfig.IpAddress2"
                    $SetNet2Ip="sed -i '/^IPADDR=/c\IPADDR=$Net2IP' /etc/sysconfig/network-scripts/ifcfg-ens224"
                    Invoke-VMScript -VM $VMconfig.VMName -ScriptType Bash -GuestUser root -GuestPassword "Bestpay!2016" -ScriptText $SetNet2Ip -Confirm:$false | Out-Null
                    
                    # $IPSPLIT=$Net2IP -split '\.'
                    # $Net2GateWay=$IPSPLIT[0]+"."+$IPSPLIT[1]+"."+$IPSPLIT[2]+".254"
                    $Net2GateWay=$VMconfig.GateWay2
                    $SetNet2RouteClean="echo '' > /etc/sysconfig/network-scripts/route-ens224"
                    $SetNet2Route1="echo '172.22.0.0/16 via $Net2GateWay' > /etc/sysconfig/network-scripts/route-ens224"
                    $SetNet2Route2="echo '172.30.0.0/16 via $Net2GateWay' >> /etc/sysconfig/network-scripts/route-ens224"
                    $SetNet2Route3="echo '172.29.0.0/16 via $Net2GateWay' >> /etc/sysconfig/network-scripts/route-ens224"
                    Invoke-VMScript -VM $VMconfig.VMName -ScriptType Bash -GuestUser root -GuestPassword "Bestpay!2016" -ScriptText $SetNet2RouteClean -Confirm:$false | Out-Null
                    Invoke-VMScript -VM $VMconfig.VMName -ScriptType Bash -GuestUser root -GuestPassword "Bestpay!2016" -ScriptText $SetNet2Route1 -Confirm:$false | Out-Null
                    Invoke-VMScript -VM $VMconfig.VMName -ScriptType Bash -GuestUser root -GuestPassword "Bestpay!2016" -ScriptText $SetNet2Route2 -Confirm:$false | Out-Null
                    Invoke-VMScript -VM $VMconfig.VMName -ScriptType Bash -GuestUser root -GuestPassword "Bestpay!2016" -ScriptText $SetNet2Route3 -Confirm:$false | Out-Null
                }
            }
        }
        break
    }
    Start-Sleep -Seconds 10
}



