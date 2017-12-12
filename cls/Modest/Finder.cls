Class Modest.Finder Extends %RegisteredObject
{

Property CNA As CNA.CNA [ Private ];

Property FinderPtr As %CacheString [ Private ];

Property CollectionPtr As %CacheString;

Property CollectionPtrPtr As %CacheString;

Property NodePtrArr As %CacheString;

Method %OnNew(cna As CNA.CNA, finderPtr As %CacheString) As %Status
{
    set ..CNA = cna
    set ..FinderPtr = finderPtr
    return $$$OK
}

ClassMethod CreateSimple(cna As CNA.CNA) As Modest.Finder
{
    set finderPtr = cna.CallFunction("modest_finder_create_simple",cna.#POINTER,"")
    return ..%New(cna,finderPtr)
}

Method FindBySelectorList(node As MyHTML.MyHTMLTreeNode, selectorList As Modest.MyCSSSelectorList) As %ListOfObjects(ELEMENTTYPE="MyHTML.MyHTMLTreeNode")
{
    set collectionPtrPtr = ##class(MyHTML.MyHTML).GetPointerToNullPointer(..CNA)
    do ..CNA.CallFunction("modest_finder_by_selectors_list",..CNA.#VOID,$lb(..CNA.#POINTER,..CNA.#POINTER,..CNA.#POINTER,..CNA.#POINTER),
        ..FinderPtr,node.MyHtmlTreeNodePtr,selectorList.MyCssSelectorListPtr,collectionPtrPtr)
    set collectionPtr = ..CNA.PointerGetAt(collectionPtrPtr,..CNA.#POINTER,0)
#;    set collection = ..CNA.PointerGetAt(collectionPtr,##class(MyHTML.MyHTMLTreeNode).#StructCollection,0)
    set nodePtrArr = ..CNA.PointerGetAt(collectionPtr,..CNA.#POINTER,0)
#;    set size = ..CNA.PointerGetAt(collectionPtr,..CNA.#SIZET,1)
    set length = ..CNA.PointerGetAt(collectionPtr,..CNA.#SIZET,2)
    set list = ##class(%ListOfObjects).%New()
    for i = 1:1:length
    {
        set nodePtr = ..CNA.PointerGetAt(nodePtrArr,..CNA.#POINTER,i-1)
        set node1 = ##class(MyHTML.MyHTMLTreeNode).%New(..CNA,nodePtr)
        do list.Insert(node1)
    }
    set ..NodePtrArr = nodePtrArr
    set ..CollectionPtr = collectionPtr
    set ..CollectionPtrPtr = collectionPtrPtr
    return list
}

Method OnClose() As %Status
{
	set argTypes = $lb(..CNA.#POINTER, ..CNA.#INT)
	do ..CNA.CallFunction("modest_finder_destroy", ..CNA.#VOID, argTypes, ..FinderPtr, 1)
	//do ..CNA.CallFunction("mycore_free", ..CNA.#VOID, $lb(..CNA.#POINTER), ..NodePtrArr)
	//do ..CNA.CallFunction("mycore_free", ..CNA.#VOID, $lb(..CNA.#POINTER), ..CollectionPtr)
	//do ..CNA.CallFunction("mycore_free", ..CNA.#VOID, $lb(..CNA.#POINTER), ..CollectionPtrPtr)
	q $$$OK
}

}

