#!/bin/sh

if ! type docker-compose > /dev/null; then
  echo "Docker Compose not found. Please install Docker Compose to run this application"
  echo "For more information visit https://docs.docker.com/compose/install/"
  exit 127
fi

docker-compose -f docker-files/docker-compose.yml build
docker-compose -f docker-files/docker-compose.yml run --rm start_db
docker-compose -f docker-files/docker-compose.yml up