/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the DeepSee Patients sample, whose purpose is to provide
/// sample data for use with DeepSee. 
/// See the comments for the Diagnoses property in DeepSee.Study.Patient.
Class DeepSee.Study.PatientDiagnosis Extends %SerialObject
{

Property DiagnosisCode As %String;

Property DiagnosedBy As DeepSee.Study.Doctor;

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
<StreamLocation>^DeepSee.Study.PatientDiagB1A7S</StreamLocation>
<Type>%Library.CacheSerialState</Type>
}

}

