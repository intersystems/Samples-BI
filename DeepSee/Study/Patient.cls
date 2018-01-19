/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the DeepSee Patients sample, whose purpose is to provide
/// sample data for use with DeepSee. 
Class DeepSee.Study.Patient Extends %Persistent
{

/// This parameter setting enables the DSTIME feature for DeepSee II
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

Property PrimaryCarePhysician As DeepSee.Study.Doctor;

Property Allergies As list Of DeepSee.Study.PatientAllergy;

/// Diagnoses of this patient. This class contains multiple versions of this property
/// each of which contains the same general diagnosis data. These versions enable you to
/// create DeepSee dimensions on a variety of types of collections.
/// Use this variation to see how DeepSee handles lists of objects.
Property Diagnoses As list Of DeepSee.Study.PatientDiagnosis;

/// Use this variation to see how DeepSee handles arrays.
/// See comments for the Diagnoses property.
Property DiagnosesAsArray As array Of %String;

/// Use this variation to see how DeepSee handles $LB lists of strings.
/// See comments for the Diagnoses property.
Property DiagnosesAsLB As %List;

/// Use this variation to see how DeepSee handles pieced strings.
/// See comments for the Diagnoses property.
Property DiagnosesAsString As %String;

/// Use this variation to see how DeepSee handles parent-child relationships
/// See comments for the Diagnoses property.
Relationship DiagnosesAsChildren As DeepSee.Study.PatientDiagnosis1 [ Cardinality = children, Inverse = Patient ];

/// Use this variation to see how DeepSee handles one-to-many relationships
/// See comments for the Diagnoses property.
Relationship DiagnosesAsMany As DeepSee.Study.PatientDiagnosis2 [ Cardinality = many, Inverse = Patient ];

Property HomeCity As DeepSee.Study.City;

/// This property represents some grouping of the patients in this fictitious study.
/// Use this as a DeepSee dimension.
Property PatientGroup As %String;

/// Value of some fictitious test; will use this as a measure; can be null.
/// When using as a measure, probably more suitable to average across the patients.
Property TestScore As %Integer;

/// Called by DeepSee.Populate:GenerateData(); see the comments for that method.
ClassMethod GenerateData(patCount As %Integer = 500, options As %String = "ADET", genNulls As %Boolean = 1, genNullDates As %Boolean = 0) As %Status
{
    Set status=$$$OK
    Write !, "Deleting patient data..."

    //first kill extent and kill extents of child tables
    Do ..%KillExtent()
    Do ##class(DeepSee.Study.PatientDiagnosis1).%KillExtent()
    Do ##class(DeepSee.Study.PatientDiagnosis2).%KillExtent()
    Do ##class(DeepSee.Study.PatientDetails).%KillExtent()
    Do ##class(DeepSee.Study.PatientEncounter).%KillExtent()
   
    Write !, "Adding patients..."
    Set status=..AddPatients(patCount,options,genNulls,1,genNullDates)
    Quit status
}

/// Called by GenerateData(); see the comments for that method.
/// Can also be called directly to add patients after the initial setup.
ClassMethod AddPatients(patCount As %Integer = 100, options As %String = "ADT", genNulls As %Boolean = 1, initSetup As %Boolean = 0, genNullDates As %Boolean = 0) As %Status
{
    If initSetup {Kill ^DeepSee.Study.Log}
    Set ^DeepSee.Study.Log($I(^DeepSee.Study.Log))=$zdatetime($h,2,3)_" Adding patients..."


    //create or update the "ID extent sets" from which we can later get random IDs
    Set status=##class(DeepSee.Populate).UpdateIdCache("DeepSee.Study.Doctor")
    Set status=##class(DeepSee.Populate).UpdateIdCache("DeepSee.Study.City")

    
    //check options; what do we need to generate?
    If ($FIND(options,"A")) {Set generateallergies=1}
        Else {Set generateallergies=0}
    If ($FIND(options,"D")) {Set generatediagnoses=1}
        Else {Set generatediagnoses=0}
    If ($FIND(options,"E")) {Set generateencounters=1}
        Else {Set generateencounters=0}
    If ($FIND(options,"T")) {Set generatedetails=1}
        Else {Set generatedetails=0}
    

    //get diagnosis and current patient count
    Set dcount=##class(DeepSee.Populate).Count("DeepSee.Study.Diagnosis")
    Set currentpatcount=##class(DeepSee.Populate).Count($CLASSNAME())
    
    //initialize counters
    If (currentpatcount=0) {
        Set initPat=100300
        }
        Else {
            //get highest PatientID in use
            Set highest=..GetHighestPatientID()
            Set initPat=$PIECE(highest,"_",2)
            }

    Set idnumber=initPat

    For n = 1:1:patCount {
        Set pat=##class(DeepSee.Study.Patient).%New()
        Set idnumber=idnumber+1     ; increment without any gaps
        Set patid="SUBJ_"_idnumber
        Set pat.PatientID=patid
        
        //get age+gender combination
        Set agegender=##class(DeepSee.Populate).RandomGenderAndAge()
        Set pat.Gender=$Piece(agegender,",",1)
        Set pat.Age=$Piece(agegender,",",2)

        //get birthdate as a string YYYY-MM-DD
        Set birthdate=##class(DeepSee.Populate).BirthDateODBC(pat.Age)
        Set pat.BirthDate=$ZDATEH(birthdate,6)  ; convert to $h explicitly and write value
 
        //get birthtime as random time hh:mm:ss
        Set timestamp=##class(%PopulateUtils).TimeStamp()   
        Set timepart=$Piece(timestamp," ",2)
        Set timestring=$Piece(timepart,":",1)_":"_$Piece(timepart,":",2)
        Set pat.BirthTime=$ZTIMEH(timestring,2) ; convert to $h and write value
 
        //combine date and time
        Set birthdateandtime=birthdate_" "_timepart
        Set pat.BirthDateTimeStamp=birthdateandtime ; write in ODBC format 
    
        //set MV version
        Set pat.BirthDateMV = pat.BirthDate - 46385
    
        //assign a doctor
        Set docid=##class(DeepSee.Populate).GetRandomId("DeepSee.Study.Doctor")
        Set doctor=##class(DeepSee.Study.Doctor).%OpenId(docid,0)
        Set pat.PrimaryCarePhysician=doctor

        // null out this property randomly to simulate missing data
        If genNulls &&##class(DeepSee.Populate).RandomTrue(15){
            Set pat.PrimaryCarePhysician=""
            }

        //assign to a patient group
        Set grouplist=$LB("A","B")
        Set groupID=$RANDOM($LISTLENGTH(grouplist))+1
        Set pat.PatientGroup=$LI(grouplist,groupID)

        //Set TestScore property
        Set pat.TestScore=50+$RANDOM(50)
        
        //null out the previous two properties in some cases
        //score can be null but won't be 0 (see above)
        //this lets us see how measures treat null values
        If (genNulls && ##class(DeepSee.Populate).RandomTrue(20)){
            Set pat.TestScore=""
            Set pat.PatientGroup=""
            }
        
        //Select a city
        Set cityid=##class(DeepSee.Populate).GetRandomId("DeepSee.Study.City")          
        Set pat.HomeCity=##class(DeepSee.Study.City).%OpenId(cityid,0)

        //If asked, update PatientDetails table
        If generatedetails {
            Set status=##class(PatientDetails).CreatePatientDetails(pat.PatientID,pat.Age,genNulls)
            If $$$ISERR(status) {Do $System.Status.DisplayError(status) Write !, "Patient details error"}
            }
        
        //If asked, generate some allergies
        If generateallergies {
            Set status=##class(DeepSee.Study.PatientAllergy).GenerateAllergies(pat,genNulls)
            If $$$ISERR(status) {Do $System.Status.DisplayError(status) Write !, "Allergies insert error"}
            }
         
         //If asked, generate some diagnoses
         If generatediagnoses {
             //iterate through available diagnoses, look up chance of patient's
             //receiving this diagnosis, based on gender & age
             //save diagnosis data in all diagnosis properties
             Set diagnosiscount=0    ; initialize this so we know if we're on the first one
             Set diaglist = ""
             Set diagstring=""
             For k=1:1:dcount{
                 Set potentialdiagnosis=##class(DeepSee.Study.Diagnosis).%OpenId(k,0)

                 //get the code
                 Set code=potentialdiagnosis.Code
                 //look up how likely this patient is to have this diagnosis
                 Set chance=##class(DeepSee.Study.Diagnosis).GetPercentChance(code,pat.Gender,pat.Age)
                
                 If ##class(DeepSee.Populate).RandomTrue(chance) {
                     Set diagnosiscount=diagnosiscount+1
                     Set desc=potentialdiagnosis.Description
                                        
                     //Build basic diagnosis properties
                     Set $LI(diaglist,diagnosiscount)=code 
                     Set diagstring=diagstring_","_code
                     Do pat.DiagnosesAsArray.SetAt(code,diagnosiscount)
                    
                     //now for the more complex properties, choose a random diagnosing doctor
                     Set diagdocid=##class(DeepSee.Populate).GetRandomId("DeepSee.Study.Doctor")
                     Set diagdoc=##class(DeepSee.Study.Doctor).%OpenId(diagdocid,0)

                     //populate Diagnoses property
                     Set patdiag=##class(DeepSee.Study.PatientDiagnosis).%New()    ; this object is serial
                     Set patdiag.DiagnosisCode=code
                     Set patdiag.DiagnosedBy=diagdoc
                     Set status=pat.Diagnoses.Insert(patdiag)
                     If $$$ISERR(status) {Do $System.Status.DisplayError(status) Write !, "Diagnoses error"}

                     //use same data in DiagnosesAsChildren relationship
                     Set patdiag1=##class(DeepSee.Study.PatientDiagnosis1).%New()
                     Set patdiag1.DiagnosisCode=code
                     Set patdiag1.DiagnosedBy=diagdoc
                     //link the objects
                     Set patdiag1.Patient=pat
                     Set status=patdiag1.%Save()
                     If $$$ISERR(status) {Do $System.Status.DisplayError(status) Write !, "DiagnosesAsChildren error"}
                    
                     //use same data in DiagnosesAsMany relationship
                     Set patdiag2=##class(DeepSee.Study.PatientDiagnosis2).%New()
                     Set patdiag2.DiagnosisCode=code
                     Set patdiag2.DiagnosedBy=diagdoc
                     //link the objects
                     Set patdiag2.Patient=pat
                     Set status=patdiag2.%Save()
                     If $$$ISERR(status) {Do $System.Status.DisplayError(status)  Write !, "DiagnosesAsMany error"}
                 }
                 Set pat.DiagnosesAsLB=diaglist
                 Set pat.DiagnosesAsString=diagstring
                 }
             
             }

        // now that we have used the age data,
        // null out birth date & age randomly to simulate missing data
        If genNullDates &&##class(DeepSee.Populate).RandomTrue(2){
            Set pat.Age=""
            Set pat.BirthDate=""
            Set pat.BirthTime=""
            Set pat.BirthDateTimeStamp=""
            Set pat.BirthDateMV = ""
            }
        
       Set status=pat.%Save()
       If $$$ISERR(status) {Do $System.Status.DisplayError(status) Write !, "Patient save error"}

       //If asked, generate some encounters (but not necessarily for everyone)
       If genNulls {
           Set chance=##class(DeepSee.Populate).RandomTrue(84)
           }
           Else {
               Set chance=1
               }
                
       If generateencounters && chance {
           Set status=##class(DeepSee.Study.PatientEncounter).CreateEncounters(pat)
           If $$$ISERR(status) {Do $System.Status.DisplayError(status) Write !, "Encounter creation error"}
           }
        
       //The following line applies to DeepSee II
        If 'initSetup {Do ##class(%DeepSee.Utils).%SynchronizeCube("patients")}

       If ('(n#1000)) {Write $C(13,27)_"[0J"_$FN(n,",",0)_" patients created in DeepSee.Study.Patient"}
       }

    //create or update the "ID extent sets" from which we can later get random IDs
    Set status=##class(DeepSee.Populate).UpdateIdCache($CLASSNAME())
    Set status=##class(DeepSee.Populate).UpdateIdCache("DeepSee.Study.PatientDetails")
   
    //Store highest PatientID for later use
    Set ^DeepSee.Study.SetupData("PatientID")=pat.PatientID
    
    Write !
    Write $C(13,27)_"[0J"_$FN(+$G(n),",",0)_" patient(s) created in DeepSee.Study.Patient"

    Set currentcount=##class(DeepSee.Populate).Count($CLASSNAME())
    Write !, "Current patient count is ",currentcount
    Set ^DeepSee.Study.Log($I(^DeepSee.Study.Log))=$zdatetime($h,2,3)_" Current patient count is "_currentcount

    //The following lines applies to DeepSee II
    If initSetup {
        Set ^DeepSee.Study.Log($I(^DeepSee.Study.Log))=$zdatetime($h,2,3)_" Building the cube..."
        Do ##class(%DeepSee.Utils).%BuildCube("patients")
        Set ^DeepSee.Study.Log($I(^DeepSee.Study.Log))=$zdatetime($h,2,3)_" Finished building the cube"
    }

    Quit status
}

/// Delete a few patients randomly. 
ClassMethod DeleteSomePatients(percent As %Numeric = 1) As %Status
{
    Set ^DeepSee.Study.Log($I(^DeepSee.Study.Log))=$zdatetime($h,2,3)_" Deleting some patients..."

    //create or update the "ID extent set" from which we can later get random IDs
    Set status=##class(DeepSee.Populate).UpdateIdCache($CLASSNAME())
    
    Set patcount=##class(DeepSee.Populate).Count($CLASSNAME())
    For i=1:1:patcount {
         If ##class(DeepSee.Populate).RandomTrue(percent) 
         {
             Set patid=##class(DeepSee.Populate).GetRandomId($CLASSNAME())
             Set status=..DeletePatient(patid)
             If $$$ISERR(status) {
                 Do $System.Status.DisplayError(status) Write !, "Delete error for patient ", patid
                 }
             }
  
         }
    Set status=##class(DeepSee.Populate).UpdateIdCache($CLASSNAME())
    Set currentcount=##class(DeepSee.Populate).Count($CLASSNAME())
    Set ^DeepSee.Study.Log($I(^DeepSee.Study.Log))=$zdatetime($h,2,3)_" Current patient count is "_currentcount
    Quit status
}

/// Deletes a patient, given its ID. 
ClassMethod DeletePatient(patid As %String) As %Status
{
    //first let's find out what we really need to do;
    //if we have 0 records in a child table, we can skip processing that table
    Set deletedetails=##class(DeepSee.Populate).Count("DeepSee.Study.PatientDetails")
    Set deleteencounters=##class(DeepSee.Populate).Count("DeepSee.Study.PatientEncounter")
    Set deletediagnoses=##class(DeepSee.Populate).Count("DeepSee.Study.PatientDiagnosis1")

    //clear out records in PatientDetails
    If deletedetails {
	    Set status=##class(PatientDetails).DeletePatientDetails(patid)
        If $$$ISERR(status) {
	        Do $System.Status.DisplayError(status) 
            Write !,"Error deleting record in PatientDetails for PatientID ",patid 
            Quit
            }
        Set status=##class(DeepSee.Populate).UpdateIdCache("DeepSee.Study.PatientDetails")
    }

    //clear out records in PatientEncounter
    If deleteencounters {
	    Set patoref=..%OpenId(patid,0)
        Set status=##class(DeepSee.Study.PatientEncounter).DeleteEncounters(patoref)
        If $$$ISERR(status) {
	        Do $System.Status.DisplayError(status) 
	        Write !,"Error deleting records in PatientEncounter for patient ",patid 
	        Quit
	        }
	    Kill patoref
    }
    
    
    //clear out records in PatientDiagnosis1 (must delete children before deleting parent)
    If deletediagnoses {
        Set myquery="DELETE FROM DeepSee_Study.PatientDiagnosis1 WHERE Patient=?"
        Set rset=##class(%ResultSet).%New("%DynamicQuery:SQL")
        Set status=rset.Prepare(myquery)
        If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
        Set status=rset.Execute(patid)
        If $$$ISERR(status) {
	        Do $System.Status.DisplayError(status) 
	        Write !, "Error deleting records in PatientDiagnosis1" 
	        Quit
	        }
    }

    //clear out records in PatientDiagnosis2
    If deletediagnoses {
        Set myquery="DELETE FROM DeepSee_Study.PatientDiagnosis2 WHERE Patient=?"
        Set rset=##class(%ResultSet).%New("%DynamicQuery:SQL")
        Set status=rset.Prepare(myquery)
        If $$$ISERR(status) {
	        Do $System.Status.DisplayError(status) 
	        Quit
	        }
        Set status=rset.Execute(patid)
        If $$$ISERR(status) {
	        Do $System.Status.DisplayError(status) 
    	    Write !, "Error deleting records in PatientDiagnosis2" 
	        Quit
	        }
    }

    Set status=##class(DeepSee.Study.Patient).%DeleteId(patid)

    //every time we add or delete records, we need to update the ID cache
    Set status=##class(DeepSee.Populate).UpdateIdCache($CLASSNAME())

    //The following line applies to DeepSee II
    Do ##class(%DeepSee.Utils).%SynchronizeCube("patients")

    Quit status
}

/// Randomly reassign some patients to different patient groups. 
ClassMethod ChangePatientGroups(percent As %Numeric = 10)
{
    //initialize this just in case
    Set status=##class(DeepSee.Populate).UpdateIdCache("DeepSee.Study.Patient")
    
    Set ^DeepSee.Study.Log($I(^DeepSee.Study.Log))=$zdatetime($h,2,3)_" Changing some patient group assignments..."

    Set patcount=##class(DeepSee.Populate).Count($CLASSNAME())
    Set changecount=0
    For i=1:1:patcount {
        If ##class(DeepSee.Populate).RandomTrue(percent) 
        {
            Set randomid=##class(DeepSee.Populate).GetRandomId($CLASSNAME())
            Set pat=..%OpenId(randomid)
        
            //assign to a patient group if already assigned
            //want to avoid putting patient into group if not currently assigned
            //because logic elsewhere ensures TestScore is null for unassigned patients
            if '(pat.PatientGroup="")
            {
                Set grouplist=$LB("A","B")
                Set groupID=$RANDOM($LISTLENGTH(grouplist))+1
                Set pat.PatientGroup=$LI(grouplist,groupID)
                Do pat.%Save()
                Set changecount=changecount+1
            }

            //The following line applies to DeepSee II
            Do ##class(%DeepSee.Utils).%SynchronizeCube("patients")
            }
    }

    Set ^DeepSee.Study.Log($I(^DeepSee.Study.Log))=$zdatetime($h,2,3)_" "_changecount_" patients changed to other groups"
}

/// Changes some patient data in various tables.
/// If rebuild is 1, this method updates the DeepSee indices (I and II) for each patient affected
/// by these changes. For DeepSee I, use this option only if you have enabled incremental updates 
/// (otherwise, you needlessly slow down the method).
ClassMethod ChangeSomePatients(percent As %Numeric = 20, rebuild As %Boolean = 1)
{
 Set currentcount=##class(DeepSee.Populate).Count($CLASSNAME())
 Write !, "Current patient count is ",currentcount, " and this will not change"
 Do ##class(DeepSee.Study.Patient).ChangePatientGroups(percent)
 Do ##class(DeepSee.Study.PatientDetails).ChangePatientDetails(percent, rebuild)
 Do ##class(DeepSee.Study.PatientEncounter).AddEncounters(percent, rebuild)

 Quit
}

ClassMethod GetHighestPatientID() As %String
{
    Quit ^DeepSee.Study.SetupData("PatientID")
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
<DataLocation>^DeepSee.Study.PatientD</DataLocation>
<DefaultData>PatientDefaultData</DefaultData>
<IdLocation>^DeepSee.Study.PatientD</IdLocation>
<IndexLocation>^DeepSee.Study.PatientI</IndexLocation>
<StreamLocation>^DeepSee.Study.PatientS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

