/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is for use with DeepSee. 
/// <p>It contains a cube based on DeepSee.Study.City. To view the cube definition, open
/// this class in Studio.
/// <p>The RelatedCubes/* cubes (like this one) use cube-to-cube relationships.
Class DeepSee.Model.RelCubes.RCities Extends %DeepSee.CubeDefinition [ DependsOn = DeepSee.Study.City ]
{

Parameter DOMAIN = "PATIENTSAMPLE";

XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube name="RelatedCubes/Cities" 
displayName="RelatedCubes/Cities"  
owner="_SYSTEM"
sourceClass="DeepSee.Study.City"
>
 
<relationship name="RelatedCubes/Doctors" displayName="Doctors"
relatedCube="RelatedCubes/Doctors"
cardinality="many"
inverse="RelatedCubes/Cities"
/>


<dimension name="CitiesD" 
displayName="CitiesD" 
allCaption="All Locations"
allDisplayName="All Locations">
<hierarchy name="H1">
<level name="ZIP" displayName="ZIP" 
sourceProperty="PostalCode" />
<level name="City" displayName="City" 
sourceProperty="Name" >
<property name="Population" displayName="Population" 
sourceProperty="Population" />
<property name="Principal Export" displayName="Principal Export" 
sourceProperty="PrincipalExport"  />
</level>
</hierarchy>
</dimension>

<measure name="Population" 
displayName="Population" 
sourceProperty="Population" 
 aggregate="SUM"/>

<measure name="Avg Population" 
displayName="Avg Population" 
sourceProperty="Population" 
 aggregate="AVG"/>

<listing name="Details" displayName="Details" 
fieldList='Name as "City",Population,PostalCode as "ZIP Code",PrincipalExport as "Principal Export"'>
</listing>

</cube>
}

}

