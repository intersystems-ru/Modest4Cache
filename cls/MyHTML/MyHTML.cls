Class MyHTML.MyHTML Extends %RegisteredObject
{

Parameter MyHtmlOptionsDefault = 0;

Parameter CNAPath = "C:\InterSystems\Libs\libcna.x86-64.dll";

Parameter MyHtmlPath = "C:\InterSystems\Libs\libmodest-0.dll";

Property CNA As CNA.CNA;

Property MyHtmlPtr As %CacheString [ Private ];

Method %OnNew() As %Status
{
    set ..CNA = ##class(CNA.CNA).%New(..#CNAPath)
    do ..CNA.LoadLibrary(..#MyHtmlPath)
    set ..MyHtmlPtr = ..CNA.CallFunction("myhtml_create",..CNA.#POINTER,"")
    do ..CNA.CallFunction("myhtml_init",..CNA.#VOID,$lb(..CNA.#POINTER,..CNA.#INT,..CNA.#INT,..CNA.#INT),..MyHtmlPtr,..#MyHtmlOptionsDefault,1,0)
    return $$$OK
}

Method CreateTree() As MyHTML.MyHTMLTree
{
    return ##class(MyHTML.MyHTMLTree).%New(..CNA,..MyHtmlPtr)
}

ClassMethod GetPointerToNullPointer(cna As CNA.CNA) As %CacheString
{
    set stream = ##class(%Stream.TmpBinary).%New()
    do stream.Write(cna.NULL)
    do stream.Flush()
    return cna.ConvertStreamToPointer(stream)
}

Method Free(tree)
{
	set argTypes = $lb(..CNA.#POINTER)
	do ..CNA.CallFunction("myhtml_tree_destroy", ..CNA.#VOID, argTypes, tree.MyHtmlTreePtr)
	do ..CNA.CallFunction("myhtml_destroy", ..CNA.#VOID, argTypes, ..MyHtmlPtr)
	do ..CNA.FreeLibrary()
}

}

