/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// Sample KPI for HoleFoods Demo.
/// This KPI provides real sales data compared with budget targets.
Class HoleFoods.KPISalesVsTarget Extends %DeepSee.KPI
{

/// Used to pass ROWS clause among methods.
Property RowClause As %String;

/// Used to pass filter clause among methods.
Property FilterClause As %String;

/// This XData definition defines the KPI.
XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi xmlns="http://www.intersystems.com/deepsee/kpi"
 name="Holefoods/SalesAgainstTargets" sourceType="mdx"
 caption="Sales against Targets"
>
<property name="AmountOfSale" displayName="AmountOfSale" columnNo="1"/>
<property name="Target" displayName="Target" columnNo="2"/>
<property name="History" displayName="History"/>
<filter name="ShowBy" displayName="ShowBy" valueList="Year,Month,ProductCategory,ProductName,Country,City" multiSelect="false"/>
<filter name="Year" displayName="Year" filterProperty="Year" multiSelect="false"/>
<filter name="Product" displayName="Product" filterProperty="" multiSelect="false"/>
<filter name="Country" displayName="Country" filterProperty="" multiSelect="false"/>
</kpi>
}

/// Notification that this KPI is being executed.
/// This is a good place to override properties, such as range and threshold.
Method %OnLoadKPI() As %Status
{
	Set tSC = $$$OK

	// Compute additional values
	Set tFilters = ..%filterValues

	// compute recent history using query
	If ((tFilters.Year'="")&&(tFilters.Year'="*")&&(tFilters.Year'="&[NOW]")) {
		// Take &[] off of Year value!
		Set tStartMonth = "Jan-"_$E(tFilters.Year,3,6)
		Set tEndMonth = "Dec-"_$E(tFilters.Year,3,6)
	}
	Else {
		Set tStartMonth = "NOW-12"
		Set tEndMonth = "NOW"
	}

	Set tROWS = ..RowsClause
	Set tMDX = "SELECT "_tROWS_"%LIST(DateOfSale.[MonthSold].["_tStartMonth_"]:["_tEndMonth_"]) ON COLUMNS FROM HOLEFOODSCOMBINED WHERE Measures.[Amount Sold] " _ ..FilterClause
	Set tRS = ##class(%DeepSee.ResultSet).%New()
	Set tSC = tRS.%PrepareMDX(tMDX)
	If $$$ISERR(tSC) Quit tSC
	Set tSC = tRS.%Execute()
	If $$$ISERR(tSC) Quit tSC

	For n = 1:1:..%seriesCount {
		Set tValue = tRS.%GetOrdinalValue(1,n)
		Set ..%data(n,"History") = tValue
	}
	Quit tSC
}

/// Return an MDX statement to execute.
Method %OnGetMDX(ByRef pMDX As %String) As %Status
{
	Set tFilters = ..%filterValues

	// Construct an MDX query based on the current filter values
	Set tROWS = ""
	Set tFILTER = ""

	// show by
	If (tFilters.ShowBy="Year") {
		Set tROWS = "[DateOfSale].[YearSold].Members"
	}
	ElseIf (tFilters.ShowBy="Month") {
		Set tROWS = "[DateOfSale].[MonthSold].Members"
	}
	ElseIf ((tFilters.ShowBy="ProductCategory")) {
		Set tROWS = "[Product].[Product Category].Members"
	}
	ElseIf ((tFilters.ShowBy="ProductName")||(tFilters.ShowBy="")) {
		Set tROWS = "[Product].[Product Name].Members"
	}
	ElseIf (tFilters.ShowBy="Country") {
		Set tROWS = "[Outlet].[Country].Members"
	}
	ElseIf (tFilters.ShowBy="City") {
		Set tROWS = "[Outlet].[City].Members"
	}
	
	If (tROWS'="") {
		Set tROWS = "NON EMPTY "_tROWS_" ON ROWS,"
	}

	// filters
	If ((tFilters.Year'="")&&(tFilters.Year'="*")) {
		Set tFILTER = tFILTER_" %FILTER [DateOfSale].[YearSold]."_tFilters.Year
	}
	If ((tFilters.Product'="")&&(tFilters.Product'="*")) {
		Set tFILTER = tFILTER_" %FILTER [Product].[Product Category]."_tFilters.Product
	}
	If ((tFilters.Country'="")&&(tFilters.Country'="*")) {
		Set tFILTER = tFILTER_" %FILTER [Outlet].[Country]."_tFilters.Country
	}

	Set ..FilterClause = tFILTER
	Set ..RowsClause = tROWS

	Set pMDX = "SELECT "_tROWS_"{Measures.[Amount Sold],Measures.[Target]} ON Columns FROM HOLEFOODSCOMBINED "_tFILTER
	Quit $$$OK
}

/// Callback to get additional members for a KPI filter.
/// This takes the form:<br/>
/// pMembers($I(pMembers))=$LB(text,value)<br/>
ClassMethod %OnGetFilterMembers(pFilter As %String, Output pMembers As %List, pSearchKey As %String) As %Status
{
	Set tSC = $$$OK
	Try {
		// get member list from cube
		If (pFilter = "Year") {
			Set tSC = ..%GetMembersForFilter("HOLEFOODSCOMBINED","[DateOfSale].[Actual].[YearSold]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		ElseIf (pFilter = "Product") {
			Set tSC = ..%GetMembersForFilter("HOLEFOODSCOMBINED","[Product].[P1].[Product Name]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
		ElseIf (pFilter = "Country") {
			Set tSC = ..%GetMembersForFilter("HOLEFOODSCOMBINED","[Outlet].[H1].[Country]",.pMembers,pSearchKey)
			If $$$ISERR(tSC) Quit
		}
	}
	Catch(ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

}

