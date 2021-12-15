function sendRequest(requestContext)
    if not isValid(requestContext) then return invalid
    if not isValid(requestContext.request) then return invalid
    if not isValid(requestContext.calbacks) then return invalid    

    if m.callbacks = invalid
        m.callbacks = {}
    end if

    uniqueId = getUniqueId()

    m.callbacks.addReplace(uniqueId, requestContext.calbacks)

    netwrokTask = CreateObject("roSGNode", "NetworkTask")
    netwrokTask.id = uniqueId
    netwrokTask.baseUrl = "baseURL"
    netwrokTask.request = requestContext.request
    netwrokTask.observeField("response", "onResponseHandler")
    netwrokTask.control = "RUN"    
    
    if m.requestTasks = invalid
		m.requestTasks = {}
	end if    
	m.requestTasks.addReplace(uniqueId, netwrokTask)    
end function

function onResponseHandler(event)    
    requestId = event.getNode()
    responseModel = event.getData()   
    if not isValid(requestId) then return invalid
    calbacks = getCallbacksFor(requestId)
    if not isValid(calbacks) then return invalid 
    if not IsValid(responseModel) then return invalid 
    if responseModel.isSuccess
        calbacks.onSuccess(responseModel)
    else 
        calbacks.onFailure(responseModel)
    end if
    cleanHandlerFor(requestId)
end function

function getUniqueId() as String
    if m.uniqueId = invalid
      m.uniqueId = 0
    end if
    m.uniqueId++
    return m.uniqueId.toStr()
end function

function getCallbacksFor(requestID)
    if IsValid(m.callbacks) and m.callbacks.Count() > 0
        return m.callbacks[requestID]
    end if
end function

function cleanHandlerFor(requestID)
    if IsValid(m.callbacks)
        m.callbacks.Delete(requestID)
    end if
    if IsValid(m.requestTasks)
        m.requestTasks.Delete(requestID)
    end if
end function