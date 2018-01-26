/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This KPI class uses an MDX query that uses %LIST to return a list of values
/// for use as a trend line in a scorecard.
/// <p>For each filter, multiSelect is false, which simplifies the query construction.
/// (The KPI query would be incorrectly formed if the user selected multiple values
/// or used the EXCLUDE option.) 
/// The KPI will not work if a URL parameter specifies multiple values or %NOT.
Class BI.Model.KPIs.DemoTrendLines Extends %DeepSee.KPI
{

Parameter DOMAIN = "PATIENTSAMPLE";

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi name="DemoTrendLines" 
displayName="DemoTrendLines"  
sourceType="mdx"
mdx="SELECT {MEASURES.[%COUNT],%LIST(birthd.decade.MEMBERS)} ON 0, NON EMPTY homed.city.MEMBERS ON 1 FROM patients"
>

<property name="PatCount" 
displayName="PatCount" 
 columnNo="1" />

<property name="BirthTrendByDecade" 
displayName="BirthTrendByDecade" 
 columnNo="2"/>

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

/// In this implementation: Given a filter (in this case an MDX level identifier), 
/// this method returns the list of members in the internal form needed by the KPI.
Method %OnGetMDX(ByRef pMDX As %String) As %Status
{

 if (..%filterValues."[gend].[h1].[gender]"'="") 
 {
    set pMDX = pMDX _ " %FILTER [gend].[h1].[gender]." _..%filterValues."[gend].[h1].[gender]"
 } 

 if (..%filterValues."[homed].[h1].[zip]"'="") 
 {
    set pMDX = pMDX _ " %FILTER [homed].[h1].[zip]." _..%filterValues."[homed].[h1].[zip]"
 } 

 quit $$$OK
}

}

