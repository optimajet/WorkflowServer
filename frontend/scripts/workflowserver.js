var WorkflowServer = {
    VueConfig: {
        methods: {
            isreadonly : function()  {
                return WorkflowServer.Data.extra.readonly || WorkflowServer.Data.readonly || WorkflowServer.Data.commands.length == 0;
            }
        }
    },
    Data: {
        extra: {
            user: {
                name: "",
                avatar: "/images/unknown.svg"
            },
            sidebar:{
                mini: false,
                drawer: false,
                menu: [
                    { title: 'Dashboard', icon: 'el-icon-location', href: "/" },
                    { title: 'Processes', icon: 'el-icon-document', href: "/all", count: null },
                    //{ title: 'My', icon: 'el-icon-folder-opened', href: "/my", count: null },
                    //{ title: 'Inbox', icon: 'el-icon-reading', href: "/inbox", count: null },
                    //{ title: 'Outbox', icon: 'el-icon-document-checked', href: "/outbox", count: null },
                  ]
            },
            breadcrumb: [],
            errormessage: null,
            confirmdialog: null,
            loading: false,
            valid: null,
            readonly: false
        },
        FormData: {}
    },
    Rules: {
        required : { required: true, message: 'The field is required', trigger: 'blur'},
        email : { type: 'email', message: 'Please enter a valid email address', trigger: 'blur' },
        url: { type: 'url', message: 'The field must be a URL'},
        number: { validator: 
            function(rule, value, callback){ 
                var intValues =  /^\d+$/;
                if(!value || (value.match(intValues) && !isNaN(value)))
                    callback();
                
                callback(new Error(rule.message));
            }, 
            message: 'The field must be a number'
        },
        float: { validator: 
            function(rule, value, callback){ 
                var floatValues =  /[+-]?([0-9]*[.])?[0-9]+/;
                if(!value || (value.match(floatValues) && !isNaN(value)))
                    callback();
                
                callback(new Error(rule.message));
            }, 
            message: 'The field must be a floating point number'
        },
        
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
    executeCommand: function(id, command, autoReload) {
        if (autoReload === null || autoReload === undefined)
        {
            autoReload = true;
        }

        return WorkflowServer.fetchJson(location.href, {
            method: "POST",
            body: JSON.stringify({
                id: id,
                command: command,
                "__operation": "executecommand",
                "noredirect": "true",
                data: WorkflowServer.Data.FormData
            })}).then(function(response){
                if(response.success){
                    if(autoReload){
                        WorkflowServer.Data.extra.loading = true;
                        if(response.targetUrl){
                            location.href = response.targetUrl;
                        }
                        else{
                            WorkflowServer.reload();
                        }
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
                        WorkflowServer.Data.extra.loading = true;
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
        return WorkflowServer.fetchJson('/data/workflow');
    },
    loadFlows: function(callback){
        return WorkflowServer.fetchJson('/data/flow');
    },
    fetchJson: function(url, options){
        return WorkflowServer.fetch(url, options)
        .then(function(response){
            if(response.ok === false){
                WorkflowServer.showError(response.statusText);
                return new Promise(function() {return null;})
            }

            const contentType = response.headers.get('content-type');
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
    
        WorkflowServer.Data.extra.loading = true;
        return fetch(url, options).catch(function(error) {
            WorkflowServer.Data.extra.loading = false;
            WorkflowServer.showError("Error data request!");
            console.log(error);
        }).then(function(response){
            WorkflowServer.Data.extra.loading = false;
            return response;
        });
    },
    queryParams: function(params) {
        return Object.keys(params)
            .map(function (k) { return encodeURIComponent(k) + '=' +
                encodeURIComponent(typeof(params[k]) == "object" ? JSON.stringify(params[k]) : params[k]);})
            .join('&');
    },
    DataExtend: function(obj){
        WorkflowServer.Data = $.extend(true, WorkflowServer.Data, obj);
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
        return WorkflowServer.fetch(location.href, {
            method: "POST",
            body: JSON.stringify({
                "__operation": "saveform",
                data: WorkflowServer.Data.FormData
            })});
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
    reload: function(){
        WorkflowServer.Data.extra.loading = true;
        location.reload();
    },
    showError: function(message){ 
        WorkflowServer.App.$notify.error({
            title: 'Error',
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
    }
};
