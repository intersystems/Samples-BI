# Samples-BI
This is the README file for SAMPLES-BI. 
The end of the file has setup instructions.
************************************************************************************
Use or operation of this code is subject to acceptance of the license available in the code 
repository for this code.
************************************************************************************
SAMPLES-BI is meant for use with the InterSystems IRIS Business Intelligence capabilities.
In order to use this sample, you must have an InterSystems IRIS license that includes these capabilities.

These classes provide sample data that you can use to explore the capabilities of InterSystems IRIS BI.
They also demonstrate ways to create BI models using InterSystems IRIS BI.

This sample contains two packages:
* The DeepSee package, which provides simple data representing a fictitious medical study, and also provides 
  an InterSystems IRIS BI model that uses that data. See details below.
* The HoleFoods package, which provides simple data representing sales of food products, and also provides 
  an InterSystems IRIS BI model that uses that data. See details below.

The documentation for InterSystems IRIS Business Intelligence refers extensively to these samples. 
The HoleFoods model provides a quick and easy introduction to BI, and the DeepSee model demonstrates 
null handling, list-based levels, and other features not included in HoleFoods. The DeepSee package also explicitly demonstrates how to address more difficult modeling scenarios. 

After setup: 
* You can use the Analyzer to explore these BI models; for information, go to 
  http://docs.intersystems.com/irislatest?KEY=D2ANLY_ch_intro
* You can open the InterSystems IRIS dashboard and explore the sample dashboards and pivot
  tables. For information, see http://docs.intersystems.com/irislatest?KEY=D2DASH
* You can work through the steps of creating a BI model, pivot tables, and dashboards.
  See http://docs.intersystems.com/irislatest?KEY=D2DT_ch_setup

************************************************************************************
Contents of the DeepSee package
************************************************************************************
This package provides simple data representing a fictitious medical study, and also provides 
an InterSystems IRIS BI model that uses that data.

* DeepSee.Model package contains the classes that demonstrate BI model capability.
   -  DeepSee.Model.PatientsCube is the primary model; this defines the PATIENTS cube that is 
      used in the MDX reference documentation and for most of the sample queries in the documentation.
      Other classes in DeepSee.Model demonstrate special cases of various kinds; see the modeling guides.
   -  DeepSee.Model.CompoundCube package contains multiple cube definitions that collectively
      demonstrate how to create a compound cube. The Advanced Modeling guide discusses these cubes.
   -  DeepSee.Model.KPIs package contains sample InterSystems IRIS BI KPIs (key performance indicators).
      All of these KPIs are either discussed in the modeling guides or are used in the sample dashboards, 
      to demonstrate different kinds of widgets.
   -  DeepSee.Model.Portlet package demonstrates a sample custom portlet. For details, see the 
      Advanced Modeling guide.
   -  DeepSee.Model.RelCube package contains multiple cube definitions that collectively
      demonstrate how to create a set of related cubes. For details, see the Advanced Modeling guide.
   -  DeepSee.Model.SubjectAreas package contains multiple class definitions that that define 
      subject areas, which are filtered cube definitions. The documentation refers to these in several
      places. The subject area DEMOMDX (DeepSee.Model.DemoMDX) is meant for use in getting familiar
      with MDX.

* DeepSee.Study package contains the classes that generate the data used by these models. The most 
  important classes are these:
   -  DeepSee.Study.Patient is the central class and provides the source table for the PATIENTS cube.
      The patients are generated in an age-sex distribution that follows the 2010 US Census data. 
   -  DeepSee.Diagnosis generates the diagnosis data used when generating patients. This diagnosis
      data consists of a small set of diagnoses for chronic conditions, along with morbidity data
      for these conditions (that is, chance of having this condition, based on age & sex). When data 
      for a patient is generated, the patient is assigned zero or more diagnoses, based on the 
      patient's age and sex, using this data.
   -  DeepSee.Allergen generates a common set of allergens, and DeepSee.AllergySeverity generates a
      common set of allergy severities. When data for a patient is generated, the patient is assigned 
      zero or more allergies, each to an allergen, with a specific severity. This enables BI modelers to
      explore multiple list-based levels and how they relate to each other.
   -  DeepSee.Study.Profession generates a set of professions, to which the working-age patients are
      assigned.

* DeepSee.Utils,.MDXAutoFiltersKPI is a sample class that adds cube-based filters to a KPI, when used
  as a superclass for that KPI. This class is discussed in the advanced modeling guide.

* DeepSee.APISamples demonstrates how to execute BI queries programmatically on the server. For details,
  see the BI implementation guide.

* DeepSee.DashboardsEtc contains the pivot table and dashboard definitions based on the models in
  the DeepSee.Model package.

* DeepSee.Populate contains the wrapper code used to generate the data for this part of the BI sample.

* DeepSee.RESTClient allows you to exercise the BI REST interface. See the book Client-Side APIs 
  for InterSystems Business Intelligence.

************************************************************************************
Contents of the HoleFoods package
************************************************************************************
This package provides simple data representing sales of food products, and also provides 
an InterSystems IRIS BI model that uses that data.
* HoleFoods.Transaction, HoleFoods.Country, HoleFoods.Outlet, HoleFoods.Product, and HoleFoods.Region
  generate the data. HoleFoods.Transation provides the source table used by the cube definitions
  for this part of the sample. 
* HoleFoods.Cube defines the HOLEFOODS cube, which is meant as a quick and easy introduction to BI
  in InterSystems IRIS. The documentation refers to this cube in numerous places.
* HoleFoods.BudgetCube and HoleFoods.CombinedCube demonstrate a compound cube.
* HoleFoods.KPI* classes define sample InterSystems IRIS BI KPIs (key performance indicators).
  For details, see the advanced modeling guide.
* HoleFioods.SampleListingGroup is a sample listing group class. Via listing groups, you can define
  detail listings without modifying the cube definition. For details, see the modeling guides.
* HoleFoods.SubjectAreaAsia is a sample subject area. For details, see the modeling guides.
* HoleFoods.Utils contains the code used to generate data for the HoleFoods part of the BI sample.
  It also contains methods you can use to add or delete data, thus exercising techniques for
  keeping the cube contents synchronized with the source data.

************************************************************************************
Setup instructions
************************************************************************************
1. Download the repo to your local disk.
2. Open the InterSystems IRIS Terminal.
3. Enter the following command (replacing with the namespace where you want to load the sample):

   ZN "mynamespace"
4. Enter the following commands (replacing with the full path of the buildsample/buildsamplebi.rtn file):

   do $system.OBJ.Load("full-path-to-buildsamplebi.rtn","ck")
   
   do ^buildsamplebi
5. Then answer any prompts.
6. After the routine has finished running, create a web application for use in this namespace and 
   enable that web app for use with analytics. Here's how:

   a. In the Management Portal, select System Administration > Security > Applications > Web Applications. 

   b. Click Create New Web Application. 

   c. For name, type csp/namespace where namespace is the specific namespace you're using. 
   d. For Namespace, select the same namespace. 

   e. Check the DeepSee and iKnow check boxes. 

   f. Accept all other defaults. 

   g. Click Save.

   If you have already defined a web application for use in this namespace, check the definiton of that web
   application and ensure that both DeepSee and iKnow check boxes are selected.

After step 6, when you access the Analytics submenu of the Management Portal, this namespace will be listed.
For example, you can now use the Analyzer with the cubes that are included within this sample.
