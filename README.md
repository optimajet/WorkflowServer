# Workflow Server

* **Official web site** - [https://workflowengine.io/server/](https://workflowengine.io/server/)
* **Documentation** - [https://workflowengine.io/documentation/workflow-server/](https://workflowengine.io/documentation/workflow-server/)
* **Demo** - [https://server.workflowengine.io/](https://server.workflowengine.io/)

## Overview

Workflow Server is a ready-to-use Workflow Engine-based application that you can deploy into your infrastructure. It can be integrated with NodeJS, PHP, Ruby, .NET, or Java applications via a REST API. Workflow Server is a key component for managing the lifecycle of business objects within your enterprise.

## Features

### Rest API

Manage schemes and processes with GET and POST requests to Workflow Server.

### Web UI

Enjoy a responsive web-based interface, enabling you to make change on the fly.

### Business Flow

Get form names depending on user role or type for each workflow instance.

### Reports

Visualize process states, & key information on schemes, processes and performance.

## OS Support

| OS      | Version                                                                                                                                                               | Architectures |
|---------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------|
| Windows | 7 SP1+, 8.1 or newer; 2008 R2 SP1 or newer                                                                                                                            | x64, x86      |
| Linux   | Red Hat Enterprise Linux/CentOS/Oracle Linux 7; Fedora 26, 27; Debian 8.7, 9; Ubuntu/Linux Mint 17.10, 16.04, 14.04, 18, 17; openSUSE 42.2+; SUSE Enterprise Linux 12 | x64           |
| macOS   | 10.12+ or newer                                                                                                                                                       | x64           |

## System Requirements

Workflow Server runs on .NET Core and supports MS SQL Server and PostgreSQL. The minimum system requirements are:

* CPU 1 core 1 Ghz 
* RAM 1 Gb 
* HDD/SSD 5 Gb

## API

The set of APIs enables the exchange of messages between external applications and Workflow Server via the HTTP protocol.

### Workflow API

Workflow API enables you to manage everything related to your schemes and workflows, be it the creation of a process instance, returning the list of available commands and executing them, getting the list of available states and setting them, inbox/outbox folders, etc.

* Creating instances & retrieving their info
* Getting a list of commands & executing them
* Getting a list of available states & setting them
* Checking if a process exists
* Accessing Inbox/Outbox folders
* Recalculating Inbox folder
 
### Callback API

Callback API allows you to integrate Workflow Server into any infrastructure (for example, the one based on microservice architecture) by specifying external URLs that you wish Workflow Server to call whenever a specific event occurs.

* Getting a list of actions & executing them
* Getting a list of conditions & executing them
* Getting rules & checking them
* Getting identities
* Generating schemes
* Receiving status change notifications

## Application Modes

Workflow Server is capable of being run either as a console application or as a Windows Service (for Windows-host only). You can choose the most suitable deployment option.

* Console application 
* Windows Service
