using AsyncHttp.Server;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Reactive.Linq;
using System.Reactive.Subjects;
using System.Web;

namespace TestCallbackAPIService
{
    class Program
    {
        static void Main(string[] args)
        {  
            string defaulturl = "http://*:8078/";
            string url = string.Empty;
            if (args.Length == 0)
            {
                Console.Write(string.Format("Enter url for HTTPLister (example '{0}'):", defaulturl));
                url = Console.ReadLine();
                if (string.IsNullOrWhiteSpace(url))
                    url = defaulturl;
            }
            else
            {
                url = args[0];
            }

            using (var server = new HttpServer(url))
            {
                Console.WriteLine(string.Format("Waiting for a connection on {0}...", url));
                var listeners = server.Subscribe(ctx =>
                    {
                        var request = ctx.Request;
                        var type = ctx.Request.HttpParams.FormParams["type"];

                        Console.WriteLine(string.Format("Request {0} form {1} {2}: {3}",
                                ctx.Request.HttpMethod, ctx.Request.ClientAddress, ctx.Request.LocalPath, type));
                        
                        string data = string.Empty;
                        switch (type)
                        {
                            case "getactions":
                                data = "[\"Action1\", \"Action2\", \"Action3\"]";
                                break;
                            case "getconditions":
                                data = "[\"Condition1\", \"Condition2\", \"Condition3\"]";
                                break;
                            case "executeaction":
                                break;
                            case "executecondition":
                                data = "true";
                                break;
                            case "getrules":
                                data = "[\"Rule1\", \"Rule2\", \"Rule3\"]";
                                break;
                            case "check":
                                data = "true";
                                break;
                            case "getidentities":
                                data = "[\"UserID1\", \"UserID2\", \"UserID3\"]";
                                break;
                            case "generate":
                                data = request.HttpParams.FormParams["scheme"];
                                break;
                            default:
                                Console.WriteLine(string.Format("Response to {0}: Unknown type", ctx.Request.ClientAddress));
                                break;

                        }

                        ctx.Respond(new StringResponse(HttpUtility.UrlEncode(data)));

                        Console.WriteLine(string.Format("Response to {0}: {1}", ctx.Request.ClientAddress, data));
                    });

                while (true)
                {
                    Console.WriteLine("For exit please enter 'Q'.");
                    var command = Console.ReadLine();
                    if (!string.IsNullOrEmpty(command) && command.ToUpper() == "Q")
                        break;
                }

                listeners.Dispose();
            }
        }
    }
}
