#!/bin/bash
# Alt-i-ett-oppsett for VPS-en (Ubuntu ARM64). To måter:
#
#   A) HELAUTOMATISK (anbefalt): lag secret på forhånd, lim inn:
#        sudo ./setup-vps.sh <playit-secret-key>
#      Få nøkkelen: playit.gg -> logg inn -> Agents -> din agent
#      -> kopier "Secret Key". Lag først TCP-tunnel der:
#      Tunnels -> Add Tunnel -> TCP (Shared IP), Local Port 25566, Enable.
#
#   B) INTERAKTIVT: sudo ./setup-vps.sh  (viser claim-lenke underveis)
#
# Ingen porter/ufw/Oracle-brannmur trengs – playit.gg lager tunnel ut.
# Scriptet er idempotent – trygt å kjøre på nytt (restarter serveren).
set -e
cd "$(dirname "$0")"
SECRET="${1:-${PLAYIT_SECRET:-}}"

echo "=== 1/5 Java-sjekk (krever Java 25+) ==="
if ! command -v java >/dev/null 2>&1; then
    echo "FEIL: Java mangler. Installer Temurin 25 først."
    exit 1
fi
java -version 2>&1 | head -n 1

echo "=== 2/5 Installerer playit (tunnel, ingen porter må åpnes) ==="
if ! command -v playit >/dev/null 2>&1; then
    curl -fsSL https://packages.playit.gg/install.sh | bash -s -- -y
fi
sudo systemctl enable playit >/dev/null 2>&1 || true

if [ -n "$SECRET" ]; then
    echo "Secret mottatt – setter opp headless (ingen nettleser nødvendig nå)."
    echo "OBS: Sørg for at TCP-tunnelen mot port 25566 finnes på playit.gg-dashboardet."
    sudo mkdir -p /etc/playit
    printf 'secret_key = "%s"\n' "$SECRET" | sudo tee /etc/playit/playit.toml >/dev/null
    sudo chmod 600 /etc/playit/playit.toml
    sudo systemctl restart playit
    sleep 8
    if sudo systemctl is-active --quiet playit; then
        echo "playit-tjenesten kjører."
    else
        echo "ADVARSEL: playit-tjenesten startet ikke – sjekk med: sudo journalctl -u playit -e"
    fi
else
    echo "=== 3/5 Koble playit til din konto (GJØR DETTE NÅ) ==="
    echo "  1) Lag gratis konto på https://playit.gg (hvis du ikke har)"
    echo "  2) Kjør i et NYTT vindu:  playit setup"
    echo "  3) Åpne claim-lenken som vises, logg inn"
    echo "  4) På https://playit.gg -> Tunnels -> Add Tunnel:"
    echo "       Protocol: TCP (Shared IP), Local Port: 25566, Enable -> Add"
    echo "  5) Noter adressen, f.eks. abc123.at.playit.gg:12345"
    echo
    echo "TIPS: Neste gang kan du hoppe over alt dette med:"
    echo "  Agents -> din agent -> kopier Secret Key, deretter:"
    echo "  sudo ./setup-vps.sh <secret-key>"
    echo
    sudo systemctl restart playit
    read -r -p "Trykk ENTER når tunnelen er opprettet (eller Ctrl+C for å avbryte)... " _ </dev/tty || true
fi

echo "=== 4/5 Installerer Minecraft-tjenesten ==="
sudo cp konkurranse.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable konkurranse >/dev/null

echo "=== 5/5 Starter serveren (første boot genererer verden, tar noen minutter) ==="
sudo systemctl restart konkurranse
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
echo "FERDIG! Del playit-adressen din med spillerne"
echo "(f.eks. abc123.at.playit.gg:12345 – vanilla klient funker)."
echo
echo "Gi deg selv OP (bytt ut DITTNAVN, lim inn alt):"
echo "  sudo systemctl stop konkurranse"
echo "  UUID=\$(curl -s https://api.mojang.com/users/profiles/minecraft/DITTNAVN | python3 -c \"import json,sys; d=json.load(sys.stdin)['id']; print(d[0:8]+'-'+d[8:12]+'-'+d[12:16]+'-'+d[16:20]+'-'+d[20:])\")"
echo "  printf '[{\"uuid\": \"%s\", \"name\": \"DITTNAVN\", \"level\": 4, \"bypassesPlayerLimit\": false}]' \"\$UUID\" > ops.json"
echo "  sudo systemctl start konkurranse"
echo "======================================================"
