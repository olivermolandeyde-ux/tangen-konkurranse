#!/bin/bash
# Start konkurranse-serveren på Mac (test/lokalt).
cd "$(dirname "$0")"
JAVA_BIN="java"
# På Mac: bruk serverens bundlete JDK hvis system-Java mangler
for cand in "../tangen-mc-server/jdk-25/Contents/Home/bin/java" "../tangen-mc-server/jdk-21/Contents/Home/bin/java"; do
    if [ -f "$cand" ]; then
        JAVA_BIN="$cand"
        break
    fi
done
echo "Starter Tangen Konkurranse-server (port 25566)..."
"$JAVA_BIN" -Xms2G -Xmx3G -XX:+UseG1GC -jar paper.jar --nogui
