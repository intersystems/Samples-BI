/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// <p>This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// <p>This class contains the doctors. 
Class BI.Study.Doctor Extends %Persistent
{

Property FirstName As %String(MAXLEN = 100);

Property LastName As %String(MAXLEN = 100);

/// City where this doctor primarily works;
Property MainCity As BI.Study.City;

/// Group into which this "study" places this doctor
Property DoctorGroup As %String;

/// Primary focus of this doctor's work;
Property DoctorType As %String;

/// Average number of patients that this doctor sees per week
/// (included to provide a numeric value in this table)
Property PatientsPerWeek As %Numeric;

/// This method reads the XData block in this class and uses it to populate the table. 
/// This method is called by BI.Populate:GenerateData().
ClassMethod GenerateData(count As %Integer = 100, genNulls = 1) As %Status
{
    Set status=$$$OK
    //first kill extent
    //never use %KillExtent() in a real application
    Do ..%KillExtent()
    set ^BI.Study.SetupData("Pediatricians")=""
    set ^BI.Study.SetupData("OBGYNs")=""
    set ^BI.Study.SetupData("OtherDoctors")=""
    

    For n = 1:1:count {
        Set doc = ##class(BI.Study.Doctor).%New()
        Set doc.FirstName = ##class(%PopulateUtils).FirstName()
        Set doc.LastName = ##class(%PopulateUtils).LastName()
        
        //assign to a doctor group
        Set grouplist=$LB("I","II","III")
        Set groupID=$RANDOM($LISTLENGTH(grouplist))+1
        Set doc.DoctorGroup=$LI(grouplist,groupID)

        //Set PatientsPerWeek property
        Set doc.PatientsPerWeek=130+$RANDOM(40)
        
        //null out the previous two properties in some cases
        If (genNulls && ##class(BI.Populate).RandomTrue(20)){
            Set doc.PatientsPerWeek=""
            Set doc.DoctorGroup=""
            }
        

        //Select a city
        Set cityid=##class(BI.Populate).GetRandomId("BI.Study.City")          
        Set doc.MainCity=##class(BI.Study.City).%OpenId(cityid,0)

        //Specify the doctor type; these are assigned somewhat randomly
        If ##class(BI.Populate).RandomTrue(70) {
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
	    if (doc.DoctorType="Pediatrician") {
		    set ^BI.Study.SetupData("Pediatricians")=^BI.Study.SetupData("Pediatricians")_","_n
	    } elseif (doc.DoctorType="OB/GYN") {
		    set ^BI.Study.SetupData("OBGYNs")=^BI.Study.SetupData("OBGYNs")_","_n
	    } else {
		    set ^BI.Study.SetupData("OtherDoctors")=^BI.Study.SetupData("OtherDoctors")_","_n
	    }

        Set status=doc.%Save()
        If $$$ISERR(status) {Do $System.Status.DisplayError(status)}

   }
   set ^BI.Study.SetupData("Pediatricians")=$ZSTRIP(^BI.Study.SetupData("Pediatricians"),"<",",")
   set ^BI.Study.SetupData("OBGYNs")=$ZSTRIP(^BI.Study.SetupData("OBGYNs"),"<",",")

   //create an "extent set" from which we can later get random IDs
   Set status=##class(BI.Populate).UpdateIdCache($CLASSNAME())
   Quit status
}

/// Randomly change doctor group and patients per week for some doctors. 
/// If rebuild is 1, this method updates the BI indices for each patient affected
/// by these changes. 
ClassMethod ChangeSomeDoctors(percent As %Numeric = 20, rebuild As %Boolean = 1)
{
    Set ^BI.Study.Log($I(^BI.Study.Log))=$zdatetime($h,2,3)_" Changing some doctor data..."

    //create an "extent set" from which we can later get random IDs
    Set status=##class(BI.Populate).UpdateIdCache($CLASSNAME())

    Set changecount=0
    Set listLength=##class(BI.Populate).Count($CLASSNAME())
    //throw the dice once as many times as we have doctors; not the same as 
    //looping through doctors but close in overall effect
    For i=1:1:listLength {
         If ##class(BI.Populate).RandomTrue(percent)
         {
            Set docid=##class(BI.Populate).GetRandomId($CLASSNAME())
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
            
                Set myquery="SELECT ID FROM BI_Study.Patient WHERE PrimaryCarePhysician=?"
                Set rset=##class(%ResultSet).%New("%DynamicQuery:SQL")
                Set status=rset.Prepare(myquery)
                If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
                Set status=rset.Execute(docid)
                If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
                    While rset.Next() {
                    Set patid=rset.Data("ID")
                 
                    Do ##class(%DeepSee.Utils).%ProcessFact("patients",patid)

                    }
                }
          Set changecount=changecount+1
         }
        } 

    //If rebuild {Kill %this} ; needed because zzBuildOne doesn't clean this up
    Set ^BI.Study.Log($I(^BI.Study.Log))=$zdatetime($h,2,3)_" "_changecount_" doctors changed"
}

/// Based on patient age (in years) and gender ("F" or "M"), return the ID of a suitable doctor
ClassMethod GetDoctorId(patientAge As %Integer = "", patientGender As %String = "") As %Integer
{
    if (patientAge="") {
	    quit ..GetRandomOtherDoctor()
    } elseif (patientAge<12)	{
	    If ##class(BI.Populate).RandomTrue(90) {
		    quit ..GetRandomPediatrician()
	    } else {
		    quit ..GetRandomOtherDoctor()
	    }
    } 
    
    if (patientGender="") {
	    quit ..GetRandomOtherDoctor()
    } elseif (patientGender="F") {
	    If ##class(BI.Populate).RandomTrue(70) {
		    quit ..GetRandomOBGYN()
	    } else {
		    quit ..GetRandomOtherDoctor()
	    }
    } else {
	    quit ..GetRandomOtherDoctor()
    }
}

ClassMethod GetRandomPediatrician() As %Integer
{
   set choosefrom=^BI.Study.SetupData("Pediatricians")
   set choosenumber=$L(choosefrom,",")
   set randomnumber=$RANDOM(choosenumber)+1
   set randomdoc=$P(choosefrom,",",randomnumber)
   quit randomdoc
}

ClassMethod GetRandomOBGYN()
{
   set choosefrom=^BI.Study.SetupData("OBGYNs")
   set choosenumber=$L(choosefrom,",")
   set randomnumber=$RANDOM(choosenumber)+1
   set randomdoc=$P(choosefrom,",",randomnumber)
   quit randomdoc
}

ClassMethod GetRandomOtherDoctor()
{
   set choosefrom=^BI.Study.SetupData("OtherDoctors")
   set choosenumber=$L(choosefrom,",")
   set randomnumber=$RANDOM(choosenumber)+1
   set randomdoc=$P(choosefrom,",",randomnumber)
   quit randomdoc
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
<DataLocation>^BI.Study.DoctorD</DataLocation>
<DefaultData>DoctorDefaultData</DefaultData>
<IdLocation>^BI.Study.DoctorD</IdLocation>
<IndexLocation>^BI.Study.DoctorI</IndexLocation>
<StreamLocation>^BI.Study.DoctorS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

