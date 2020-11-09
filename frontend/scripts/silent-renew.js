var DefaultTimeout = 10000;
var Log = Oidc.Log;


var IFrameWindow = function(params) {

    var me = this;

    this.promise = new Promise(function(resolve, reject) {
        me._resolve = resolve;
        me._reject = reject;
    });

    this.origin = params.origin;

    this._boundMessageEvent = this._message.bind(this);
    window.addEventListener("message", this._boundMessageEvent, false);

    this._frame = window.document.createElement("iframe");

    // shotgun approach
    this._frame.style.visibility = "hidden";
    this._frame.style.position = "absolute";
    this._frame.style.display = "none";
    this._frame.style.width = 0;
    this._frame.style.height = 0;

    window.document.body.appendChild(this._frame);
}

IFrameWindow.prototype.navigate = function(params) {
    if (!params || !params.url) {
        this._error("No url provided");
    }
    else {
        var timeout = params.silentRequestTimeout || DefaultTimeout;
        Log.debug("IFrameWindow.navigate: Using timeout of:", timeout);
        this._timer = window.setTimeout(this._timeout.bind(this), timeout);
        this._frame.src = params.url;
    }

    return this.promise;
}

IFrameWindow.prototype._success = function(data) {
    this._cleanup();

    Log.debug("IFrameWindow: Successful response from frame window");
    this._resolve(data);
}

IFrameWindow.prototype._error = function(message) {
    this._cleanup();

    Log.error(message);
    this._reject(new Error(message));
}

IFrameWindow.prototype.close = function() {
    this._cleanup();
}

IFrameWindow.prototype._cleanup = function() {
    if (this._frame) {
        Log.debug("IFrameWindow: cleanup");

        window.removeEventListener("message", this._boundMessageEvent, false);
        window.clearTimeout(this._timer);
        window.document.body.removeChild(this._frame);

        this._timer = null;
        this._frame = null;
        this._boundMessageEvent = null;
    }
}

IFrameWindow.prototype._timeout = function() {
    Log.debug("IFrameWindow.timeout");
    this._error("Frame window timed out");
}

IFrameWindow.prototype._message = function(e) {
    Log.debug("IFrameWindow.message");

    if (this._timer &&
       // e.origin === this._get_origin() &&
        e.source === this._frame.contentWindow
    ) {
        var url = e.data;
        if (url) {
            this._success({ url: url });
        }
        else {
            this._error("Invalid response from frame");
        }
    }
}

IFrameWindow.prototype._get_origin = function() {
    return location.protocol + "//" + location.host;
}

IFrameWindow.notifyParent = function(url, origin) {
    Log.debug("IFrameWindow.notifyParent");
    url = url || window.location.href;
    if (url) {
        Log.debug("IFrameWindow.notifyParent: posting url message to parent");
        window.parent.postMessage(url,
            origin || location.protocol + "//" + location.host
        );
    }
}

var IFrameNavigator = function(settings) {
    if(settings) {
        this.origin = settings.origin;
    }
}

IFrameNavigator.prototype.prepare = function(params) {
    var clonedParams = $.extend(true, {}, params);
    clonedParams.origin= this.origin;

    var frame = new IFrameWindow(clonedParams);
    return Promise.resolve(frame);
}

IFrameNavigator.prototype.callback = function(url) {
    Log.debug("IFrameNavigator.callback");

    try {
        IFrameWindow.notifyParent(url, this.origin);
        return Promise.resolve();
    }
    catch (e) {
        return Promise.reject(e);
    }
}
