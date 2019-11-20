/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// It defines overall methods to generate data for this sample.
/// It also contains general-purpose utilities for populating these tables. 
/// 
Class BI.Populate Extends %RegisteredObject
{

/// Invoke this method to set up all the data for these classes.
ClassMethod Setup(patCount As %Integer = 1000, options As %String = "ADTR")
{
	// Generates patients & rainfall data
	// also builds patients and cityrainfall cube 
	// (because DSTIME="auto" in the source classes
	// don't generate encounter data by default)
	do ..GenerateData(patCount,,options)
	
	// Build CityCube
	do ##class(%DeepSee.Utils).%BuildCube("Cities")

	// Build cube for new connector example
	do ##class(%DeepSee.Utils).%BuildCube("ConnectorCube")

	// Generate another 100 patients in the disconnected second set & build cube
	// do ..GeneratePatientQuerySample(100)
		
	// Must build related cubes in correct order
	do ..BuildRelatedCubes()

	// Must build cubes with shared dimensions in correct order
	do ..BuildCompoundCubes()
	
	// set up term lists used by controls on dashboards
	do ..SetupTermLists()

    // Define pivot variables
    do ..SetupVariables()
}

/// This method generates the sample data for the patients and related classes.
/// patCount specifies the number of patients to generate in BI.Study.Patients.
/// patientsPerDoc specifies the approximate ratio of patients per doctor.
/// At least one doctor is always created.
/// options is a case-insensitive string that controls whether certain child data is also generated.
/// If it includes the letter A, allergy data is generated. This option is on by default.
/// If it includes the letter D, diagnosis data is generated. This option is on by default.
/// If it includes the letter T, the PatientDetails table is populated. This option is on by default.
/// If it includes the letter E, the PatientEncounter table is populated. This option is off by default.
/// If it includes the letter R, the CityRainfall table is populated. This option is off by default.
/// If it includes the letter X, half the patients are written to the BI.Study.PatientSet2 
/// table (the "extra" set) and half are written to BI.Study.Patients. This option is off by default.
/// genNulls specifies whether to insert random null values. By default, this option is on, and the
/// GenerateData method sets the patient's primary care physician, part of the allergy data, and assorted
/// other data to null in a percentage of cases (or in some cases, it simply does not generate child data).
/// genDateNulls specifies whether to insert random null values for birth dates. 
/// By default, this option is off.
ClassMethod GenerateData(patCount As %Integer = 10000, patientsPerDoc As %Numeric = 25, options As %String = "ADT", genNulls As %Boolean = 1, genDateNulls As %Boolean = 0) As %Status
{
    set start=$PIECE($HOROLOG,",",2)

    set status=$$$OK
    if ($FIND(options,"X")) {
        set generateextraset=1
        set mainpatcount=patCount\2
        set extrapatcount=patCount\2
        }
        else {
            set generateextraset=0
            set mainpatcount=patCount
            }

    // First set up code tables
    write !, "setting up code tables"
    set status=..SetupCodeTables()
    if $$$ISERR(status) {Do $System.Status.DisplayError(status) quit}
    
    if ($FIND(options,"R")) {
	    set status=##class(BI.Study.CityRainfall).GenerateData()
        if $$$ISERR(status) {Do $System.Status.DisplayError(status) quit}
	    }
    
    // Set up doctors
    if (patientsPerDoc<1) {
        set patientsPerDoc=1
        }
        
    set docCount=patCount\patientsPerDoc
    if (docCount < 1) {
        set docCount=1
        }

    write !, "setting up "_ docCount_" doctors"
    set status=##class(BI.Study.Doctor).GenerateData(docCount,genNulls)
    if $$$ISERR(status) {quit $System.Status.DisplayError(status)}
    
    // Set up patients
    set status=##class(BI.Study.Patient).GenerateData(mainpatcount,options,genNulls,genDateNulls)
    if $$$ISERR(status) {quit $System.Status.DisplayError(status)}

    if generateextraset {
        set status=##class(BI.Study.PatientSet2).GenerateData(extrapatcount,options,genNulls)
        if $$$ISERR(status) {quit $System.Status.DisplayError(status)}
        }
        
    write !,"Elapsed time: ",($PIECE($HOROLOG,",",2)-start)," seconds"
    quit status
}

/// Called by GenerateData
ClassMethod SetupCodeTables() As %Status [ Internal ]
{
    kill ^BI.Study.SetupData
    set ^BI.Study.SetupData="This global is created by Setup methods in the BI.Study package."
    set status=##class(BI.Study.Allergen).Setup()
    if $$$ISERR(status) {Do $System.Status.DisplayError(status) quit}
    set status=##class(BI.Study.AllergySeverity).Setup()
    if $$$ISERR(status) {Do $System.Status.DisplayError(status) quit}
    set status=##class(BI.Study.City).Setup()
    if $$$ISERR(status) {Do $System.Status.DisplayError(status) quit}
    set status=##class(BI.Study.Diagnosis).Setup()
    if $$$ISERR(status) {Do $System.Status.DisplayError(status) quit}
    set status=##class(BI.Study.Profession).Setup()
    if $$$ISERR(status) {Do $System.Status.DisplayError(status) quit}
    quit status
}

/// Returns true randomly some percentage of the time.
ClassMethod RandomTrue(cutoff As %Numeric, scale As %Numeric = 1000000)
{
    // Scale everything up to deal with fractional cutoff values
    set scaledcutoff=scale*cutoff
    set lotterypick=$random(scale*100)
    
    if (lotterypick<scaledcutoff) {
        set maybetrue=1
        }
        else {
            set maybetrue=0
            }
    quit maybetrue
}

/// Given an age, returns an appropriate birthdate as a string.
ClassMethod BirthDateODBC(age As %Numeric) As %String
{
    set currentyear=$PIECE($ZDATE($h,6)," ",3)  ; YYYY
    set birthyear=currentyear-age
    
    set birthdate=..RandomODBCDateString(birthyear) ; returns YYYY-MM-DD
    
    quit birthdate
}

/// Given a year, returns a suitable date in that year,
/// in the form "YYYY-MM-DD" 
/// For example: 2008-07-01 
ClassMethod RandomODBCDateString(year As %Integer) As %String
{
    set month=$RANDOM(12)+1

    // Figure out how many days in this month
    set daycount=$CASE(month,1:31,2:28,3:31,4:30,5:31,6:30,7:31,8:31,9:30,10:31,11:30,12:31)
    set isleapyear=$S((year)#4=0:$S('((((year)#100)=0)&&(((year)#400)'=0)):1,1:0),1:0) ; got this from Joe
    if (isleapyear && (month="2")) {set daycount=29}

    set day=$RANDOM(daycount)+1

    set padday=$TR($J(day,2)," ",0)         ; adds 0 to start of 1-digit days
    set padmonth=$TR($J(month,2)," ",0)     ; adds 0 to start of 1-digit months
    quit year_"-"_padmonth_"-"_padday
}

/// Given a year, returns a suitable date in that year,
/// in the form "MMM D, YYYY" 
/// For example: Jul 1, 2003 
/// Note: This is not currently used.
ClassMethod RandomMMMD(year As %Integer) As %String
{
    set monthlist=$LB("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sept","Oct","Nov","Dec")
    set month=$LI(monthlist,$RANDOM(12)+1)

    // Figure out how many days in this month
    set daycount=$CASE(month,"Jan":31,"Feb":28,"Mar":31,"Apr":30,"May":31,"Jun":30,"Jul":31,"Aug":31,"Sept":30,"Oct":31,"Nov":30,"Dec":31)
    set isleapyear=$S((%y)#4=0:$S('((((%y)#100)=0)&&(((%y)#400)'=0)):1,1:0),1:0)
    if (isleapyear && (month="Feb")) {set daycount=29}

    set day=$RANDOM(daycount)+1

    quit month_" "_day_", "_year
}

/// Returns a string containing age+gender chosen from 2000 census distribution
/// format: gender,age 
/// gender is M or F
ClassMethod RandomGenderAndAge() As %String
{
    // Draw a number from the lottery
    set rand=$RANDOM(100000)+1 
        
    // Now select a bucket and generate an age, based on the lottery
    // This is not compact but is easy to compare to my spreadsheet
    if (rand<3486) {
        set age=$R(5)       ; 0 < =age <= 4
        }
        elseif ((rand>=3486) && (rand<7225)) {
            set age=5+$R(5)     ; 5 < =age <= 9
            }
        elseif ((rand>=7225) && (rand<10964)) {
            set age=10+$R(5)    ; 10 <= age <= 14
            }
        elseif ((rand>=10964) && (rand<14656)) {
            set age=15+$R(5)    ; 15 <= age <= 19
            }
        elseif ((rand>=14656) && (rand<18098)) {
            set age=20+$R(5)    ; 20 <= age <= 24
            }
        elseif ((rand>=18098) && (rand<21580)) {
            set age=25+$R(5)    ; 25 <=age <= 29
            }
        elseif ((rand>=21580) && (rand<25248)) {
            set age=30+$R(5)    ; 30 <=age <= 34
            }
        elseif ((rand>=25248) && (rand<29270)) {
            set age=35+$R(5)    ; 35 <=age <= 39
            }
        elseif ((rand>=29270) && (rand<33225)) {
            set age=40+$R(5)    ; 40 <=age <= 44
            }
        elseif ((rand>=33225) && (rand<36736)) {
            set age=45+$R(5)    ; 45 <=age <= 49
            }
        elseif ((rand>=36736) && (rand<39797)) {
            set age=50+$R(5)    ; 50 <=age <= 54
            }
        elseif ((rand>=39797) && (rand<42110)) {
            set age=55+$R(5)    ; 55 <=age <= 59
            }
        elseif ((rand>=42110) && (rand<43935)) {
            set age=60+$R(5)    ; 60 <=age <= 64
            }
        elseif ((rand>=43935) && (rand<45449)) {
            set age=65+$R(5)    ; 65 <=age <= 69
            }
        elseif ((rand>=45449) && (rand<46886)) {
            set age=70+$R(5)    ; 70 <=age <= 74
            }
        elseif ((rand>=46886) && (rand<47968)) {
            set age=75+$R(5)    ; 75 <=age <= 79
            }
        elseif ((rand>=47968) && (rand<48620)) {
            set age=80+$R(5)    ; 80 <=age <= 84
            }
        elseif ((rand>=48620) && (rand<49056)) {
            set age=85+$R(8)    ; 85 <=age
            }

        // Start on female part of the lottery
        elseif ((rand>=49056) && (rand<52383)) {
            set age=$R(5)       ; 0 < =age <= 4
            }
        elseif ((rand>=52383) && (rand<55946)) {
            set age=5+$R(5)     ; 5 < =age <= 9
            }
        elseif ((rand>=55946) && (rand<59502)) {
            set age=10+$R(5)    ; 10 <= age <= 14
            }
        elseif ((rand>=59502) && (rand<62995)) {
            set age=15+$R(5)    ; 15 <= age <= 19
            }   
        elseif ((rand>=62995) && (rand<66291)) {
            set age=20+$R(5)    ; 20 <= age <= 24
            }
        elseif ((rand>=66291) && (rand<69696)) {
            set age=25+$R(5)    ; 25 <=age <= 29
            }
        elseif ((rand>=69696) && (rand<73317)) {
            set age=30+$R(5)    ; 30 <=age <= 34
            }
        elseif ((rand>=73317) && (rand<77363)) {
            set age=35+$R(5)    ; 35 <=age <= 39
            }
        elseif ((rand>=77363) && (rand<81383)) {
            set age=40+$R(5)    ; 40 <=age <= 44
            }
        elseif ((rand>=81383) && (rand<85009)) {
            set age=45+$R(5)    ; 45 <=age <= 49
            }
        elseif ((rand>=85009) && (rand<88199)) {
            set age=50+$R(5)    ; 50 <=age <= 54
            }
        elseif ((rand>=88199) && (rand<90672)) {
            set age=55+$R(5)    ; 55 <=age <= 59
            }
        elseif ((rand>=90672) && (rand<92686)) {
            set age=60+$R(5)    ; 60 <=age <= 64
            }
        elseif ((rand>=92686) && (rand<94510)) {
            set age=65+$R(5)    ; 65 <=age <= 69
            }
        elseif ((rand>=94510) && (rand<96271)) {
            set age=70+$R(5)    ; 70 <=age <= 74
            }
        elseif ((rand>=96271) && (rand<97824)) {
            set age=75+$R(5)    ; 75 <=age <= 79
            }
        elseif ((rand>=97824) && (rand<98930)) {
            set age=80+$R(5)    ; 80 <=age <= 84
            }
        elseif (rand>=98930) {
            set age=85+$R(15)   ; 85 <=age
            }
        
    // Now append gender string
    if (rand<49056) {
        set return="M,"_age
        }
        else {
            set return="F,"_age
            }
    
    quit return
}

/// Returns count of IDs in the given extent or 0 if none.
ClassMethod Count(cls) As %Numeric [ Internal ]
{
    // Convert class name to table name; assume first period needs to
    // be converted to an underscore (this is not a general-purpose method)
    set periodpos=$FIND(cls,".")
    set part1=$EXTRACT(cls,0,periodpos-2)
    set part2=$EXTRACT(cls,periodpos,*)
    set tname=part1_"_"_part2
 
    set myquery="SELECT Count(*) as RecCount FROM "_tname
    set rset=##class(%ResultSet).%New("%DynamicQuery:SQL")
    set status=rset.Prepare(myquery)
    if $$$ISERR(status) {Do $System.Status.DisplayError(status) quit}
    set status=rset.Execute()
    
    if $$$ISERR(status) {Do $System.Status.DisplayError(status) write !, "error with query" quit}
    set reccount=0
    do rset.Next()
    set reccount=rset.Data("RecCount")
    quit reccount
}

/// Given a class, creates a cache that contains all the current IDs for
/// that class. Use GetRandomId() to get a random ID from this cache.
ClassMethod UpdateIdCache(cls) As %Status [ Internal ]
{

   Set reccount = ..Count(cls)
   Set periodpos=$FIND(cls,".")
   Set part1=$EXTRACT(cls,0,periodpos-2)
   Set part2=$EXTRACT(cls,periodpos,*)
   Set tname=part1_"_"_part2

   //allocate a temporary pointer
   Set tp=$INCREMENT(^IRIS.Temp)
      
   // Save this so we can use it later to find this cache
   set ^BI.Study.SetupData("ExtentSetPointers",cls)=tp
   
   // Use same unique tp for temporary pointer and for "name" of
   // the extent set
   set status=##class(%PopulateUtils).BuildValuesetSQL(tp,tp,tname,"%ID",reccount)
   
   quit status
}

/// Returns a random ID from the given class.
/// This method assumes that you have already run UpdateIdCache().
ClassMethod GetRandomId(cls) As %String [ Internal ]
{
   set test=$DATA(^BI.Study.SetupData("ExtentSetPointers",cls))
   if test {set tp=^BI.Study.SetupData("ExtentSetPointers",cls)}
   else {quit "no id"}

   // Use same unique tp for temporary pointer and for "name" of
   // the extent set
   set randomid=##class(%PopulateUtils).ExtentValue(tp,tp)
   quit randomid
}

ClassMethod GeneratePatientQuerySample(patCount As %Integer = 100)
{
	// Generate additional patients in the disconnected second set
	// for the benefit of PatientsQuery cube
	do ##class(BI.Study.PatientSet2).GenerateData(patCount)
	
    // Build PatientsQueryCube
	do ##class(%DeepSee.Utils).%BuildCube("PatientsQueryCube")
}

/// Builds the related cubes in the correct order.
/// This is useful as a separate method in case you want to experiment with
/// the definitions of these cubes.
ClassMethod BuildRelatedCubes()
{
	do ##class(%DeepSee.Utils).%BuildCube("relatedcubes/cities")
    do ##class(%DeepSee.Utils).%BuildCube("relatedcubes/doctors")

    // Can build these in either order:
    do ##class(%DeepSee.Utils).%BuildCube("relatedcubes/patients")
    do ##class(%DeepSee.Utils).%BuildCube("relatedcubes/cityrainfall")

    // Build this one after relatedcubes/patients
    do ##class(%DeepSee.Utils).%BuildCube("relatedcubes/allergies")
}

/// Builds the cubes in the correct order for the compound cube example.
/// These cubes have shared dimensions and so must be built in a specific order.
/// This is useful as a separate method in case you want to experiment with
/// the definitions of these cubes.
ClassMethod BuildCompoundCubes()
{
    do ##class(%DeepSee.Utils).%BuildCube("compoundcube/patients")

    // Can build these in any order:
    do ##class(%DeepSee.Utils).%BuildCube("compoundcube/cityrainfall")
    do ##class(%DeepSee.Utils).%BuildCube("compoundcube/doctors")
}

/// Use this to try out <level> dependsOn attribute
ClassMethod ReassignPatients() As %Status
{
	set query = "SELECT %Id as ID,PatientGroup FROM BI_Study.Patient WHERE HomeCity->PostalCode IN (32006,32007)"
    set statement=##class(%SQL.Statement).%New()
    set sc = statement.%Prepare(query)
    if 'sc { write "%Prepare failed",$System.Status.DisplayError(sc) quit}
    set rset = statement.%Execute()
    while rset.%Next() {
	    if rset.%Get("PatientGroup")="A" {
		    set id=rset.%Get("ID")
		    set p=##class(BI.Study.Patient).%OpenId(id)
		    set p.PatientGroup="B"
		    do p.%Save()
		    }
     }

	set query = "SELECT %Id as ID,PatientGroup FROM BI_Study.Patient WHERE HomeCity->PostalCode IN (34577,36711,38928)"
    set statement=##class(%SQL.Statement).%New()
    set sc = statement.%Prepare(query)
    if 'sc { write "%Prepare failed",$System.Status.DisplayError(sc) quit}
    set rset = statement.%Execute()
    while rset.%Next() {
	    if rset.%Get("PatientGroup")="B" {
		    set id=rset.%Get("ID")
		    set p=##class(BI.Study.Patient).%OpenId(id)
		    set p.PatientGroup="A"
		    do p.%Save()
		    }
     }
     do ##class(%DeepSee.Utils).%SynchronizeCube("patients")
}

/// Purely for demo purposes, this method defines term lists used by this sample.
ClassMethod SetupTermLists() [ Internal ]
{
	set name="Patients Pivots"
	set uname="PATIENTS PIVOTS"
	write "Defining term list ",name,"...",!
	
	kill ^DeepSee.TermList(uname)
	set ^DeepSee.TermList(uname,"name")=name
	set ^DeepSee.TermList(uname,"modDate")=$zdt($h,3)
	set ^DeepSee.TermList(uname,"data","Patients by Diagnosis","VALUE")="Use in Dashboards/For Patients Scorecard.pivot"
	set ^DeepSee.TermList(uname,"data","Patients by Age & Gender","VALUE")="Use in Dashboards/Patient Allergy Counts by Age & Gender.pivot"
	set ^DeepSee.TermList(uname,"data","Patients by Color","VALUE")="Use in Dashboards/Patients by Favorite Color.pivot"
	set ^DeepSee.TermList(uname,"data","Patients by Group","VALUE")="Use in Dashboards/Patients by Group.pivot"

	set name="Patients RowSpecs"
	set uname="PATIENTS ROWSPECS"
	write "Defining term list ",name,"...",!
	set ^DeepSee.TermList(uname,"modDate")=$zdt($h,3)
	set ^DeepSee.TermList(uname,"data","Age Groups","VALUE")="[aged].[h1].[age group].MEMBERS"
	set ^DeepSee.TermList(uname,"data","Allergies","VALUE")="[allerd].[h1].[allergies].MEMBERS"
	set ^DeepSee.TermList(uname,"data","Cities","VALUE")="[homed].[h1].[city].MEMBERS"
	set ^DeepSee.TermList(uname,"data","Diagnoses","VALUE")="[diagd].[h1].[diagnoses].MEMBERS"
	set ^DeepSee.TermList(uname,"data","Favorite Colors","VALUE")="[colord].[h1].[favorite color].MEMBERS"
	set ^DeepSee.TermList(uname,"data","Industries","VALUE")="[profd].[h1].[industry].MEMBERS"
	set ^DeepSee.TermList(uname,"data","Professions","VALUE")="[profd].[h1].[profession].MEMBERS"
	set ^DeepSee.TermList(uname,"data","ZIP Codes","VALUE")="[homed].[h1].[zip].MEMBERS"
}

/// Purely for demo purposes, this method defines pivot variables used by this sample.
ClassMethod SetupVariables() [ Internal ]
{
	// Cannot assume the following will work from release to release; replace with use of API when available

	write "Defining YEAR pivot variable in PATIENTS cube",!
	kill ^DeepSee.Variables("PATIENTS","YEAR")
	set ^DeepSee.Variables("PATIENTS","YEAR")=$lb("Year","Year","","2018","literal","string","kpi","PatientsYears.kpi","","")
}

}

