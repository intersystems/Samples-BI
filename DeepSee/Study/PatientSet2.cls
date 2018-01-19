/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the DeepSee Patients sample, whose purpose is to provide
/// sample data for use with DeepSee. 
/// <p>This class represents an additional set of patients collected
/// by a separate research team and put into a separate table. It does
/// not have all the properties that DeepSee.Study.Patient has.
/// For information on these properties and methods, see the corresponding
/// comments in DeepSee.Study.Patient.
/// <p>This table is populated only if you use the X option when running the 
/// GenerateData() method in DeepSee.Populate.
Class DeepSee.Study.PatientSet2 Extends %Persistent
{

Property PatientID As %String;

Property Gender As %String;

Property Age As %Integer;

Property PrimaryCarePhysician As DeepSee.Study.Doctor;

Property Allergies As list Of DeepSee.Study.PatientAllergy;

Property Diagnoses As list Of DeepSee.Study.PatientDiagnosis;

Property HomeCity As %String;

Property PatientGroup As %String;

Property TestScore As %Numeric;

/// Called by DeepSee.Populate:GenerateData(); see the comments for that method.
ClassMethod GenerateData(patCount As %Integer = 500, options As %String = "ADT", genNulls As %Boolean = 1) As %Status
{
     Set status=$$$OK
     //first kill extent and kill extents of child tables
     //never use %KillExtent() in a real application
     Do ..%KillExtent()
     Set status=..AddPatients(patCount,options,genNulls)
     Quit status
}

/// Called by DeepSee.Populate:GenerateData(); see the comments for that method.
/// Can also be called directly to add patients after the initial setup.
ClassMethod AddPatients(patCount As %Integer = 500, options As %String = "AD", genNulls = 1) As %Status
{
    Set status=$$$OK
    
    //check options; what Do we need to generate?
    If ($FIND(options,"A")) {Set generateallergies=1}
        Else {Set generateallergies=0}
    If ($FIND(options,"D")) {Set generatediagnoses=1}
        Else {Set generatediagnoses=0}
    
    Set dcount=##class(DeepSee.Populate).Count("DeepSee.Study.Diagnosis")
    Set currentpatcount=##class(DeepSee.Populate).Count($CLASSNAME())
    If (currentpatcount=0) {Set initPat=5000}
        Else {Set initPat=patcount+1}
    Set idnumber=initPat

    For n = 1:1:patCount {
        Set pat=##class(DeepSee.Study.PatientSet2).%New()
        Set idnumber=idnumber+1     ; increment without any gaps
        Set patid="SET2_"_idnumber
        Set pat.PatientID=patid
        
        //get age+gender combination
        Set agegender=##class(DeepSee.Populate).RandomGenderAndAge()
        Set pat.Gender=$Piece(agegender,",",1)
        Set pat.Age=$Piece(agegender,",",2)
   
        //assign a doctor
        Set docid=##class(DeepSee.Populate).GetRandomId("DeepSee.Study.Doctor")
        Set doctor=##class(DeepSee.Study.Doctor).%OpenId(docid,0)
        Set pat.PrimaryCarePhysician=doctor

        // null out this property randomly to simulate missing data
        If genNulls &&##class(DeepSee.Populate).RandomTrue(15){
            Set pat.PrimaryCarePhysician=""
            }

        //assign to a patient group
        Set grouplist=$LB("Group A","Group B")
        Set groupID=$RANDOM($LISTLENGTH(grouplist))+1
        Set pat.PatientGroup=$LI(grouplist,groupID)

        //Set TestScore property and assign a test version
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
        Set city=##class(DeepSee.Study.City).%OpenId(cityid,0)
        Set pat.HomeCity=city.Name

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
            Set diagnosiscount=0    ; initialize this so we know If we're on the first one
            Set diaglist=""
            For k=1:1:dcount{
                Set potentialdiagnosis=##class(DeepSee.Study.Diagnosis).%OpenId(k,0)

                //get the code
                Set code=potentialdiagnosis.Code
                //look up how likely this patient is to have this diagnosis
                Set chance=##class(DeepSee.Study.Diagnosis).GetPercentChance(code,pat.Gender,pat.Age)
                
                If ##class(DeepSee.Populate).RandomTrue(chance) {
                    Set diagnosiscount=diagnosiscount+1
                    Set desc=potentialdiagnosis.Description                             
                    Set diagdocid=##class(DeepSee.Populate).GetRandomId("DeepSee.Study.Doctor")
                    Set diagdoc=##class(DeepSee.Study.Doctor).%OpenId(diagdocid,0)

                    //populate Diagnoses property
                    Set patdiag=##class(DeepSee.Study.PatientDiagnosis).%New()    ; this object is serial
                    Set patdiag.DiagnosisCode=code
                    Set patdiag.DiagnosedBy=diagdoc
                    Set status=pat.Diagnoses.Insert(patdiag)
                    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Write !, "Diagnoses error"}
                    }
                }
             
             }

        Set status=pat.%Save()
        If $$$ISERR(status) {Do $System.Status.DisplayError(status) Write !, "Patient save error"}
        If ('(n#1000)) {Write $C(13,27)_"[0J"_$FN(n,",",0)_" patients created in DeepSee.Study.Patient"}
}

   //create an "extent set" from which we can later get random IDs
   Set status=##class(DeepSee.Populate).UpdateIdCache($CLASSNAME())
   
   Write !
   Write $C(13,27)_"[0J"_$FN(+$G(n),",",0)_" patient(s) created in DeepSee.Study.PatientSet2"
   Quit status
}

Storage Default
{
<Data name="PatientSet2DefaultData">
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
<Value>PrimaryCarePhysician</Value>
</Value>
<Value name="6">
<Value>Allergies</Value>
</Value>
<Value name="7">
<Value>Diagnoses</Value>
</Value>
<Value name="8">
<Value>HomeCity</Value>
</Value>
<Value name="9">
<Value>PatientGroup</Value>
</Value>
<Value name="10">
<Value>TestScore</Value>
</Value>
</Data>
<DataLocation>^DeepSee.Study.PatientSet2D</DataLocation>
<DefaultData>PatientSet2DefaultData</DefaultData>
<IdLocation>^DeepSee.Study.PatientSet2D</IdLocation>
<IndexLocation>^DeepSee.Study.PatientSet2I</IndexLocation>
<StreamLocation>^DeepSee.Study.PatientSet2S</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

