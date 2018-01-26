/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// <p>This KPI class is intended for use in a dashboard that demos real-time updates using
/// the Patients sample. The actions in this class invoke methods in that sample
/// that add, change, or delete data.
/// <p>The actions are defined in the %OnDashboardAction() callback. The XData block in
/// this class contains one <action> element for each action, to advertise these actions
/// to the widget builder in the user interface.
/// <p>This KPI class also defines a simple one-cell KPI which is displayed in a text meter 
/// widget on that dashboard. (An alternative way to access these actions from ANY dashboard 
/// would be to use this class as the actionClass for the Patients cube.)
/// <p>To see the full KPI definition, open this class in Studio.
Class BI.Model.KPIs.DemoDataChanges Extends %DeepSee.KPI
{

Parameter DOMAIN = "PATIENTSAMPLE";

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi name="DemoDataChanges" 
displayName="DemoDataChanges"
sourceType="mdx" 
mdx="SELECT MEASURES.[%COUNT] ON 0 FROM [PATIENTS]">

<property name="PatCount" 
displayName="PatCount" 
 columnNo="1" />

<action name="AddPatients" 
displayName="AddPatients" />

<action name="ChangeFavoriteColors" 
displayName="ChangeFavoriteColors" />

<action name="ChangePatientGroups" 
displayName="ChangePatientGroups" />

<action name="AddEncounters" 
displayName="AddEncounters" />

<action name="DeleteSomePatients" 
displayName="DeleteSomePatients" />

<action name="ChangeSomeDoctors" 
displayName="ChangeSomeDoctors" />

</kpi>
}

ClassMethod %OnDashboardAction(pAction As %String, pContext As %ZEN.proxyObject) As %Status
{
 Set sc = $$$OK
 Try {
      If (pAction = "AddPatients") {
	      Job ##class(BI.Study.Patient).AddPatients()
          }
         Elseif (pAction="ChangeFavoriteColors")
         {
	         Job ##class(BI.Study.PatientDetails).ChangePatientDetails()
               }
         Elseif (pAction="ChangePatientGroups")
         {
	         Job ##class(BI.Study.Patient).ChangePatientGroups()
               }
         Elseif (pAction="AddEncounters")
         {
	         Job ##class(BI.Study.PatientEncounter).AddEncounters()
               }
         Elseif (pAction="DeleteSomePatients")
         {
	         Job ##class(BI.Study.Patient).DeleteSomePatients()
               }
         Elseif (pAction="ChangeSomeDoctors")
         {
	         Job ##class(BI.Study.Doctor).ChangeSomeDoctors()
               }
         }
        Catch(ex) {
                Set sc = ex.AsStatus()
        }
 Quit sc
}

}

