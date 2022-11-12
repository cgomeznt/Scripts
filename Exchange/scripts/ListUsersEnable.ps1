Get-User -RecipientTypeDetails UserMailbox -ResultSize Unlimited | where {$_.UseraccountControl -notlike �*accountdisabled*�} | Select-Object DisplayName,WindowsEmailAddress,UserAccountControl