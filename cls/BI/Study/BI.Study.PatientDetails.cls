/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// <p>This class is part of the BI Patients sample, whose purpose is to provide
/// sample data for use with InterSystems IRIS BI. 
/// It represents an additional table of data,
/// perhaps entered by a separate research team, and its only connection to
/// BI.Study.Patient is that both tables have the same PatientID field. Thus to use
/// fields of this table as BI dimensions/levels, it is necessary to use an SQL query
/// in the dimension definition. 
/// <p>This table is populated only if you use the T option when running the
/// GenerateData() method in BI.Populate.
Class BI.Study.PatientDetails Extends %Persistent
{

Property PatientID As %String;

Property Profession As BI.Study.Profession;

Property FavoriteColor As %String;

/// This index is meant to improve performance when the BI indices are built. 
/// The BI data model for BI.Study.Patient uses an SQL query that refers 
/// to PatientID.
Index PatientIDIndex On PatientID [ Unique ];

/// Called by BI.Study.Patient:AddPatients().
ClassMethod CreatePatientDetails(PatientID As %String, age As %Numeric = 35, genNulls As %Boolean) As %Status
{
    set status=$$$OK
    set patdetails=##class(PatientDetails).%New()
    set patdetails.PatientID=PatientID

    // Get random color
    set colorlist=$LB("Red","Blue","Green","Purple","Yellow","Orange")
    set colorid=$RANDOM($LISTLENGTH(colorlist))+1
    set patdetails.FavoriteColor=$LI(colorlist,colorid)

    if ((age>17) && (age<70)) 
    {
        // Not everyone in this age range is employed
        if ##class(BI.Populate).RandomTrue(87){
            // Get random profession
            set profid=##class(BI.Populate).GetRandomId("BI.Study.Profession")
            set patdetails.Profession=##class(BI.Study.Profession).%OpenId(profid,0)
            }
        }
                
    if 'genNulls
    {
        // If genNulls is off, save details in all cases
        set status=patdetails.%Save()
        if $$$ISERR(status) {Do $System.Status.DisplayError(status) Write !, "Details error"}
        }
        Else 
        {
            // If genNulls is on, roll the dice and 
            // save the details only some of the time
            if ##class(BI.Populate).RandomTrue(76)
            {
                set status=patdetails.%Save()
                if $$$ISERR(status) {Do $System.Status.DisplayError(status) Write !, "Patient details save error"}
                }
   }
   
   quit status
}

/// Iterate through patient extent and change color for some percentage of patients.
/// if rebuild is 1, this method updates the BI indices for each patient 
/// affected by these changes. 
ClassMethod ChangePatientDetails(percent As %Numeric = 10, rebuild As %Boolean = 1)
{
    set ^BI.Study.Log($I(^BI.Study.Log))=$zdatetime($h,2,3)_" Changing some patient details..."

    // Create or update the "ID extent sets" from which we can later get random IDs
    set status=##class(BI.Populate).UpdateIdCache($CLASSNAME())

    set recordcount=##class(BI.Populate).Count($CLASSNAME())
    set changecount=0
    
    set colorlist=$LB("Red","Blue","Green","Purple","Yellow","Orange")
    
    for i=1:1:recordcount 
    {
        if ##class(BI.Populate).RandomTrue(percent) 
        {
            set colorid=$RANDOM($LISTLENGTH(colorlist))+1

            set randomid=##class(BI.Populate).GetRandomId($CLASSNAME())
            set patdetails=..%OpenId(randomid)
            set patdetails.FavoriteColor=$LI(colorlist,colorid)
            do patdetails.%Save()
            set changecount=changecount+1   
            
            if rebuild {
                // Because the BI.Study.Patient table is unaware of the BI.Study.PatientDetails
                // table, changing info in PatientDetails does NOT fire any triggers for
                // the patients, so it is necessary to figure out which patients are 
                // affected and update the indices for those patients
            
                set patID=patdetails.PatientID
            
                set myquery="SELECT ID FROM BI_Study.Patient WHERE PatientID=?"
                set rset=##class(%Resultset).%New("%DynamicQuery:SQL")
                set status=rset.Prepare(myquery)
                if $$$ISERR(status) {Do $System.Status.DisplayError(status) quit}
                set status=rset.Execute(patID)
                if $$$ISERR(status) {Do $System.Status.DisplayError(status) quit}
                while rset.Next() {
                    set id=rset.Data("ID")

                    do ##class(%DeepSee.Utils).%ProcessFact("patients",id)

                }
                kill rset              
               
            }
          }
        }
        if rebuild {kill %this} ; needed because zzBuildOne doesn't clean this up
        set ^BI.Study.Log($I(^BI.Study.Log))=$zdatetime($h,2,3)_" Details changed for "_ changecount _" patients"
}

/// Clear out patient details
ClassMethod DeletePatientDetails(PatientID As %String) As %Status
{
            
    set myquery="DELETE FROM BI_Study.PatientDetails WHERE PatientID=?"
    set rset=##class(%Resultset).%New("%DynamicQuery:SQL")
    set status=rset.Prepare(myquery)
    if $$$ISERR(status) {Do $System.Status.DisplayError(status) quit}
    set status=rset.Execute(PatientID)
    quit status
}
}

