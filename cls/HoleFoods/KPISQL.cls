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
	if $IsObject(..%filterValues) {
		set tWHERE = ""
		if (..%filterValues.City'="") {
			set tWHERE = tWHERE _ $S(tWHERE="":"",1:" AND ") _ " Outlet->City = '" _ ..%filterValues.City _"'"
		}
		if (..%filterValues.Product'="") {
			set tWHERE = tWHERE _ $S(tWHERE="":"",1:" AND ") _ " Product = '" _ ..%filterValues.Product _"'"
		}

		if (tWHERE'="") {
			// insert WHERE clase within query
			set tSQL1 = $P(pSQL,"GROUP BY",1)
			set tSQL2 = $P(pSQL,"GROUP BY",2)
			set pSQL = tSQL1 _ " WHERE " _ tWHERE
			if (tSQL2 '= "") {
				set pSQL = pSQL _ " GROUP BY" _ tSQL2
			}
		}
	}
	quit $$$OK
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
/// This method is simply a convenient alternative to the <method>%OnGetListingResultset</method> method.
/// It takes precedence over the <method>%OnGetListingResultset</method> method.
ClassMethod %OnGetListingSQL(ByRef pFilters As %String, ByRef pSelection As %String, pListingName As %String = "") As %String
{
	set tSQL = "SELECT TOP 1000 %ID,DateOfSale,Product FROM HoleFoods.SalesTransaction"

	// Apply sorting, if aksed for
	if (+$G(pSelection("sortColumn"))>0) {
		set tSQL = tSQL _ " ORDER BY " _ pSelection("sortColumn") _ " " _ $G(pSelection("sortDir"))
	}
	
	quit tSQL
}

}

