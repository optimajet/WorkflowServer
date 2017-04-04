WorkflowServer. Powered by WorkflowEngine.NET
==================

The WorkflowServer is open source standalone HTTP server. It supports two modes: console and windows service.  You can Integrate a workflow functionality to a solution using HTTP-protocol. Solution can use any technologies: .NET, PHP, Java, NodeJS, Ruby, Python.

## Features

- Process scheme generation in runtime
- BackEnd with designer of process scheme
- Integration into any solutions (.NET, PHP, Java, NodeJS, Ruby, Python and etc.) using HTTP-protocol
- Database support: MS SQL, Oracle, MySQL, PostgreSQL, RavenDB, MongoDB
- Mode: Console and Windows Sevice

### Execution

You can execute the WorkflowServer in Console mode or Windows Service mode.
```
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
```

### Inegration API

Integration via HTTP:

- Workflow API
- Designer API
- Callback API

#### Workflow API

```
url: /workflowapi
```
Implements the basic operation of WorkflowRuntime.
The basic operations:

- Creation of the instance
- Getting the list of available commands<
- Execution of the command
- Getting the list of available states to set
- Set State
- Process is exist

Creation of the instance - Creates the instance of the process. Please note that the  parameters parameter in query will be passed to an 
IWorkflowGenerator instance. In most cases you don't need it. If you want to pass initial parameters to the process. Use POST query and specify 
this parameters as form data.
```
/workflowapi?operation=createinstance&processid=&schemacode=&identityid=&impersonatedIdentityId=&parameters=
```
Getting the list of available commands - Returns the list of available commands for current state of the process and known user Id.
```
/workflowapi?operation=getavailablecommands&processid=&identityid=&impersonatedIdentityId=
```
Execution of the command - This call will execute the command. If you want to pass command parameters to the process. Use POST query and specify 
this parameters as form data.
```
/workflowapi?operation=executecommand&processid=&identityid=&impersonatedIdentityId=
```
Getting the list of available states to set - Returns the list of available states, that can be set through the SetState function.
```
/workflowapi?operation=getavailablestatetoset&processid=
```
Set state - This call will set state for the process.
```
/workflowapi?operation=setstate&processid=&identityid=&impersonatedIdentityId=&state&parameters=
```
Process is exist
```
/workflowapi?operation=isexistprocess&processid=
```
Response
```
{
    "success": "",
    "data": "",
    "error": ""
}
```
#### Designer API
```
url: /designerapi
```
Implements the server-interface for the workflow designer.

#### Callback API
For full integration WorkflowEngine.NET requires implementation of the interfaces: IWorkflowRuleProvider, IWorkflowActionProvider, IWorkflowGenerator. WokflowServer forwards request via HTTP (POST) to an external service.

**Paramerets of IWorkflowActionProvider:**

GetActions
```
input: type=getactions
return: [list of actions]
```
ExecuteAction
```
input: type=executeaction, name=[name of action], parameter=[parameter of action], pi=[ProcessInstanse serialized to json]
```
ExecuteCondition
```
input: type=executecondition, name=[name of action], parameter=[parameter of action], pi=[ProcessInstanse serialized to json]
return: [result of condition]
```

**Paramerets of IWorkflowRuleProvider:**

GetRules
```
input: type=getrules
return: [list of rules]
```
Check
```
input: type=check,pi=[ProcessInstanse serialized to json],identityid=[user id],name=[name of rule],parameter=[parameter of rule]
return: [result of check]
```
GetIdentities
```
input: type=getidentities,pi=[ProcessInstanse serialized to json],name=[name of rule],parameter=[parameter of rule]
return: [list of idetities of users]
```
**Paramerets of IWorkflowGenerator:**
Generate
````
input: type=generate, schemecode=[code of scheme],schemeid=[id of scheme],parameters=[parameters of workflow],scheme=[XML scheme of workflow]
return: [XML scheme of workflow]
````
#### Backend
Used for create/edit/view scheme of workflow. 

![https://workflowengine.io/designer](https://workflowengine.io/images/schemes/scheme.png)

**Official web site** - [https://workflowengine.io/](https://workflowengine.io/)

For technical questions, please contact <a href="mailto:wf@optimajet.com?subject=Qustion from hithub">wf@optimajet.com</a>

For commercial use, please contact <a href="mailto:sales@optimajet.com?subject=Qustion from hithub">sales@optimajet.com</a>

**WorkflowEngine.NET free limits:**
- Activity: 15
- Transition: 25
- Command: 5
- Schema: 1
- Thread: 1

