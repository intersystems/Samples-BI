/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is for use with DeepSee. 
/// <p>It contains a cube based on DeepSee.Study.Patients. 
/// To view the cube definition, open this class in Studio.
/// <p>The RelatedCubes/* cubes (like this one) use cube-to-cube relationships.
Class DeepSee.Model.RelCubes.RPatients Extends %DeepSee.CubeDefinition [ DependsOn = (DeepSee.Study.Patient, DeepSee.Model.RelCubes.RDoctors, DeepSee.Model.RelCubes.RCities) ]
{

Parameter DOMAIN = "PATIENTSAMPLE";

XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube 
name="RelatedCubes/Patients" displayName="RelatedCubes/Patients" 
owner="_SYSTEM"
sourceClass="DeepSee.Study.Patient"
nullReplacement="None"
disabled="false"
>

<relationship name="RelatedCubes/Cities" displayName="Cities"
relatedCube="RelatedCubes/Cities"
cardinality="one"
 sourceProperty="HomeCity"/>

<relationship name="RelatedCubes/Doctors" displayName="Doctors"
relatedCube="RelatedCubes/Doctors"
cardinality="one"
 sourceProperty="PrimaryCarePhysician"  nullReplacement="No Doctor"/>
 
<dimension name="AgeD" displayName="AgeD" 
allCaption="All Patients"  allDisplayName="All Patients">
<hierarchy name="H1" displayName="H1">
<level name="Age Group" displayName="Age Group"
sourceProperty="Age" 
rangeExpression="(,29]:0 to 29;[30,59]:30 to 59;[60,):60+;"
 factName="DxAgeGroup" />
<level name="Age Bucket" displayName="Age Bucket"
sourceExpression="##class(DeepSee.Model.PatientsCube).GetAgeBucket(%source.Age)" 
 factName="DxAgeBucket"/>
<level name="Age" displayName="Age"
sourceProperty="Age"
factName="DxAge">
<property name="Age" displayName="Age"
sourceExpression='$CASE($LENGTH(%source.Age),2:%source.Age,:"0"_%source.Age)'
sort="asc"
 factName="PxAge"/>
</level>
</hierarchy>
</dimension>

<dimension name="DiagD" displayName="DiagD" hasAll="false" >
<hierarchy name="H1" displayName="H1">
<level name="Diagnoses" displayName="Diagnoses"
list="true" 
sourceProperty="DiagnosesAsLB" 
factName="DxDiagnoses"> 
</level>
</hierarchy>
</dimension>

<dimension name="GenD" displayName="GenD" hasAll="false">
<hierarchy name="H1" displayName="H1">
<level name="Gender" displayName="Gender"  
sourceProperty="Gender" 
 useDisplayValue="true" factName="DxGender"/>
</hierarchy>
</dimension>

<dimension name="ColorD" displayName="ColorD" hasAll="false">
<hierarchy name="H1" displayName="H1">
<level name="Favorite Color" displayName="Favorite Color" 
sourceExpression='##class(DeepSee.Model.PatientsCube).GetFavoriteColor(%source.PatientID)' 
 factName="DxColor"/>
</hierarchy>
</dimension>

<dimension name="PatGrpD" displayName="PatGrpD" hasAll="false">
<hierarchy name="H1" displayName="H1">
<level name="Tested" displayName="Tested" 
sourceExpression='$SELECT(%source.TestScore="":"No",1:"Yes")' 
 factName="DxTested"/>
<level name="Patient Group" displayName="Patient Group" 
sourceExpression='$CASE(%source.PatientGroup,"A":"Group A","B":"Group B",:"None")'
 factName="DxPatGroup"/>
</hierarchy>
</dimension>

<measure name="Avg Age" displayName="Avg Age" 
sourceProperty="Age" 
 aggregate="AVG"/>

<measure name="Avg Allergy Count" displayName="Avg Allergy Count" 
type="integer"
sourceExpression='##class(DeepSee.Model.PatientsCube).GetAllergyCount(%source.%ID)' 
 aggregate="AVG" />

<measure name="Avg Test Score" displayName="Avg Test Score" 
sourceProperty="TestScore" 
 aggregate="AVG"/>

<listing name="Details" displayName="Details" 
 fieldList='PatientID,Age,Gender,HomeCity->Name AS "Home City",TestScore AS "Test Score",PrimaryCarePhysician'
  orderBy="Age,Gender" /> 

</cube>
}

}

