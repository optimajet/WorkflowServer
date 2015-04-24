WorkflowServer. Powered by WorkflowEngine.NET
==================

The WorkflowServer is open source standalone HTTP server. It supports two modes: console and windows service.  You can Integrate a workflow functionality to a solution using HTTP-protocol. Solution can use any technologies: .NET, PHP, Java, NodeJS, Ruby, Python.

<h2>Features:</h2>
<ul>
<li>Process scheme generation in runtime</li>
<li>BackEnd with designer of process scheme</li>
<li>Integration into any solutions (.NET, PHP, Java, NodeJS, Ruby, Python and etc.) using HTTP-protocol</li>
<li>Database support: MS SQL, Oracle, MySQL, PostgreSQL, RavenDB, MongoDB</li>
<li>Mode: Console and Windows Sevice</li>
</ul>

<h3>Execute</h3>
You can execute the WorkflowServer in Console mode or Windows Service mode.
````
Usage is: wfes [options]
        -url=<options>          Url for bind HTTP listener (Default: 'http://*:8077/')
        -callbackurl=<options>  URL for Callback API
        -callbackgenscheme      Enable request for post-generation of scheme
Database:
        -dbprovider=<options>   DB Provider: mssql=MS SQL Server, oracle=Oracle, mysql=MySQL, postgresql=PostgreSQL, ravendb=RavenDB, mongodb=MongoDB
        -dbcs=<options>         ConnectionString for DB (Available for MS SQL, Oracle, PostgreSQL, MySQL)
        -dburl=<options>        Url for DB (Available for RavenDB, MongoDB
        -dbdatabase=<options>   Database name (Available for RavenDB, MongoDB
Other:
        -nostartworkflow
        -log                    Show logs to the console
        -befolder=<options>     Folder with backend files (Default: '../backend')
````
<h3>Inegration API</h3>
Integration via HTTP:
<ul>
<li>Workflow API</li>
<li>Designer API</li>
<li>Callback API</li>
</ul>

1. Workflow API
````
url: /workflowapi
````
Implements the basic operation of WorkflowRuntime.
The basic operations:
<ul>
<li>Creation of the instance</li>
<li>Getting the list of available commands</li>
<li>Execution of the command</li>
<li>Getting the list of available states to set</li>
<li>Set State</li>
<li>Process is exist</li>
</ul>
Creation of the instance - Creates the instance of the process.
````
/workflowapi?operation=createinstance&processid=&schemacode=&identityid=&impersonatedIdentityId=&parameters=
````
Getting the list of available commands - Returns the list of available commands for current state of the process and known user Id.
````
/workflowapi?operation=getavailablecommands&processid=&identityid=&impersonatedIdentityId=
````
Execution of the command - This call will execute the command.
````
/workflowapi?operation=executecommand&processid=&identityid=&impersonatedIdentityId=
````
Getting the list of available states to set - Returns the list of available states, that can be set through the SetState function.
````
/workflowapi?operation=getavailablestatetoset&processid=
````
Set state - This call will set state for the process.
````
/workflowapi?operation=setstate&processid=&identityid=&impersonatedIdentityId=&state&parameters=
````
Process is exist
````
/workflowapi?operation=isexistprocess&processid=
````
Response
````
{
    "success": "",
    "data": "",
    "error": ""
}
````
<h3>2. Designer API</h3>
````
url: /designerapi
````
Implements the server-interface for the workflow designer.

<h3>3. Callback API</h3>
For full integration WorkflowEngine.NET requires implementation of the interfaces: IWorkflowRuleProvider, IWorkflowActionProvider, IWorkflowGenerator. WokflowServer forwards request via HTTP (POST) to an external service.

<h4>Paramerets of IWorkflowActionProvider:</h4>

GetActions
````
input: type=getactions
return: [list of actions]
````
ExecuteAction
````
input: type=executeaction, name=[name of action], parameter=[parameter of action], pi=[ProcessInstanse serialized to json]
````
ExecuteCondition
````
input: type=executecondition, name=[name of action], parameter=[parameter of action], pi=[ProcessInstanse serialized to json]
return: [result of condition]
````

<h4>Paramerets of IWorkflowRuleProvider:</h4>

GetRules
````
input: type=getrules
return: [list of rules]
````
Check
````
input: type=check,pi=[ProcessInstanse serialized to json],identityid=[user id],name=[name of rule],parameter=[parameter of rule]
return: [result of check]
````
GetIdentities
````
input: type=getidentities,pi=[ProcessInstanse serialized to json],name=[name of rule],parameter=[parameter of rule]
return: [list of idetities of users]
````
<h4>Paramerets of IWorkflowGenerator:</h4>
Generate
````
input: type=generate, schemecode=[code of scheme],schemeid=[id of scheme],parameters=[parameters of workflow],scheme=[XML scheme of workflow]
return: [XML scheme of workflow]
````
<h3>Backend</h3>
Used for create/edit/view scheme of workflow. 

<a href="http://workflowenginenet.com/server"><img src="http://workflowenginenet.com/Cms_Data/Contents/WFE/Media/content_images/workflowserver.png" alt="gworkflowserver" width="400" style="
    border: 1px solid;
    border-color: #3e4d5c;"></a>

<hr>
<b>Official web site</b> - <a href="http://workflowenginenet.com">http://workflowenginenet.com/server</a><br/>
For technical questions, please contact <a href="mailto:wf@optimajet.com?subject=Qustion from hithub">wf@optimajet.com<a><br/>
For commercial use, please contact <a href="mailto:sales@optimajet.com?subject=Qustion from hithub">sales@optimajet.com</a><br/>

<b>WorkflowEngine.NET free limits:</b>
<ul>
<li>Activity: 15</li>
<li>Transition: 25</li>
<li>Command: 5</li>
<li>Schema: 1</li>
<li>Thread: 1</li>
</ul>
