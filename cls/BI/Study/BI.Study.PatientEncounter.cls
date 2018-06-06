/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// <p>This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// <p>A patient can have multiple encounters 
/// (interactions with a medical professional). The encounter data here is minimal, but you 
/// can create dimensions/levels based on the number of encounters a patient has, as well as 
/// on the attending physician for those encounters. 
/// <p>This table is populated only if you use the E option when running the GenerateData() 
/// method in BI.Populate. You can also use the AddEncounters() method 
/// of this class to add encounters to existing patients.
Class BI.Study.PatientEncounter Extends %Persistent
{

Property Patient As BI.Study.Patient;

Property EncounterNumber As %String;

Property PrimaryDoctor As BI.Study.Doctor;

Property EncounterType As %String;

/// Called by BI.Study.Patient:AddPatients().
ClassMethod CreateEncounters(pat As BI.Study.Patient) As %Status
{

    Set encNo=100 ; starting value

    Set encountercount=..GetRandomEncounterCount(pat.Age) 	
    
    Set patnumber=$PIECE(pat.PatientID,"_",2)   ; get number part from this string
    For i=1:1:encountercount {
        Set encounter=##class(BI.Study.PatientEncounter).%New()
        Set encounter.Patient=pat
        Set encounter.EncounterNumber=patnumber_"-"_encNo

        Set docid=##class(BI.Populate).GetRandomId("BI.Study.Doctor")
        Set encounter.PrimaryDoctor=##class(BI.Study.Doctor).%OpenId(docid,0)
        Set encounter.EncounterType=..GetRandomEncounterType()

        Set status=encounter.%Save()
        Set encNo=encNo+1
        }
    Quit status
}

/// Iterate through patients and add encounters randomly to some percentage.
/// If rebuild is 1, this method updates the BI indices for each patient 
/// affectedby these changes. 
ClassMethod AddEncounters(percent As %Numeric = 20, rebuild As %Boolean = 1) As %Status
{
    Set ^BI.Study.Log($I(^BI.Study.Log))=$zdatetime($h,2,3)_" Adding encounters..."

    //create or update the "ID extent sets" from which we can later get random IDs
    Set status=##class(BI.Populate).UpdateIdCache("BI.Study.Patient")
    Set status=##class(BI.Populate).UpdateIdCache("BI.Study.Doctor")

    Set patcount=##class(BI.Populate).Count("BI.Study.Patient")
    Set changecount=0
    
    //first check to see if we have any encounter data; if we don't, we can add
    //encounters more quickly
    Set myquery="SELECT Count(*) as ENCCOUNT FROM BI_Study.PatientEncounter"
    Set rset=##class(%ResultSet).%New("%DynamicQuery:SQL")
    Set status=rset.Prepare(myquery)
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
    Set status=rset.Execute()
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
    Set enccount=0
    While rset.Next() {
        Set enccount=rset.Data("ENCCOUNT")
        }
    
    //roll the dice as many times as we have patients; this is not the same
    //as iterating through the patients but does provide similar coverage
    For i=1:1:patcount    
    {
        If ##class(BI.Populate).RandomTrue(percent) 
        {
            Set changecount=changecount+1
            Set id=##class(BI.Populate).GetRandomId("BI.Study.Patient")
            Set pat=##class(BI.Study.Patient).%OpenId(id,0)
            Set patID=pat.%Id() ; use when querying extent
            
            //if we already have encounter data, we must 
            //get highest number encounter for this patient, if any
            If (enccount>0) {
	            Set myquery="SELECT EncounterNumber FROM BI_Study.PatientEncounter WHERE Patient=? ORDER BY EncounterNumber"
                Set rset=##class(%ResultSet).%New("%DynamicQuery:SQL")
                Set status=rset.Prepare(myquery)
                If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
                Set status=rset.Execute(patID)
                If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
                Set result=""
                While rset.Next() {
                    Set result=rset.Data("EncounterNumber")
                    }
                If (result'="") {
	            Set highestencno=result
                    Set encNo=$PIECE(highestencno,"-",2) + 1    ; increment by 1 from what's there
                 } Else {
	             //this patient has no encounters yet
	             Set encNo=100
	         }
                } Else {
	           Set encNo=100
	        }
                   
            //number of encounters to add
            Set encountercount=$RANDOM(2)+1   ; ADD 1 or 2 encounters
            
            //base part for encounter number
            Set patnumber=$PIECE(pat.PatientID,"_",2)   ; get number part from this string

            For j=1:1:encountercount {
                Set encounter=##class(BI.Study.PatientEncounter).%New()
                Set encounter.Patient=pat
                Set encounter.EncounterNumber=patnumber_"-"_encNo
                Set docid=##class(BI.Populate).GetRandomId("BI.Study.Doctor")
                Set encounter.PrimaryDoctor=##class(BI.Study.Doctor).%OpenId(docid,0)
                Set encounter.EncounterType=..GetRandomEncounterType()

                Set status=encounter.%Save()
                Set encNo=encNo+1
                }

            If rebuild {
                //Because the BI.Study.Patient table is unaware of the BI.Study.PatientEncounter
                //table, changing info in BI.Study.PatientEncounter does NOT fire any triggers for
                //the patients, so it is necessary to update the indices for those patients
                Set id=pat.%Id()

                Do ##class(%DeepSee.Utils).%ProcessFact("patients",id)
             }
            }
        }
    Set ^BI.Study.Log($I(^BI.Study.Log))=$zdatetime($h,2,3)_" Added encounters for "_changecount_" patients"
    //If rebuild {Kill %this}	; needed because zzBuildOne doesn't clean this up
    Quit $$$OK
}

/// Clear out records in PatientEncounter; called when you delete patients.
ClassMethod DeleteEncounters(pat As BI.Study.Patient) As %Status
{
    Set patid=pat.%Id()
    Set myquery="DELETE FROM BI_Study.PatientEncounter WHERE Patient=?"
    Set rset=##class(%ResultSet).%New("%DynamicQuery:SQL")
    Set status=rset.Prepare(myquery)
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
    Set status=rset.Execute(patid)
    Quit status
}

ClassMethod GetRandomEncounterType() As %String
{
    If ##class(BI.Populate).RandomTrue(5) {
	 Quit "Emergency"   
    }  Elseif ##class(BI.Populate).RandomTrue(30) {
	 Quit "Outpatient"
    }  Else {
	 Quit "Inpatient"
    }
}

ClassMethod GetRandomEncounterCount(age As %Numeric) As %Integer
{
    Set factor=(age+1)*1.5
    Set count=3 + $RANDOM(20) + $RANDOM(factor)
    Quit count
}

Index PatientIndex On Patient;

Storage Default
{
<Data name="PatientEncounterDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Patient</Value>
</Value>
<Value name="3">
<Value>EncounterNumber</Value>
</Value>
<Value name="4">
<Value>PrimaryDoctor</Value>
</Value>
<Value name="5">
<Value>EncounterType</Value>
</Value>
</Data>
<DataLocation>^BI.Study.PatientEncoB0D9D</DataLocation>
<DefaultData>PatientEncounterDefaultData</DefaultData>
<IdLocation>^BI.Study.PatientEncoB0D9D</IdLocation>
<IndexLocation>^BI.Study.PatientEncoB0D9I</IndexLocation>
<StreamLocation>^BI.Study.PatientEncoB0D9S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

