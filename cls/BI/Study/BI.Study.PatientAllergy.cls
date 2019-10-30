/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// <p>This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// <p>
/// An allergy has multiple pieces of information,
/// which you can use separately or in combination to create dimensions, depending
/// on what you want to see.
Class BI.Study.PatientAllergy Extends %SerialObject
{

/// A substance to which the patient is allergic.
Property Allergen As BI.Study.Allergen;

/// Severity of this allergic reaction.
Property Severity As BI.Study.AllergySeverity;

/// Doctor who recorded this allergic reaction.
Property DiagnosedBy As BI.Study.Doctor;

/// Called by BI.Study.Patient:GenerateData() or by BI.Study.PatientSet2:GenerateData().
/// Pat argument could be either BI.Study.Patient or BI.Study.PatientSet2.
ClassMethod GenerateAllergies(pat, genNulls As %Boolean) As %Status
{
    set status=$$$OK

    // First decide if patient has no known allergies
    if ##class(BI.Populate).RandomTrue(15) {
	    // Assume ID 1 is the nil allergen
	    set allergen=##class(BI.Study.Allergen).%OpenId(1,0)
	    set status=..AddAllergy(pat,allergen,genNulls)
	    quit status
	    }
    
    // Iterate through remaining allergens and randomly assign to patient
    set allergencount=##class(BI.Populate).Count("BI.Study.Allergen")
    for i=2:1:allergencount {
	    if ##class(BI.Populate).RandomTrue(5) {
		    set allergen=##class(BI.Study.Allergen).%OpenId(i,0)
	        set status=..AddAllergy(pat,allergen,genNulls)
	        }
	    }
    
    quit status
}

/// Adds the given allergen to the patient and returns the patient by reference
ClassMethod AddAllergy(ByRef pat, allergen As BI.Study.Allergen, genNulls As %Boolean) As %Status
{
    set status=$$$OK

    set allergy=..%New()
    set allergy.Allergen=allergen
    
	if (allergen.Code'="000") {

		set sevid=##class(BI.Populate).GetRandomId("BI.Study.AllergySeverity")
		set allergy.Severity=##class(BI.Study.AllergySeverity).%OpenId(sevid,0)

		set docid=##class(BI.Populate).GetRandomId("BI.Study.Doctor")
		set allergy.DiagnosedBy=##class(BI.Study.Doctor).%OpenId(docid,0)
	}
            
	if genNulls {
		// For some percent of allergies, severity is not recorded
		if ##class(BI.Populate).RandomTrue(2){
			set allergy.Severity=""
		}
		// For some percent of allergies, diagnosing doctor is not recorded
		if ##class(BI.Populate).RandomTrue(8){
			set allergy.DiagnosedBy=""
		}
	}

    // Now add this to the patient 
    set status=pat.Allergies.Insert(allergy)

    // Create the same data in the PatientAllergy1 table 
    set status=##class(BI.Study.PatientAllergy1).CreateOne(pat,allergen,allergy.Severity,allergy.DiagnosedBy)
            
    quit status
}
}

