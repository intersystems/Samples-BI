/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This is a sample DeepSee data model.<br/>
/// This represents budget values for the HoleFoods model.
/// Refer to the <class>HoleFoods.BudgetCube</class> class for more details.
Class HoleFoods.BudgetCube Extends %DeepSee.CubeDefinition [ DependsOn = (HoleFoods.Cube, HoleFoods.Transaction, HoleFoods.KPIAction) ]
{

Parameter DOMAIN = "HOLEFOODS";

/// This xml document defines the HoleFoods model.
XData Cube [ XMLNamespace = "http://www.intersystems.com/deepsee" ]
{
<cube name="HoleFoodsBudget" 
caption="HoleFoods Budget"
defaultListing="Listing"
defaultMember="[Product].[All Product]"
nullReplacement="Missing Value"
buildRestriction="Actual=0"
actionClass="HoleFoods.KPIAction"
sourceClass="HoleFoods.Transaction">

<listing name="ListingX" sql="SELECT ID,UnitsSold,Outlet->City FROM $$$SOURCE WHERE $$$RESTRICT" />
<listing name="Listing" fieldList="%ID,DateOfSale,Outlet->City,%EXTERNAL(Channel) Channel,Product->Name,UnitsSold,AmountOfSale,(Discount*100)||'%' Discount,Comment" orderBy="DateOfSale,%ID"/>
<listing name="Listing By Date" fieldList="%ID,DateOfSale" orderBy="DateOfSale,%ID"/>
<listing name="Listing By Product" fieldList="%ID,Product->Name" orderBy="Product->Name,%ID"/>

<measure name="Target" sourceProperty="TargetAmount" aggregate="SUM" formatString="#,###.##"/>

<dimension name="DateOfSale" sharesFrom="HoleFoods"/>
<dimension name="Product" sharesFrom="HoleFoods"/>
<dimension name="Outlet" sharesFrom="HoleFoods"/>

</cube>
}

}

