@echo OFF

dotnet restore -s https://api.nuget.org/v3/index.json
IF ERRORLEVEL 9009 goto :NO_SDK_ERROR

dotnet build

dotnet publish -o bin

start.bat

exit

:NO_SDK_ERROR
echo .NET Core not found. Please install .NET Core SDK 3.1 to run this application
echo For more information visit https://dotnet.microsoft.com/download/dotnet-core/3.1
