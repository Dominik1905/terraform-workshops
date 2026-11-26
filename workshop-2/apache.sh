#!/bin/bash
# Bei einem Fehler abbrechen und die Installation ohne Rückfragen ausführen.
set -e
export DEBIAN_FRONTEND=noninteractive

# Paketlisten aktualisieren und Apache installieren.
apt-get update
apt-get install -y apache2

# Apache jetzt starten und für künftige Systemstarts aktivieren.
systemctl enable --now apache2

# Der Browser soll beim Aufruf der Startseite Hello World anzeigen.
echo '<h1>Hello World</h1>' > /var/www/html/index.html
