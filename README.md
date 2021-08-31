# Samples-BI
This is the README file for SAMPLES-BI. 
The end of the file has setup instructions.

* [Overview](#overview)
  * [Contents of the BI package](#contents-of-the-bi-package)
  * [Contents of the HoleFoods package](#contents-of-the-holefoods-package)
* [Setup instructions](#setup-instructions)
  * [Setup with Docker and ZPM](#setup-with-docker-and-zpm)
  * [Step-by-step Installation](#step-by-step-installation)

---
Use or operation of this code is subject to acceptance of the license available in the code 
repository for this code.

---

## Overview

Samples-BI is meant for use with the InterSystems IRIS Business Intelligence capabilities.
In order to use this sample, you must have an InterSystems IRIS license that includes these capabilities.

These classes provide sample data that you can use to explore the capabilities of InterSystems IRIS BI.
They also demonstrate ways to create BI models using InterSystems IRIS BI.

This sample contains two packages:
* The `BI` package, which provides simple data representing a fictitious medical study, and also provides 
  an InterSystems IRIS BI model that uses that data. See details below.
* The `HoleFoods` package, which provides simple data representing sales of food products, and also provides 
  an InterSystems IRIS BI model that uses that data. See details below.

The documentation for InterSystems IRIS Business Intelligence refers extensively to these samples. 
The HoleFoods model provides a quick and easy introduction to BI, and the BI model demonstrates 
null handling, list-based levels, and other features not included in HoleFoods. The BI package also 
explicitly demonstrates how to address more difficult modeling scenarios. 

After setup: 
* You can use the Analyzer to explore these BI models; for information, go [here](http://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=D2ANLY_ch_intro)
* You can open the InterSystems IRIS dashboard and explore the sample dashboards and pivot
  tables. For information, see [this](http://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=D2DASH)
* You can work through the steps of creating a BI model, pivot tables, and dashboards.
  See [this](http://docs.intersystems.com/irislatest/csp/docbook/Doc.View.cls?KEY=D2DT_ch_setup)

The repository also includes a number of configuration files and scripts that are not part of the sample itself.
Please refer to [dev.md] for more about the role of these files.

### Contents of the BI package

This package provides simple data representing a fictitious medical study, and also provides 
an InterSystems IRIS BI model that uses that data.

* `BI.Model` package contains the classes that demonstrate BI model capability.
   -  `BI.Model.PatientsCube` is the primary model; this defines the PATIENTS cube that is 
      used in the MDX reference documentation and for most of the sample queries in the documentation.
      Other classes in BI.Model demonstrate special cases of various kinds; see the BI modeling guides.
   -  `BI.Model.CompoundCube` package contains multiple cube definitions that collectively
      demonstrate how to create a compound cube. The Advanced Modeling guide discusses these cubes.
   -  `BI.Model.KPIs` package contains sample InterSystems IRIS BI KPIs (key performance indicators).
      All of these KPIs are either discussed in the modeling guides or are used in the sample dashboards, 
      to demonstrate different kinds of widgets.
   -  `BI.Model.Portlet` package demonstrates a sample custom portlet. For details, see the 
      Advanced Modeling guide.
   -  `BI.Model.RelCube` package contains multiple cube definitions that collectively
      demonstrate how to create a set of related cubes. For details, see the Advanced Modeling guide.
   -  `BI.Model.SubjectAreas` package contains multiple class definitions that that define 
      subject areas, which are filtered cube definitions. The documentation refers to these in several
      places. The subject area DEMOMDX (`DeepSee.Model.DemoMDX`) is meant for use in getting familiar
      with MDX.

* `BI.Study` package contains the classes that generate the data used by these models. The most 
  important classes are these:
   -  `BI.Study.Patient` is the central class and provides the source table for the PATIENTS cube.
      The patients are generated in an age-sex distribution that follows the 2010 US Census data. 
   -  `BI.Diagnosis` generates the diagnosis data used when generating patients. This diagnosis
      data consists of a small set of diagnoses for chronic conditions, along with morbidity data
      for these conditions (that is, chance of having this condition, based on age & sex). When data 
      for a patient is generated, the patient is assigned zero or more diagnoses, based on the 
      patient's age and sex, using this data.
   -  `BI.Allergen` generates a common set of allergens, and BI.AllergySeverity generates a
      common set of allergy severities. When data for a patient is generated, the patient is assigned 
      zero or more allergies, each to an allergen, with a specific severity. This enables BI modelers to
      explore multiple list-based levels and see how they relate to each other.
   -  `BI.Study.Profession` generates a set of professions, to which the working-age patients are
      assigned.

* `BI.Utils.MDXAutoFiltersKPI` is a sample class that adds cube-based filters to a KPI, when used
  as a superclass for that KPI. This class is discussed in the advanced modeling guide.

* `BI.APISamples` demonstrates how to execute BI queries programmatically on the server. For details,
  see the BI implementation guide.

* `BI.DashboardsEtc` contains the pivot table and dashboard definitions based on the models in
  the BI.Model package.

* `BI.Populate` contains the wrapper code used to generate the data for this part of the BI sample.

### Contents of the HoleFoods package

This package provides simple data representing sales of food products, and also provides 
an InterSystems IRIS BI model that uses that data.
* `HoleFoods.Transaction`, `HoleFoods.Country`, `HoleFoods.Outlet`, `HoleFoods.Product`, and `HoleFoods.Region`
  generate the data. `HoleFoods.Transation` provides the source table used by the cube definitions
  for this part of the sample. 
* `HoleFoods.Cube` defines the HOLEFOODS cube, which is meant as a quick and easy introduction to BI
  in InterSystems IRIS. The documentation refers to this cube in numerous places.
* `HoleFoods.BudgetCube` and `HoleFoods.CombinedCube` demonstrate a compound cube.
* `HoleFoods.KPI*` classes define sample InterSystems IRIS BI KPIs (key performance indicators).
  For details, see the advanced modeling guide.
* `HoleFoods.SampleListingGroup` is a sample listing group class. Via listing groups, you can define
  detail listings without modifying the cube definition. For details, see the modeling guides.
* `HoleFoods.SubjectAreaAsia` is a sample subject area. For details, see the modeling guides.
* `HoleFoods.Utils` contains the code used to generate data for the HoleFoods part of the BI sample.
  It also contains methods you can use to add or delete data, thus exercising techniques for
  keeping the cube contents synchronized with the source data.

## Setup instructions

### Setup with Docker and ZPM

ZPM stands for ObjectScript Package Manager. It provides a simple and unified way to install ObjectScript modules [Learn More](https://community.intersystems.com/post/introducing-intersystems-objectscript-package-manager). You can either install ZPM on an existing InterSystems IRIS instance based on [these instructions](https://github.com/intersystems-community/zpm), or use one of the prebuilt Community Edition Docker images that have it pre-installed. The instructions below are for the latter option.

0. Make sure you have [Docker-desktop](https://www.docker.com/products/docker-desktop) installed.

1. Pull the IRIS Community Edition image with zpm:
```
$ docker pull intersystemsdc/iris-community:2021.1.0.215.0-zpm
```
   You can take the latest tag of IRIS or IRIS for Health Community Edition with ZPM [here](https://hub.docker.com/r/intersystemsdc/iris-community)

2. Run IRIS container with ZPM:
```
$ docker run --name irisce -d --publish 52773:52773 intersystemsdc/iris-community:2021.1.0.215.0-zpm
```
3. RUN IRIS terminal and install Samples-BI:
```
docker exec -it irisce iris session iris
Node: c6e0f00b8d42, Instance: IRIS

USER>zpm  
zpm: USER>install samples-bi

[samples-bi]	Reload START
[samples-bi]	Reload SUCCESS
[samples-bi]	Module object refreshed.
[samples-bi]	Validate START
[samples-bi]	Validate SUCCESS
[samples-bi]	Compile START
[samples-bi]	Compile SUCCESS
[samples-bi]	Activate START
2,187 row(s) created
Building cube [HOLEFOODS]
...
Complete
Elapsed time:                  0.009120s
Source expression time:        0.000307s
Defining term list Patients Pivots...
Defining term list Patients RowSpecs...
Defining YEAR pivot variable in PATIENTS cube

[samples-bi]	Configure SUCCESS
[samples-bi]	Activate SUCCESS
```
4. Open IRIS analytics portal and work with Samples-BI:
http://localhost:52773/csp/user/_DeepSee.UserPortal.Home.zen?$NAMESPACE=USER

### Step-by-step Installation 

1. Clone or [download](http://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=asamples) the repository. If you downloaded a ZIP, extract the files to a directory on the server. You will need to refer to these files' location in step 8.
2. If you have not yet created a namespace in InterSystems IRIS, follow the [detailed instructions](http://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=ASAMPLES_createns) to do so. 
3. In the Management Portal, click System Administration > Security > Applications > Web Applications.
4. Click the link in the first column of the row /csp/mynamespace where `mynamespace` is the namespace from step 2.
5. Click the Analytics checkbox and then click Save.

6. Open the InterSystems IRIS Terminal.
7. Enter the following command (replacing `mynamespace` with the namespace from step 2):
   ```
   ZN "mynamespace"
   ```
8. Enter the following commands (replacing `full-path-to-Build.SampleBI.cls` with the full path of the `buildsample/Build.SampleBI.cls` file):

   ```
   do $system.OBJ.Load("full-path-to-Build.SampleBI.cls","ck")
   
   do ##class(Build.SampleBI).Build()
   ```
9. When prompted, enter the full path of the directory to which you downloaded this sample. The method then loads and compiles the code and performs other needed setup steps.

Now, when you access the Analytics submenu of the Management Portal, this namespace will be listed. For example, you can now use the Analyzer with the cubes that are included within this sample.

IMPORTANT: If the namespace is not listed when you access the Analytics submenu of the Management Portal, see [Setting Up the Web Application](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=D2IMP_ch_setup#D2IMP_setup_web_app) in the book [Implementing InterSystems IRIS Business Intelligence](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=D2IMP_ch_setup).


