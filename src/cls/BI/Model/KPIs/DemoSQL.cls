/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This KPI class uses an SQL query and defines one filter.
Class BI.Model.KPIs.DemoSQL Extends %DeepSee.KPI
{

Parameter DOMAIN = "PATIENTSAMPLE";

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi name="DemoSQL" 
displayName="DemoSQL" 
sourceType="sql">

<property name="PatCount" 
displayName="PatCount" 
 columnNo="2" />

<property name="AvgAge" 
displayName="AvgAge" 
 columnNo="3"/>

<filter name="ZipCode" 
displayName="ZipCode" 
 sql="SELECT DISTINCT PostalCode FROM BI_Study.City"/>

</kpi>
}

/// This callback defines the basic SQL query and also checks for the current values
/// in the filter. The callback adds an SQL WHERE clause with one of the following forms,
/// depending on the user's selections:
/// WHERE HomeCity->PostalCode = zip_code_selected_by_user
/// WHERE HomeCity->PostalCode IN (zip_code_1,zip_code_2,...)
/// WHERE HomeCity->PostalCode <> zip_code_selected_by_user
/// WHERE HomeCity->PostalCode NOT IN (zip_code_1,zip_code_2,...)
Method %OnGetSQL(ByRef pSQL As %String) As %Status
{
    // This is the start of the SQL query for this KPI
    set pSQL = "SELECT HomeCity->Name, Count(*),AVG(Age) FROM BI_Study.Patient "
    
    set where = ""

    // Look at %filterValues to see if a filter has been applied to this KPI instance
    if $IsObject(..%filterValues) {
        if (..%filterValues.ZipCode'="") 
        {
            // Call utility method that returns filter data in convenient format
            set sqlstring=..%GetSQLForFilter("HomeCity->PostalCode","ZipCode")
            set where = "WHERE "_sqlstring
            
            // Old version -- this works but only if you disable multiselect for this fitler
            // set where = "WHERE HomeCity->PostalCode = '" _ ..%filterValues.ZipCode _ "' "
        } 
    }

    set groupby="GROUP BY HomeCity "
    set orderby="ORDER BY HomeCity "
    // assemble the SQL statement
    set pSQL=pSQL_where_groupby_orderby
	quit $$$OK
}

}

