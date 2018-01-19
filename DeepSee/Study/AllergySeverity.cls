/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the DeepSee Patients sample, whose purpose is to provide
/// sample data for use with DeepSee. 
/// <p>This class contains the allergy severity lookup table.
/// <p>You can extend or modify the data contained here by editing the XData block in this class. 
Class DeepSee.Study.AllergySeverity Extends %Persistent
{

/// Unique code for the allergy severity
Property Code As %String;

/// Unique description (user-visible name) for the allergy severity
Property Description As %String;

XData LoadData
{
<table>
 <row>001^Minor</row>
 <row>002^Moderate</row>
 <row>003^Life-threatening</row>
 <row>009^Inactive</row>
 <row>099^Unable to determine</row>
</table>
}

/// This method reads the XData block in this class and uses it to populate the table. 
/// This method is called by DeepSee.Populate:GenerateData().
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
   
   //iterate through document, node by node
   While textreader.Read()
   {
       If (textreader.NodeType="chars")
       {
           Set value=textreader.Value
           //write !, "value is: ", value
           Set obj=..%New()
           Set obj.Code=$Piece(value,"^",1)
           Set obj.Description=$Piece(value,"^",2)
           Set status=obj.%Save()
           If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
           }
   }

   Set status=##class(DeepSee.Populate).UpdateIdCache($CLASSNAME())

   Quit status
}

Storage Default
{
<Data name="AllergySeverityDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Code</Value>
</Value>
<Value name="3">
<Value>Description</Value>
</Value>
</Data>
<DataLocation>^DeepSee.Study.AllergySeverityD</DataLocation>
<DefaultData>AllergySeverityDefaultData</DefaultData>
<IdLocation>^DeepSee.Study.AllergySeverityD</IdLocation>
<IndexLocation>^DeepSee.Study.AllergySeverityI</IndexLocation>
<StreamLocation>^DeepSee.Study.AllergySeverityS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

