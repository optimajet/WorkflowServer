using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace AsyncHttp.Server
{
    public class Response
    {
        public Response()
        {
            WriteStream = s => { };
            StatusCode = 200;
            Headers = new Dictionary<string, string>{{"Content-Type", "text/html"}};
        }

        public int StatusCode { get; set; }
        public IDictionary<string, string> Headers { get; set; }
        public Action<Stream> WriteStream { get; set; }
    }

    public class StringResponse : Response
    {
        public StringResponse(string message, string contenttype = "text/html", Dictionary<string, string> additionalHeaders = null)
        {
            Headers = new Dictionary<string, string> { { "Content-Type", contenttype } };

            if (additionalHeaders != null)
            {
                foreach(var ah in additionalHeaders)
                {
                    Headers.Add(ah);
                }
            }

            var bytes = Encoding.Default.GetBytes(message);
            WriteStream = s => s.Write(bytes, 0 , bytes.Length);
        }
    }

    public class EmptyResponse : Response
    {
        public EmptyResponse(int statusCode = 204)
        {
            StatusCode = statusCode;
        }
    }

    public class FileResponse : Response
    {
        public FileResponse(string filename)
        {
            StatusCode = 200;
            Headers = new Dictionary<string, string> { 
                { "Content-Type", GetContentTypeByFileName(filename) }
            };

            WriteStream = s => {
                using (FileStream filestream = File.OpenRead(filename))
                {
                    filestream.CopyTo(s);
                }
            };
        }

        private string GetContentTypeByFileName(string filepath)
        {
            string Extension = filepath.Substring(filepath.LastIndexOf('.'));
            var ct = string.Empty;

            switch (Extension)
            {
                case ".htm":
                case ".html":
                    ct = "text/html; charset=UTF-8";
                    break;
                case ".css":
                    ct = "text/css; charset=UTF-8";
                    break;
                case ".js":
                    ct = "text/javascript; charset=UTF-8";
                    break;
                case ".jpg":
                    ct = "image/jpeg";
                    break;
                case ".jpeg":
                case ".png":
                case ".gif":
                    ct = "image/" + Extension.Substring(1);
                    break;
                default:
                    if (Extension.Length > 1)
                    {
                        ct = "application/" + Extension.Substring(1);
                    }
                    else
                    {
                        ct = "application/unknown";
                    }
                    break;
            }
            return ct;
        }
    }
}