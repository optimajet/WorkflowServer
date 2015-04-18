using System.Collections.Specialized;
using System.IO;
using System.Linq;
using System.Net;
using System.Web;

namespace AsyncHttp.Server
{
    public class RequestContext
    {
        private readonly HttpListenerResponse listenerResponse;

        public RequestContext(HttpListenerRequest request, HttpListenerResponse response)
        {
            listenerResponse = response;
            Request = MapRequest(request);
        }

        private static Request MapRequest(HttpListenerRequest request)
        {
            var mapRequest = new Request
                                 {
                                     Headers = request.Headers.ToDictionary(),
                                     HttpMethod = request.HttpMethod,
                                     InputStream = request.InputStream,
                                     RawUrl = request.RawUrl,
                                     LocalPath = request.Url.LocalPath,
                                     HttpParams = new HttpNameValueCollection(ref request),
                                     ClientAddress = request.RemoteEndPoint.Address.ToString()
                                 };
            return mapRequest;
        }

        public Request Request { get; private set; }

        public void Respond(Response response)
        {
            foreach (var header in response.Headers.Where(r => r.Key != "Content-Type"))
            {
                listenerResponse.AddHeader(header.Key, header.Value);
            }

            listenerResponse.ContentType = response.Headers["Content-Type"];
            listenerResponse.StatusCode = response.StatusCode;
            using (var output = listenerResponse.OutputStream)
            {
                response.WriteStream(output);
            }
            listenerResponse.Close();
        }
    }
}