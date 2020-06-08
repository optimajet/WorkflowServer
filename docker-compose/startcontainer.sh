#!/bin/sh

if ! type docker-compose > /dev/null; then
  echo "Docker Compose not found. Please install Docker Compose to run this application"
  echo "For more information visit https://docs.docker.com/compose/install/"
  exit 127
fi

docker-compose build
docker-compose up
