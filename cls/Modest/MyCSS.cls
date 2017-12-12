Class Modest.MyCSS Extends %RegisteredObject
{

Property CNA As CNA.CNA [ Private ];

Property MyCssPtr As %CacheString [ Private ];

Method %OnNew(cna As CNA.CNA, myCssPtr As %CacheString) As %Status
{
    set ..CNA = cna
    set ..MyCssPtr = myCssPtr
    return $$$OK
}

ClassMethod Create(cna As CNA.CNA) As Modest.MyCSS
{
    set myCssPtr = cna.CallFunction("mycss_create",cna.#POINTER,"")
    // TODO Заменить void на struct mystatus_t
    do cna.CallFunction("mycss_init",cna.#VOID,$lb(cna.#POINTER),myCssPtr)
    return ..%New(cna,myCssPtr)
}

Method CreateEntry() As Modest.MyCSSEntry
{
    set myCssEntryPtr = ..CNA.CallFunction("mycss_entry_create",..CNA.#POINTER,"")
    // TODO Заменить void на struct mystatus_t
    do ..CNA.CallFunction("mycss_entry_init",..CNA.#VOID,$lb(..CNA.#POINTER,..CNA.#POINTER),..MyCssPtr,myCssEntryPtr)
    return ##class(Modest.MyCSSEntry).%New(..CNA,myCssEntryPtr)
}

Method OnClose() As %Status
{
	set argTypes = $lb(..CNA.#POINTER, ..CNA.#INT)
	do ..CNA.CallFunction("mycss_destroy", ..CNA.#VOID, argTypes, ..MyCssPtr, 1)
	q $$$OK
}

}

