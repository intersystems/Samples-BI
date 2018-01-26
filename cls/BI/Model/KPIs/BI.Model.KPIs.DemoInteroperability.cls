/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
Class BI.Model.KPIs.DemoInteroperability Extends BI.Utils.MDXAutoFiltersKPI
{

Parameter CUBE = "PATIENTS";

Parameter DOMAIN = "PATIENTSAMPLE";

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi name="DemoInteroperability" displayName="DemoInteroperability"  
sourceType="mdx">

<property name="Patient Count" displayName="Patient Count" columnNo="1" />
<property name="Avg Age" displayName="Avg Age" columnNo="2" />

</kpi>
}

Method %OnGetMDX(ByRef pMDX As %String) As %Status
{
 set yaxis=", NON EMPTY [profd].[h1].[profession].MEMBERS ON 1"
 //check custom filter value
 if (..%filterValues."Yaxis"'="") {
	 set yaxis=", NON EMPTY "_..%filterValues.Yaxis_".MEMBERS ON 1"
 }
 set pMDX="SELECT {MEASURES.[%COUNT],MEASURES.[avg age]} on 0"_yaxis_" FROM "_..#CUBE

 /// append a %FILTER clause to handle any other filter values
 Set pMDX = pMDX _ ..FilterBuilder() 
 Quit $$$OK
}

/// Implementation.
ClassMethod %OnGetFilterList(ByRef pFilters As %List, pDataSourceName As %String = "") As %Status
{
	//call method in superclass so we can get filters of the associated cube
	set tSC=##super(.pFilters,pDataSourceName)
	quit:$$$ISERR(tSC) tSC
	
	//update pFilters array to include the custom filter
	set pFilters($i(pFilters)) = $lb("Yaxis","Yaxis",,0)
    
    quit $$$OK
}

/// Implementation.
ClassMethod %OnGetFilterMembers(pFilter As %String, Output pMembers As %List, pSearchKey As %String = "", pDataSourceName As %String = "") As %Status
{
	set pMembers=""
	if (pFilter="Yaxis") {
		set pMembers($I(pMembers))=$LB("Home City","[homed].[h1].[city]")
		set pMembers($I(pMembers))=$LB("Favorite Color","[colord].[h1].[favorite color]")
		set pMembers($I(pMembers))=$LB("Profession","[profd].[h1].[profession]")
		set pMembers($I(pMembers))=$LB("Diagnoses","[diagd].[h1].[diagnoses]")
	} else {
    	//call method in superclass so we can get filter members for the associated cube
 		do ..%GetMembersForFilter(..#CUBE,pFilter,.pMembers,pSearchKey)
	}
    quit $$$OK
}

}

