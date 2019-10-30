/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// <p>This class contains the cities and the ZIP codes to which they belong, as
/// well as city-specific properties to use as level properties in BI.
/// <p>You can extend or modify the data contained here by editing the XData block in this class. 
Class BI.Study.City Extends %Persistent
{

Property PostalCode As %String;

Property Name As %String;

Property Population As %Integer;

Property PrincipalExport As %String;

/// Fields: postal code^city^city population^principal export
/// There are multiple cities in most postal codes
XData LoadData
{
<table>
 <row>36711^Centerville^49000^video games</row>
 <row>34577^Cypress^3000^gravel</row>
 <row>34577^Magnolia^4503^bundt cake</row>
 <row>34577^Pine^15060^spaghetti</row>
 <row>38928^Cedar Falls^90000^iron</row>
 <row>38928^Elm Heights^33194^lettuce</row>
 <row>32006^Juniper^10333^wheat</row>
 <row>32006^Spruce^5900^mud</row>
 <row>32007^Redwood^29192^peaches</row>
</table>
}

/// This method reads the XData block in this class and uses it to populate the table. 
/// This method is called by BI.Populate:GenerateData().
ClassMethod setup() As %Status
{
   set status=$$$OK
   // First kill extent and child extent
   // Never use %KillExtent() in a real application
   do ..%KillExtent()

   // Get a stream of XML from the XData block contained in this class
   set tStream=##class(%Dictionary.CompiledXData).IDKEYOpen($CLASSNAME(),"LoadData").Data
   if '$IsObject(tStream) {set tSC=%objlasterror quit}
   
   set status=##class(%XML.TextReader).ParseStream(tStream,.textreader)
   
   // Check status
   if $$$ISERR(status) {do $System.Status.DisplayError(status) quit}
   
   // Iterate through document, node by node
   while textreader.Read()
   {
       if (textreader.NodeType="chars")
       {
           set value=textreader.Value
           // Write !, "value is: ", value
           set obj=..%New()
           set obj.PostalCode=$Piece(value,"^",1)
           set obj.Name=$Piece(value,"^",2)
           set obj.Population=$Piece(value,"^",3)
           set obj.PrincipalExport=$Piece(value,"^",4)
           set status=obj.%Save()
           if $$$ISERR(status) {do $System.Status.DisplayError(status) quit}
           }
   }

   // Create an "extent set" from which we can later get random IDs
   set status=##class(BI.Populate).UpdateIdCache($CLASSNAME())
   
   quit status
}
}

