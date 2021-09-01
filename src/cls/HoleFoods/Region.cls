/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This specifies a geographic region within the HoleFoods demo.
Class HoleFoods.Region Extends %Persistent
{

/// Name of this region.
Property Name As %String(MAXLEN = 80);

Storage Default
{
<Data name="RegionDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
</Data>
<DataLocation>^HoleFoods.RegionD</DataLocation>
<DefaultData>RegionDefaultData</DefaultData>
<IdLocation>^HoleFoods.RegionD</IdLocation>
<IndexLocation>^HoleFoods.RegionI</IndexLocation>
<StreamLocation>^HoleFoods.RegionS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}

