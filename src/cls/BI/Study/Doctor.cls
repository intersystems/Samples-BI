/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// This class contains the doctors. 
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
    set status=$$$OK
    //first kill extent
    //never use %KillExtent() in a real application
    do ..%KillExtent()
    set ^BI.Study.SetupData("Pediatricians")=""
    set ^BI.Study.SetupData("OBGYNs")=""
    set ^BI.Study.SetupData("OtherDoctors")=""
    

    For n = 1:1:count {
        set doc = ##class(BI.Study.Doctor).%New()
        set doc.FirstName = ##class(%PopulateUtils).FirstName()
        set doc.LastName = ##class(%PopulateUtils).LastName()
        
        // Assign to a doctor group
        set grouplist=$LB("I","II","III")
        set groupID=$RANDOM($LISTLENGTH(grouplist))+1
        set doc.DoctorGroup=$LI(grouplist,groupID)

        // Set PatientsPerWeek property
        set doc.PatientsPerWeek=130+$RANDOM(40)
        
        // Null out the previous two properties in some cases
        if (genNulls && ##class(BI.Populate).RandomTrue(20)){
            set doc.PatientsPerWeek=""
            set doc.DoctorGroup=""
            }
        

        // Select a city
        set cityid=##class(BI.Populate).GetRandomId("BI.Study.City")          
        set doc.MainCity=##class(BI.Study.City).%OpenId(cityid,0)

        // Specify the doctor type; these are assigned somewhat randomly
        if ##class(BI.Populate).RandomTrue(70) {
            set typelist=$LB("General Physician","Internist","Pediatrician","OB/GYN")
            set typeid=$RANDOM($LISTLENGTH(typelist))+1
            set doc.DoctorType=$LI(typelist,typeid)
            }
        else {
            set typelist=$LB("Anesthesiologist","Allergist","Cardiologist","Dermatologist",
                        "Emergency Physician","Gastroenterologist","Radiologist","Surgeon")
            set typeid=$RANDOM($LISTLENGTH(typelist))+1
            set doc.DoctorType=$LI(typelist,typeid)
	    }
	    if (doc.DoctorType="Pediatrician") {
		    set ^BI.Study.SetupData("Pediatricians")=^BI.Study.SetupData("Pediatricians")_","_n
	    } elseif (doc.DoctorType="OB/GYN") {
		    set ^BI.Study.SetupData("OBGYNs")=^BI.Study.SetupData("OBGYNs")_","_n
	    } else {
		    set ^BI.Study.SetupData("OtherDoctors")=^BI.Study.SetupData("OtherDoctors")_","_n
	    }

        set status=doc.%Save()
        if $$$ISERR(status) {do $System.Status.DisplayError(status)}

   }
   set ^BI.Study.SetupData("Pediatricians")=$ZSTRIP(^BI.Study.SetupData("Pediatricians"),"<",",")
   set ^BI.Study.SetupData("OBGYNs")=$ZSTRIP(^BI.Study.SetupData("OBGYNs"),"<",",")

   // Create an "extent set" from which we can later get random IDs
   set status=##class(BI.Populate).UpdateIdCache($CLASSNAME())
   quit status
}

/// Randomly change doctor group and patients per week for some doctors. 
/// if rebuild is 1, this method updates the BI indices for each patient affected
/// by these changes. 
ClassMethod ChangeSomeDoctors(percent As %Numeric = 20, rebuild As %Boolean = 1)
{
    set ^BI.Study.Log($I(^BI.Study.Log))=$zdatetime($h,2,3)_" Changing some doctor data..."

    // Create an "extent set" from which we can later get random IDs
    set status=##class(BI.Populate).UpdateIdCache($CLASSNAME())

    set changecount=0
    set listLength=##class(BI.Populate).Count($CLASSNAME())

    // Throw the dice once as many times as we have doctors; not the same as 
    // looping through doctors but close in overall effect
    for i=1:1:listLength {
         if ##class(BI.Populate).RandomTrue(percent)
         {
            set docid=##class(BI.Populate).GetRandomId($CLASSNAME())
            set doc=..%OpenId(docid)

            // Assign to a doctor group
            set grouplist=$LB("I","II","III")
            set groupID=$RANDOM($LISTLENGTH(grouplist))+1
            set doc.DoctorGroup=$LI(grouplist,groupID)

            // Set PatientsPerWeek property
            set doc.PatientsPerWeek=130+$RANDOM(40)
            do doc.%Save()
            
            if rebuild {
	            // Because doctors are in a separate table, changing info for a 
                // doctor does NOT fire any triggers for the patients, 
                // so it is necessary to figure out which patients are affected 
                // and update the indices for those patients
            
                set myquery="SELECT ID FROM BI_Study.Patient WHERE PrimaryCarePhysician=?"
                set rset=##class(%ResultSet).%New("%DynamicQuery:SQL")
                set status=rset.Prepare(myquery)
                if $$$ISERR(status) {do $System.Status.DisplayError(status) quit}
                set status=rset.Execute(docid)
                if $$$ISERR(status) {do $System.Status.DisplayError(status) quit}
                    while rset.Next() {
                    set patid=rset.Data("ID")
                 
                    do ##class(%DeepSee.Utils).%ProcessFact("patients",patid)

                    }
                }
          set changecount=changecount+1
         }
        } 

    // If rebuild {Kill %this} ; needed because zzBuildone doesn't clean this up
    set ^BI.Study.Log($I(^BI.Study.Log))=$zdatetime($h,2,3)_" "_changecount_" doctors changed"
}

/// Based on patient age (in years) and gender ("F" or "M"), return the ID of a suitable doctor
ClassMethod GetDoctorId(patientAge As %Integer = "", patientGender As %String = "") As %Integer
{
    if (patientAge="") {
	    quit ..GetRandomOtherDoctor()
    } elseif (patientAge<12)	{
	    if ##class(BI.Populate).RandomTrue(90) {
		    quit ..GetRandomPediatrician()
	    } else {
		    quit ..GetRandomOtherDoctor()
	    }
    } 
    
    if (patientGender="") {
	    quit ..GetRandomOtherDoctor()
    } elseif (patientGender="F") {
	    if ##class(BI.Populate).RandomTrue(70) {
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

