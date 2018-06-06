/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// <p>This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// This class contains the diagnosis code lookup table, with a small set of possible
/// diagnoses. It also defines the incidence rates for these diagnoses, by age and gender.
/// <p>
/// You can extend or modify the data contained here by editing the XData block in this class.
/// <p>
/// Use the GetPercentChance() method to retrieve the chance of having
/// a specific diagnosis, given an age and gender.
Class BI.Study.Diagnosis Extends %Persistent
{

/// Unique code for the diagnosis;
Property Code As %String;

/// Unique description (user-visible name) for the diagnosis
Property Description As %String;

/// A row element is a pieced string with the following format:
/// <pre>diagnosis code^diagnosis description^fpiece^mpiece </pre>
/// fpiece gives rates for females, and mpiece gives rates for males.
/// Both fpiece and mpiece have the following format:
/// <pre>bucket1 details,bucket2 details,bucket3 details, ... </pre>
/// Each bucket represents an age bucket and the number of current (not lifetime)
/// diagnoses of this type per hundred patients of this age and gender.
/// Each bucket has the following format:
/// <pre>lowerAge_upperAge_countPerHundredPatientsOfThisAgeAndGender</pre>
/// Each row must have data for all ages for patients of either gender.
/// <ul>
/// <li>asthma source: ASTHMA06FINAL.PDF from www.lungusa.org/atf/cf/</li>
/// <li>CHD: www.heartstats.org (used numbers for 1998)</li>
/// <li>diabetes: www.mchd.com/data_reports/mccha/12_Morbidity_and_Hospitalizations.html (Used U.S. values)</li>
/// <li>osteoporosis source: http://www.surgeongeneral.gov/library/bonehealth/ (No data for patients under 65)</li>
/// <li>epilepsy: wikipedia (55 cases per 100000 people)</li>
/// </ul>
/// 
XData LoadData
{
<table>
 <row>diabetes^diabetes
 ^0_17_0, 18_24_1.5, 25_34_3.2, 35_44_5.2, 45_54_7.9, 55_64_13.4, 65_999_17.1
 ^0_17_0, 18_24_1.5, 25_34_3.2, 35_44_5.2, 45_54_7.9, 55_64_13.4, 65_999_17.1
 </row>
 <row>asthma^asthma
 ^0_17_06.71, 18_999_8.25
 ^0_17_10.15, 18_999_4.97
 </row>
 <row>CHD^coronary heart disease
 ^0_15_0, 16_24_0,  25_34_.3, 35_44_.6, 45_54_1.8, 55_64_6.3,  65_74_12.5, 75_999_18.4
 ^0_15_0, 16_24_.1, 25_34_.4, 35_44_.9, 45_54_4.3, 55_64_13.6, 65_74_20.2, 75_999_23.4
  </row>
<row>osteoporosis^osteoporosis
 ^0_64_0, 65_74_19.0, 75_84_32.5, 85_999_50.5
 ^0_64_0, 65_74_02.0, 75_84_06.4, 85_999_13.7
  </row>
<row>epilepsy^epilepsy
 ^0_999_.00055
 ^0_999_.00055
</row>
</table>
}

/// This method reads the XData block in this class and uses it to populate the table. 
/// This method is called by BI.Populate:GenerateData().
/// It also writes related data to a global for use when creating patients.
/// The diagnosis incidence rates are deliberately NOT put into a table where
/// BI can access them. The idea of the sample is to simulate real-life
/// patterns. 
ClassMethod Setup() As %Status
{
   Set status=$$$OK
   //first kill extent and related global
   //never use %KillExtent() in a real application
   Do ..%KillExtent()
   Kill ^BI.Study.SetupData("diagnoses")
   
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
           Set obj=..%New()
           Set diagcode=$Piece(value,"^",1) ;use this below in multiple places
           Set obj.Code=diagcode
           Set obj.Description=$Piece(value,"^",2)
           Set status=obj.%Save()
           If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
           
           //now set global to contain occurrence rates by gender and age
           Set fpiece=$ZSTRIP($Piece(value,"^",3),"*CW")    ; strip out line feed & white space
           Set mpiece=$ZSTRIP($Piece(value,"^",4),"*CW")    ; strip out line feed & white space
           
           Set ^BI.Study.SetupData("diagnoses",diagcode,"F")=fpiece
           Set ^BI.Study.SetupData("diagnoses",diagcode,"M")=mpiece
           }
               
       }

   Quit status
}

/// For use when generating data; called by Setup method.
/// Can also use this at the command line for testing purposes.
ClassMethod GetPercentChance(code As %String, gender As %String, age As %Numeric) As %Numeric
{
    //get appropriate global node & convert it to a list
    Set list=$LISTFROMSTRING(^BI.Study.SetupData("diagnoses",code,gender))
    
    Set chance=0
    // iterate through list and find appropriate bucket
    for i=1:1:$LISTLENGTH(list) {
        //get list item and its upper and lower ages
        Set item=$LISTGET(list,i)
        Set itemlowerage=+$Piece(item,"_",1)
        Set itemupperage=+$Piece(item,"_",2)

        If ((age>itemlowerage) && (age<=itemupperage)) {
            Set chance=$Piece(item,"_",3)
            }
        }
    
    Quit chance
}

Storage Default
{
<Data name="DiagnosisDefaultData">
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
<DataLocation>^BI.Study.DiagnosisD</DataLocation>
<DefaultData>DiagnosisDefaultData</DefaultData>
<IdLocation>^BI.Study.DiagnosisD</IdLocation>
<IndexLocation>^BI.Study.DiagnosisI</IndexLocation>
<StreamLocation>^BI.Study.DiagnosisS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

