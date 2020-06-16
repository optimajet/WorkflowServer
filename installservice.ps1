$serviceName = "OptimaJet.WorkflowServer";
$serviceDescription = "OptimaJet Workflow Server";
$exepath = Get-ChildItem -Path .\WindowsService -Filter WorkflowServerService.exe -Recurse;
$exeDirectory = $exepath.Directory;
$exe = $exepath.FullName;
$user =  "NT AUTHORITY\SYSTEM";
# $user = $env:computername + "\" + $env:username;

 $netCoreVer = (dir (Get-Command dotnet).Path.Replace('dotnet.exe', 'shared\Microsoft.NETCore.App')).Name | Where-Object {$_ -like '2.1.*'}

 if (!$netCoreVer) {  
    Write-Host ".NET Core not found. Please install .NET Core 2.1 to run this application";
    Write-Host "For more information visit https://dotnet.microsoft.com/download/dotnet-core/2.1";
    Exit; 
}

$acl = Get-Acl $exeDirectory
$aclRuleArgs = $user, "Read,Write,ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule($aclRuleArgs)
$acl.SetAccessRule($accessRule) | Out-Null
$acl | Set-Acl $exeDirectory | Out-Null

$service = Get-WmiObject -Class Win32_Service -Filter "Name='$serviceName'"

if ($service) { 
    if ($service.State = "Running")
    {
        Stop-Service $serviceName  | Out-Null;
         Write-Host "$serviceName stopped"
    }


    $service.delete() | Out-Null;
     Write-Host "$serviceName deleted";
}

New-Service -Name $serviceName -BinaryPathName $exe  -Description $serviceDescription -DisplayName $serviceName -StartupType Automatic | Out-Null;

if ($error)
{
    Write-Host "Unable to create $serviceName";
    Exit;
}

Write-Host "$serviceName created";

# New-Service -Name $serviceName -BinaryPathName $exepath -Credential $user -Description $serviceDescription -DisplayName $serviceName -StartupType Automatic  | Out-Null;

Start-Service -Name $serviceName  | Out-Null;
if ($error)
{
    Write-Host "Unable to start $serviceName";
    Exit;
}
Write-Host "$serviceName started";

