/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is for use with DeepSee II. 
/// <p>It contains a subject area based on the patients cube (DeepSee.Model.PatientsCube). 
/// To view the subject area definition, open this class in Studio.
/// 
Class DeepSee.Model.SubjectAreas.YoungPatients Extends %DeepSee.SubjectArea [ DependsOn = DeepSee.Model.PatientsCube ]
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

