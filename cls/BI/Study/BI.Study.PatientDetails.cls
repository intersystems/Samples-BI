/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// <p>This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// It represents an additional table of data,
/// perhaps entered by a separate research team, and its only connection to
/// BI.Study.Patient is that both tables have the same PatientID field. Thus to use
/// fields of this table as BI dimensions/levels, it is necessary to use an SQL query
/// in the dimension definition. 
/// <p>This table is populated only if you use the T option when running the
/// GenerateData() method in BI.Populate.
Class BI.Study.PatientDetails Extends %Persistent
{

Property PatientID As %String;

Property Profession As BI.Study.Profession;

Property FavoriteColor As %String;

/// This index is meant to improve performance when the BI indices are built. 
/// The BI data model for BI.Study.Patient uses an SQL query that refers 
/// to PatientID.
Index PatientIDIndex On PatientID [ Unique ];

/// Called by BI.Study.Patient:AddPatients().
ClassMethod CreatePatientDetails(PatientID As %String, age As %Numeric = 35, genNulls As %Boolean) As %Status
{
    Set status=$$$OK
    Set patdetails=##class(PatientDetails).%New()
    Set patdetails.PatientID=PatientID

    //get random color
    Set colorlist=$LB("Red","Blue","Green","Purple","Yellow","Orange")
    Set colorid=$RANDOM($LISTLENGTH(colorlist))+1
    Set patdetails.FavoriteColor=$LI(colorlist,colorid)

    If ((age>17) && (age<70)) 
    {
        //not everyone in this age range is employed
        If ##class(BI.Populate).RandomTrue(87){
            //get random profession
            Set profid=##class(BI.Populate).GetRandomId("BI.Study.Profession")
            Set patdetails.Profession=##class(BI.Study.Profession).%OpenId(profid,0)
            }
        }
                
    If 'genNulls
    {
        //If genNulls is off, save details in all cases
        Set status=patdetails.%Save()
        If $$$ISERR(status) {Do $System.Status.DisplayError(status) Write !, "Details error"}
        }
        Else 
        {
            //If genNulls is on, roll the dice and 
            //save the details only some of the time
            If ##class(BI.Populate).RandomTrue(76)
            {
                Set status=patdetails.%Save()
                If $$$ISERR(status) {Do $System.Status.DisplayError(status) Write !, "Patient details save error"}
                }
   }
   
   Quit status
}

/// Iterate through patient extent and change color for some percentage of patients.
/// If rebuild is 1, this method updates the BI indices for each patient 
/// affected by these changes. 
ClassMethod ChangePatientDetails(percent As %Numeric = 10, rebuild As %Boolean = 1)
{
    Set ^BI.Study.Log($I(^BI.Study.Log))=$zdatetime($h,2,3)_" Changing some patient details..."

    //create or update the "ID extent sets" from which we can later get random IDs
    Set status=##class(BI.Populate).UpdateIdCache($CLASSNAME())

    Set recordcount=##class(BI.Populate).Count($CLASSNAME())
    Set changecount=0
    
    Set colorlist=$LB("Red","Blue","Green","Purple","Yellow","Orange")
    
    For i=1:1:recordcount 
    {
        If ##class(BI.Populate).RandomTrue(percent) 
        {
            Set colorid=$RANDOM($LISTLENGTH(colorlist))+1

            Set randomid=##class(BI.Populate).GetRandomId($CLASSNAME())
            Set patdetails=..%OpenId(randomid)
            Set patdetails.FavoriteColor=$LI(colorlist,colorid)
            Do patdetails.%Save()
            Set changecount=changecount+1   
            
            If rebuild {
                //Because the BI.Study.Patient table is unaware of the BI.Study.PatientDetails
                //table, changing info in PatientDetails does NOT fire any triggers for
                //the patients, so it is necessary to figure out which patients are 
                //affected and update the indices for those patients
            
                Set patID=patdetails.PatientID
            
                Set myquery="SELECT ID FROM BI_Study.Patient WHERE PatientID=?"
                Set rset=##class(%ResultSet).%New("%DynamicQuery:SQL")
                Set status=rset.Prepare(myquery)
                If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
                Set status=rset.Execute(patID)
                If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
                While rset.Next() {
                    Set id=rset.Data("ID")

                    Do ##class(%DeepSee.Utils).%ProcessFact("patients",id)

                }
                Kill rset              
               
            }
          }
        }
        If rebuild {Kill %this} ; needed because zzBuildOne doesn't clean this up
        Set ^BI.Study.Log($I(^BI.Study.Log))=$zdatetime($h,2,3)_" Details changed for "_ changecount _" patients"
}

/// Clear out patient details
ClassMethod DeletePatientDetails(PatientID As %String) As %Status
{
            
    Set myquery="DELETE FROM BI_Study.PatientDetails WHERE PatientID=?"
    Set rset=##class(%ResultSet).%New("%DynamicQuery:SQL")
    Set status=rset.Prepare(myquery)
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
    Set status=rset.Execute(PatientID)
    Quit status
}

Storage Default
{
<Data name="PatientDetailsDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>PatientID</Value>
</Value>
<Value name="3">
<Value>Profession</Value>
</Value>
<Value name="4">
<Value>FavoriteColor</Value>
</Value>
</Data>
<DataLocation>^BI.Study.PatientDetailsD</DataLocation>
<DefaultData>PatientDetailsDefaultData</DefaultData>
<IdLocation>^BI.Study.PatientDetailsD</IdLocation>
<IndexLocation>^BI.Study.PatientDetailsI</IndexLocation>
<StreamLocation>^BI.Study.PatientDetailsS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

