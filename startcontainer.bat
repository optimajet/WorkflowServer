@echo OFF

docker-compose -f docker-files/docker-compose.yml build
IF ERRORLEVEL 9009 goto :NO_DOCKER

docker-compose -f docker-files/docker-compose.yml run --rm start_db
docker-compose -f docker-files/docker-compose.yml up

pause

exit

:NO_DOCKER
echo Docker Compose not found. Please install Docker Compose to run this application
echo For more information visit https://docs.docker.com/compose/install/
