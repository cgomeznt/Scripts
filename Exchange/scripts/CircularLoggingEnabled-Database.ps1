Get-MailboxDatabase | select name, circularloggingenabled | sort circularloggingenabled -desc | ft -AutoSize