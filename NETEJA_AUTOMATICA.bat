@echo off
echo Netejant fitxers innecessaris...

REM Crear backup
if not exist "BACKUP_NETEJA" mkdir "BACKUP_NETEJA"

REM Eliminar documentacio de proves
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
del /Q "COM_OBRIR_*.md" 2>nul
del /Q "COMANDES_*.md" 2>nul
del /Q "LA_VERITAT_*.md" 2>nul
del /Q "REAL_*.md" 2>nul
del /Q "FINAL_SOLUTION*.md" 2>nul
del /Q "FINAL_*.md" 2>nul
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
del /Q "EXECUTAR_*.md" 2>nul
del /Q "FORCE_*.md" 2>nul
del /Q "KILL_*.md" 2>nul
del /Q "NETEJA_*.md" 2>nul
del /Q "MONITORITZAR_*.md" 2>nul
del /Q "RESTART_*.md" 2>nul
del /Q "PASSOS_*.md" 2>nul
del /Q "PLA_*.md" 2>nul
del /Q "INSTRUCCIONS_*.md" 2>nul
del /Q "INSTAL·LAR_*.md" 2>nul
del /Q "INSTALL_*.md" 2>nul
del /Q "MANUAL_*.md" 2>nul
del /Q "GITHUB_*.md" 2>nul
del /Q "GOOGLE_*.md" 2>nul
del /Q "DEPLOYMENT_*.md" 2>nul
del /Q "QUICKSTART.md" 2>nul
del /Q "PROJECT_*.md" 2>nul
del /Q "SYSTEM_*.md" 2>nul
del /Q "APLICACIO_*.md" 2>nul
del /Q "ACLARIMENT_*.md" 2>nul
del /Q "AFEGIR_*.md" 2>nul
del /Q "TODO_*.md" 2>nul
del /Q "EXPLICACIO_*.md" 2>nul
del /Q "CONFIGURAR_SECRETS*.md" 2>nul
del /Q "CONFIGURAR_GIT*.md" 2>nul
del /Q "CONFIGURAR_GITHUB*.md" 2>nul
del /Q "GUIA_ACTUALITZACIO*.md" 2>nul
del /Q "GUIA_DOCKER*.md" 2>nul
del /Q "GUIA_ENTRENAMENT*.md" 2>nul
del /Q "GUIA_RAPIDA*.md" 2>nul
del /Q "GUIA_US_APLICACIO.md" 2>nul
del /Q "GUIA_US_COMPLET*.md" 2>nul
del /Q "ANALISI_*.md" 2>nul
del /Q "IMPLEMENTAR_*.md" 2>nul
del /Q "TASCA_*.md" 2>nul
del /Q "RESUM_ACTUALITZACIO*.md" 2>nul
del /Q "RESUM_FINAL*.md" 2>nul
del /Q "REFACTOR_*.md" 2>nul
del /Q "UI_*.md" 2>nul
del /Q "README_DEPLOYMENT.md" 2>nul

REM Eliminar scripts duplicats
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
del /Q "EXECUTAR_*.bat" 2>nul
del /Q "INICIAR_*.bat" 2>nul
del /Q "VERIFICAR_*.bat" 2>nul
del /Q "DESPLEGAR_*.bat" 2>nul
del /Q "RUN_*.bat" 2>nul
del /Q "executar_*.bat" 2>nul

REM Eliminar scripts shell
del /Q "*.sh" 2>nul

REM Eliminar logs
del /Q "*.txt" 2>nul
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

echo Neteja completada!
echo Fitxers .md restants:
dir *.md /b | find /c /v ""
