/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// <p>This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// <p>This class contains the rainfall for the cities, by year and month, and is meant
/// for use as an additional BI model/cube.
/// <p>This table is populated only if you use the R option when running the 
/// GenerateData() method in BI.Populate. You can also use
/// the GenerateData() method in this class if you have already populated the main
/// sample.
/// <p>
/// You can extend or modify the data contained here by editing the XData block in this class.
Class BI.Study.CityRainfall Extends %Persistent
{

/// This parameter setting enables the DSTIME feature for InterSystems IRIS BI
Parameter DSTIME = "AUTO";

Property City As BI.Study.City;

Property MonthAndYear As %Date;

Property InchesOfRain As %Numeric;

/// Fields: month number^average rainfall in inches^variance in inches
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
    write !, "Creating rainfall data for the cities..."
    
    // Never use %KillExtent() in a real application
    do ..%KillExtent()

    // Get a stream of XML from the XData block contained in this class
    set tStream=##class(%Dictionary.CompiledXData).IDKEYOpen($CLASSNAME(),"LoadData").Data
    if '$IsObject(tStream) {set tSC=%objlasterror quit}
   
    set status=##class(%XML.TextReader).ParseStream(tStream,.textreader)
    //check status
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit}
   
    //iterate through document, node by node
    while textreader.Read()
    {
        if (textreader.NodeType="chars")
        {
            set value=textreader.Value

            set month=$Piece(value,"^",1)
            set avgrainfall=$Piece(value,"^",2)
            set var=$Piece(value,"^",3)
            set ^||myvar("rainfall",month,"min")=avgrainfall-var
            set ^||myvar("rainfall",month,"max")=avgrainfall+var
            }
    }
   
    set myquery="select ID from BI_Study.City"
    set rset=##class(%Resultset).%New("%DynamicQuery:SQL")
    set status=rset.Prepare(myquery)
    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit}
    set status=rset.Execute()
    
    while (rset.Next(.status)) {
	    if $$$ISERR(status) {do $System.Status.DisplayError(status) quit}
	    set cityid=rset.Data("ID")
	    set city=##class(BI.Study.City).%OpenId(cityid,0)
	    	        
        //we have rainfall data for a particular span of years
        set separator=##class(%SYS.NLS.Format).GetFormatItem("DateSeparator")
        for year=1900:1:$Piece($Zdate($h,1),separator,3) {
	        for month=1:1:12 {
		        set record=..%New()
		   		set record.City=city
		   		if (month<10) {
			   		set monthstring="0"_month
			   		}
			   		else {
				   		set monthstring=month
				   		}
		    set datestring=year_"-"_monthstring_"-01"
    	    set min=^||myvar("rainfall",month,"min")
    	    set max=^||myvar("rainfall",month,"max")
    	    set rainfall=min + ($RANdoM(max*100)+1)/100	


    	    set record.MonthAndYear=$ZDATEH(datestring,3)
	        set record.InchesOfRain=rainfall
	        set status=record.%Save()
            if $$$ISERR(status) {do $System.Status.DisplayError(status) quit}
		   }
	   }
	   
    }
     
    do ##class(%DeepSee.Utils).%SynchronizeCube("cityrainfall")

    quit status
}
}

