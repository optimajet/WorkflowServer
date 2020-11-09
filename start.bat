@echo OFF

CD "bin"

dotnet "WorkflowServer.dll"
IF ERRORLEVEL 9009 goto :NO_DOTNETCORE

pause

exit

:NO_DOTNETCORE
echo .NET Core not found. Please install .NET Core 3.1 to run this application
echo For more information visit https://dotnet.microsoft.com/download/dotnet-core/3.1
