# Gyors útmutató - Több ERPNext példány futtatása

Ez az útmutató megmutatja, hogyan futtass 2 vagy több ERPNext példányt párhuzamosan ugyanazon a gépen.

## 🎯 Gyors példa: 2 példány telepítése

### Lépés 1: Első példány

```bash
cd ~/spektor-go-docker

# Konfiguráció
cp .env.example .env
nano .env
```

Állítsd be:
```env
COMPOSE_PROJECT_NAME=erpnext-prod
HTTP_PORT=8080
WEBSOCKET_PORT=9000
MARIADB_PORT=3306
SITE_NAME=production.local
```

```bash
# Indítás
docker-compose up -d
```

### Lépés 2: Második példány

```bash
# Új könyvtár létrehozása
cd ~
cp -r spektor-go-docker spektor-go-docker-dev
cd spektor-go-docker-dev

# Konfiguráció
cp .env.example .env
nano .env
```

Állítsd be (ELTÉRŐ értékekkel):
```env
COMPOSE_PROJECT_NAME=erpnext-dev
HTTP_PORT=8081
WEBSOCKET_PORT=9001
MARIADB_PORT=3307
SITE_NAME=development.local
```

```bash
# Indítás
docker-compose up -d
```

## ✅ Ellenőrzés

```bash
# Első példány
curl http://localhost:8080

# Második példány
curl http://localhost:8081
```

## 📋 Port hozzárendelések

| Példány | HTTP | WebSocket | MariaDB | Project Name |
|---------|------|-----------|---------|--------------|
| 1 (prod) | 8080 | 9000 | 3306 | erpnext-prod |
| 2 (dev) | 8081 | 9001 | 3307 | erpnext-dev |
| 3 (test) | 8082 | 9002 | 3308 | erpnext-test |

## 🔧 Kezelés

```bash
# Első példány
cd ~/spektor-go-docker
docker-compose ps
docker-compose logs -f backend

# Második példány
cd ~/spektor-go-docker-dev
docker-compose ps
docker-compose logs -f backend
```

## 🗑️ Törlés

```bash
# Csak egy példány törlése
cd ~/spektor-go-docker-dev
docker-compose down -v  # -v törli az adatokat is

# Összes példány törlése
docker stop $(docker ps -aq)
docker volume prune -f
```

## 💡 Tippek

1. **Egyedi nevek**: Mindig használj egyedi `COMPOSE_PROJECT_NAME`-et
2. **Port ütközés elkerülése**: Ellenőrizd, hogy a portok szabadok-e: `netstat -tuln | grep LISTEN`
3. **Erőforrások**: Minden példány ~4GB RAM-ot igényel
4. **Backup**: Minden példánynak külön backup kell: `docker exec <container> bench backup`

## 🎨 Használati esetek

- **Production + Development**: Egy éles és egy teszt környezet
- **Multi-tenant**: Több ügyfél számára különálló példányok
- **Verzió tesztelés**: Különböző ERPNext verziók párhuzamos futtatása
- **Training környezet**: Oktatási példány az éles rendszer mellett

## Részletes dokumentáció

Lásd: [README.md](README.md) - "Többpéldányos telepítés" szakasz
