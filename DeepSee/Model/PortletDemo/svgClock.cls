/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
Class DeepSee.Model.PortletDemo.svgClock Extends %CSP.Page
{

ClassMethod OnPreHTTP() As %Boolean [ ServerOnly = 1 ]
{
	set %response.ContentType="image/svg+xml"
	quit $$$OK
}

ClassMethod OnPage() As %Status
{
	set size=$G(%request.Data("SIZE",1),200)
	set uri="?"
	for par="LOGO","CIRCLE","UTC","OFFSET","STEP" {
		if $d(%request.Data(par,1),val) set uri=uri_par_"="_val_"&amp;"
	}
 &html<<svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' 
		width="#(size)#" height="#(size)#" viewBox="0 0 400 400" onload="clockInit(evt);">
<defs>
	<filter id="dropShadow" x="-2%" y="-2%" height="120%" width="120%">
		<feGaussianBlur in="SourceAlpha" stdDeviation="3" />
		<feOffset dx="6" dy="6" result="offsetBlur" />
		<feMerge>
			<feMergeNode in="offsetBlur"/>
			<feMergeNode in="SourceGraphic"/>
		</feMerge>
	</filter>
</defs>
<rect id="rect" x="10" y="10" height="380" width="380"
    style="stroke:black; fill:lightgreen; filter:url(#dropShadow)"/>
<circle id="circle" cx="200" cy="200" r="190" 
	style="stroke:black; fill:lightgreen; filter:url(#dropShadow)" />

<g id="watch" style="stroke:none; stroke-width:2px; filter:url(#dropShadow)">
	<path id="path1" d="M 80,200 a120,120 0 1,1 0,0.001" 
		fill="none" stroke="none" />
	<g id="quarter" fill="yellow" stroke="yellow" stroke-width="10" >
	  	<circle cx="50" cy="200" id="circ" r="8" />
  		<path d="M 45 200 l 20 0" transform="rotate(30,200,200)" />
  		<path d="M 45 200 l 20 0" transform="rotate(60,200,200)" />
		</g>
	<use xlink:href="#quarter" transform="rotate(90,200,200)"/>
	<use xlink:href="#quarter" transform="rotate(180,200,200)"/>
	<use xlink:href="#quarter" transform="rotate(270,200,200)"/>

	<g id="hour" stroke="grey" fill="black" stroke-width="2">
		<path d="M 200,100 l -10,110 10,20 10,-20 z" />
	 	</g>
	<g id="min" stroke="grey" fill="black" stroke-width="8"> 
		<path d="M 200,80 l 0,160" /> 
		<path d="M 200,80 l -7,30 14,0 z" stroke-width="4"/>
 		</g>
 	<circle cx="200" cy="200" r="15" fill="red" stroke="black" stroke-width="4" />
	<g id="sec" >
		<path d="M 200,200 l 0,30 0,-200" stroke="red" stroke-width="4"/>
		</g>
  	<circle cx="200" cy="200" r="2" fill="black" stroke="black" stroke-width="2" />
</g>  
<text id="logo" x="200" y="120" text-anchor="middle" 
	style="pointer-events:none; font-size:20pt; fill:gray; stroke:none;	font-family:tahoma verdana;" >
	</text>
>
 		Write "<script language='text/ecmascript'>",!	
 		Write "function uri() { return '"_uri_"' ; }",!
 &html<
 </script>
 <script language='text/ecmascript'>
 function clockInit(evt)
{
	svgRoot = evt.target.ownerDocument;
	hr=svgRoot.getElementById('hour');
	min=svgRoot.getElementById('min');
 	sec=svgRoot.getElementById('sec');
 	logo=svgRoot.getElementById('logo');
 	rect=svgRoot.getElementById('rect');
 	circle=svgRoot.getElementById('circle');	
 	// uri=svgRoot.baseURI; I hate IE
 	uri=uri();
 	val=uri.split('UTC=');
 	UTC=val[1]?parseInt(val[1]):0;
 	val=uri.split('CIRCLE=');
 	shape=val[1]?parseInt(val[1]):0;
 	if (shape>0) { 
		rect.setAttribute('style','stroke:none; fill:none; visibility:hidden;');
 	} else {
	 	circle.setAttribute('style','stroke:none; fill:none; visibility:hidden;');
 	}
 	val=uri.split('LOGO=');
 	if (val[1]) { 
 		val=val[1].split('&amp;');
 		logo.firstChild.data=decodeURI(val[0]);
 		// UTC=(val[0]=='UTC');
 	}
 	val=uri.split("OFFSET=");
 	offset=val[1]?parseInt(val[1]):0;
 	val=uri.split("STEP=");
 	step=val[1]?parseInt(val[1]):100;
 	step=Math.max(step,10);
 	tick();
}
function tick() {
	move();
  	aktiv = window.setTimeout("tick()",step);
}
function move() {
	var now = new Date();
	if (UTC) {
		var h = now.getUTCHours()+(offset/60);
		var m = now.getUTCMinutes()+(offset%60);
 	} else {
		var h = now.getHours()+(offset/60);
		var m = now.getMinutes()+(offset%60);
		}
	var s=now.getSeconds();
	var f=now.getMilliseconds();
	hr.setAttribute('transform','rotate('+((m/60+h)*30)+',200,200)');
	min.setAttribute('transform','rotate('+((s/60+m)*6)+',200,200)');
	sec.setAttribute('transform','rotate('+((f/1000+s)*6)+',200,200)');
}
</script>
</svg>
>
	quit $$$OK
}

}

