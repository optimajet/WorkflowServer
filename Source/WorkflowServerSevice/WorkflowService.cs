using AsyncHttp.Server;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Configuration;
using System.Data;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using System.Threading.Tasks;

namespace WorkflowServerSevice
{
    public partial class WorkflowService : ServiceBase
    {
        HttpServer server;
        IDisposable listeners;
        OptimaJet.WorkflowServer workflowserver;
        public WorkflowService()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            OptimaJet.WorkflowServerParameter wsparams = GetParams();
            RegisterWorkflowEngine();

            Log("WorkflowServer by OptimaJet 2015");
            Log("WorkflowEngine.NET: Init...");
            workflowserver = new OptimaJet.WorkflowServer(wsparams);

            if (!wsparams.NoStartWorkflow)
            {
                Log("WorkflowEngine.NET: Starting...");
                workflowserver.Start();
            }

            Log("HttpServer: Starting...");
            server = new HttpServer(wsparams.Url);
            Log(string.Format("Waiting for a connection on {0}...", wsparams.Url));

            listeners = OptimaJet.ServerHelper.SubscribeProcessing(server, workflowserver);
        }

        protected override void OnStop()
        {
            listeners.Dispose();
            server.Dispose();
        }

        private OptimaJet.WorkflowServerParameter GetParams()
        {
            var p = new OptimaJet.WorkflowServerParameter();

            p.Url = ConfigurationManager.AppSettings["url"];
            p.CallbackApiUrl = ConfigurationManager.AppSettings["callbackurl"];
            p.CallbackGenScheme = bool.Parse(ConfigurationManager.AppSettings["callbackgenscheme"]);
            p.ApiKey = ConfigurationManager.AppSettings["apikey"];
            p.Provider = ConfigurationManager.AppSettings["dbprovider"];
            p.ConnectionString = ConfigurationManager.AppSettings["dbcs"];
            p.DBUrl = ConfigurationManager.AppSettings["dburl"];
            p.Database = ConfigurationManager.AppSettings["dbdatabase"];
            p.NoStartWorkflow = bool.Parse(ConfigurationManager.AppSettings["nostartworkflow"]);
            if(bool.Parse(ConfigurationManager.AppSettings["log"]))
                p.Log = Log;

            p.BackendFolder = ConfigurationManager.AppSettings["befolder"];
            return p;
        }

        public void Log(string message)
        {
            try
            {
                if (!EventLog.SourceExists("OptimaJet.WorkflowServer"))
                {
                    EventLog.CreateEventSource("OptimaJet.WorkflowServer", "OptimaJet.WorkflowServer");
                }
                eventLog1.Source = "OptimaJet.WorkflowServer";
                eventLog1.WriteEntry(message);
            }
            catch { }
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
    }
}
