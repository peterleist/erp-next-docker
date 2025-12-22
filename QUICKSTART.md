# Gyors Útmutató - ERPNext Docker

## ERPNext v16.0.0-dev 🚀

## Telepítés 3 lépésben

### 1. Konfiguráció
```bash
cp .env.example .env
nano .env  # Állítsd be a jelszavakat!
```

### 2. Indítás
```bash
docker-compose up -d
```

### 3. Várj 30 másodpercet
```bash
# Nyisd meg a böngészőben:
http://localhost:8080

# Bejelentkezés:
Username: Administrator
Password: (amit beállítottál az .env fájlban)
```

## Státusz ellenőrzése

```bash
# Konténerek állapota
docker-compose ps

# Configurator log (site létrehozás)
docker-compose logs configurator

# Backend log
docker-compose logs -f backend
```

## Leállítás

```bash
# Leállítás
docker-compose down

# Leállítás + adatok törlése
docker-compose down -v
```

## Problémamegoldás

### Site már létezik hiba
```bash
docker-compose down -v
docker-compose up -d
```

### Workers hibák
```bash
docker-compose restart queue-short queue-long scheduler
```

## További információk

Részletes dokumentáció: [README.md](README.md)
