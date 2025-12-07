# 🔧 ERROR: Docker Engine No Està Executant-se

## ⚠️ EL PROBLEMA

```
ERROR: error during connect: open //./pipe/dockerDesktopLinuxEngine: 
The system cannot find the file specified.
```

**Significat:** Docker Desktop no està executant-se o està penjat.

---

## ✅ SOLUCIÓ (3 passos)

### Pas 1: Reiniciar Docker Desktop

```
1. Obre Docker Desktop
2. Espera que digui "Docker Desktop is running"
3. Si està penjat:
   - Click dreta a la icona de la safata
   - "Quit Docker Desktop"
   - Espera 30 segons
   - Obre Docker Desktop de nou
```

### Pas 2: Verificar que funciona

Obre PowerShell i executa:

```powershell
docker ps
```

**Si respon amb una taula (encara que buida):** ✅ Docker funciona

**Si dona error:** ❌ Docker no funciona → Continua al Pas 3

### Pas 3: Reset Docker Desktop (si cal)

```
1. Docker Desktop → Settings (engranatge)
2. Troubleshoot
3. "Restart Docker Desktop"
4. Espera 2 minuts
5. Prova docker ps de nou
```

---

## 🚀 DESPRÉS DE REINICIAR

Quan Docker Desktop digui "Engine running":

```powershell
.\DEPLOY_FACIL.bat
```

---

## 💡 PER QUÈ PASSA AIXÒ?

Docker Desktop a Windows és inestable i sovint:
- Es penja
- No arrenca correctament
- Perd la connexió amb WSL2

**És normal. No és culpa teva.**

---

## 🎯 CHECKLIST

Abans d'executar el script:

- [ ] Docker Desktop obert
- [ ] Diu "Docker Desktop is running"
- [ ] `docker ps` funciona (respon en < 2 segons)
- [ ] Executar `.\DEPLOY_FACIL.bat`

---

## 📞 SI CONTINUA FALLANT

### Opció A: Reset complet

```
Docker Desktop → Settings → Troubleshoot → 
"Reset to factory defaults"
```

### Opció B: Reiniciar Windows

```
A vegades Docker Desktop necessita un reinici de Windows
per funcionar correctament.
```

### Opció C: Usar GitHub Actions

```
Si Docker Desktop continua fallant, podem usar
GitHub Actions per fer el build al núvol.
```

---

## ✅ RESUM

1. **Obre Docker Desktop**
2. **Espera que digui "Engine running"**
3. **Prova `docker ps`**
4. **Executa `.\DEPLOY_FACIL.bat`**

**Això hauria de funcionar!** 💪
