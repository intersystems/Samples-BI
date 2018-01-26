/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// <p>Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// <p>This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// <p>This class contains the professions and their industries.
Class BI.Study.Profession Extends %Persistent
{

Property Profession As %String;

Property Industry As %String;

/// Used by Setup method. The format of <row> is: 
/// <pre>industry^profession</pre>
/// <p>
/// Industries taken from http://www.census.gov/epcd/susb/latest/us/US--.HTM 
/// <p>Only a few industries and professions are included.
XData LoadData
{
<table>
 <row>Accommodation and Food Services^Baker</row>
 <row>Accommodation and Food Services^Cook</row>
 <row>Construction^Electrician</row>
 <row>Construction^Carpenter</row>
 <row>Construction^Plumber</row>
 <row>Educational Services^Teacher</row>
 <row>Educational Services^Corporate Trainer</row>
 <row>Finance and Insurance^Insurance Agent</row>
 <row>Finance and Insurance^Bank Teller</row>
 <row>Finance and Insurance^Benefits Coordinator</row>
 <row>Health Care and Social Assistance^Doctor</row>
 <row>Health Care and Social Assistance^Nurse</row>
 <row>Professional, Scientific, and Technical Services^Veterinarian</row>
 <row>Professional, Scientific, and Technical Services^Programmer</row>
 <row>Professional, Scientific, and Technical Services^Architect</row>
 <row>Professional, Scientific, and Technical Services^Accountant</row>
 <row>Real Estate and Leasing^Real Estate Agent</row>
 <row>Retail Trade^Retail Clerk</row>
 <row>Retail Trade^Store Manager</row>
 <row>Transportation and Warehousing^Truck Driver</row>
 <row>Transportation and Warehousing^Warehouse Manager</row>
 <row>Other Services^Appliance Repair Specialist</row>
 <row>Other Services^Other</row>
 </table>
}

/// This method reads the XData block in this class and uses it to populate the table. 
/// This method is called by BI.Populate:GenerateData().
ClassMethod Setup() As %Status
{
   Set status=$$$OK
   //first kill extent
   //never use %KillExtent() in a real application
   Do ..%KillExtent()
   
   // Get a stream of XML from the XData block contained in this class
   Set tStream=##class(%Dictionary.CompiledXData).IDKEYOpen($CLASSNAME(),"LoadData").Data
   If '$IsObject(tStream) {Set tSC=%objlasterror Quit}
   
   Set status=##class(%XML.TextReader).ParseStream(tStream,.textreader)
   //check status
   If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
   
   Set count=0
   //iterate through document, node by node
   While textreader.Read()
   {
       If (textreader.NodeType="chars")
       {
           Set value=textreader.Value
           //write !, "value is: ", value
           Set obj=..%New()
           Set obj.Industry=$Piece(value,"^",1)
           Set obj.Profession=$Piece(value,"^",2)
           Set status=obj.%Save()
           If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
           Set count=count+1
           }
   }

   //create an "extent set" from which we can later get random IDs
   Set status=##class(BI.Populate).UpdateIdCache($CLASSNAME())

   Quit status
}

Storage Default
{
<Data name="ProfessionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Profession</Value>
</Value>
<Value name="3">
<Value>Industry</Value>
</Value>
</Data>
<DataLocation>^BI.Study.ProfessionD</DataLocation>
<DefaultData>ProfessionDefaultData</DefaultData>
<IdLocation>^BI.Study.ProfessionD</IdLocation>
<IndexLocation>^BI.Study.ProfessionI</IndexLocation>
<StreamLocation>^BI.Study.ProfessionS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

