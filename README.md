# Tangen Konkurranse-server

Fersk, egen Paper-server (26.2) kun for konkurransebygging. Kjører på **port 25566**
ved siden av hovedserveren (25565).

- **Verden:** uendelig flat superflat med **gray_concrete** øverst (bedrock + 2 dirt under).
- **Gamemode:** creative for alle, peaceful, flyging på, spawn-protection av.
- **Klient:** vanilla Minecraft fungerer – **ingen modded launcher nødvendig**.
  Vil du bygge med **Axiom**, installer Axiom Fabric-modden på din egen PC
  (samme spillversjon) + be en OP om OP-tilgang. Serverdelen (`plugins/`)
  er allerede installert.

## Kom i gang på VPS

```bash
git clone <denne-repoen> konkurranse
cd konkurranse
sudo ufw allow 25566/tcp
# + åpne 25566/TCP i Oracle Cloud ingress (samme sted som 25565)
sudo cp konkurranse.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now konkurranse
```

Koble til: `<vps-ip>:25566`. Første spiller som joiteter må få OP av noen med
konsoll: `op <navn>` (via `sudo journalctl -u konkurranse -f` for logg,
eller `screen` + `start-vps.sh` hvis du vil ha konsoll).
