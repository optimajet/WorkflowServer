<!--Stay on the edge of our innovations and learn about the changes made to Workflow Server with each of our releases.-->
# Release Notes

## 2.7 {#2.7}

- Updated to [Workflow Engine .NET 5.0](https://workflowengine.io/documentation/release-notes/workflow-engine/#5.0)
- Workflow Server application now runs on **.NET Core 3.1** platform.
- Users are added to the database and Admin panel. Users can be created and modified through the Admin panel, through the Workflow API methods and using synchronization via LDAP.
- Users can be assigned with Roles, thus the role-based authorization of full value became available in the Workflow.
- Added authorization for forms based on OpenId, added authentication option via Facebook, Google and Okta.
- CallbackApi is now able to connect multiple callback servers.
- Files Plugin and Loops Plugin from Workflow Engine .NET have been added.
- Added an option to import and export server configuration. All server settings, schemes, code actions, forms and users are exported (and imported).
- Added Developer Mode, in which the server configuration is also saved to hard drive. The directory is specified in the configuration file of a specific instance.
- Added an option to embed forms into other web-sites and applications.
- In the Workflow API has been added the Resume method which resumes the process execution.
- In the Workflow API has been added a method to update the process scheme to a new one. The same feature has been added to the Admin panel interface.

**The following additional actions must be taken to upgrade to Workflow Server 2.7:**

- Install [.NET Core 3.1](https://dotnet.microsoft.com/download/dotnet-core/3.1), if you don't already install it.
- Run the SQL script *update_wfs_2_7* for all relative databases and MongoDB.
  - [MSSQL]()
  - [PostgreSQL]()
  - [Oracle]()
  - [MySQL]()
  - [MongoDB]()
- Add the following settings into the [configuration file](https://github.com/optimajet/WorkflowServer/blob/master/config.json).
  
  ```javascript
  "ExternalEventLoggerConfig": {
    "ConsoleTarget": [ "Error" ]
  },
    "IdentityServerSettings": {
    "CertificateFile": "IdentityServer4Auth.pfx",
    "CertificatePassword": "password",
    "RedirectHosts": [ "http://localhost:8077", "http://localhost:8078" ],
    "RedirectUrls": [],
    "DefaultFormsRedirect": "http://localhost:8078",
    "AuthorityBaseUrl": "http://localhost:8077",
    "UseHostRedirectValidator": false
  },
  ```

## 2.6 {#2.6}

- Updated to [Workflow Engine .NET 4.2](https://workflowengine.io/documentation/release-notes/workflow-engine/#4.2)
- Support of the multi-server mode has been added. If you need to run the Workflow Server instance in multi-server mode,  add the following setting to the *config.json* file.
  
  ```javascript
  {
    "IsMultiServer": true
  }
  ```

- Added database logs with records search possibility.
- Added new Workflow API  methods for managing a Workflow Server instance. *Start*, *Stop* and *IsActive*.
- Added ability to develop the end-user forms (frontend interface) based on Vue.js. It is the beta version. Access control for these forms will be added in the next version. It is also possible in the next version the base library of controls will be changed.

**If you use global Code Actions and you have several servers deployed, then to apply the changes you need to restart each of them. To do this, you can use the *Start* method from the Workflow API.**

**The following additional actions must be taken to upgrade to Workflow Server 2.6:**

- Run the SQL script *update_wfs_2_6* for all relative databases and MongoDB.
  - [MSSQL]()
  - [PostgreSQL]()
  - [Oracle]()
  - [MySQL]()
  - [MongoDB]()

## 2.5 {#2.5}

- Updated to [Workflow Engine .NET 4.1](https://workflowengine.io/documentation/release-notes/workflow-engine/#4.1)
- Support for multi-tenant applications.
  - *TenantId* has been added to processes. When creating a process using the *createinstance WorkflowAPI* method, one can specify *TenantId* and use its value to work with the process. Also, when manipulating a process using WorkflowAPI methods, one can optionally assign *TenantId*; once *TenantId* is specified, its compliance with the initial *TenantId* value set at the process creation is automatically checked.
  - For schemes one can specify tags, and then, search for schemes where these tags are indicated. Tags can be set on the *Workflow/Manage Schemes* admin page. In the *getschemelist WorkflowAPI* method, one can specify a list of tags to search for schemes. The search is performed using an OR expression.
- The possibility to set a login and a password to access the WorkflowServer admin panel has been provided. This setting is available on the *Dashboard* page in the *Security* tab.
- The possibility to set an access token to access the *WorkflowAPI* methods has been provided. This setting is available on the *Dashboard* page in the *Security* tab.
- The Basic Plugin has been connected to the WorkflowServer, it can be enabled on the *Dashboard* page in the *Plugins* tab. For a full list of methods, please, see [here](https://workflowengine.io/documentation/release-notes/workflow-engine/#4.1).
- Using the *createinstance, executecommand and get state of WorkflowAPI* methods, one can pass implicit (that is, not explicitly described in the process scheme) persistent parameters. A parameter can also be a valid JSON object of any complexity. In this case, the type `DynamicParameter` should be applied to control such a parameter in the code.
- The *getparameter* and *setparameter* methods to read and modify process parameters have been added to *WorkflowAPI*.
- Intellisense has been added to the Code Actions editor, in schemes and in the *Workflow / Global Code Actions* section of the admin panel.
- In the *API / Workflow API* section, forms to execute *WorkflowAPI* methods have been added; an example request is also generated there.

**The following additional actions must be taken to upgrade to Workflow Server 2.5:**

- Run the SQL script update_2_7_to_2_8.sql for all relative databases.
  - [MSSQL](https://github.com/optimajet/WorkflowEngine.NET/blob/master/Providers/NETCore_OptimaJet.Workflow.MSSQL/Scripts/update_4_0_to_4_1.sql)
  - [PostgreSQL](https://github.com/optimajet/WorkflowEngine.NET/blob/master/Providers/NETCore_OptimaJet.Workflow.PostgreSQL/Scripts/update_4_0_to_4_1.sql)
  - [Oracle](https://github.com/optimajet/WorkflowEngine.NET/blob/master/Providers/NETCore_OptimaJet.Workflow.Oracle/Scripts/update_4_0_to_4_1.sql)
  - [MySQL](https://github.com/optimajet/WorkflowEngine.NET/blob/master/Providers/NETCore_OptimaJet.Workflow.MySQL/Scripts/update_4_0_to_4_1.sql)
- **IMPORTANT! Incorrect behavior was fixed when the subprocess was merged in the parent process via the set state of the parent process mechanism. Previously, the parent process parameters were OVERWRITTEN. Now, the parent process parameters won't be changed. Only new parameters from the subprocess will be written to the parent process automatically. The same way the merge via calculating conditions always works. If you consciously exploited this behavior, then the best way to get parameters from the subprocess is to use a property `processInstance.MergedSubprocessParameters` when merge occurs.**
- In the previous versions, implicit parameters passed by the WorkflowAPI methods were always interpreted as strings. Starting from version 2.5, the WorkflowServer converts these parameters to types (int, bool, double, DynamicParameter etc). If it’s important for you to keep the old behavior, add the following setting to the *config.json* file.

  ```javascript
  {
    "ImplicitParametersParsingType": "Legacy"
  }
  ```

- In the previous versions, process parameters were transferred to *Callback server* in the camel case. That is, the first letter of the parameter name (for example, 'Parameter1') became small ('parameter1'). Now, the parameter name will not change. If it’s important for you to keep the old behavior, add the following setting to the *config.json* file.

  ```javascript
  {
    "CallbackServerJsonSerialization": "CamelCase"
  }
  ```

## 2.4

- Updated to Workflow Engine .NET 4.0

**The following additional actions must be taken to upgrade to Workflow Server 2.4:**

- Run the SQL  script `update_WFE_4_0.sql` for all relative databases.

## 2.3

- Added localization for German, French, Spanish, Italian, Portuguese, Turkish, and Russian languages.
- `SchemaName` setting has been added to specify the database schema to which the server is connected. 
- The `GetSchemeList` method has been added to the server API, this method returns a list of schemes that exist on the server.
- The logging system has been added. Errors, debug information and informational messages are logged. Logging targets can be console, debug output or files. For windows service, logging can also be done in the Windows Event Log.
-  The `LogInfo`,` LogError`, `LogMessage` methods have been added to the server API - methods for writing to the log from outside the server.
- The following new features are available in the `WorkflowRuntime` object, which is always available in standard WFE actions. `runtime.Logger` - returns logger, for recording messages to the log. `runtime.LogError ()`, `runtime.LogDebug ()`, `runtime.LogInfo ()` are methods for writing messages to the log.
- The docker container was published , containing the Workflow Server with the ability to transfer all the configuration settings to it.

## 2.2

- The MongoDB support has been added, this type of connection also works with the Cosmos DB.

---

## 2.1

- Added Oracle and MySQL support
- The `ExecuteCommand` method from WorkflowAPI returns information on whether the command was executed and process state after execution (including all process parameters)
- The source code of a console application which you can connect your `IWorkflowActionProvider` and `IWorkflowRuleProvider` to and perform fine-tuning of Workflow Engine was uploaded to (GitHub)[https://github.com/optimajet/workflowserver]

---

## 2.0

- First release of Workflow Server 2.0