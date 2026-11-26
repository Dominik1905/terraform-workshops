#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

# Bei einem vorübergehenden Fehler des Paketservers erneut versuchen.
for attempt in 1 2 3 4 5; do
  if apt-get --error-on=any update &&
     apt-get -o Acquire::Retries=3 install -y apache2; then
    break
  fi

  if [ "$attempt" -eq 5 ]; then
    echo 'Apache konnte nach fünf Versuchen nicht installiert werden.' >&2
    exit 1
  fi

  sleep 45
done

# Apache starten und die Seite sowie die Testdatei bereitstellen.
systemctl enable --now apache2
printf '<h1>Hello World</h1>\n' > /var/www/html/index.html
hostname > /var/www/html/instance.txt
