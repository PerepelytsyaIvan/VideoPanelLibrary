
sub init()

end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ? ">>> PanelList: onKeyEvent("key", "press")"
    result = true
    if not press then return result
    if key = "OK"
        buttonTitle = m.buttonsTitle[m.top.focusKey]
        if buttonTitle = "Yes"
            ' Show question
        else
            m.panel.visible = false
            m.top.parent.setFocus(true)
        end if
    else if key = "right"
        m.top.focusKey = max(m.top.focusKey - 1, 0)
    else if key = "left"
        m.top.focusKey = min(m.top.focusKey + 1, m.listConfig.count() - 1)
    end if
    return result
end function



function max(a, b)
    if a < b then
        return b
    else
        return a
    end if
end function

function min(a, b)
    if a > b then
        return b
    else
        return a
    end if
end function
