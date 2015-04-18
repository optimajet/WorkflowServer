@set @x=0; new ActiveXObject('Shell.Application').ShellExecute ('cmd.exe','/K ' + '"' + WScript.ScriptFullName + '"' + ' Admin','','runas',1);/*
@echo off
if "%~1" neq "Admin" (
  cscript.exe //nologo //e:jscript "%~f0"
) else (
  cd /d "%~dp0"
  cd bin
  C:\Windows\Microsoft.NET\Framework\v4.0.30319\installutil.exe WorkflowServerSevice.exe /uninstall
  pause
)
exit /B

*/