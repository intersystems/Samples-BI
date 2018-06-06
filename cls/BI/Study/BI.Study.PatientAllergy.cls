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
    Set status=$$$OK

    //First decide if patient has no known allergies
    If ##class(BI.Populate).RandomTrue(15) {
	    // assume ID 1 is the nil allergen
	    Set allergen=##class(BI.Study.Allergen).%OpenId(1,0)
	    Set status=..AddAllergy(pat,allergen,genNulls)
	    Quit status
	    }
    
    //iterate through remaining allergens and randomly assign to patient
    Set allergencount=##class(BI.Populate).Count("BI.Study.Allergen")
    For i=2:1:allergencount {
	    If ##class(BI.Populate).RandomTrue(5) {
		    Set allergen=##class(BI.Study.Allergen).%OpenId(i,0)
	        Set status=..AddAllergy(pat,allergen,genNulls)
	        }
	    }
    
    Quit status
}

/// adds the given allergen to the patient and returns the patient by reference
ClassMethod AddAllergy(ByRef pat, allergen As BI.Study.Allergen, genNulls As %Boolean) As %Status
{
    Set status=$$$OK

    Set allergy=..%New()
    Set allergy.Allergen=allergen
    
	if (allergen.Code'="000") {

		Set sevid=##class(BI.Populate).GetRandomId("BI.Study.AllergySeverity")
		Set allergy.Severity=##class(BI.Study.AllergySeverity).%OpenId(sevid,0)

		Set docid=##class(BI.Populate).GetRandomId("BI.Study.Doctor")
		Set allergy.DiagnosedBy=##class(BI.Study.Doctor).%OpenId(docid,0)
	}
            
	If genNulls {
		//for some percent of allergies, severity is not recorded
		If ##class(BI.Populate).RandomTrue(2){
			Set allergy.Severity=""
		}
		//for some percent of allergies, diagnosing doctor is not recorded
		If ##class(BI.Populate).RandomTrue(8){
			Set allergy.DiagnosedBy=""
		}
	}

    //now add this to the patient 
    Set status=pat.Allergies.Insert(allergy)

    //create the same data in the PatientAllergy1 table 
    set status=##class(BI.Study.PatientAllergy1).CreateOne(pat,allergen,allergy.Severity,allergy.DiagnosedBy)
            
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
<StreamLocation>^BI.Study.PatientAllergyS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}

