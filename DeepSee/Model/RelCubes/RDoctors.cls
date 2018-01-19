/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is for use with DeepSee II. 
/// <p>It contains a cube based on DeepSee.Study.Doctors. 
/// To view the cube definition, open this class in Studio.
/// <p>The RelatedCubes/* cubes (like this one) use cube-to-cube relationships.
Class DeepSee.Model.RelCubes.RDoctors Extends %DeepSee.CubeDefinition [ DependsOn = (DeepSee.Study.Doctor, DeepSee.Model.RelCubes.RCities) ]
{

Parameter DOMAIN = "PATIENTSAMPLE";

XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube 
name="RelatedCubes/Doctors" displayName="RelatedCubes/Doctors" 
owner="_SYSTEM"
sourceClass="DeepSee.Study.Doctor"
nullReplacement="None"
 disabled="false">

<relationship name="RelatedCubes/Cities" 
displayName="Cities" 
relatedCube="RelatedCubes/Cities" 
inverse="RelatedCubes/Doctors" 
cardinality="one"
sourceProperty="MainCity"
 />

<dimension name="DocD" displayName="DocD" 
allCaption="All Doctors"  allDisplayName="All Doctors">
<hierarchy name="H1" displayName="H1">
<level name="Doctor Group" displayName="Doctor Group" 
sourceProperty="DoctorGroup" 
 factName="DxDocGroup" nullReplacement="No Doctor Group"/>
<level name="Doctor" displayName="Doctor" 
sourceExpression="%source.%ID" 
factName="DxDoc">
<property name="Name" displayName="Name" 
isName="true" 
sort="asc" 
sourceExpression='%source.LastName_", "_%source.FirstName'
 factName="PxDoc"/>
</level>
</hierarchy>
</dimension>

<dimension name="DocTypeD" displayName="DocTypeD" 
hasAll="false">
<hierarchy name="H1" displayName="H1">
<level name="Doctor Type" displayName="Doctor Type"
sourceProperty="DoctorType"
factName="DxDocType" />
</hierarchy>
</dimension>


<dimension name="SetBuilderD" displayName="Sets" 
type="computed" dimensionClass="%DeepSee.SetBuilder.ComputedDimension" >
<hierarchy name="H1" >
<level name="Set" />
</hierarchy>
</dimension>

<measure name="Patients Per Week" 
displayName="Patients Per Week" 
sourceProperty="PatientsPerWeek" 
 aggregate="SUM"/>

<measure name="Avg Patients Per Week" 
displayName="Avg Patients Per Week" 
sourceProperty="PatientsPerWeek" 
 aggregate="AVG"/>
 
<listing name="Details" displayName="Details" 
  fieldList='FirstName as "First Name",LastName as "Last Name",DoctorType as "Doctor Type",DoctorGroup as "Doctor Group",PatientsPerWeek as "Patients Per Week",MainCity->Name AS "Main City"'>
</listing>

</cube>
}

}

