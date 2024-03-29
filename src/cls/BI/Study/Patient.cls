/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
Class BI.Study.Patient Extends %Persistent
{

/// This parameter setting enables the DSTIME feature for InterSystems IRIS BI
Parameter DSTIME = "AUTO";

/// ID of this patient, as assigned within this fictitious study;
/// useful as a detail listing field.
Property PatientID As %String;

Property Gender As %String(DISPLAYLIST = ",Female,Male", VALUELIST = ",F,M");

Property Age As %Integer;

/// %Date version of the birth date.
/// This property contains same data as the BirthDateTimeStamp property. 
/// This class contains multiple birth date properties so that you can
/// try the supported data types.
Property BirthDate As %Date;

/// Birth time as %Time.
/// This class contains the birth time data in two properties (this property and 
/// BirthDateTimeStamp) so that you can try the time data in both formats.
Property BirthTime As %Time;

/// %TimeStamp version of the birth date.
/// This property contains same date as the BirthDate property. 
/// Also see BirthTime.
Property BirthDateTimeStamp As %TimeStamp;

/// %MV.Date version of the birth date.
/// This property contains same date as the BirthDateTimeStamp property. 
Property BirthDateMV As %MV.Date;

Property PrimaryCarePhysician As BI.Study.Doctor;

Property Allergies As list Of BI.Study.PatientAllergy;

/// Diagnoses of this patient. This class contains multiple versions of this property
/// each of which contains the same general diagnosis data. These versions enable you to
/// create BI dimensions on a variety of types of collections.
/// Use this variation to see how BI handles lists of objects.
Property Diagnoses As list Of BI.Study.PatientDiagnosis;

/// Use this variation to see how BI handles arrays.
/// See comments for the Diagnoses property.
Property DiagnosesAsArray As array Of %String;

/// Use this variation to see how BI handles $LB lists of strings.
/// See comments for the Diagnoses property.
Property DiagnosesAsLB As %List;

/// Use this variation to see how BI handles pieced strings.
/// See comments for the Diagnoses property.
Property DiagnosesAsString As %String;

/// Use this variation to see how BI handles parent-child relationships
/// See comments for the Diagnoses property.
Relationship DiagnosesAsChildren As BI.Study.PatientDiagnosis1 [ Cardinality = children, Inverse = Patient ];

/// Use this variation to see how BI handles one-to-many relationships
/// See comments for the Diagnoses property.
Relationship DiagnosesAsMany As BI.Study.PatientDiagnosis2 [ Cardinality = many, Inverse = Patient ];

Property HomeCity As BI.Study.City;

/// This property represents some grouping of the patients in this fictitious study.
/// Use this as a BI dimension.
Property PatientGroup As %String;

/// Value of some fictitious test; will use this as a measure; can be null.
/// When using as a measure, probably more suitable to average across the patients.
Property TestScore As %Integer;

/// Called by BI.Populate:GenerateData(); see the comments for that method.
ClassMethod GenerateData(patCount As %Integer = 500, options As %String = "ADET", genNulls As %Boolean = 1, genNullDates As %Boolean = 0) As %Status
{
    set status=$$$OK
    write !, "Deleting patient data..."

    // First kill extent and kill extents of child tables
    do ..%KillExtent()
    do ##class(BI.Study.PatientDiagnosis1).%KillExtent()
    do ##class(BI.Study.PatientDiagnosis2).%KillExtent()
    do ##class(BI.Study.PatientDetails).%KillExtent()
    do ##class(BI.Study.PatientEncounter).%KillExtent()
    do ##class(BI.Study.PatientAllergy1).%KillExtent()
   
    write !, "Adding patients..."
    set status=..AddPatients(patCount,options,genNulls,1,genNullDates)
    quit status
}

/// Called by GenerateData(); see the comments for that method.
/// Can also be called directly to add patients after the initial setup.
ClassMethod AddPatients(patCount As %Integer = 100, options As %String = "ADT", genNulls As %Boolean = 1, initSetup As %Boolean = 0, genNullDates As %Boolean = 0) As %Status
{
    if initSetup {Kill ^BI.Study.Log}
    set ^BI.Study.Log($I(^BI.Study.Log))=$zdatetime($h,2,3)_" Adding patients..."


    // Create or update the "ID extent sets" from which we can later get random IDs
    set status=##class(BI.Populate).UpdateIdCache("BI.Study.Doctor")
    set status=##class(BI.Populate).UpdateIdCache("BI.Study.City")

    
    // Check options; what do we need to generate?
    if ($FIND(options,"A")) {set generateallergies=1}
        else {set generateallergies=0}
    if ($FIND(options,"D")) {set generatediagnoses=1}
        else {set generatediagnoses=0}
    if ($FIND(options,"E")) {set generateencounters=1}
        else {set generateencounters=0}
    if ($FIND(options,"T")) {set generatedetails=1}
        else {set generatedetails=0}
    

    // Get diagnosis and current patient count
    set dcount=##class(BI.Populate).Count("BI.Study.Diagnosis")
    set currentpatcount=##class(BI.Populate).Count($CLASSNAME())
    
    // Initialize counters
    if (currentpatcount=0) {
        set initPat=100300
        }
        else {
            // Get highest PatientID in use
            set highest=..GetHighestPatientID()
            set initPat=$PIECE(highest,"_",2)
            }

    set idnumber=initPat

    for n = 1:1:patCount {
        set pat=##class(BI.Study.Patient).%New()
        set idnumber=idnumber+1     ; increment without any gaps
        set patid="SUBJ_"_idnumber
        set pat.PatientID=patid
        
        // Get age+gender combination
        set agegender=##class(BI.Populate).RandomGenderAndAge()
        set pat.Gender=$Piece(agegender,",",1)
        set pat.Age=$Piece(agegender,",",2)

        // Get birthdate as a string YYYY-MM-DD
        set birthdate=##class(BI.Populate).BirthDateODBC(pat.Age)
        set pat.BirthDate=$ZDATEH(birthdate,6)  ; convert to $h explicitly and write value
 
        // Get birthtime as random time hh:mm:ss
        set timestamp=##class(%PopulateUtils).TimeStamp()   
        set timepart=$Piece(timestamp," ",2)
        set timestring=$Piece(timepart,":",1)_":"_$Piece(timepart,":",2)
        set pat.BirthTime=$ZTIMEH(timestring,2) ; convert to $h and write value
 
        // Combine date and time
        set birthdateandtime=birthdate_" "_timepart
        set pat.BirthDateTimeStamp=birthdateandtime ; write in ODBC format 
    
        // Set MV version
        set pat.BirthDateMV = pat.BirthDate - 46385
    
        // Assign a doctor
        // Set docid=##class(BI.Populate).GetRandomId("BI.Study.Doctor")
        set docid=##class(BI.Study.Doctor).GetDoctorId(pat.Age,pat.Gender)
        do pat.PrimaryCarePhysicianSetObjectId(docid)

        // Null out this property randomly to simulate missing data
        if genNulls &&##class(BI.Populate).RandomTrue(5){
            set pat.PrimaryCarePhysician=""
        }

        // Assign to a patient group
        set grouplist=$LB("A","B")
        set groupID=$RANDOM($LISTLENGTH(grouplist))+1
        set pat.PatientGroup=$LI(grouplist,groupID)

        // Set TestScore property
        set pat.TestScore=50+$RANDOM(50)
        
        // Null out the previous two properties in some cases
        // Score can be null but won't be 0 (see above)
        // This lets us see how measures treat null values
        if (genNulls && ##class(BI.Populate).RandomTrue(20)){
            set pat.TestScore=""
            set pat.PatientGroup=""
            }
        
        // Select a city
        set cityid=##class(BI.Populate).GetRandomId("BI.Study.City")          
        set pat.HomeCity=##class(BI.Study.City).%OpenId(cityid,0)

        // If asked, update PatientDetails table
        if generatedetails {
            set status=##class(PatientDetails).CreatePatientDetails(pat.PatientID,pat.Age,genNulls)
            if $$$ISERR(status) {do $System.Status.DisplayError(status) write !, "Patient details error"}
            }
        
        // If asked, generate some allergies
        if generateallergies {
            set status=##class(BI.Study.PatientAllergy).GenerateAllergies(pat,genNulls)
            if $$$ISERR(status) {do $System.Status.DisplayError(status) write !, "Allergies insert error"}
            }
         
         // If asked, generate some diagnoses
         if generatediagnoses {
             // Iterate through available diagnoses, look up chance of patient's
             // receiving this diagnosis, based on gender & age
             // save diagnosis data in all diagnosis properties
             set diagnosiscount=0    ; initialize this so we know if we're on the first one
             set diaglist = ""
             set diagstring=""
             for k=1:1:dcount{
                 set potentialdiagnosis=##class(BI.Study.Diagnosis).%OpenId(k,0)

                 // Get the code
                 set code=potentialdiagnosis.Code
                 // Look up how likely this patient is to have this diagnosis
                 set chance=##class(BI.Study.Diagnosis).GetPercentChance(code,pat.Gender,pat.Age)
                
                 if ##class(BI.Populate).RandomTrue(chance) {
                     set diagnosiscount=diagnosiscount+1
                     set desc=potentialdiagnosis.Description
                                        
                     // Build basic diagnosis properties
                     set $LI(diaglist,diagnosiscount)=code 
                     set diagstring=diagstring_","_code
                     do pat.DiagnosesAsArray.SetAt(code,diagnosiscount)
                    
                     // Now for the more complex properties, choose a random diagnosing doctor
                     set diagdocid=##class(BI.Populate).GetRandomId("BI.Study.Doctor")
                     set diagdoc=##class(BI.Study.Doctor).%OpenId(diagdocid,0)

                     // Populate Diagnoses property
                     set patdiag=##class(BI.Study.PatientDiagnosis).%New()    ; this object is serial
                     set patdiag.DiagnosisCode=code
                     set patdiag.DiagnosedBy=diagdoc
                     set status=pat.Diagnoses.Insert(patdiag)
                     if $$$ISERR(status) {do $System.Status.DisplayError(status) write !, "Diagnoses error"}

                     // Use same data in DiagnosesAsChildren relationship
                     set patdiag1=##class(BI.Study.PatientDiagnosis1).%New()
                     set patdiag1.DiagnosisCode=code
                     set patdiag1.DiagnosedBy=diagdoc
                     
                     // Link the objects
                     set patdiag1.Patient=pat
                     set status=patdiag1.%Save()
                     if $$$ISERR(status) {do $System.Status.DisplayError(status) write !, "DiagnosesAsChildren error"}
                    
                     // Use same data in DiagnosesAsMany relationship
                     set patdiag2=##class(BI.Study.PatientDiagnosis2).%New()
                     set patdiag2.DiagnosisCode=code
                     set patdiag2.DiagnosedBy=diagdoc
                     
                     // Link the objects
                     set patdiag2.Patient=pat
                     set status=patdiag2.%Save()
                     if $$$ISERR(status) {do $System.Status.DisplayError(status)  write !, "DiagnosesAsMany error"}
                 }
                 set pat.DiagnosesAsLB=diaglist
                 set pat.DiagnosesAsString=diagstring
                 }
             
             }

        // Now that we have used the age data,
        // null out birth date & age randomly to simulate missing data
        if genNullDates &&##class(BI.Populate).RandomTrue(2){
            set pat.Age=""
            set pat.BirthDate=""
            set pat.BirthTime=""
            set pat.BirthDateTimeStamp=""
            set pat.BirthDateMV = ""
            }
        
       set status=pat.%Save()
       if $$$ISERR(status) {do $System.Status.DisplayError(status) write !, "Patient save error"}

       // If asked, generate some encounters (but not necessarily for everyone)
       if genNulls {
           set chance=##class(BI.Populate).RandomTrue(84)
           }
           else {
               set chance=1
               }
                
       if generateencounters && chance {
           set status=##class(BI.Study.PatientEncounter).CreateEncounters(pat)
           if $$$ISERR(status) {do $System.Status.DisplayError(status) write !, "Encounter creation error"}
           }
        
        if 'initSetup {do ##class(%DeepSee.Utils).%SynchronizeCube("patients")}

       if ('(n#1000)) {write $C(13,27)_"[0J"_$FN(n,",",0)_" patients created in BI.Study.Patient"}
       }

    // Create or update the "ID extent sets" from which we can later get random IDs
    set status=##class(BI.Populate).UpdateIdCache($CLASSNAME())
    set status=##class(BI.Populate).UpdateIdCache("BI.Study.PatientDetails")
   
    // Store highest PatientID for later use
    set ^BI.Study.SetupData("PatientID")=pat.PatientID
    
    write !
    write $C(13,27)_"[0J"_$FN(+$G(n),",",0)_" patient(s) created in BI.Study.Patient"

    set currentcount=##class(BI.Populate).Count($CLASSNAME())
    write !, "Current patient count is ",currentcount
    set ^BI.Study.Log($I(^BI.Study.Log))=$zdatetime($h,2,3)_" Current patient count is "_currentcount

    if initSetup {
        set ^BI.Study.Log($I(^BI.Study.Log))=$zdatetime($h,2,3)_" Building the cube..."
        do ##class(%DeepSee.Utils).%BuildCube("patients")
        set ^BI.Study.Log($I(^BI.Study.Log))=$zdatetime($h,2,3)_" Finished building the cube"
    }

    quit status
}

/// Delete a few patients randomly. 
ClassMethod DeleteSomePatients(percent As %Numeric = 1) As %Status
{
    set ^BI.Study.Log($I(^BI.Study.Log))=$zdatetime($h,2,3)_" Deleting some patients..."

    // Create or update the "ID extent set" from which we can later get random IDs
    set status=##class(BI.Populate).UpdateIdCache($CLASSNAME())
    
    set patcount=##class(BI.Populate).Count($CLASSNAME())
    for i=1:1:patcount {
         if ##class(BI.Populate).RandomTrue(percent) 
         {
             set patid=##class(BI.Populate).GetRandomId($CLASSNAME())
             set status=..DeletePatient(patid)
             if $$$ISERR(status) {
                 do $System.Status.DisplayError(status) write !, "Delete error for patient ", patid
                 }
             }
  
         }
    set status=##class(BI.Populate).UpdateIdCache($CLASSNAME())
    set currentcount=##class(BI.Populate).Count($CLASSNAME())
    set ^BI.Study.Log($I(^BI.Study.Log))=$zdatetime($h,2,3)_" Current patient count is "_currentcount
    quit status
}

/// Deletes a patient, given its ID. 
ClassMethod DeletePatient(patid As %String) As %Status
{
    // First let's find out what we really need to do;
    // if we have 0 records in a child table, we can skip processing that table
    set deletedetails=##class(BI.Populate).Count("BI.Study.PatientDetails")
    set deleteencounters=##class(BI.Populate).Count("BI.Study.PatientEncounter")
    set deletediagnoses=##class(BI.Populate).Count("BI.Study.PatientDiagnosis1")

    // Clear out records in PatientDetails
    if deletedetails {
	    set status=##class(PatientDetails).DeletePatientDetails(patid)
        if $$$ISERR(status) {
	        do $System.Status.DisplayError(status) 
            write !,"Error deleting record in PatientDetails for PatientID ",patid 
            quit
            }
        set status=##class(BI.Populate).UpdateIdCache("BI.Study.PatientDetails")
    }

    // Clear out records in PatientEncounter
    if deleteencounters {
	    set patoref=..%OpenId(patid,0)
        set status=##class(BI.Study.PatientEncounter).DeleteEncounters(patoref)
        if $$$ISERR(status) {
	        do $System.Status.DisplayError(status) 
	        write !,"Error deleting records in PatientEncounter for patient ",patid 
	        quit
	        }
	    kill patoref
    }
    
    
    // Clear out records in PatientDiagnosis1 (must delete children before deleting parent)
    if deletediagnoses {
        set myquery="DELETE FROM BI_Study.PatientDiagnosis1 WHERE Patient=?"
        set rset=##class(%ResultSet).%New("%DynamicQuery:SQL")
        set status=rset.Prepare(myquery)
        if $$$ISERR(status) {do $System.Status.DisplayError(status) quit}
        set status=rset.Execute(patid)
        if $$$ISERR(status) {
	        do $System.Status.DisplayError(status) 
	        write !, "Error deleting records in PatientDiagnosis1" 
	        quit
	        }
    }

    // Clear out records in PatientDiagnosis2
    if deletediagnoses {
        set myquery="DELETE FROM BI_Study.PatientDiagnosis2 WHERE Patient=?"
        set rset=##class(%ResultSet).%New("%DynamicQuery:SQL")
        set status=rset.Prepare(myquery)
        if $$$ISERR(status) {
	        do $System.Status.DisplayError(status) 
	        quit
	        }
        set status=rset.Execute(patid)
        if $$$ISERR(status) {
	        do $System.Status.DisplayError(status) 
    	    write !, "Error deleting records in PatientDiagnosis2" 
	        quit
	        }
    }

    set status=##class(BI.Study.Patient).%DeleteId(patid)

    // Every time we add or delete records, we need to update the ID cache
    set status=##class(BI.Populate).UpdateIdCache($CLASSNAME())

    do ##class(%DeepSee.Utils).%SynchronizeCube("patients")

    quit status
}

/// Randomly reassign some patients to different patient groups. 
ClassMethod ChangePatientGroups(percent As %Numeric = 10)
{
    // Initialize this just in case
    set status=##class(BI.Populate).UpdateIdCache("BI.Study.Patient")
    
    set ^BI.Study.Log($I(^BI.Study.Log))=$zdatetime($h,2,3)_" Changing some patient group assignments..."

    set patcount=##class(BI.Populate).Count($CLASSNAME())
    set changecount=0
    for i=1:1:patcount {
        if ##class(BI.Populate).RandomTrue(percent) 
        {
            set randomid=##class(BI.Populate).GetRandomId($CLASSNAME())
            set pat=..%OpenId(randomid)
        
            // Assign to a patient group if already assigned
            // want to avoid putting patient into group if not currently assigned
            // because logic elsewhere ensures TestScore is null for unassigned patients
            if '(pat.PatientGroup="")
            {
                set grouplist=$LB("A","B")
                set groupID=$RANDOM($LISTLENGTH(grouplist))+1
                set pat.PatientGroup=$LI(grouplist,groupID)
                do pat.%Save()
                set changecount=changecount+1
            }

            do ##class(%DeepSee.Utils).%SynchronizeCube("patients")
            }
    }

    set ^BI.Study.Log($I(^BI.Study.Log))=$zdatetime($h,2,3)_" "_changecount_" patients changed to other groups"
}

/// Changes some patient data in various tables.
/// if rebuild is 1, this method updates the BI indices for each patient affected
/// by these changes. 
ClassMethod ChangeSomePatients(percent As %Numeric = 20, rebuild As %Boolean = 1)
{
 set currentcount=##class(BI.Populate).Count($CLASSNAME())
 write !, "Current patient count is ",currentcount, " and this will not change"
 do ##class(BI.Study.Patient).ChangePatientGroups(percent)
 do ##class(BI.Study.PatientDetails).ChangePatientDetails(percent, rebuild)
 do ##class(BI.Study.PatientEncounter).AddEncounters(percent, rebuild)

 quit
}

ClassMethod GetHighestPatientID() As %String
{
    quit ^BI.Study.SetupData("PatientID")
}

Storage Default
{
<Data name="DiagnosesAsArray">
<Attribute>DiagnosesAsArray</Attribute>
<Structure>subnode</Structure>
<Subscript>"DiagnosesAsArray"</Subscript>
</Data>
<Data name="PatientDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>PatientID</Value>
</Value>
<Value name="3">
<Value>Gender</Value>
</Value>
<Value name="4">
<Value>Age</Value>
</Value>
<Value name="5">
<Value>BirthDate</Value>
</Value>
<Value name="6">
<Value>BirthTime</Value>
</Value>
<Value name="7">
<Value>BirthDateTimeStamp</Value>
</Value>
<Value name="8">
<Value>BirthDateMV</Value>
</Value>
<Value name="9">
<Value>PrimaryCarePhysician</Value>
</Value>
<Value name="10">
<Value>Allergies</Value>
</Value>
<Value name="11">
<Value>Diagnoses</Value>
</Value>
<Value name="12">
<Value>DiagnosesAsLB</Value>
</Value>
<Value name="13">
<Value>DiagnosesAsString</Value>
</Value>
<Value name="14">
<Value>HomeCity</Value>
</Value>
<Value name="15">
<Value>PatientGroup</Value>
</Value>
<Value name="16">
<Value>TestScore</Value>
</Value>
</Data>
<DataLocation>^BI.Study.PatientD</DataLocation>
<DefaultData>PatientDefaultData</DefaultData>
<IdLocation>^BI.Study.PatientD</IdLocation>
<IndexLocation>^BI.Study.PatientI</IndexLocation>
<StreamLocation>^BI.Study.PatientS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

