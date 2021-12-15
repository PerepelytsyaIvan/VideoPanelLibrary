sub init()
    m.top.headerParameters = {}
    m.top.querryParams = {}
    m.top.arrayBody = []
    m.top.context = {}
    m.top.body = {}
end sub

function getUrl(params = invalid) as String    
    return m.top.url 
end function

function getBody(params = invalid)
    if m.top.arrayBody.Count() > 0
        return m.top.arrayBody
    end if
    return m.top.body
end function

function getHeaders(params = invalid)    
    header = {}
    if isValid(m.top.headerParameters)
        header = m.top.headerParameters
    end if
    return header
end function

function getQuerryString()
    string = "?"
    querryParams = getDefaultQuerryParams()
    if isValid(m.top.querryParams)
        querryParams.append(m.top.querryParams)
    end if    
    for each parmsPair in querryParams.Items()
        string += parmsPair.key + "=" + parmsPair.value + "&"
    end for
    if string = "?"
        return ""
    end if
    return string
end function

function getDefaultQuerryParams()
    querry = {}
    return querry
end function
