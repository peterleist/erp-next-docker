# ERPNext Docker Compose Setup

Ez a Docker Compose konfiguráció egy teljes Frappe ERPNext 16 rendszert állít össze, az alábbi guide alapján:
https://medium.com/@ibrahim.ah888/step-by-step-guide-to-installing-erpnext-16-beta-on-ubuntu-22-04-lts-484e62f0d480

**✨ ERPNext v16.0.0-dev verzió**

**🚀 Támogatja a többpéldányos telepítést! Futtathatsz párhuzamosan több ERPNext példányt.**

## Komponensek

- **MariaDB 10.6**: Adatbázis szerver
- **Redis Cache**: Cache tárolás
- **Redis Queue**: Aszinkron feladat sor
- **Configurator**: Site inicializáló konténer (egyszeri futás)
- **Backend**: Frappe framework és ERPNext alkalmazás
- **Frontend**: Nginx web szerver
- **WebSocket**: Valós idejű frissítések
- **Queue Workers**: Háttérfeladatok végrehajtása
- **Scheduler**: Időzített feladatok

**📦 Előre telepített alkalmazások:**
- ERPNext
- **Spektor Go** - CMMS & Service Management System

## Követelmények

- Docker Engine 20.10+
- Docker Compose 2.0+
- Minimum 4GB RAM (8GB ajánlott)
- Minimum 20GB szabad lemezterület (50GB+ ajánlott)

## Telepítés

### 1. Klónozd a repository-t vagy töltsd le a fájlokat

```bash
cd /Users/ispeterl/github/spektor-go-docker
```

### 2. Környezeti változók beállítása

Másold le a `.env.example` fájlt `.env` néven és állítsd be a saját értékeket:

```bash
cp .env.example .env
nano .env
```

Állítsd be az alábbi változókat:

```env
MYSQL_ROOT_PASSWORD=strong_password_here
SITE_NAME=erp.local
ADMIN_PASSWORD=strong_admin_password
DEVELOPER_MODE=0
```

### 3. Hosts fájl módosítása (opcionális, fejlesztéshez)

Ha lokálisan teszteled, add hozzá a site nevet a hosts fájlhoz:

```bash
sudo nano /etc/hosts
```

Add hozzá:
```
127.0.0.1 erp.local
```

### 4. Indítsd el a konténereket

**Első indításkor a configurator konténer létrehozza a site-ot, ez 5-10 percet vesz igénybe:**

```bash
docker-compose up -d
```

**Figyeld a configurator konténer folyamatát:**

```bash
docker-compose logs -f configurator
```

Amikor látod a "Installed erpnext" üzenetet, a site elkészült.

### 5. Ellenőrizd, hogy a configurator sikeresen lefutott

```bash
docker-compose ps configurator
```

Az állapotnak "Exited (0)" kell lennie.

### 6. Hozzáférés az ERPNext-hez

Nyisd meg a böngészőben:

```
http://localhost:8080
```

Vagy ha hosts fájlt módosítottad:

```
http://erp.local:8080
```

**Bejelentkezési adatok:**
- Username: `Administrator`
- Password: Az `.env` fájlban megadott `ADMIN_PASSWORD`

## Hasznos parancsok

### Konténerek indítása
```bash
docker-compose up -d
```

### Konténerek leállítása
```bash
docker-compose down
```

### Logok megtekintése
```bash
docker-compose logs -f
```

### Egy adott szolgáltatás logjainak megtekintése
```bash
docker-compose logs -f erpnext-backend
```

### Bench parancsok futtatása
```bash
# Backend konténerben
docker exec -it erpnext-backend bench --version

# Site lista
docker exec -it erpnext-backend bench --site erp.local list-apps
```

### Site biztonsági mentése
```bash
docker exec -it erpnext-backend bench --site erp.local backup
```

### Új app telepítése (pl. HRMS)
```bash
# Get app
docker exec -it erpnext-backend bench get-app hrms

# Install app to site
docker exec -it erpnext-backend bench --site erp.local install-app hrms

# Rebuild
docker exec -it erpnext-backend bench build

# Restart services
docker-compose restart backend frontend websocket queue-short queue-long scheduler
```

### Cache törlése
```bash
docker exec -it erpnext-backend bench --site erp.local clear-cache
```

### Migrációk futtatása
```bash
docker exec -it erpnext-backend bench --site erp.local migrate
docker-compose restart backend frontend websocket queue-short queue-long scheduler
```

## Kötet (Volume) információk

Az alábbi Docker volumek kerülnek létrehozásra az adatok perzisztens tárolásához:

- `mariadb-data`: MariaDB adatbázis fájlok
- `redis-cache-data`: Redis cache adatok
- `redis-queue-data`: Redis queue adatok
- `sites-data`: ERPNext site fájlok, konfiguráció, uploaded fájlok, backupok

## Biztonsági mentés

### Adatbázis backup

```bash
# Site backup (database + files)
docker exec -it erpnext-backend bench --site erp.local backup --with-files

# Backup fájlok megtekintése
docker exec -it erpnext-backend ls -lh /home/frappe/frappe-bench/sites/erp.local/private/backups/

# Backup fájlok kimentése a host gépre
docker cp erpnext-backend:/home/frappe/frappe-bench/sites/erp.local/private/backups/. ./backups/
```

### Backup visszatöltése

```bash
# Állítsd le a rendszert
docker-compose down

# Töröld a sites volume-ot
docker volume rm spektor-go-docker_sites-data

# Indítsd újra (újra létrejön a configurator)
docker-compose up -d configurator

# Várj, míg létrejön az üres site, majd állítsd le
docker-compose stop

# Másold be a backup-ot
docker cp ./backups/your-backup-file.sql.gz erpnext-backend:/tmp/

# Indítsd el a backend-et és töltsd vissza
docker-compose up -d backend
docker exec -it erpnext-backend bench --site erp.local restore /tmp/your-backup-file.sql.gz
```

### Volume backup

```bash
# Összes volume biztonsági mentése
docker run --rm \
  -v spektor-go-docker_mariadb-data:/data \
  -v $(pwd)/backup:/backup \
  alpine tar czf /backup/mariadb-backup-$(date +%Y%m%d).tar.gz /data
```

## Problémamegoldás

### Configurator sikertelen (exited with error)

Ellenőrizd a logokat:
```bash
docker-compose logs configurator
```

Gyakori okok:
- MariaDB nem elérhető (várj egy kicsit tovább)
- Helytelen jelszó a .env fájlban
- Site már létezik (töröld a sites-data volume-ot)

### Site már létezik hiba

```bash
docker-compose down
docker volume rm spektor-go-docker_sites-data
docker-compose up -d
```

### Konténerek nem indulnak el

Ellenőrizd a logokat:
```bash
docker-compose logs
```

### ERPNext nem elérhető

1. Ellenőrizd, hogy a configurator sikeresen lefutott:
```bash
docker-compose ps configurator  # State: Exited (0)
```

2. Ellenőrizd a backend logokat:
```bash
docker-compose logs backend
```

3. Ellenőrizd, hogy minden szolgáltatás fut:
```bash
docker-compose ps
```

### Adatbázis kapcsolati hiba

Ellenőrizd a MariaDB konténer állapotát:
```bash
docker-compose logs mariadb
```

Teszteld a kapcsolatot:
```bash
docker exec -it erpnext-mariadb mysql -u root -p
# Add meg a jelszót amikor kéri
```

### Workers hibák (Redis connection refused)

Ez akkor fordulhat elő, ha a workers a configurator előtt próbálnak elindulni:
```bash
# Indítsd újra az érintett szolgáltatásokat
docker-compose restart queue-short queue-long scheduler
```

### Port foglalt (8080)

Ha a 8080-as port már használatban van, módosítsd a `docker-compose.yml` fájlban:
```yaml
ports:
  - "8081:8080"  # Módosítsd 8081-re vagy más szabad portra
```

## Frissítés

```bash
# Állítsd le a konténereket
docker-compose down

# Húzd le az új képeket
docker-compose pull

# Indítsd újra a konténereket
docker-compose up -d

# Futtasd a migrációkat
docker exec -it erpnext-backend bench --site erp.local migrate
```

## Production környezet

Production használathoz:

1. Állíts be erős jelszavakat az `.env` fájlban
2. Használj SSL/TLS-t (pl. Nginx reverse proxy + Let's Encrypt)
3. Állítsd be a megfelelő domain nevet
4. Rendszeres biztonsági mentések
5. Monitorozás és logolás beállítása
6. Tűzfal konfiguráció

## 🔄 Többpéldányos telepítés (Multiple Instances)

Két vagy több ERPNext példány futtatása ugyanazon a gépen.

### Előkészületek

A docker-compose konfiguráció támogatja a többpéldányos futtatást. Minden példánynak:
- Egyedi project neve van (`COMPOSE_PROJECT_NAME`)
- Egyedi portjai vannak (HTTP, WebSocket, MariaDB)
- Saját volume-jai vannak (elkülönített adatok)

### Első példány (Instance 1)

```bash
# Készítsd el az első példány konfigurációját
cp .env.example .env

# Szerkeszd az értékeket
nano .env
```

`.env` tartalom:
```env
COMPOSE_PROJECT_NAME=erpnext-instance1
HTTP_PORT=8080
WEBSOCKET_PORT=9000
MARIADB_PORT=3306
MYSQL_ROOT_PASSWORD=password1
SITE_NAME=site1.local
ADMIN_PASSWORD=admin1
```

```bash
# Indítsd el az első példányt
docker-compose up -d
```

### Második példány (Instance 2)

```bash
# Készíts egy új könyvtárat a második példánynak
cd ..
mkdir spektor-go-docker-instance2
cd spektor-go-docker-instance2

# Másold át a fájlokat
cp -r ../spektor-go-docker/* .

# Készítsd el a második példány konfigurációját
cp .env.example .env
```

`.env` tartalom:
```env
COMPOSE_PROJECT_NAME=erpnext-instance2
HTTP_PORT=8081
WEBSOCKET_PORT=9001
MARIADB_PORT=3307
MYSQL_ROOT_PASSWORD=password2
SITE_NAME=site2.local
ADMIN_PASSWORD=admin2
```

```bash
# Indítsd el a második példányt
docker-compose up -d
```

### Harmadik, negyedik példány...

Ismételd meg a fenti lépéseket, csak figyelj arra, hogy:
- `COMPOSE_PROJECT_NAME` legyen egyedi (pl. `erpnext-instance3`)
- A portok ne ütközzenek:
  - Instance 3: HTTP=8082, WebSocket=9002, MariaDB=3308
  - Instance 4: HTTP=8083, WebSocket=9003, MariaDB=3309

### Példányok kezelése

```bash
# Első példány kezelése
cd spektor-go-docker
docker-compose ps
docker-compose logs -f
docker-compose down

# Második példány kezelése
cd spektor-go-docker-instance2
docker-compose ps
docker-compose logs -f
docker-compose down
```

### Hozzáférés a példányokhoz

- **Instance 1**: http://localhost:8080
- **Instance 2**: http://localhost:8081
- **Instance 3**: http://localhost:8082
- stb.

### Hosts fájl konfiguráció (opcionális)

Ha egyedi domain neveket szeretnél használni:

```bash
sudo nano /etc/hosts
```

Add hozzá:
```
127.0.0.1 site1.local
127.0.0.1 site2.local
127.0.0.1 site3.local
```

Ezután elérheted:
- http://site1.local:8080
- http://site2.local:8081
- http://site3.local:8082

### Volume-ok és adatok

Minden példánynak saját volume-jai vannak:
- `erpnext-instance1_mariadb-data`
- `erpnext-instance1_sites-data`
- `erpnext-instance2_mariadb-data`
- `erpnext-instance2_sites-data`
- stb.

Volume-ok listázása:
```bash
docker volume ls | grep erpnext
```

### Egyetlen példány törlése

```bash
cd spektor-go-docker-instance2
docker-compose down -v  # A -v flag törli a volume-okat is
```

## További információk

- [ERPNext Dokumentáció](https://docs.erpnext.com/)
- [Frappe Framework Dokumentáció](https://frappeframework.com/docs)
- [ERPNext GitHub](https://github.com/frappe/erpnext)

## Licenc

ERPNext és Frappe Framework: GNU General Public License v3.0
