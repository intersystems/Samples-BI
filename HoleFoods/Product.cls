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

Storage Default
{
<Data name="ProductDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Category</Value>
</Value>
<Value name="3">
<Value>Name</Value>
</Value>
<Value name="4">
<Value>Price</Value>
</Value>
</Data>
<DataLocation>^HoleFoods.ProductD</DataLocation>
<DefaultData>ProductDefaultData</DefaultData>
<IdLocation>^HoleFoods.ProductD</IdLocation>
<IndexLocation>^HoleFoods.ProductI</IndexLocation>
<StreamLocation>^HoleFoods.ProductS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

