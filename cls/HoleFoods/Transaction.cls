/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// Instances of this class represent specific transactions within
/// the HoleFoods demo.<br/>
/// This table combines both "actual" data and "budget" data so that the sample cube
/// can show comparisons between the two.<br/>
/// Actual records will have a true value for the Actual property.<br/>
/// Budget records will have a false value for the Actual property. The budget value will
/// be stored in the TargetAmount property. Budget values are set for each city, product, and
/// month (using the first day of the month).
Class HoleFoods.Transaction Extends %Persistent [ SqlTableName = SalesTransaction ]
{

/// Track changes to this class.
Parameter DSTIME = "auto";

Index DateOfSale On DateOfSale;

Index Product On Product [ Type = bitmap ];

Index Outlet On Outlet [ Type = bitmap ];

/// If true, this represents an actual sale
/// otherwise this represents a sales target.
Property Actual As %Boolean;

/// Date of this sale.
Property DateOfSale As %Date;

/// Product sold.
Property Product As Product;

/// Store or other outlet in which the sale occurred.
Property Outlet As Outlet;

/// Channel product was sold through: "Retail" or "Online".
Property Channel As %String(DISPLAYLIST = ",Retail,Online", VALUELIST = ",1,2");

/// Actual amount of this sale.
Property AmountOfSale As %Numeric(SCALE = 2);

/// Units sold.
Property UnitsSold As %Integer;

/// Discount amount.
Property Discount As %Numeric(SCALE = 2);

/// For budget items, this is the target value for a period,region, and product.
Property TargetAmount As %Numeric(SCALE = 2);

/// Customer comment on this transaction (if any).
Property Comment As %String(MAXLEN = 500);

/// US Zipcode of customer (if provided).
Property ZipCode As %String(MAXLEN = 25);

/// Latitude of customer (determined from zip code).
Property Latitude As %Double;

/// Longitude of customer (determined from zip code).
Property Longitude As %Double;

Storage Default
{
<Data name="TransactionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Actual</Value>
</Value>
<Value name="3">
<Value>DateOfSale</Value>
</Value>
<Value name="4">
<Value>Product</Value>
</Value>
<Value name="5">
<Value>Outlet</Value>
</Value>
<Value name="6">
<Value>Channel</Value>
</Value>
<Value name="7">
<Value>AmountOfSale</Value>
</Value>
<Value name="8">
<Value>UnitsSold</Value>
</Value>
<Value name="9">
<Value>Discount</Value>
</Value>
<Value name="10">
<Value>TargetAmount</Value>
</Value>
<Value name="11">
<Value>Comment</Value>
</Value>
<Value name="12">
<Value>ZipCode</Value>
</Value>
<Value name="13">
<Value>Latitude</Value>
</Value>
<Value name="14">
<Value>Longitude</Value>
</Value>
</Data>
<DataLocation>^HoleFoods.TransactionD</DataLocation>
<DefaultData>TransactionDefaultData</DefaultData>
<IdLocation>^HoleFoods.TransactionD</IdLocation>
<IndexLocation>^HoleFoods.TransactionI</IndexLocation>
<StreamLocation>^HoleFoods.TransactionS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

