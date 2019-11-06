Include %occInclude

/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
Class BI.APISamples
{

/// Executes a hardcoded query and prints the results.
/// Returns the result set as output.
ClassMethod RunQuery1(Output result As %DeepSee.ResultSet) As %Status
{
    set rset=##class(%DeepSee.ResultSet).%New()
    set query="SELECT MEASURES.[%COUNT] ON 0, diagd.MEMBERS ON 1 FROM patients"
    set status=rset.%PrepareMDX(query)
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit status}

    set status=rset.%Execute()
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit status}
   
    write !, "Full results are as follows ***************",!
    do rset.%Print()
    quit $$$OK
}

/// Executes a query that uses a named parameter and prints the results.
/// Returns the result set as output.
ClassMethod RunQuery2(city As %String = "Magnolia", Output result As %DeepSee.ResultSet) As %Status
{
    set rset=##class(%DeepSee.ResultSet).%New()
    set query="WITH %PARM c AS 'value:Magnolia'"
    _"SELECT homed.[city].@c ON 0 FROM patients"
    set status=rset.%PrepareMDX(query)
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit status}

    set myparms("c")=city
    set status=rset.%Execute(.myparms)
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit status}
   
    write !, "Full results are as follows ***************",!
    do rset.%Print()
    quit $$$OK
}

/// Executes a query that does a detail listing and prints the results.
/// Returns the result set as output.
ClassMethod RunQuery3()
{
    set rset=##class(%DeepSee.ResultSet).%New()
    
    set query="DRILLTHROUGH SELECT gend.female ON 0,birthd.[1913] ON 1 "
             _"FROM patients RETURN PatientID,PrimaryCarePhysician->LastName"

    set status=rset.%PrepareMDX(query)
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit}

    set status=rset.%Execute()
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit}
    
    write !, "Listing details for the first cell are as follows ***************",!
    do rset.%PrintListing()
}

/// Executes a query and prints the results.
/// Then for comparison, displays a specific cell.
ClassMethod ShowCell() As %Status
{
    set rset=##class(%DeepSee.ResultSet).%New()
    set query="SELECT MEASURES.[avg age] ON 0, homed.[city].MEMBERS ON 1 "
             _"FROM patients"
    set status=rset.%PrepareMDX(query)
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit status}

    set status=rset.%Execute()
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit status}
    
    write !, "Full results are as follows ***************",!
    do rset.%Print()
    
    write !, "Cell 1,5 is as follows  ***************",!
    write rset.%GetOrdinalValue(1,5)
    quit status
}

/// Executes a query and prints the results.
/// Then for comparison, displays information about the row labels.
ClassMethod ShowRowLabels() As %Status
{
    set rset=##class(%DeepSee.ResultSet).%New()
    set query="SELECT CROSSJOIN(aged.[age group].MEMBERS,"
             _"gend.gender.MEMBERS) ON 1 FROM patients"
    set status=rset.%PrepareMDX(query)
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit status}

    set status=rset.%Execute()
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit status}
    
    write !, "Full results are as follows ***************",!
    do rset.%Print()
    
    write !, "Labels used on the rows are as follows ***************",!
    for j=1:1:rset.%GetRowCount() {
        write !, "Row ",j
        set labelcount=rset.%GetOrdinalLabel(.pLabel,2,j)
        For i=1:1:labelcount {
            write !, "    label("_i_") is "_pLabel(i)
            }
       }
    
    quit $$$OK
}

/// Given a result set as input, this method generates a report on
/// the query metadata.
ClassMethod ShowQueryMetadata(rset As %DeepSee.ResultSet) As %Status
{
    set cubename=rset.%GetCubeName()
    write !, "This result set comes from the following cube: ",cubename,!
    
    set status=rset.%GetParameterInfo(.pParms)
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit status}
    if $DATA(pParms) {
        write "The query uses the following parameters:",!
        set p = $ORDER(pParms(""))
            While (p '= "") {
                write $$$UPPER(p), " = " ,$GET(pParms(p,"VALUE")),!
                set p = $ORDER(pParms(p))
        }
    }
    set query=rset.%GetQueryText()
    write "The query is as follows:",!, query,!

    set isdrill=rset.%IsDrillThrough()
    if isdrill {
        set listingsql=rset.%GetListingSQL()
        write !!, "It uses the following SQL to drill into the source table:"
        write !, listingsql
        }
}

/// Given a result set as input, this method generates a report on
/// the result metadata.
ClassMethod ShowResultMetadata(rset As %DeepSee.ResultSet)
{
    set cubename=rset.%GetCubeName()
    write !, "This result set comes from the cube ",cubename
    
    set querykey=rset.%GetQueryKey()
    set cellcount=##class(%DeepSee.ResultSet).%GetCellCount(cubename,querykey)
    write !, "It has ", cellcount, " cells"
    
    //For i=1:1:cellcount{
      //  write !, "cell number ",i," has the value ",rset.%GetOrdinalValue(i)
        //}
}

/// Given a result set as input, this method generates a report on
/// the slicer statement for a given cell range.
ClassMethod ShowSlicerStatement(rset As %DeepSee.ResultSet, Row1 As %Integer = 1, Col1 As %Integer = 1, Row2 As %Integer, Col2 As %Integer) As %Status
{
    if '$DATA(Row2) {set Row2=Row1}
    if '$DATA(Col2) {set Col2=Col1}

    set status=rset.%GetSlicerForCellRange(.slicer,Row1,Col1,Row2,Col2)
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit status}
    
    write !, "The requested cell range:"
    write !, "   Columns ",Col1, " through ", Col2
    write !, "   Rows    ",Row1, " through ", Row2

    write !, "The slicer statement for the given cell range is as follows:"
    write !, slicer
    
    if 'rset.%IsDrillThrough(){
        write !!, "For comparison, the query results are as follows:",!
        do rset.%Print()
    }
    Else {
	    write !!, "This is a drillthrough query and %Print "
	    _"does not provide a useful basis of comparison"
	    }
}

/// Executes a hardcoded query and returns a result set.
ClassMethod GetResultSet1() As %DeepSee.ResultSet
{
    set rset=##class(%DeepSee.ResultSet).%New()
    set query="SELECT {MEASURES.[avg test score],MEASURES.[%COUNT]} ON 0, "
             _"diagd.h1.diagnoses.MEMBERS ON 1 FROM patients"
    set status=rset.%PrepareMDX(query)
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit $$$NULLOREF}

    set status=rset.%Execute()
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit $$$NULLOREF}
    
    quit rset
}

/// Executes a hardcoded query and returns a result set.
ClassMethod GetResultSet2(city As %String = "Magnolia") As %DeepSee.ResultSet
{
    set rset=##class(%DeepSee.ResultSet).%New()
    set query="WITH %PARM c AS 'value:Magnolia'"
             _"SELECT homed.h1.[city].@c ON 0 FROM patients"

    set status=rset.%PrepareMDX(query)
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit $$$NULLOREF}

    set myparms("c")=city
    set status=rset.%Execute(.myparms)
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit $$$NULLOREF}
    
    quit rset
}

/// executes a hardcoded query and returns a result set
ClassMethod GetResultSet3() As %DeepSee.ResultSet
{
    set rset=##class(%DeepSee.ResultSet).%New()
    set query="DRILLTHROUGH SELECT gend.h1.gender.female ON 0,birthd.h1.year.[1913] ON 1 "
             _"FROM patients RETURN PatientID,PrimaryCarePhysician->LastName"

    set status=rset.%PrepareMDX(query)
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit $$$NULLOREF}

    set status=rset.%Execute()
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit $$$NULLOREF}
    
    quit rset
}

/// Executes a hardcoded query and returns a result set.
ClassMethod GetResultSet4() As %DeepSee.ResultSet
{
    set rset=##class(%DeepSee.ResultSet).%New()
    set query="SELECT CROSSJOIN(gend.h1.gender.MEMBERS,MEASURES.[%COUNT]) ON 0, "
             _"aged.h1.[age bucket].MEMBERS ON 1 FROM patients"
    set status=rset.%PrepareMDX(query)
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit $$$NULLOREF}

    set status=rset.%Execute()
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit $$$NULLOREF}
    
    quit rset
}

}

