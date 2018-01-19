/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
Class DeepSee.Study.SetBuilder
{

ClassMethod Run(pSetName As %String = "MyDoctors")
{
	do:$$$ISOK(..Build(pSetName)) ..Test(pSetName)
}

ClassMethod Test(pSetName As %String = "MyDoctors") As %Status
{
	set tSC = $$$OK
	try {
		write !!,"Testing set: '"_pSetName_"'"
		#dim tSet As %DeepSee.SetBuilder.Definition
		set tSet = ##class(%DeepSee.SetBuilder.Definition).%GetInstance(pSetName, .tSC)
		quit:$$$ISERR(tSC)
		
		write !,"	member count with default Gender: ",tSet.%GetMemberCount(,.tSC)
		quit:$$$ISERR(tSC)
		
		set tParams("Gender") = "F"
		write !,"	member count with Gender=Female: ",tSet.%GetMemberCount(.tParams, .tSC)
		quit:$$$ISERR(tSC)
		
		set tResultSet = tSet.%Execute(.tParams, .tSC)
		quit:$$$ISERR(tSC)
		write !!,"Retrieved as ResultSet (Gender=F):"
		while tResultSet.%Next() { write !,"	- ID: ",tResultSet.%ROWID }
		
		set tSC = tSet.%GetAsArray(.tArray, .tParams)
		quit:$$$ISERR(tSC)
		write !!,"Retrieved as array (Gender=F):"
		zwrite tArray
		
		set tListingRS = tSet.%ExecuteListing("DoctorListing", .tParams, .tSC)
		quit:$$$ISERR(tSC)
		write !!,"Retrieved as Listing (Gender=F):"
		while tListingRS.%Next() { write !,"	- ",tListingRS.%Get("LastName"),", ",tListingRS.FirstName,"  (group: ",tListingRS.%GetData(3),")" }
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	if $$$ISERR(tSC) {
		w !,"An error occurred while testing the set:",!
		do $system.OBJ.DisplayError(tSC)
	}
	quit tSC
}

ClassMethod Build(pSetName As %String = "MyDoctors", pOverwrite As %Boolean = 0) As %Status
{
	set tSC = $$$OK
	try {
		if (pOverwrite  && ##class(%DeepSee.SetBuilder.Utils).%SetExists(pSetName, .tClassName)) {
			set tSC = $$Delete^%apiOBJ(tClassName, "-d")
			quit:$$$ISERR(tSC)
		}
		
		set tBuilder = ##class(%DeepSee.SetBuilder.Builder).%New()
		
		set tSC = tBuilder.New(pSetName)
		quit:$$$ISERR(tSC)
		write !,"Creating new set definition: '"_pSetName_"'"
		
		// select all doctors
		set tSC = tBuilder.AddSQL(.tAllDoctors, "SELECT ID, DoctorType FROM DeepSee_Study.Doctor")
		quit:$$$ISERR(tSC)
		
		// manually list a few interesting specialisms
		set tSC = tBuilder.AddValueList(.tSpecialisms, $lb("Internist", "Surgeon"))
		quit:$$$ISERR(tSC)
		
		// filter the list of all doctors to those with the required specialism
		set tSC = tBuilder.AddPropertyFilter(.tSpecialistDoctors, tAllDoctors, "DoctorType", tSpecialisms)
		quit:$$$ISERR(tSC)
		
		
		// add a parameter to parametrize the whole set
		do tBuilder.AddSetParameter("Gender", "M")
		
		
		// select all patients of the selected gender
		set tParams(1) = "%parameter.Gender"
		set tSC = tBuilder.AddSQL(.tPatients, "SELECT ID, PrimaryCarePhysician FROM DeepSee_Study.Patient WHERE Gender = ?",, .tParams)
		quit:$$$ISERR(tSC)
		
		set tAggregatedProps("PatientCount") = "count"
		set tSC = tBuilder.AddPropertySelector(.tDoctorsWithPatients, tPatients, "PrimaryCarePhysician", .tAggregatedProps)
		quit:$$$ISERR(tSC)
		
		set tSC = tBuilder.AddPropertyFilter(.tLowVolumeDoctors, tDoctorsWithPatients, "PatientCount",, $lb(1,2,3,4,5,6,7,8,9,10,11,12))
		quit:$$$ISERR(tSC)
		
		
		set tSC = tBuilder.AddIntersect(.tDoctors, $lb(tLowVolumeDoctors, tSpecialistDoctors))
		quit:$$$ISERR(tSC)
		
		
		write !,"Done creating definition, now saving..."
		do tBuilder.SetOutputOperator(tDoctors)
		set tSC = tBuilder.Save("DeepSee.Study.Sets."_pSetName)
		quit:$$$ISERR(tSC)
		
		
		// oh, I forgot one!
		set tSC = tBuilder.AddValuesToList(tSpecialisms, $lb("Emergency Physician"))
		quit:$$$ISERR(tSC)
		set tSC = tBuilder.AddListing("DoctorListing", "FirstName, LastName, DoctorGroup")
		quit:$$$ISERR(tSC)
		set tSC = tBuilder.Save() // class name is remembered
		quit:$$$ISERR(tSC)
		
		
	} catch (ex) {
		set tSC = ex.AsStatus()
	}
	if $$$ISERR(tSC) {
		w !,"An error occurred while creating the set:",!
		do $system.OBJ.DisplayError(tSC)
	}
	quit tSC
}

}

