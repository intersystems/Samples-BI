/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// This specifies the country within the HoleFoods demo.
Class HoleFoods.Country Extends %Persistent
{

/// Region in which this country is located.
Property Region As Region;

/// Name of this country.
Property Name As %String(MAXLEN = 90);

}

