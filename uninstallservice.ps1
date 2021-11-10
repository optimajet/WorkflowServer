$serviceName = "OptimaJet.WorkflowServer";

$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($service.Length -gt 0) 
{
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
else
{
  Write-Host "$serviceName doesn't exist";
}