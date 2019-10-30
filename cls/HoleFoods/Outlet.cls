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

}

