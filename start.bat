@echo OFF

CD "bin"

dotnet "WorkflowServer.dll"
IF ERRORLEVEL 9009 goto :NO_DOTNETCORE

pause

exit

:NO_DOTNETCORE
echo .NET not found. Please install .NET 8.0 to run this application
echo For more information visit https://dotnet.microsoft.com/en-us/download
