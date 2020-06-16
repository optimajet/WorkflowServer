#!/bin/sh

if ! type dotnet > /dev/null; then
  echo ".NET Core not found. Please install .NET Core 2.1 to run this application"
  echo "For more information visit https://dotnet.microsoft.com/download/dotnet-core/2.1"
  exit 127
fi

cd ./bin
dotnet WorkflowServer.dll
