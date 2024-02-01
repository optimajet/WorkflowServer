#!/bin/sh

if ! type dotnet > /dev/null; then
  echo ".NET not found. Please install .NET 8.0 to run this application"
  echo "For more information visit https://dotnet.microsoft.com/en-us/download"
  exit 127
fi

cd ./bin
dotnet WorkflowServer.dll
