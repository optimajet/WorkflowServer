if(ELEMENT && ELEMENT.lang){
    ELEMENT.locale(ELEMENT.lang.en);
}

function getBaseUrl () {
    if (typeof(document.baseURI) !== 'undefined') return document.baseURI;

    var baseTag = document.getElementsByTagName('base')[0];
    return location.origin + (baseTag ? baseTag.getAttribute('href') : '');
}

var WorkflowServer = {
    VueConfig: {
        methods: {
            isreadonly : function()  {
                var commandsWithoutRevert = WorkflowServer.Data.commands.filter(function(c){return c.Classifier != 2;});
                var existingProcess = WorkflowServer.Data.processInstance;

                return WorkflowServer.Data.extra.readonly || WorkflowServer.Data.readonly || (!commandsWithoutRevert.length && existingProcess);
            }
        }
    },
    Data: {
        extra: {
            user: {
                name: null,
                sub: null,
                avatar: "images/unknown.svg"
            },
            id_token: null,
            sidebar:{
                mini: false,
                drawer: false,
                menu: [
                    { title: 'Dashboard', icon: 'el-icon-location', href: "" },
                    { title: 'Processes', icon: 'el-icon-document', href: "all", count: null },
                    { title: 'My', icon: 'el-icon-folder-opened', href: "my", count: null, authRequired: true },
                    { title: 'Inbox', icon: 'el-icon-reading', href: "inbox", count: null, authRequired: true },
                    { title: 'Outbox', icon: 'el-icon-document-checked', href: "outbox", count: null, authRequired: true },
                    { title: 'Profile', icon: 'el-icon-user', href: "profile", authRequired: true },
                  ]
            },
            breadcrumb: [],
            errormessage: null,
            confirmdialog: null,
            loading: false,
            valid: null,
            readonly: false,
            initialized: false,
            designer: {
                id: null,
                instance: null,
                apiUrl: null,
                type: null,
                containerId: null,
                deltaWidth: 0,
                deltaHeight: 0
            }
        },
        monitorSession: true,
        embedded: false,
        formsServerUrl: getBaseUrl(),
        formUrl: null, // current form URL
        redirectUrl: null,
        logoutRedirectUrl: null,
        FormData: {}
    },
    Rules: {
        required : { required: true, message: 'The field is required', trigger: 'blur'},
        email : { type: 'email', message: 'Please enter a valid email address', trigger: 'blur' },
        url: { type: 'url', message: 'The field must be a URL'},
        number: { validator: 
            function(rule, value, callback){ 
                var intValues =  /^\d+$/;
                if(!value || Number.isInteger(value) || (value.match(intValues) && !isNaN(value)))
                {
                   callback();
                   return;
                }
                
                callback(new Error(rule.message));
            }, 
            message: 'The field must be a number'
        },
        float: { validator: 
            function(rule, value, callback){ 
                var floatValues =  /[+-]?([0-9]*[.])?[0-9]+/;
                if(!value || (Number(value) === value && value % 1 !== 0) || (value.match(floatValues) && !isNaN(value)))
                {
                    callback();
                    return;
                }
                
                callback(new Error(rule.message));
            }, 
            message: 'The field must be a floating point number'
        }
        
    },
    createForm: function() {
        document.baseURI = getBaseUrl();

        WorkflowServer.onCreated().then(function() {
            WorkflowServer.registerRemoteComponent();

            WorkflowServer.VueConfig.el = '#app';
            WorkflowServer.App = new Vue(WorkflowServer.VueConfig);
        });
    },
    createEmbeddedForm: function(authorityUrl, formsUrl, formUrl, containerId, redirectUrl, logoutRedirectUrl, locale) {
        document.baseURI = getBaseUrl();

        var correctFormsUrl = this.withTrailingSlash(formsUrl);

        WorkflowServer.DataExtend({
            authorityUrl: this.withTrailingSlash(authorityUrl),
            formsServerUrl: correctFormsUrl,
            formUrl,
            monitorSession: false,
            redirectUrl: redirectUrl,
            logoutRedirectUrl: logoutRedirectUrl,
            isEmbeddedIntoAnotherForm: true
        });

        ELEMENT.locale(locale || ELEMENT.lang.en);

        WorkflowServer.onCreated().then(function() {
            WorkflowServer.createMonitorFrame(correctFormsUrl + "monitorframe.html");
            WorkflowServer.registerRemoteComponent(formUrl, true);
            WorkflowServer.VueConfig.el = '#' + containerId;
            WorkflowServer.App = new Vue(WorkflowServer.VueConfig);
        });
    },
    createDesigner: function(designerApiUrl, containerId) {
        document.baseURI = getBaseUrl();

        WorkflowServer.loadStyle(WorkflowServer.Data.authorityUrl + "/css/workflowdesigner.min.css");

        WorkflowServer.loadScriptsInOrder([
            WorkflowServer.Data.authorityUrl + "/scripts/workflowdesigner.min.js",
            WorkflowServer.Data.authorityUrl + "/scripts/workflowdesigner.localization.js",
            WorkflowServer.Data.authorityUrl + "/scripts/pace.min.js",
        ]).then(function () {
            var designer =  WorkflowServer.Data.extra.designer;

            designer.containerId = containerId;
            designer.apiUrl = "/" + designerApiUrl;
            designer.type = WorkflowServer.getUrlParameter('type');
            designer.id = WorkflowServer.getUrlParameter('id');
            WorkflowServer.redrawDesigner();
        });
    },
    createEmbeddedDesigner: function(authorityUrl, formsUrl, designerApiUrl, containerId, type, id, deltaWidth,
                                     deltaHeight, redirectUrl, logoutRedirectUrl, locale) {
        document.baseURI = getBaseUrl();

        var correctFormsUrl = this.withTrailingSlash(formsUrl);

        WorkflowServer.DataExtend({
            authorityUrl: this.withTrailingSlash(authorityUrl),
            formsServerUrl: correctFormsUrl,
            monitorSession: false,
            redirectUrl: redirectUrl,
            logoutRedirectUrl: logoutRedirectUrl,
            isEmbeddedIntoAnotherForm: true
        });

        ELEMENT.locale(locale || ELEMENT.lang.en);

        WorkflowServer.onCreated().then(WorkflowServer.preFetch).then(function() {

            WorkflowServer.createMonitorFrame(correctFormsUrl + "./monitorframe.html");

            var designer =  WorkflowServer.Data.extra.designer;

            designer.containerId = containerId;
            designer.apiUrl = "/" + designerApiUrl;
            designer.type = type;
            designer.id = id;
            designer.deltaWidth = deltaWidth;
            designer.deltaHeight = deltaHeight;

            WorkflowServer.redrawDesigner();
        });
    },
    loadInstances: function(options){
        if(Array.isArray(options.sortBy) && options.sortBy.length > 0){
            options.sort = options.sortBy[0];
            if(Array.isArray(options.sortDesc) && options.sortDesc.length > 0 && options.sortDesc[0]){
                options.sort += " DESC";
            }
        }

        return WorkflowServer.fetchJson(location.href, {queryParams: Object.assign({}, options, {dataonly: true})});
    },
    getCommandType: function(command){
        var res = "";
        if(command.Classifier == 1)
            res = "primary";
        else if(command.Classifier == 2)
            res = 'danger';
        else
            res = 'info';

        return res;
    },
    getLaunchUrl: function(name, type) {
        if(!type) {
            type = "workflow";
        }
        return '' + type + '/' + name + '/launch';
    },
    navigate: function(url) {
        if(!url) {
            WorkflowServer.reload();
        } else {
            //TODO?
            if (url.startsWith("/")) {url = "." + url}

            WorkflowServer.Data.extra.loading = true;

            if(WorkflowServer.Data.isEmbeddedIntoAnotherForm) {
                WorkflowServer.updateRemoteComponent(WorkflowServer.Data.formsServerUrl, url);
            } else if (WorkflowServer.Data.embedded){
                location.href = WorkflowServer.updateQueryStringParameter(url,"embedded",true);
            }
            else {
                location.href = url;
            }
        }
    },
    launch: function(name, type) {
        return WorkflowServer.fetchJson(WorkflowServer.getLaunchUrl(name, type), {
            method: "POST",
            body: JSON.stringify({ data: WorkflowServer.Data.FormData })
        }).then(function(response) {
            if(response.success) {
                WorkflowServer.navigate(response.targetUrl);
                return response;
            }
            else{
                var msg = response.message;
                if(!msg) msg = "The request has not been processed.";
                WorkflowServer.showError(msg);
            }
        });
    },
    executeCommand: function(id, command, commandType, autoReload) {
        if (autoReload === null || autoReload === undefined) {
            autoReload = true;
        }

        var url = WorkflowServer.Data.isEmbeddedIntoAnotherForm ? WorkflowServer.Data.formUrl : location.href;
        var type = "workflow";
        var name = null;

        if(commandType) {
            if (typeof commandType === 'string' || commandType instanceof String) {
                name = commandType;
            } else {
                if(commandType.type) {
                    type = commandType.type;
                }
                name = commandType.name;
            }
        }
        
        if(name) {
            url = "" + type + "/" + name;
            if(WorkflowServer.Data.isEmbeddedIntoAnotherForm) {
                url = WorkflowServer.Data.formsServerUrl + url;
            }
        }

        return WorkflowServer.fetchJson(url, {
            method: "POST",
            body: JSON.stringify({
                id: id,
                command: command,
                "__operation": "executecommand",
                data: WorkflowServer.Data.FormData
            })}).then(function(response){
                if(response.success){
                    if(autoReload){
                        WorkflowServer.navigate(response.targetUrl);
                    }
                    return response;
                }
                else{
                    var msg = response.message;
                    if(!msg) msg = "The request has not been processed.";
                    WorkflowServer.showError(msg);
                }
            });
    },
    deleteInstance: function(id, autoReload){
        if (autoReload === null || autoReload === undefined)
        {
            autoReload = true;
        }
        return WorkflowServer.fetchJson(location.href, {
            method: "DELETE",
            body: JSON.stringify({
                processid: id
            })}).then(function(response){
                if(response.success){
                    if(autoReload){
                        WorkflowServer.reload();
                        return response;
                    }
                    else
                        return response;
                }
                else{
                    var msg = response.message;
                    if(!msg) msg = "The request has not been processed.";
                    WorkflowServer.showError(msg);
                }
            });
    },
    loadSchemes: function(callback){
        return WorkflowServer.fetchJson( WorkflowServer.Data.formsServerUrl + 'data/workflow');
    },
    loadFlows: function(callback){
        return WorkflowServer.fetchJson(WorkflowServer.Data.formsServerUrl +  'data/flow');
    },
    fetchJson: function(url, options){
        return WorkflowServer.fetch(url, options)
        .then(function(response){
            if(response.ok === false){
                WorkflowServer.showError(response.statusText);
                return new Promise(function() {return null;})
            }

            var contentType = response.headers.get('content-type');
            if (response.status === 401) {
                WorkflowServer.showError('401 Request was not authorized.');
                return new Promise(function() {return null;});
            }

            if (contentType === null) return new Promise(function() {return null;});
            else if (contentType.startsWith('application/json')) return response.json();
            else{
                WorkflowServer.showError("An exception on the server. The request has not been processed.");
                return new Promise(function() {return null;})
            }
        });
    },
    fetch: function(url, options){
      
        return WorkflowServer.preFetch().then(function() {
          
            if (options === null || options === undefined)
            {
                options = {};
            }
            options.credentials = 'same-origin';
            // options = {
            //     credentials: 'same-origin',
            //     ...options,
            // };
        
            if(options.queryParams) {
                url += (url.indexOf('?') === -1 ? '?' : '&') + WorkflowServer.queryParams(options.queryParams);
                delete options.queryParams;
            }

            if(WorkflowServer.authHeader) {
                options.headers = {
                    'Authorization': WorkflowServer.authHeader
                };
            }
       
            WorkflowServer.Data.extra.loading = true;
            return fetch(url, options).catch(function(error) {
                WorkflowServer.Data.extra.loading = false;
                WorkflowServer.showError("Error data request!");
                console.log(error);
            }).then(function(response){

                WorkflowServer.Data.extra.loading = false;

                if(!response.ok && response.status === 401) {

                    if(!WorkflowServer.authHeader) {
                       WorkflowServer.logon();
                    }
                } 

                return response;
                
            });
        });
    },
    queryParams: function(params) {
        return Object.keys(params)
            .map(function (k) { return encodeURIComponent(k) + '=' +
                encodeURIComponent(typeof(params[k]) == "object" ? JSON.stringify(params[k]) : params[k]);})
            .join('&');
    },
    DataExtend: function(obj){
        var customizer = function(objValue, srcValue)
        {
            if (_.isArray(objValue)) {
                return srcValue;
            }
        };
        _.mergeWith(WorkflowServer.Data, obj, customizer);
        return WorkflowServer.Data;
    },
    getSort: function(sort){
        if(sort && sort.order){
            if(sort.order == "ascending"){
                return sort.prop + " ASC";
            }
            else{
                return sort.prop + " DESC";
            }

        }
        return "";
    },
    saveForm: function(){
        var url = WorkflowServer.Data.isEmbeddedIntoAnotherForm ? WorkflowServer.Data.formUrl : location.href;
        return WorkflowServer.fetch(url, {
            method: "POST",
            body: JSON.stringify({
                "__operation": "saveform",
                data: WorkflowServer.Data.FormData
            })}).then(function(response){
                if(response.ok){
                    WorkflowServer.reload();
                }
                else{
                    var msg = response.message;
                    if(!msg) msg = "The request has not been processed.";
                    WorkflowServer.showError(msg);
                    console.log(response);
                }
                
            });
    },
    getTitle: function(item){
        var fields = ["title", "name",  "Id", "ProcessId"];
        for (var i = 0; i < fields.length; i++){
            var field = fields[i];
            if(item){
                if(item[field])
                    return item[field];
            }
            else {

                if(WorkflowServer.Data.FormData && WorkflowServer.Data.FormData[field])
                    return WorkflowServer.Data.FormData[field];

                if(WorkflowServer.Data[field])
                    return WorkflowServer.Data[field];
            }
        }
        return "";
    },
    formatDate: function(date){
        if(!date){
            return "";
        }
        
        var d = new Date(date);
        return d.toLocaleDateString() + " " + d.toLocaleTimeString();
    },
    reload: function() {
        WorkflowServer.Data.extra.loading = true;
        
        if(WorkflowServer.Data.isEmbeddedIntoAnotherForm) {
            WorkflowServer.updateRemoteComponent(WorkflowServer.Data.formUrl,"");
        } else {
            location.reload();
        }
    },
    showError: function(message){
        WorkflowServer.App.$notify.error({
            title: 'Error',
            message: message
          });
    },
    showWarning: function(message){ 
        WorkflowServer.App.$notify.warning({
            title: 'Warning',
            message: message
          });
    },
    showConfirm: function(title, message, callback){
        WorkflowServer.Data.extra.confirmdialog = {
            title : title,
            message : message,
            onSuccess: function(){
                callback && callback();
                WorkflowServer.Data.extra.confirmdialog = null;
            }
        };
    },
    getRedirectUrl: function() {
        if(!WorkflowServer.Data.isEmbeddedIntoAnotherForm) {
            return WorkflowServer.getFormsUrl() + "formssignincallback.html";
        }
        return WorkflowServer.Data.redirectUrl || window.location.href;
    },
    getLogoutRedirectUrl: function() {
        if(!WorkflowServer.Data.isEmbeddedIntoAnotherForm) {
            return WorkflowServer.getFormsUrl() + "formssignoutcallback.html";
        }
        return WorkflowServer.Data.logoutRedirectUrl || WorkflowServer.Data.redirectUrl || window.location.href;
    },
    getFormsUrl: function() {
        return WorkflowServer.Data.formsServerUrl ||  window.location.protocol + "//" + window.location.host;
    },
    createManager: function() {
        var userManagerConfig = {
            client_id: 'forms',
            redirect_uri: WorkflowServer.getRedirectUrl(),
            response_type: 'token id_token',
            scope: "openid profile Forms Designer email Roles ExternalLogins",
            authority: WorkflowServer.Data.authorityUrl,
            silent_redirect_uri: WorkflowServer.getFormsUrl() + "silentRenew.html",
            automaticSilentRenew: true,
            filterProtocolClaims: true,
            loadUserInfo: true,
            monitorSession: WorkflowServer.Data.monitorSession,
            post_logout_redirect_uri: WorkflowServer.getLogoutRedirectUrl(),
            iframeNavigator: new IFrameNavigator()
        };
        WorkflowServer.userManager = new Oidc.UserManager(userManagerConfig);
        WorkflowServer.userManager.events.addUserLoaded(function() {

            WorkflowServer.userManager.getUser().then(function(user) {
                if (user && !user.expired) {
                    WorkflowServer.onGetUser(user);
                }
            });
        });
    
        WorkflowServer.userManager.events.addUserSignedOut(WorkflowServer.signOutHandler);
    },
    signOutHandler: function() {
        WorkflowServer.userManager.removeUser().then(function() {
            WorkflowServer.logon();
        });
    },
    getManager: function() {

        if(!WorkflowServer.userManager) {
            WorkflowServer.createManager();
        }
       
        return WorkflowServer.userManager;
    },
    preFetch: function() {

        if(WorkflowServer.authHeader) return Promise.resolve();
       
        return WorkflowServer.getManager().getUser().then(function(user) {
           
            if (user && !user.expired) {
                WorkflowServer.onGetUser(user);
            
                return Promise.resolve();
            } else {
                return WorkflowServer.getManager().signinSilent().catch(function(error) {

                    if(error.error === "login_required") {
                        console.log("session expired");
                    } else {
                        console.log("signin error", error);
                    }
                    
                    return Promise.resolve();
                });
            }
        });
    },
    logon: function() {
        // pass tenantId in extraQueryParams
        return WorkflowServer.getManager().signinRedirect({state: {
            callerUrl: window.location.href // can be used for redirect in custom callback page
        }});
    },
    logoff: function() {
        WorkflowServer.Data.extra.user = {
            name: null,
            sub: null,
            avatar: "images/unknown.svg"
        };
        WorkflowServer.authHeader = null;
        var manager = WorkflowServer.getManager();

        var signoutParams = {
            'id_token_hint': WorkflowServer.Data.extra.id_token
        };

        if(WorkflowServer.getLogoutRedirectUrl() !== window.location.href) {
            signoutParams.data = {
                callerUrl: window.location.href
            };
        }
        else if (WorkflowServer.Data.isEmbeddedIntoAnotherForm)
        {
            signoutParams['post_logout_redirect_uri'] = WorkflowServer.getLogoutRedirectUrl();
        }

        manager.signoutRedirect(signoutParams);
        manager.removeUser();
    },
    updateProfile: function(user) {

        return WorkflowServer.fetch('user/updateprofile', {
            method: "POST",
            body: JSON.stringify({
                profile: user
            })}).then(function(response) {
                if(response.ok){
                
                    if(user.password) {
                        WorkflowServer.logoff();
                    } else {
                        WorkflowServer.getManager().signinSilent();
                    }
                }
                else{
                    var msg = response.message;
                    if(!msg) msg = "The request has not been processed.";
                    WorkflowServer.showError(msg);
                    console.log(response);
                }
            });
    },
    deleteExternalLogin: function(id) {
        return WorkflowServer.fetch('user/deleteexternallogin/' + id).then(function(response) {
            if(response.ok){
                WorkflowServer.getManager().signinSilent();
            }
            else{
                var msg = response.message;
                if(!msg) msg = "The request has not been processed.";
                WorkflowServer.showError(msg);
                console.log(response);
            }
        });

    },
    isAdminAccount: function() {
        return WorkflowServer.Data.extra.user.sub === 'admin';
    },
    onGetUser: function(user) {

        WorkflowServer.Data.extra.id_token = user.id_token;

        WorkflowServer.Data.extra.user = user.profile;

        if(!WorkflowServer.Data.extra.user.avatar) {
            WorkflowServer.Data.extra.user.avatar = "images/unknown.svg";
        }

        WorkflowServer.authHeader = 'Bearer ' + user.access_token;

        if (typeof WorkflowServer.onGetUserCallback === "function") {
            WorkflowServer.onGetUserCallback(user);
        }
    },
    onCreated: function() {

        $.ajaxSetup({
            beforeSend: function(xhr) {
              xhr.setRequestHeader('Authorization', WorkflowServer.authHeader);
            }
        });

        if (window.location.hash) {
            var hash = window.location.hash.substring(1, window.location.hash.length - 1);
            if (hash.split('=').indexOf("id_token") > -1) {

                return WorkflowServer.getManager().signinRedirectCallback().then(function(user) {
                    if (user && !user.expired) {
                        WorkflowServer.onGetUser(user);
                    }
                }).then(function() {
                    history.pushState(undefined, undefined, window.location.pathname);
                });
            }
        }
  
        return Promise.resolve(); 
    },
    registerRemoteComponent: function(url, embedded) {

        if(!url) url = location.href;

        //TODO
        // Add slash in the end for base url case if need
        if (document.baseURI && document.baseURI.substring(0, document.baseURI.length - 1) === location.href) url = document.baseURI;

        WorkflowServer.Data.embedded = !!embedded;      

        Vue.component("remote-form", function (resolve, reject) {
            
            WorkflowServer.fetchForm(url).then(function (response) {
                resolve(WorkflowServer.createRemoteComponent(response));
            })
            .catch(function (error) {
                console.error("remote component loading error", error);
                reject();
            });
            
        });
    },
    updateRemoteComponent: function(serverUrl, relativeUrl) {
        Vue.component("remote-form", function (resolve, reject) {

            WorkflowServer.fetchForm(relativeUrl,serverUrl)
            .then(function (response) {
                resolve(WorkflowServer.createRemoteComponent(response));
            })
            .catch(function (error) {
                console.error("remote component loading error", error);
                reject();
            });
            
        });
        WorkflowServer.App.$forceUpdate();
    },
    fetchForm: function(url, serverUrl) {

        if(serverUrl) {
            var urlWithoutSideSlashes = url.replace(/^\/|\/$/g, '');
            url = serverUrl + urlWithoutSideSlashes;
        }

        WorkflowServer.Data.formUrl = url;
        var embeddedFromUrl = (WorkflowServer.getUrlParameter('embedded') || "").toLowerCase() === "true";
        WorkflowServer.Data.embedded =  WorkflowServer.Data.embedded || embeddedFromUrl;

        var queryParams = {
            template: true
        };

        if(WorkflowServer.Data.embedded && !embeddedFromUrl) {
            queryParams.embedded = WorkflowServer.Data.embedded;
        }
        return WorkflowServer.fetchJson(url, { queryParams: queryParams }).then(function (response) {
            if(response.executeCommand) {
                return WorkflowServer.executeCommand(undefined, response.executeCommand.command,
                    response.executeCommand.commandType, false).then(function(response) {

                        if(WorkflowServer.Data.isEmbeddedIntoAnotherForm) {
                            return WorkflowServer.fetchForm(response.targetUrl, WorkflowServer.Data.formsServerUrl);
                        }

                        WorkflowServer.navigate(response.targetUrl);
                        //location.href = response.targetUrl;
                        return Promise.resolve(response);
                    });

            }else if(response.targetUrl) {

                if(WorkflowServer.Data.isEmbeddedIntoAnotherForm) {
                    return WorkflowServer.fetchForm(response.targetUrl, WorkflowServer.Data.formsServerUrl);
                }

                WorkflowServer.navigate(response.targetUrl);
                //location.href = response.targetUrl;
            }

            return Promise.resolve(response);
        })
    },
    createRemoteComponent: function(response) {

        if(response.Data) {
            WorkflowServer.DataExtend(response.Data);
        }

        if(response.Scripts) {

            var body = document.getElementsByTagName("body")[0];

            response.Scripts.forEach(function(script) {
                var scriptElement = document.createElement("script");
                scriptElement.appendChild(document.createTextNode(script)); 
                body.appendChild(scriptElement);
            });
        }

        return {
            template: response.Template,
            data: function () {
                return WorkflowServer.Data;
            },
            methods: WorkflowServer.VueConfig.methods
        }
    },
    withTrailingSlash: function(url) {
        if (url.endsWith("/")) return url
        else return url + "/";
    },

    createMonitorFrame: function(url) {
        WorkflowServer.frame = window.document.createElement("iframe");
        WorkflowServer.frame.style.visibility = "hidden";
        WorkflowServer.frame.style.position = "absolute";
        WorkflowServer.frame.style.display = "none";
        WorkflowServer.frame.style.width = 0;
        WorkflowServer.frame.style.height = 0;

        WorkflowServer.frame.src = url;

        window.document.body.appendChild(WorkflowServer.frame);
        window.addEventListener("message", WorkflowServer.monitorFrameEventHandler, false);
    },

    monitorFrameEventHandler: function(e) {

        if(e.data === "signout") {
            WorkflowServer.signOutHandler();
        }
    },
    loadScript: function(url) {
        return new Promise(function(resolve, reject) {
            var script = document.createElement('script');
            script.src = url;
    
            script.addEventListener('load', function() {
                // The script is loaded completely
                resolve(true);

            });
    
            document.head.appendChild(script);
        });
    },
    waterfall: function(promises) {
        return promises.reduce(
            function(p, c) {
                // Waiting for `p` completed
                return p.then(function() {
                    // and then `c`
                    return c().then(function(result) {
                        return true;
                    });
                });
            },
            // The initial value passed to the reduce method
            Promise.resolve([])
        );
    },
    loadScriptsInOrder: function(arrayOfJs) {
        var promises = arrayOfJs.map(function(url) {
            return function()  {
                return WorkflowServer.loadScript(url);
            }
        });
        return WorkflowServer.waterfall(promises);
    },
    loadStyle: function(url) {
        $('head').append($('<link rel="stylesheet" type="text/css" />').attr('href', url));
    },
    redrawDesigner: function() {

        var designer =  WorkflowServer.Data.extra.designer;
   
        var w = $(window).width();
        var h = $(window).height();
        
        var data;
        if (designer.instance) {
            data = designer.instance.data;
            designer.instance.destroy();
            window.removeEventListener("resize", WorkflowServer.redrawDesigner);
        }
    
        designer.instance = new WorkflowDesigner({
            name: 'dwkit-embedded-wfdesigner',
            apiurl: WorkflowServer.Data.authorityUrl + designer.apiUrl,
            renderTo: designer.containerId,
            templatefolder: WorkflowServer.Data.authorityUrl + '/templates/',
            graphwidth: w - designer.deltaWidth,
            graphheight: h - designer.deltaHeight
        });

        window.addEventListener("resize", WorkflowServer.redrawDesigner);
    
        if (data == undefined) {
            WorkflowServer.loadscheme();
        }
        else {
            designer.instance.data = data;
            designer.instance.render();
        }
    },
    loadscheme: function() {

        var designer =  WorkflowServer.Data.extra.designer;

        var p = null;

        if(designer.type === 'scheme') {
            p = { schemecode: designer.id, processid: undefined };
        } else {
            p = { processid: designer.id, readonly: true };
        }

        if (designer.instance.exists(p, null, WorkflowServer.errorHandler)) {
            designer.instance.load(p);
        }
        else{
            console.error("scheme not found: ", p);
        }
     
    },
    errorHandler: function(error) {

        if(error) {
            if(error.split && error.split(" ").includes("401:")) { // Unauthorized
                WorkflowServer.createAuthorizationButton();
            } else if (error.errorMessage && error.errorMessage.stack) {
                console.error(error.errorMessage.stack);
            }
        }
    },
    createAuthorizationButton: function() {

        var designer =  WorkflowServer.Data.extra.designer;

        designer.instance.destroy();
        window.removeEventListener("resize", WorkflowServer.redrawDesigner);

        var template = null;

        if(WorkflowServer.Data.extra.user.sub) {
            template = '<el-card style="max-width:220px"><div slot="header" class="clearfix"><span>Designer</span>' + 
                '</div><div  class="text item"><i class="el-icon-error"></i>Access denied for this user</div><br/>' + 
                '<el-button @click="WorkflowServer.logoff()">Logout</el-button></el-card>';
        } else {
            template = '<el-card style="max-width:220px"><div slot="header" class="clearfix"><span>Designer</span>' + 
                '</div><div  class="text item"><i class="el-icon-error"></i>Unauthorized</div><br/>' + 
                '<el-button @click="WorkflowServer.logon()">Logon</el-button></el-card>';
        }

        var LoginButton = Vue.extend({
            template: template
          });
       
        new LoginButton().$mount('#' + designer.containerId);
    },
    getUrlParameter: function(name) {
        var urlParams = new URLSearchParams(location.search);

        var keys = urlParams.keys();

        var result = keys.next();
        while (!result.done) {
            if (result.value.toLowerCase() === name.toLowerCase()) {
                return urlParams.get(result.value);
            }
            result = keys.next();
        }
        return null;
    },
    updateQueryStringParameter: function(uri, key, value) {
        var re = new RegExp("([?&])" + key + "=.*?(&|#|$)", "i");
        if( value === undefined ) {
            if (uri.match(re)) {
                var res = uri.replace(re, '$1$2');
                if(res[res.length - 1] === '&')
                    res = res.substring(0, res.length - 1);
                return res;
            } else {
                return uri;
            }
        } else {
            if (uri.match(re)) {
                return uri.replace(re, '$1' + key + "=" + value + '$2');
            } else {
                var hash =  '';
                if( uri.indexOf('#') !== -1 ){
                    hash = uri.replace(/.*#/, '#');
                    uri = uri.replace(/#.*/, '');
                }
                var separator = uri.indexOf('?') !== -1 ? "&" : "?";
                return uri + separator + key + "=" + value + hash;
            }
        }
    }
};

//Oidc.Log.level = Oidc.Log.DEBUG;
//Oidc.Log.logger = console;
