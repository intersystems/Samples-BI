/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This specifies the country within the HoleFoods demo.
Class HoleFoods.Country Extends %Persistent
{

/// Region in which this country is located.
Property Region As Region;

/// Name of this country.
Property Name As %String(MAXLEN = 90);

Storage Default
{
<Data name="CountryDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Region</Value>
</Value>
<Value name="3">
<Value>Name</Value>
</Value>
</Data>
<DataLocation>^HoleFoods.CountryD</DataLocation>
<DefaultData>CountryDefaultData</DefaultData>
<IdLocation>^HoleFoods.CountryD</IdLocation>
<IndexLocation>^HoleFoods.CountryI</IndexLocation>
<StreamLocation>^HoleFoods.CountryS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

