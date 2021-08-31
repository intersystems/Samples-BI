/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is for use with InterSystems IRIS BI. 
/// It contains a cube based on BI.Study.PatientAllergy1. To view the cube definition, open
/// this class in Studio or the BI Architect.
/// The RelatedCubes/* cubes (like this one) use cube-to-cube relationships.
Class BI.Model.RelCubes.RAllergies Extends %DeepSee.CubeDefinition [ DependsOn = (BI.Study.PatientAllergy1, BI.Model.RelCubes.RPatients), ProcedureBlock ]
{

Parameter DOMAIN = "PATIENTSAMPLE";

XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube xmlns="http://www.intersystems.com/deepsee" 
name="RelatedCubes/Allergies" displayName="RelatedCubes/Allergies" 
sourceClass="BI.Study.PatientAllergy1" countMeasureName="%COUNT" 
>
<relationship name="RelatedCubes/Patients" displayName="Patient"
relatedCube="RelatedCubes/Patients"
cardinality="one"
sourceProperty="Patient"
 nullReplacement="No Data Available"/>


  <dimension name="AllerD" hasAll="true" 
  allCaption="All Allergies" allDisplayName="All Allergies" type="data" >
    <hierarchy name="H1" disabled="false">
      <level name="Allergen" sourceProperty="Allergen.Description" nullReplacement="No Data Available">
      </level>
    </hierarchy>
  </dimension>
  <dimension name="SevD" hasAll="false" type="data" >
    <hierarchy name="H1" disabled="false">
      <level name="Severity" sourceProperty="Severity.Description" nullReplacement="No Data Available">
      </level>
    </hierarchy>
  </dimension>
  <measure name="%ID" disabled="false" sourceProperty="%ID" aggregate="COUNT" type="integer" hidden="true" searchable="false" iKnowSource="string"></measure>
</cube>
}

}

