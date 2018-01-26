/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is for use in a compound cube (and can also be used on its own).
/// <p>To view the cube definition, open this class in Studio.
Class BI.Model.CompoundCube.CityRainfall Extends %DeepSee.CubeDefinition [ DependsOn = (BI.Study.CityRainfall, BI.Model.CompoundCube.Patients) ]
{

XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube 
name="CompoundCube/CityRainfall" 
displayName="CompoundCube/CityRainfall"  
owner="_SYSTEM"
sourceClass="BI.Study.CityRainfall"
countMeasureName="Rainfall Observation Count"
 >

<dimension name="BirthD" displayName="DateD" 
type="time" sourceProperty="MonthAndYear" 
allCaption="All Dates" allDisplayName="All Dates" 
sharesFrom="CompoundCube/Patients">
<hierarchy name="H1" displayName="H1" >
<level name="Year" displayName="Year" timeFunction="Year" />
<level name="MonthYear" displayName="MonthYear" timeFunction="MonthYear" />
</hierarchy>
<hierarchy name="H2" displayName="H2">
<level name="Month" displayName="Month" timeFunction="MonthNumber" />
</hierarchy>
</dimension>

<dimension name="HomeD" 
displayName="CitiesD" 
allCaption="All Locations"
allDisplayName="All Locations" 
sharesFrom="CompoundCube/Patients">
<hierarchy name="H1" >
<level name="ZIP" displayName="ZIP" 
sourceProperty="City.PostalCode" />
<level name="City" displayName="City" 
sourceProperty="City.Name" >
<property name="Population" displayName="Population" 
sourceProperty="City.Population" />
<property name="Principal Export" displayName="Principal Export" 
sourceProperty="City.PrincipalExport"  />
</level>
</hierarchy>
</dimension>



<measure name="Monthly Rainfall Inches" 
displayName="Monthly Rainfall Inches"
sourceProperty="InchesOfRain" 
 aggregate="SUM"/>

<measure name="Avg Monthly Rainfall Inches" 
displayName="Avg Monthly Rainfall Inches"
sourceProperty="InchesOfRain" 
 aggregate="AVG"/>

<listing name="Details" displayName="Details" 
  fieldList='City->Name as "City",MonthAndYear as "Date",InchesOfRain as "Inches of Rain"'>
</listing>

</cube>
}

}

