/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This simple plug-in demo provides two properties:
/// PatientCount, which behaves the same as the %COUNT measure </li>
/// HighScoreCount, which counts the patients with TestScore greater than 95. </li>
Class BI.Model.KPIs.PluginDemo Extends %DeepSee.KPIPlugIn
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
    set pMDX = "SELECT FROM "_..#BASECUBE
	quit $$$OK
}

/// As input, this method receives a statement result that is the result of a listing query
Method %OnCompute(pSQLRS As %SQL.StatementResult, pFactCount As %Integer) As %Status
{
	set tSC = $$$OK
	Try {
		// Place answer in KPI output
		set ..%seriesCount = 1
		set ..%seriesNames(1) = "PluginDemo"
		
		// Set Count property of KPI -- just use received pFactCount
        set ..%data(1,"PatientCount") = pFactCount

		// Iterate through result set to get HighScoreCount 
		set n = 0
		set highcount = 0
		while (pSQLRS.%Next(.tSC)) {
			if $$$ISERR(tSC) Quit
			set n = n + 1
			
			set testscore = pSQLRS.MxTestScore
			if (testscore>95) {
   			    set highcount = highcount + 1
			}

 			// Update pct complete
			if (n#100 = 0) {
				Do ..%SetPercentComplete(100*(n/pFactCount))
			}
		}
		set ..%data(1,"HighScoreCount") = highcount

	}
	catch(ex) {
		set tSC = ex.AsStatus()
	}
	quit tSC
}

}

