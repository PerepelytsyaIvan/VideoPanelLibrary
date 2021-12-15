
function initWithResponse(response)
    m.top.isSuccess = not response.error
    if response.error
        if IsAssociativeArray(response.response)
            m.top.error = response.response
        else
            m.top.error = {
                message: response.response
            }
        end if
    else
        if IsValid(response.response)
            if response.error
                m.top.error = {
                    message: response.response.message
                }
                m.top.isSuccess = false
            else
                if IsAssociativeArray(response.response)
                    m.top.data = response.response
                else
                    m.top.arrayData = response.response
                end if
            end if
        end if
    end if
end function