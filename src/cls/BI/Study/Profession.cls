/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// This class contains the professions and their industries.
Class BI.Study.Profession Extends %Persistent
{

Property Profession As %String;

Property Industry As %String;

/// Used by Setup method. The format of <row> is: 
/// industry^profession
/// Industries taken from http://www.census.gov/epcd/susb/latest/us/US--.HTM 
/// Only a few industries and professions are included.
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
   set status=$$$OK
   
   // First kill extent
   // Never use %KillExtent() in a real application
   do ..%KillExtent()
   
   // Get a stream of XML from the XData block contained in this class
   set tStream=##class(%Dictionary.CompiledXData).IDKEYOpen($CLASSNAME(),"LoadData").Data
   if '$IsObject(tStream) {set tSC=%objlasterror Quit}
   
   set status=##class(%XML.TextReader).ParseStream(tStream,.textreader)
   
   // Check status
   if $$$ISERR(status) {do $System.Status.DisplayError(status) Quit}
   
   set count=0
   
   // Iterate through document, node by node
   while textreader.Read()
   {
       if (textreader.NodeType="chars")
       {
           set value=textreader.Value
           // write !, "value is: ", value
           set obj=..%New()
           set obj.Industry=$Piece(value,"^",1)
           set obj.Profession=$Piece(value,"^",2)
           set status=obj.%Save()
           if $$$ISERR(status) {do $System.Status.DisplayError(status) Quit}
           set count=count+1
           }
   }

   // Create an "extent set" from which we can later get random IDs
   set status=##class(BI.Populate).UpdateIdCache($CLASSNAME())

   quit status
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
<Type>%Storage.Persistent</Type>
}

}

