@echo off
chcp 65001 >nul
echo ========================================
echo 🧹 NETEJA DEL PROJECTE
echo ========================================
echo.
echo Aquesta neteja eliminarà:
echo   ❌ Documentació temporal (50+ fitxers .md)
echo   ❌ Scripts Docker locals (30+ fitxers .bat/.sh)
echo   ❌ Logs i fitxers temporals
echo   ❌ Docker Compose files (locals)
echo.
echo Mantindrà:
echo   ✅ Codi font (backend, frontend, worker)
echo   ✅ cloudbuild.yaml
echo   ✅ Guies essencials (5 fitxers)
echo   ✅ Scripts Cloud Run (3 fitxers)
echo.
set /p CONFIRM="Estàs segur? (S/N): "
if /i not "%CONFIRM%"=="S" (
    echo.
    echo Neteja cancel·lada.
    pause
    exit /b 0
)

echo.
echo 🗑️  Eliminant fitxers...
echo.

REM ============================================
REM DOCUMENTACIÓ TEMPORAL
REM ============================================
echo [1/4] Eliminant documentació temporal...

del /Q ACLARIMENT_IMPORTANT.md 2>nul
del /Q AFEGIR_MODEL_YOLO.md 2>nul
del /Q ALTERNATIVES_PROFESSIONALS.md 2>nul
del /Q ANALISI_PROBLEMES_I_MILLORES.md 2>nul
del /Q APLICACIO_FUNCIONANT.md 2>nul
del /Q ARCHITECTURE.md 2>nul
del /Q BUILD_LOCAL_AMB_IA_EN_PROGRES.md 2>nul
del /Q COM_HO_FAN_ELS_PROFESSIONALS.md 2>nul
del /Q COM_OBRIR_TERMINAL_WSL2.md 2>nul
del /Q COMANDES_RAPIDES_WSL2.md 2>nul
del /Q CONFIGURAR_GIT_I_GITHUB.md 2>nul
del /Q CONFIGURAR_GITHUB_SECRETS.md 2>nul
del /Q CONFIGURAR_SECRETS_CORRECTAMENT.md 2>nul
del /Q CONFIGURAR_SECRETS_GITHUB.md 2>nul
del /Q COPY_THIS_YAML.md 2>nul
del /Q CRITICAL_PATH_TEST_RESULTS.md 2>nul
del /Q DEPLOYMENT_GUIDE.md 2>nul
del /Q DOCKER_BUILD_FIX.md 2>nul
del /Q DOCKER_CLOUD_BUILD_SETUP.md 2>nul
del /Q DOCKER_RESOURCE_ERROR.md 2>nul
del /Q EMERGENCY_CHECK.bat 2>nul
del /Q EXECUTAR_BUILD_GITHUB.md 2>nul
del /Q EXECUTE_NOW_OPTION_C.md 2>nul
del /Q EXPLICACIO_OLLAMA.md 2>nul
del /Q FINAL_PROJECT_SUMMARY.md 2>nul
del /Q FINAL_SOLUTION_MEMORY.md 2>nul
del /Q FINAL_SOLUTION.md 2>nul
del /Q FINAL_YAML_OPTIMIZED.md 2>nul
del /Q FIXED_YAML.md 2>nul
del /Q FORCE_CLOSE_EVERYTHING.md 2>nul
del /Q GITHUB_ACCOUNT_STRATEGY.md 2>nul
del /Q GITHUB_ACTIONS_BUILD.yml 2>nul
del /Q GITHUB_ACTIONS_SETUP.md 2>nul
del /Q GOOGLE_CLOUD_RUN_GUIDE.md 2>nul
del /Q GUIA_ACTUALITZACIO_ZXING.md 2>nul
del /Q GUIA_DOCKER_WSL2_NATIU.md 2>nul
del /Q GUIA_ENTRENAMENT_YOLO.md 2>nul
del /Q GUIA_INTEGRACIO_LLM.md 2>nul
del /Q GUIA_RAPIDA_DOCKER_HUB.md 2>nul
del /Q GUIA_US_APLICACIO.md 2>nul
del /Q GUIA_US_COMPLET_AMB_EXEMPLES.md 2>nul
del /Q IMPLEMENTAR_MILLORES_ARA.md 2>nul
del /Q INSTALL_GIT.md 2>nul
del /Q "INSTAL·LAR_DOCKER_COMPOSE_MANUAL.md" 2>nul
del /Q INSTRUCCIONS_CLARES_ARA.md 2>nul
del /Q INSTRUCCIONS_DEPLOY_NUVOL.md 2>nul
del /Q INSTRUCCIONS_FINALS_ZXING.md 2>nul
del /Q KILL_EVERYTHING_WINDOWS.md 2>nul
del /Q LA_VERITAT_SOBRE_DOCKER.md 2>nul
del /Q MANUAL_GITHUB_SETUP.md 2>nul
del /Q MONITORITZAR_BUILD.md 2>nul
del /Q NETEJA_TOTAL_DOCKER.md 2>nul
del /Q NETWORK_TIMEOUT_FIX.md 2>nul
del /Q PADDLEPADDLE_VERSION_FIX.md 2>nul
del /Q PASSOS_FINALS.md 2>nul
del /Q PLA_COMPLET_EXECUTAT.md 2>nul
del /Q PLA_CORRECCIONS_FINALS.md 2>nul
del /Q PROBLEMA_STREAMLIT_SOLUCIONAT.md 2>nul
del /Q PROFESSIONAL_SOLUTIONS.md 2>nul
del /Q PROJECT_SUMMARY.md 2>nul
del /Q QUE_ESTA_PASSANT_BUILD.md 2>nul
del /Q QUE_FER_ARA.md 2>nul
del /Q QUE_FER_AVUI_DIUMENGE.md 2>nul
del /Q QUICKSTART.md 2>nul
del /Q README_DEPLOYMENT.md 2>nul
del /Q REAL_PROBLEM_FOUND.md 2>nul
del /Q REBUILD_AMB_WSL2.md 2>nul
del /Q REFACTOR_YOLO_SUMMARY.md 2>nul
del /Q RESTART_WSL_AND_BUILD.md 2>nul
del /Q RESUM_ACTUALITZACIO_ZXING.md 2>nul
del /Q RESUM_FINAL_SOLUCIO.md 2>nul
del /Q SOLUCIO_BUILD_ERROR.md 2>nul
del /Q SOLUCIO_CONNEXIO_93_PACKET_LOSS.md 2>nul
del /Q SOLUCIO_DEFINITIVA_CONNEXIO.md 2>nul
del /Q SOLUCIO_DEFINITIVA_DOCKER_HUB.md 2>nul
del /Q SOLUCIO_DEFINITIVA_SENSE_DOCKER.md 2>nul
del /Q SOLUCIO_DEFINITIVA_SIMPLE.md 2>nul
del /Q SOLUCIO_DOCKER_ENGINE.md 2>nul
del /Q SOLUCIO_DOCKER_NO_INICIA.md 2>nul
del /Q SOLUCIO_ERROR_IO_DOCKER.md 2>nul
del /Q SOLUCIO_FINAL_EOF.md 2>nul
del /Q SOLUCIO_FINAL_MANUAL.md 2>nul
del /Q SOLUCIO_GITHUB_ACTIONS_FALLAT.md 2>nul
del /Q SOLUCIO_RPC_ERROR_FINAL.md 2>nul
del /Q SOLUCIO_SIMPLE_DOCKER_HUB.md 2>nul
del /Q SOLUCIO_SIMPLE_SENSE_CPP.md 2>nul
del /Q SOLUCIO_TERMINAL_VSCODE_WSL.md 2>nul
del /Q SOLUCIO_URGENT_WSL_TRENCAT.md 2>nul
del /Q SOLUCIO_WORKER_CPU.md 2>nul
del /Q SOLUCIO_WORKFLOW_FALLAT.md 2>nul
del /Q SOLUTION_NOW.md 2>nul
del /Q SOLUTION_RPC_ERROR.md 2>nul
del /Q START_BUILD_NOW.md 2>nul
del /Q SYSTEM_EXPLANATION.md 2>nul
del /Q TASCA_ZXING_COMPLETADA.md 2>nul
del /Q TESTING_REPORT.md 2>nul
del /Q TESTING_RESULTS_YOLO_REFACTOR.md 2>nul
del /Q TODO_ZXING_UPDATE.md 2>nul
del /Q UI_REDESIGN_SUMMARY.md 2>nul
del /Q UTILITZAR_DOCKER_WSL2.md 2>nul
del /Q VERIFICACIO_REFACTOR_YOLO.md 2>nul
del /Q VERIFICAR_CONTENIDORS_WSL2.md 2>nul
del /Q VERIFICAR_I_SOLUCIONS.md 2>nul
del /Q WAIT_FOR_BUILD.md 2>nul
del /Q WHAT_IS_HAPPENING.md 2>nul
del /Q WHY_NOT_IN_DOCKER_DESKTOP.md 2>nul
del /Q WSL2_MEMORY_FIX.md 2>nul

REM ============================================
REM SCRIPTS DOCKER (LOCALS)
REM ============================================
echo [2/4] Eliminant scripts Docker locals...

del /Q afegir_worker_simple.bat 2>nul
del /Q afegir_worker.bat 2>nul
del /Q ARREGLAR_DOCKER_PRIMER.bat 2>nul
del /Q build_cloud.bat 2>nul
del /Q BUILD_I_PUSH_LOCAL_FIXED.bat 2>nul
del /Q BUILD_I_PUSH_LOCAL.bat 2>nul
del /Q BUILD_NEW_WORKER.bat 2>nul
del /Q BUILD_PAS_A_PAS_AMB_IA.bat 2>nul
del /Q BUILD_PAS_A_PAS.bat 2>nul
del /Q BUILD_RAPID_DOCKER_DESKTOP.bat 2>nul
del /Q build_sequential.bat 2>nul
del /Q check_build_status.ps1 2>nul
del /Q check_docker_status.bat 2>nul
del /Q check_now.bat 2>nul
del /Q check_worker_build.bat 2>nul
del /Q CHECK_WORKER_STATUS.bat 2>nul
del /Q CLEAN_ALL_DOCKER.bat 2>nul
del /Q DEPLOY_DOCKER_HUB_ARA.bat 2>nul
del /Q DEPLOY_FACIL.bat 2>nul
del /Q DIAGNOSTICAR_I_ARREGLAR.bat 2>nul
del /Q EXECUTAR_ARA_FINAL.bat 2>nul
del /Q executar_mobil_scan.bat 2>nul
del /Q EXECUTAR_SENSE_MILLORES.bat 2>nul
del /Q GIT_PUSH_WORKER.bat 2>nul
del /Q INICIAR_AMB_LLM.bat 2>nul
del /Q INICIAR_DOCKER_I_EXECUTAR.bat 2>nul
del /Q INICIAR_I_REBUILD.bat 2>nul
del /Q REBUILD_ALL_NO_CACHE.bat 2>nul
del /Q REBUILD_BACKEND_ARA.bat 2>nul
del /Q REBUILD_COMPLET_AMB_IA.bat 2>nul
del /Q REBUILD_FRONTEND_ARA.bat 2>nul
del /Q REBUILD_WORKER_MINIMAL.bat 2>nul
del /Q REBUILD_WORKER_NO_CACHE.bat 2>nul
del /Q REBUILD_WORKER_RETRY.bat 2>nul
del /Q REBUILD_WORKER_SIMPLE.bat 2>nul
del /Q REINICIAR_DOCKER_I_BUILD.bat 2>nul
del /Q run_all_local.bat 2>nul
del /Q run_cloud.bat 2>nul
del /Q run_from_dockerhub.bat 2>nul
del /Q RUN_FROM_HUB_MILLORES.bat 2>nul
del /Q setup_cloud_builder.bat 2>nul
del /Q setup_github_actions.bat 2>nul
del /Q TEST_BUILD.bat 2>nul
del /Q TEST_CPP_SCANNER.bat 2>nul
del /Q TEST_EXHAUSTIU.bat 2>nul
del /Q TEST_WORKER_BUILD.bat 2>nul
del /Q UTILITZAR_DOCKER_DESKTOP.bat 2>nul
del /Q VERIFICAR_APLICACIO.bat 2>nul
del /Q VERIFICAR_ESTAT_ARA.bat 2>nul

REM Scripts WSL2
del /Q check_llm_status.sh 2>nul
del /Q iniciar_amb_llm_wsl.sh 2>nul
del /Q iniciar_amb_ollama_opcional.sh 2>nul
del /Q iniciar_local_simple.sh 2>nul
del /Q iniciar_prod.sh 2>nul
del /Q iniciar_worker_sense_llm.sh 2>nul
del /Q "instal·lar_docker_compose.sh" 2>nul
del /Q rebuild_worker_cpu.sh 2>nul
del /Q setup_docker_wsl2.sh 2>nul
del /Q SETUP_GIT_AUTOMATIC.sh 2>nul
del /Q tornar_a_intentar.sh 2>nul

REM ============================================
REM DOCKER COMPOSE FILES (LOCALS)
REM ============================================
echo [3/4] Eliminant Docker Compose files...

del /Q docker-compose.cloud.yml 2>nul
del /Q docker-compose.hub-millores.yml 2>nul
del /Q docker-compose.hub.yml 2>nul
del /Q docker-compose.llm.yml 2>nul
del /Q docker-compose.prod.yml 2>nul
REM Mantenir docker-compose.yml per referència local

REM ============================================
REM LOGS I TEMPORALS
REM ============================================
echo [4/4] Eliminant logs i fitxers temporals...

del /Q build_log.txt 2>nul
del /Q build_output.txt 2>nul
del /Q worker_logs.txt 2>nul
del /Q audit_results_*.csv 2>nul
del /Q *.log 2>nul

REM Fitxers multimedia temporals
del /Q VID_20251204_170312.mp4 2>nul
del /Q visio-stock-1765035550265.png 2>nul

REM GitHub workflows locals (no necessaris)
if exist .github\workflows\build.yml del /Q .github\workflows\build.yml 2>nul
if exist .github\workflows\docker-build-millores.yml del /Q .github\workflows\docker-build-millores.yml 2>nul

echo.
echo ========================================
echo ✅ NETEJA COMPLETADA!
echo ========================================
echo.
echo Fitxers eliminats:
echo   ❌ ~80 fitxers .md de documentació temporal
echo   ❌ ~50 scripts .bat/.sh de Docker local
echo   ❌ ~5 docker-compose files locals
echo   ❌ Logs i fitxers temporals
echo.
echo Fitxers mantinguts:
echo   ✅ backend/ frontend/ worker/ shared/
echo   ✅ cloudbuild.yaml
echo   ✅ README.md
echo   ✅ GUIA_COMPLETA_GESTIO_PROJECTE.md
echo   ✅ DEPLOY_GOOGLE_CLOUD_RUN.md
echo   ✅ GUIA_RAPIDA_GOOGLE_CLOUD.md
echo   ✅ COM_ACCEDIR_APLICACIO.md
echo   ✅ RESUM_FINAL_GOOGLE_CLOUD.md
echo   ✅ DESPLEGAR_SERVEIS_ARA.bat
echo   ✅ deploy_cloud_run.bat
echo   ✅ SETUP_GOOGLE_CLOUD.bat
echo   ✅ docker-compose.yml (referència)
echo.
echo El projecte està net i llest per Git! 🚀
echo.
pause
