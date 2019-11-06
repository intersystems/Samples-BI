/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
Class BI.Model.PortletDemo.ClockPortlet Extends %DeepSee.Component.Portlet.abstractPortlet
{

Property srcparams As %String;

/// Static HTML display method: draw the BODY of this component as HTML.
Method %DrawHTML()
{
	set size=$G(..settings("SIZE"))
	set ..srcparams=""
	for val="LOGO","STEP","OFFSET","CIRCLE","UTC","SIZE" set ..srcparams=..srcparams_val_"="_$G(..settings(val))_"&"
	
		&html<<div class="Clock" style="overflow:hidden;"> 
		<embed style="overflow:hidden;" id="frame_2" type="image/svg+xml" 
		src="BI.Model.PortletDemo.svgClock.cls?#(..srcparams)#" height="#(size)#" width="#(size)#"/>
		</div>>
}

/// Return the URL of the icon to display for this portlet.
/// This is displayed in the Widget Builder dialog.
/// This should be overridden in subclasses.
ClassMethod %OnGetPortletIcon() As %String
{
	quit "../broker/deepsee/insert_table_clock_48.png"
}

/// Return the localized caption of this portlet.
/// This is displayed in the Widget Builder dialog.
/// This should be overridden in subclasses.
ClassMethod %OnGetPortletName() As %String
{
	quit "AnalogClock"
}

/// Return an optional array of "settings" values for this portlet.
/// The list of settings is displayed in the Widget Builder where the user can view and
/// edit them.
/// When the portlet is rendered, the values of all settings is made available to the
/// portlet's <method>%DrawHTML</method> method via the <property>settings</property>--a
/// multidimensional array subscripted by setting name.
/// On return, pInfo can contain a list of settings in the form:
/// pInfo(n) = $LB(name,value,type,caption,title)
/// name is the logical name of the setting.
/// value is the default value of the setting.
/// type indicates the type of the setting. This determines the control
/// displayed to get the value of the setting. If omitted the type is assumed to be a string.
/// The type can be: "%Integer", "%Boolean", or "ENUM^caption1:value1,caption2:value2".
/// caption is the localized caption of the setting.
/// title is an optional tooltip displayed for the setting.
ClassMethod %OnGetPortletSettings(Output pInfo As %List, ByRef pSettings) As %Status
{
  kill pInfo
  set pInfo($I(pInfo)) = $LB("LOGO",$G(pSettings("LOGO")),"","Clock logo","Logo displayed on top of clock")
  set pInfo($I(pInfo)) = $LB("STEP",$G(pSettings("STEP"),"10"),"%Integer","Second hand redraw interval (msec)","milliseconds steps of second hand")
  set pInfo($I(pInfo)) = $LB("OFFSET",$G(pSettings("OFFSET"),"0"),"%Integer","Offset from base time (min)","minutes difference from base time (Local or UTC)")
  set pInfo($I(pInfo)) = $LB("UTC",$G(pSettings("UTC"),"0"),"%Boolean","UTC","Time Base: local (default) or UTC")
  set pInfo($I(pInfo)) = $LB("CIRCLE",$G(pSettings("CIRCLE"),"1"),"%Boolean","Circle","Shape: square (default) or circle")
  set pInfo($I(pInfo)) = $LB("SIZE",$G(pSettings("SIZE"),"150"),"%Integer","Size","Size of the clock")
     
  quit pInfo
}

}

