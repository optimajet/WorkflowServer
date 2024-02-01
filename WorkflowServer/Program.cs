using System;
using Microsoft.AspNetCore.Hosting;
using OptimaJet.Workflow.Core.Runtime;
using OptimaJet.WorkflowServer;
using OptimaJet.WorkflowServer.Initializing;

namespace WorkflowServer
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var initializer = new WorkflowServerInitializer(consoleLog: true, eventLog: false, moveUpBackendFolderIfConfig: false);

            (bool success, IWebHost host) = initializer.BuildWebHost(workflowServer =>
            {
                //Register your own Action and Rule providers
                //workflowServer.RegisterActionProvider(new ActionProvider());
                //workflowServer.RegisterRuleProvider(new RuleProvider());
                
                //Register your own CodeAutocompleter
                //workflowServer.RegisterCodeAutocompleters(new CodeProvider());

                //register additional assemblies
                WorkflowRuntime.CodeActionsRegisterAssembly(typeof(System.Net.Http.HttpClient).Assembly);
            });

            if (!success)
            {
                //it is failure
                Console.ReadKey();
                return;
            }

            using (host)
            {
                host.RunAsync().Wait();

                WorkflowServerRuntime wf = initializer.WorkflowServer;

                wf.FormManager.Stop();
                wf.WorkflowRuntime.Logger.Info("Shutting down...");
                wf.WorkflowRuntime.Shutdown();
                wf.WorkflowRuntime.Logger.Dispose();
            }
        }
    }
}
