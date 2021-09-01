/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This Data Connector uses a UNION query that combines the main patient table with
/// the "extra" patient set (BI.Study.PatientSet2).
Class BI.Model.PatientsQuery Extends %DeepSee.DataConnector
{

XData SourceQuery [ XMLNamespace = "http://www.intersystems.com/deepsee/connector/query" ]
{
<sql>
SELECT %ID,PatientID,Gender,Age,HomeCity->Name AS "HomeCity",
PatientGroup,TestScore From BI_Study.Patient 
UNION
SELECT %ID,PatientID,Gender,Age,HomeCity,
PatientGroup,TestScore From BI_Study.PatientSet2
</sql>
}

/// This XData definition defines the output of this connector.
XData Output [ XMLNamespace = "http://www.intersystems.com/deepsee/connector/output" ]
{
<connector> 
<property name="ID" displayName="ID" idKey="true"
sourceProperty="%ID" /> 

<property name="PatientID" displayName="PatientID" 
sourceProperty="PatientID" /> 

<property name="Gender" displayName="Gender" 
sourceProperty="Gender" /> 

<property name="Age" displayName="Age" 
sourceProperty="Age" type="%ZEN.Datatype.integer"/>

<property name="HomeCity" displayName="Home City" 
sourceProperty="HomeCity"/>

<property name="PatientGroup" displayName="Patient Group" 
sourceProperty="PatientGroup" transform='$CASE(%val,"A":"Group A","B":"Group B",:%val)' />

<property name="TestScore" displayName="Test Score" 
sourceProperty="TestScore" type="%ZEN.Datatype.integer"/>

</connector>
}

}

