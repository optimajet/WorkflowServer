using AsyncHttp.Server;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OptimaJet
{
    public static class ServerHelper
    {
        public static IDisposable SubscribeProcessing(HttpServer server, WorkflowServer workflowserver)
        {
            return server.Subscribe(async ctx =>
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

                    workflowserver.Parameters?.Log?.Invoke(string.Format("Workflow API {0} ({2}): {1}",
                        ctx.Request.HttpMethod, ctx.Request.RawUrl, ctx.Request.ClientAddress));
                    response = await workflowserver.WorkflowApiProcessing(ctx);
                }
                else if (path == "/designerapi")
                {
                    workflowserver.Parameters?.Log?.Invoke(string.Format("Designer API {0} ({2}): {1}",
                        ctx.Request.HttpMethod, ctx.Request.RawUrl, ctx.Request.ClientAddress));
                    response = await workflowserver.DesignerApiProcessing(ctx);
                }
                else
                {
                    workflowserver.Parameters?.Log?.Invoke(string.Format("Get file ({1}): {0}", ctx.Request.RawUrl, ctx.Request.ClientAddress));
                    response = await BackEndProcessing(ctx, workflowserver.Parameters);
                }

                ctx.Respond(response);
            });
        }

        public static Task<Response> BackEndProcessing(RequestContext ctx, WorkflowServerParameter parameter)
        {
            return Task.Run(()=>BackendProcessingSync(ctx, parameter));
        }

        private static Response BackendProcessingSync(RequestContext ctx, WorkflowServerParameter parameter)
        {
            var localPath = ctx.Request.LocalPath;
            if (localPath.IndexOf("..", StringComparison.Ordinal) >= 0)
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
