/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// <p>This class contains a cube based on BI.Study.Patients. This class also contains utility methods used by this cube.
Class BI.Model.PatientsCube Extends %DeepSee.CubeDefinition [ DependsOn = BI.Study.Patient ]
{

Parameter DOMAIN = "PATIENTSAMPLE";

XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube 
name="Patients"  displayName="Patients" 
 owner="_SYSTEM"
 sourceClass="BI.Study.Patient"
 nullReplacement="None"
 defaultListing="Patient details"
 countMeasureCaption="Patient Count"
 description="Represents patients in a fictitious study"
 >

<dimension name="AgeD" displayName="AgeD" 
allCaption="All Patients"  allDisplayName="All Patients"
description="These levels group patients by age at study date. This is a data dimension, not an age dimension.">
<hierarchy name="H1" displayName="H1">
<level name="Age Group" displayName="Age Group"
sourceProperty="Age" 
rangeExpression="(,29]:0 to 29;[30,59]:30 to 59;[60,):60+;"
 factName="DxAgeGroup" 
 description="Group patients by large age ranges"/>
<level name="Age Bucket" displayName="Age Bucket"
sourceExpression="##class(BI.Model.PatientsCube).GetAgeBucket(%source.Age)" 
 factName="DxAgeBucket"
  description="Group patients by age in ten-year bands"/>
<level name="Age" displayName="Age"
sourceProperty="Age"
factName="DxAge"
description="Group patients by age in years" sort="asc numeric"> 
</level>
</hierarchy>
</dimension>

<dimension name="AllerD" displayName="AllerD" hasAll="false" 
description="This level groups patients by their allergies (possibly more than one per patient). No Data Available means the allergy data is null.">
<hierarchy name="H1" displayName="H1">
<level name="Allergies" displayName="Allergies" 
list="true" 
sourceExpression='##class(BI.Model.PatientsCube).GetAllergies(%source.%ID)' nullReplacement="No Data Available"
 factName="DxAllergies" /> 
</hierarchy>
</dimension>

<dimension name="AllerSevD" displayName="AllerSevD" hasAll="false" 
description="This level groups patients by their allergy severities (possibly more than one per patient). No Data Available means the allergy data is null."
>
<hierarchy name="H1" displayName="H1">
<level name="Allergy Severities" displayName="Allergy Severities" 
list="true" 
sourceExpression='##class(BI.Model.PatientsCube).GetAllergySeverities(%source.%ID)'
factName="DxAllergySeverities"  
nullReplacement="No Data Available"> 
 <property name="SeveritySort"  displayName="SeveritySort" 
 sourceExpression="##class(BI.Model.PatientsCube).GetSeveritySort(%value)" 
 factName="PxSort"
  sort="asc numeric" />
</level>
</hierarchy>
</dimension>

<dimension name="BirthD" displayName="BirthD" type="time" 
sourceProperty="BirthDate" hasAll="false"
description="These levels group patients by birth date">
<hierarchy name="H1" displayName="H1">
<level name="Decade" displayName="Decade" timeFunction="Decade" />
<level name="Year"  displayName="Year" timeFunction="Year"  />
<level name="Quarter Year" displayName="Quarter Year" timeFunction="QuarterYear" />
<level name="Period" displayName="Period" timeFunction="MonthYear" />
<level name="Date" displayName="Date" timeFunction="DayMonthYear" />
</hierarchy>
</dimension>

<dimension name="BirthQD" displayName="BirthQD" type="time" 
sourceProperty="BirthDate" hasAll="false" 
description="This level groups patients by birth quarter. This lets you see seasonality, independent of year.">
<hierarchy name="H1" displayName="H1">
<level name="Quarter" displayName="Quarter" timeFunction="QuarterNumber" />
<level name="Month" displayName="Month" timeFunction="MonthNumber" />
</hierarchy>
</dimension>

<dimension name="BirthTD" displayName="BirthTD" type="time" 
sourceProperty="BirthDateTimeStamp" hasAll="false" 
description="This level groups patients by birth time. This lets you see hourly variations, independent of day.">
<hierarchy name="H1" displayName="H1">
<level name="Birth Time" displayName="Birth Time" timeFunction="HourNumber" 
factName="DxBirthTime"/>
</hierarchy>
</dimension>

<dimension name="BirthWeekdayD" displayName="BirthWeekdayD" type="data" 
hasAll="false" disabled="false"
description="This level groups patients by the day of the week on which each patient was born. This lets you see periodicity, independent of year or month.">
<hierarchy name="H1" displayName="H1">
<level name="Weekday" displayName="Weekday" 
sourceExpression="$system.SQL.DAYNAME(%source.BirthDate)"  >
<member name="Sunday" displayName="Sunday" />
<member name="Monday" displayName="Monday" />
<member name="Tuesday" displayName="Tuesday" />
<member name="Wednesday" displayName="Wednesday" />
<member name="Thursday" displayName="Thursday" />
<member name="Friday" displayName="Friday" />
<member name="Saturday" displayName="Saturday" />
</level>
</hierarchy>
</dimension>

<dimension name="ColorD" displayName="ColorD" hasAll="false" 
description="This level groups patients by their favorite color, if known">
<hierarchy name="H1" displayName="H1">
<level name="Favorite Color" displayName="Favorite Color" 
sourceExpression='##class(BI.Model.PatientsCube).GetFavoriteColor(%source.PatientID)' 
 factName="DxColor"/>
</hierarchy>
</dimension>

<dimension name="DiagD" displayName="DiagD" hasAll="false" 
description="This level groups patients by their diagnoses (possibly more than one per patient). None means no diagnosis relevant to the study."
>
<hierarchy name="H1" displayName="H1">
<level name="Diagnoses" displayName="Diagnoses"
list="true" 
sourceProperty="DiagnosesAsLB" 
factName="DxDiagnoses"> 
</level>
</hierarchy>
</dimension>

<dimension name="DocD" displayName="DocD" hasAll="false"
description="These levels group patients by their primary care physician (if any)."
 showHierarchies="false">
<hierarchy name="H1" displayName="H1">
<level name="Doctor Group" displayName="Doctor Group" 
sourceProperty="PrimaryCarePhysician.DoctorGroup" 
 factName="DxDocGroup" description="Doctors are assigned to Doctor Groups, in this fictitious study."/>
<level name="Doctor" displayName="Doctor" 
sourceExpression="%source.PrimaryCarePhysician" 
factName="DxDoc" description="Duplicate names are possible. Keys are forced to be unique.">
<property name="Name" displayName="Name" 
isName="true" hidden="true" 
sort="asc" 
sourceExpression='%source.PrimaryCarePhysician.LastName_", "_%source.PrimaryCarePhysician.FirstName'
 factName="PxDoc"/>
</level>
</hierarchy>
<hierarchy name="H2" displayName="H2">
<level name="Doctor Type" displayName="Doctor Type" sourceProperty="PrimaryCarePhysician.DoctorType"
factName="DxDocType" description="Primary discipline of the doctor"/>
</hierarchy>
</dimension>

<dimension name="GenD" displayName="GenD" hasAll="false" 
description="This level groups patients by gender.">
<hierarchy name="H1" displayName="H1">
<level name="Gender" displayName="Gender"  
sourceProperty="Gender" 
 useDisplayValue="true" factName="DxGender"/>
</hierarchy>
</dimension>

<dimension name="HomeD" displayName="HomeD" hasAll="false" 
description="These levels group patients by home address.">
<hierarchy name="H1" displayName="H1">
<level name="ZIP" displayName="ZIP" 
sourceProperty="HomeCity.PostalCode" 
 factName="DxHomeZIP"
 description="In this demo, cities are contained inside ZIP codes."/>
<level name="City" displayName="City" 
sourceProperty="HomeCity"
factName="DxHomeCity" 
description="This level has three properties. One property is used as the city name; this one is hidden.">
<property name="Population" displayName="Population" 
sourceProperty="HomeCity.Population" 
isReference="true" 
factName="PxPopulation"  
 />
<property name="Principal Export" displayName="Principal Export" 
sourceProperty="HomeCity.PrincipalExport" 
isReference="true" 
factName="PxExport" 
 />
 <property name="Name" displayName="Name"
 sourceProperty="HomeCity.Name" 
 isReference="true"
   factName="PxName" 
   isName="true" hidden="true" />
</level>
</hierarchy>
</dimension>

<dimension name="PatGrpD" displayName="PatGrpD" hasAll="false">
<hierarchy name="H1" displayName="H1">
<level name="Tested" displayName="Tested" 
sourceExpression='$SELECT(%source.TestScore="":"No",1:"Yes")' 
 factName="DxTested" description="We have test scores only for patients in groups A and B."/>
<level name="Patient Group" displayName="Patient Group" 
sourceExpression='$CASE(%source.PatientGroup,"A":"Group A","B":"Group B",:"None")'
 factName="DxPatGroup" description="Patients are assigned to Patient Groups, in this fictitious study."/>
</hierarchy>
</dimension>

<dimension name="ProfD" displayName="ProfD" hasAll="false"
description="These levels group patients by profession and industry.">
<hierarchy name="H1" displayName="H1">
<level name="Industry" displayName="Industry" 
sourceExpression='##class(BI.Model.PatientsCube).GetIndustry(%source.PatientID)' 
 factName="DxIndustry"/>
<level name="Profession" displayName="Profession" 
sourceExpression='##class(BI.Model.PatientsCube).GetProfession(%source.PatientID)' 
 factName="DxProfession" />
</hierarchy>
</dimension>

<dimension name="ComputedD" displayName="ComputedD" 
  disabled="false" 
  hasAll="false" 
  type="computed" 
  dimensionClass="%DeepSee.ComputedDimension.SQL">
    <hierarchy name="H1" displayName="H1">
      <level name="Computed" displayName="Computed" >
        <member name="member 1" displayName="member 1" 
        spec="select ID from BI_Model_PatientsCube.Fact WHERE MxAge&lt;50 AND DxHomeCity->PxName='Elm Heights'" 
         description="This computed member is defined by an SQL query"/>
        <member name="member 2" displayName="member 2" 
        spec="select ID from $$$TABLE WHERE MxAge=40 AND DxHomeCity->PxName='Juniper'"
         description="This computed member is defined by an SQL query"/>
      </level>
    </hierarchy>
</dimension>
  
<measure name="Age" displayName="Age" 
sourceProperty="Age" 
aggregate="SUM" 
 factName="MxAge"/>

<measure name="Avg Age" displayName="Avg Age" 
sourceProperty="Age" 
 aggregate="AVG"/>

<measure name="Allergy Count" displayName="Allergy Count" 
type="integer"
sourceExpression='##class(BI.Model.PatientsCube).GetAllergyCount(%source.%ID)' 
aggregate="SUM" 
 searchable="true"/>

<measure name="Avg Allergy Count" displayName="Avg Allergy Count" 
type="integer"
sourceExpression='##class(BI.Model.PatientsCube).GetAllergyCount(%source.%ID)' 
 aggregate="AVG" />

<measure name="Encounter Count" displayName="Encounter Count" 
 type="integer"
 sourceExpression='##class(BI.Model.PatientsCube).GetEncounterCount(%source.%ID)' 
 aggregate="SUM" 
  searchable="true"/>

<measure name="Avg Enc Count" displayName="Avg Enc Count" 
type="integer"
sourceExpression='##class(BI.Model.PatientsCube).GetEncounterCount(%source.%ID)' 
 aggregate="AVG"/>

<measure name="Test Score" displayName="Test Score" 
sourceProperty="TestScore" 
 aggregate="SUM" searchable="true"/>

<measure name="Avg Test Score" displayName="Avg Test Score" 
sourceProperty="TestScore" 
 aggregate="AVG"/>


<calculatedMember name="Unique Doctor Count" displayName="Unique Doctor Count" 
dimension="Measures"
valueExpression="COUNT([docd].[h1].[doctor].MEMBERS,EXCLUDEEMPTY)"  
 description="This calculated measure counts members of the DocD dimension"/>

<calculatedMember name="Median Test Score" displayName="Median Test Score" 
dimension="Measures"
valueExpression='%KPI("%DeepSee.Median","MEDIAN",1,"%measure","Test Score","%CONTEXT")' 
formatString="#.##"
 description="This calculated member demos the sample median plugin"/>

<calculatedMember name="90th Percentile Test Score" displayName="90th Percentile Test Score" 
dimension="Measures"
valueExpression='%KPI("%DeepSee.Percentile","PERCENTILE",1,"%measure","Test Score","%percentile","90","%CONTEXT")' 
formatString="#.##"
 description="This calculated member demos the sample percentile plugin"/>

<calculatedMember name="Primary Colors" displayName="Primary Colors"
dimension="ColorD"
valueExpression="%OR({[COLORD].[H1].[FAVORITE COLOR].&amp;[Blue],[COLORD].[H1].[FAVORITE COLOR].&amp;[Red],[COLORD].[H1].[FAVORITE COLOR].&amp;[Yellow]})"
 description="This calculated member uses %OR to combine members of the ColorD dimension" />

<calculatedMember name="Secondary Colors" displayName="Secondary Colors"
dimension="ColorD"
valueExpression="%OR({[COLORD].[H1].[FAVORITE COLOR].&amp;[Green],[COLORD].[H1].[FAVORITE COLOR].&amp;[Orange],[COLORD].[H1].[FAVORITE COLOR].&amp;[Purple]})"
 description="This calculated member uses %OR to combine members of the ColorD dimension" />


<listing name="Patient details" displayName="Patient details" 
 fieldList='PatientID,Age,Gender,HomeCity->Name AS "Home City",TestScore AS "Test Score"'
  orderBy="Age,Gender" /> 

<listing name="Doctor details" displayName="Doctor details" 
 fieldList='PatientID,PrimaryCarePhysician->LastName As "Doctor Last Name",PrimaryCarePhysician->FirstName AS "Doctor First Name",PrimaryCarePhysician->DoctorType AS "Doctor Type",PrimaryCarePhysician->DoctorGroup AS "Doctor Group"' 
  orderBy="PatientID" /> 

<listing name="Custom SQL listing" displayName="Custom SQL listing" 
 sql="SELECT source.PatientID,FavoriteColor FROM $$$SOURCE, BI_Study.PatientDetails details 
 WHERE $$$RESTRICT AND source.PatientID=details.PatientID ORDER BY source.PatientID"/>


<namedSet name="Sample Set" displayName="Sample Set" 
setExpression="homed.h1.city.MEMBERS" />

<namedSet name="Sample set 2" displayName="Sample Set 2"
setExpression="{colord.h1.[favorite color].red,allerd.h1.allergies.wheat,aged.h1.age.75}" />

</cube>
}

/// Returns the number of allergies the patient has or null if there are no recorded allergies; 
/// used by the Allergy Count measure.
ClassMethod GetAllergyCount(ID As %Numeric) As %Numeric
{
	set allergies=##class(BI.Study.Patient).%OpenId(ID,0).Allergies
    // Check to see if patient has any recorded allergy data
    // if not, count is null
    
    if allergies.Count()=0 {
		set allcount=""
		}
		 //check to see if patient has "Nil known allergies"
		 //in this case, the patient has one "allergen" whose code is 000
		elseif ((allergies.Count()=1) && (allergies.GetAt(1).Allergen.Code="000")) {
		        set allcount=0
		        }
		else {
	        set allcount=allergies.Count()
	        }		        
	    
	quit allcount
	
	// Quit allergies.Count() ; old simple version doesn't handle case where "allergen"
	// is "Nil known allergies"
}

/// Returns the number of encounters recorded for the patient; 
/// used by the Encounter Count measure.
ClassMethod GetEncounterCount(ID As %Numeric) As %Numeric
{
    set myquery="SELECT Count(*) AS ReturnValue FROM BI_Study.PatientEncounter "
              _ "WHERE Patient=?"
    set rset=##class(%ResultSet).%New("%DynamicQuery:SQL")
    set status=rset.Prepare(myquery)
    if $$$ISERR(status) {Do $System.Status.DisplayError(status) Write "Prepare error"}
    set status=rset.Execute(ID)
    if $$$ISERR(status) {Do $System.Status.DisplayError(status) Write "Execute error"}
    while rset.Next() {
     set ReturnValue=rset.Data("ReturnValue")
     }
    if ReturnValue="" {
        set ReturnValue=0
        }        
    quit ReturnValue
}

/// Returns a $LIST of the allergies of the patient; 
/// used by the [AllerD].[H1].[Allergies] level."
ClassMethod GetAllergies(ID As %Numeric) As %List
{
    set allergies=##class(BI.Study.Patient).%OpenId(ID,0).Allergies
    if (allergies.Count()=0) {quit $LISTFROMSTRING("")}
    set list=""
    for i=1:1:allergies.Count() {
        set $LI(list,i)=allergies.GetAt(i).Allergen.Description
        }
    quit list
}

/// Returns a $LIST of the allergy severities of the patient; 
/// used by the [AllerSevD].[H1].[Allergy Severities] level.
/// Not currently used.
ClassMethod GetAllergySeverities(ID As %Numeric) As %List
{
    set allergies=##class(BI.Study.Patient).%OpenId(ID,0).Allergies
    if (allergies.Count()=0) {
	    set list=$LISTFROMSTRING("")
	    }
        //check to see if patient has "Nil known allergies"
		//in this case, the patient has one "allergen" whose code is 000
	    elseif ((allergies.Count()=1) && (allergies.GetAt(1).Allergen.Code="000")) {
		    set list=$LISTFROMSTRING("Nil known allergies")
		    }
    	else {
	    	set list=""
            for i=1:1:allergies.Count() {
                set $LI(list,i)=allergies.GetAt(i).Severity.Description
                }
	        }
    quit list
}

/// Returns a $LIST of the allergy severities of the patient; 
/// used by the [AllerSevD].[H1].[Allergy Severities] level.
/// In this version, prepend each severity with the corresponding numeric code
/// (or an invented code), in order to force the members to sort as wanted.
ClassMethod GetAllergySeverities2(ID As %Numeric) As %List
{
    set allergies=##class(BI.Study.Patient).%OpenId(ID,0).Allergies
    if (allergies.Count()=0) {
	    set list=$LISTFROMSTRING("999 No Data Available")
	    }
        //check to see if patient has "Nil known allergies"
		//in this case, the patient has one "allergen" whose code is 000
	    elseif ((allergies.Count()=1) && (allergies.GetAt(1).Allergen.Code="000")) {
		    set list=$LISTFROMSTRING("000 Nil known allergies")
		    }
    	else {
	    	set list=""
            for i=1:1:allergies.Count() {
	            //get the code, check to see if null
	            //if so, replace with standard no data available string
	            set code=allergies.GetAt(i).Severity.Code
	            if code="" { set code="999 No Data Available"}
                set $LI(list,i)=code_" "_allergies.GetAt(i).Severity.Description
                }
	        }
    quit list
}

/// Returns a $LIST of the diagnoses of the patient; 
/// used by the [DiagD].[H1].[Diagnoses] level.
ClassMethod GetDiagnoses(ID As %Numeric) As %List
{
    set diagnoses=##class(BI.Study.Patient).%OpenId(ID,0).DiagnosesAsChildren
    if (diagnoses.Count()=0) {quit $LISTFROMSTRING("")}
    set list=""
    for i=1:1:diagnoses.Count() {
        set $LI(list,i)=diagnoses.GetAt(i).DiagnosisCode
        }
    quit list
}

/// Returns the favorite color of the patient; 
/// used by the [ColorD].[H1].[Favorite Color] level.
ClassMethod GetFavoriteColor(patientID As %String) As %String
{
    new SQLCODE
    &sql(SELECT FavoriteColor INTO :ReturnValue 
    FROM BI_Study.PatientDetails 
    WHERE PatientID=:patientID)
    if (SQLCODE'=0) {
        set ReturnValue=""
        }
    quit ReturnValue
}

/// Returns the profession of the patient; 
/// used by the [ProfD].[H1].[Profession] level.
ClassMethod GetProfession(patientID As %String) As %String
{
    new SQLCODE
    &sql(SELECT Profession->Profession INTO :ReturnValue 
    FROM BI_Study.PatientDetails 
    WHERE PatientID=:patientID)
    if (SQLCODE'=0) {
        set ReturnValue=""
        }
    quit ReturnValue
}

/// Returns the industry of the patient; 
/// used by the [ProfD].[H1].[Industry] level.
ClassMethod GetIndustry(patientID As %String) As %String
{
    new SQLCODE
    &sql(SELECT Profession->Industry INTO :ReturnValue 
    FROM BI_Study.PatientDetails 
    WHERE PatientID=:patientID)
    if (SQLCODE'=0) {
        set ReturnValue=""
        }
    quit ReturnValue
}

/// Returns the name of the patient's primary care physician. 
/// Not used by the cube but included as an example of a utility method.
ClassMethod GetDocName(ID As %Numeric) As %String
{
    set pat=##class(BI.Study.Patient).%OpenId(ID,0)
    set doc=pat.PrimaryCarePhysician
    
    set docname=""
    if (doc'="") {
	      set docname=doc.LastName_", "_doc.FirstName
		  }
	quit docname
}

/// Given a number, returns one of the strings "0 to 9", "10 to 19", "20 to 29", etc. 
/// Used by the cube as an alternative to rangeExpression
ClassMethod GetAgeBucket(age As %Numeric) As %String
{
    if (age="") {set return=""}
    elseif (age<10) {set return="0 to 9"}
    elseif (age<20) {set return="10 to 19"}
    elseif (age<30) {set return="20 to 29"}
    elseif (age<40) {set return="30 to 39"}
    elseif (age<50) {set return="40 to 49"}
    elseif (age<60) {set return="50 to 59"}
    elseif (age<70) {set return="60 to 69"}
    elseif (age<80) {set return="70 to 79"}
    else {set return="80+"}
    quit return
}

/// Given a number, returns one of the strings "0 to 29", "30 to 59",or "60+". 
/// Not used by the cube, but included as an example of a utility method.
ClassMethod GetAgeGroup(age As %Numeric) As %String
{
    if (age="") {set return=""}
    elseif (age<30) {set return="0 to 29"}
    elseif (age<60) {set return="30 to 59"}
    else {set return="60+"}
    quit return
}

/// Given a patient, returns the name of the doctor at the patient's last encounter, if any.
/// Not used by the cube but included as an example of a utility method.
ClassMethod GetLastDoctor(pat As %Numeric) As %String
{
    new SQLCODE
    set docname=""
    &sql(select TOP 1 PrimaryDoctor INTO :doctor 
	FROM BI_Study.PatientEncounter 
	WHERE Patient=:pat ORDER BY EncounterNumber )
    if (SQLCODE'=0) {
        quit ""
        }
    set doc=##class(BI.Study.Doctor).%OpenId(doctor,0)
    set docname=doc.LastName_", "_doc.FirstName
    quit docname
}

/// used to control sort order of Allergy Severity level
ClassMethod GetSeveritySort(severity As %String) As %Integer
{
   if (severity="Nil known allergies") {
	   set sort=1
   } elseif (severity="Minor") {
		set sort=2
   } elseif (severity="Moderate") {
		set sort=3
   } elseif (severity="Life-threatening") {
		set sort=4
   } elseif (severity="Inactive") {
		set sort=5
   } elseif (severity="Unable to determine") {
		set sort=6
   } else {
	   set sort=99
   }
   quit sort
}

}

