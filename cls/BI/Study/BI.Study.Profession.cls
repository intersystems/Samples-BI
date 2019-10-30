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
 <row>Health Care and Social Assistance^do ctor</row>
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
   do  ..%KillExtent()
   
   // Get a stream of XML from the XData block contained in this class
   set tStream=##class(%Dictionary.CompiledXData).IDKEYOpen($CLASSNAME(),"LoadData").Data
   if '$IsObject(tStream) {set tSC=%objlasterror Quit}
   
   set status=##class(%XML.TextReader).ParseStream(tStream,.textreader)
   
   // Check status
   if $$$ISERR(status) {do  $System.Status.DisplayError(status) Quit}
   
   set count=0
   
   // Iterate through do cument, node by node
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
           if $$$ISERR(status) {do  $System.Status.DisplayError(status) Quit}
           set count=count+1
           }
   }

   // Create an "extent set" from which we can later get rando m IDs
   set status=##class(BI.Populate).UpdateIdCache($CLASSNAME())

   quit status
}

}

