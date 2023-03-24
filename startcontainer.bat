@echo OFF

docker compose -f docker-files/docker-compose.yml build
docker compose -f docker-files/docker-compose.yml run --rm start_db
docker compose -f docker-files/docker-compose.yml up

pause

exit
