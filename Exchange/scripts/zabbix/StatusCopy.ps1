
$valor=(D:\scripts\StatusCopy-Database.ps1 | findstr "Failed" | Measure-Object -line).Lines
C:\"Program Files\zabbix_agent\bin\win64\"zabbix_sender.exe -c C:\"Program Files\zabbix_agent\conf\"zabbix_agentd.conf  -z srv-vccs-zabbix.credicard.com.ve -s SRV-VCCS-MAIL2 -k StatusCopyDatabase -o $valor
