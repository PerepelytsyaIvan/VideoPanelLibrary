sub init()
    m.top.setFocus(true)
    m.panel = m.top.findNode("panel")
    m.questionLabel = m.top.findNode("questionLabel")
    m.panelButtons = m.top.findNode("panelButtons")
    m.focusKey = 0
    m.buttons = []
    setupPanelButton()
end sub

sub configurePanel()
    m.top.videoPlayer.observeField("state", "onChangeStateVideoPlayer")
end sub

sub onChangeStateVideoPlayer(event)
    state = event.getData()
    if state = "buffering"

    else if state = "playing"
        if  m.top.videoPlayer.position < 10
            m.timer = CreateObject("roSGNode", "Timer")
            m.timer.observeField("fire", "onChageDuration")
            m.timer.repeat = true
            m.timer.duration = 1
            m.timer.control = "start"
        end if
    end if
end sub 

sub onChageDuration()
    if  m.top.videoPlayer.position >= 10
        m.timer.control = "stop"
        m.panel.visible = true
        m.top.setFocus(true)
    end if
end sub

sub setupPanelButton()
    m.buttonsTitle = ["Yes", "No"]
    for each item in m.buttonsTitle
        button = m.panelButtons.createChild("Rectangle")
        button.width = 140
        button.height = 50
        button.color = "#FFFFFF"
        title = button.createChild("Label")
        title.width = 140
        title.height = 50
        title.font.size = 20
        title.color = "#000000"
        title.text = item            
        title.vertAlign = "center"
        title.horizAlign = "center"
        m.buttons.push(button)  
    end for
    updateFocusButton(0)
end sub

sub unfocusAllButton()
    for each item in m.buttons
        focusButton(item, false)
    end for
end sub

sub updateFocusButton(key)
    unfocusAllButton()
    if key < m.buttons.count()
        m.indexButton = key
        focusButton(m.buttons[key], true)
    end if
end sub


sub focusButton(button, focused)
    if button = invalid then return
    if focused
        button.opacity = 1.0
    else
        button.opacity = 0.4
    end if
end sub

sub layoutSubviews()
    m.panel.translation = [850, 580]
    m.questionLabel.width = m.top.widthPanel
    m.questionLabel.height = (m.top.heightPanel - 70)
    m.panelButtons.translation = [200,  m.top.heightPanel - 65]
end sub

function onKeyEvent(key as string, press as boolean) as boolean
    ? ">>> VideoPanel: onKeyEvent("key", "press")"
    result = false
    if not press then return result
    if key = "right"
        updateFocusButton(min(m.focusKey + 1, m.buttons.count() - 1))
        result = true
    else if key = "left"
        updateFocusButton(max(m.focusKey - 1, 0))
        result = true
    else if key = "OK"
        if m.indexButton = 0
            m.questionLabel.text = "Please wait ..."
            request = CreateObject("roSGNode", "URLRequest")
            request.url = "https://api3-dev.inthegame.io/userApi/shop/getProductByName"
            request.querryParams = {"data":{"productName":"PettersonApps","userToken":"00c242ed7505a8b004461a1b6995d000","broadcasterId":"6162dae264ced968fa6b74ef"}}
            request.method = "POST"
            networkManager = CreateObject("roSGNode", "NetworkTask")
            networkManager.request = request
            networkManager.observeField("response", "showEventsData")
            networkManager.control = "RUN"
        else
            m.panel.visible = false
            m.top.videoPlayer.setFocus(true)
            result = true
        end if
    end if
    return result
end function

sub showEventsData(event)
    responce = event.getData()
    m.questionLabel.text = responce.data.status
    ? "Responce" responce
end sub

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