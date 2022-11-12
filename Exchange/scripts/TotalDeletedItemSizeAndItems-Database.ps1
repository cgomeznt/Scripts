
Get-Mailbox -Database $args[0] | Get-MailboxStatistics | ft displayname,totaldeleteditemsize,totalitemsize