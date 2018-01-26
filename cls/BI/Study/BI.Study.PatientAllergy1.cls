/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// <p>This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// <p>
/// An allergy has multiple pieces of information,
/// which you can use separately or in combination to create dimensions, depending
/// on what you want to see.
Class BI.Study.PatientAllergy1 Extends %Persistent
{

/// Patient who has this allergy
Property Patient As BI.Study.Patient;

/// A substance to which the patient is allergic.
Property Allergen As BI.Study.Allergen;

/// Severity of this allergic reaction.
Property Severity As BI.Study.AllergySeverity;

/// Doctor who recorded this allergic reaction.
Property DiagnosedBy As BI.Study.Doctor;

ClassMethod CreateOne(patient As BI.Study.Patient, allergen As BI.Study.Allergen = "", severity As BI.Study.AllergySeverity = "", diagnosedBy As BI.Study.Doctor = "") As %Status
{
	set new=..%New()
	set new.Patient=patient
	if (allergen'="") {
		set new.Allergen=allergen
	}
	if (severity'="") {
		set new.Severity=severity
	}
	if (diagnosedBy'="") {
		set new.DiagnosedBy=diagnosedBy
	}
	set status=new.%Save()
	quit status
}

Storage Default
{
<Data name="PatientAllergy1DefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Allergen</Value>
</Value>
<Value name="3">
<Value>Severity</Value>
</Value>
<Value name="4">
<Value>DiagnosedBy</Value>
</Value>
<Value name="5">
<Value>Patient</Value>
</Value>
</Data>
<DataLocation>^BI.Study.PatientAllergy1D</DataLocation>
<DefaultData>PatientAllergy1DefaultData</DefaultData>
<IdLocation>^BI.Study.PatientAllergy1D</IdLocation>
<IndexLocation>^BI.Study.PatientAllergy1I</IndexLocation>
<StreamLocation>^BI.Study.PatientAllergy1S</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

