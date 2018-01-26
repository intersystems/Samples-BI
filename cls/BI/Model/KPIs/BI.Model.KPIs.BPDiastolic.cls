/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// 1-row hardcoded KPI for use in demonstrating ranges and thresholds in a *meter*.
Class BI.Model.KPIs.BPDiastolic Extends %DeepSee.KPI
{

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi name="BPDiastolic" sourceType="mdx" 
mdx='SELECT {70} ON 0 FROM [PATIENTS]'
>
<property name="Diastolic"  columnNo="1" />

</kpi>
}

Method %OnLoadKPI() As %Status
{
    set ..%rangeLower=40
    set ..%thresholdLower=60
    set ..%thresholdUpper=80
    set ..%rangeUpper=100
    quit $$$OK
}

}

