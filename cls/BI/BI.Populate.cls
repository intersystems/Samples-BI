/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// <p>It defines overall methods to generate data for this sample.
/// It also contains general-purpose utilities for populating these tables. 
/// 
Class BI.Populate Extends %RegisteredObject
{

/// Invoke this method to set up all the data for these classes.
ClassMethod Setup(patCount As %Integer = 1000, options As %String = "ADTR")
{
	//generates patients & rainfall data
	//also builds patients and cityrainfall cube 
	//(because DSTIME="auto" in the source classes)
	//don't generate encounter data by default
	do ..GenerateData(patCount,,options)
	
	//build CityCube
	do ##class(%DeepSee.Utils).%BuildCube("Cities")

	//build cube for new connector example
	do ##class(%DeepSee.Utils).%BuildCube("ConnectorCube")

	//generate another 100 patients in the disconnected second set & build cube
	//do ..GeneratePatientQuerySample(100)
		
	//must build related cubes in correct order
	do ..BuildRelatedCubes()

	//must build cubes with shared dimensions in correct order
	do ..BuildCompoundCubes()
	
	//set up term lists used by controls on dashboards
	do ..SetupTermLists()

    //define pivot variables
    do ..SetupVariables()
}

/// This method generates the sample data for the patients and related classes.
/// <p>patCount specifies the number of patients to generate in BI.Study.Patients.
/// <p>patientsPerDoc specifies the approximate ratio of patients per doctor.
/// At least one doctor is always created.
/// <p>options is a case-insensitive string that controls whether certain child data is also generated.
/// <ul>
/// <li>If it includes the letter A, allergy data is generated. This option is on by default.</li>
/// <li>If it includes the letter D, diagnosis data is generated. This option is on by default.</li>
/// <li>If it includes the letter T, the PatientDetails table is populated. This option is on by default.</li>
/// <li>If it includes the letter E, the PatientEncounter table is populated. This option is off by default.</li>
/// <li>If it includes the letter R, the CityRainfall table is populated. This option is off by default.</li>
/// <li>If it includes the letter X, half the patients are written to the BI.Study.PatientSet2 
/// table (the "extra" Set) and half are written to BI.Study.Patients. This option is off by default.</li>
/// </ul>
/// genNulls specifies whether to insert random null values. By default, this option is on, and the
/// GenerateData method sets the patient's primary care physician, part of the allergy data, and assorted
/// other data to null in a percentage of cases (or in some cases, it simply does not generate child data).
/// <p>genDateNulls specifies whether to insert random null values for birth dates. 
/// By default, this option is off.
ClassMethod GenerateData(patCount As %Integer = 10000, patientsPerDoc As %Numeric = 25, options As %String = "ADT", genNulls As %Boolean = 1, genDateNulls As %Boolean = 0) As %Status
{
    Set start=$PIECE($HOROLOG,",",2)

    Set status=$$$OK
    If ($FIND(options,"X")) {
        Set generateextraset=1
        Set mainpatcount=patCount\2
        Set extrapatcount=patCount\2
        }
        Else {
            Set generateextraset=0
            Set mainpatcount=patCount
            }

    //first set up code tables
    Write !, "Setting up code tables"
    Set status=..SetUpCodeTables()
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
    
    If ($FIND(options,"R")) {
	    Set status=##class(BI.Study.CityRainfall).GenerateData()
        If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
	    }
    
    //Set up doctors
    If (patientsPerDoc<1) {
        Set patientsPerDoc=1
        }
        
    Set docCount=patCount\patientsPerDoc
    If (docCount < 1) {
        Set docCount=1
        }

    Write !, "Setting up "_ docCount_" doctors"
    Set status=##class(BI.Study.Doctor).GenerateData(docCount,genNulls)
    If $$$ISERR(status) {Quit $System.Status.DisplayError(status)}
    
    //Set up patients
    Set status=##class(BI.Study.Patient).GenerateData(mainpatcount,options,genNulls,genDateNulls)
    If $$$ISERR(status) {Quit $System.Status.DisplayError(status)}

    If generateextraset {
        Set status=##class(BI.Study.PatientSet2).GenerateData(extrapatcount,options,genNulls)
        If $$$ISERR(status) {Quit $System.Status.DisplayError(status)}
        }
        
    Write !,"Elapsed time: ",($PIECE($HOROLOG,",",2)-start)," seconds"
    Quit status
}

/// Called by GenerateData
ClassMethod SetUpCodeTables() As %Status [ Internal ]
{
    Kill ^BI.Study.SetupData
    Set ^BI.Study.SetupData="This global is created by setup methods in the BI.Study package."
    Set status=##class(BI.Study.Allergen).Setup()
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
    Set status=##class(BI.Study.AllergySeverity).Setup()
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
    Set status=##class(BI.Study.City).Setup()
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
    Set status=##class(BI.Study.Diagnosis).Setup()
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
    Set status=##class(BI.Study.Profession).Setup()
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
    Quit status
}

/// Returns true randomly some percentage of the time.
ClassMethod RandomTrue(cutoff As %Numeric, scale As %Numeric = 1000000)
{
    //scale everything up to deal with fractional cutoff values
    Set scaledcutoff=scale*cutoff
    Set lotterypick=$random(scale*100)
    
    If (lotterypick<scaledcutoff) {
        Set maybetrue=1
        }
        Else {
            Set maybetrue=0
            }
    Quit maybetrue
}

/// Given an age, returns an appropriate birthdate as a string.
ClassMethod BirthDateODBC(age As %Numeric) As %String
{
    Set currentyear=$PIECE($ZDATE($h,6)," ",3)  ; YYYY
    Set birthyear=currentyear-age
    
    Set birthdate=..RandomODBCDateString(birthyear) ; returns YYYY-MM-DD
    
    Quit birthdate
}

/// Given a year, returns a suitable date in that year, in 
/// the form "YYYY-MM-DD" 
/// <p>For example: 2008-07-01 
ClassMethod RandomODBCDateString(year As %Integer) As %String
{
    Set month=$RANDOM(12)+1

    //figure out how many days in this month
    Set daycount=$CASE(month,1:31,2:28,3:31,4:30,5:31,6:30,7:31,8:31,9:30,10:31,11:30,12:31)
    Set isleapyear=$S((year)#4=0:$S('((((year)#100)=0)&&(((year)#400)'=0)):1,1:0),1:0) ; got this from Joe
    If (isleapyear && (month="2")) {Set daycount=29}

    Set day=$RANDOM(daycount)+1

    Set padday=$TR($J(day,2)," ",0)         ; adds 0 to start of 1-digit days
    Set padmonth=$TR($J(month,2)," ",0)     ; adds 0 to start of 1-digit months
    Quit year_"-"_padmonth_"-"_padday
}

/// Given a year, returns a suitable date in that year, in
/// the form "MMM D, YYYY" 
/// <p>For example: Jul 1, 2003 
/// <p>Note: This is not currently used.
ClassMethod RandomMMMD(year As %Integer) As %String
{
    Set monthlist=$LB("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sept","Oct","Nov","Dec")
    Set month=$LI(monthlist,$RANDOM(12)+1)

    //figure out how many days in this month
    Set daycount=$CASE(month,"Jan":31,"Feb":28,"Mar":31,"Apr":30,"May":31,"Jun":30,"Jul":31,"Aug":31,"Sept":30,"Oct":31,"Nov":30,"Dec":31)
    Set isleapyear=$S((%y)#4=0:$S('((((%y)#100)=0)&&(((%y)#400)'=0)):1,1:0),1:0)
    If (isleapyear && (month="Feb")) {Set daycount=29}

    Set day=$RANDOM(daycount)+1

    Quit month_" "_day_", "_year
}

/// Returns a string containing age+gender chosen from 2000 census distribution
/// <p>format: gender,age 
/// <p>gender is M or F
ClassMethod RandomGenderAndAge() As %String
{
    //draw a number from the lottery
    Set rand=$RANDOM(100000)+1 
        
    //now select a bucket and generate an age, based on the lottery
    //this is not compact but is easy to compare to my spreadsheet
    If (rand<3486) {
        Set age=$R(5)       ; 0 < =age <= 4
        }
        Elseif ((rand>=3486) && (rand<7225)) {
            Set age=5+$R(5)     ; 5 < =age <= 9
            }
        Elseif ((rand>=7225) && (rand<10964)) {
            Set age=10+$R(5)    ; 10 <= age <= 14
            }
        Elseif ((rand>=10964) && (rand<14656)) {
            Set age=15+$R(5)    ; 15 <= age <= 19
            }
        Elseif ((rand>=14656) && (rand<18098)) {
            Set age=20+$R(5)    ; 20 <= age <= 24
            }
        Elseif ((rand>=18098) && (rand<21580)) {
            Set age=25+$R(5)    ; 25 <=age <= 29
            }
        Elseif ((rand>=21580) && (rand<25248)) {
            Set age=30+$R(5)    ; 30 <=age <= 34
            }
        Elseif ((rand>=25248) && (rand<29270)) {
            Set age=35+$R(5)    ; 35 <=age <= 39
            }
        Elseif ((rand>=29270) && (rand<33225)) {
            Set age=40+$R(5)    ; 40 <=age <= 44
            }
        Elseif ((rand>=33225) && (rand<36736)) {
            Set age=45+$R(5)    ; 45 <=age <= 49
            }
        Elseif ((rand>=36736) && (rand<39797)) {
            Set age=50+$R(5)    ; 50 <=age <= 54
            }
        Elseif ((rand>=39797) && (rand<42110)) {
            Set age=55+$R(5)    ; 55 <=age <= 59
            }
        Elseif ((rand>=42110) && (rand<43935)) {
            Set age=60+$R(5)    ; 60 <=age <= 64
            }
        Elseif ((rand>=43935) && (rand<45449)) {
            Set age=65+$R(5)    ; 65 <=age <= 69
            }
        Elseif ((rand>=45449) && (rand<46886)) {
            Set age=70+$R(5)    ; 70 <=age <= 74
            }
        Elseif ((rand>=46886) && (rand<47968)) {
            Set age=75+$R(5)    ; 75 <=age <= 79
            }
        Elseif ((rand>=47968) && (rand<48620)) {
            Set age=80+$R(5)    ; 80 <=age <= 84
            }
        Elseif ((rand>=48620) && (rand<49056)) {
            Set age=85+$R(8)    ; 85 <=age
            }       
        //start on female part of the lottery
        Elseif ((rand>=49056) && (rand<52383)) {
            Set age=$R(5)       ; 0 < =age <= 4
            }
        Elseif ((rand>=52383) && (rand<55946)) {
            Set age=5+$R(5)     ; 5 < =age <= 9
            }
        Elseif ((rand>=55946) && (rand<59502)) {
            Set age=10+$R(5)    ; 10 <= age <= 14
            }
        Elseif ((rand>=59502) && (rand<62995)) {
            Set age=15+$R(5)    ; 15 <= age <= 19
            }   
        Elseif ((rand>=62995) && (rand<66291)) {
            Set age=20+$R(5)    ; 20 <= age <= 24
            }
        Elseif ((rand>=66291) && (rand<69696)) {
            Set age=25+$R(5)    ; 25 <=age <= 29
            }
        Elseif ((rand>=69696) && (rand<73317)) {
            Set age=30+$R(5)    ; 30 <=age <= 34
            }
        Elseif ((rand>=73317) && (rand<77363)) {
            Set age=35+$R(5)    ; 35 <=age <= 39
            }
        Elseif ((rand>=77363) && (rand<81383)) {
            Set age=40+$R(5)    ; 40 <=age <= 44
            }
        Elseif ((rand>=81383) && (rand<85009)) {
            Set age=45+$R(5)    ; 45 <=age <= 49
            }
        Elseif ((rand>=85009) && (rand<88199)) {
            Set age=50+$R(5)    ; 50 <=age <= 54
            }
        Elseif ((rand>=88199) && (rand<90672)) {
            Set age=55+$R(5)    ; 55 <=age <= 59
            }
        Elseif ((rand>=90672) && (rand<92686)) {
            Set age=60+$R(5)    ; 60 <=age <= 64
            }
        Elseif ((rand>=92686) && (rand<94510)) {
            Set age=65+$R(5)    ; 65 <=age <= 69
            }
        Elseif ((rand>=94510) && (rand<96271)) {
            Set age=70+$R(5)    ; 70 <=age <= 74
            }
        Elseif ((rand>=96271) && (rand<97824)) {
            Set age=75+$R(5)    ; 75 <=age <= 79
            }
        Elseif ((rand>=97824) && (rand<98930)) {
            Set age=80+$R(5)    ; 80 <=age <= 84
            }
        Elseif (rand>=98930) {
            Set age=85+$R(15)   ; 85 <=age
            }
        
    //now append gender string
    If (rand<49056) {
        Set return="M,"_age
        }
        Else {
            Set return="F,"_age
            }
    
    Quit return
}

/// Returns count of IDs in the given extent or 0 if none.
ClassMethod Count(cls) As %Numeric [ Internal ]
{
    //convert class name to table name; assume first period needs to
    //be converted to an underscore (this is not a general-purpose method)
    Set periodpos=$FIND(cls,".")
    Set part1=$EXTRACT(cls,0,periodpos-2)
    Set part2=$EXTRACT(cls,periodpos,*)
    Set tname=part1_"_"_part2
 
    Set myquery="SELECT Count(*) as RecCount FROM "_tname
    Set rset=##class(%ResultSet).%New("%DynamicQuery:SQL")
    Set status=rset.Prepare(myquery)
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Quit}
    Set status=rset.Execute()
    
    If $$$ISERR(status) {Do $System.Status.DisplayError(status) Write !, "error with query" Quit}
    Set reccount=0
    Do rset.Next()
    Set reccount=rset.Data("RecCount")
    Quit reccount
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
   Set tp=$INCREMENT(^CacheTemp)
   //save this so we can use it later to find this cache
   Set ^BI.Study.SetupData("ExtentSetPointers",cls)=tp
   
   //use same unique tp for temporary pointer and for "name" of
   //the extent set
   Set status=##class(%PopulateUtils).BuildValueSetSQL(tp,tp,tname,"%ID",reccount)
   
   Quit status
}

/// Returns a random ID from the given class.
/// This method assumes that you have already run UpdateIdCache().
ClassMethod GetRandomId(cls) As %String [ Internal ]
{
   Set test=$DATA(^BI.Study.SetupData("ExtentSetPointers",cls))
   If test {Set tp=^BI.Study.SetupData("ExtentSetPointers",cls)}
   Else {Quit "no id"}

   //use same unique tp for temporary pointer and for "name" of
   //the extent set
   Set randomid=##class(%PopulateUtils).ExtentValue(tp,tp)
   Quit randomid
}

ClassMethod GeneratePatientQuerySample(patCount As %Integer = 100)
{
	//generate additional patients in the disconnected second set
	//for the benefit of PatientsQuery cube
	do ##class(BI.Study.PatientSet2).GenerateData(patCount)
	//build PatientsQueryCube
	do ##class(%DeepSee.Utils).%BuildCube("PatientsQueryCube")
}

/// Builds the related cubes in the correct order.
/// This is useful as a separate method in case you want to experiment with
/// the definitions of these cubes.
ClassMethod BuildRelatedCubes()
{
	do ##class(%DeepSee.Utils).%BuildCube("relatedcubes/cities")
    do ##class(%DeepSee.Utils).%BuildCube("relatedcubes/doctors")

    //can build these in either order:
    do ##class(%DeepSee.Utils).%BuildCube("relatedcubes/patients")
    do ##class(%DeepSee.Utils).%BuildCube("relatedcubes/cityrainfall")

    //build this one after relatedcubes/patients
    do ##class(%DeepSee.Utils).%BuildCube("relatedcubes/allergies")
}

/// Builds the cubes in the correct order for the compound cube example.
/// These cubes have shared dimensions and so must be built in a specific order.
/// This is useful as a separate method in case you want to experiment with
/// the definitions of these cubes.
ClassMethod BuildCompoundCubes()
{
    do ##class(%DeepSee.Utils).%BuildCube("compoundcube/patients")

    //can build these in any order:
    do ##class(%DeepSee.Utils).%BuildCube("compoundcube/cityrainfall")
    do ##class(%DeepSee.Utils).%BuildCube("compoundcube/doctors")
}

/// Use this to try out <level> dependsOn attribute
ClassMethod ReassignPatients() As %Status
{
	set query = "SELECT %Id as ID,PatientGroup FROM BI_Study.Patient WHERE HomeCity->PostalCode IN (32006,32007)"
    set statement=##class(%SQL.Statement).%New()
    set sc = statement.%Prepare(query)
    IF 'sc { WRITE "%Prepare failed",$System.Status.DisplayError(sc) QUIT}
    set rset = statement.%Execute()
    WHILE rset.%Next() {
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
    IF 'sc { WRITE "%Prepare failed",$System.Status.DisplayError(sc) QUIT}
    set rset = statement.%Execute()
    WHILE rset.%Next() {
	    if rset.%Get("PatientGroup")="B" {
		    set id=rset.%Get("ID")
		    set p=##class(BI.Study.Patient).%OpenId(id)
		    set p.PatientGroup="A"
		    do p.%Save()
		    }
     }
     Do ##class(%DeepSee.Utils).%SynchronizeCube("patients")
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
	//cannot assume the following will work from release to release; replace with use of API when available

	write "Defining YEAR pivot variable in PATIENTS cube",!
	kill ^DeepSee.Variables("PATIENTS","YEAR")
	set ^DeepSee.Variables("PATIENTS","YEAR")=$lb("Year","Year","","2018","literal","string","kpi","PatientsYears.kpi","","")
}

}

