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

/// fields: postal code^city^city population^principal export
/// there are multiple cities in most postal codes
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
ClassMethod Setup() As %Status
{
   Set status=$$$OK
   //first kill extent and child extent
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
           //write !, "value is: ", value
           Set obj=..%New()
           Set obj.PostalCode=$Piece(value,"^",1)
           Set obj.Name=$Piece(value,"^",2)
           Set obj.Population=$Piece(value,"^",3)
           Set obj.PrincipalExport=$Piece(value,"^",4)
           Set status=obj.%Save()
           If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
           }
   }

   //create an "extent set" from which we can later get random IDs
   Set status=##class(BI.Populate).UpdateIdCache($CLASSNAME())
   
   Quit status
}

Storage Default
{
<Data name="CityDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>PostalCode</Value>
</Value>
<Value name="3">
<Value>Name</Value>
</Value>
<Value name="4">
<Value>Population</Value>
</Value>
<Value name="5">
<Value>PrincipalExport</Value>
</Value>
</Data>
<DataLocation>^BI.Study.CityD</DataLocation>
<DefaultData>CityDefaultData</DefaultData>
<IdLocation>^BI.Study.CityD</IdLocation>
<IndexLocation>^BI.Study.CityI</IndexLocation>
<StreamLocation>^BI.Study.CityS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

