/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// Sample KPI for HoleFoods Demo.
/// This KPI provides synthetic corporate data and defines some simple actions.
Class HoleFoods.KPICFO Extends %DeepSee.KPI
{

/// This XData definition defines the KPI.
XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi name="Holefoods/CFO" sourceType="manual">
<property name="Metric"/>
<property name="Alarm"/>
<property name="Trend"/>

<action name="Spend"/>
<action name="Cut Costs"/>
<action name="Raise Prices"/>
<action name="Cut Prices"/>
<action name="Reset"/>
</kpi>
}

/// Notify subclass that KPI is has just be executed.
/// This is a good place to override properties, such as range and threshold.
Method %OnLoadKPI() As %Status
{
	// define list of metrics we will calculate
	// all are percentage of target, so are 0-1.5 typically.

	Set tMetrics(1) = "EBIT"
	Set tMetrics(2) = "Share Price"
	Set tMetrics(3) = "A/Payable"
	Set tMetrics(4) = "A/Receivable"
	Set tMetrics(5) = "Long-term Debt"
	Set tMetrics(6) = "Inventory"
	Set tMetrics(7) = "Market Share"
	
	Set ..%seriesCount = 0
	Set n = $O(tMetrics(""))
	While (n'="") {
		Set ..%seriesCount = ..%seriesCount + 1
		Set ..%seriesNames(n) = $G(tMetrics(n))
		Set ..%data(n,"Metric") = $G(^HoleFoods.CFO(n))
		Set tDelta = $G(^HoleFoods.CFO(n,"delta"))
		Set ..%data(n,"Trend") = $S(tDelta>0.05:tDelta,tDelta<-0.05:tDelta,1:0)
		
		Set tLow = 0.5
		Set tHigh = 0.8
		If (n=2) {
			// special case for share price
			Set tLow = 0.8
			Set tHigh = 1.2
		}
		
		If (..%data(n,"Metric") < tLow) {
			Set ..%data(n,"Alarm") = (tLow-..%data(n,"Metric"))*-100
		}
		ElseIf (..%data(n,"Metric") > tHigh) {
			Set ..%data(n,"Alarm") = (..%data(n,"Metric")-tHigh)*100
		}
		Else {
			Set ..%data(n,"Alarm") = 0
		}
		Set n = $O(tMetrics(n))
	}
	Quit $$$OK
}

/// This callback is invoked from a dashboard when an action defined by this dashboard is invoked.
ClassMethod %OnDashboardAction(pAction As %String, pContext As %ZEN.proxyObject) As %Status
{
#define EBIT	1
#define	SHARE	2
#define AR		3
#define AP		4
#define DEBT	5
#define INV		6
#define	MKT		7

#define INCREASE(%n,%amt) Set ^HoleFoods.CFO(%n) = ($G(^HoleFoods.CFO(%n)) * (1 + (($R(%amt)-(%amt*0.25))/100)))
#define DECREASE(%n,%amt) Set ^HoleFoods.CFO(%n) = ($G(^HoleFoods.CFO(%n)) * (1 + (($R(%amt)-(%amt*0.75))/100)))

	// remember prior value so we can compute delta
	Merge tPrior = ^HoleFoods.CFO
	
	If (pAction = "Spend") {
		$$$DECREASE($$$EBIT,40)
		$$$INCREASE($$$AP,40)
		$$$DECREASE($$$AR,5)
		$$$INCREASE($$$DEBT,30)
		$$$INCREASE($$$INV,20)
		$$$INCREASE($$$MKT,5)
		Set pContext.command = "refresh"
	}
	ElseIf (pAction = "Cut Costs") {
		$$$INCREASE($$$EBIT,40)
		$$$DECREASE($$$AP,30)
		$$$INCREASE($$$AR,5)
		$$$DECREASE($$$DEBT,5)
		$$$DECREASE($$$INV,10)
		$$$DECREASE($$$MKT,5)
		Set pContext.command = "refresh"
	}
	ElseIf (pAction = "Raise Prices") {
		$$$INCREASE($$$EBIT,20)
		$$$INCREASE($$$AR,30)
		$$$DECREASE($$$DEBT,10)
		$$$INCREASE($$$INV,10)
		$$$DECREASE($$$MKT,10)
		Set pContext.command = "refresh"
	}
	ElseIf (pAction = "Cut Prices") {
		$$$DECREASE($$$EBIT,40)
		$$$DECREASE($$$AR,30)
		$$$INCREASE($$$DEBT,10)
		$$$DECREASE($$$INV,30)
		$$$INCREASE($$$MKT,10)
		Set pContext.command = "refresh"
	}
	ElseIf (pAction = "Reset") {
		Kill ^HoleFoods.CFO
		Set ^HoleFoods.CFO(1) = 0.8
		Set ^HoleFoods.CFO(2) = 0.6
		Set ^HoleFoods.CFO(3) = 0.8
		Set ^HoleFoods.CFO(4) = 0.8
		Set ^HoleFoods.CFO(5) = 0.8
		Set ^HoleFoods.CFO(6) = 0.8
		Set ^HoleFoods.CFO(7) = 0.5

		// send refresh command to client
		Set pContext.command = "refresh"
	}

	If ($G(^HoleFoods.CFO($$$MKT)) > 0.95) {
		// no monopolies
		Set ^HoleFoods.CFO($$$MKT) = 0.95
	}


	// share price is average of all!
	// but each "zero" takes away points
	Set tTotal = 0
	Set tCount = 0
	Set tZeroes = 0
	Set n = $O(^HoleFoods.CFO(""))
	While (n'="") {
		Set tValue = $G(^HoleFoods.CFO(n))
		If (tValue <= 0) {
			Set ^HoleFoods.CFO(n) = 0
		}
		If (tValue < 0.2) {
			Set tZeroes = tZeroes + 1
		}
		If (tValue >= 1.5) {
			Set ^HoleFoods.CFO(n) = 1.5
		}
		Set tCount = tCount + 1
		Set tTotal = tTotal + tValue
		Set n = $O(^HoleFoods.CFO(n))
	}
	If (tCount>0) {
		Set ^HoleFoods.CFO($$$SHARE) = (tTotal/tCount) / (tZeroes+1)
		If (^HoleFoods.CFO($$$SHARE)<=0) {
			// out of business
			Set ^HoleFoods.CFO($$$SHARE) = 0
		}
	}

	// compute deltas, if any
	Set n = $O(tPrior(""))
	While (n'="") {
		Set tOld = $G(tPrior(n))
		If (tOld'="") {
			Set ^HoleFoods.CFO(n,"delta") = $G(^HoleFoods.CFO(n)) - tOld
		}
		Set n = $O(tPrior(n))
	}

	Quit $$$OK
}

}

