using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace AsyncHttp.Server
{
    public class Request
    {
        public string HttpMethod { get; set; }
        public IDictionary<string, IEnumerable<string>> Headers { get; set; }
        public Stream InputStream { get; set; }
        public string RawUrl { get; set; }
        public int ContentLength
        {
            get { return int.Parse(Headers["Content-Length"].First()); }
        }

        public string LocalPath { get; set; }
        public HttpNameValueCollection HttpParams { get; set; }

        public string ClientAddress { get; set; }
    }
}