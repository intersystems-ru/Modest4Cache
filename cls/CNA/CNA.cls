Class CNA.CNA Extends %RegisteredObject
{

Property LibId As %String [ Private ];

Property CNAId As %Integer [ Private ];

Property TypeSizes As %String [ Private ];

Property Alignments As %String [ Private ];

Property AllocatedMemory As %ListOfDataTypes [ Private ];

Property NULL As %String;

/// C void type. May be used only for the type of return value.
Parameter VOID = 0;

/// Unsigned char.
Parameter UCHAR = 1;

/// Signed char.
Parameter SCHAR = 2;

/// Unsigned int.
Parameter UINT = 3;

/// Signed char.
Parameter INT = 4;

/// Unsigned short.
Parameter USHORT = 5;

/// Signed short.
Parameter SHORT = 6;

/// Unsigned long int.
Parameter ULONG = 7;

/// Signed long int.
Parameter LONG = 8;

/// Unsigned 64-bit int (Usually equal to C type unsigned long long int).
/// <p> Works wrong with values larger than maximum of signed 64-bit integers because of Cache <class>%Integer</class> class limitations. 
Parameter UINT64 = 9;

/// Signed 64-bit int (Usually equals to C type long long int).
Parameter INT64 = 10;

/// Single precision floating point type.
/// <p>Value of this types must be passed to functions as <class>%Double</class>.  
Parameter FLOAT = 11;

/// Double precision floating point type.
/// <p>Value of this types must be passed to functions as <class>%Double</class>.  
Parameter DOUBLE = 12;

/// Type equal to C long double. It's supported not for all platforms.
Parameter LONGDOUBLE = 13;

/// Pointer type.
Parameter POINTER = 14;

/// Type equal to C size_t. Usually it is an unsigned 32 or 64-bit integer.
Parameter SIZET = 15;

/// Structure type.
Parameter STRUCT = 16;

/// Number of all available types in CNA.
Parameter NTYPES = 17;

ClassMethod ThrowMessage(msg As %String) [ Private ]
{
	set st = $$$ERROR($$$GeneralError, msg)
	throw ##class(%Exception.StatusException).CreateFromStatus(st)
}

ClassMethod CreateStructType(types As %List) As %String [ Private ]
{
	set size = $LISTLENGTH(types)
	set structType = $CHAR(..#STRUCT, size)
	for i=1:1:size {
		set type = $LIST(types, i)
		set structType = structType _ ..ConvertTypeFromCacheToCNA(type)
	}
	
	return structType
}

ClassMethod ConvertTypeFromCacheToCNA(type As %String) As %String [ Private ]
{
	if ($LISTVALID(type)) {
		return ..CreateStructType(type)	
	} else {
		return $CHAR(type)
	}
}

Method GetAlignments() As %String [ Private ]
{
	set os = $SYSTEM.Version.GetOS()
	set platform = $SYSTEM.Version.GetPlatform()
	
	set aligns = ""
	for i=0:1:(..#NTYPES - 2) {
		set size = $ASCII(..TypeSizes, i + 1)
		if ((size > 4) && (os = "UNIX") && ($find(platform,"x86-32") '= 0)) {
			set aligns = aligns _ $CHAR(4)
		} else {
			set aligns = aligns _ $CHAR(size)
		} 
	}
	return aligns
}

Method ApplyAlignment(ByRef memory As %String, ByRef offset As %Integer, alignment As %Integer) [ Private ]
{
	set padding = (alignment - (offset # alignment)) # alignment
	if ($DATA(memory)) {
		for j=1:1:padding {
			set memory = memory _ $CHAR(0)
		}
	}
	set offset = offset + padding
}

Method GetSizeAndAlignment(type, Output size As %Integer, Output alignment As %Integer) [ Private ]
{
	if ($LISTVALID(type)) {
		set alignment = 0
		set offset = 0
		for i=1:1:$LISTLENGTH(type) {
			do ..GetSizeAndAlignment($LIST(type, i), .elemSize, .elemAlign)
			if (elemAlign > alignment) {
				set alignment = elemAlign	
			}
			do ..ApplyAlignment( , .offset, elemAlign)
			set offset = offset + elemSize
		}
		do ..ApplyAlignment( , .offset, alignment)
		set size = offset
		
	} else {
		set size = $ASCII(..TypeSizes, type + 1)
		set alignment = $ASCII(..Alignments, type + 1)		
	}
}

Method CheckStructSupport() [ Private ]
{
	set os = $SYSTEM.Version.GetOS()
	set platform = $SYSTEM.Version.GetPlatform()
	
	if (((os '= "UNIX") && (os '= "Windows")) || (($FIND(platform, "x86-32") '= 0) && ($FIND(platform, "x86-64") '= 0))) {
		do ..ThrowMessage("Structures are unsupported on your platform")
	}
}

Method ConvertStructFromCacheToCNA(type As %List, values As %List) As %String [ Private ]
{
	do ..CheckStructSupport()
	
	set struct = ""
	set maxAlign = 0
	set offset = 0
	
	for i=1:1:$LISTLENGTH(values) {
		set elemType = $LIST(type, i)
		do ..GetSizeAndAlignment(elemType, .elemSize, .elemAlign)
		
		if (elemAlign > maxAlign) {
			set maxAlign = elemAlign	
		}
		
		do ..ApplyAlignment(.struct, .offset, elemAlign)
		
		set offset = offset + elemSize
		set struct = struct _ ..ConvertFromCacheToCNA(elemType, $LIST(values, i))
	}
	
	do ..ApplyAlignment(.struct, .offset, maxAlign)
		
	return struct
}

Method ConvertStructFromCNAToCache(type As %List, struct As %String) As %ListOfDataTypes [ Private ]
{
	set aligns = ..GetAlignments()
	set values = ""
	set offset = 0
	for i=1:1:$LISTLENGTH(type) {
		set elemType = $LIST(type, i)
		set elemSize = $ASCII(..TypeSizes, elemType + 1)
		set elemAlign = $ASCII(aligns, elemType + 1)
		
		set padding = (elemAlign - (offset # elemAlign)) # elemAlign
		set offset = offset + padding + elemSize
		set $LIST(values, *+1) = ..ConvertFromCNAToCache(elemType, $EXTRACT(struct, offset - elemSize + 1, offset + 1))

	}	
	return values
}

ClassMethod SignedToUnsigned(value As %Integer, size As %Integer) As %Integer [ Private ]
{
	set max = $CASE(size, 1:"7F", 2:"7FFF", 4:"7FFFFFFF", 8:"7FFFFFFFFFFFFFFF")
	set minusOne = $CASE(size, 1:"FF", 2:"FFFF", 4:"FFFFFFFF", 8:"FFFFFFFFFFFFFFFF")
	
	if ((value > $ZHEX(max)) || (value <= - $ZHEX(max))) {
		do ..ThrowMessage("Illegal value")
	} 
	if (value < 0) {
		set value = $ZHEX(minusOne) + value + 1
	}
	return value
}

ClassMethod UnsignedToSigned(value As %Integer, size As %Integer) As %Integer [ Private ]
{
	set max = $CASE(size, 1:"7F", 2:"7FFF", 4:"7FFFFFFF", 8:"7FFFFFFFFFFFFFFF")
	set minusOne = $CASE(size, 1:"FF", 2:"FFFF", 4:"FFFFFFFF", 8:"FFFFFFFFFFFFFFFF")
	
	if ((value < 0) || (value > $ZHEX(minusOne))) {
		do ..ThrowMessage("Illegal Value")
	}
	if (value > $ZHEX(max)) {
		set value = value - $ZHEX(minusOne) - 1
	}
	return value
}

ClassMethod ConvertIntegerFromCacheToCNA(type As %Integer, size As %Integer, value As %Integer) As %String [ Private ]
{
	set isUnsigned = (type = ..#UCHAR ) || 
	                 (type = ..#UINT  ) ||
	                 (type = ..#USHORT) ||
	                 (type = ..#ULONG ) ||
	                 (type = ..#SIZET ) ||
	                 (type = ..#UINT64)
	
	if (('isUnsigned) && ((size = 1) || (size = 2) || (size = 4))) {
		set value = ..SignedToUnsigned(value, size)
	} elseif (isUnsigned && (size = 8)) {
		//set value = ..UnsignedToSigned(value, size)
		//TODO: and support for uint64
	}
	
	return $case(size, 1:$CHAR(value), 2:$ZWCHAR(value), 4:$ZLCHAR(value), 8:$ZQCHAR(value))
}

ClassMethod ConvertIntegerFromCNAToCache(type As %Integer, size As %Integer, value As %String) As %Integer [ Private ]
{
	set isUnsigned = (type = ..#UCHAR ) || 
	                 (type = ..#UINT  ) ||
	                 (type = ..#USHORT) ||
	                 (type = ..#ULONG ) ||
	                 (type = ..#SIZET ) ||
	                 (type = ..#UINT64)
	                 
	set value = $CASE(size, 1:$ASCII(value), 2:$ZWASCII(value), 4:$ZLASCII(value), 8:$ZQASCII(value))
	
	if (('isUnsigned) && ((size = 1) || (size = 2) || (size = 4))) {
		set value = ..UnsignedToSigned(value, size)
	} elseif (isUnsigned && (size = 8)) {
		//set value = ..SignedToUnsigned(value, size)
		//TODO: and support for uint64
	}
	
	return value
}

Method ConvertFromCacheToCNA(type, value) As %String [ Private ]
{
	if (type >= ..#NTYPES) {
			do ..ThrowMessage("Incorrect type")	
	}
	set size = $ASCII(..TypeSizes, type + 1)
			
	if (type = ..#FLOAT) {
		set d2f = $ZF(-4, 3, ..CNAId, "double_to_float")
		set cnaVal = $ZF(-5, ..CNAId, d2f, $ZDCHAR(value))
	}elseif (type = ..#LONGDOUBLE) {
		set d2ld = $ZF(-4, 3, ..CNAId, "double_to_long_double")
		set cnaVal = $ZF(-5, ..CNAId, d2ld, $ZDCHAR(value))
	}elseif (type = ..#DOUBLE) {
		set cnaVal = $ZDCHAR(value)
	}elseif (type = ..#POINTER) {
		set cnaVal = value
	}elseif (type = ..#VOID) {
		do ..ThrowMessage("#VOID may be used only for the type of return value")
	}elseif ($LISTVALID(type)) {
		set cnaVal = ..ConvertStructFromCacheToCNA(type, value)
	}else {
		set cnaVal = ..ConvertIntegerFromCacheToCNA(type, size, value)
	}
	if (cnaVal = "") {
		do ..ThrowMessage("Illegal value or unsupported size of numeric type")
	}
	return cnaVal
}

Method ConvertFromCNAToCache(type, value As %String) [ Private ]
{
	if (type >= ..#NTYPES) {
			do ..ThrowMessage("Incorrect type")	
	}
	set size = $ASCII(..TypeSizes, type + 1)
	if (type = ..#FLOAT) {
		set f2d = $ZF(-4, 3, ..CNAId, "float_to_double")
		set returnValue = $ZDASCII($zf(-5, ..CNAId, f2d, value))
	}elseif (type = ..#LONGDOUBLE) {
		set ld2d = $ZF(-4, 3, ..CNAId, "long_double_to_double")
		set returnValue = $ZDASCII($zf(-5, ..CNAId, ld2d, value))
	}elseif (type = ..#DOUBLE) {
		set returnValue = $ZDASCII(value)
	}elseif (type = ..#POINTER) {
		set returnValue = value
	}elseif (type = ..#VOID) {
		set returnValue = ""
	}elseif ($LISTVALID(type)) {
		set returnValue = ..ConvertStructFromCNAToCache(type, value)
	}else {
		set returnValue = ..ConvertIntegerFromCNAToCache(type, size, value)
	}
	return returnValue
}

/// Calls function <var>name</var> from previously loaded dynamic library.
/// 
/// <p> You need to specify type of return value of the function and types of all arguments.
/// Types may be represented as one of <class>CNA.CNA</class> parameters if it is a plain C datatype or as list of parameters if it is a structure.
/// You need to put all argument types into the list and pass it to argument <var>argTypes</var>.
/// If there is no arguments you need to pass an empty list.
/// 
/// <p> Argument values is passed the same way as a simple function arguments after first four of it.
/// 
/// <p>See examples in <class>CNA.Tests</class>.
Method CallFunction(name As %String, returnType, argTypes As %List, args... As %List)
{
	set callFunc = $ZF(-4, 3, ..CNAId, "call_function")
	if ('$DATA(args)) {
		set args = 0
	}
	if ($LISTLENGTH($GET(argTypes)) '= args) {
		do ..ThrowMessage("Size of list of argument types and number of arguments must be equal.")
	}
	set cnaArgTypes = ""
	set cnaArgs = ""
	
	for i = 1:1:args {
		set val = $GET(args(i))
		if ('$LISTDATA(argTypes, i)) {
			do ..ThrowMessage("Incorrect list of argument types")
		}
		set type = $LIST(argTypes, i)
		
		if ($LISTVALID(type)) {
			do ..GetSizeAndAlignment(type, .size, .alignment) 
			set cnaArgs = cnaArgs _ ..ConvertIntegerFromCacheToCNA(..#SIZET, $ASCII(..TypeSizes, ..#SIZET + 1), size)
		}
		
		set cnaArgs = cnaArgs _ ..ConvertFromCacheToCNA(type, val)
		set cnaArgTypes = cnaArgTypes _ ..ConvertTypeFromCacheToCNA(type)
	}
	set cnaArgTypes = cnaArgTypes _ ..ConvertTypeFromCacheToCNA(returnType)
	set cnaRet = $ZF(-5, ..CNAId, callFunc, ..LibId, name, cnaArgTypes, cnaArgs)
			
	set returnValue =  ..ConvertFromCNAToCache(returnType, cnaRet)
	return returnValue
}

/// Loads dynamic library with path <var>path</var> to CNA.
Method LoadLibrary(path As %String)
{
	set loadLib = $ZF(-4, 3, ..CNAId, "load_library")
	set ..LibId = $ZF(-5, ..CNAId, loadLib, path)
}

/// Releases loaded dynamic library from CNA.
Method FreeLibrary()
{
	set freeLib = $ZF(-4, 3, ..CNAId, "free_library")
	do $ZF(-5, ..CNAId, freeLib, ..LibId)
}

Method %OnNew(CNAPath As %String) As %Status [ Private ]
{
	try {
		if (('$DATA(CNAPath)) || ('##class(%File).Exists(CNAPath))) {
			do ..ThrowMessage("CNA file doesn't exists")	
		}
	
		set ..CNAId = $ZF(-4, 1, CNAPath)
		set getSizes = $ZF(-4, 3, ..CNAId, "get_sizes")
		set ..TypeSizes = $ZF(-5, ..CNAId, getSizes)
		set ..Alignments = ..GetAlignments()
		set ..NULL = ..ConvertFromCacheToCNA(..#SIZET, 0)
	} catch ex {
		do ex.Log()
		return ex.AsStatus()
	}
	
	Quit $$$OK
}

Method %OnClose() As %Status
{
	try {
		set s2p = $ZF(-4, 3, ..CNAId, "free_pointer")
		for i=1:1:..AllocatedMemory.Size {
			do $ZF(-5, ..CNAId, s2p, ..AllocatedMemory.GetAt(i))		
		}

		do $ZF(-4, 2, ..CNAId)
	} catch ex {
		do ex.Log()
		return ex.AsStatus()
	}
	Quit $$$OK
}

/// Provides access to array element with index <var>index</var>. 
/// 
/// <p> <var>pointer</var> must be a C array created by <method>ConvertStreamToPointer</method>, <method>ConvertStringToPointer</method> or by C functions.
/// 
/// <p> <var>type</var> is passed with the same rules as in <method>CallFunction</method>.
/// 
/// <p> Operating with pointers may be unsafe!
Method PointerGetAt(pointer As %String, type, index As %Integer)
{
	set getAt = $ZF(-4, 3, ..CNAId, "pointer_get_at")
	set cnaIndex = ..ConvertFromCacheToCNA(..#SIZET, index)
	set cnaVal = $ZF(-5, ..CNAId, getAt, pointer, $CHAR(type), cnaIndex)
	return ..ConvertFromCNAToCache(type, cnaVal)
}

/// Assigns <var>value</var> to array element with index <var>index</var>. 
/// 
/// <p> <var>pointer</var> must be a C array created by <method>ConvertStreamToPointer</method>, <method>ConvertStringToPointer</method> or by C functions.
/// 
/// <p> <var>type</var> is passed with the same rules as in <method>CallFunction</method>.
/// 
/// <p> Operating with pointers may be unsafe!
Method PointerSetAt(pointer As %String, type, index As %Integer, value)
{
	set setAt = $ZF(-4, 3, ..CNAId, "pointer_set_at")
	set cnaVal = ..ConvertFromCacheToCNA(type, value)
	set cnaIndex = ..ConvertFromCacheToCNA(..#SIZET, index)
	do $zf(-5, ..CNAId, setAt, pointer, $CHAR(type), cnaIndex, cnaVal)
}

/// Converts Cache string to C array (with UTF8 encoding) and returns a <var>pointer</var> to the beginning of this array.
Method ConvertStringToPointer(string As %String) As %String
{
	set s2p = $ZF(-4, 3, ..CNAId, "string_to_pointer")
	set pointer = $ZF(-5, ..CNAId, s2p, $ZCVT(string, "O", "UTF8"))
	do ..AllocatedMemory.Insert(pointer)
	return pointer
}

/// Converts UTF8 C-string to Cache string
Method ConvertPointerToString(pointer As %String) As %String
{
	set p2s = $ZF(-4, 3, ..CNAId, "pointer_to_string")
	set string = $ZF(-5, ..CNAId, p2s, pointer)
	return $ZCVT(string, "I", "UTF8")
}

/// Converts Cache stream to C array and returns a <var>pointer</var> to the beginning of this array.
Method ConvertStreamToPointer(stream As %Stream.Object) As %String
{
	set a2p = $ZF(-4, 3, ..CNAId, "append_to_pointer")
	set len = 0
	set fullLen = 0
	set pointer = ..ConvertFromCacheToCNA(..#SIZET, 0)
	while (len '= -1) {
		set len = 32768
		set string = stream.Read(.len, .st)
		if ($$$ISERR(st)) {
			do ..AllocatedMemory.Insert(pointer)
			throw ##class(%Exception.StatusException).CreateFromStatus(st)
		}
		set pointer = $ZF(-5, ..CNAId, a2p, pointer, ..ConvertFromCacheToCNA(..#SIZET, fullLen), string)			
		set fullLen = fullLen + len
	}
	do ..AllocatedMemory.Insert(pointer)
	return pointer
}

}

