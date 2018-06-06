/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// <p>This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// See the comments for the Diagnoses property in BI.Study.Patient.
/// <p>This table is populated only if you use the D option when running the
/// GenerateData() method in BI.Populate.
Class BI.Study.PatientDiagnosis1 Extends %Persistent
{

Relationship Patient As BI.Study.Patient [ Cardinality = parent, Inverse = DiagnosesAsChildren ];

Property DiagnosisCode As %String;

Property DiagnosedBy As BI.Study.Doctor;

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
<IdLocation>^BI.Study.PatientC("DiagnosesAsChildren")</IdLocation>
<IndexLocation>^BI.Study.PatientDiag6E31I</IndexLocation>
<StreamLocation>^BI.Study.PatientDiag6E31S</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

