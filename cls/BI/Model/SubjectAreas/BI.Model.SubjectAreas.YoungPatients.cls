/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is for use with InterSystems IRIS BI. 
/// It contains a subject area based on the patients cube (BI.Model.PatientsCube). 
/// To view the subject area definition, open this class in Studio.
/// 
Class BI.Model.SubjectAreas.YoungPatients Extends %DeepSee.SubjectArea [ DependsOn = BI.Model.PatientsCube ]
{

/// This XData definition defines the SubjectArea.
XData SubjectArea [ XMLNamespace = "http://www.intersystems.com/deepsee/subjectarea" ]
{
<subjectArea name="YoungPatients" 
    displayName="Young Patients"
	baseCube="Patients" filterSpec="aged.h1.[age group].[0 to 29]" >
	</subjectArea>
}

}

