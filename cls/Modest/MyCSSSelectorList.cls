Class Modest.MyCSSSelectorList Extends %RegisteredObject
{

Property CNA As CNA.CNA [ Private ];

Property MyCssSelectorListPtr As %CacheString;

Method %OnNew(cna As CNA.CNA, myCssSelectorListPtr As %CacheString) As %Status
{
    set ..CNA = cna
    set ..MyCssSelectorListPtr = myCssSelectorListPtr
    return $$$OK
}

ClassMethod Create(cna As CNA.CNA) As Modest.MyCSS
{
    set myCssPtr = cna.CallFunction("mycss_create",cna.#POINTER,"")
    // TODO Заменить void на struct mystatus_t
    do cna.CallFunction("mycss_init",cna.#VOID,$lb(cna.#POINTER),myCssPtr)
    return ..%New(cna,myCssPtr)
}

}

