var http = require("http");
var url = require("url");

var users = [
  { name: "User1", userId: "User1", roles: ["User", "Manager", "Accountant"] },
  { name: "User2", userId: "User2", roles: ["User", "Manager"] },
  { name: "User3", userId: "User3", roles: ["User", "Supervisor"] },
  { name: "User4", userId: "User4", roles: ["User"] }
];

http
  .createServer(function(req, res) {
    var parsedUrl = url.parse(req.url, true);
    var pathname = parsedUrl.pathname;
    var query = parsedUrl.query;

    if (req.method === "POST") {
      let data = [];
      req.on("data", chunk => {
        data.push(chunk);
      });

      req.on("end", () => {
        let parameters = JSON.parse(data);
        Object.assign(parameters, query);
        processRequest(pathname, parameters, req, res);
      });
    } else {
      processRequest(pathname, query, req, res);
    }
  })
  .listen(8080); //the server object listens on port 8080

function processRequest(pathname, parameters, req, res) {
  let content = "The operation is not found!";
  let contentType = "application/json";
  if (pathname === "/") {
    content = defaultpage(parameters);
    contentType = "text/plain";
  } else if (pathname === "/getactions") {
    content = getaction(parameters);
  } else if (pathname === "/executeactions") {
    content = executeactions(parameters);
  } else if (pathname === "/getconditions") {
    content = getconditions(parameters);
  } else if (pathname === "/executeconditions") {
    content = executeconditions(parameters);
  } else if (pathname === "/getrules") {
    content = getrules(parameters);
  } else if (pathname === "/checkrule") {
    content = checkrule(parameters);
  } else if (pathname === "/getidentities") {
    content = getidentities(parameters);
  } else if (pathname === "/processstatuschanged") {
    content = processstatuschanged(parameters);
  }

  res.writeHead(200, { "Content-Type": contentType });
  if (typeof content !== "string") {
    content = JSON.stringify({
      success: true,
      data: content
    });
  }

  parameters.processInstance = "...";
  console.log(req.url, "parameters:", parameters, "response:", content);
  res.write(content); //write a response to the client
  res.end(); //end the response
}

function defaultpage() {
  let res = "This is Callback API sample for WorkflowServer.";
  res += "\n\n";
  res += "Users list:\n";
  users.forEach(function(user) {
    res += JSON.stringify(user) + "\n";
  });
  res += "\n\n";
  res +=
    "Source code: https://codesandbox.io/s/workflowservercallbackapi-57zb8";
  return res;
}

function getaction({ schemeCode }) {
  return ["Action1", "Action2", "Action3", "StartSurvey"];
}

var surveys = {};

function executeactions({ name, parameter, processInstance }) {   
  if(name == "StartSurvey") {
    setTimeout(function(){
      surveys[processInstance.Id] = true;
    }, 30000);
  }
  //TODO Execute the action
}

function getconditions({ schemeCode }) {
  return ["Condition1", "Condition2", "Condition3", "IsSurveyFinished"];
}

function executeconditions({ name, parameter, processInstance }) {
  if(name == "IsSurveyFinished"){
    if(surveys[processInstance.Id] == true){
      return true;
    }
    return false;
  }
  return true;
}

function getrules({ schemeCode }) {
  return ["CheckRole"];
}

function checkrule({ name, identityId, parameter, processInstance }) {
  //TODO Check the rule
  if (name === "CheckRole") {
    let roleName = parameter;
    let user = undefined;
    users.forEach(function(u) {
      if (u.userId === identityId) user = u;
    });

    if (user && Array.isArray(user.roles)) {
      return user.roles.includes(roleName);
    }
  }

  return false;
}

function getidentities({ name, parameter, processInstance }) {
  //TODO Return all users for the role
  if (name === "CheckRole") {
    let roleName = parameter;
    let identities = [];
    users.forEach(function(u) {
      if (Array.isArray(u.roles) && u.roles.includes(roleName)) {
        identities.push(u.userId);
      }
    });
    return identities;
  }

  return [];
}

function processstatuschanged({ processId, schemeCode, processInstance }) {}
