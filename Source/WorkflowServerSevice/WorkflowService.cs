using AsyncHttp.Server;
using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Configuration;
using System.Diagnostics;
using System.Linq;
using System.ServiceProcess;
using System.Text;
using OptimaJet;

namespace WorkflowServerSevice
{
    public partial class WorkflowService : ServiceBase
    {
        HttpServer _server;
        IDisposable _listeners;
        OptimaJet.WorkflowServer _workflowserver;
        ConcurrentDictionary<LogEntryType,byte> _logEntryTypes = new ConcurrentDictionary<LogEntryType,byte>();
        public WorkflowService()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            WorkflowServerParameter wsparams = GetParams();
            RegisterWorkflowEngine();

            Log("WorkflowEngine.NET: Init...");
            _workflowserver = new OptimaJet.WorkflowServer(wsparams);

            if (!wsparams.NoStartWorkflow)
            {
                Log("WorkflowEngine.NET: Starting...");
                _workflowserver.Start();
            }

            Log("HttpServer: Starting...");
            _server = new HttpServer(wsparams.Url);
            Log($"Waiting for a connection on {wsparams.Url}...");

            _listeners = ServerHelper.SubscribeProcessing(_server, _workflowserver);
        }

        protected override void OnStop()
        {
            _listeners.Dispose();
            _server.Dispose();
        }

        private WorkflowServerParameter GetParams()
        {
            var p = new WorkflowServerParameter
            {
                Url = ConfigurationManager.AppSettings["url"],
                CallbackApiUrl = ConfigurationManager.AppSettings["callbackurl"],
                CallbackGenScheme = bool.Parse(ConfigurationManager.AppSettings["callbackgenscheme"]),
                ApiKey = ConfigurationManager.AppSettings["apikey"],
                Provider = ConfigurationManager.AppSettings["dbprovider"],
                ConnectionString = ConfigurationManager.AppSettings["dbcs"],
                DBUrl = ConfigurationManager.AppSettings["dburl"],
                Database = ConfigurationManager.AppSettings["dbdatabase"],
                NoStartWorkflow = bool.Parse(ConfigurationManager.AppSettings["nostartworkflow"])
            };

            if(bool.Parse(ConfigurationManager.AppSettings["log"]))
                p.Log = Log;
            var logEntryTypesString = ConfigurationManager.AppSettings["logentrytypes"];
            if (!string.IsNullOrEmpty(logEntryTypesString))
            {
                logEntryTypesString.Split(',').ToList().ForEach(v =>
                {
                    var parsed = (LogEntryType) Enum.Parse(typeof(LogEntryType), v, true);
                    _logEntryTypes.AddOrUpdate(parsed, 0, (type, b) => b);
                });
            }
            else
            {
                _logEntryTypes.AddOrUpdate(LogEntryType.Error, 0, (type, b) => b);
            }


            p.BackendFolder = ConfigurationManager.AppSettings["befolder"];
            return p;
        }

        public void Log(string message, LogEntryType type = LogEntryType.Information)
        {
            if (!_logEntryTypes.ContainsKey(type))
            {
                return;
            }
            try
            {
                if (!EventLog.SourceExists("OptimaJet.WorkflowServer"))
                {
                    EventLog.CreateEventSource("OptimaJet.WorkflowServer", "OptimaJet.WorkflowServer");
                }
                eventLog1.Source = "OptimaJet.WorkflowServer";
                if (type == LogEntryType.Information)
                    eventLog1.WriteEntry(message,EventLogEntryType.Information);
                else
                {
                    eventLog1.WriteEntry(message, EventLogEntryType.Error);
                }
            }
            catch
            {
                // ignored
            }
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
