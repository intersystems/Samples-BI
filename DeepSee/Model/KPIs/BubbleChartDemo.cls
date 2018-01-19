/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// Sample KPI for HoleFoods Demo.
/// This KPI provides synthetic corporate data and defines some simple actions.
Class DeepSee.Model.KPIs.BubbleChartDemo Extends %DeepSee.KPI
{

/// This XData definition defines the KPI.
XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi name="BubbleChartDemo" sourceType="manual">
<property name="x"/>
<property name="y"/>
<property name="radius"/>
<property name="color"/>
<property name="opacity"/>

</kpi>
}

/// Notify subclass that KPI is has just be executed.
/// This is a good place to override properties, such as range and threshold.
Method %OnLoadKPI() As %Status
{
	set n=1
	set ..%seriesNames(n)="Alpha"
	set ..%data(n,"x")=15
	set ..%data(n,"y")=327
	set ..%data(n,"radius")=$R(6)+4
	set ..%data(n,"color")=$R(3)
	set ..%data(n,"opacity")=$R(7)+4
	
	set n=2
	set ..%seriesNames(n)="Beta"
	set ..%data(n,"x")=10
	set ..%data(n,"y")=200
	set ..%data(n,"radius")=$R(6)+4
	set ..%data(n,"color")=$R(3)
	set ..%data(n,"opacity")=$R(7)+4
	
	set n=3
	set ..%seriesNames(n)="Gamma"
	set ..%data(n,"x")=22
	set ..%data(n,"y")=256
	set ..%data(n,"radius")=$R(6)+4
	set ..%data(n,"color")=$R(3)
	set ..%data(n,"opacity")=$R(7)+4

	set n=4
	set ..%seriesNames(n)="Delta"
	set ..%data(n,"x")=17
	set ..%data(n,"y")=193
	set ..%data(n,"radius")=$R(6)+4
	set ..%data(n,"color")=$R(3)
	set ..%data(n,"opacity")=$R(7)+4

	set n=5
	set ..%seriesNames(n)="Epsilon"
	set ..%data(n,"x")=27
	set ..%data(n,"y")=281
	set ..%data(n,"radius")=$R(6)+4
	set ..%data(n,"color")=$R(3)
	set ..%data(n,"opacity")=$R(7)+4

	set n=6
	set ..%seriesNames(n)="Zeta"
	set ..%data(n,"x")=33
	set ..%data(n,"y")=301
	set ..%data(n,"radius")=$R(6)+4
	set ..%data(n,"color")=$R(3)
	set ..%data(n,"opacity")=$R(7)+4

	set n=7
	set ..%seriesNames(n)="Eta"
	set ..%data(n,"x")=25
	set ..%data(n,"y")=310
	set ..%data(n,"radius")=$R(6)+4
	set ..%data(n,"color")=$R(3)
	set ..%data(n,"opacity")=$R(7)+4

	set n=8
	set ..%seriesNames(n)="Theta"
	set ..%data(n,"x")=17
	set ..%data(n,"y")=399
	set ..%data(n,"radius")=$R(6)+4
	set ..%data(n,"color")=$R(3)
	set ..%data(n,"opacity")=$R(7)+4

	set n=9
	set ..%seriesNames(n)="Iota"
	set ..%data(n,"x")=35
	set ..%data(n,"y")=175
	set ..%data(n,"radius")=$R(6)+4
	set ..%data(n,"color")=$R(3)
	set ..%data(n,"opacity")=$R(7)+4

	set n=10
	set ..%seriesNames(n)="Kappa"
	set ..%data(n,"x")=28
	set ..%data(n,"y")=255
	set ..%data(n,"radius")=$R(6)+4
	set ..%data(n,"color")=$R(3)
	set ..%data(n,"opacity")=$R(7)+4

	set ..%seriesCount=n
	quit $$$OK
}

}

