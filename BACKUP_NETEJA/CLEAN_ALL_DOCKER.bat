@echo off
echo ========================================
echo NETEJA COMPLETA DE DOCKER
echo ========================================
echo.
echo Aquest script netejara TOTS els contenidors,
echo imatges, volums i xarxes de Docker.
echo.
pause

echo.
echo [1/6] Aturant tots els contenidors...
docker stop $(docker ps -aq) 2>nul

echo.
echo [2/6] Esborrant tots els contenidors...
docker rm $(docker ps -aq) 2>nul

echo.
echo [3/6] Esborrant totes les imatges...
docker rmi $(docker images -q) -f 2>nul

echo.
echo [4/6] Esborrant tots els volums...
docker volume rm $(docker volume ls -q) 2>nul

echo.
echo [5/6] Esborrant totes les xarxes...
docker network prune -f

echo.
echo [6/6] Neteja final del sistema...
docker system prune -a -f --volumes

echo.
echo ========================================
echo NETEJA COMPLETADA!
echo ========================================
echo.
echo Ara Docker esta completament net.
echo Pots fer build de mobil_scan sense problemes.
echo.
pause
