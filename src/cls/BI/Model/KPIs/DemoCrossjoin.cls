/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This KPI demonstrates how to use an MDX crossjoin query in a KPI.
/// 
Class BI.Model.KPIs.DemoCrossjoin Extends %DeepSee.KPI
{

Parameter DOMAIN = "PATIENTSAMPLE";

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi name="CrossjoinKPI" displayName="CrossjoinKPI" sourceType="manual" >
<property columnNo="1" name="Patient Count" />
<property columnNo="2" name="Avg Test Score"/>
<property columnNo="3" name="Avg Allergy Count"/>

</kpi>
}

Method %OnExecute() As %Status
{
 set tSC = $$$OK
 try
 {
  set MDX = "SELECT {[Measures].[%COUNT],[Measures].[Avg Test Score],"
  _"[Measures].[Avg Allergy Count]} ON 0,"
  _"NONEMPTYCROSSJOIN([AgeD].[Age Group].Members,[PatGrpD].[Patient Group].Members) ON 1 "
  _"FROM [Patients]"
 
 // Create a result set from the query
 set dsRS=##class(%DeepSee.ResultSet).%New()
 set status = dsRS.%PrepareMDX(MDX)
 set status = dsRS.%Execute()
 
 // Get the number of rows and columns
 set rowCount = dsRS.%GetRowCount()
 set colCount = dsRS.%GetColumnCount()

 set ..%seriesCount=rowCount

 // Iterate through rows
 for rows = 1:1:..%seriesCount
 {
  // Row dimensions are stored as labels. The second parameter is 2 for rows (columns would be 1)
  do dsRS.%GetOrdinalLabel(.label,2,rows)
        
   // Fetch the two labels and concatenate them to create name of series
   set ..%seriesNames(rows)=label(2)_" / "_label(1)

  // Iterate through the columns 
  for col = 1:1:colCount
   {
   // Get value in cell
   set tValue= dsRS.%GetOrdinalValue(col,rows)
            
   // The measures can be taken out of the cells in the ResultSet
   Set:col=1 ..%data(rows,"Patient Count") = tValue
   Set:col=2 ..%data(rows,"Avg Test Score") = tValue
   Set:col=3 ..%data(rows,"Avg Allergy Count") = tValue
   }
  }    
}
 catch(ex) {
     Set tSC = ex.AsStatus()
 }
 quit tSC
}

}

