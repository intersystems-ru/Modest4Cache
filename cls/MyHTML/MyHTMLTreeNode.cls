Class MyHTML.MyHTMLTreeNode Extends %RegisteredObject
{

Parameter StructCollection = {$lb(##class(CNA.CNA).#POINTER,##class(CNA.CNA).#SIZET,##class(CNA.CNA).#SIZET)};

Parameter TagIdUndef = 0;

Parameter TagIdText = 1;

Parameter TagIdComment = 2;

Property CNA As CNA.CNA [ Private ];

Property MyHtmlTreeNodePtr As %CacheString;

Method %OnNew(cna As CNA.CNA, myHtmlTreeNodePtr As %CacheString) As %Status
{
    set ..CNA = cna
    set ..MyHtmlTreeNodePtr = myHtmlTreeNodePtr
    return $$$OK
}

Method FirstChild() As MyHTML.MyHTMLTreeNode
{
    set nodePtr = ..CNA.CallFunction("myhtml_node_child",..CNA.#POINTER,$lb(..CNA.#POINTER),..MyHtmlTreeNodePtr)
    if nodePtr = ..CNA.NULL  return ""
    return ##class(MyHTML.MyHTMLTreeNode).%New(..CNA,nodePtr)
}

Method Text() As %String
{
    set strPtr = ..CNA.CallFunction("myhtml_node_text",..CNA.#POINTER,$lb(..CNA.#POINTER,..CNA.#POINTER),..MyHtmlTreeNodePtr,..CNA.NULL)
    return ..CNA.ConvertPointerToString(strPtr)
}

Method TagId() As %Integer
{
    return ..CNA.CallFunction("myhtml_node_tag_id",..CNA.#UINT,$lb(..CNA.#POINTER),..MyHtmlTreeNodePtr)
}

Method IsCloseSelf() As %Boolean
{
    return ..CNA.CallFunction("myhtml_node_is_close_self",..CNA.#INT,$lb(..CNA.#POINTER),..MyHtmlTreeNodePtr) = 1
}

Method Next() As MyHTML.MyHTMLTreeNode
{
    set nodePtr = ..CNA.CallFunction("myhtml_node_next",..CNA.#POINTER,$lb(..CNA.#POINTER),..MyHtmlTreeNodePtr)
    if nodePtr = ..CNA.NULL  return ""
    return ..%New(..CNA,nodePtr)
}

Method FirstAttribute() As MyHTML.MyHTMLNodeAttribute
{
    set attrPtr = ..CNA.CallFunction("myhtml_node_attribute_first",..CNA.#POINTER,$lb(..CNA.#POINTER),..MyHtmlTreeNodePtr)
    if attrPtr = ..CNA.NULL  return $$$NULLOREF
    return ##class(MyHTML.MyHTMLNodeAttribute).%New(..CNA,attrPtr)
}

}

