/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// This class represents an additional set of patients collected
/// by a separate research team and put into a separate table. It does
/// not have all the properties that BI.Study.Patient has.
/// For information on these properties and methods, see the corresponding
/// comments in BI.Study.Patient.
/// This table is populated only if you use the X option when running the 
/// GenerateData() method in BI.Populate.
Class BI.Study.PatientSet2 Extends %Persistent
{

Property PatientID As %String;

Property Gender As %String;

Property Age As %Integer;

Property PrimaryCarePhysician As BI.Study.Doctor;

Property Allergies As list Of BI.Study.PatientAllergy;

Property Diagnoses As list Of BI.Study.PatientDiagnosis;

Property HomeCity As %String;

Property PatientGroup As %String;

Property TestScore As %Numeric;

/// Called by BI.Populate:GenerateData(); see the comments for that method.
ClassMethod GenerateData(patCount As %Integer = 500, options As %String = "ADT", genNulls As %Boolean = 1) As %Status
{
     set status=$$$OK
     //first kill extent and kill extents of child tables
     //never use %KillExtent() in a real application
     do ..%KillExtent()
     set status=..AddPatients(patCount,options,genNulls)
     quit status
}

/// Called by BI.Populate:GenerateData(); see the comments for that method.
/// Can also be called directly to add patients after the initial setup.
ClassMethod AddPatients(patCount As %Integer = 500, options As %String = "AD", genNulls = 1) As %Status
{
    set status=$$$OK
    
    // Check options; what do we need to generate?
    if ($FIND(options,"A")) {set generateallergies=1}
        else {set generateallergies=0}
    if ($FIND(options,"D")) {set generatediagnoses=1}
        else {set generatediagnoses=0}
    
    set dcount=##class(BI.Populate).Count("BI.Study.Diagnosis")
    set currentpatcount=##class(BI.Populate).Count($CLASSNAME())
    if (currentpatcount=0) {set initPat=5000}
        else {set initPat=patCount+1}
    set idnumber=initPat

    for n = 1:1:patCount {
        set pat=##class(BI.Study.PatientSet2).%New()
        set idnumber=idnumber+1     ; increment without any gaps
        set patid="SET2_"_idnumber
        set pat.PatientID=patid
        
        // Get age+gender combination
        set agegender=##class(BI.Populate).RandomGenderAndAge()
        set pat.Gender=$Piece(agegender,",",1)
        set pat.Age=$Piece(agegender,",",2)
   
        // Assign a doctor
        set docid=##class(BI.Populate).GetRandomId("BI.Study.Doctor")
        set doctor=##class(BI.Study.Doctor).%OpenId(docid,0)
        set pat.PrimaryCarePhysician=doctor

        // Null out this property randomly to simulate missing data
        if genNulls &&##class(BI.Populate).RandomTrue(15){
            set pat.PrimaryCarePhysician=""
            }

        // Assign to a patient group
        set grouplist=$LB("Group A","Group B")
        set groupID=$RANDOM($LISTLENGTH(grouplist))+1
        set pat.PatientGroup=$LI(grouplist,groupID)

        // Set TestScore property and assign a test version
        set pat.TestScore=50+$RANDOM(50)
        
        // Null out the previous two properties in some cases
        // score can be null but won't be 0 (see above)
        // this lets us see how measures treat null values
        if (genNulls && ##class(BI.Populate).RandomTrue(20)){
            set pat.TestScore=""
            set pat.PatientGroup=""
            }

        // Select a city
        set cityid=##class(BI.Populate).GetRandomId("BI.Study.City")
        set city=##class(BI.Study.City).%OpenId(cityid,0)
        set pat.HomeCity=city.Name

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
            set diaglist=""
            for k=1:1:dcount{
                set potentialdiagnosis=##class(BI.Study.Diagnosis).%OpenId(k,0)

                // Get the code
                set code=potentialdiagnosis.Code
                
                // Look up how likely this patient is to have this diagnosis
                set chance=##class(BI.Study.Diagnosis).GetPercentChance(code,pat.Gender,pat.Age)
                
                if ##class(BI.Populate).RandomTrue(chance) {
                    set diagnosiscount=diagnosiscount+1
                    set desc=potentialdiagnosis.Description                             
                    set diagdocid=##class(BI.Populate).GetRandomId("BI.Study.Doctor")
                    set diagdoc=##class(BI.Study.Doctor).%OpenId(diagdocid,0)

                    // Populate Diagnoses property
                    set patdiag=##class(BI.Study.PatientDiagnosis).%New()    ; this object is serial
                    set patdiag.DiagnosisCode=code
                    set patdiag.DiagnosedBy=diagdoc
                    set status=pat.Diagnoses.Insert(patdiag)
                    if $$$ISERR(status) {do $System.Status.DisplayError(status) write !, "Diagnoses error"}
                    }
                }
             
             }

        set status=pat.%Save()
        if $$$ISERR(status) {do $System.Status.DisplayError(status) write !, "Patient save error"}
        if ('(n#1000)) {write $C(13,27)_"[0J"_$FN(n,",",0)_" patients created in BI.Study.Patient"}


   // Create an "extent set" from which we can later get random IDs
   set status=##class(BI.Populate).UpdateIdCache($CLASSNAME())
   
   write !
   write $C(13,27)_"[0J"_$FN(+$G(n),",",0)_" patient(s) created in BI.Study.PatientSet2"
   quit status
}

}
}
