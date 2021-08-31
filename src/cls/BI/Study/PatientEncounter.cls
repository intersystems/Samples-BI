/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// A patient can have multiple encounters 
/// (interactions with a medical professional). The encounter data here is minimal, but you 
/// can create dimensions/levels based on the number of encounters a patient has, as well as 
/// on the attending physician for those encounters. 
/// This table is populated only if you use the E option when running the GenerateData() 
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

    set encNo=100 ; starting value

    set encountercount=..GetRandomEncounterCount(pat.Age) 	
    
    set patnumber=$PIECE(pat.PatientID,"_",2)   ; get number part from this string
    for i=1:1:encountercount {
        set encounter=##class(BI.Study.PatientEncounter).%New()
        set encounter.Patient=pat
        set encounter.EncounterNumber=patnumber_"-"_encNo

        set docid=##class(BI.Populate).GetRandomId("BI.Study.Doctor")
        set encounter.PrimaryDoctor=##class(BI.Study.Doctor).%OpenId(docid,0)
        set encounter.EncounterType=..GetRandomEncounterType()

        set status=encounter.%Save()
        set encNo=encNo+1
        }
    quit status
}

/// Iterate through patients and add encounters randomly to some percentage.
/// if rebuild is 1, this method updates the BI indices for each patient 
/// affectedby these changes. 
ClassMethod AddEncounters(percent As %Numeric = 20, rebuild As %Boolean = 1) As %Status
{
    set ^BI.Study.Log($I(^BI.Study.Log))=$zdatetime($h,2,3)_" Adding encounters..."

    // Create or update the "ID extent sets" from which we can later get random IDs
    set status=##class(BI.Populate).UpdateIdCache("BI.Study.Patient")
    set status=##class(BI.Populate).UpdateIdCache("BI.Study.Doctor")

    set patcount=##class(BI.Populate).Count("BI.Study.Patient")
    set changecount=0
    
    // First check to see if we have any encounter data; if we don't, we can add
    // encounters more quickly
    set myquery="SELECT Count(*) as ENCCOUNT FROM BI_Study.PatientEncounter"
    set rset=##class(%ResultSet).%New("%DynamicQuery:SQL")
    set status=rset.Prepare(myquery)
    if $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
    set status=rset.Execute()
    if $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
    set enccount=0
    while rset.Next() {
        set enccount=rset.Data("ENCCOUNT")
        }
    
    // Roll the dice as many times as we have patients; this is not the same
    // as iterating through the patients but does provide similar coverage
    for i=1:1:patcount    
    {
        if ##class(BI.Populate).RandomTrue(percent) 
        {
            set changecount=changecount+1
            set id=##class(BI.Populate).GetRandomId("BI.Study.Patient")
            set pat=##class(BI.Study.Patient).%OpenId(id,0)
            set patID=pat.%Id() ; use when querying extent
            
            // If we already have encounter data, we must 
            // get highest number encounter for this patient, if any
            if (enccount>0) {
	            set myquery="SELECT EncounterNumber FROM BI_Study.PatientEncounter WHERE Patient=? ORDER BY EncounterNumber"
                set rset=##class(%ResultSet).%New("%DynamicQuery:SQL")
                set status=rset.Prepare(myquery)
                if $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
                set status=rset.Execute(patID)
                if $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
                set result=""
                while rset.Next() {
                    set result=rset.Data("EncounterNumber")
                    }
                if (result'="") {
	            set highestencno=result
                    set encNo=$PIECE(highestencno,"-",2) + 1    ; increment by 1 from what's there
                 } else {
	             // This patient has no encounters yet
	             set encNo=100
	         }
                } else {
	           set encNo=100
	        }
                   
            // Number of encounters to add
            set encountercount=$RANDOM(2)+1   ; ADD 1 or 2 encounters
            
            // Base part for encounter number
            set patnumber=$PIECE(pat.PatientID,"_",2)   ; get number part from this string

            for j=1:1:encountercount {
                set encounter=##class(BI.Study.PatientEncounter).%New()
                set encounter.Patient=pat
                set encounter.EncounterNumber=patnumber_"-"_encNo
                set docid=##class(BI.Populate).GetRandomId("BI.Study.Doctor")
                set encounter.PrimaryDoctor=##class(BI.Study.Doctor).%OpenId(docid,0)
                set encounter.EncounterType=..GetRandomEncounterType()

                set status=encounter.%Save()
                set encNo=encNo+1
                }

            if rebuild {
                // Because the BI.Study.Patient table is unaware of the BI.Study.PatientEncounter
                // table, changing info in BI.Study.PatientEncounter does NOT fire any triggers for
                // the patients, so it is necessary to update the indices for those patients
                set id=pat.%Id()

                Do ##class(%DeepSee.Utils).%ProcessFact("patients",id)
             }
            }
        }
    set ^BI.Study.Log($I(^BI.Study.Log))=$zdatetime($h,2,3)_" Added encounters for "_changecount_" patients"
    // If rebuild {Kill %this}	; needed because zzBuildOne doesn't clean this up
    quit $$$OK
}

/// Clear out records in PatientEncounter; called when you delete patients.
ClassMethod DeleteEncounters(pat As BI.Study.Patient) As %Status
{
    set patid=pat.%Id()
    set myquery="DELETE FROM BI_Study.PatientEncounter WHERE Patient=?"
    set rset=##class(%ResultSet).%New("%DynamicQuery:SQL")
    set status=rset.Prepare(myquery)
    if $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
    set status=rset.Execute(patid)
    quit status
}

ClassMethod GetRandomEncounterType() As %String
{
    if ##class(BI.Populate).RandomTrue(5) {
	 quit "Emergency"   
    }  elseif ##class(BI.Populate).RandomTrue(30) {
	 quit "Outpatient"
    }  else {
	 quit "Inpatient"
    }
}

ClassMethod GetRandomEncounterCount(age As %Numeric) As %Integer
{
    set factor=(age+1)*1.5
    set count=3 + $RANDOM(20) + $RANDOM(factor)
    quit count
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
<DataLocation>^BI.Study.PatientEncounterD</DataLocation>
<DefaultData>PatientEncounterDefaultData</DefaultData>
<IdLocation>^BI.Study.PatientEncounterD</IdLocation>
<IndexLocation>^BI.Study.PatientEncounterI</IndexLocation>
<StreamLocation>^BI.Study.PatientEncounterS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

