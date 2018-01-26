/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is for use in a compound cube (and can also be used on its own).
/// <p>To view the cube definition, open this class in Studio.
Class BI.Model.CompoundCube.Doctors Extends %DeepSee.CubeDefinition [ DependsOn = (BI.Study.Doctor, BI.Model.CompoundCube.Patients) ]
{

Parameter DOMAIN = "PATIENTSAMPLE";

XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube 
name="CompoundCube/Doctors" 
displayName="CompoundCube/Doctors" 
owner="_SYSTEM"
sourceClass="BI.Study.Doctor"
nullReplacement="None"
 disabled="false"
 countMeasureName="Doctor Count"
>

<dimension name="DocD" displayName="DocD" 
allCaption="All Doctors"  allDisplayName="All Doctors"
sharesFrom="CompoundCube/Patients">
<hierarchy name="H1" displayName="H1">
<level name="Doctor Group" displayName="Doctor Group" 
sourceProperty="DoctorGroup" 
 factName="DxDocGroup"/>
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
hasAll="false" sharesFrom="CompoundCube/Patients" >
<hierarchy name="H1" displayName="H1">
<level name="Doctor Type" displayName="Doctor Type"
sourceProperty="DoctorType"
factName="DxDocType" />
</hierarchy>
</dimension>

<dimension name="HomeD" 
displayName="CitiesD" 
allCaption="All Locations"
allDisplayName="All Locations" 
sharesFrom="CompoundCube/Patients">
<hierarchy name="H1" >
<level name="ZIP" displayName="ZIP" 
sourceProperty="MainCity.PostalCode" />
<level name="City" displayName="City" 
sourceProperty="MainCity.Name" >
<property name="Population" displayName="Population" 
sourceProperty="MainCity.Population" />
<property name="Principal Export" displayName="Principal Export" 
sourceProperty="MainCity.PrincipalExport"  />
</level>
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

