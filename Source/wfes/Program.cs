using System;
using System.Collections.Generic;
using System.Linq;
using System.Reactive.Linq;
using System.Reactive.Subjects;
using System.Text;
using AsyncHttp.Server;
using System.IO;
using System.Configuration;

namespace wfes
{
    class Program
    {
        static string _backendFolder = "../backend";
        static void Main(string[] args)
        {
            RegisterWorkflowEngine();

            //for tests (MS SQL)
            //args = new string[]{
            //    "-url=http://*:8077/",
            //    "-callbackurl=http://localhost:8078/",
            //    //"-callbackgenscheme",
            //    "-dbprovider=mssql",
            //    "-log",
            //    "-dbcs=Data Source=(local);Initial Catalog=WorkflowApp;Integrated Security=False;User ID=sa;Password=1;",
            //    "-befolder=../../../backend"
            //};

            var wsparams = ParseWorkflowServerParameter(args); 
            if (wsparams == null)
            {
                ShowAllParameters();
                return;
            }

            Console.WriteLine("WorkflowServer by OptimaJet 2015");
            Console.WriteLine("WorkflowEngine.NET: Init...");
            var workflowserver = new OptimaJet.WorkflowServer(wsparams);

            if (!wsparams.NoStartWorkflow)
            {
                Console.WriteLine("WorkflowEngine.NET: Starting...");
                workflowserver.Start();
            }

            Console.WriteLine("WorkflowServer: Starting...");
            var subject = new Subject<string>();

            using (var server = new HttpServer(wsparams.Url))
            {
                Console.WriteLine(string.Format("Waiting for a connection on {0}...", wsparams.Url));
                var listeners = OptimaJet.ServerHelper.SubscribeProcessing(server, workflowserver);
                    
                while (true)
                {
                    Console.WriteLine("For exit please enter '^Q'.");
                    var command = Console.ReadLine();
                    if (command.ToUpper() == "^Q")
                        break;
                }
                
                listeners.Dispose();
            }
        }


        public static void Log(string msg)
        {
            Console.WriteLine(msg);
        }

        private static void RegisterWorkflowEngine()
        {
            if (ConfigurationManager.AppSettings.AllKeys.Contains("WorkflowEngineKey"))
            {
                var licensekey = ConfigurationManager.AppSettings["WorkflowEngineKey"];
                if (!string.IsNullOrWhiteSpace(licensekey))
                    OptimaJet.WorkflowServer.RegisterLicenseKey(licensekey);
            }
        }

        public static void ShowAllParameters()
        {
            Console.WriteLine("WorkflowServer powered by WorkflowEngine.NET");
            Console.WriteLine("http://workflowenginenet.com/server");
            Console.WriteLine();
            Console.WriteLine("Usage is: wfes [options]");
            Console.WriteLine();
            Console.WriteLine("\t-url=<options>\t\tUrl for bind HTTP listener (Default: 'http://*:8077/')");
            Console.WriteLine("\t-callbackurl=<options>\tURL for Callback API");
            Console.WriteLine("\t-callbackgenscheme\tEnable request for post-generation of scheme");
            Console.WriteLine("\t-apikey=<options>\tKey for access");
            Console.WriteLine();
            Console.WriteLine("Database:");
            Console.WriteLine("\t-dbprovider=<options>\tDB Provider: mssql=MS SQL Server, oracle=Oracle, mysql=MySQL, postgresql=PostgreSQL, ravendb=RavenDB, mongodb=MongoDB");
            Console.WriteLine("\t-dbcs=<options>\t\tConnectionString for DB (Available for MS SQL, Oracle, PostgreSQL, MySQL_");
            Console.WriteLine("\t-dburl=<options>\tUrl for DB (Available for RavenDB, MongoDB");
            Console.WriteLine("\t-dbdatabase=<options>\tDatabase name (Available for RavenDB, MongoDB");
            Console.WriteLine();
            Console.WriteLine("Other:");
            Console.WriteLine("\t-nostartworkflow\t");
            Console.WriteLine("\t-log\t\t\tShow logs to the console");
            Console.WriteLine("\t-befolder=<options>\tFolder with backend files (Default: '../backend')");
        }

        private static OptimaJet.WorkflowServerParameter ParseWorkflowServerParameter(string[] args)
        {
            if (args.Length == 0)
                return null;

            var p = new OptimaJet.WorkflowServerParameter() {
                BackendFolder = _backendFolder
            };

            foreach(var arg in args)
            {
                var str = arg.Trim();

                var key = string.Empty;
                var value = string.Empty;
                int index = str.IndexOf('=');
                if (index < 0)
                    index = str.Length;

                key = str.Substring(1, index - 1);
                if (str.Length > index + 1)
                    value = str.Substring(index + 1, str.Length - (index+1));

                switch(key)
                {
                    case "url": p.Url = value; break;
                    case "callbackurl": p.CallbackApiUrl = value; break;
                    case "callbackgenscheme": p.CallbackGenScheme = true; break;
                    case "apikey": p.ApiKey = value; break;
                    case "dbprovider": p.Provider = value; break;
                    case "dbcs": p.ConnectionString = value; break;
                    case "dburl": p.DBUrl = value; break;
                    case "dbdatabase": p.Database = value; break;
                    case "nostartworkflow": p.NoStartWorkflow = true; break;
                    case "log": p.Log = Log; break;
                    case "befolder": p.BackendFolder = value; break;
                    default:
                        Console.WriteLine(string.Format("Unknown '{0}' parameter.", key));
                        return null;
                }
            }

            return p;
        }
    }
}
