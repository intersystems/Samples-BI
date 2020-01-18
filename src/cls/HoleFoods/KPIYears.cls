/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This KPI class provides the list of values for the 
/// Years pivot variable of the HoleFoods cube.
Class HoleFoods.KPIYears Extends %DeepSee.KPI
{

Parameter DOMAIN = "PATIENTSAMPLE";

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi name="HoleFoodsYears" 
displayName="HoleFoodsYears"  
sourceType="mdx"
mdx="SELECT [DateOfSale].[Actual].[YearSold].CURRENTMEMBER.Properties(&quot;Key&quot;) ON 0,NON EMPTY [DateOfSale].[Actual].[YearSold].Members ON 1 FROM [HOLEFOODS]" 
>

<property name="Value" 
displayName="Value" 
 columnNo="1" />

</kpi>
}

}

