/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class defines a compound cube.
/// <p>To view the cube definition, open this class in Studio.
Class BI.Model.CompoundCube.CompoundCube Extends %DeepSee.SubjectArea [ DependsOn = (BI.Model.CompoundCube.Patients, BI.Model.CompoundCube.Doctors, BI.Model.CompoundCube.CityRainfall) ]
{

/// This XData definition defines the SubjectArea.
XData SubjectArea [ XMLNamespace = "http://www.intersystems.com/deepsee/subjectarea" ]
{
<subjectArea name="CompoundCube/CompoundCube"  displayName="CompoundCube/CompoundCube"
	baseCube="CompoundCube/Patients,CompoundCube/Doctors,CompoundCube/CityRainfall"  >
	</subjectArea>
}

}

