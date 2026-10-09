#!/bin/bash
# Start konkurranse-serveren på Linux/VPS i screen (gir konsoll via `screen -r konkurranse`).
# NB: Bruk systemd-tjenesten (konkurranse.service) for fast drift i stedet.
cd "$(dirname "$0")"
JAVA_BIN="java"
if ! command -v "$JAVA_BIN" >/dev/null 2>&1; then
    echo "FEIL: Java mangler. Samme Java 25 som hovedserveren brukes."
    exit 1
fi
echo "Starter Tangen Konkurranse-server (port 25566)..."
"$JAVA_BIN" -Xms2G -Xmx3G -XX:+UseG1GC -jar paper.jar --nogui
