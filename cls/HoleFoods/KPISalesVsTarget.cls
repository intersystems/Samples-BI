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
	set tSC = $$$OK

	// Compute additional values
	set tFilters = ..%filterValues

	// Compute recent history using query
	if ((tFilters.Year'="")&&(tFilters.Year'="*")&&(tFilters.Year'="&[NOW]")) {
		// Take &[] off of Year value!
		set tStartMonth = "Jan-"_$E(tFilters.Year,3,6)
		set tEndMonth = "Dec-"_$E(tFilters.Year,3,6)
	}
	else {
		set tStartMonth = "NOW-12"
		set tEndMonth = "NOW"
	}

	set tROWS = ..RowsClause
	set tMDX = "SELECT "_tROWS_"%LIST(DateOfSale.[MonthSold].["_tStartMonth_"]:["_tEndMonth_"]) ON COLUMNS FROM HOLEFOODSCOMBINED WHERE Measures.[Amount Sold] " _ ..FilterClause
	set tRS = ##class(%DeepSee.Resultset).%New()
	set tSC = tRS.%PrepareMDX(tMDX)
	if $$$ISERR(tSC) quit tSC
	set tSC = tRS.%Execute()
	if $$$ISERR(tSC) quit tSC

	for n = 1:1:..%seriesCount {
		set tValue = tRS.%GetOrdinalValue(1,n)
		set ..%data(n,"History") = tValue
	}
	quit tSC
}

/// Return an MDX statement to execute.
Method %OnGetMDX(ByRef pMDX As %String) As %Status
{
	set tFilters = ..%filterValues

	// Construct an MDX query based on the current filter values
	set tROWS = ""
	set tFILTER = ""

	// Show by
	if (tFilters.ShowBy="Year") {
		set tROWS = "[DateOfSale].[YearSold].Members"
	}
	elseif (tFilters.ShowBy="Month") {
		set tROWS = "[DateOfSale].[MonthSold].Members"
	}
	elseif ((tFilters.ShowBy="ProductCategory")) {
		set tROWS = "[Product].[Product Category].Members"
	}
	elseif ((tFilters.ShowBy="ProductName")||(tFilters.ShowBy="")) {
		set tROWS = "[Product].[Product Name].Members"
	}
	elseif (tFilters.ShowBy="Country") {
		set tROWS = "[Outlet].[Country].Members"
	}
	elseif (tFilters.ShowBy="City") {
		set tROWS = "[Outlet].[City].Members"
	}
	
	if (tROWS'="") {
		set tROWS = "NON EMPTY "_tROWS_" ON ROWS,"
	}

	// Filters
	if ((tFilters.Year'="")&&(tFilters.Year'="*")) {
		set tFILTER = tFILTER_" %FILTER [DateOfSale].[YearSold]."_tFilters.Year
	}
	if ((tFilters.Product'="")&&(tFilters.Product'="*")) {
		set tFILTER = tFILTER_" %FILTER [Product].[Product Category]."_tFilters.Product
	}
	if ((tFilters.Country'="")&&(tFilters.Country'="*")) {
		set tFILTER = tFILTER_" %FILTER [Outlet].[Country]."_tFilters.Country
	}

	set ..FilterClause = tFILTER
	set ..RowsClause = tROWS

	set pMDX = "SELECT "_tROWS_"{Measures.[Amount Sold],Measures.[Target]} ON Columns FROM HOLEFOODSCOMBINED "_tFILTER
	quit $$$OK
}

/// Callback to get additional members for a KPI filter.
/// This takes the form:<br/>
/// pMembers($I(pMembers))=$LB(text,value)<br/>
ClassMethod %OnGetFilterMembers(pFilter As %String, Output pMembers As %List, pSearchKey As %String) As %Status
{
	set tSC = $$$OK
	try {
		// Get member list from cube
		if (pFilter = "Year") {
			set tSC = ..%GetMembersForFilter("HOLEFOODSCOMBINED","[DateOfSale].[Actual].[YearSold]",.pMembers,pSearchKey)
			if $$$ISERR(tSC) quit
		}
		elseif (pFilter = "Product") {
			set tSC = ..%GetMembersForFilter("HOLEFOODSCOMBINED","[Product].[P1].[Product Name]",.pMembers,pSearchKey)
			if $$$ISERR(tSC) quit
		}
		elseif (pFilter = "Country") {
			set tSC = ..%GetMembersForFilter("HOLEFOODSCOMBINED","[Outlet].[H1].[Country]",.pMembers,pSearchKey)
			if $$$ISERR(tSC) quit
		}
	}
	catch(ex) {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

}

