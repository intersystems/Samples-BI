/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class contains a cube based on BI.Study.CityRainfall. 
/// The dimension, hierarchy, and level definitions here use the same names
/// as in the Patients cube, so that these cubes can be used together.
Class BI.Model.RainfallCube Extends %DeepSee.CubeDefinition [ DependsOn = BI.Study.CityRainfall ]
{

Parameter DOMAIN = "PATIENTSAMPLE";

XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube 
name="CityRainfall" displayName="CityRainfall"   
 owner="_SYSTEM"
 caption="City Rainfall Data"
 sourceClass="BI.Study.CityRainfall"
 >

<dimension name="HomeD" displayName="CityD" 
allCaption="All Cities"  allDisplayName="All Cities" >
<hierarchy name="H1" displayName="H1">
<level name="ZIP" displayName="ZIP" 
sourceProperty="City.PostalCode" />
<level name="City" displayName="City" 
sourceProperty="City">
<property name="Population" displayName="Population" 
sourceProperty="City.Population" />
<property name="Principal Export" displayName="Principal Export" 
sourceProperty="City.PrincipalExport" />
 <property name="Name" displayName="Name"
 sourceProperty="City.Name" 
 isReference="true"
  isName="true" hidden="true" />
</level>
</hierarchy>
</dimension>

<dimension name="BirthD" displayName="DateD" type="time" 
sourceProperty="MonthAndYear" hasAll="false">
<hierarchy name="H1" displayName="H1">
<level name="Decade" displayName="Decade"  timeFunction="Decade"  />
<level name="Year" displayName="Year" timeFunction="Year" />
<level name="Quarter Year" displayName="Quarter Year" timeFunction="QuarterYear" />
<level name="Period" displayName="Period" timeFunction="MonthYear" />
<level name="Date" displayName="Date" timeFunction="DayMonthYear" />
</hierarchy>
</dimension>

<dimension name="BirthQD" displayName="QuarterD" type="time" 
sourceProperty="MonthAndYear" hasAll="false">
<hierarchy name="H1" displayName="H1">
<level name="Quarter" displayName="Quarter" timeFunction="QuarterNumber" />
<level name="Month" displayName="Month" timeFunction="MonthNumber" />
</hierarchy>
</dimension>

<measure name="Rainfall Inches" displayName="Rainfall Inches" 
sourceProperty="InchesOfRain" 
aggregate="SUM"/>

<measure name="Avg Rainfall Inches" displayName="Avg Rainfall Inches" 
sourceProperty="InchesOfRain" 
aggregate="AVG"/>

<listing name="Details" displayName="Details" 
  fieldList='City->Name as "City",MonthAndYear as "Date",InchesOfRain as "Inches of Rain"'>
</listing>

</cube>
}

}

