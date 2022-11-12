
# Mueve los mailbox activos de un servidor hacia la copia, el siguiente ejemplo, muve todas las Base de Datos activas del
# servidor SRV-VCCS-MAIL1 hacia el servidor de copia SRV-VCCS-MAIL2
# Move-ActiveMailboxDatabase -Server SRV-VCCS-MAIL1


Move-ActiveMailboxDatabase -Server $args[0]