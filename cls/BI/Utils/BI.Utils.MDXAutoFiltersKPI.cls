/// Use or operation of this code is subject to acceptance of the license available in the code repository for this code.
/// Use this superclass to create an MDX-based KPI that automatically 
/// adds a %FILTER clause to your MDX query. The %FILTER clause includes
/// any selections in any filters that use levels from the appropriate cube.
/// To use this superclass:
/// Specify sourceType="mdx" in &lt;kpi>.
/// Specify a query within the mdx attribute of &lt;kpi>
/// Specify the CUBE parameter so that we can automatically fetch the members
/// of the levels for use as filters.
/// Instead, all levels of the associated cube are automatically available as filters.
/// Or, if you want more control over the form of the query, override %OnGetMDX() as usual
/// and include the following line after creating your basic MDX query:
/// set pMDX=pMDX_..FilterBuilder()
/// This method gets the current filter state, creates the %FILTER clause, 
/// and tacks it on to the end of your query.
/// If you want more control over the members of one or more filters, override 
/// %OnGetFilterMembers() as usual. To get all the members for a given level/filter, 
/// use this: set sc=..%GetMembersForFilter(..#CUBE,pFilter,.pMembers)
/// And then do something different as needed in other scenarios.
/// To add additional filters (to be used in a different way):
/// Within <kpi>, declare the filters that you want to make available. 
/// The logical name for each filter must be of the form of an MDX level specifier, e.g.,
/// [dimension].[hierarchy].[level]. This is needed so that we can retrieve the 
/// level members.
/// Override %OnGetFilters(). In your implementation, get the filters from the 
/// cube by calling #super() and then add your custom filters to the array.

Class BI.Utils.MDXAutoFiltersKPI Extends %DeepSee.KPI [ Abstract ]
{

/// Specifies the cube that this KPI uses. Specify the logical cube name.
Parameter CUBE As %String;

/// Implementation; can be overridden.
ClassMethod %OnGetFilterMembers(pFilter As %String, Output pMembers As %List, pSearchKey As %String = "", pDataSourceName As %String = "") As %Status
{
    set sc=..%GetMembersForFilter(..#CUBE_".cube",pFilter,.pMembers)
	quit sc
}

/// Implementation; can be overridden.
Method %OnGetMDX(ByRef pMDX As %String) As %Status
{
     set pMDX=pMDX_..FilterBuilder()
     quit $$$OK
}

/// Examines the filters defined in the cube, determines the current value of each, 
/// returns a string that can be used as the %FILTER clause.
Method FilterBuilder() As %String [ Internal, Private ]
{
 	set tFilters=""
 	set tSC = ##class(%DeepSee.Dashboard.Utils).%GetFiltersForDataSource(..#CUBE_".cube",.tFilters)
	quit:$$$ISERR(tSC) ""
   
    // Iterate through defined filters and build up usedFilters array
	set i = "",usedFilters=0
	for {
		set i = $order(tFilters(i))
		quit:i=""

	    set filter=tFilters(i)
	   	set filterName=$LI(filter,2)
		set filterValue=$PROPERTY(..%filterValues,filterName)

		if filterValue'="" { 
		    set usedFilters=usedFilters+1
			do ..ParseFilterValue(filterValue,.FilterStateArray)
			// create usedFilters array
	    	//used FilterStateArray and build the string for this filter
	    	set string=..BuildString(filterName,.FilterStateArray)
	    	set usedFilters(usedFilters)=string
	    } ; end of looking at non-null filters

    } ; end of looking at defined filters
    
    set where=""
    if usedFilters>=1 {
       set where=..CombineFilterStrings(.usedFilters)
    }
    quit where
}

/// Uses usedFilters array and returns a string that can be used
/// as the %FILTER clause of a MDX query.
ClassMethod CombineFilterStrings(ByRef usedFilters) As %String [ Private ]
{
    set where=""
	if (usedFilters=1) {
	    set where=" %FILTER "_usedFilters(1)
   } elseif (usedFilters>1) {
	    set where=usedFilters(1)
		for i=2:1:usedFilters {
			set where="NONEMPTYCROSSJOIN("_usedFilters(i)_","_where_")"
	  	}
	  	set where=" %FILTER "_where
    }
    quit where
}

/// Given a filter value, returns, by reference, a FilterStateArray, 
/// which describes the filter state.
ClassMethod ParseFilterValue(filterValue As %String, Output FilterStateArray) As %Status [ Private ]
{
    // Initialize this node 
    kill FilterStateArray  
    set FilterStateArray("not")=0
    
	Set filterValue = $ZSTRIP(filterValue,"<>W")
	set firstbit=$EXTRACT(filterValue,1,4)
	if firstbit="%NOT" {
		set FilterStateArray("not")=1
		set filterValue=$EXTRACT(filterValue,6,*)
	}

    // Now check if we have a set
    set nextbit=$EXTRACT(filterValue)
    if nextbit="{" {
	    // Take off { from the start and } from the end
	    set filterValue=$EXTRACT(filterValue,2,*-1)
        
		// Parse the list of values the same way that Joe does
		Set valueCount=..%SplitList(filterValue,.tList)
		set FilterStateArray=valueCount
		for i=1:1:valueCount {
			set FilterStateArray(i)=tList(i)
			}
	    
	} else {
		// List has only 1 item; put it into the array
		set FilterStateArray=1
		set FilterStateArray(1)=filterValue
	}

	quit $$$OK
}

/// Given a filter name and a FilterStateArray, 
/// returns a string that can be used as an MDX set.
ClassMethod BuildString(filterName, ByRef FilterStateArray) As %String [ Private ]
{
    if (FilterStateArray = 1) {
	    set string=filterName_"."_FilterStateArray(1)
        if (FilterStateArray("not")=1) {
	       set string=string_".%NOT"
	       }
    } else {
	    set string="%OR({"
	    for i=1:1:FilterStateArray{
		   set string=string_filterName_"."_FilterStateArray(i)_","
		   } 
        // Remove trailing comma and close set (which is wrapped in %OR)
        set string=$EXTRACT(string,1,*-1)
	    set string=string_"})"
	   
        // Deal with NOT case
        if FilterStateArray("not")=1 {
	       set string="EXCEPT("_filterName_".MEMBERS,"_string_")"
	       }
	}
	quit string
}

ClassMethod %OnGetFilterList(Output pFilters As %List, pDataSourceName As %String = "") As %Status
{
		set tSC = ##class(%DeepSee.Dashboard.Utils).%GetFiltersForDataSource(..#CUBE_".cube",.tFilters)
		quit:$$$ISERR(tSC)
		
		set i = ""
		for {
			set i = $order(tFilters(i), 1, data)
			quit:i=""
			
			set pFilters($i(pFilters)) = $lb($lg(data,2), $lg(data,1),,1)
		}
        quit $$$OK
}

}

