/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the DeepSee Patients sample, whose purpose is to provide
/// sample data for use with DeepSee. 
/// See the comments for the Diagnoses property in DeepSee.Study.Patient.
/// <p>This table is populated only if you use the D option when running the 
/// GenerateData() method in DeepSee.Populate.
Class DeepSee.Study.PatientDiagnosis2 Extends %Persistent
{

Relationship Patient As DeepSee.Study.Patient [ Cardinality = one, Inverse = DiagnosesAsMany ];

Property DiagnosisCode As %String;

Property DiagnosedBy As DeepSee.Study.Doctor;

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
<DataLocation>^DeepSee.Study.PatientDiag6F71D</DataLocation>
<DefaultData>PatientDiagnosis2DefaultData</DefaultData>
<IdLocation>^DeepSee.Study.PatientDiag6F71D</IdLocation>
<IndexLocation>^DeepSee.Study.PatientDiag6F71I</IndexLocation>
<StreamLocation>^DeepSee.Study.PatientDiag6F71S</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

