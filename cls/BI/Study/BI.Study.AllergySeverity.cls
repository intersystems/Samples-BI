/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// This class contains the allergy severity lookup table.
/// You can extend or modify the data contained here by editing the XData block in this class. 
Class BI.Study.AllergySeverity Extends %Persistent
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
/// This method is called by BI.Populate:GenerateData().
ClassMethod Setup() As %Status
{
   set status=$$$OK
   // First kill extent
   // Never use %KillExtent() in a real application
   Do ..%KillExtent()
   
   // Get a stream of XML from the XData block contained in this class
   set tStream=##class(%Dictionary.CompiledXData).IDKEYOpen($CLASSNAME(),"LoadData").Data
   if '$IsObject(tStream) {set tSC=%objlasterror Quit}
   
   set status=##class(%XML.TextReader).ParseStream(tStream,.textreader)
   
   // Check status
   if $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
   
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
           if $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
           }
   }

   set status=##class(BI.Populate).UpdateIdCache($CLASSNAME())

   quit status
}

}

