/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the DeepSee Patients sample, whose purpose is to provide
/// sample data for use with DeepSee. 
/// <p>This class contains the doctors. 
Class DeepSee.Study.Doctor Extends %Persistent
{

Property FirstName As %String(MAXLEN = 100);

Property LastName As %String(MAXLEN = 100);

/// City where this doctor primarily works;
Property MainCity As DeepSee.Study.City;

/// Group into which this "study" places this doctor
Property DoctorGroup As %String;

/// Primary focus of this doctor's work;
Property DoctorType As %String;

/// Average number of patients that this doctor sees per week
/// (included to provide a numeric value in this table)
Property PatientsPerWeek As %Numeric;

/// This method reads the XData block in this class and uses it to populate the table. 
/// This method is called by DeepSee.Populate:GenerateData().
ClassMethod GenerateData(count As %Integer = 100, genNulls = 1) As %Status
{
    Set status=$$$OK
    //first kill extent
    //never use %KillExtent() in a real application
    Do ..%KillExtent()

    For n = 1:1:count {
        Set doc = ##class(DeepSee.Study.Doctor).%New()
        Set doc.FirstName = ##class(%PopulateUtils).FirstName()
        Set doc.LastName = ##class(%PopulateUtils).LastName()
        
        //assign to a doctor group
        Set grouplist=$LB("I","II","III")
        Set groupID=$RANDOM($LISTLENGTH(grouplist))+1
        Set doc.DoctorGroup=$LI(grouplist,groupID)

        //Set PatientsPerWeek property
        Set doc.PatientsPerWeek=130+$RANDOM(40)
        
        //null out the previous two properties in some cases
        If (genNulls && ##class(DeepSee.Populate).RandomTrue(20)){
            Set doc.PatientsPerWeek=""
            Set doc.DoctorGroup=""
            }
        

        //Select a city
        Set cityid=##class(DeepSee.Populate).GetRandomId("DeepSee.Study.City")          
        Set doc.MainCity=##class(DeepSee.Study.City).%OpenId(cityid,0)

        //Specify the doctor type; these are assigned nearly randomly
        If ##class(DeepSee.Populate).RandomTrue(60) {
            Set typelist=$LB("General Physician","Internist","Pediatrician","OB/GYN")
            Set typeid=$RANDOM($LISTLENGTH(typelist))+1
            Set doc.DoctorType=$LI(typelist,typeid)
            }
            Else {
                Set typelist=$LB("Anesthesiologist","Allergist","Cardiologist","Dermatologist",
                        "Emergency Physician","Gastroenterologist","Radiologist","Surgeon")
                Set typeid=$RANDOM($LISTLENGTH(typelist))+1
                Set doc.DoctorType=$LI(typelist,typeid)
	            }

        Set status=doc.%Save()
        If $$$ISERR(status) {Do $System.Status.DisplayError(status)}

   }

   //create an "extent set" from which we can later get random IDs
   Set status=##class(DeepSee.Populate).UpdateIdCache($CLASSNAME())
   Quit status
}

/// Randomly change doctor group and patients per week for some doctors. 
/// If rebuild is 1, this method updates the DeepSee indices for each patient affected
/// by these changes. For DeepSee I, use this option only if you have enabled incremental updates
/// (otherwise, you needlessly slow down the method).
ClassMethod ChangeSomeDoctors(percent As %Numeric = 20, rebuild As %Boolean = 1)
{
    Set ^DeepSee.Study.Log($I(^DeepSee.Study.Log))=$zdatetime($h,2,3)_" Changing some doctor data..."

    //create an "extent set" from which we can later get random IDs
    Set status=##class(DeepSee.Populate).UpdateIdCache($CLASSNAME())

    Set changecount=0
    Set listLength=##class(DeepSee.Populate).Count($CLASSNAME())
    //throw the dice once as many times as we have doctors; not the same as 
    //looping through doctors but close in overall effect
    For i=1:1:listLength {
         If ##class(DeepSee.Populate).RandomTrue(percent)
         {
            Set docid=##class(DeepSee.Populate).GetRandomId($CLASSNAME())
            Set doc=..%OpenId(docid)

            //assign to a doctor group
            Set grouplist=$LB("I","II","III")
            Set groupID=$RANDOM($LISTLENGTH(grouplist))+1
            Set doc.DoctorGroup=$LI(grouplist,groupID)

            //Set PatientsPerWeek property
            Set doc.PatientsPerWeek=130+$RANDOM(40)
            Do doc.%Save()
            
            If rebuild {
	            //Because doctors are in a separate table, changing info for a 
                //doctor does NOT fire any triggers for the patients, 
                //so it is necessary to figure out which patients are affected 
                //and update the indices for those patients
            
                Set myquery="SELECT ID FROM DeepSee_Study.Patient WHERE PrimaryCarePhysician=?"
                Set rset=##class(%ResultSet).%New("%DynamicQuery:SQL")
                Set status=rset.Prepare(myquery)
                If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
                Set status=rset.Execute(docid)
                If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
                    While rset.Next() {
                    Set patid=rset.Data("ID")
                  
                    //The following line applies to DeepSee I
                    //Do ##class(DeepSee.Study.Patient).zzBuildOne(patid)
                    
                    //The following line applies to DeepSee II
                    Do ##class(%DeepSee.Utils).%ProcessFact("patients",patid)

                    }
                }
          Set changecount=changecount+1
         }
        } 

    //If rebuild {Kill %this} ; needed because zzBuildOne doesn't clean this up
    Set ^DeepSee.Study.Log($I(^DeepSee.Study.Log))=$zdatetime($h,2,3)_" "_changecount_" doctors changed"
}

Storage Default
{
<Data name="DoctorDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>FirstName</Value>
</Value>
<Value name="3">
<Value>LastName</Value>
</Value>
<Value name="4">
<Value>MainCity</Value>
</Value>
<Value name="5">
<Value>DoctorGroup</Value>
</Value>
<Value name="6">
<Value>DoctorType</Value>
</Value>
<Value name="7">
<Value>PatientsPerWeek</Value>
</Value>
</Data>
<DataLocation>^DeepSee.Study.DoctorD</DataLocation>
<DefaultData>DoctorDefaultData</DefaultData>
<IdLocation>^DeepSee.Study.DoctorD</IdLocation>
<IndexLocation>^DeepSee.Study.DoctorI</IndexLocation>
<StreamLocation>^DeepSee.Study.DoctorS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

