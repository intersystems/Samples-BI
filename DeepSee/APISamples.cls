Include %occInclude

/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
Class DeepSee.APISamples
{

/// Executes a hardcoded query and prints the results.
/// Returns the result set as output.
ClassMethod RunQuery1(Output result As %DeepSee.ResultSet) As %Status
{
    Set rset=##class(%DeepSee.ResultSet).%New()
    Set query="SELECT MEASURES.[%COUNT] ON 0, diagd.MEMBERS ON 1 FROM patients"
    Set status=rset.%PrepareMDX(query)
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit status}

    Set status=rset.%Execute()
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit status}
   
    Write !, "Full results are as follows ***************",!
    Do rset.%Print()
    Quit $$$OK
}

/// Executes a query that uses a named parameter and prints the results.
/// Returns the result set as output.
ClassMethod RunQuery2(city As %String = "Magnolia", Output result As %DeepSee.ResultSet) As %Status
{
    Set rset=##class(%DeepSee.ResultSet).%New()
    Set query="WITH %PARM c AS 'value:Magnolia'"
    _"SELECT homed.[city].@c ON 0 FROM patients"
    Set status=rset.%PrepareMDX(query)
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit status}

    Set myparms("c")=city
    Set status=rset.%Execute(.myparms)
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit status}
   
    Write !, "Full results are as follows ***************",!
    Do rset.%Print()
    Quit $$$OK
}

/// Executes a query that does a detail listing and prints the results.
/// Returns the result set as output
ClassMethod RunQuery3()
{
    Set rset=##class(%DeepSee.ResultSet).%New()
    
    Set query="DRILLTHROUGH SELECT gend.female ON 0,birthd.[1913] ON 1 "
             _"FROM patients RETURN PatientID,PrimaryCarePhysician->LastName"

    Set status=rset.%PrepareMDX(query)
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}

    Set status=rset.%Execute()
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
    
    Write !, "Listing details for the first cell are as follows ***************",!
    Do rset.%PrintListing()
}

/// Executes a query and prints the results.
/// Then for comparison, displays a specific cell.
ClassMethod ShowCell() As %Status
{
    Set rset=##class(%DeepSee.ResultSet).%New()
    Set query="SELECT MEASURES.[avg age] ON 0, homed.[city].MEMBERS ON 1 "
             _"FROM patients"
    Set status=rset.%PrepareMDX(query)
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit status}

    Set status=rset.%Execute()
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit status}
    
    Write !, "Full results are as follows ***************",!
    Do rset.%Print()
    
    Write !, "Cell 1,5 is as follows  ***************",!
    Write rset.%GetOrdinalValue(1,5)
    Quit status
}

/// Executes a query and prints the results.
/// Then for comparison, displays information about the row labels.
ClassMethod ShowRowLabels() As %Status
{
    Set rset=##class(%DeepSee.ResultSet).%New()
    Set query="SELECT CROSSJOIN(aged.[age group].MEMBERS,"
             _"gend.gender.MEMBERS) ON 1 FROM patients"
    Set status=rset.%PrepareMDX(query)
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit status}

    Set status=rset.%Execute()
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit status}
    
    Write !, "Full results are as follows ***************",!
    Do rset.%Print()
    
    Write !, "Labels used on the rows are as follows ***************",!
    For j=1:1:rset.%GetAxisSize(2) {
        Write !, "Row ",j
        Set labelcount=rset.%GetOrdinalLabel(.pLabel,2,j)
        For i=1:1:labelcount {
            Write !, "    label("_i_") is "_pLabel(i)
            }
       }
    
    Quit $$$OK
}

/// Given a result set as input, this method generates a report on
/// the query metadata.
ClassMethod ShowQueryMetadata(rset As %DeepSee.ResultSet) As %Status
{
    Set cubename=rset.%GetCubeName()
    Write !, "This result set comes from the following cube: ",cubename,!
    
    Set status=rset.%GetParameterInfo(.pParms)
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit status}
    If $DATA(pParms) {
        Write "The query uses the following parameters:",!
        Set p = $ORDER(pParms(""))
            While (p '= "") {
                Write $$$UPPER(p), " = " ,$GET(pParms(p,"VALUE")),!
                Set p = $ORDER(pParms(p))
        }
    }
    Set query=rset.%GetQueryText()
    Write "The query is as follows:",!, query,!

    Set isdrill=rset.%IsDrillThrough()
    If isdrill {
        Set listingsql=rset.%GetListingSQL()
        Write !!, "It uses the following SQL to drill into the source table:"
        Write !, listingsql
        }
}

/// Given a result set as input, this method generates a report on
/// the result metadata.
ClassMethod ShowResultMetadata(rset As %DeepSee.ResultSet)
{
    Set cubename=rset.%GetCubeName()
    Write !, "This result set comes from the cube ",cubename
    
    Set querykey=rset.%GetQueryKey()
    Set cellcount=##class(%DeepSee.ResultSet).%GetCellCount(cubename,querykey)
    Write !, "It has ", cellcount, " cells"
    
    //For i=1:1:cellcount{
      //  Write !, "cell number ",i," has the value ",rset.%GetOrdinalValue(i)
        //}
}

/// Given a result set as input, this method generates a report on
/// the slicer statement for a given cell range.
ClassMethod ShowSlicerStatement(rset As %DeepSee.ResultSet, Row1 As %Integer = 1, Col1 As %Integer = 1, Row2 As %Integer, Col2 As %Integer) As %Status
{
    If '$DATA(Row2) {Set Row2=Row1}
    If '$DATA(Col2) {Set Col2=Col1}

    Set status=rset.%GetSlicerForCellRange(.slicer,Row1,Col1,Row2,Col2)
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit status}
    
    Write !, "The requested cell range:"
    Write !, "   Columns ",Col1, " through ", Col2
    Write !, "   Rows    ",Row1, " through ", Row2

    Write !, "The slicer statement for the given cell range is as follows:"
    Write !, slicer
    
    If 'rset.%IsDrillThrough(){
        Write !!, "For comparison, the query results are as follows:",!
        Do rset.%Print()
    }
    Else {
	    Write !!, "This is a drillthrough query and %Print "
	    _"does not provide a useful basis of comparison"
	    }
}

/// executes a hardcoded query and returns a result set
ClassMethod GetResultSet1() As %DeepSee.ResultSet
{
    Set rset=##class(%DeepSee.ResultSet).%New()
    Set query="SELECT {MEASURES.[avg test score],MEASURES.[%COUNT]} ON 0, "
             _"diagd.h1.diagnoses.MEMBERS ON 1 FROM patients"
    Set status=rset.%PrepareMDX(query)
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit $$$NULLOREF}

    Set status=rset.%Execute()
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit $$$NULLOREF}
    
    Quit rset
}

/// executes a hardcoded query and returns a result set
ClassMethod GetResultSet2(city As %String = "Magnolia") As %DeepSee.ResultSet
{
    Set rset=##class(%DeepSee.ResultSet).%New()
    Set query="WITH %PARM c AS 'value:Magnolia'"
             _"SELECT homed.h1.[city].@c ON 0 FROM patients"

    Set status=rset.%PrepareMDX(query)
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit $$$NULLOREF}

    Set myparms("c")=city
    Set status=rset.%Execute(.myparms)
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit $$$NULLOREF}
    
    Quit rset
}

/// executes a hardcoded query and returns a result set
ClassMethod GetResultSet3() As %DeepSee.ResultSet
{
    Set rset=##class(%DeepSee.ResultSet).%New()
    Set query="DRILLTHROUGH SELECT gend.h1.gender.female ON 0,birthd.h1.year.[1913] ON 1 "
             _"FROM patients RETURN PatientID,PrimaryCarePhysician->LastName"

    Set status=rset.%PrepareMDX(query)
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit $$$NULLOREF}

    Set status=rset.%Execute()
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit $$$NULLOREF}
    
    Quit rset
}

ClassMethod GetResultSet4() As %DeepSee.ResultSet
{
    Set rset=##class(%DeepSee.ResultSet).%New()
    Set query="SELECT CROSSJOIN(gend.h1.gender.MEMBERS,MEASURES.[%COUNT]) ON 0, "
             _"aged.h1.[age bucket].MEMBERS ON 1 FROM patients"
    Set status=rset.%PrepareMDX(query)
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit $$$NULLOREF}

    Set status=rset.%Execute()
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit $$$NULLOREF}
    
    Quit rset
}

}

