#!/bin/sh

if ! type dotnet > /dev/null; then
  echo ".NET not found. Please install .NET SDK 8.0 to run this application"
  echo "For more information visit https://dotnet.microsoft.com/en-us/download"
  exit 127
fi

dotnet restore -s https://api.nuget.org/v3/index.json
dotnet build
dotnet publish -o ./bin

./start.sh
