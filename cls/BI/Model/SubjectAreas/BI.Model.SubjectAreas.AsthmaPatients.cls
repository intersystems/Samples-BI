/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is for use with InterSystems IRIS BI. 
/// <p>It contains a subject area based on the patients cube (BI.Model.PatientsCube). 
/// To view the subject area definition, open this class in Studio.
/// 
Class BI.Model.SubjectAreas.AsthmaPatients Extends %DeepSee.SubjectArea [ DependsOn = BI.Model.PatientsCube ]
{

/// This XData definition defines the SubjectArea.
XData SubjectArea [ XMLNamespace = "http://www.intersystems.com/deepsee/subjectarea" ]
{
<subjectArea name="AsthmaPatients" 
    displayName="Asthma Patients"
	baseCube="Patients" filterSpec="diagd.h1.diagnoses.asthma" >
	</subjectArea>
}

}

