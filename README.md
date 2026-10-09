# Tangen Konkurranse-server

Fersk, egen Paper-server (26.2) kun for konkurransebygging. Kjører på **port 25566**
ved siden av hovedserveren (25565).

- **Verden:** uendelig flat superflat med **gray_concrete** øverst (bedrock + 2 dirt under).
- **Gamemode:** creative for alle, peaceful, flyging på, spawn-protection av.
- **Klient:** vanilla Minecraft fungerer – **ingen modded launcher nødvendig**.
  Vil du bygge med **Axiom**, installer Axiom Fabric-modden på din egen PC
  (samme spillversjon) + be en OP om OP-tilgang. Serverdelen (`plugins/`)
  er allerede installert.

## Kom i gang på VPS (én kommando, ingen porter)

Vi bruker **playit.gg-tunnel** – du slipper ufw og Oracle-brannmur helt:

```bash
git clone https://github.com/olivermolandeyde-ux/tangen-konkurranse.git konkurranse
cd konkurranse
sudo ./setup-vps.sh
```

Skriptet installerer playit + starter serveren. Underveis ber det deg om å
lage gratis konto på playit.gg, åpne claim-lenken (`playit setup`) og lage en
TCP-tunnel mot port **25566**. Del tunnel-adressen
(f.eks. `abc123.at.playit.gg:12345`) med spillerne.

Koble til med **playit-adressen din**. Første spiller som jointer må få OP
av noen med konsoll: `op <navn>` (se logg med `sudo journalctl -u konkurranse -f`,
eller kjør `screen` + `./start-vps.sh` hvis du vil ha konsoll).
