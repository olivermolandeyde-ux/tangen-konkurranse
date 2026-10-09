#!/bin/bash
# Alt-i-ett-oppsett for VPS-en (Ubuntu). Kjør DENNE ENE kommandoen fra hjemmemappen:
#   git clone https://github.com/olivermolandeyde-ux/tangen-konkurranse.git konkurranse && cd konkurranse && sudo ./setup-vps.sh
# Scriptet er idempotent – trygt å kjøre på nytt (restarter serveren).
set -e
cd "$(dirname "$0")"

echo "=== 1/5 Java-sjekk (krever Java 25+) ==="
if ! command -v java >/dev/null 2>&1; then
    echo "FEIL: Java mangler. Installer Temurin 25 først."
    exit 1
fi
java -version 2>&1 | head -n 1

echo "=== 2/5 Brannmur: åpner 25566/tcp ==="
sudo ufw allow 25566/tcp || true
echo "HUSK: åpne også 25566/TCP i Oracle Cloud-konsollen (samme sted som 25565)."

echo "=== 3/5 Installerer systemd-tjeneste ==="
sudo cp konkurranse.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable konkurranse >/dev/null

echo "=== 4/5 Starter serveren på nytt ==="
sudo systemctl restart konkurranse

echo "=== 5/5 Venter på boot (første gang tar flere minutter) ==="
for _ in $(seq 1 40); do
    if [ -f logs/latest.log ] && grep -q "Done (" logs/latest.log 2>/dev/null; then
        break
    fi
    sleep 15
done
if grep -q "Done (" logs/latest.log 2>/dev/null; then
    grep "Done (" logs/latest.log | tail -n 1
else
    echo "Ser ikke 'Done' ennå – sjekk selv med: sudo journalctl -u konkurranse -f"
    exit 1
fi

echo
echo "======================================================"
echo "FERDIG! Koble til med: <din-vps-ip>:25566"
echo
echo "Gi deg selv OP (bytt ut DITTNAVN, lim inn alt):"
echo "  sudo systemctl stop konkurranse"
echo "  UUID=\$(curl -s https://api.mojang.com/users/profiles/minecraft/DITTNAVN | python3 -c \"import json,sys; d=json.load(sys.stdin)['id']; print(d[0:8]+'-'+d[8:12]+'-'+d[12:16]+'-'+d[16:20]+'-'+d[20:])\")"
echo "  printf '[{\"uuid\": \"%s\", \"name\": \"DITTNAVN\", \"level\": 4, \"bypassesPlayerLimit\": false}]' \"\$UUID\" > ops.json"
echo "  sudo systemctl start konkurranse"
echo "======================================================"
