/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is for use with DeepSee. 
/// <p>It contains a cube based on DeepSee.Study.CityRainfall To view the cube definition, open
/// this class in Studio.
/// <p>The RelatedCubes/* cubes (like this one) use cube-to-cube relationships.
Class DeepSee.Model.RelCubes.RCityRainfall Extends %DeepSee.CubeDefinition [ DependsOn = (DeepSee.Study.CityRainfall, DeepSee.Model.RelCubes.RCities) ]
{

XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube 
name="RelatedCubes/CityRainfall" 
displayName="RelatedCubes/CityRainfall"  
owner="_SYSTEM"
sourceClass="DeepSee.Study.CityRainfall"
 >

<relationship name="RelatedCubes/Cities" 
displayName="Cities" 
relatedCube="RelatedCubes/Cities" 
cardinality="one"
sourceProperty="City"
 />

<dimension name="DateD" displayName="DateD" 
type="time" sourceProperty="MonthAndYear" 
allCaption="All Dates" allDisplayName="All Dates">
<hierarchy name="H1" displayName="H1">
<level name="Year" displayName="Year" timeFunction="Year" />
<level name="MonthYear" displayName="MonthYear" timeFunction="MonthYear" />
</hierarchy>
<hierarchy name="H2" displayName="H2">
<level name="Month" displayName="Month" timeFunction="MonthNumber" />
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

