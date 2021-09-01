/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// See the comments for the Diagnoses property in BI.Study.Patient.
/// This table is populated only if you use the D option when running the 
/// GenerateData() method in BI.Populate.
Class BI.Study.PatientDiagnosis2 Extends %Persistent
{

Relationship Patient As BI.Study.Patient [ Cardinality = one, Inverse = DiagnosesAsMany ];

Property DiagnosisCode As %String;

Property DiagnosedBy As BI.Study.Doctor;

Index PatientIndex On Patient;

Storage Default
{
<Data name="PatientDiagnosis2DefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Patient</Value>
</Value>
<Value name="3">
<Value>DiagnosisCode</Value>
</Value>
<Value name="4">
<Value>DiagnosedBy</Value>
</Value>
</Data>
<DataLocation>^BI.Study.PatientDiagnosis2D</DataLocation>
<DefaultData>PatientDiagnosis2DefaultData</DefaultData>
<IdLocation>^BI.Study.PatientDiagnosis2D</IdLocation>
<IndexLocation>^BI.Study.PatientDiagnosis2I</IndexLocation>
<StreamLocation>^BI.Study.PatientDiagnosis2S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

