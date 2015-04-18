The WorkflowServer is open source standalone HTTP server. It supports two modes: console and windows service.  You can Integrate a workflow functionality to a solution using HTTP-protocol. Solution can use any technologies: .NET, PHP, Java, NodeJS, Ruby, Python.

Features
- Process scheme generation in runtime
- BackEnd with designer of process scheme
- Integration into any solutions (.NET, PHP, Java, NodeJS, Ruby, Python and etc.) using HTTP-protocol
- Database support: MS SQL, Oracle, MySQL, PostgreSQL, RavenDB, MongoDB
- Mode: Console and Windows Sevice

Homepage: http://workflowenginenet.com/server
Github: https://github.com/optimajet/WorkflowServer
Email: wf@optimajet.com

BEFORE USE CREATE TABLES FROM SCRIPTS!!! (Folder: \SQL)

1. Console

Execute HTTP server: run_mssql.bat (ATTENTION: For current settings, need run run_callbackapi_sharp.bat)
Execute HTTP server (with log): run_mssql_withlog.bat (ATTENTION: For current settings, need run run_callbackapi_sharp.bat)

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

Example for MSSQL:
cd <bin folder>
wfes.exe -url="http://*:8077/" -callbackurl="http://localhost:8078/" -befolder="../backend" -callbackgenscheme -dbprovider=mssql -dbcs="Data Source=(local);Initial Catalog=WorkflowApp;Integrated Security=False;User ID=sa;Password=1;"

2. WindowsServise

Before install the services, check configuration: bin\WorkflowServerSevice.exe.config

For install the service: workflowservice_install.bat (ATTENTION: For current settings, need run run_callbackapi_sharp.bat)
For unistall the service: workflowservice_uninstall.bat
The Log output to EventLogs/Applications (name: OptimaJet.WorkflowServer).

3. CallbackAPI

The package include a callbackapi console application on csharp.
If you need sample on other language, contact sales@optimajet.com. 
Example: test\csharp\TestCallbackAPIService.exe http://*:8078