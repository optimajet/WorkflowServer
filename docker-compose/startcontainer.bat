@echo OFF

docker-compose build
IF ERRORLEVEL 9009 goto :NO_DOCKER

docker-compose up

pause

exit

:NO_DOCKER
echo Docker Compose not found. Please install Docker Compose to run this application
echo For more information visit https://docs.docker.com/compose/install/
