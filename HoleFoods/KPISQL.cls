/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// Example KPI definition using SQL statements against the HoleFoods transaction data.
Class HoleFoods.KPISQL Extends %DeepSee.KPI [ DependsOn = HoleFoods.Transaction ]
{

/// This XData definition defines the KPI.
XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi
xmlns="http://www.intersystems.com/deepsee/kpi"
 name="HoleFoods/KPISQL" sourceType="sql"
 sql="SELECT TOP 10000 Product->Name Product, Product ProductCode, Outlet->City As City, Outlet As CityId, Count(*) FROM HoleFoods.SalesTransaction GROUP BY Product"
 caption="KPI SQL">

<filter name="City" valueList="Paris,Munich,Beijing"/>
<filter name="Product" displayList="Onion Ring,Ziti" valueList="SKU-222,SKU-296"/>

<property name="Product" columnNo="1"/>
<property name="SKU" columnNo="2"/>
<property name="City" columnNo="3"/>
<property name="CityId" columnNo="4"/>
<property name="Count" columnNo="5"/>
</kpi>
}

/// This callback, if implements, lets a subclass provide an SQL statement to fetch data for this KPI. 
Method %OnGetSQL(ByRef pSQL As %String) As %Status
{
	If $IsObject(..%filterValues) {
		Set tWHERE = ""
		If (..%filterValues.City'="") {
			Set tWHERE = tWHERE _ $S(tWHERE="":"",1:" AND ") _ " Outlet->City = '" _ ..%filterValues.City _"'"
		}
		If (..%filterValues.Product'="") {
			Set tWHERE = tWHERE _ $S(tWHERE="":"",1:" AND ") _ " Product = '" _ ..%filterValues.Product _"'"
		}

		If (tWHERE'="") {
			// insert WHERE clase within query
			Set tSQL1 = $P(pSQL,"GROUP BY",1)
			Set tSQL2 = $P(pSQL,"GROUP BY",2)
			Set pSQL = tSQL1 _ " WHERE " _ tWHERE
			If (tSQL2 '= "") {
				Set pSQL = pSQL _ " GROUP BY" _ tSQL2
			}
		}
	}
	Quit $$$OK
}

/// This callback, if implemented, returns the text of an SQL query used to provide
/// a "detail listing" for this KPI.<br/>
/// <var>pFilters</var> is an array of current filter values: pFilters(name)=value.<br/>
/// <var>pSelection</var> is an array containing information about the current selected items in the pivot.
/// It contains 2 values:<br/>
/// pSelection("selectedRange") contains the current selected cells in the pivot as a string in the form
/// "startRow,startCol,endRow,endCol" (1-based). "" if no cells are selected.<br/>
/// pSelection("rowValues") contains a csv-list of "row" values for the selected rows in the pivot (similar
/// to the $$$VALUELIST value used for OpenWindow URLs. This may contain "\," for "," within the data values.<br/>
/// <var>pListingName</var> is the name of the listing to display. This is reserved for future use.<br/>
/// This method is simply a convenient alternative to the <method>%OnGetListingResultSet</method> method.
/// It takes precedence over the <method>%OnGetListingResultSet</method> method.
ClassMethod %OnGetListingSQL(ByRef pFilters As %String, ByRef pSelection As %String, pListingName As %String = "") As %String
{
	Set tSQL = "SELECT TOP 1000 %ID,DateOfSale,Product FROM HoleFoods.SalesTransaction"

	// apply sorting, if aksed for
	If (+$G(pSelection("sortColumn"))>0) {
		Set tSQL = tSQL _ " ORDER BY " _ pSelection("sortColumn") _ " " _ $G(pSelection("sortDir"))
	}
	
	Quit tSQL
}

}

