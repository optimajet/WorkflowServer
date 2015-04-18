using AsyncHttp.Server;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OptimaJet
{
    public class ServerHelper
    {
        public static IDisposable SubscribeProcessing(HttpServer server, WorkflowServer workflowserver)
        {
            return server.Subscribe(ctx =>
            {
                var path = ctx.Request.LocalPath.ToLower();

                Response response = null;
                if (path == "/workflowapi")
                {
                    if (!string.IsNullOrWhiteSpace(workflowserver.Parameters.ApiKey) &&
                    ctx.Request.HttpParams.QueryString["apikey"] != workflowserver.Parameters.ApiKey)
                    {
                        ctx.Respond(new StringResponse("APIKEY is not valid!"));
                        return;
                    }

                    if (workflowserver.Parameters.Log != null)
                        workflowserver.Parameters.Log(string.Format("Workflow API {0} ({2}): {1}",
                        ctx.Request.HttpMethod, ctx.Request.RawUrl, ctx.Request.ClientAddress));
                    response = workflowserver.WorkflowApiProcessing(ref ctx);
                }
                else if (path == "/designerapi")
                {
                   if (workflowserver.Parameters.Log != null)
                        workflowserver.Parameters.Log(string.Format("Designer API {0} ({2}): {1}",
                        ctx.Request.HttpMethod, ctx.Request.RawUrl, ctx.Request.ClientAddress));
                    response = workflowserver.DesignerApiProcessing(ref ctx);
                }
                else
                {
                    if (workflowserver.Parameters.Log != null)
                        workflowserver.Parameters.Log(string.Format("Get file ({1}): {0}", ctx.Request.RawUrl, ctx.Request.ClientAddress));
                    response = BackEndProcessing(ref ctx, workflowserver.Parameters);
                }

                ctx.Respond(response);
            });
        }

        public static Response BackEndProcessing(ref RequestContext ctx, WorkflowServerParameter parameter)
        {
            var localPath = ctx.Request.LocalPath;
            if (localPath.IndexOf("..") >= 0)
            {
                return new EmptyResponse(404);
            }

            if (localPath.EndsWith("/"))
            {
                localPath += "index.html";
            }

            string filepath = parameter.BackendFolder + localPath;

            if (!File.Exists(filepath))
            {
                return new EmptyResponse(404);
            }

            return new FileResponse(filepath);
        }
    }
}
