$serviceName = "OptimaJet.WorkflowServer"
$serviceDescription = "OptimaJet Workflow Server"
$exepath = Get-ChildItem -Path .\WindowsService -Filter WorkflowServerService.exe -Recurse
$exeDirectory = $exepath.Directory
$exe = $exepath.FullName
$user =  "NT AUTHORITY\SYSTEM"

$netCoreVer = dotnet --list-runtimes | Select-String -Pattern '6\.0*'

 if (!$netCoreVer) {  
    Write-Host ".NET not found. Please install .NET 8.0 to run this application"
    Write-Host "For more information visit https://dotnet.microsoft.com/en-us/download"
    Exit; 
}

$acl = Get-Acl $exeDirectory
$aclRuleArgs = $user, "Read,Write,ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($aclRuleArgs)
$acl.SetAccessRule($accessRule) | Out-Null
$acl | Set-Acl $exeDirectory | Out-Null

$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($service.Length -gt 0) { 
    if ($service.Status -eq "Running")
    {
        try
        {
             Stop-Service $serviceName
        }
        catch 
        {
            Write-Host $error
            Write-Host "Unable to stop $serviceName"
            Exit
        }

        Write-Host "$serviceName stopped"
    }

    try
    {
        if (Get-Command "Remove-Service" -errorAction SilentlyContinue)
        {
            Remove-Service $serviceName
        }
        else
        {
            sc.exe delete $serviceName | Out-Null 
        }
    }
    catch
    {
        Write-Host $error
        Write-Host "Unable to delete $serviceName";
        Exit;
    }

    Write-Host "$serviceName deleted";
}

try
{
    New-Service -Name $serviceName -BinaryPathName $exe  -Description $serviceDescription -DisplayName $serviceName -StartupType Automatic | Out-Null
}
catch
{
    Write-Host $error
    Write-Host "Unable to create $serviceName";
    Exit;
}

Write-Host "$serviceName created";

try
{
    Start-Service -Name $serviceName
}
catch
{
    Write-Host $error
    Write-Host "Unable to start $serviceName";
    Exit;
}

Write-Host "$serviceName started";

