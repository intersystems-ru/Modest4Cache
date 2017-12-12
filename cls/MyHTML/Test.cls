Class MyHTML.Test [ Abstract ]
{

ClassMethod PrintTree(tree As MyHTML.MyHTMLTree, node As MyHTML.MyHTMLTreeNode, level As %Integer)
{
    while $isobject(node)
    {
        for j = 1:1:level  write "  "
        set tagId = node.TagId()
        set tagName = tree.TagNameById(tagId)
        if tagName '= ""
        {
            write "<"_tagName
        }
        else
        {
            write "<!wrong!"
        }
        set attr = node.FirstAttribute()
        while $isobject(attr)
        {
            set name = attr.Key()
            if name '= ""
            {
                write " "_name
                set value = attr.Value()
                if value '= ""  write "="""_value_""""
            }
            set attr = attr.Next()
        }
        if node.IsCloseSelf()  w "/"
        if (tagId = ##class(MyHTMLTreeNode).#TagIdText) || (tagId = ##class(MyHTMLTreeNode).#TagIdComment)
        {
            w ">: "_node.Text(), !
        }
        else
        {
            w ">", !
        }
        do ..PrintTree(tree,node.FirstChild(),level+1)
        set node = node.Next()
    }
}

ClassMethod PrintTreeNode(tree As MyHTML.MyHTMLTree, node As MyHTML.MyHTMLTreeNode, level As %Integer)
{
    while $isobject(node)
    {
        for j = 1:1:level  write "  "
        set tagId = node.TagId()
        set tagName = tree.TagNameById(tagId)
        if tagName '= ""
        {
            write "<"_tagName
        }
        else
        {
            write "<!wrong!"
        }
        set attr = node.FirstAttribute()
        while $isobject(attr)
        {
            set name = attr.Key()
            if name '= ""
            {
                write " "_name
                set value = attr.Value()
                if value '= ""  write "="""_value_""""
            }
            set attr = attr.Next()
        }
        if node.IsCloseSelf()  w "/"
        if (tagId = ##class(MyHTMLTreeNode).#TagIdText) || (tagId = ##class(MyHTMLTreeNode).#TagIdComment)
        {
            w ">: "_node.Text(), !
        }
        else
        {
            w ">", !
        }
        do ..PrintTree(tree,node.FirstChild(),level+1)
        set node = node.FirstChild()
    }
}

/// do ##class(MyHTML.Test).Test1()
ClassMethod Test1()
{
    set myHtml = ##class(MyHTML.MyHTML).%New()
    set tree = myHtml.CreateTree()
    do tree.Parse("<html><head></head><body>Hello, world!<input type=""button""/></body></html>")
    set node = tree.GetDocument()
    do ..PrintTree(tree,node.FirstChild(),0)
}

ClassMethod Test2()
{
    set myHtml = ##class(MyHTML.MyHTML).%New()
    set tree = myHtml.CreateTree()
    set request = ##class(%Net.HttpRequest).%New()
    set request.Server = "google.com"
    set request.Https = $$$YES
    set request.SSLConfiguration = "google"
    set st = request.Get("/")
    do $SYSTEM.Status.DisplayError(st)
    set html = request.HttpResponse.Data.Read(100000000)
    do tree.Parse(html)
    set node = tree.GetDocument()
    do ..PrintTree(tree,node.FirstChild(),0)
}

/// w ##class(MyHTML.Test).Test1()
ClassMethod Test3()
{
    set myHtml = ##class(MyHTML.MyHTML).%New()
    set tree = myHtml.CreateTree()
    do tree.Parse("<div><p id=p1><p id=p2><p id=p3><a>link</a><p id=p4><p id=p5><p id=p6></div>")
    set node = tree.GetDocument()
    set myCss = ##class(Modest.MyCSS).Create(myHtml.CNA)
    set myCssEntry = myCss.CreateEntry()
    set finder = ##class(Modest.Finder).CreateSimple(myHtml.CNA)
    set entrySelectors = myCssEntry.Selectors()
    set selectorList = entrySelectors.Parse("div > :nth-child(2n+1):not(:has(a))")
    set list = finder.FindBySelectorList(node, selectorList)
    for i = 1:1:list.Count()
    {
        do ..PrintTreeNode(tree,list.GetAt(i),0)
        w !
    }
}

ClassMethod Run()
{
    do ..Test1()
    w !,!,!
    do ..Test2()
}

ClassMethod RunCrash(i As %Integer)
{
    for j=1:1:20{
        s a = $i(^MyHTML.Test.Stat(i))
        do ..Test3()
    }
}

ClassMethod CollectStat()
{
    k ^MyHTML.Test.Stat
    for i=1:1:100{
        j ..RunCrash(i)
    }
    zw ^MyHTML.Test.Stat
}

/// do ##class(MyHTML.Test).Test4()
ClassMethod Test4()
{
	set file = ##class(%Stream.FileCharacter).%New()
	set file.TranslateTable = "CP1251"
	do file.LinkToFile("C:\Users\gevor\OneDrive\Рабочий стол\5001_5291169.html")
	
    set myHtml = ##class(MyHTML.MyHTML).%New()
    set tree = myHtml.CreateTree()
    do tree.Parse(file.Read($$$MaxStringLength))
    set node = tree.GetDocument()

	//do ..PrintTree(tree,node.FirstChild(),0)
	
	
    set myCss = ##class(Modest.MyCSS).Create(myHtml.CNA)
    set myCssEntry = myCss.CreateEntry()
    
    set finder = ##class(Modest.Finder).CreateSimple(myHtml.CNA)
    
    set entrySelectors = myCssEntry.Selectors()
    
    set selectorList = entrySelectors.Parse("META[name*=""JUDGENAME""]")
    
    set list = finder.FindBySelectorList(node, selectorList)
    
    //do ##class(%ZEN.Auxiliary.jsonProvider).%ObjectToJSON(list,,,"bioaeqltw")
    
    for i = 1:1:list.Count()
    {
	    do ..PrintTreeNode(tree,list.GetAt(i),0)
	    set node = list.GetAt(i)
       
        set attr = node.FirstAttribute()
        while $isobject(attr)
        {
            set name = attr.Key()
            if name '= ""
            {
                write name _ ": " _ attr.Value(),!
            }
            set attr = attr.Next()
        }
	}
	
	do myCss.OnClose()
	do myCssEntry.OnClose()
	do finder.OnClose()
	
	do myHtml.Free(tree)
	kill
}

ClassMethod ToUTF8() As %Status
{
	set file = ##class(%Stream.FileCharacter).%New()
	set file.TranslateTable = "CP1251"
	do file.LinkToFile("C:\Users\gevor\OneDrive\Рабочий стол\0535_534776_original.html")
	
	set file2 = ##class(%Stream.FileCharacter).%New()
	set file2.TranslateTable = "UTF8"
	do file2.LinkToFile("C:\Users\gevor\OneDrive\Рабочий стол\0535_534776_original_utf8.html")
	
	q file2.CopyFromAndSave(file)
}

}

