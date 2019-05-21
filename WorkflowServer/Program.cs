using System;
using System.IO;
using System.Net;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using OptimaJet.Workflow.Core.Runtime;
using OptimaJet.WorkflowServer;


namespace WorkflowServer
{
    class Program
    {
        private const string LicenseFileName = "license.key";

        static string configFileName = "config.json";
        static string licensePath = string.Empty;

        static void Main(string[] args)
        {
            Console.WriteLine("WorkflowServer by OptimaJet 2019");

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
                    licensePath = "..";
                }
            }

            var builder = new ConfigurationBuilder()
                    .SetBasePath(Directory.GetCurrentDirectory())
                    .AddJsonFile(configFileName, optional: false, reloadOnChange: true)
                    .AddEnvironmentVariables()
            ;

            var configuration = builder.Build();
            var wsparams = configuration.Get<ServerSettings>();

            ConfigApi.LicenseFileName = Path.Combine(wsparams.LicensePath ?? licensePath, LicenseFileName);
            RegisterWorkflowEngine(ConfigApi.LicenseFileName);

            wsparams.UseEventLog = false;
            Console.WriteLine("WorkflowEngine: Init...");
            var workflowserver = new WorkflowServerRuntime(wsparams);
            
            //Register your own Action and Rule providers
            //workflowserver.RegisterActionProvider(new ActionProvider());
            //workflowserver.RegisterRuleProvider(new RuleProvider());
            
            //register additional assemblies
            WorkflowRuntime.CodeActionsRegisterAssembly(typeof(System.Net.Http.HttpClient).Assembly);

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

            Console.WriteLine("WorkflowServer: Starting...");

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
                    .UseUrls(wsparams.Url).ConfigureCorsServices(workflowserver).SubscribeProcessing(workflowserver);
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
                    .ConfigureCorsServices(workflowserver)
                    .SubscribeProcessing(workflowserver);

            }

            using (var host = hostBuilder.Build())
            {
                host.RunAsync().Wait();
                workflowserver.WorkflowRuntime.Logger.Info("Shutting down...");
                workflowserver.WorkflowRuntime.Logger.Dispose();
            }
        }

        private static void RegisterWorkflowEngine(string pathToLicense)
        {
            if (File.Exists(pathToLicense))
            {
                try
                {
                    Console.WriteLine("WorkflowServer: Registering a license...");
                    var licenseText = File.ReadAllText(pathToLicense);
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
