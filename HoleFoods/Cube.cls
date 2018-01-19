/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This is a sample DeepSee data model.<br/>
/// This cube represents a model for the fictional "HoleFoods" corporation.
/// It is based on the classes within the HoleFoods package.<br/>
/// To create data for this model, the easiest thing to do is to
/// use the BuildData method within the <class>HoleFoods.Utils</class> class:<br/>
/// From the command line:<br/>
/// <example language="cache">
/// Do ##class(HoleFoods.Utils).BuildData(1000000,1,1)
/// </example>
/// The first argument is the number of records to create, 
/// the second argument indicates that index building should be done in parallel,
/// the third is a verbose flag; if true, then progress is displayed as the data is built.
Class HoleFoods.Cube Extends %DeepSee.CubeDefinition [ DependsOn = (HoleFoods.Transaction, HoleFoods.KPIAction) ]
{

Parameter DOMAIN = "HOLEFOODS";

/// This xml document defines the HoleFoods model.
XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube name="HoleFoods" 
caption="HoleFoods Sales"
defaultListing="Listing"
nullReplacement="Missing Value"
buildRestriction="Actual=1"
actionClass="HoleFoods.KPIAction"
sourceClass="HoleFoods.Transaction">

<listing name="ListingX" 
 sql="SELECT ID,UnitsSold,Outlet->City FROM $$$SOURCE WHERE $$$RESTRICT" />

<listing name="Listing" 
fieldList="%ID,DateOfSale,Outlet->City,%EXTERNAL(Channel) Channel,Product->Name Product,UnitsSold,AmountOfSale Revenue,(Discount*100)||'%' Discount,Comment" 
 orderBy="DateOfSale,%ID"/>

<listing name="Listing By Date" 
fieldList="%ID,DateOfSale" 
 orderBy="DateOfSale,%ID"/>

<listing name="Listing By Product" 
fieldList="%ID,Product->Name Product" 
 orderBy="Product->Name,%ID"/>

<listing name="Customer Info" 
listingType="map" 
 fieldList='%ID,Outlet->City "Store Location",Outlet->Country->Name Country,Product->Name Product,ZipCode "Customer ZipCode",Latitude,Longitude'/>

<listingField name="ID" fieldExpression="%ID" />
<listingField name="Channel" fieldExpression="%EXTERNAL(Channel) Channel" />
<listingField name="City" fieldExpression="Outlet->City" />
<listingField name="Comment" fieldExpression="Comment" />
<listingField name="Country" fieldExpression="Outlet->Country->Name Country" />
<listingField name="Date Of Sale" fieldExpression="DateOfSale" />
<listingField name="Latitude" fieldExpression="Latitude" />
<listingField name="Longitude" fieldExpression="Longitude" />
<listingField name="Product" fieldExpression="Product->Name Product" />
<listingField name="Product Category" fieldExpression="Product->Category" />
<listingField name="Revenue" fieldExpression="AmountOfSale Revenue" />
<listingField name="Units Sold" fieldExpression="UnitsSold" />
<listingField name="ZIP Code" fieldExpression="ZipCode" />

<index name="MxUnitsSold" properties="MxUnitsSold" type="bitmap"/>
<index name="MxAmountSold" properties="MxAmountOfSale" type="bitmap"/>

<measure name="Amount Sold" displayName="Revenue" sourceProperty="AmountOfSale" aggregate="SUM" formatString="$#,###.##"/>
<measure name="Units Sold" sourceProperty="UnitsSold" aggregate="SUM" searchable="true"/>
<measure name="Max Units" sourceProperty="UnitsSold" aggregate="MAX"/>
<measure name="Big Sale Count" sourceExpression='$S(%source.UnitsSold="":"",%source.UnitsSold>5:1,1:0)' type="boolean" />

<measure name="Comment" sourceProperty='Comment' type="text" factName="MxComment" />

<calculatedMember dimension="Measures" name="Pct Sold" valueExpression="Product.CurrentMember/Product.CurrentMember.Parent" formatString="###.##%"/>

<calculatedMember dimension="MyRegion" name="North" valueExpression="Aggregate({Outlet.[Boston],Outlet.[New York]})" />
<calculatedMember dimension="MyRegion" name="South" valueExpression="Aggregate({Outlet.[Atlanta],Outlet.[Paris]})" />
<calculatedMember dimension="MyRegion" name="West" valueExpression="Aggregate({Outlet.[Chicago],Outlet.[Tokyo]})" />

<namedSet name="Top Cities" setExpression="HEAD(Outlet.City.Members,3)" />

<!-- convenient named sets -->
<namedSet name="Last 5 Years" setExpression="DateOfSale.YearSold.[NOW-4]:[NOW]" />
<namedSet name="Current Year " setExpression="DateOfSale.YearSold.[NOW]" />

<calculatedMember dimension="Measures" name="5 year avg growth" 
valueExpression="(DateOfSale.YearSold.[NOW]-DateOfSale.YearSold.[NOW-4])/(DateOfSale.YearSold.[NOW-4]*5)" 
formatString="###.##%"/>
<calculatedMember dimension="Measures" name="Growth over last period" 
valueExpression="(DateOfSale.CurrentMember-DateOfSale.CurrentMember.Lag(1))/DateOfSale.CurrentMember.Lag(1)" 
formatString="###.##%"/>
<calculatedMember dimension="Measures" name="Product percent of total" 
valueExpression="Product.CurrentMember/Product.[All Product].%ALL" 
formatString="###.##%"/>

<calculatedMember name="Median Revenue" displayName="Median Revenue" 
dimension="Measures"
valueExpression='%KPI("%DeepSee.Median","MEDIAN",1,"%measure","Amount Sold","%CONTEXT")' 
formatString="$#,#.##"
 description="This calculated member demos the sample median plugin"/>

<calculatedMember name="90th Percentile Revenue" displayName="90th Percentile Revenue" 
dimension="Measures"
valueExpression='%KPI("%DeepSee.Percentile","PERCENTILE",1,"%measure","Amount Sold","%percentile","90","%CONTEXT")' 
formatString="$#,#.##"
 description="This calculated member demos the sample percentile plugin"/>

<!-- computed dimension based on comments -->
<dimension name="Comments" type="computed" dimensionClass="SQL" hasAll="false">
<hierarchy name="H1">
<level name="Comments" factName="MxComment">
<member name="Complaints" spec="WHERE $$$FACT %CONTAINSTERM('complained') OR $$$FACT %CONTAINSTERM('ranted')"/>
<member name="Compliments" spec="WHERE $$$FACT %CONTAINSTERM('happy')"/>
</level>
</hierarchy>
</dimension>

<dimension name="DateOfSale" type="time" sourceProperty="DateOfSale">
<hierarchy name="Actual">
<level name="YearSold" timeFunction='Year'/>
<level name="MonthSold" timeFunction="MonthYear"/>
<level name="DaySold" timeFunction="DayMonthYear" />
</hierarchy>
</dimension>

<dimension name="Product">
<hierarchy name="P1">
<level name="Product Category" sourceProperty="Product.Category"/>
 <level name="Product Name" sourceProperty="Product" dependsOn="[Outlet].[H1].[Region],[DateOfSale].[Actual].[YearSold]">
<property name="Name" sourceProperty="Product.Name" isName="true" isReference="true"/>
<property name="UnitPrice" sourceProperty="Product.Price" displayName="Unit Price" />
<property name="PriceSquared" sourceExpression='%source.Product.Price*%source.Product.Price' />
<property name="SKU" sourceProperty="Product.SKU" isDescription="true"/>
</level>
</hierarchy>
</dimension>

<dimension name="Outlet">
<hierarchy name="H1">
<level name="Region" sourceProperty="Outlet.Country.Region.Name" />
<level name="Country" sourceProperty="Outlet.Country.Name" />
<level name="City" sourceProperty="Outlet">
<property name="Name" sourceProperty="Outlet.City" isName="true"/>
<property name="Population" sourceProperty="Outlet.Population"/>
<property name="Latitude" sourceProperty="Outlet.Latitude"/>
<property name="Longitude" sourceProperty="Outlet.Longitude"/>
</level>
</hierarchy>
</dimension>

<dimension name="Channel">
<hierarchy name="H1">
<level name="Channel Name" sourceProperty="Channel"  nullReplacement="No Channel">
<property name="Name" sourceProperty="Channel" useDisplayValue="true" isName="true"/>
</level>
</hierarchy>
</dimension>

<dimension name="Discount">
<hierarchy name="H1">
<level name="Discount Type" sourceProperty="Discount" rangeExpression="(,0]:None;(0,0.2):1-19%;[0.2,0.5):20-49%;[0.5,1]:50%+;"/>
</hierarchy>
</dimension>

<!-- this dimension is based on the number of Units Sold at one time -->
<dimension name="UnitsPerTransaction">
<hierarchy name="H1">
<level name="UnitsSold" sourceProperty="UnitsSold" />
</hierarchy>
</dimension>

</cube>
}

}

