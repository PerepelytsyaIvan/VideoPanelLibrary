sub init()
    m.top.functionName = "sendRequest"
end sub

function sendRequest()
    url = m.top.baseUrl
    request = m.top.request
    if url = invalid or request = invalid then return invalid
    pathURL = request.callFunc("getUrl", {})
    if Instr(0,pathURL, "http") > 0        
        url = pathURL
    else
        url += pathURL
    end if    
    body = request.callFunc("getBody", {})
    headers = request.callFunc("getHeaders", {})     
    CachedUtil = CacheUtil(url, {ttl:request.cacheExpiredInterval})
    CachedResponse = CachedUtil.get()
    if isValid(request.cacheExpiredInterval) and IsValid(CachedResponse)        
        response =  {
            response : ParseJson(CachedResponse)
            error : false
        }
    else
        if request.method = "POST"
            response = postRequest(url, body, headers)
        else
            response = getRequest(url, headers)
        end if 
        if isValid(request.cacheExpiredInterval) and request.cacheExpiredInterval > 0
            CachedUtil.put(FormatJson(response.response))
        end if
    end if
    responseModel = CreateObject("roSGNode", "URLResponse")
    responseModel.callFunc("initWithResponse", response)
    responseModel.context = request.context
    m.top.response = responseModel        
end function

function getRequest(url, headers = invalid) as object
    res = CreateObject("roUrlTransfer")
    port = CreateObject("roMessagePort")
    res.SetPort(port)
    res.setURL(url)
    h = getDefaultHeders()
    if headers <> invalid
        h.Append(headers)
    end if
    res.SetHeaders(h)
    res.EnableEncodings(true)
    res.SetCertificatesFile("common:/certs/ca-bundle.crt")
    res.InitClientCertificates()    
    if res.AsyncGetToString()
        while true
            msg = Wait (0, port)
            if Type (msg) = "roUrlEvent"
                resJson = invalid
                if msg.GetResponseCode() = 200
                    resJson =  {
                        response : ParseJson(msg.GetString())
                        error : false
                    }        
                else if msg.GetResponseCode() = 401
                    scene = m.top.getScene()
                    scene.callFunc("logOut", {})    
                    resJson =  {
                        response : "UNAUTORIZE"
                        error : true
                    }
                    return resJson          
                else
                    serverResponse = invalid
                    if IsString(msg.GetString()) and Len(msg.GetString()) > 0
                        serverResponse = ParseJson(msg.GetString())
                    end if
                    if serverResponse = invalid
                        serverResponse = msg.GetFailureReason()
                    end if
                    resJson =  {
                        response : serverResponse
                        error : true
                    }          
                end if              
         
                ConsolLog().logGetRequest(url, h, msg)
                return resJson
                exit while
            else if Type (msg) = "Invalid"
                res.AsyncCancel()
                exit while
            end if
        end while
    end if
end function

function postRequest(url, body, headers = invalid)
    http = CreateObject("roUrlTransfer")
    http.RetainBodyOnError(true)
    port = CreateObject("roMessagePort")
    http.SetPort(port)
    http.SetCertificatesFile("common:/certs/ca-bundle.crt")
    http.InitClientCertificates()
    http.setURL(url)
    http.EnableEncodings(true)

    h = getDefaultHeders()
    if headers <> invalid
        h.Append(headers)
    end if
    http.SetHeaders(h)

    body = FormatJson(body)

    if http.AsyncPostFromString(body) then
        event = Wait(35000, http.GetPort())
        if Type(event) = "roUrlEvent" then
            resJson = invalid
            resCode = event.GetResponseCode()
            ? "res code: " resCode
            if resCode = 200
                resJson = {
                    response : ParseJson(event.GetString())   
                    error : false
                }
            else if resCode = 401
                scene = m.top.getScene()
                scene.callFunc("logOut", {})    
                resJson =  {
                    response : "UNAUTORIZE"
                    error : true
                }
                return resJson    
            else
                serverResponse = invalid
                if IsString(event.GetString()) and Len(event.GetString()) > 0
                    serverResponse = ParseJson(event.GetString())
                end if
                if serverResponse = invalid
                    serverResponse = event.GetFailureReason()
                end if
                resJson =  {
                    response : serverResponse
                    error : true
                }      
            end if                
            ConsolLog().logPOSTRequest(url, body, h, event)            
            return resJson
        else if event = invalid then
            http.asynccancel()
        else
            ? "AsyncPostFromString unknown event"
        end if
    end if
end function

function getDefaultHeders()
    headers = {}    
    ' headers["accept"] = "application/json"        
    ' headers["content-type"] = "application/json"  
    return headers
end function