# Este script fue gracias a:
# http://www.brianbeaulieu.com/2013/02/monitoring-for-mailbox-failover.html


param([string]$DB)
add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010             

# default to critical, only have a return of 0 upon successful match
# $Status = 2

# Customnize This:
# If your primary servers share a common string, you can try to use wildcards. Otherwise a different
# script might be needed for each of your servers along with separate Zabbix userParameter.
# This will need to be customized accordingly. 
# The main issue is making sure that your servers at Data Center B do not match
# $PrimaryServerString

#  Esta es la línea que debe modificarse para eliminar la alarma en Zabbix (Cambiar por el SRV-VCCS-MAIL1)
$PrimaryServerString = "SRV-VCCS-MAIL2"

$ServerStr = "SRV-VCCS-MAIL2"

# don't print errors, it'll confuse zabbix
$ErrorActionPreference = "SilentlyContinue"

ForEach ($Type in Get-MailboxDatabase -identity * )
{
 #Debug
 #Write-Host $Type.Server
  
 if ($Type.Server -like $PrimaryServerString )
 {
  # Debug
  #Write-Host "Databases Mounted @ Data Center B"
  $Status = 0 
  Write-Host $Type.Name $Status
  C:\"Program Files\zabbix_agent\bin\win64\"zabbix_sender.exe -c C:\"Program Files\zabbix_agent\conf\"zabbix_agentd.conf  -z srv-vccs-zabbix.credicard.com.ve -s $ServerStr -k $Type.Name -o $Status
 } else {
  # Debug
  #Write-Host $Type.Name "Mounted on" $Type.Server
  $Status = 2 
  Write-Host $Type.Name $Status
  C:\"Program Files\zabbix_agent\bin\win64\"zabbix_sender.exe -c C:\"Program Files\zabbix_agent\conf\"zabbix_agentd.conf  -z srv-vccs-zabbix.credicard.com.ve -s $ServerStr -k $Type.Name -o $Status
 }
}

# Zabbix does not want any \r\n
# Write-Host $Status # -nonewline
# Write-Host $DB

# Este otro script es para Sacar el Status de las Copias

$Valor = "Failed"
$Valor1 = "Crawling"
$status = 0

ForEach ($Type in D:\scripts\StatusCopy-Database.ps1 )
{
 #Debug
 #Write-Host $Type.Server
  
  $variable = $Type.ContentIndexState
  # Write-Host $variable

 if ($Type.ContentIndexState -like $Valor )
 {
   $status = 2 
   # Write-Host $status
 }
 elseif ($Type.ContentIndexState -like $Valor1 )
 {
   $status = 3
   # Write-Host $status
 }
} 
Write-Host $status > D:\Temp\prueba.txt
C:\"Program Files\zabbix_agent\bin\win64\"zabbix_sender.exe -c C:\"Program Files\zabbix_agent\conf\"zabbix_agentd.conf  -z srv-vccs-zabbix.credicard.com.ve -s $ServerStr -k StatusCopyDatabase -o $status


# Este otro script es para Sacar el Status de las Base de Datos

$Valor = "Suspended"
$Valor1 = "Dismounted" 
$Valor2 = "Failed"
$Valor3 = "Seeding"
$status = 0

ForEach ($Type in D:\scripts\StatusCopy-Database.ps1 )
{
 #Debug
 #Write-Host $Type.Server
  
  $variable = $Type.Status
  # Write-Host $variable

 if ($Type.Status -like $Valor )
 {
   $status = 2 
   # Write-Host $status
 }
 elseif ($Type.Status -like $Valor1 )
 {
   $status = 3
   # Write-Host $status
 }
 elseif ($Type.Status -like $Valor2 )
 {
   $status = 4
   # Write-Host $status
 }
 elseif ($Type.Status -like $Valor3 )
 {
   $status = 5
   # Write-Host $status
 }
} 
Write-Host $status > D:\Temp\prueba.txt
C:\"Program Files\zabbix_agent\bin\win64\"zabbix_sender.exe -c C:\"Program Files\zabbix_agent\conf\"zabbix_agentd.conf  -z srv-vccs-zabbix.credicard.com.ve -s $ServerStr -k StatusDatabase -o $status

# Sentencia para obtener buzones en DB distinta a DB Egresados y moverlos a BD Egresados
# Get-MailboxDatabase | where {$_.Name -notlike "Egresados"} | Get-Mailbox  -OrganizationalUnit Egresados | New-MoveRequest -BadItemLimit 100 -AcceptLargeDataLoss -TargetDatabase Egresados

# Get-MoveRequest -MoveStatus Completed | Remove-MoveRequest -Confirm:$False
