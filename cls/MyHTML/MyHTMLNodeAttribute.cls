Class MyHTML.MyHTMLNodeAttribute Extends %RegisteredObject
{

Property CNA As CNA.CNA [ Private ];

Property MyHtmlNodeAttributePtr As %CacheString [ Private ];

Method %OnNew(cna As CNA.CNA, attrPtr As %CacheString) As %Status
{
    set ..CNA = cna
    set ..MyHtmlNodeAttributePtr = attrPtr
    return $$$OK
}

Method Next() As MyHTML.MyHTMLNodeAttribute
{
    set attrPtr = ..CNA.CallFunction("myhtml_attribute_next",..CNA.#POINTER,$lb(..CNA.#POINTER),..MyHtmlNodeAttributePtr)
    if attrPtr = ..CNA.NULL  return $$$NULLOREF
    return ..%New(..CNA,attrPtr)
}

Method Key() As %String
{
    set strPtr = ..CNA.CallFunction("myhtml_attribute_key",..CNA.#POINTER,$lb(..CNA.#POINTER,..CNA.#POINTER),..MyHtmlNodeAttributePtr,..CNA.NULL)
    if strPtr = ..CNA.NULL  return ""
    return ..CNA.ConvertPointerToString(strPtr)
}

Method Value() As %String
{
    set strPtr = ..CNA.CallFunction("myhtml_attribute_value",..CNA.#POINTER,$lb(..CNA.#POINTER,..CNA.#POINTER),..MyHtmlNodeAttributePtr,..CNA.NULL)
    if strPtr = ..CNA.NULL  return ""
    return ..CNA.ConvertPointerToString(strPtr)
}

}

