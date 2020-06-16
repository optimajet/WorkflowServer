#!/bin/sh

if ! type dotnet > /dev/null; then
  echo ".NET Core not found. Please install .NET Core SDK 2.1 to run this application"
  echo "For more information visit https://dotnet.microsoft.com/download/dotnet-core/2.1"
  exit 127
fi

dotnet restore -s https://api.nuget.org/v3/index.json
dotnet build
dotnet publish -o ./bin

./start.sh
