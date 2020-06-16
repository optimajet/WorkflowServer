$serviceName = "OptimaJet.WorkflowServer";

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
else
{
  Write-Host "$serviceName doesn't exist";
}