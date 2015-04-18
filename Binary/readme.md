The WorkflowServer is open source standalone HTTP server. It supports two modes: console and windows service.  You can Integrate a workflow functionality to a solution using HTTP-protocol. Solution can use any technologies: .NET, PHP, Java, NodeJS, Ruby, Python.


<b>BEFORE USE CREATE TABLES FROM SCRIPTS!!! (Folder: SQL)</b>

<h2>1. Console</h2>

Execute HTTP server (ATTENTION: For current settings, need run <b>run_callbackapi_sharp.bat</b>): 
````
run_mssql.bat
```` 
Execute HTTP server (with log) (ATTENTION: For current settings, need run <b>run_callbackapi_sharp.bat</b>): 
````
run_mssql_withlog.bat
```` 

wfes.exe parameters:
````
Usage is: wfes [options]

        -url=<options>          Url for bind HTTP listener (Default: 'http://*:8077/')
        -callbackurl=<options>  URL for Callback API
        -callbackgenscheme      Enable request for post-generation of scheme
        -apikey=<options>       Key for access

Database:
        -dbprovider=<options>   DB Provider: mssql=MS SQL Server, oracle=Oracle, mysql=MySQL, postgresql=PostgreSQL, ravendb=RavenDB, mongodb=MongoDB
        -dbcs=<options>         ConnectionString for DB (Available for MS SQL, Oracle, PostgreSQL, MySQL_
        -dburl=<options>        Url for DB (Available for RavenDB, MongoDB
        -dbdatabase=<options>   Database name (Available for RavenDB, MongoDB

Other:
        -nostartworkflow
        -log                    Show logs to the console
        -befolder=<options>     Folder with backend files (Default: '../backend')
````

Example for MSSQL:
````
cd <bin folder>
wfes.exe -url="http://*:8077/" -callbackurl="http://localhost:8078/" -befolder="../backend" -callbackgenscheme -dbprovider=mssql -dbcs="Data Source=(local);Initial Catalog=WorkflowApp;Integrated Security=False;User ID=sa;Password=1;"
````

<h2>2. WindowsServise</h2>

Before install the services, check configuration: bin\WorkflowServerSevice.exe.config

For install the service (ATTENTION: For current settings, need run run_callbackapi_sharp.bat):
````
workflowservice_install.bat 
````
For unistall the service: 
````
workflowservice_uninstall.bat
````
The Log output to EventLogs/Applications (name: OptimaJet.WorkflowServer).

<h2>3. CallbackAPI</h2>

The package include a callbackapi console application on csharp. If you need sample on other language, contact sales@optimajet.com. 
Example: 
````
test\csharp\TestCallbackAPIService.exe http://*:8078
````