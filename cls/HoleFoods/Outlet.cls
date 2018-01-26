/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This represents a Sales Outlet for the HoleFoods demo.
Class HoleFoods.Outlet Extends %Persistent
{

/// Country in which this city is located.
Property Country As Country;

/// City name of this location.
Property City As %String(MAXLEN = 100);

/// Population of this city.
Property Population As %Integer(MINVAL = 0);

/// Type of outlet: "retail", "web", etc.
Property Type As %String(MAXLEN = 50);

/// Latitude of this location.
Property Latitude As %Double;

/// Longitude of this location.
Property Longitude As %Double;

Storage Default
{
<Data name="OutletDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Country</Value>
</Value>
<Value name="3">
<Value>City</Value>
</Value>
<Value name="4">
<Value>Population</Value>
</Value>
<Value name="5">
<Value>Type</Value>
</Value>
<Value name="6">
<Value>Latitude</Value>
</Value>
<Value name="7">
<Value>Longitude</Value>
</Value>
</Data>
<DataLocation>^HoleFoods.OutletD</DataLocation>
<DefaultData>OutletDefaultData</DefaultData>
<IdLocation>^HoleFoods.OutletD</IdLocation>
<IndexLocation>^HoleFoods.OutletI</IndexLocation>
<StreamLocation>^HoleFoods.OutletS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}

