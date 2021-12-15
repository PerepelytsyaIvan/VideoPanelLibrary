function getWidthForText(text, font)
    label = CreateObject("roSGNode", "Label")
    label.height = font.size
    label.width = 0
    label.text = text
    return label.boundingrect().width
end function

function GetRegularFontWithSize(size)
    return GetFontWithSize(size, "pkg:/fonts/Roboto-Regular.ttf")
end function

function GetMontserratSemiBoldFontWithSize(size)
    return GetFontWithSize(size, "pkg:/fonts/Montserrat-SemiBold.ttf")
end function

function GetFontWithSize(size, fontFile = "pkg:/fonts/Roboto-Regular.ttf")
    font = CreateObject("roSGNode", "Font")
    font.uri = fontFile
    font.size = size
    return font
end function

function getRuntime(runtime as integer) as string
    runtime = runtime / 1000
    runtimeSecs = runtime MOD 60
    runtimeMins = (runtime \ 60) MOD 60
    runtimeHours = (runtime \ 3600)

    if runtimeSecs < 10
        runtimeSecs = "0" + runtimeSecs.toStr()
    else
        runtimeSecs = runtimeSecs.toStr()
    end if

    if runtimeMins < 10
        runtimeMins = "0" + runtimeMins.toStr()
    else
        runtimeMins = runtimeMins.toStr()
    end if
    if runtimeHours > 0
        if runtimeHours < 10
            runtimeHours = "0" + runtimeHours.toStr()
        else
            runtimeHours = runtimeHours.toStr()
        end if
        totalRuntime = runtimeHours + ":" + runtimeMins + ":" + runtimeSecs
    else
        totalRuntime = "00:" + runtimeMins + ":" + runtimeSecs
    end if
    return totalRuntime
end function

function getSecondsFrom(intervalString) 
    numberValue = 1
    r = CreateObject("roRegex", "\d+","")
    values = r.Match(intervalString)
    if values.Count() > 0 
        value = values[0].ToInt()
        if IsInteger(value)
            numberValue = value
            lastPart =  intervalString.Split(values[0]).Peek()
            if lastPart = "M"
                numberValue = numberValue * 60
            else if lastPart = "H"
                numberValue = numberValue * 60 * 60
            else if lastPart = "D"
                numberValue = numberValue * 60 * 60 * 24
            end if
        end if        
    end if
    return numberValue
end function

function getHeightOfTextWith(width, font, text) 
    height = 0
    label = CreateObject("roSGNode", "Label")
    label.font = font
    label.wrap = true
    label.width = width
    label.height = 0
    label.text = text
    height = label.boundingRect().height
    return height
end function

' ******************************************************
' Logging Helper Functions
' ******************************************************

function ConsolLog() as Object
    console = {
        logPOSTRequest: function(url, body, requestHeaders, urlEvent)
            logPOSTRequest(url, body, requestHeaders, urlEvent)
        end function
        logGetRequest: function(url, requestHeaders, urlEvent)
            logGetRequest(url, requestHeaders, urlEvent)
        end function
        logObject: function(logObject, logerName = invalid)
            logObjectWithName(logerName, logObject)
        end function
    }
    return console
end function

sub logObjectWithName(logerName, logObject)
    log = ""
    if IsString(logerName)
        log += ">>> " + logerName + ": "
    end if
    if IsString(logObject)
        log += chr(10) + chr(10) + logObject   
        ? log    
    else if IsValid(objectToPrintable(logObject))
        #if LOG_REQUEST_ENABLED   
            ? log
            ? objectToPrintable(logObject)
        #endif    
    else
        #if LOG_REQUEST_ENABLED   
        ? log
        ? "Cant print this object!!!"
        #endif    
    end if   
end sub

function objectToTheString(obj)
    stringObj = ""
    if IsAssociativeArray(obj)
        return FormatJson(obj)
    else  if IsArray(obj)
        for each item in obj
            stringObj += chr(10) + objectToTheString(item) + chr(10)
        end for                
    else  if IsSGNode(obj)
        fields = obj.getFields()
        return objectToTheString(fields)
    end if
    return stringObj
end function

function objectToPrintable(obj)
    stringObj = ""
    if IsAssociativeArray(obj) or IsArray(obj)
        return obj
    else  if IsSGNode(obj)
        fields = obj.getFields()
        return fields
    else 
        return invalid
    end if
    return stringObj
end function

' =====================================================

function logRequest(url, body, requestHeaders, method, roURLEvent)
    resJson = invalid
    responseString = roURLEvent.GetString()
    if isValid(responseString) and Len(responseString) > 0
        resJson = ParseJson(responseString)
    end if
    h = roURLEvent.GetResponseHeaders()
    #if LOG_REQUEST_ENABLED                                           
        ? ""
        ? "======================("method")========================== "
        ? "URL: " url
        ? ""
        if method = "POST"
            ? "BODY: " body
            ? ""
        end if
        ? "HEADERS: " requestHeaders
        ? "=================================================== "
        ? ""
        ? "RESPONSE CODE: " roURLEvent.GetResponseCode().toStr()
        ? "=================================================== "        
        ? ""
        ? "RESPONSE: " resJson
        ? "=================================================== "
        ? ""
    #end if           
end function

function logGetRequest(url, requestHeaders, roURLEvent)
    logRequest(url, invalid, requestHeaders,  "GET", roURLEvent)       
end function

function logPOSTRequest(url, body, requestHeaders, roURLEvent)
    logRequest(url, body, requestHeaders, "POST", roURLEvent)       
end function

' ******************************************************
' Registry Helper Functions
' ******************************************************

function RegRead(key, section = invalid)
    if section = invalid then section = "Portico"
    sec = CreateObject("roRegistrySection", section)
    if sec.Exists(key)
        return parseJson(sec.Read(key))
    end if
    return invalid
end function

function RegReadMulti(arr, section = invalid)
    if section = invalid then section = "Portico"
    sec = CreateObject("roRegistrySection", section)
    return sec.ReadMulti(arr)
end function

function RegWrite(key, val, section = invalid)
    if section = invalid then section = "Portico"
    sec = CreateObject("roRegistrySection", section)
    sec.Write(key, val)
end function

function RegWriteMulti(obj, section = "Portico")
    sec = CreateObject("roRegistrySection", section)
    for each key in obj
        obj[key] = FormatJson(obj[key], 1)
    end for
    sec.WriteMulti(obj)
end function

function RegDelete(key = invalid, section = "Portico")
    if key = invalid
        sec = CreateObject("roRegistry")
        sec.Delete(section)
    else
        sec = CreateObject("roRegistrySection", section)
        sec.Delete(key)
    end if
end function

sub saveInGlobal(key, data)
    if m.global[key] <> invalid
        m.global[key] = data
    else
        obj = {}
        obj[key] = data
        m.global.addFields(obj)
    end if
end sub

' ******************************************************
' Max function (largest from values)
' ******************************************************

function max(a, b)
    if a < b then
        return b
    else
        return a
    end if
end function

' ******************************************************
' Min function (minimum from values)
' ******************************************************

function min(a, b)
    if a > b then
        return b
    else
        return a
    end if
end function

' ******************************************************
' Array Helper Functions
' ******************************************************

function filterArr(arr, key, value)
    if arr <> invalid
        filterredArr = []
        arrCount = arr.Count() - 1
        for i = 0 to arrCount
            ? arr[i][key]
            ? value
            if arr[i][key] = value
                filterredArr.Push(arr[i])
            end if
        end for
        if (filterredArr.Count() > 0)
            return filterredArr
        else
            return invalid
        end if
    else return invalid
    end if
end function

function firstWhere(arr, key, value)
    if arr <> invalid
        filterredArr = []
        arrCount = arr.Count() - 1
        for i = 0 to arrCount
            if arr[i][key] = value
                filterredArr.Push(arr[i])
            end if
        end for
        if (filterredArr.Count() > 0)
            return filterredArr[0]
        else
            return invalid
        end if
    else return invalid
    end if
end function

function sortArray(list, property, ascending=true) as dynamic
    for i = 1 to list.count() - 1
        value = list[i]
        j = i - 1

        while j >= 0
            if (ascending and list[j][property] < value[property]) or (not ascending and list[j][property] > value[property]) then 
                exit while
            end if

            list[j + 1] = list[j]
            j = j - 1
        end while

        list[j + 1] = value
    next
    return list
end function

function findArrIndex(arr, key, value, key2 = invalid)
    if arr <> invalid
        if key2 <> invalid
            for i = 0 to arr.Count() - 1
                if arr[i][key][key2] = value
                    return i
                end if
            end for
        else
            for i = 0 to arr.Count() - 1
                if arr[i][key] = value
                    return i
                end if
            end for
        end if
    end if
    return invalid
end function

function contains(arr as object, value as string) as boolean
    for each entry in arr
        if entry = value
            return true
        end if
    end for
    return false
end function

function getIndex(arr, value)
    i = 0
    for each item in arr
        if item = value
            return i
        end if
        i++
    end for
    return invalid
end function

' ******************************************************
' ToString
' ******************************************************

function ToString(variable as dynamic) as string
    if Type(variable) = "roInt" or Type(variable) = "roInteger" or Type(variable) = "roFloat" or Type(variable) = "Float" then
        return Str(variable).Trim()
    else if Type(variable) = "roBoolean" or Type(variable) = "Boolean" then
        if variable = true then
            return "True"
        end if
        return "False"
    else if Type(variable) = "roString" or Type(variable) = "String" then
        return variable
    else
        return Type(variable)
    end if
end function

' ******************************************************
' Type check
' ******************************************************

function IsXmlElement(value as dynamic) as boolean
    return IsValid(value) and GetInterface(value, "ifXMLElement") <> invalid
end function

function IsFunction(value as dynamic) as boolean
    return IsValid(value) and GetInterface(value, "ifFunction") <> invalid
end function

function IsBoolean(value as dynamic) as boolean
    return IsValid(value) and GetInterface(value, "ifBoolean") <> invalid
end function

function IsInteger(value as dynamic) as boolean
    return IsValid(value) and GetInterface(value, "ifInt") <> invalid and (Type(value) = "roInt" or Type(value) = "roInteger" or Type(value) = "Integer")
end function

function IsFloat(value as dynamic) as boolean
    return IsValid(value) and (GetInterface(value, "ifFloat") <> invalid or (Type(value) = "roFloat" or Type(value) = "Float"))
end function

function IsDouble(value as dynamic) as boolean
    return IsValid(value) and (GetInterface(value, "ifDouble") <> invalid or (Type(value) = "roDouble" or Type(value) = "roIntrinsicDouble" or Type(value) = "Double"))
end function

function IsList(value as dynamic) as boolean
    return IsValid(value) and GetInterface(value, "ifList") <> invalid
end function

function IsArray(value as dynamic) as boolean
    return IsValid(value) and Type(value) = "roArray"
end function

function IsAssociativeArray(value as dynamic) as boolean
    return IsValid(value) and Type(value) = "roAssociativeArray" 
end function

function IsString(value as dynamic) as boolean
    return IsValid(value) and GetInterface(value, "ifString") <> invalid
end function

function IsDateTime(value as dynamic) as boolean
    return IsValid(value) and (GetInterface(value, "ifDateTime") <> invalid or Type(value) = "roDateTime")
end function

function IsSGNode(value as dynamic) as boolean
    return IsValid(value) and (GetInterface(value, "ifSGNodeField") <> invalid or Type(value) = "roSGNode")
end function

function IsValid(value as dynamic) as boolean
    return Type(value) <> "<uninitialized>" and value <> invalid
end function

function IsInvalid(value as dynamic) as boolean
    return Type(value) = "<uninitialized>" or value = invalid
end function


function defaultValueIfInvalid(default as object, unknown)
    if unknown = invalid then return default
    return unknown
end function

function getDeviceID()
    di = CreateObject("roDeviceInfo")
    uuid = ""
    if di.IsRIDADisabled()
        uuid = GenerateUUID()
        ConsolLog().logObject(uuid)
    else
        uuid = di.GetRIDA()
        ConsolLog().logObject(uuid)
    end if 
    return uuid
end function 

function getDeviceModel()
    di = CreateObject("roDeviceInfo")    
    return di.getModel()
end function 

function getDeviceName()
    di = CreateObject("roDeviceInfo")    
    return di.GetModelDisplayName()
end function 

function getUserToken()
    customer = RegRead("customer")
    if isValid(customer)
        'return customer[EnumsUtil().DTOProperties.CUSTOM_USER_TOKEN]        
    end if
end function

function getRefreshToken()
    customer = RegRead("customer")
    if isValid(customer)
        'return customer[EnumsUtil().DTOProperties.CUSTOM_REFRESH_TOKEN]        
    end if
end function

function getProductStatus()
    if isValid(m.global.products)

    end if
    return invalid
end function

function getProductCode()
    if isValid(m.global.products)
        
    end if
    return invalid
end function

function getLocale()
    di = CreateObject("roDeviceInfo")    
    return di.GetCurrentLocale()
end function

Function GenerateUUID() As String
    stored = RegRead("UUID")
    if stored <> invalid then return stored
    new = GetRandomHexString(8) + "-" + GetRandomHexString(4) + "-" + GetRandomHexString(4) + "-" + GetRandomHexString(4) + "-" + GetRandomHexString(12)
    valueObject = {
      "UUID" : new
    }
    RegWriteMulti(valueObject)
    return new
End Function

Function GetRandomHexString(length As Integer) As String
    hexChars = "0123456789ABCDEF"
    hexString = ""
    for i = 1 to length
        hexString = hexString + hexChars.Mid(Rnd(16) - 1, 1)
    next
    return hexString
End Function

Function toBase64String(object) As String
    json = FormatJson(object)
    byteArray = CreateObject("roByteArray")
    byteArray.FromAsciiString(json)
    return byteArray.ToBase64String()
End Function

Function fromBase64String(base64String as String) As Object
    byteArray = CreateObject("roByteArray")
    byteArray.FromBase64String(base64String)
    asciString = byteArray.ToAsciiString()
    json = ParseJson(asciString)    
    return json
End Function

Function dateFromISOString(dateString)
    dateTime = CreateObject("roDateTime")
    dateTime.FromISO8601String(dateString)
    return dateTime
End Function

Function getSizeMaskGroupWith(size) as object
    deviceInfo = CreateObject("roDeviceInfo")
    resolution = deviceInfo.GetUIResolution()
    if resolution.name = "HD"
        size[0] = size[0] * 2/3
        size[1] = size[1] * 2/3
        return size
    end if
    return size
End Function

Function localize(key)
    if IsValid(m.global.Custom_Application_LocalizationUrl)
        localizedString = firstWhere(m.global.Custom_Application_LocalizationUrl.Properties, "Name", key)
        if IsValid(localizedString)
            return localizedString.Value.Replace("%@", "")
        else 
            return key
        end if
    else
        return key
    end if
End Function

function isAddWatchlist(clean_title) as object
    for each item in m.global.watchlist
        if item.clean_title = clean_title 
            return true
        end if
    end for
    return false
end function

sub sortedVideoTrending(shows) as object
    data = shows.data
    if IsValid(shows.data)
        if shows.data.response.rows.Count() > 0
            data.response.Delete("rows")
            sortedArray = sortArray(shows.data.response.rows, "views_count", false)
            data.response.AddReplace("rows", sortedArray)
            shows.setField("data", data)
            return shows
        end if
    end if
    return []
end sub
