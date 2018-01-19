/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This KPI class provides the list of values for the 
/// Years pivot variable of the Patients cube.
Class DeepSee.Model.KPIs.Years Extends %DeepSee.KPI
{

Parameter DOMAIN = "PATIENTSAMPLE";

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi name="PatientsYears" 
displayName="PatientsYears"  
sourceType="mdx"
mdx="SELECT [BirthD].[H1].[Year].CURRENTMEMBER.Properties(&quot;Key&quot;) ON 0,NON EMPTY [BirthD].[H1].[Year].Members ON 1 FROM [patients]" 
>

<property name="Value" 
displayName="Value" 
 columnNo="1" />

</kpi>
}

}

