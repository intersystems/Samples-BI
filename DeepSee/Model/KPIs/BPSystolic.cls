/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// 1-row hardcoded KPI for use in demonstrating ranges and thresholds in a *meter*
Class DeepSee.Model.KPIs.BPSystolic Extends %DeepSee.KPI
{

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi name="BPSystolic" sourceType="mdx" 
mdx='SELECT {110} ON 0 FROM [PATIENTS]'
>
<property name="Systolic"  columnNo="1" />

</kpi>
}

Method %OnLoadKPI() As %Status
{
    set ..%rangeLower=70
    set ..%thresholdLower=90
    set ..%thresholdUpper=120
    set ..%rangeUpper=190
    quit $$$OK
}

}

