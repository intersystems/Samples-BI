/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// <p>This class contains a cube based on BI.Model.PatientsQuery.
/// <p>This cube is not built by default.
Class BI.Model.PatientsQueryCube Extends %DeepSee.CubeDefinition [ DependsOn = BI.Model.PatientsQuery ]
{

Parameter DOMAIN = "PATIENTSAMPLE";

XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube 
name="PatientsQueryCube" displayName="PatientsQueryCube"  
 owner="_SYSTEM"
 sourceClass="BI.Model.PatientsQuery"
 nullReplacement="None"
>

<dimension name="AgeD" displayName="AgeD" 
sourceProperty="Age" 
allCaption="All Patients"  allDisplayName="All Patients">
<hierarchy name="H1" displayName="H1">
<level name="Age Group" displayName="Age Group"
rangeExpression="(,29]:0 to 29;[30,59]:30 to 59;[60,):60+;"
 factName="DxAgeGroup" />
<level name="Age Bucket" displayName="Age Bucket"
rangeExpression="(,9]:0 to 9;[10,19]:10 to 19;[20,29]:20 to 29;[30,39]:30 to 39;[40,49]:40 to 49;[50,59]:50 to 59;[60,69]:60 to 69;[70,79]:70 to 79;[80,):80+;"
 factName="DxAgeBucket"/>
<level name="Age" displayName="Age"
factName="DxAge">
</level>
</hierarchy>
</dimension>

<dimension name="GenD" displayName="GenD" hasAll="false">
<hierarchy name="H1" displayName="H1">
<level name="Gender" displayName="Gender"  
sourceProperty="Gender" 
rangeExpression="F:Female;M:Male;" 
 factName="DxGender"/>
</hierarchy>
</dimension>

<dimension name="HomeD" displayName="HomeD" hasAll="false">
<hierarchy name="H1" displayName="H1">
<level name="City" displayName="City" 
sourceProperty="HomeCity" 
factName="DxHomeCity">
</level>
</hierarchy>
</dimension>

<dimension name="PatGrpD" displayName="PatGrpD" hasAll="false">
<hierarchy name="H1" displayName="H1">
<level name="Patient Group" displayName="Patient Group" 
sourceProperty="PatientGroup"
 factName="DxPatGroup"/>
</hierarchy>
</dimension>

<measure name="Patient Count" displayName="Patient Count" 
sourceExpression="1" 
 aggregate="SUM" />
 
<measure name="Age" displayName="Age" 
sourceProperty="Age" 
aggregate="SUM" 
 factName="MxAge"/>

<measure name="Avg Age" displayName="Avg Age" 
sourceProperty="Age" 
 aggregate="AVG"/>

<measure name="Test Score" displayName="Test Score" 
sourceProperty="TestScore" 
 aggregate="SUM" searchable="true"/>

<measure name="Avg Test Score" displayName="Avg Test Score" 
sourceProperty="TestScore" 
 aggregate="AVG"/>

</cube>
}

}

