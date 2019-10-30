/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// <p>This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// See the comments for the Diagnoses property in BI.Study.Patient.
/// <p>This table is populated only if you use the D option when running the 
/// GenerateData() method in BI.Populate.
Class BI.Study.PatientDiagnosis2 Extends %Persistent
{

Relationship Patient As BI.Study.Patient [ Cardinality = one, Inverse = DiagnosesAsMany ];

Property DiagnosisCode As %String;

Property DiagnosedBy As BI.Study.Doctor;

Index PatientIndex On Patient;

}

