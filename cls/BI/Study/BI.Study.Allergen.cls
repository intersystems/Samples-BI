/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// <p>This class contains the allergen code lookup table. 
/// <p>You can extend or modify the data contained here by editing the XData block in this class. 
Class BI.Study.Allergen Extends %Persistent
{

/// Unique code for the allergen
Property Code As %String;

/// Unique description (user-visible name) for the allergen
Property Description As %String;

/// Format: code^description <p>
/// The first row is special: this is the "allergen" that represents no known allergies.
/// We treat this one differently when creating patient allergens.
XData LoadData
{
<table>
 <row>000^nil known allergies</row>
 <row>001^additive/coloring agent</row>
 <row>002^animal dander</row>
 <row>003^ant bites</row>
 <row>004^bee stings</row>
 <row>005^dairy products</row>
 <row>006^dust mites</row>
 <row>007^eggs</row>
 <row>008^fish</row>
 <row>009^mold</row>
 <row>010^peanuts</row>
 <row>011^pollen</row>
 <row>012^shellfish</row>
 <row>013^soy</row>
 <row>014^tree nuts</row>
 <row>015^wheat</row>
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
   Quit status
}

Storage Default
{
<Data name="AllergenDefaultData">
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
<DataLocation>^BI.Study.AllergenD</DataLocation>
<DefaultData>AllergenDefaultData</DefaultData>
<IdLocation>^BI.Study.AllergenD</IdLocation>
<IndexLocation>^BI.Study.AllergenI</IndexLocation>
<StreamLocation>^BI.Study.AllergenS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

