# 🌐 Com Accedir a la Teva Aplicació

## 📍 URLs dels Serveis

Un cop desplegats els serveis, obtindràs 3 URLs:

### Frontend (Interfície Web)
```
https://mobil-scan-frontend-XXXXXXXXXX-ew.a.run.app
```
**Això és el que obriràs al navegador!**

### Backend (API)
```
https://mobil-scan-backend-XXXXXXXXXX-ew.a.run.app
```
**Utilitzat internament pel frontend**

### Worker
```
(No té URL pública, executa en background)
```

## 🚀 Com Obtenir les URLs

### Opció 1: Des del Script
Quan acabi `DESPLEGAR_SERVEIS_ARA.bat`, veuràs:
```
Frontend URL: https://mobil-scan-frontend-xxx.run.app
Backend URL: https://mobil-scan-backend-xxx.run.app
```

### Opció 2: Comanda Manual
```bash
gcloud run services list --project mobil-scan-app
```

### Opció 3: Consola Web
👉 https://console.cloud.google.com/run?project=mobil-scan-app

## 🌐 Accedir des del Navegador

### Des del PC:
1. Copia la URL del frontend
2. Enganxa-la al navegador
3. Ja està! L'aplicació carregarà

### Des del Mòbil:
1. Obre el navegador del mòbil
2. Enganxa la mateixa URL
3. Funciona igual que al PC!

**Avantatge:** És una URL pública amb HTTPS, accessible des de qualsevol lloc!

## 📱 Accés des del Mòbil (Detallat)

### Opció A: Compartir URL
1. Al PC, copia la URL del frontend
2. Envia-la al mòbil (WhatsApp, email, etc.)
3. Clica l'enllaç al mòbil
4. S'obre l'aplicació

### Opció B: Codi QR
1. Genera un QR de la URL: https://www.qr-code-generator.com/
2. Escaneja amb el mòbil
3. S'obre l'aplicació

### Opció C: Afegir a Pantalla d'Inici
**Android:**
1. Obre la URL al Chrome
2. Menú (3 punts) → "Afegir a pantalla d'inici"
3. Ara tens una icona com una app!

**iOS:**
1. Obre la URL al Safari
2. Botó compartir → "Afegir a pantalla d'inici"
3. Ara tens una icona com una app!

## 🔒 Seguretat

- ✅ **HTTPS automàtic** - Connexió segura
- ✅ **Certificat SSL** - Proporcionat per Google
- ✅ **Accessible públicament** - Qualsevol amb la URL pot accedir
- ⚠️ **Sense autenticació** - Si vols restringir accés, cal afegir login

## 📊 Monitoritzar l'Aplicació

### Veure Logs
```bash
# Frontend
gcloud run services logs read mobil-scan-frontend --project mobil-scan-app

# Backend
gcloud run services logs read mobil-scan-backend --project mobil-scan-app

# Worker
gcloud run services logs read mobil-scan-worker --project mobil-scan-app
```

### Veure Estat
```bash
gcloud run services describe mobil-scan-frontend --region europe-west1 --project mobil-scan-app
```

### Consola Web (Més Fàcil)
👉 https://console.cloud.google.com/run?project=mobil-scan-app

Aquí pots veure:
- URLs dels serveis
- Logs en temps real
- Mètriques (CPU, memòria, requests)
- Errors

## 🔄 Actualitzar l'Aplicació

Si fas canvis al codi:

```bash
# 1. Recompilar imatges
gcloud builds submit --config=cloudbuild.yaml --project=mobil-scan-app

# 2. Redesplegar serveis
DESPLEGAR_SERVEIS_ARA.bat
```

**Temps:** 15-20 minuts (més ràpid que la primera vegada)

## 🛑 Aturar l'Aplicació (Estalviar Diners)

### Opció 1: Eliminar Serveis
```bash
gcloud run services delete mobil-scan-frontend --region europe-west1 --project mobil-scan-app
gcloud run services delete mobil-scan-backend --region europe-west1 --project mobil-scan-app
gcloud run services delete mobil-scan-worker --region europe-west1 --project mobil-scan-app
```

### Opció 2: Escalar a 0 (Recomanat)
Els serveis ja estan configurats amb `--min-instances 0`, així que:
- **Quan no hi ha tràfic:** Escala a 0 (no pagues)
- **Quan arriba una petició:** S'activa automàticament (triga 2-3 segons)

**No cal fer res!** Google ho gestiona automàticament.

## 💰 Costos

### Amb Tràfic Baix (< 100 requests/dia):
- **Frontend:** ~2€/mes
- **Backend:** ~3€/mes
- **Worker:** ~5€/mes
- **Total:** ~10€/mes

### Sense Tràfic:
- **Cost:** 0€ (escala a 0)

### Primer Any:
- **300$ gratis** - Cobreix 30 mesos!

## 🆘 Problemes Comuns

### Error 503: Service Unavailable
**Causa:** El servei s'està iniciant (cold start)  
**Solució:** Espera 5-10 segons i refresca

### Error 404: Not Found
**Causa:** URL incorrecta  
**Solució:** Verifica la URL amb `gcloud run services list`

### L'aplicació no carrega
**Causa:** Servei no desplegat correctament  
**Solució:** Revisa logs amb `gcloud run services logs read`

## ✅ Checklist d'Accés

- [ ] Serveis desplegats correctament
- [ ] URL del frontend obtinguda
- [ ] URL oberta al navegador del PC
- [ ] Aplicació carrega correctament
- [ ] URL compartida al mòbil
- [ ] Aplicació funciona al mòbil
- [ ] (Opcional) Afegida a pantalla d'inici

## 🎉 Resultat Final

Ara tens:
- ✅ Aplicació web accessible des de qualsevol lloc
- ✅ HTTPS automàtic
- ✅ Escalabilitat automàtica
- ✅ Sense Docker Desktop
- ✅ Sense manteniment de servidors
- ✅ Accessible des del mòbil

**Simplement obre la URL i ja està!** 🚀

---

**Nota:** Guarda la URL del frontend en un lloc segur. És l'única cosa que necessites per accedir a l'aplicació!
