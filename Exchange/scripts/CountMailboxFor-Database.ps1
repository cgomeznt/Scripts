(Get-MailboxDatabase) | ForEach-Object {Write-Host $_.Name (Get-Mailbox -Database $_.Name).Count}