/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This KPI class uses an SQL query and defines one filter.
/// <p>To see the full KPI definition, open this class in Studio.
Class DeepSee.Model.KPIs.DemoSQL Extends %DeepSee.KPI
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
 sql="SELECT DISTINCT PostalCode FROM DeepSee_Study.City"/>

</kpi>
}

/// This callback defines the basic SQL query and also checks for the current values
/// in the filter. The callback adds an SQL WHERE clause with one of the following forms,
/// depending on the user's selections:
/// <ul>
/// <li> WHERE HomeCity->PostalCode = zip_code_selected_by_user
/// <li> WHERE HomeCity->PostalCode IN (zip_code_1,zip_code_2,...)
/// <li> WHERE HomeCity->PostalCode <> zip_code_selected_by_user
/// <li> WHERE HomeCity->PostalCode NOT IN (zip_code_1,zip_code_2,...)
/// </ul>
Method %OnGetSQL(ByRef pSQL As %String) As %Status
{
    //this is the start of the SQL query for this KPI
    Set pSQL = "SELECT HomeCity->Name, Count(*),AVG(Age) FROM DeepSee_Study.Patient "
    
    Set where = ""
    //look at %filterValues to see if a filter has been applied to this KPI instance
    If $IsObject(..%filterValues) {
        If (..%filterValues.ZipCode'="") 
        {
            // Call utility method that returns filter data in convenient format
            Set sqlstring=..%GetSQLForFilter("HomeCity->PostalCode","ZipCode")
            Set where = "WHERE "_sqlstring
            
            // Old version -- this works but only if you disable multiselect for this fitler
            // Set where = "WHERE HomeCity->PostalCode = '" _ ..%filterValues.ZipCode _ "' "
        } 
    }

    Set groupby="GROUP BY HomeCity "
    Set orderby="ORDER BY HomeCity "
    // assemble the SQL statement
    Set pSQL=pSQL_where_groupby_orderby
	Quit $$$OK
}

}

