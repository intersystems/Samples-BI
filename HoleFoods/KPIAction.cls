/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// KPI class used to supply Actions for the HOLEFOODS cube.
/// This is a demonstration and does not actually do anything!
Class HoleFoods.KPIAction Extends %DeepSee.KPI
{

/// This XData definition defines the KPI.
XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi
xmlns="http://www.intersystems.com/deepsee/kpi"
 name="Holefoods Actions">

<action name="ActionA"/>
<action name="ActionB"/>
<action name="ActionC"/>
</kpi>
}

/// This callback is invoked from a dashboard when an action defined by this dashboard is invoked.
ClassMethod %OnDashboardAction(pAction As %String, pContext As %ZEN.proxyObject) As %Status
{
	// pAction is the name of the action (as defined in the XML list).
	// pContext contains information from the client
	// and can be used to return information.

	// value associated with current item in widget.
	Set tSelectedValue = pContext.currValue

	If (pAction="ActionA") {
		// Go to a new page
		Set pContext.command = "navigate:http://www.intersystems.com"
	}

	Quit $$$OK
}

}

