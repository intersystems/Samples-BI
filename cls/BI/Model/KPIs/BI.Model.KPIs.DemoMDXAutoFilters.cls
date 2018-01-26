/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
Class BI.Model.KPIs.DemoMDXAutoFilters Extends BI.Utils.MDXAutoFiltersKPI
{

Parameter CUBE = "PATIENTS";

Parameter DOMAIN = "PATIENTSAMPLE";

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi name="DemoMDXAutoFilters" displayName="DemoMDXAutoFilters"  
sourceType="mdx"
mdx="SELECT {[Measures].[%COUNT],[Measures].[Avg Age],[Measures].[Avg Allergy Count]} ON 0,NON EMPTY [DiagD].[H1].[Diagnoses].Members ON 1 FROM [Patients]">

<property name="Patient Count" displayName="Patient Count" columnNo="1" />
<property name="Avg Age" displayName="Avg Age" columnNo="2" />
<property name="Avg Allergy Count" displayName="Avg Allergy Count" columnNo="3" />

</kpi>
}

}

