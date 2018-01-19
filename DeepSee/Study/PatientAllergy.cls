/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the DeepSee Patients sample, whose purpose is to provide
/// sample data for use with DeepSee. 
/// <p>
/// An allergy has multiple pieces of information,
/// which you can use separately or in combination to create dimensions, depending
/// on what you want to see.
Class DeepSee.Study.PatientAllergy Extends %SerialObject
{

/// A substance to which the patient is allergic.
Property Allergen As DeepSee.Study.Allergen;

/// Severity of this allergic reaction.
Property Severity As DeepSee.Study.AllergySeverity;

/// Doctor who recorded this allergic reaction.
Property DiagnosedBy As DeepSee.Study.Doctor;

/// Called by DeepSee.Study.Patient:GenerateData() or by DeepSee.Study.PatientSet2:GenerateData().
/// Pat argument could be either DeepSee.Study.Patient or DeepSee.Study.PatientSet2.
ClassMethod GenerateAllergies(pat, genNulls As %Boolean) As %Status
{
    Set status=$$$OK

    //First decide if patient has no known allergies
    If ##class(DeepSee.Populate).RandomTrue(15) {
	    // assume ID 1 is the nil allergen
	    Set allergen=##class(DeepSee.Study.Allergen).%OpenId(1,0)
	    Set status=..AddAllergy(pat,allergen,genNulls)
	    Quit status
	    }
    
    //iterate through remaining allergens and randomly assign to patient
    Set allergencount=##class(DeepSee.Populate).Count("DeepSee.Study.Allergen")
    For i=2:1:allergencount {
	    If ##class(DeepSee.Populate).RandomTrue(5) {
		    Set allergen=##class(DeepSee.Study.Allergen).%OpenId(i,0)
	        Set status=..AddAllergy(pat,allergen,genNulls)
	        }
	    }
    
    Quit status
}

/// adds the given allergen to the patient and returns the patient by reference
ClassMethod AddAllergy(ByRef pat, allergen As DeepSee.Study.Allergen, genNulls As %Boolean) As %Status
{
    Set status=$$$OK

    Set allergy=..%New()
    Set allergy.Allergen=allergen
            
    Set sevid=##class(DeepSee.Populate).GetRandomId("DeepSee.Study.AllergySeverity")
    Set allergy.Severity=##class(DeepSee.Study.AllergySeverity).%OpenId(sevid,0)

    Set docid=##class(DeepSee.Populate).GetRandomId("DeepSee.Study.Doctor")
    Set allergy.DiagnosedBy=##class(DeepSee.Study.Doctor).%OpenId(docid,0)
            
    If genNulls {
	    //for some percent of allergies, severity is not recorded
        If ##class(DeepSee.Populate).RandomTrue(2){
            Set allergy.Severity=""
            }
        //for some percent of allergies, diagnosing doctor is not recorded
        If ##class(DeepSee.Populate).RandomTrue(8){
            Set allergy.DiagnosedBy=""
            }
            }

    //now add this to the patient 
    Set status=pat.Allergies.Insert(allergy)
            
    Quit status
}

Storage Default
{
<Data name="PatientAllergyState">
<Value name="1">
<Value>Allergen</Value>
</Value>
<Value name="2">
<Value>Severity</Value>
</Value>
<Value name="3">
<Value>DiagnosedBy</Value>
</Value>
</Data>
<State>PatientAllergyState</State>
<StreamLocation>^DeepSee.Study.PatientAllergyS</StreamLocation>
<Type>%Library.CacheSerialState</Type>
}

}

