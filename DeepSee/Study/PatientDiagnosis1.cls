/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the DeepSee Patients sample, whose purpose is to provide
/// sample data for use with DeepSee. 
/// See the comments for the Diagnoses property in DeepSee.Study.Patient.
/// <p>This table is populated only if you use the D option when running the
/// GenerateData() method in DeepSee.Populate.
Class DeepSee.Study.PatientDiagnosis1 Extends %Persistent
{

Relationship Patient As DeepSee.Study.Patient [ Cardinality = parent, Inverse = DiagnosesAsChildren ];

Property DiagnosisCode As %String;

Property DiagnosedBy As DeepSee.Study.Doctor;

Index PatientIndex On Patient;

Storage Default
{
<Data name="PatientDiagnosis1DefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>DiagnosisCode</Value>
</Value>
<Value name="3">
<Value>DiagnosedBy</Value>
</Value>
</Data>
<DataLocation>{%%PARENT}("DiagnosesAsChildren")</DataLocation>
<DefaultData>PatientDiagnosis1DefaultData</DefaultData>
<IdLocation>^DeepSee.Study.PatientC("DiagnosesAsChildren")</IdLocation>
<IndexLocation>^DeepSee.Study.PatientDiag6E31I</IndexLocation>
<StreamLocation>^DeepSee.Study.PatientDiag6E31S</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

