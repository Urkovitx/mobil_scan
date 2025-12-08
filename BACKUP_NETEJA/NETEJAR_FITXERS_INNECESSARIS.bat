@echo off
echo ========================================
echo NETEJA DE FITXERS INNECESSARIS
echo ========================================
echo.
echo Aquest script eliminara fitxers de:
echo - Documentacio de proves i tests
echo - Scripts duplicats o obsolets
echo - Logs i outputs temporals
echo.
echo IMPORTANT: Es creara una carpeta BACKUP abans d'esborrar
echo.
pause

echo.
echo [1/4] Creant backup...
if not exist "BACKUP_NETEJA" mkdir "BACKUP_NETEJA"
xcopy *.md "BACKUP_NETEJA\" /Y /Q > nul 2>&1
xcopy *.bat "BACKUP_NETEJA\" /Y /Q > nul 2>&1
echo [OK] Backup creat a BACKUP_NETEJA\

echo.
echo [2/4] Eliminant documentacio de proves...

REM Eliminar fitxers de troubleshooting i proves
del /Q "SOLUCIO_*.md" 2>nul
del /Q "BUILD_*.md" 2>nul
del /Q "REBUILD_*.md" 2>nul
del /Q "PROBLEMA_*.md" 2>nul
del /Q "ERROR_*.md" 2>nul
del /Q "FIX_*.md" 2>nul
del /Q "ARREGLAR_*.md" 2>nul
del /Q "DIAGNOSTICAR_*.md" 2>nul
del /Q "VERIFICAR_*.md" 2>nul
del /Q "VERIFICACIO_*.md" 2>nul
del /Q "TEST_*.md" 2>nul
del /Q "TESTING_*.md" 2>nul
del /Q "CRITICAL_*.md" 2>nul
del /Q "EMERGENCY_*.md" 2>nul
del /Q "URGENT_*.md" 2>nul
del /Q "WHAT_*.md" 2>nul
del /Q "QUE_*.md" 2>nul
del /Q "COM_HO_*.md" 2>nul
del /Q "LA_VERITAT_*.md" 2>nul
del /Q "REAL_*.md" 2>nul
del /Q "FINAL_SOLUTION*.md" 2>nul
del /Q "SOLUTION_*.md" 2>nul
del /Q "ALTERNATIVES_*.md" 2>nul
del /Q "PROFESSIONAL_*.md" 2>nul
del /Q "NETWORK_*.md" 2>nul
del /Q "DOCKER_*.md" 2>nul
del /Q "PADDLEPADDLE_*.md" 2>nul
del /Q "COPY_*.md" 2>nul
del /Q "FIXED_*.md" 2>nul
del /Q "WAIT_*.md" 2>nul
del /Q "START_*.md" 2>nul
del /Q "EXECUTE_*.md" 2>nul
del /Q "FORCE_*.md" 2>nul
del /Q "KILL_*.md" 2>nul
del /Q "NETEJA_*.md" 2>nul
del /Q "MONITORITZAR_*.md" 2>nul
del /Q "RESTART_*.md" 2>nul

echo [OK] Documentacio de proves eliminada

echo.
echo [3/4] Eliminant scripts duplicats...

REM Eliminar scripts de proves
del /Q "build_*.bat" 2>nul
del /Q "BUILD_*.bat" 2>nul
del /Q "rebuild_*.bat" 2>nul
del /Q "REBUILD_*.bat" 2>nul
del /Q "test_*.bat" 2>nul
del /Q "TEST_*.bat" 2>nul
del /Q "check_*.bat" 2>nul
del /Q "CHECK_*.bat" 2>nul
del /Q "afegir_*.bat" 2>nul
del /Q "ARREGLAR_*.bat" 2>nul
del /Q "DIAGNOSTICAR_*.bat" 2>nul
del /Q "CLEAN_*.bat" 2>nul
del /Q "EMERGENCY_*.bat" 2>nul
del /Q "FORCE_*.bat" 2>nul
del /Q "KILL_*.bat" 2>nul
del /Q "REINICIAR_*.bat" 2>nul
del /Q "UTILITZAR_*.bat" 2>nul
del /Q "run_*.bat" 2>nul
del /Q "setup_*.bat" 2>nul
del /Q "GIT_*.bat" 2>nul

REM Eliminar scripts shell de proves
del /Q "rebuild_*.sh" 2>nul
del /Q "check_*.sh" 2>nul
del /Q "iniciar_*.sh" 2>nul
del /Q "tornar_*.sh" 2>nul
del /Q "setup_*.sh" 2>nul
del /Q "instal·lar_*.sh" 2>nul

echo [OK] Scripts duplicats eliminats

echo.
echo [4/4] Eliminant logs i temporals...

REM Eliminar logs i outputs
del /Q "build_log.txt" 2>nul
del /Q "build_output.txt" 2>nul
del /Q "*.csv" 2>nul
del /Q "*.mp4" 2>nul

REM Eliminar docker-compose duplicats
del /Q "docker-compose.cloud.yml" 2>nul
del /Q "docker-compose.hub.yml" 2>nul
del /Q "docker-compose.hub-millores.yml" 2>nul
del /Q "docker-compose.prod.yml" 2>nul

REM Eliminar workflows duplicats
del /Q ".github\workflows\build.yml" 2>nul
del /Q ".github\workflows\docker-build-millores.yml" 2>nul
del /Q "GITHUB_ACTIONS_BUILD.yml" 2>nul

echo [OK] Logs i temporals eliminats

echo.
echo ========================================
echo NETEJA COMPLETADA!
echo ========================================
echo.
echo Fitxers mantinguts (IMPORTANTS):
echo - README.md
echo - ARQUITECTURA_DUAL_IA.md
echo - CONFIGURAR_GEMINI_API.md
echo - DEPLOY_AMB_IA.bat
echo - DEPLOY_GOOGLE_CLOUD_RUN.md
echo - RESUM_INTEGRACIO_IA.md
echo - GUIA_INTEGRACIO_LLM.md
echo - ACTUALITZAR_APLICACIO.bat
echo - NETEJAR_PROJECTE.bat
echo - docker-compose.yml
echo - docker-compose.llm.yml
echo - cloudbuild.yaml
echo.
echo Si vols recuperar algun fitxer, esta a: BACKUP_NETEJA\
echo.
pause
