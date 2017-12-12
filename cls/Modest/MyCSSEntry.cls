Class Modest.MyCSSEntry Extends %RegisteredObject
{

Property CNA As CNA.CNA [ Private ];

Property MyCssEntryPtr As %CacheString [ Private ];

Method %OnNew(cna As CNA.CNA, myCssEntryPtr As %CacheString) As %Status
{
    set ..CNA = cna
    set ..MyCssEntryPtr = myCssEntryPtr
    return $$$OK
}

Method Selectors() As Modest.MyCSSSelectors
{
    set myCssSelectorsPtr = ..CNA.CallFunction("mycss_entry_selectors",..CNA.#POINTER,$lb(..CNA.#POINTER),..MyCssEntryPtr)
    return ##class(Modest.MyCSSSelectors).%New(..CNA,myCssSelectorsPtr)
}

Method OnClose() As %Status
{
	set argTypes = $lb(..CNA.#POINTER)
	do ..CNA.CallFunction("mycss_entry_destroy", ..CNA.#VOID, argTypes, ..MyCssEntryPtr)
	quit $$$OK
}

}

