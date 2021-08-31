/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This class defines a listing group for the BI Patients sample. 
/// To see the definition of this listing group, use the BI > Tools > Listing Group Manager menu option
/// or open this class in Studio.
Class BI.Model.SampleListingGroup Extends %DeepSee.ListingGroupDefinition [ DependsOn = (BI.Model.PatientsCube, BI.Model.RelCubes.RPatients, BI.Model.SubjectAreas.AsthmaPatients, BI.Model.SubjectAreas.YoungPatients), Not ProcedureBlock ]
{

/// Need this because we have another listing group class with the same short class name.
/// We use the XMLTYPE parameter to make sure these two classes project differently to XML.
Parameter XMLTYPE = "PatientsSampleListingGroup";

Parameter DOMAIN = "PATIENTSAMPLE";

XData Listings [ XMLNamespace = "http://www.intersystems.com/deepsee/listinggroup" ]
{
<listingGroup xmlns="http://www.intersystems.com/deepsee/listinggroup" name="Additional Listings for Patients Sample" disabled="false" targetCubes="PATIENTS,RELATEDCUBES/PATIENTS,ASTHMAPATIENTS,YOUNGPATIENTS">
  <listing name="Sample Listing 1" displayName="Sample Listing 1" disabled="false" listingType="table" fieldList="PatientID,Gender,BirthDate,Age,HomeCity-&gt;PostalCode ZIP,HomeCity-&gt;Name City,PatientGroup"></listing>
  <listing name="Sample Listing 2" disabled="false" listingType="table" fieldList="PatientID,PatientGroup,DiagnosesAsString,TestScore"></listing>
</listingGroup>
}

}

