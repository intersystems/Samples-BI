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

}

