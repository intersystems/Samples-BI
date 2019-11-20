/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is for use in a compound cube (and can also be used on its own).
/// To view the cube definition, open this class in Studio.
Class BI.Model.CompoundCube.Patients Extends %DeepSee.CubeDefinition [ DependsOn = BI.Study.Patient ]
{

Parameter DOMAIN = "PATIENTSAMPLE";

XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube 
name="CompoundCube/Patients" 
displayName="CompoundCube/Patients" 
owner="_SYSTEM"
sourceClass="BI.Study.Patient"
nullReplacement="None"
disabled="false"
countMeasureName="Patient Count"
>

<dimension name="BirthD" displayName="BirthD" type="time" 
sourceProperty="BirthDate" hasAll="true" allDisplayName="All Patients"
description="These levels group patients by birth date">
<hierarchy name="H1" displayName="H1">
<level name="Decade" displayName="Decade" timeFunction="Decade" />
<level name="Year"  displayName="Year" timeFunction="Year"  />
<level name="Quarter Year" displayName="Quarter Year" timeFunction="QuarterYear" />
<level name="Period" displayName="Period" timeFunction="MonthYear" />
<level name="Date" displayName="Date" timeFunction="DayMonthYear" />
</hierarchy>
</dimension>

<dimension name="DocD" displayName="DocD" hasAll="false"
description="These levels group patients by their primary care physician (if any)."
>
<hierarchy name="H1" displayName="H1">
<level name="Doctor Group" displayName="Doctor Group" 
sourceProperty="PrimaryCarePhysician.DoctorGroup" 
 factName="DxDocGroup" description="Doctors are assigned to Doctor Groups, in this fictitious study."/>
<level name="Doctor" displayName="Doctor" 
sourceExpression="%source.PrimaryCarePhysician" 
factName="DxDoc" description="Duplicate names are possible. Keys are forced to be unique.">
<property name="Name" displayName="Name" 
isName="true" 
sort="asc" 
sourceExpression='%source.PrimaryCarePhysician.LastName_", "_%source.PrimaryCarePhysician.FirstName'
 factName="PxDoc"/>
</level>
</hierarchy>
</dimension>

<dimension name="DocTypeD" displayName="DocTypeD" 
hasAll="false">
<hierarchy name="H1" displayName="H1">
<level name="Doctor Type" displayName="Doctor Type"
sourceProperty="PrimaryCarePhysician.DoctorType"
factName="DxDocType" />
</hierarchy>
</dimension>

<dimension name="HomeD" displayName="HomeD" hasAll="false" 
description="These levels group patients by home address.">
<hierarchy name="H1" displayName="H1">
<level name="ZIP" displayName="ZIP" 
sourceProperty="HomeCity.PostalCode" 
 factName="DxHomeZIP"
 description="In this demo, cities are contained inside ZIP codes."/>
<level name="City" displayName="City" 
sourceProperty="HomeCity.Name"
factName="DxHomeCity" 
description="This level has two properties: one string and one numeric.">
<property name="Population" displayName="Population" 
sourceProperty="HomeCity.Population" 
 factName="PxPopulation"/>
<property name="Principal Export" displayName="Principal Export" 
sourceProperty="HomeCity.PrincipalExport" 
 factName="PxExport" />
</level>
</hierarchy>
</dimension>

<measure name="Avg Allergy Count" displayName="Avg Allergy Count" 
type="integer"
sourceExpression='##class(BI.Model.PatientsCube).GetAllergyCount(%source.%ID)' 
 aggregate="AVG" />

<measure name="Avg Test Score" displayName="Avg Test Score" 
sourceProperty="TestScore" 
 aggregate="AVG"/>

<listing name="Details" displayName="Details" 
 fieldList='PatientID,Age,Gender,HomeCity->Name AS "Home City",TestScore AS "Test Score"'
  orderBy="Age,Gender" /> 

</cube>
}

}

