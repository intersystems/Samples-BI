/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This represents a Product within the HoleFoods demo.
Class HoleFoods.Product Extends %Persistent
{

Index KEY On SKU [ IdKey ];

/// Category of this product.
Property Category As %String(MAXLEN = 100);

/// Name of this product.
Property Name As %String(MAXLEN = 120);

/// SKU for this product.
Property SKU As %String(MAXLEN = 22);

/// List price for this product.
Property Price As %Numeric(MINVAL = 0);

}

