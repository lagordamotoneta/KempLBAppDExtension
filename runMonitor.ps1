
# Determine Script Path & Set Globals
$invocation = (Get-Variable MyInvocation).Value
$runDir = Split-Path $invocation.MyCommand.Path
$propFile = $runDir + '\monitor.properties'
$logfile = $runDir + '\monitor.log'

# Import External Functions
. $runDir"\Function-LogWrite.ps1"

# Start Monitoring Tasks

# Read From Properties File
$file_content = Get-Content $propFile
$file_content = $file_content -join [Environment]::NewLine
$configuration = ConvertFrom-StringData($file_content)

$monitored_vs_ips=$configuration.'monitored_vs_ips'.Split(",")
$monitored_vs_ports=$configuration.'monitored_vs_ports'.Split(",")
$monitored_rs_ips=$configuration.'monitored_rs_ips'.Split(",")
$monitored_rs_ports=$configuration.'monitored_rs_ports'.Split(",")


$Params = @{
"URI"     = "https://"+ $configuration.'kemp_lb_ip'+"access/stats"
"Method"  = 'GET'
"Body" = @{"kemp_api_key" = $configuration.'kemp_api_key'
}
}


try {
            $oXMLDocument = Invoke-RestMethod @Params

           <#
           $oXMLDocument=New-Object System.XML.XMLDocument
           $oXMLDocument.Load($runDir+"\stats.xml")#>


           if($oXMLDocument.Response.stat -eq 200){
                Write-Host $oXMLDocument.Response.stat

               #CPU
               $oCPU=$oXMLDocument.selectNodes('//CPU/*')
               foreach($elem in $oCPU ){
                    Write-Host $elem
                    $MAReq="name="+ $configuration.'metric_path'+$elem.ParentNode.Name+"|"+$elem.LocalName
                    foreach($smt in $elem.ChildNodes){
                        $additional="|"+$smt.Name +",value=" + [Long]$smt.InnerText
                        $Final= $MAReq + $additional
                        Write-Host $Final
                    }
                }
                #Network
                $oNetwork=$oXMLDocument.selectNodes('//Network/*')
                foreach($elem in $oNetwork ){
                    $MAReq="name="+ $configuration.'metric_path'+$elem.ParentNode.Name+"|"+$elem.LocalName
                    foreach($smt in $elem.ChildNodes){
                        $additional="|"+$smt.Name +",value=" + [Long]$smt.InnerText
                        $Final= $MAReq + $additional
                        Write-Host $Final
                    }
                }

                #Memory
                $oMemory=$oXMLDocument.selectNodes('//Memory/*')

                foreach($elem in $oMemory ){
                     $MAReq="name="+ $configuration.'metric_path'+$elem.ParentNode.Name+'|'+$elem.Name  +",value=" + [Long]$elem.InnerText
                       Write-Host $MAReq
                    }

                #VSTotals
                $oVStotals=$oXMLDocument.selectNodes('//VStotals/*')

                foreach($elem in $oVStotals ){
                     $MAReq="name="+ $configuration.'metric_path'+$elem.ParentNode.Name+'|'+$elem.Name  +",value=" + [Long]$elem.InnerText
                       Write-Host $MAReq
                    }

                #DiskUsage
                #The path used for this one will change according to the directory on the disk. ie:
                $oDiskUsage=$oXMLDocument.selectNodes('//DiskUsage/*')
                #$oDiskUsage.OuterXml
                foreach($elem in $oDiskUsage ){
                    $MAReq="name="+ $configuration.'metric_path'+$elem.ParentNode.Name+"|"+$elem.LocalName
                    foreach($smt in $elem.ChildNodes){

                        if ($smt.Name -eq "name"){
                            $volName="|"+$smt.InnerText

                            }
                        else{
                                $additional=$volName+"|"+$smt.Name +",value=" + [Long]$smt.InnerText
                                $Final= $MAReq + $additional}
                                Write-Host $Final


                    }
                }

                #VS
                $oVs=$oXMLDocument.selectNodes('//Vs')
                foreach($elem in $oVs.Where{$_.VSAddress -in $monitored_vs_ips -and $_.VSPort -in $monitored_vs_ports} ){
                    $MAReq="name="+ $configuration.'metric_path'+$elem.LocalName + "|" + $elem.VSAddress + "|" + $elem.VSProt+ "|Port|" + $elem.VSPort
                    foreach($smt in $elem.ChildNodes.Where{$_.Name -notin ("VSAddress","VSPort","VSProt","Index")}){
                        if ($smt.Name -eq "Status"){
                            if ($smt.InnerText -eq "up"){
                               #write status 1
                               $upStatus=1
                               $writeStatus = $MAReq + "|" + $smt.Name + ",value=" + [Long]$upStatus
                               Write-Host $writeStatus
                            }else{
                               $upStatus=0
                               $writeStatus = $MAReq + "|" + $smt.Name +  ",value=" + [Long]$upStatus
                               Write-Host $writeStatus
                            }

                        }else{

                        $Final= $MAReq + "|" + $smt.Name  +",value=" + [Long]$smt.'#text'
                        Write-Host $Final
                        }
                    }
                }


                #RS
                $oRs=$oXMLDocument.selectNodes('//Rs')
                foreach($elem in $oRs.Where{$_.Addr -in $monitored_rs_ips -and $_.Port -in $monitored_rs_ports } ){
                    $MAReq="name="+ $configuration.'metric_path'+$elem.LocalName + "|" + $elem.Addr + "|Port|" + $elem.Port
                    foreach($smt in $elem.ChildNodes.Where{$_.Name -notin ("VSIndex","RSIndex","Addr","Port")}){
                        $Final= $MAReq + "|" + $smt.Name  +",value=" + [Long]$smt.'#text'
                        Write-Host $Final

                    }
                }

           }


       }
       catch {
           Write-Host "ERROR"
           Write-Host $_

       }
