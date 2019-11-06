/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// This class contains the allergen code lookup table. 
/// You can extend or modify the data contained here by editing the XData block in this class. 
Class BI.Study.Allergen Extends %Persistent
{

/// Unique code for the allergen
Property Code As %String;

/// Unique description (user-visible name) for the allergen
Property Description As %String;

/// Format: code^description 
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
   set status=$$$OK
   // First kill extent
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
           //write !, "value is: ", value
           set obj=..%New()
           set obj.Code=$Piece(value,"^",1)
           set obj.Description=$Piece(value,"^",2)
           set status=obj.%Save()
           if $$$ISERR(status) {do $System.Status.DisplayError(status) quit}
           }
   }
   quit status
}
}

