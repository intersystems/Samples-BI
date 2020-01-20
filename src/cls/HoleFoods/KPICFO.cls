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
	// Define list of metrics we will calculate
	// all are percentage of target, so are 0-1.5 typically.

	set tMetrics(1) = "EBIT"
	set tMetrics(2) = "Share Price"
	set tMetrics(3) = "A/Payable"
	set tMetrics(4) = "A/Receivable"
	set tMetrics(5) = "Long-term Debt"
	set tMetrics(6) = "Inventory"
	set tMetrics(7) = "Market Share"
	
	set ..%seriesCount = 0
	set n = $O(tMetrics(""))
	while (n'="") {
		set ..%seriesCount = ..%seriesCount + 1
		set ..%seriesNames(n) = $G(tMetrics(n))
		set ..%data(n,"Metric") = $G(^HoleFoods.CFO(n))
		set tDelta = $G(^HoleFoods.CFO(n,"delta"))
		set ..%data(n,"Trend") = $S(tDelta>0.05:tDelta,tDelta<-0.05:tDelta,1:0)
		
		set tLow = 0.5
		set tHigh = 0.8
		if (n=2) {
			// Special case for share price
			set tLow = 0.8
			set tHigh = 1.2
		}
		
		if (..%data(n,"Metric") < tLow) {
			set ..%data(n,"Alarm") = (tLow-..%data(n,"Metric"))*-100
		}
		elseif (..%data(n,"Metric") > tHigh) {
			set ..%data(n,"Alarm") = (..%data(n,"Metric")-tHigh)*100
		}
		else {
			set ..%data(n,"Alarm") = 0
		}
		set n = $O(tMetrics(n))
	}
	quit $$$OK
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

#define INCREASE(%n,%amt) set ^HoleFoods.CFO(%n) = ($G(^HoleFoods.CFO(%n)) * (1 + (($R(%amt)-(%amt*0.25))/100)))
#define DECREASE(%n,%amt) set ^HoleFoods.CFO(%n) = ($G(^HoleFoods.CFO(%n)) * (1 + (($R(%amt)-(%amt*0.75))/100)))

	// Remember prior value so we can compute delta
	merge tPrior = ^HoleFoods.CFO
	
	if (pAction = "Spend") {
		$$$DECREASE($$$EBIT,40)
		$$$INCREASE($$$AP,40)
		$$$DECREASE($$$AR,5)
		$$$INCREASE($$$DEBT,30)
		$$$INCREASE($$$INV,20)
		$$$INCREASE($$$MKT,5)
		set pContext.command = "refresh"
	}
	elseif (pAction = "Cut Costs") {
		$$$INCREASE($$$EBIT,40)
		$$$DECREASE($$$AP,30)
		$$$INCREASE($$$AR,5)
		$$$DECREASE($$$DEBT,5)
		$$$DECREASE($$$INV,10)
		$$$DECREASE($$$MKT,5)
		set pContext.command = "refresh"
	}
	elseif (pAction = "Raise Prices") {
		$$$INCREASE($$$EBIT,20)
		$$$INCREASE($$$AR,30)
		$$$DECREASE($$$DEBT,10)
		$$$INCREASE($$$INV,10)
		$$$DECREASE($$$MKT,10)
		set pContext.command = "refresh"
	}
	elseif (pAction = "Cut Prices") {
		$$$DECREASE($$$EBIT,40)
		$$$DECREASE($$$AR,30)
		$$$INCREASE($$$DEBT,10)
		$$$DECREASE($$$INV,30)
		$$$INCREASE($$$MKT,10)
		set pContext.command = "refresh"
	}
	elseif (pAction = "Reset") {
		kill ^HoleFoods.CFO
		set ^HoleFoods.CFO(1) = 0.8
		set ^HoleFoods.CFO(2) = 0.6
		set ^HoleFoods.CFO(3) = 0.8
		set ^HoleFoods.CFO(4) = 0.8
		set ^HoleFoods.CFO(5) = 0.8
		set ^HoleFoods.CFO(6) = 0.8
		set ^HoleFoods.CFO(7) = 0.5

		// Send refresh command to client
		set pContext.command = "refresh"
	}

	if ($G(^HoleFoods.CFO($$$MKT)) > 0.95) {
		// No monopolies
		set ^HoleFoods.CFO($$$MKT) = 0.95
	}


	// Share price is average of all!
	// but each "zero" takes away points
	set tTotal = 0
	set tCount = 0
	set tZeroes = 0
	set n = $O(^HoleFoods.CFO(""))
	while (n'="") {
		set tValue = $G(^HoleFoods.CFO(n))
		if (tValue <= 0) {
			set ^HoleFoods.CFO(n) = 0
		}
		if (tValue < 0.2) {
			set tZeroes = tZeroes + 1
		}
		if (tValue >= 1.5) {
			set ^HoleFoods.CFO(n) = 1.5
		}
		set tCount = tCount + 1
		set tTotal = tTotal + tValue
		set n = $O(^HoleFoods.CFO(n))
	}
	if (tCount>0) {
		set ^HoleFoods.CFO($$$SHARE) = (tTotal/tCount) / (tZeroes+1)
		if (^HoleFoods.CFO($$$SHARE)<=0) {
			// Out of business
			set ^HoleFoods.CFO($$$SHARE) = 0
		}
	}

	// Compute deltas, if any
	set n = $O(tPrior(""))
	while (n'="") {
		set tOld = $G(tPrior(n))
		if (tOld'="") {
			set ^HoleFoods.CFO(n,"delta") = $G(^HoleFoods.CFO(n)) - tOld
		}
		set n = $O(tPrior(n))
	}

	quit $$$OK
}

}

