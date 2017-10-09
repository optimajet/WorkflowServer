using OptimaJet.Workflow.Core.Generator;
using OptimaJet.Workflow.Core.Model;
using OptimaJet.Workflow.Core.Runtime;
using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.IO;
using System.Net;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
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
            var res = SendRequest("check", ruleName, processInstance, identityId, parameter).Result;
            return JsonConvert.DeserializeObject<bool>(res);
        }

        public IEnumerable<string> GetIdentities(ProcessInstance processInstance, WorkflowRuntime runtime, string ruleName, string parameter)
        {
            var res = SendRequest("getidentities", ruleName, processInstance, null, parameter).Result;
            return JsonConvert.DeserializeObject<List<string>>(res);
        }

        public List<string> GetRules()
        {
            var res = SendRequest("getrules").Result;
            return JsonConvert.DeserializeObject<List<string>>(res);
        }
        #endregion

        #region IWorkflowActionProvider
        public void ExecuteAction(string name, ProcessInstance processInstance, WorkflowRuntime runtime, string actionParameter)
        {
            ExecuteActionAsync(name, processInstance, runtime, actionParameter, CancellationToken.None).Wait();
        }

        public async Task ExecuteActionAsync(string name, ProcessInstance processInstance, WorkflowRuntime runtime, string actionParameter, CancellationToken token)
        {
            await SendRequest("executeaction", name, processInstance, null, actionParameter);
        }

        public bool ExecuteCondition(string name, ProcessInstance processInstance, WorkflowRuntime runtime, string actionParameter)
        {
            return ExecuteConditionAsync(name, processInstance, runtime, actionParameter, CancellationToken.None).Result;
        }

        public async Task<bool> ExecuteConditionAsync(string name, ProcessInstance processInstance, WorkflowRuntime runtime, string actionParameter, CancellationToken token)
        {
            var res = await SendRequest("executecondition", name, processInstance, null, actionParameter);
            return JsonConvert.DeserializeObject<bool>(res);
        }

        public bool IsActionAsync(string name)
        {
            return true;
        }

        public bool IsConditionAsync(string name)
        {
            return true;
        }

        public List<string> GetActions()
        {
            var res = SendRequest("getactions").Result;
            return JsonConvert.DeserializeObject<List<string>>(res);
        }

        public List<string> GetConditions()
        {
            var res = SendRequest("getconditions").Result;
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

            var res = Send(pars).Result;
            return XElement.Parse(res);
        }
        #endregion

        #region Send
        private async Task<string> SendRequest(string type, string name = null, ProcessInstance processInstance = null, string identityId = null, string parameter = null)
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

            return await Send(parameters);
        }

        public async Task<string> Send(NameValueCollection parameters)
        {
            if (string.IsNullOrWhiteSpace(_parameters.CallbackApiUrl))
                return null;

            var targerUrl = $"{_parameters.CallbackApiUrl}{(_parameters.CallbackApiUrl.IndexOf("?", StringComparison.Ordinal) < 0 ? "?" : "&")}apikey={_parameters.ApiKey}";

            StringBuilder sb = new StringBuilder();
            foreach (string key in parameters.AllKeys)
            {
                if (sb.Length > 0)
                    sb.Append("&");
                sb.AppendFormat("{0}={1}", key, HttpUtility.UrlEncode(parameters[key]));
            }

            _parameters.Log?.Invoke($"WorkflowProviderWebApi Send request {targerUrl}");

            var request = (HttpWebRequest)WebRequest.Create(targerUrl);
            request.Method = "POST";
            request.ContentType = "application/x-www-form-urlencoded";
            using (var stream = await request.GetRequestStreamAsync())
            {
                byte[] buffer = Encoding.Default.GetBytes(sb.ToString());
                await stream.WriteAsync(buffer, 0, buffer.Length);
            }

            var response = (HttpWebResponse)await request.GetResponseAsync();
            var responseString = await new StreamReader(response.GetResponseStream()).ReadToEndAsync();
            return HttpUtility.UrlDecode(responseString);
        }
        #endregion
    }
}
