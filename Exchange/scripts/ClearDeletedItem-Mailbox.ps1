Get-Mailbox -Database $args[0] | search-mailbox -searchquery "Subject:'*'" -DeleteContent -SearchDumpsterOnly