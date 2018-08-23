using System;
using System.IO;
using System.Net;
using Microsoft.AspNetCore.Hosting;
using Newtonsoft.Json;
using OptimaJet.Workflow.Core.Runtime;
using OptimaJet.WorkflowServer;

namespace WorkflowServer
{
    class Program
    {
        static string configFileName = "config.json";
        static string licenseFileName = "license.key";
        static void Main(string[] args)
        {
            Console.WriteLine("WorkflowServer by OptimaJet 2018");

            if (!File.Exists(configFileName))
            {
                string tmp = Path.Combine("..", configFileName);
                if (!File.Exists(tmp))
                {
                    Console.WriteLine("Not found {0} and {1} file!", configFileName, tmp);
                    return;
                }
                else
                {
                    configFileName = tmp;
                    licenseFileName = Path.Combine("..", licenseFileName);
                }
            }

            ConfigApi.LicenseFileName = licenseFileName;
            RegisterWorkflowEngine();
            
            var config = File.ReadAllText(configFileName);
            var wsparams = JsonConvert.DeserializeObject<ServerSettings>(config);
            if(wsparams.Log)
                wsparams.Logger = Log;
            Console.WriteLine("WorkflowEngine: Init...");
            var workflowserver = new WorkflowServerRuntime(wsparams);
            
            //Register your own Action and Rule providers
            //workflowserver.RegisterActionProvider(new ActionProvider());
            //workflowserver.RegisterRuleProvider(new RuleProvider());

            if (!wsparams.NoStartWorkflow)
            {
                Console.WriteLine("WorkflowEngine: Starting...");
                try
                {
                    workflowserver.Start();
                    Console.WriteLine("WorkflowEngine: Started.");
                }
                catch(Exception ex)
                {
                    Console.WriteLine("WorkflowEngine: {0}", ex.Message);
                }
            }

            Console.WriteLine("WorkflowStarting: Starting...");

            UrlInfo info;
            try
            {
                info = wsparams.GetUrlInfo();
            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                return;
            }

            IWebHostBuilder hostBuilder;
            if (!info.IsHttps)
            {
                hostBuilder = new WebHostBuilder().UseKestrel().UseContentRoot(Directory.GetCurrentDirectory())
                    .UseUrls(wsparams.Url).SubscribeProcessing(workflowserver);
            }
            else
            {
                if (string.IsNullOrEmpty(wsparams.CertificateFile))
                {
                    Console.WriteLine(@"Please specify certificate file name and path relative to the directory that contains the application 
in CertificateFile setting in configuration file");
                    return;
                }
                if (string.IsNullOrEmpty(wsparams.CertificatePassword))
                {
                    Console.WriteLine("Please specify certificate password in CertificatePassword setting in configuration file");
                    return;
                }

                hostBuilder = new WebHostBuilder().UseKestrel(
                        options =>
                        {
                            if (info.ForAllIPs)
                            {
                                options.Listen(IPAddress.Any, info.Port, listenOptions => { listenOptions.UseHttps(wsparams.CertificateFile, wsparams.CertificatePassword); });
                            }
                            else if (info.IsLocalhost)
                            {
                                options.Listen(IPAddress.Loopback, info.Port, listenOptions => { listenOptions.UseHttps(wsparams.CertificateFile, wsparams.CertificatePassword); });
                            }
                            else
                            {
                                options.Listen(info.Address, info.Port, listenOptions => { listenOptions.UseHttps(wsparams.CertificateFile, wsparams.CertificatePassword); });
                            }
                           
                        })
                    .UseContentRoot(Directory.GetCurrentDirectory())
                    .SubscribeProcessing(workflowserver);

            }

            using (var host = hostBuilder.Build())
            {
                host.Start();
                Console.WriteLine("WorkflowStarting: Started.");
                Console.WriteLine("Waiting for a connection on {0}...", wsparams.Url);

                while (true)
                {
                    Console.WriteLine("For exit please enter 'Q'.");
                    var command = Console.ReadLine();
                    if (command != null && command.ToUpper() == "Q")
                        break;
                }

            }
        }


        public static void Log(string msg, bool error = false)
        {
            Console.WriteLine(msg);
        }

        private static void RegisterWorkflowEngine()
        {
            if (File.Exists(licenseFileName))
            {
                try
                {
                    Console.WriteLine("WorkflowServer: Registering a license...");
                    var licenseText = File.ReadAllText(licenseFileName);
                    WorkflowServerRuntime.RegisterLicenseKey(licenseText);
                    Console.WriteLine("WorkflowServer: The license is registered.");
                }
                catch
                {
                    Console.WriteLine("WorkflowServer: The license is wrong.");
                }
            }
        }
    }
}
