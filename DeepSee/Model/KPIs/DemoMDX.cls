/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This KPI class uses an MDX query and has three filters.
/// For each filter, multiSelect is false, which simplifies the query construction.
/// <p>To see the full KPI definition, open this class in Studio.
Class DeepSee.Model.KPIs.DemoMDX Extends %DeepSee.KPI
{

Parameter DOMAIN = "PATIENTSAMPLE";

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi name="DemoMDX" 
displayName="DemoMDX"  
sourceType="mdx"
mdx="SELECT {[MEASURES].[%COUNT],MEASURES.[avg test score]} ON 0,NON EMPTY [homed].[h1].[city].MEMBERS ON 1 FROM [patients]" 
>

<property name="PatCount" 
displayName="PatCount" 
 columnNo="1" />

<property name="AvgTestScore" 
displayName="AvgTestScore" 
 columnNo="2"/>

<filter name="[aged].[h1].[age group]" 
displayName="AgeGroup"
 multiSelect="false"/>

<filter name="[gend].[h1].[gender]" 
displayName="Gender"
 multiSelect="false" />

<filter name="[homed].[h1].[zip]" 
displayName="ZipCode" 
 multiSelect="false" />

</kpi>
}

/// In this implementation: Given a filter (in this case an MDX level identifier), 
/// this method returns the list of members in the internal form needed by the KPI.
ClassMethod %OnGetFilterMembers(pFilter As %String, Output pMembers As %List) As %Status
{
    set status = $$$OK
	
    try {
        do ..%GetMembersForFilter("Patients.cube",pFilter,.pMembers)
    }
    catch(ex) {
        set status = ex.AsStatus()
    }

    quit status
}

/// In this implementation: This method adds a %FILTER clause for each non-null 
/// filter value. Because multiselect is off, query construction is fairly simple.
Method %OnGetMDX(ByRef pMDX As %String) As %Status
{
 if (..%filterValues."[homed].[h1].[zip]"'="") 
 {
    set pMDX = pMDX _ " %FILTER [homed].[h1].[zip]." _..%filterValues."[homed].[h1].[zip]"
 } 

 if (..%filterValues."[gend].[h1].[gender]"'="") 
 {
    set pMDX = pMDX _ " %FILTER [gend].[h1].[gender]." _..%filterValues."[gend].[h1].[gender]"
 } 

 if (..%filterValues."[aged].[h1].[age group]"'="") 
 {
    set pMDX = pMDX _ " %FILTER [aged].[h1].[age group]." _..%filterValues."[aged].[h1].[age group]"
 } 

 quit $$$OK
}

}

