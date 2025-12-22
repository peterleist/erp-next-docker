# ERPNext v16 Telepítés Sikeres! ✅

## Verzió információk

- **ERPNext**: v16.0.0-dev
- **Frappe**: v16.0.0-dev
- **MariaDB**: 10.6
- **Redis**: 7-alpine
- **Python**: 3.12

## Elérés

- **URL**: http://localhost:8080
- **Site név**: spektor-go.local
- **Felhasználónév**: Administrator
- **Jelszó**: Az `.env` fájlban megadott `ADMIN_PASSWORD`

## Futó szolgáltatások

```
✅ MariaDB         - Port 3306
✅ Redis Cache     - Port 6379
✅ Redis Queue     - Port 6379
✅ Backend         - Gunicorn (internal)
✅ Frontend        - Nginx Port 8080
✅ WebSocket       - Port 9000
✅ Queue Workers   - Short & Long queues
✅ Scheduler       - Background jobs
```

## Hasznos parancsok

### Verzió ellenőrzés
```bash
docker exec -it erpnext-backend bench version
```

### Telepített appok
```bash
docker exec -it erpnext-backend bench --site spektor-go.local list-apps
```

### Backup készítése
```bash
docker exec -it erpnext-backend bench --site spektor-go.local backup --with-files
```

### HRMS telepítése
```bash
docker exec -it erpnext-backend bench get-app hrms
docker exec -it erpnext-backend bench --site spektor-go.local install-app hrms
docker-compose restart backend frontend websocket queue-short queue-long scheduler
```

### Logok figyelése
```bash
docker-compose logs -f backend
docker-compose logs -f queue-short
```

### Konténerek újraindítása
```bash
docker-compose restart
```

### Site konzol
```bash
docker exec -it erpnext-backend bench --site spektor-go.local console
```

## Következő lépések

1. **Nyisd meg a böngészőben**: http://localhost:8080
2. **Jelentkezz be** az Administrator fiókkal
3. **Kövesd az Setup Wizard-ot**:
   - Vállalat adatok megadása
   - Pénznem beállítása
   - Nyelv kiválasztása
   - Email konfiguráció
4. **Kezdd el használni az ERPNext-et!**

## Fejlesztői funkciók

A v16 dev verzió tartalmazza a legújabb funkciókat és fejlesztéseket. Ha production környezetbe szeretnél telepíteni, érdemes megvárni a stable v16 release-t.

## Támogatás

- [ERPNext Dokumentáció](https://docs.erpnext.com/)
- [Frappe Framework](https://frappeframework.com/)
- [Community Forum](https://discuss.frappe.io/)

---

**Készítve**: 2025. December 22.
**Guide alapja**: https://medium.com/@ibrahim.ah888/step-by-step-guide-to-installing-erpnext-16-beta-on-ubuntu-22-04-lts-484e62f0d480
