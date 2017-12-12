Class CNA.Examples.LibGD Extends %RegisteredObject
{

Property gd As %String [ Private ];

Property libc As %String [ Private ];

Method %OnNew(CNAPath As %String, gdPath As %String, libcPath As %String) As %Status [ Private ]
{
	try {
		if (('$data(CNAPath)) || ('##class(%File).Exists(CNAPath))) {
			return $$$ERROR("CNA file doesn't exists")	
		}
		if (('$data(gdPath)) || ('##class(%File).Exists(gdPath))) {
			return $$$ERROR("libgd file doesn't exists")	
		}
		if (('$data(libcPath)) || ('##class(%File).Exists(libcPath))) {
			return $$$ERROR("libc file doesn't exists")	
		}
		
		set ..gd = ##class(CNA.CNA).%New(CNAPath)
		set ..libc = ##class(CNA.CNA).%New(CNAPath)

		do ..gd.LoadLibrary(gdPath)
		do ..libc.LoadLibrary(libcPath)
	} catch ex {
		do ex.Log()
		return ex.AsStatus()
	}
	
	Quit $$$OK
}

Method %OnClose() As %Status [ Private ]
{
	try {
		do ..gd.FreeLibrary()
		do ..libc.FreeLibrary()
	} catch ex {
		do ex.Log()
		return ex.AsStatus()
	}
	Quit $$$OK
}

Method DrawAnimatedCircles(path As %String)
{
	try {
		set prev = ..gd.NULL

		set argTypes = $lb(..libc.#POINTER, ..libc.#POINTER)

		set pPath = ..libc.ConvertStringToPointer(path)
		set pMode = ..libc.ConvertStringToPointer("wb")

		set out = ..libc.CallFunction("fopen", ..libc.#POINTER, argTypes, pPath, pMode)
		if (out = ..libc.NULL) {
			write "Can't open file " _ path _ "for writing", !
			return
		}

		set argTypes = $lb(..gd.#INT, ..gd.#INT)
		set im = ..gd.CallFunction("gdImageCreate", ..gd.#POINTER, argTypes, 500, 500)

		set argTypes = $lb(..gd.#POINTER, ..gd.#INT, ..gd.#INT, ..gd.#INT)
		do ..gd.CallFunction("gdImageColorAllocate", ..gd.#INT, argTypes, im, 255, 255, 255)

		set argTypes = $lb(..gd.#POINTER, ..gd.#POINTER, ..gd.#INT, ..gd.#INT)
		do ..gd.CallFunction("gdImageGifAnimBegin", ..gd.#VOID, argTypes, im, out, 1, 0)

		for i=1:1:20 {
			set argTypes = $lb(..gd.#INT, ..gd.#INT)
			set im = ..gd.CallFunction("gdImageCreate", ..gd.#POINTER, argTypes, 500, 500)

			set argTypes = $lb(..gd.#POINTER, ..gd.#INT, ..gd.#INT, ..gd.#INT)
			do ..gd.CallFunction("gdImageColorAllocate", ..gd.#INT, argTypes, im, 255, 255, 255)
			set color = ..gd.CallFunction("gdImageColorAllocate", ..gd.#INT, argTypes, im, $r(256), $r(256), $r(256))

			set $li(argTypes, *+1) = ..gd.#INT
			set d = 50 + $r(250)
			do ..gd.CallFunction("gdImageFilledEllipse", ..gd.#VOID, argTypes, im, (d \ 2) + $r(500 - d), (d \ 2) + $r(500 - d), d, d, color)

			set argTypes = $lb(..gd.#POINTER, ..gd.#POINTER, ..gd.#INT, ..gd.#INT, ..gd.#INT, ..gd.#INT, ..gd.#INT, ..gd.#POINTER)
			do ..gd.CallFunction("gdImageGifAnimAdd", ..gd.#VOID, argTypes, im, out, 1, 0, 0, 10, 1, prev)
			
			if (prev '= ..gd.NULL) {
				set argTypes = $lb(..gd.#POINTER) 
				do ..gd.CallFunction("gdImageDestroy", ..gd.#VOID, argTypes, prev)
			}
			set prev = im
		}

		set argTypes = $lb(..gd.#POINTER)
		do ..gd.CallFunction("gdImageGifAnimEnd", ..gd.#VOID, argTypes, out)
		do ..libc.CallFunction("fclose", ..gd.#VOID, argTypes, out)
	} catch ex {
		write $system.Status.GetErrorText(ex.AsStatus()),!
	}
}

Method PrintStringOnPng(path As %String, saveTo As %String, text As %String)
{
	try {
		set pPath = ..libc.ConvertStringToPointer(path)
		set pText = ..libc.ConvertStringToPointer(text)
		set out = ..libc.ConvertStringToPointer(saveTo)
		set rb = ..libc.ConvertStringToPointer("rb")
		set wb = ..libc.ConvertStringToPointer("wb")

		set argTypes = $lb(..libc.#POINTER, ..libc.#POINTER)

		set fd = ..libc.CallFunction("fopen", ..libc.#POINTER, argTypes, pPath, rb)
		if (fd = ..libc.NULL) {
			write "Can't open file " _ path _ "for reading", !
			return
		}

		set argTypes = $lb(..gd.#POINTER)
		set im = ..gd.CallFunction("gdImageCreateFromPng", ..gd.#POINTER, argTypes, fd)
		if (im = ..gd.NULL) {
			write "Can't open png " _ path _ ". File may be corrupt or it does not contain PNG image", !
			return
		}

		set argTypes = $lb(..gd.#POINTER, ..gd.#INT, ..gd.#INT, ..gd.#INT)
		set black = ..gd.CallFunction("gdImageColorAllocate", ..gd.#INT, argTypes, im, 0, 0, 0)

		set font = ..gd.CallFunction("gdFontGetLarge", ..gd.#POINTER)

		set argTypes = $lb(..gd.#POINTER, ..gd.#POINTER, ..gd.#INT, ..gd.#INT, ..gd.#POINTER, ..gd.#INT)
		do ..gd.CallFunction("gdImageString", ..gd.#VOID, argTypes, im, font, 0, 0, pText, black)

		set argTypes = $lb(..gd.#POINTER) 
		do ..libc.CallFunction("fclose", ..gd.#VOID, argTypes, fd)
		
		set $li(argTypes, *+1) = ..libc.#POINTER
		set fd = ..libc.CallFunction("fopen", ..libc.#POINTER, argTypes, out, wb)
		if (fd = ..libc.NULL) {
			write "Can't open file " _ saveTo _ "for writing", !
			return
		}

		do ..gd.CallFunction("gdImagePng", ..gd.#VOID, argTypes, im, fd)

		set argTypes = $lb(..gd.#POINTER) 
		do ..libc.CallFunction("fclose", ..gd.#VOID, argTypes, fd)
		
	} catch ex {
		write $system.Status.GetErrorText(ex.AsStatus()),!
	}
}

}

