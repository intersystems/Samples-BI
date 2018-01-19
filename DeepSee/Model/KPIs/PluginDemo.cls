/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This simple plug-in demo provides two properties:
/// <ul>
/// <li>PatientCount, which behaves the same as the %COUNT measure </li>
/// <li>HighScoreCount, which counts the patients with TestScore greater than 95. </li>
/// </ul>
Class DeepSee.Model.KPIs.PluginDemo Extends %DeepSee.KPIPlugIn
{

/// Display this one in the Analyzer
Parameter PUBLIC = 1;

/// This plug-in works only with one cube
Parameter BASECUBE = "Patients";

/// Query the fact table rather than the source table
Parameter LISTINGSOURCE = "FactTable";

/// Display this plug-in in the Analyzer for drag & drop use
Parameter PLUGINTYPE = "Pivot";

/// Specifies the field list (RETURN clause) of the listing used to supply data for this
/// plug-in.
Parameter LISTINGFIELDS As STRING = "MxTestScore";

XData KPI [ XMLNamespace = "http://www.intersystems.com/deepsee/kpi" ]
{
<kpi name="PluginDemo" displayName="PluginDemo" caption="PluginDemo" >

<property name="PatientCount" displayName="PatientCount" description="Count the records" />
<property name="HighScoreCount" displayName="HighScoreCount" 
description="Count the patients with a high test score (>95)" />

</kpi>
}

/// Get the base query for this plug-in.
Method %OnGetMDX(ByRef pMDX As %String) As %Status
{
    Set pMDX = "SELECT FROM "_..#BASECUBE
	Quit $$$OK
}

/// As input, this method receives a statement result that is the result of a listing query
Method %OnCompute(pSQLRS As %SQL.StatementResult, pFactCount As %Integer) As %Status
{
	Set tSC = $$$OK
	Try {
		// place answer in KPI output
		Set ..%seriesCount = 1
		Set ..%seriesNames(1) = "PluginDemo"
		//set Count property of KPI -- just use received pFactCount
        Set ..%data(1,"PatientCount") = pFactCount

		// iterate through result set to get HighScoreCount 
		set n = 0
		Set highcount = 0
		While (pSQLRS.%Next(.tSC)) {
			If $$$ISERR(tSC) Quit
			set n = n + 1
			
			Set testscore = pSQLRS.MxTestScore
			if (testscore>95) {
   			    Set highcount = highcount + 1
			}

 			// update pct complete
			If (n#100 = 0) {
				Do ..%SetPercentComplete(100*(n/pFactCount))
			}
		}
		Set ..%data(1,"HighScoreCount") = highcount

	}
	Catch(ex) {
		Set tSC = ex.AsStatus()
	}
	Quit tSC
}

}

