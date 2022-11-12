# Este script es el encardado de buscar dentro de todas las Base de datos de Exchangetodos los usuarios 
# que se encuentran en la OU de Egresados y moverlos hacia la Base de Datos de Egresados


param([string]$DB)
add-pssnapin Microsoft.Exchange.Management.PowerShell.E2010     


# Sentencia para obtener de las distinta DB los usuarios que estan en la OU e Egresados y moverlos a la BD Egresados
Get-MailboxDatabase | where {$_.Name -notlike "Egresados"} | Get-Mailbox  -OrganizationalUnit Egresados | New-MoveRequest -BadItemLimit 100 -AcceptLargeDataLoss -TargetDatabase Egresados


# Sentencia que remueve unicamente los request del tipo Completed
Get-MoveRequest -MoveStatus Completed | Remove-MoveRequest -Confirm:$False
