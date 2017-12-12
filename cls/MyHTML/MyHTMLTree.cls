Class MyHTML.MyHTMLTree Extends %RegisteredObject
{

Parameter MyEncodingUtf8 = 0;

Property CNA As CNA.CNA [ Private ];

Property MyHtmlTreePtr As %CacheString;

Method %OnNew(cna As CNA.CNA, myHtmlPtr As %CacheString) As %Status
{
    set ..CNA = cna
    set ..MyHtmlTreePtr = ..CNA.CallFunction("myhtml_tree_create",..CNA.#POINTER,"")
    do ..CNA.CallFunction("myhtml_tree_init",..CNA.#VOID,$lb(..CNA.#POINTER,..CNA.#POINTER),..MyHtmlTreePtr,myHtmlPtr)
    return $$$OK
}

Method Parse(str As %String)
{
    set strPtr = ..CNA.ConvertStringToPointer(str)
    do ..CNA.CallFunction("myhtml_parse",..CNA.#VOID,$lb(..CNA.#POINTER,..CNA.#INT,..CNA.#POINTER,..CNA.#INT),..MyHtmlTreePtr,..#MyEncodingUtf8,strPtr,$l(str))
}

Method GetDocument() As MyHTML.MyHTMLTreeNode
{
    set nodePtr = ..CNA.CallFunction("myhtml_tree_get_document",..CNA.#POINTER,$lb(..CNA.#POINTER),..MyHtmlTreePtr)
    return ##class(MyHTML.MyHTMLTreeNode).%New(..CNA,nodePtr)
}

Method TagNameById(tagId As %Integer) As %String
{
    set strPtr = ..CNA.CallFunction("myhtml_tag_name_by_id",..CNA.#POINTER,$lb(..CNA.#POINTER,..CNA.#UINT,..CNA.#POINTER),..MyHtmlTreePtr,tagId,..CNA.NULL)
    if strPtr = ..CNA.NULL  return ""
    return ..CNA.ConvertPointerToString(strPtr)
}

}

