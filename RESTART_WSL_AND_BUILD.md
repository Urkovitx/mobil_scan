# ✅ Fitxer .wslconfig Creat!

## 🎉 Ja està fet!

He creat el fitxer `C:\Users\ferra\.wslconfig` amb:

```ini
[wsl2]
memory=8GB
processors=4
swap=2GB
localhostForwarding=true
```

---

## 🚀 ARA FES AIXÒ (3 Passos)

### Pas 1: Tanca WSL

Obre PowerShell **com Administrador** i executa:

```powershell
wsl --shutdown
```

Espera 10 segons.

### Pas 2: Reinicia Docker Desktop

1. Tanca Docker Desktop completament (creu X)
2. Obre Docker Desktop altra vegada
3. Espera 1-2 minuts que s'iniciï

### Pas 3: Torna a Fer Build

```powershell
cd C:\Users\ferra\Projectes\Prova\PROJECTE SCAN AI\INSTALL_DOCKER_FILES\mobil_scan
docker-compose up --build
```

---

## ⏱️ Temps Estimat

- Reiniciar WSL: 10 segons
- Reiniciar Docker: 1-2 minuts
- Build: 20 minuts
- **Total: ~22 minuts**

---

## ✅ Ara Hauria de Funcionar!

Amb 8 GB de RAM, Docker pot compilar els 3 contenidors sense problemes.

---

## 📋 Resum Ràpid

1. ✅ Fitxer `.wslconfig` creat
2. ⏳ Executa: `wsl --shutdown`
3. ⏳ Reinicia Docker Desktop
4. ⏳ Executa: `docker-compose up --build`
5. ⏳ Espera 20 minuts
6. ✅ Funciona!

---

## 💡 Si Encara Falla

Usa l'script seqüencial:

```powershell
.\build_sequential.bat
```

---

**Propera Acció:** Executa `wsl --shutdown` en PowerShell com Administrador! 🚀
