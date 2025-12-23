# Spektor Go - Előre Telepített Setup

## Mi változott?

Az ERPNext Docker környezet most automatikusan telepíti a **Spektor Go** appot az ERPNext mellett.

## Telepített alkalmazások

1. **ERPNext** - ERP rendszer
2. **Spektor Go** - CMMS & Service Management System

## Hogyan működik?

Az `init-site.sh` script automatikusan:
1. Letölti a Spektor Go appot GitHubról
2. Létrehozza az ERPNext site-ot
3. Telepíti az ERPNext-et
4. Telepíti a Spektor Go-t

## Új telepítés

Amikor új környezetet indítasz:

```bash
# 1. Állítsd be a környezeti változókat
cp .env.example .env
nano .env

# 2. Indítsd el a Docker Compose-t
docker-compose up -d

# 3. Várj kb. 2-3 percet, amíg minden települ

# 4. Nyisd meg a böngészőben
http://localhost:8080
```

## Mit fogsz látni?

Bejelentkezés után az ERPNext-ben megjelenik a **SpektorGo** workspace a navigációban.

## Frissítések

Ha frissíteni akarod a Spektor Go appot egy futó környezetben:

```bash
# Belépés a backend containerbe
docker exec -it <container_name>-backend-1 bash

# App frissítése
cd apps/spektor_go
git pull

# Pip reinstall (ha szükséges)
cd /home/frappe/frappe-bench
./env/bin/pip install -e ./apps/spektor_go

# Migráció
bench --site <site_name> migrate

# Cache törlése
bench --site <site_name> clear-cache

# Újraindítás
exit
docker restart <container_name>-backend-1
```

## Megjegyzések

- Az init script csak az első indításkor fut le (configurator container)
- Ha már létező site-tal rendelkezel, akkor manuálisan kell telepíteni a Spektor Go-t
- A Spektor Go mindig a GitHub main branch legfrissebb verzióját használja a telepítéskor

## Troubleshooting

### Ha a Spektor Go nem jelenik meg

```bash
# Ellenőrizd, hogy telepítve van-e
docker exec -it <container_name>-backend-1 bench --site <site_name> list-apps

# Ha nem látszik, telepítsd manuálisan
docker exec -it <container_name>-backend-1 bench get-app https://github.com/peterleist/spektor-go
docker exec -it <container_name>-backend-1 bench --site <site_name> install-app spektor_go
docker restart <container_name>-backend-1
```

### ModuleNotFoundError: No module named 'spektor_go'

```bash
docker exec -it <container_name>-backend-1 bash -c "cd /home/frappe/frappe-bench && ./env/bin/pip install -e ./apps/spektor_go"
docker restart <container_name>-backend-1
```
