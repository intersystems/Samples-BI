/// REST Application test bed <br/>
/// This is just a quick graphical alternative to cURL for people who 
/// need to exercise the API but hate to type <br />
/// Out of the box, this sample was designed to run against the DocServer example
/// in SAMPLES, but this can be customized by changing the SERVERCLASS parameter
/// to point to a different subclass of %CSP.REST, and changing the cspApplication
/// property to match the dispatch application defined in the management portal.<br />
/// This page should be hosted on the same server that provides the REST services as
/// it uses its own location.hostname properties for getting the host and port number of
/// the server<br />
/// <b>Additionally, the processRequest() method has a username and password pair hardcoded
/// into the method to save typing, this is fine for personal desk checking but should
/// be customized or removed before sharing this code</b>
Class BI.RESTClient Extends %ZEN.Component.page
{

Parameter JSINCLUDES = "zenCSLM.js,zenESVG.js,DeepSee.js";

/// This is the name of the CLASS that defines the UrlMap (the core of a REST service)
/// that you wish to explore, it should be a subclass of %CSP.REST
Parameter SERVERCLASS = "%DeepSee.REST.v1";

Property serverClass As %ZEN.Datatype.string [ InitialExpression = {..#SERVERCLASS} ];

Property namespace As %ZEN.Datatype.string [ InitialExpression = "SAMPLES" ];

Property server As %ZEN.Datatype.string;

/// Container for the current URL actually being used to send the request
Property requestUrl As %ZEN.Datatype.string;

/// This is the name of the REST dispatcher as defined in the SMP
Property cspApplication As %ZEN.Datatype.string [ InitialExpression = "/api/deepsee" ];

XData Style
{
<style type="text/css">
.heading {
	font:bold 18px Arial;
	text-align: center;
}

.routeDiv {
	border-top:1px solid #000042;
	border-bottom:1px solid #000042;
	position:relative;
	width:100%;
	height:25px;
	display:block;
	font:16px monospace;
}

.routeURL {
	border-right:1px solid #000042;
	position:absolute;
	top:0px;
	bottom:0px;
	left:10px;
	width:550px;
}
.routeMethod {
	border-right:1px solid #000042;
	position:absolute;
	top:0px;
	bottom:0px;
	left:560px;
	width:70px;
	text-align:center;
}

.routeService {
	position:absolute;
	top:0px;
	bottom:0px;
	left:640px;
	width:250px;
}

.responseText {
	position:absolute;
	top:45px;
	left:5px;
	right:5px;
	bottom:8px;
}

.reqForm {
	position:absolute;
	top:3px;
	left:10px;
	right:10px;
	bottom:3px;
}

.targetUrl {
	font-weight:bold;
	border-bottom:2px solid #000042;
	margin-bottom:5px;
	margin-top:5px;
}

.parameterBlock {
	position:relative;
	width:100%;
}

.parameterName {
	position:absolute;
	top:0px;
	left:5px;
}

.parameterValue {
	position:relative;
	left:45%;
	width:50%;
	top:0px;
}

#bodyCtrl {
	width:98%;
	height:50px;
}

#submit {
	margin:5%;
	width:90%;
}

#urlMap {
	position:absolute;
	top:60px;
	left:0px;
	right:0px;
	bottom:0px;
	overflow:auto;
	background:#fafaff;
}

#requestArea {
	position:absolute;
	top:00px;
	left:0px;
	right:0px;
	bottom:0px;
	overflow:auto;
	background:#eeeeff;
}

#responseArea {
	position:absolute;
	top:0px;
	left:0px;
	right:0px;
	bottom:0px;
	overflow:hidden;
	background:#eeffee;
}

.directions {
	font-weight:bold;
	text-align:center;
}

#mapClass {
	position:absolute;
	font:bold 16px monospace;
	top:5px;
	right:10px;
}

#appPrefix {
	position:absolute;
	font:bold 16px monospace;
	top:5px;
	left:10px;
}

#namespace {
	position:absolute;
	font:bold 16px monospace;
	top:5px;
	left:190px;
}


</style>
}

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" title="" layout="none">
<activeVGroup split="50%" handleThickness="3px">
<html>
<div class="heading">DeepSee REST Services Test Page</div>
<div class="directions">Click on a service to generate a request form</div>
<div id="mapClass">
</div>
<div id="appPrefix">
</div>
<div id="namespace">
</div>
<div id="urlMap">
</div>
</html>
<activeHGroup split="25%" handleThickness="3px">
<group id="requestArea" layout="none"></group>
<vgroup>
<group id="responseArea" layout="none"></group>
</vgroup>
</activeHGroup>
</activeVGroup>
</page>
}

ClientMethod onloadHandler() [ Language = javascript ]
{
	this.currentRoute = -1;
	
	this.setRouting();

	// Add a little context for the user
	
	var div = document.getElementById("mapClass");
	div.innerHTML = zenEscapeHTML(this.serverClass);
	
	var div = document.getElementById("appPrefix");
	var html = [];
	html.push('<div class="appPrefix">');
	html.push('<div>Application</div>');
	html.push('<input class="appPrefix" id="appInput" type="text" value="'+this.cspApplication+'" onchange="zenPage.changeApplication()"/>');
	html.push('</div>');
	//div.innerHTML = zenEscapeHTML(this.cspApplication + ' on ' + this.server);
	div.innerHTML = html.join('\n');
	
	var div = document.getElementById("namespace");
	var html = [];
	html.push('<div class="namespace">');
	html.push('<div>Namespace</div>');
	html.push('<input class="namespace" id="nsInput" type="text" value="'+this.namespace+'" onchange="zenPage.changeNamespace()"/>');
	html.push('</div>');
	div.innerHTML = html.join('\n');
}

ClientMethod setRouting() [ Language = javascript ]
{
	if (this.isSystemApplication()) {
		this.prefix = "//"+location.host+this.cspApplication+'/v1/'+encodeURIComponent(this.namespace);
	}
	else {
		this.prefix = "//"+location.host+this.cspApplication;
	}

	this.routes = this.getRoutes();
	this.renderRoutes(this.routes);
	this.renderRequestForm(0);
}

ClientMethod changeApplication() [ Language = javascript ]
{
	var cspApplication = document.getElementById('appInput').value;
	if ('/'==cspApplication[cspApplication.length-1]) {
		cspApplication = cspApplication.substr(0,cspApplication.length-1);
		document.getElementById('appInput').value = cspApplication;
	}

	this.cspApplication = cspApplication;
	
	document.getElementById('nsInput').disabled = (!this.isSystemApplication());
	if (this.isSystemApplication()) {
		document.getElementById('nsInput').value = this.namespace;
	}
	else {
		document.getElementById('nsInput').value = '';
	}

	this.setRouting();
}

ClientMethod changeNamespace() [ Language = javascript ]
{
	this.namespace = document.getElementById('nsInput').value;
	this.setRouting();
}

ClientMethod isSystemApplication() [ Language = javascript ]
{
	return ('/api/deepsee'==this.cspApplication.toLowerCase())
}

/// Callback function to highlight the last clicked-upon service and
/// call out to generate a form
ClientMethod selectRoute(idx) [ Language = javascript ]
{
	if (this.currentRoute>=0) {
		var div = document.getElementById("route_"+this.currentRoute);
		div.style.background = "";
	}
	var div = document.getElementById("route_"+idx);
	div.style.background = "#f0f0ff";
	this.renderRequestForm(idx);
}

/// Renderer for client-side projection of the URL
ClientMethod renderRoutes(rd) [ Language = javascript ]
{
	var div = document.getElementById("urlMap");
	var html = [];
	for (var i=0;i<rd.length;i++) {
		var o = rd[i];
		html.push('<div id="route_'+i+'" class="routeDiv" dataIdx="'+i+'" onclick="zenPage.selectRoute('+i+');">');
		html.push('<div class="routeURL">'+o.url+'</div>');
		html.push('<div class="routeMethod">'+o.method+'</div>');
		html.push('<div class="routeService">'+o.call+'</div>');
		html.push('</div>');
	}
	div.innerHTML=html.join("\n");
}

/// Generate a basic form for the most common options people are likely to 
/// need when desk checking a REST url Map.  For GET requests the options
/// are fairly limited.  For PUT and POST requests, you have the option of entering
/// text for the body of the request, or selecting a file from disk.  If a disk
/// file is selected, the contents of the text area widget on screen is ignored.
ClientMethod renderRequestForm(idx) [ Language = javascript ]
{
	this.currentRoute = -1;
	var div = document.getElementById("requestArea");
	var o = this.routes[parseInt(idx)];
	if (o) {
		var html = [];
		this.currentRoute = parseInt(idx);
		html.push('<div class="reqForm">');
		html.push('<div class="heading">Request</div>');
		html.push('<div class="targetUrl">'+o.method+' '+o.url+'</div>');
		if (o.parms) {
			for (var i=0;i<o.parms.length;i++) {
				html.push('<div class="parameterBlock">');
				html.push('<div class="parameterName">'+o.parms[i]+'</div>');
				html.push('<input class="parameterValue" id="parm_'+i+'_Ctrl" type="text" />');
				html.push('</div>');				
			}
		}
		html.push('<div>Accept: <select id="acceptCtrl">');
		html.push('<option value="application/json">JSON</option>');
		html.push('<option value="text/plain">Text</option>');
		html.push('</select></div>');
		if (o.method=="POST") {
			html.push('<div>Content-Type: <select id="contentCtrl">');
			html.push('<option value="application/json">JSON</option>');
			html.push('<option value="text/plain">Text</option>');
			html.push('</select></div>');
			html.push('<textArea id="bodyCtrl"></textArea>');
			html.push('<input type="file" id="fileCtrl" />');	
		}
		html.push('<button type="button" id="submit" onclick="zenPage.processRequest()">SUBMIT</button>');
		html.push('</div>');
		div.innerHTML=html.join("\n");
	}
}

/// This builds up an abstract model of a request object based on 
/// values entered into the generated form.  NOTE that the username and
/// password have been hard-coded here for speed of testing.
ClientMethod processRequest() [ Language = javascript ]
{
	// Enter REST server authentication here for testing
	var userName = "";
	var userPassword = "";

	var r = {};
	if (this.currentRoute==-1) return;
	var o = this.routes[this.currentRoute];
	
	var tmp = o.url;
	if (o.parms) {
		for (var i=0;i<o.parms.length;i++) {
			//var val = encodeURIComponent(document.getElementById('parm_'+i+'_Ctrl').value);
			var val = document.getElementById('parm_'+i+'_Ctrl').value;
			tmp = tmp.split(o.parms[i]).join(val);
		}
	}
	r.url = this.prefix+tmp;
	r.method = o.method;
	r.user = userName;
	r.passwd = userPassword;
	r.callback = zenPage.processResponse;
	r.acceptType = document.getElementById("acceptCtrl").value;
	if (r.method=="POST" || r.method=="PUT") {
		r.contentType = document.getElementById("contentCtrl").value;
		r.body = document.getElementById("bodyCtrl").value;
		
		var fileHandle = document.getElementById("fileCtrl").files[0];
		if (fileHandle) {
			r.body = fileHandle;
		}
	}
	
	zenPage.requestUrl = r.url;	// Store the URL for display
	
	zenPage.clearResponseArea(0);		// Needs to be called after the requestUrl is set!
	
	this.submitRequest(r);
}

/// This generic method takes a request profile in the form of a JS object
/// and initiates a simple HTTP Request.
/// The request profile may include the any of the following: <br />
/// url - the resourse to request <br />
/// method - the method to use, one of GET, PUT, POST or DELETE <br />
/// user - user name for authentication purposes <br />
/// passwd - user password for authentication purposes <br />
/// acceptType - preferred MIME type for the response <br />
/// contentType - MIME type of request body <br />
/// body - content of request body <br />
/// async - flag to indicate request should be made asynchronously <br />
/// callback - method to when complete (request object will be passed in as sole parameter) <br />
ClientMethod submitRequest(r) [ Language = javascript ]
{
	// check for required properties
	if (!r || !r.method || !r.url ) return;
	// create gemeric request
	var xhr = new XMLHttpRequest();

	// customize for our request, async calls by default
	if (r.async=='undefined') r.async = true;
	
	xhr.open(r.method,r.url,r.async);

	// set up callback handler
	xhr.onload = function () {
  		if (xhr.status === 200) {
    		if (r.callback) {
				r.callback(xhr);
    		}
			else {
   				alert('done');
			}
  		} else {
    		alert('An error occurred\nUse the browsers Developer Tools to inspect headers.');
  		}
  	}

	if (r.user) {
		var tmp=r.user;
		if (r.passwd) tmp=r.user+':'+r.passwd;
		var authStr = "Basic "+btoa(tmp);
		xhr.setRequestHeader("Authorization",authStr);
	}
		
	if (r.acceptType) {
		xhr.setRequestHeader("Accept",r.acceptType);
	}
	var contents = null;
	if (r.method=='POST'||r.method=='PUT') {
		if (r.contentType) {
			xhr.setRequestHeader("Content-Type",r.contentType);
		}
		if (r.body) {
			contents = r.body;
		}
	}
	// kick off the request
	xhr.send(contents);
}

/// Local method to just spit out the body of the response object
ClientMethod processResponse(xhr) [ Language = javascript ]
{
	if (xhr) {
		var body = xhr.responseText;
		var bodyObject = JSON.parse(body);
	}
	
	var div = document.getElementById("responseArea");
	var html=[];
	html.push('<div class="heading">Response</div>');
	html.push('<div class="targetURL" style="position:absolute;left:10px;">'+zenPage.requestUrl+'</div>');
	html.push('<div class="responseText">');
	html.push('<textArea style="width:100%;height:100%;">');
	if (bodyObject) {
		html.push(JSON.stringify(bodyObject,null,2));
	}
	html.push("</textArea>");
	html.push('</div>');
	div.innerHTML=html.join("\n");
}

/// The route data comes down from the server as an XML block (from the XData section
/// of whatever SERVERCLASS was defined) and needs to be converted to a JavaScript 
/// object for local processing. The server side call here is the <i>only</i> reason this 
/// page happens to be a Zen page, all the work done creating XMLHttpRequest objects
/// could have been done from any HTML5 web page, REST does not require the client to be 
/// Zen or even CSP.
ClientMethod getRoutes() [ Language = javascript ]
{
	var routeData = [];
	var xmlData = this.GetRouteData();
	if (xmlData.indexOf("!!")!=0) {
		var xRoot = ESVG.xmlParse(xmlData);
		if (!xRoot) return(null);
		var rInfo = ESVG.xmlGetChildByNodeName(xRoot,"Routes");
		if (rInfo==null) return(null);
		for (var k = rInfo.firstChild;k!=null;k=k.nextSibling) {
			if (k.nodeName=="Route") {
				routeData.push(this.buildRouteObject(k));
			}
			else if (k.nodeName=="Map") {
				// N.B.:  This only supports a single Forward. Multiple forward chains would
				// require recursive handling.
				var newDispatchClass = k.getAttributeByName("Forward").nodeValue;
				if (newDispatchClass) {
					var fwdData = this.GetRouteData(newDispatchClass);
					
					if (fwdData.indexOf("!!")!=0) {
						var fRoot = ESVG.xmlParse(fwdData);
						if (!fRoot) return(null);
						var fInfo = ESVG.xmlGetChildByNodeName(fRoot,"Routes");
						if (fInfo==null) return(null);
						for (var f = fInfo.firstChild;f!=null;f=f.nextSibling) {
							if (f.nodeName=="Route") {
								routeData.push(this.buildRouteObject(f,k.getAttributeByName("Prefix").nodeValue));
							}
						}
					}
				}
			}
		}
	}
	return(routeData);
}

ClientMethod buildRouteObject(xmlNode, prefix) [ Language = javascript ]
{
	var o={};
	o.url = (prefix ? prefix : '') + xmlNode.getAttributeByName("Url").nodeValue;
	var a = o.url.split('/');
	var parms = [];
	for (var i=0;i<a.length;i++) {
		if (a[i].indexOf(':')==0) parms.push(a[i]);
	}
	if (parms.length>0) o.parms = parms;
	o.method = xmlNode.getAttributeByName("Method").nodeValue;
	o.call = xmlNode.getAttributeByName("Call").nodeValue;
	return o;
}

ClientMethod clearResponseArea() [ Language = javascript ]
{
	this.processResponse()
	/*
	var div = document.getElementById("responseArea");
	var html=[];
	html.push('<div class="heading">Response</div>');
	html.push('<div class="responseText">');
	html.push('<textArea style="width:100%;height:100%;">');
	html.push('');
	html.push("</textArea>");
	html.push('</div>');
	div.innerHTML=html.join("\n");
	*/
}

/// Read the UrlMap XData section from the class given in the SERVERCLASS parameter
/// and export it as a block of XML.  This is used by the client page to generate
/// on-screen request forms for exercising the various paths.
ClassMethod GetRouteData(pDispatchClass = "") As %ZEN.Datatype.string [ ZenMethod ]
{
	Set tDispatchClass = $S(pDispatchClass'="":pDispatchClass,1:..#SERVERCLASS)
   	Set xdataID = tDispatchClass_"||UrlMap"
	Set m = ""
	If (xdataID="") {
	   Set m = "!!NOCLASS"
	}
	Else {
	   // Get a stream of XML from the XData block contained in this class
	   Set compiledXdata=##class(%Dictionary.CompiledXData).%OpenId(xdataID)
	   If '$IsObject(compiledXdata) {
		   Set m = "!!OPENFAILED"
	   }
	   Else {
		   Set tStream=compiledXdata.Data
		   If '$IsObject(tStream) {
			   Set tSC=%objlasterror 
			   Set m = "!!NODATA"
		   }
		   Else {
			   //iterate through document, node by node
			   Do tStream.Rewind()
			   While (tStream.AtEnd = 0) {
				   Set l = tStream.ReadLine()
				   
				   // +DTB297 - A regEx catch-all (.*) is used to add support the / character
				   // in these elements. Replace this with the known parameters to drive the
				   // test page controls.
				   If (l["/FilterMembers/") {
					   Set l = $Replace(l,"(.*)",":dataSource/:filterSpec")
				   }
				   ElseIf (l["/PivotVariableDetails/") {
					   Set l = $Replace(l,"(.*)",":cube/:variable")
				   }
				   ElseIf (l["/Filters/") {
					   Set l = $Replace(l,"(.*)",":dataSource")
				   }
				   ElseIf (l["(.*)") {
					   Set l = $Replace(l,"(.*)",":cube")
				   }
				   // -DTB297
				   
			 	   Set m = m_$CHAR(10)_l
			   }
		   }
	   }
	}	
	Quit m
}

/// This callback is called after the server-side page 
/// object and all of its children are created.<br/>
/// Subclasses can override this to add, remove, or modify 
/// items within the page object model, or to provide values
/// for controls.
Method %OnAfterCreatePage() As %Status
{
	Set ..server = $P($SYSTEM,":",2)
	Quit $$$OK
}

}

