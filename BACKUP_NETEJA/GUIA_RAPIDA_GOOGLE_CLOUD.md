# 🚀 Guia Ràpida: Google Cloud Run en 3 Passos

## ✅ Estat Actual

- ✅ Google Cloud SDK instal·lat
- ✅ Sessió iniciada (ferranpalacin@gmail.com)
- ✅ Projecte creat (mobil-scan-app)
- ⚠️ **Falta:** Activar facturació

## 📋 Pas 1: Activar Facturació (5 minuts)

### Opció A: Des del Navegador (Recomanat)

1. **Obre:** https://console.cloud.google.com/billing

2. **Clica:** "Link a billing account" o "Vincular compte de facturació"

3. **Selecciona el projecte:** `mobil-scan-app`

4. **Afegeix targeta:**
   - No et cobraran res
   - Tens **300$ gratis** per començar
   - Només per verificació

5. **Accepta** els termes

### Opció B: Des de la Consola

```bash
# Llista comptes de facturació
gcloud billing accounts list

# Vincula el compte al projecte
gcloud billing projects link mobil-scan-app --billing-account=XXXXXX-XXXXXX-XXXXXX
```

## 🔧 Pas 2: Executar Setup (2 minuts)

Un cop activada la facturació:

```bash
SETUP_GOOGLE_CLOUD.bat
```

Això farà:
- ✅ Activar APIs necessàries
- ✅ Configurar regió (Europa)
- ✅ Verificar configuració

## 🚀 Pas 3: Deploy! (20 minuts)

```bash
deploy_cloud_run.bat
```

Això farà:
- ✅ Compilar imatges al núvol
- ✅ Desplegar backend, frontend i worker
- ✅ Obtenir URLs públiques

## 📊 Resultat Final

```
Frontend:  https://mobil-scan-frontend-xxx.run.app
Backend:   https://mobil-scan-backend-xxx.run.app
Worker:    (executa en background)
```

## 💰 Costos

### Primer Any (amb 300$ gratis):
- **Mesos 1-7:** GRATIS (cobert pels 300$)
- **Mesos 8-12:** ~40€/mes

### Optimització:
```bash
# Escala a 0 quan no s'usa
gcloud run services update mobil-scan-frontend --min-instances 0
```

## 🆘 Troubleshooting

### Error: "Billing not enabled"
➡️ Activa facturació a: https://console.cloud.google.com/billing

### Error: "API not enabled"
➡️ Executa: `SETUP_GOOGLE_CLOUD.bat`

### Error: "Permission denied"
➡️ Executa: `gcloud auth login`

## 📚 Comandes Útils

```bash
# Veure projecte actual
gcloud config get-value project

# Veure serveis desplegats
gcloud run services list

# Veure logs
gcloud run services logs read mobil-scan-frontend

# Eliminar servei
gcloud run services delete mobil-scan-frontend

# Veure costos
gcloud billing accounts list
```

## 🎯 Checklist Complet

- [x] Google Cloud SDK instal·lat
- [x] Sessió iniciada
- [x] Projecte creat (mobil-scan-app)
- [ ] **Facturació activada** ← FES AIXÒ ARA
- [ ] APIs activades (SETUP_GOOGLE_CLOUD.bat)
- [ ] Deploy executat (deploy_cloud_run.bat)
- [ ] Aplicació funcionant

## 🔗 Links Importants

- **Consola:** https://console.cloud.google.com/
- **Facturació:** https://console.cloud.google.com/billing
- **Cloud Run:** https://console.cloud.google.com/run
- **Logs:** https://console.cloud.google.com/logs

## ⏱️ Temps Estimat Total

| Pas | Temps |
|-----|-------|
| Activar facturació | 5 min |
| Executar setup | 2 min |
| Deploy al núvol | 20 min |
| **TOTAL** | **27 min** |

---

## 🎉 Pròxim Pas

**Activa la facturació ara:**
👉 https://console.cloud.google.com/billing

Després executa:
```bash
SETUP_GOOGLE_CLOUD.bat
deploy_cloud_run.bat
```

**I oblida Docker Desktop per sempre!** 🚀
