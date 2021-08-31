/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// See the comments for the Diagnoses property in BI.Study.Patient.
Class BI.Study.PatientDiagnosis Extends %SerialObject
{

Property DiagnosisCode As %String;

Property DiagnosedBy As BI.Study.Doctor;

Storage Default
{
<Data name="PatientDiagnosisState">
<Value name="1">
<Value>DiagnosisCode</Value>
</Value>
<Value name="2">
<Value>DiagnosedBy</Value>
</Value>
</Data>
<State>PatientDiagnosisState</State>
<StreamLocation>^BI.Study.PatientDiagnosisS</StreamLocation>
<Type>%Storage.Serial</Type>
}

}

