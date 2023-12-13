### LNR

Configs und Backups der verschiedenen Streams und doodles dazwischen

### Zu beachten

Alle Configs hier enthalten meine public-keys vom Host
bitte in der eigenen Testumgebung eigene keys verwenden!

Alle ansible Playbooks enthalten u.U. auch meinen user bzw. keys
-> bitte ebenfalls anpassen

### Grundsätzliches zum Setup

ansible läuft bei mir auf dem Proxmox-Host
Dieser hat noch ein vmbr1001 auf dem die Management-IPs
der vyos-VMs erreichbar sind.

In diesem vmbr1001 gibt es kein Gateway, auch die vyos-VMs haben
einfach nur eine IP dort drin.

Das ist eine Krücke und wird im realen Leben anders gemacht,
hier ist es einfach nur der Einfachheit so damit man sich nicht
Huhn-Ei-Problemen aufhalten muss und die initiale Config schneller geht.

### Worum geht's hier überhaupt?

Hier landen Configs die wir in Twitch-Streams zu den Themen ansible und Netzwerk
erarbeitet haben, so dass man selber weiter probieren kann.

Streams finden statt auf https://twitch.tv/aibix0001

Freitags 20:30 "ansible und automation"
	 hier wollen wir ansible lernen und im Laufe der Zeit Dinge
	 automatisieren die wir in den Samstag-Streams gebaut haben.

Samstags 21:30 "late night routing"
	 hier bei geht es, wie der Titel schon verrät, um Netzwerk und Routing
	 wir machen eine "Journey" von statischen Routen über OSPF, BGP zu MPLS
	 und schauen uns dabei an wie ein ISP Netz aufgebaut ist.

Sonntags 11:00 unregelmäßiger Frühschoppen
	 verschiedene Themen und/oder Bastelkrams