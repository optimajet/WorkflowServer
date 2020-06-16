/*
 * Workflow Server
 * https://workflowengine.io/server/
 */
 
Workfow Server is a ready-to-use Workflow Engine-based application that you can deploy into your infrastructure. It can be integrated with NodeJS, PHP, Ruby, .NET, or Java applications via an HTTP API. Workflow Server is a key component for managing the lifecycle of business objects within your enterprise.

How to launch via docker
-----------------
1. Run the startcontainer script
    For Windows:
        startcontainer.bat

    For Linux/MacOS:
	chmod +x docker-files/wait-for-postgres.sh
        chmod +x startcontainer.sh
        ./startcontainer.sh

This script build this workflowserver's solution and run it with Postgres database.

2. Open http://localhost:8077 in a browser.
3. Upload your license key via the Dashboard or save the licence key as 'license.key' into the folder or add to 'license' folder.
4. Fill in Callback API urls at http://localhost:8077/?apanel=callbackapi to perform integration.

If you would like to run WorkflowServer on MSSQL or MongoDB. 
You need to use one of docker-compose files:
- MS SQL Server: docker-files/docker-compose-mssql.yml
- MongoDB: docker-files/docker-compose-mongo.yml

MongoDB script:
	chmod +x docker-files/wait-for-mongo.sh (for Linux/MacOS only!!!)
	docker-compose -f docker-files/docker-compose-mongo.yml build
	docker-compose -f docker-files/docker-compose-mongo.yml run --rm start_db
	docker-compose -f docker-files/docker-compose-mongo.yml up

MSSQL script:
	chmod +x docker-files/wait-for-mssql.sh (for Linux/MacOS only!!!)
	docker-compose -f docker-files/docker-compose-mssql.yml build
	docker-compose -f docker-files/docker-compose-mssql.yml run --rm start_db
	docker-compose -f docker-files/docker-compose-mssql.yml up

How to launch it with a custom database
-----------------
1. Run the following SQL-scripts on a Database (for MS SQL Server from SQL\MSSQL folder, for PostgreSQL from SQL\PostgreSQL, for Oracle from SQL\Oracle folder,for MySql from SQL\MySql folder):
	1.1. CreatePersistenceObjects.sql
	1.2. WorkflowServerScripts.sql
2. Make the following changes to the config.json file:
	2.1. Change the URL parameter to the IP and the port of the HTTP listener. Most likely you'll need to leave it as is.
	2.2. Specify "mssql", "postgresql", "oracle", "mysql" or "mongodb" in the "provider" parameter depending on what database provider you are using.
	2.3. Change the ConnectionString parameter to match your database provider connection settings.	
3. Install .NET Core 2.1
4.1. Workflow Server supports console and service modes on Windows:
	4.1.1. Run the 'start.bat' file to run it in the Console mode
	4.1.2. Run the 'installservice.bat' as administrator to run it in the Service mode
4.2. For Linux/MacOS: 
	4.2.1. Open the terminal in a folder where you extracted the 'workflowserver.zip' archive to
	4.2.2. Run the following command: chmod +x start.sh
	4.2.3. Run the following command: './start.sh'
5. Open http://localhost:8077 in a browser.
6. Upload your license key via the Dashboard or save the licence key as 'license.key' into the folder or add to 'license' folder.
7. Fill in Callback API urls at http://localhost:8077/?apanel=callbackapi to perform integration.

How to rebuild and run
-----------------
For Windows:
    Run buildandstart.bat

For Linux/MacOS:
    chmod +x buildandstart.sh
    chmod +x start.sh
    ./buildandstart.sh

How to run in Visual Studio
-----------------
1. Open WorkflowServer.sln in Visual Studio or JetBrains Rider
2. Check the connection string to the database in the config.json file, Provider and ConnectionString parameter
3. Run WorkflowServer project

If you need any assistance, please email us at sales@optimajet.com.

Official web site: https://workflowengine.io/server/
Documentation: https://dwkit.com/documentation/
Demo: http://server.workflowengine.io/
Email: sales@optimajet.com