/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the DeepSee Patients sample, whose purpose is to provide
/// sample data for use with DeepSee. 
/// <p>This class contains the rainfall for the cities, by year and month, and is meant
/// for use as an additional DeepSee model/cube.
/// <p>This table is populated only if you use the R option when running the 
/// GenerateData() method in DeepSee.Populate. You can also use
/// the GenerateData() method in this class if you have already populated the main
/// sample.
/// <p>
/// You can extend or modify the data contained here by editing the XData block in this class.
Class DeepSee.Study.CityRainfall Extends %Persistent
{

/// This parameter setting enables the DSTIME feature for DeepSee II
Parameter DSTIME = "AUTO";

Property City As DeepSee.Study.City;

Property MonthAndYear As %Date;

Property InchesOfRain As %Numeric;

/// fields: month number^average rainfall in inches^variance in inches
XData LoadData
{
<table>
 <row>1^1.13^0.25</row>
 <row>2^1.56^0.25</row>
 <row>3^2.71^0.25</row>
 <row>4^2.77^0.5</row>
 <row>5^5.22^0.5</row>
 <row>6^4.31^0.5</row>
 <row>7^2.61^0.35</row>
 <row>8^2.60^0.35</row>
 <row>9^3.84^0.5</row>
 <row>10^3.23^0.5</row>
 <row>11^1.98^0.35</row>
 <row>12^1.40^0.25</row>
</table>
}

/// Call this after the cities have been set up; this means we reopen each city once.
ClassMethod GenerateData() As %Status
{
    Write !, "Creating rainfall data for the cities..."
    //never use %KillExtent() in a real application
    Do ..%KillExtent()

    // Get a stream of XML from the XData block contained in this class
    Set tStream=##class(%Dictionary.CompiledXData).IDKEYOpen($CLASSNAME(),"LoadData").Data
    If '$IsObject(tStream) {Set tSC=%objlasterror Quit}
   
    Set status=##class(%XML.TextReader).ParseStream(tStream,.textreader)
    //check status
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
   
    //iterate through document, node by node
    While textreader.Read()
    {
        If (textreader.NodeType="chars")
        {
            Set value=textreader.Value

            Set month=$Piece(value,"^",1)
            Set avgrainfall=$Piece(value,"^",2)
            Set var=$Piece(value,"^",3)
            Set ^||myvar("rainfall",month,"min")=avgrainfall-var
            Set ^||myvar("rainfall",month,"max")=avgrainfall+var
            }
    }
   
    Set myquery="select ID from DeepSee_Study.City"
    Set rset=##class(%ResultSet).%New("%DynamicQuery:SQL")
    Set status=rset.Prepare(myquery)
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
    Set status=rset.Execute()
    
    While (rset.Next(.status)) {
	    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
	    Set cityid=rset.Data("ID")
	    Set city=##class(DeepSee.Study.City).%OpenId(cityid,0)
	    	        
        //we have rainfall data for a particular span of years
        set separator=##class(%SYS.NLS.Format).GetFormatItem("DateSeparator")
        For year=1900:1:$Piece($Zdate($h,1),separator,3) {
	        For month=1:1:12 {
		        Set record=..%New()
		   		Set record.City=city
		   		If (month<10) {
			   		Set monthstring="0"_month
			   		}
			   		Else {
				   		Set monthstring=month
				   		}
		    Set datestring=year_"-"_monthstring_"-01"
    	    Set min=^||myvar("rainfall",month,"min")
    	    Set max=^||myvar("rainfall",month,"max")
    	    Set rainfall=min + ($RANDOM(max*100)+1)/100	


    	    Set record.MonthAndYear=$ZDATEH(datestring,3)
	        Set record.InchesOfRain=rainfall
	        Set status=record.%Save()
            If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
		   }
	   }
	   
    }
     
    Do ##class(%DeepSee.Utils).%SynchronizeCube("cityrainfall")

    Quit status
}

Storage Default
{
<Data name="CityRainfallDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>City</Value>
</Value>
<Value name="3">
<Value>MonthAndYear</Value>
</Value>
<Value name="4">
<Value>InchesOfRain</Value>
</Value>
</Data>
<DataLocation>^DeepSee.Study.CityRainfallD</DataLocation>
<DefaultData>CityRainfallDefaultData</DefaultData>
<IdLocation>^DeepSee.Study.CityRainfallD</IdLocation>
<IndexLocation>^DeepSee.Study.CityRainfallI</IndexLocation>
<StreamLocation>^DeepSee.Study.CityRainfallS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

