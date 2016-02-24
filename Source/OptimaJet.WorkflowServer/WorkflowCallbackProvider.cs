using OptimaJet.Workflow.Core.Generator;
using OptimaJet.Workflow.Core.Model;
using OptimaJet.Workflow.Core.Runtime;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.IO;
using System.Net;
using System.Text;
using System.Web;
using System.Xml.Linq;
using Newtonsoft.Json;

namespace OptimaJet
{
    public class WorkflowCallbackProvider : IWorkflowRuleProvider, IWorkflowActionProvider, IWorkflowGenerator<XElement>
    {
        WorkflowServerParameter _parameters;
        IWorkflowGenerator<XElement> _parentgenerator;
        public WorkflowCallbackProvider(WorkflowServerParameter parameters, IWorkflowGenerator<XElement> generator)
        {
            _parameters = parameters;
            _parentgenerator = generator;
        }

        #region IWorkflowRuleProvider
        public bool Check(ProcessInstance processInstance, WorkflowRuntime runtime, string identityId, string ruleName, string parameter)
        {
            var res = SendRequest("check", ruleName, processInstance, identityId, parameter);
            return JsonConvert.DeserializeObject<bool>(res);
        }

        public IEnumerable<string> GetIdentities(ProcessInstance processInstance, WorkflowRuntime runtime, string ruleName, string parameter)
        {
            var res = SendRequest("getidentities", ruleName, processInstance, null, parameter);
            return JsonConvert.DeserializeObject<List<string>>(res);
        }

        public List<string> GetRules()
        {
            var res = SendRequest("getrules");
            return JsonConvert.DeserializeObject<List<string>>(res);
        }
        #endregion

        #region IWorkflowActionProvider
        public void ExecuteAction(string name, ProcessInstance processInstance, WorkflowRuntime runtime, string actionParameter)
        {
            SendRequest("executeaction", name, processInstance, null, actionParameter);
        }

        public bool ExecuteCondition(string name, ProcessInstance processInstance, WorkflowRuntime runtime, string actionParameter)
        {
            var res = SendRequest("executecondition", name, processInstance, null, actionParameter);
            return JsonConvert.DeserializeObject<bool>(res);
        }

        public List<string> GetActions()
        {
            var res = SendRequest("getactions");
            return JsonConvert.DeserializeObject<List<string>>(res);
        }
        #endregion

        #region IWorkflowGenerator
        public XElement Generate(string schemeCode, Guid schemeId, IDictionary<string, object> parameters)
        {
            var xe = _parentgenerator.Generate(schemeCode, schemeId, parameters);
            if (!_parameters.CallbackGenScheme || string.IsNullOrWhiteSpace(_parameters.CallbackApiUrl))
                return xe;

            NameValueCollection pars = new NameValueCollection(){
                {"type", "generate"},
                {"parameters", JsonConvert.SerializeObject(parameters)},
                {"schemecode", schemeCode},
                {"schemeid", schemeId.ToString("N")},
                {"scheme", xe.ToString()},
            };

            var res = Send(pars);
            return XElement.Parse(res);
        }
        #endregion

        #region Send
        private string SendRequest(string type, string name = null, ProcessInstance processInstance = null, string identityId = null, string parameter = null)
        {
            if (string.IsNullOrWhiteSpace(_parameters.CallbackApiUrl))
                return "null";

            NameValueCollection parameters = new NameValueCollection(){
                {"type", type},
                {"pi", processInstance != null ? JsonConvert.SerializeObject(processInstance) : null},
                {"identityid", identityId},
                {"name", name},
                {"parameter", parameter},
            };

            return Send(parameters);
        }

        public string Send(NameValueCollection parameters)
        {
            if (string.IsNullOrWhiteSpace(_parameters.CallbackApiUrl))
                return null;

            var targerUrl = string.Format("{0}{1}apikey={2}", _parameters.CallbackApiUrl, _parameters.CallbackApiUrl.IndexOf("?") < 0 ? "?" : "&", _parameters.ApiKey);

            StringBuilder sb = new StringBuilder();
            foreach (string key in parameters.AllKeys)
            {
                if (sb.Length > 0)
                    sb.Append("&");
                sb.AppendFormat("{0}={1}", key, HttpUtility.UrlEncode(parameters[key]));
            }

            if (_parameters.Log != null)
            {
                _parameters.Log(string.Format("WorkflowProviderWebApi Send request {0}", targerUrl));
            }
            
            var request = (HttpWebRequest)WebRequest.Create(targerUrl);
            request.Method = "POST";
            request.ContentType = "application/x-www-form-urlencoded";
            using (var stream = request.GetRequestStream())
            {
                byte[] buffer = Encoding.Default.GetBytes(sb.ToString());
                stream.Write(buffer, 0, buffer.Length);
            }

            var response = (HttpWebResponse)request.GetResponse();
            var responseString = new StreamReader(response.GetResponseStream()).ReadToEnd();
            return HttpUtility.UrlDecode(responseString);
        }
        #endregion
    }
}
