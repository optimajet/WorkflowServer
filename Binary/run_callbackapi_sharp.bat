@set @x=0; new ActiveXObject('Shell.Application').ShellExecute ('cmd.exe','/K ' + '"' + WScript.ScriptFullName + '"' + ' Admin','','runas',1);/*
@echo off
if "%~1" neq "Admin" (
  cscript.exe //nologo //e:jscript "%~f0"
) else (
  cd /d "%~dp0"
  cd test\csharp
  TestCallbackAPIService.exe http://*:8078/
  pause
)
exit /B

*/
