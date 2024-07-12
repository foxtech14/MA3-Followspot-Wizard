-- ****************************************************************
-- local plugin variables
-- ****************************************************************

local pluginName = select(1, ...);
local pluginComponent = select(2, ...);
local signals = select(3, ...);
local handles = select(4, ...);

-- global function cache
local C = Cmd;
local E = Echo;
local MB = MessageBox;
local PI = PopupInput;
local GV = GlobalVars();

-- function lookup table
local functions = {}

-- Get the colors.
local colorTransparent = Root().ColorTheme.ColorGroups.Global.Transparent
local colorBackground = Root().ColorTheme.ColorGroups.Button.Background
local colorBackgroundPlease = Root().ColorTheme.ColorGroups.Button.BackgroundPlease

local colorRed = Root().ColorTheme.ColorGroups.SystemMonitor.Red
local colorGreen = Root().ColorTheme.ColorGroups.SystemMonitor.Green
local colorBlue = Root().ColorTheme.ColorGroups.SystemMonitor.Blue
local colorCyan = Root().ColorTheme.ColorGroups.SystemMonitor.Cyan
local colorMagenta = Root().ColorTheme.ColorGroups.SystemMonitor.Magenta
local colorYellow = Root().ColorTheme.ColorGroups.SystemMonitor.Yellow

local colorDarkBlue = Root().ColorTheme.ColorGroups.Checkbox.SelectedBackground

-- ****************************************************************
-- helper functions
-- ****************************************************************

local function isempty(s)
    return s == nil or s == ''
end

local function spiltString(inputstr, sep, i)
    local t = {}
    if sep == nil then sep = "%s" end
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t[i]
end

local function baseWindow()
    -- Get the index of the display on which to create the dialog.
    local displayIndex = Obj.Index(GetFocusDisplay())
    if displayIndex > 5 then
        displayIndex = 1
    end

    -- Get the overlay.
    local display = GetDisplayByIndex(displayIndex)
    local screenOverlay = display.ScreenOverlay

    -- Delete any UI elements currently displayed on the overlay.
    screenOverlay:ClearUIChildren()

    -- Create Window Base
    local window = screenOverlay:Append("BaseInput")
    return window, display
end

local function notInstalledWarning()
    MB({
        title = "Warning",
        message = "Please install the Plugin before trying to configure anthing.",
        commands = {{value = 1, name = "Ok"}},
        icon = "logo_small",
    })
end

-- ****************************************************************
-- worker functions
-- ****************************************************************

local function getPresets(type, first, last)
    local presets = {}
    presets[0] = "..."
    for i = first, last do
        local preset = DataPool().PresetsPool[type][i]
        local label = string.format("%s | %s", i, preset)
        presets[i] = label
    end
    return presets
end

local function storeOff(spot, cue)
    local fixture = GetVar(GV, "bbSpot"..spot)
    local seq = GetVar(GV, "bbSpot"..spot.."Seq")

    C("Blind On")
    C("ClearAll")
    C(string.format("Fixture %s At %s", fixture, 0))
    C(string.format("Store Sequence %s Cue  %s /nc", seq, cue))
    C(string.format("Label Sequence %s Cue  %s 'OFF'", seq, cue))
    C("ClearAll")
    C("Blind Off")
end

-- ****************************************************************
-- secondary functions
-- ****************************************************************

local function info()
    E("info here")
end

local function config()
    E("config")
end

local function install()
    E("installing")

    SetVar(GV, "bbSpot1", 0)
    SetVar(GV, "bbSpot2", 0)
    SetVar(GV, "bbSpot3", 0)
    SetVar(GV, "bbSpot4", 0)
    SetVar(GV, "bbSpot5", 0)
    SetVar(GV, "bbSpot6", 0)
    SetVar(GV, "bbSpot1Seq", 0)
    SetVar(GV, "bbSpot2Seq", 0)
    SetVar(GV, "bbSpot3Seq", 0)
    SetVar(GV, "bbSpot4Seq", 0)
    SetVar(GV, "bbSpot5Seq", 0)
    SetVar(GV, "bbSpot6Seq", 0)
    SetVar(GV, "bbCharacterStart", 2.1)
    SetVar(GV, "bbCharacterEnd", 2.2)
    SetVar(GV, "bbColourStart", 4.1)
    SetVar(GV, "bbColourEnd", 4.2)
    SetVar(GV, "bbSizeStart", 23.1)
    SetVar(GV, "bbSizeEnd", 23.2)
    SetVar(GV, "bbCharacterPool", 2)
    SetVar(GV, "bbColourPool", 4)
    SetVar(GV, "bbSizePool", 23)

    SetVar(GV, "bbSpotsInstalled", "true")
end

local function uninstall()
    E("uninstalling")

    DelVar(GV, "bbSpot1")
    DelVar(GV, "bbSpot2")
    DelVar(GV, "bbSpot3")
    DelVar(GV, "bbSpot4")
    DelVar(GV, "bbSpot5")
    DelVar(GV, "bbSpot6")
    DelVar(GV, "bbSpot1Seq")
    DelVar(GV, "bbSpot2Seq")
    DelVar(GV, "bbSpot3Seq")
    DelVar(GV, "bbSpot4Seq")
    DelVar(GV, "bbSpot5Seq")
    DelVar(GV, "bbSpot6Seq")
    DelVar(GV, "bbCharacterStart")
    DelVar(GV, "bbCharacterEnd")
    DelVar(GV, "bbColourStart")
    DelVar(GV, "bbColourEnd")
    DelVar(GV, "bbSizeStart")
    DelVar(GV, "bbSizeEnd")
    DelVar(GV, "bbCharacterPool")
    DelVar(GV, "bbColourPool")
    DelVar(GV, "bbSizePool")

    DelVar(GV, "bbSpotsInstalled")
end

-- ****************************************************************
-- main functions
-- ****************************************************************

functions['install'] = function()

    local window, display = baseWindow()

    local titleBar = window:Append("TitleBar")
    local titleButton = titleBar:Append("TitleButton")
    local closeButton = titleBar:Append("CloseButton")

    local dialogFrame = window:Append("DialogFrame")

    local infoButton = dialogFrame:Append("Button")
    local configButton = dialogFrame:Append("Button")
    local installButton = dialogFrame:Append("Button")
    local uninstallButton = dialogFrame:Append("Button")

    local function displayConfig()
        -- Create the dialog base.
        local dialogWidth = 400
        window.Name = "Followspot Wizard"
        window.H = "0"
        window.W = dialogWidth
        window.MaxSize = string.format("%s,%s", display.W * 0.8, display.H)
        window.MinSize = string.format("%s,0", dialogWidth - 100)
        window.Columns = 1
        window.Rows = 2
        window[1][1].SizePolicy = "Fixed"
        window[1][1].Size = "60"
        window[1][2].SizePolicy = "Stretch"
        window.AutoClose = "No"
        window.CloseOnEscape = "Yes"

        -- Create the title bar.
        titleBar.Columns = 2;
        titleBar.Rows = 1;
        titleBar.Anchors = "0,0";
        titleBar[2][2].SizePolicy = "Fixed";
        titleBar[2][2].Size = "50";
        titleBar.Texture = "corner1";

        titleButton.Text = "BBLX - Followspot Wizard";
        titleButton.Texture = "corner1";
        titleButton.Anchors = "0,0";
        titleButton.Icon = "object_fixture2";

        closeButton.Anchors = "1,0";
        closeButton.Texture = "corner2";

        -- Create the dialog's main frame.
        dialogFrame.H = "100%";
        dialogFrame.W = "100%";
        dialogFrame.Columns = 1;
        dialogFrame.Rows = 4;
        dialogFrame.Anchors = "0,1"
        dialogFrame[1][1].SizePolicy = "Fixed";
        dialogFrame[1][1].Size = "125";
        dialogFrame[1][2].SizePolicy = "Fixed";
        dialogFrame[1][2].Size = "100";
        dialogFrame[1][3].SizePolicy = "Fixed";
        dialogFrame[1][3].Size = "100";
        dialogFrame[1][4].SizePolicy = "Fixed";
        dialogFrame[1][4].Size = "100";

        -- Create a Button.
        -- This is row 1 of the dialogFrame.
        infoButton.Anchors = "0,0"
        infoButton.Margin = {
            left = 25,
            right = 25,
            top = 25,
            bottom = 25
        }
        infoButton.Font = "Regular24"
        infoButton.Name= "info"
        infoButton.Text = "INFO"
        infoButton.Texture = "corner15"
        infoButton.BackColor = colorDarkBlue
        infoButton.PluginComponent = handles

        -- Create a Button.
        -- This is row 2 of the dialogFrame.
        configButton.Anchors = "0,1"
        configButton.Margin = {
            left = 25,
            right = 25,
            top = 0,
            bottom = 25
        }
        configButton.Font = "Regular24"
        configButton.Name= "config"
        configButton.Text = "CONFIG"
        configButton.Texture = "corner15"
        configButton.BackColor = colorDarkBlue
        configButton.PluginComponent = handles

        -- Create a Button.
        -- This is row 3 of the dialogFrame.
        installButton.Anchors = "0,2"
        installButton.Margin = {
            left = 25,
            right = 25,
            top = 0,
            bottom = 25
        }
        installButton.Font = "Regular24"
        installButton.Name= "install"
        installButton.Text = "INSTALL"
        installButton.Texture = "corner15"
        installButton.BackColor = colorDarkBlue
        installButton.PluginComponent = handles

        -- Create a Button.
        -- This is row 4 of the dialogFrame.
        uninstallButton.Anchors = "0,3"
        uninstallButton.Margin = {
            left = 25,
            right = 25,
            top = 0,
            bottom = 25
        }
        uninstallButton.Font = "Regular24"
        uninstallButton.Name= "uninstall"
        uninstallButton.Text = "UN-INSTALL"
        uninstallButton.Texture = "corner15"
        uninstallButton.BackColor = colorDarkBlue
        uninstallButton.PluginComponent = handles

    end

    displayConfig()

    infoButton.Clicked = "infoClicked"
    configButton.Clicked = "configClicked"
    installButton.Clicked = "installClicked"
    uninstallButton.Clicked = "uninstallClicked"

    signals.infoClicked = function(caller)
        info()
    end

    signals.configClicked = function(caller)
        functions['config']()
    end

    signals.installClicked = function(caller)
        E("Install Started...")
        install()
        E("Install Complete...")
    end

    signals.uninstallClicked = function(caller)
        E("Uninstall Started...")
        uninstall()
        E("Uninstall Complete...")
    end

end

functions['config'] = function()

    -- check to see if the plugin has been installed or not
    if (isempty(GetVar(GV, "bbSpotsInstalled"))) then
        notInstalledWarning()
        return
    end
    
    local window, display = baseWindow()

    local titleBar = window:Append("TitleBar")
    local titleButton = titleBar:Append("TitleButton")
    local closeButton = titleBar:Append("CloseButton")

    local dialogFrame = window:Append("DialogFrame")

    local layoutGrid = dialogFrame:Append("UILayoutGrid")
    local charStartTitle = layoutGrid:Append("UIObject")
    local charStartText = layoutGrid:Append("LineEdit")
    local charEndTitle = layoutGrid:Append("UIObject")
    local charEndText = layoutGrid:Append("LineEdit")

    local colourStartTitle = layoutGrid:Append("UIObject")
    local colourStartText = layoutGrid:Append("LineEdit")
    local colourEndTitle = layoutGrid:Append("UIObject")
    local colourEndText = layoutGrid:Append("LineEdit")

    local sizeStartTitle = layoutGrid:Append("UIObject")
    local sizeStartText = layoutGrid:Append("LineEdit")
    local sizeEndTitle = layoutGrid:Append("UIObject")
    local sizeEndText = layoutGrid:Append("LineEdit")

    local buttonGrid = dialogFrame:Append("UILayoutGrid")
    local applyButton = buttonGrid:Append("Button")
    local cancelButton = buttonGrid:Append("Button")

    local function displayConfig()
        -- Create the dialog base.
        local dialogWidth = 650
        window.Name = "Followspot Wizard Config"
        window.H = "0"
        window.W = dialogWidth
        window.MaxSize = string.format("%s,%s", display.W * 0.8, display.H)
        window.MinSize = string.format("%s,0", dialogWidth - 100)
        window.Columns = 1
        window.Rows = 2
        window[1][1].SizePolicy = "Fixed"
        window[1][1].Size = "60"
        window[1][2].SizePolicy = "Stretch"
        window.AutoClose = "No"
        window.CloseOnEscape = "Yes"

        -- Create the title bar.
        titleBar.Columns = 2;
        titleBar.Rows = 1;
        titleBar.Anchors = "0,0";
        titleBar[2][2].SizePolicy = "Fixed";
        titleBar[2][2].Size = "50";
        titleBar.Texture = "corner1";

        titleButton.Text = "BBLX - Followspot Wizard";
        titleButton.Texture = "corner1";
        titleButton.Anchors = "0,0";
        titleButton.Icon = "object_fixture2";

        closeButton.Anchors = "1,0";
        closeButton.Texture = "corner2";

        -- Create the dialog's main frame.
        dialogFrame.H = "100%";
        dialogFrame.W = "100%";
        dialogFrame.Columns = 1;
        dialogFrame.Rows = 2;
        dialogFrame.Anchors = "0,1"
        dialogFrame[1][1].SizePolicy = "Fixed";
        dialogFrame[1][1].Size = "360";
        dialogFrame[1][2].SizePolicy = "Fixed";
        dialogFrame[1][2].Size = "120";

        -- Create the main layout grid.
        -- This is row 1 of the dialogFrame.
        layoutGrid.Columns = 2
        layoutGrid.Rows = 6
        layoutGrid.Anchors = "0,0"
        layoutGrid.Margin = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0
        }

        -- Create a title.
        -- This is row 1 col 1 of the grid.
        charStartTitle.Text = "Character Start"
        charStartTitle.ContentDriven = "Yes"
        charStartTitle.ContentWidth = "No"
        charStartTitle.TextAutoAdjust = "No"
        charStartTitle.Anchors = "0,0"
        charStartTitle.Padding = {
            left = 30,
            right = 30,
            top = 15,
            bottom = 15
        }
        charStartTitle.Font = "Medium20"
        charStartTitle.HasHover = "No"
        charStartTitle.BackColor = colorTransparent

        -- Create a Number Input.
        -- This is row 2 col 1 of the grid.
        charStartText.TextAutoAdjust = "Yes"
        charStartText.Anchors = "0,1"
        charStartText.Margin = {
            left = 30,
            right = 30,
            top = 0,
            bottom = 0
        }
        charStartText.Padding = "5,5"
        charStartText.Font = "Regular20"
        charStartText.Filter = "0123456789."
        charStartText.VkPluginName = "TextInputNumOnly"
        charStartText.MaxTextLength = 8
        charStartText.HideFocusFrame = "Yes"
        charStartText.PluginComponent = handles

        -- Create a title.
        -- This is row 1 col 2 of the grid.
        charEndTitle.Text = "Character End"
        charEndTitle.ContentDriven = "Yes"
        charEndTitle.ContentWidth = "No"
        charEndTitle.TextAutoAdjust = "No"
        charEndTitle.Anchors = "1,0"
        charEndTitle.Padding = {
            left = 30,
            right = 30,
            top = 15,
            bottom = 15
        }
        charEndTitle.Font = "Medium20"
        charEndTitle.HasHover = "No"
        charEndTitle.BackColor = colorTransparent

        -- Create a Number Input.
        -- This is row 2 col 2 of the grid.
        charEndText.TextAutoAdjust = "Yes"
        charEndText.Anchors = "1,1"
        charEndText.Margin = {
            left = 30,
            right = 30,
            top = 0,
            bottom = 0
        }
        charEndText.Padding = "5,5"
        charEndText.Font = "Regular20"
        charEndText.Filter = "0123456789."
        charEndText.VkPluginName = "TextInputNumOnly"
        charEndText.MaxTextLength = 8
        charEndText.HideFocusFrame = "Yes"
        charEndText.PluginComponent = handles

        -- Create a title.
        -- This is row 3 col 1 of the grid.
        colourStartTitle.Text = "Colour Start"
        colourStartTitle.ContentDriven = "Yes"
        colourStartTitle.ContentWidth = "No"
        colourStartTitle.TextAutoAdjust = "No"
        colourStartTitle.Anchors = "0,2"
        colourStartTitle.Padding = {
            left = 30,
            right = 30,
            top = 15,
            bottom = 15
        }
        colourStartTitle.Font = "Medium20"
        colourStartTitle.HasHover = "No"
        colourStartTitle.BackColor = colorTransparent

        -- Create a Number Input.
        -- This is row 4 col 1 of the grid.
        colourStartText.TextAutoAdjust = "Yes"
        colourStartText.Anchors = "0,3"
        colourStartText.Margin = {
            left = 30,
            right = 30,
            top = 0,
            bottom = 0
        }
        colourStartText.Padding = "5,5"
        colourStartText.Font = "Regular20"
        colourStartText.Filter = "0123456789."
        colourStartText.VkPluginName = "TextInputNumOnly"
        colourStartText.MaxTextLength = 8
        colourStartText.HideFocusFrame = "Yes"
        colourStartText.PluginComponent = handles

        -- Create a title.
        -- This is row 3 col 2 of the grid.
        colourEndTitle.Text = "Colour End"
        colourEndTitle.ContentDriven = "Yes"
        colourEndTitle.ContentWidth = "No"
        colourEndTitle.TextAutoAdjust = "No"
        colourEndTitle.Anchors = "1,2"
        colourEndTitle.Padding = {
            left = 30,
            right = 30,
            top = 15,
            bottom = 15
        }
        colourEndTitle.Font = "Medium20"
        colourEndTitle.HasHover = "No"
        colourEndTitle.BackColor = colorTransparent

        -- Create a Number Input.
        -- This is row 4 col 2 of the grid.
        colourEndText.TextAutoAdjust = "Yes"
        colourEndText.Anchors = "1,3"
        colourEndText.Margin = {
            left = 30,
            right = 30,
            top = 0,
            bottom = 0
        }
        colourEndText.Padding = "5,5"
        colourEndText.Font = "Regular20"
        colourEndText.Filter = "0123456789."
        colourEndText.VkPluginName = "TextInputNumOnly"
        colourEndText.MaxTextLength = 8
        colourEndText.HideFocusFrame = "Yes"
        colourEndText.PluginComponent = handles

        -- Create a title.
        -- This is row 5 col 1 of the grid.
        sizeStartTitle.Text = "Size Start"
        sizeStartTitle.ContentDriven = "Yes"
        sizeStartTitle.ContentWidth = "No"
        sizeStartTitle.TextAutoAdjust = "No"
        sizeStartTitle.Anchors = "0,4"
        sizeStartTitle.Padding = {
            left = 30,
            right = 30,
            top = 15,
            bottom = 15
        }
        sizeStartTitle.Font = "Medium20"
        sizeStartTitle.HasHover = "No"
        sizeStartTitle.BackColor = colorTransparent

        -- Create a Number Input.
        -- This is row 6 col 1 of the grid.
        sizeStartText.TextAutoAdjust = "Yes"
        sizeStartText.Anchors = "0,5"
        sizeStartText.Margin = {
            left = 30,
            right = 30,
            top = 0,
            bottom = 0
        }
        sizeStartText.Padding = "5,5"
        sizeStartText.Font = "Regular20"
        sizeStartText.Filter = "0123456789."
        sizeStartText.VkPluginName = "TextInputNumOnly"
        sizeStartText.MaxTextLength = 8
        sizeStartText.HideFocusFrame = "Yes"
        sizeStartText.PluginComponent = handles

        -- Create a title.
        -- This is row 5 col 2 of the grid.
        sizeEndTitle.Text = "Size End"
        sizeEndTitle.ContentDriven = "Yes"
        sizeEndTitle.ContentWidth = "No"
        sizeEndTitle.TextAutoAdjust = "No"
        sizeEndTitle.Anchors = "1,4"
        sizeEndTitle.Padding = {
            left = 30,
            right = 30,
            top = 15,
            bottom = 15
        }
        sizeEndTitle.Font = "Medium20"
        sizeEndTitle.HasHover = "No"
        sizeEndTitle.BackColor = colorTransparent

        -- Create a Number Input.
        -- This is row 6 col 2 of the grid.
        sizeEndText.TextAutoAdjust = "Yes"
        sizeEndText.Anchors = "1,5"
        sizeEndText.Margin = {
            left = 30,
            right = 30,
            top = 0,
            bottom = 0
        }
        sizeEndText.Padding = "5,5"
        sizeEndText.Font = "Regular20"
        sizeEndText.Filter = "0123456789."
        sizeEndText.VkPluginName = "TextInputNumOnly"
        sizeEndText.MaxTextLength = 8
        sizeEndText.HideFocusFrame = "Yes"
        sizeEndText.PluginComponent = handles

        -- Create the button grid.
        -- This is row 2 of the dialogFrame.
        buttonGrid.Columns = 2
        buttonGrid.Rows = 1
        buttonGrid.Anchors = "0,1"
        buttonGrid.Margin = {
            left = 0,
            right = 0,
            top = 40,
            bottom = 0
        }

        applyButton.Anchors = "0,0"
        applyButton.Textshadow = 1;
        applyButton.HasHover = "Yes";
        applyButton.Text = "Apply";
        applyButton.Font = "Medium20";
        applyButton.TextalignmentH = "Centre";
        applyButton.PluginComponent = handles

        cancelButton.Anchors = "1,0"
        cancelButton.Textshadow = 1;
        cancelButton.HasHover = "Yes";
        cancelButton.Text = "Cancel";
        cancelButton.Font = "Medium20";
        cancelButton.TextalignmentH = "Centre";
        cancelButton.PluginComponent = handles
        cancelButton.Visible = "Yes"

    end

    displayConfig()

    charStartText.Content = tonumber(GetVar(GV, "bbCharactersStart"))
    charEndText.Content = tonumber(GetVar(GV, "bbCharactersEnd"))
    colourStartText.Content = tonumber(GetVar(GV, "bbColoursStart"))
    colourEndText.Content = tonumber(GetVar(GV, "bbColoursEnd"))
    sizeStartText.Content = tonumber(GetVar(GV, "bbSizesStart"))
    sizeEndText.Content = tonumber(GetVar(GV, "bbSizesEnd"))

    applyButton.Clicked = "ApplyButtonClicked"
    cancelButton.Clicked = "CancelButtonClicked"

    -- Handlers
    signals.ApplyButtonClicked = function(caller)
        Obj.Delete(screenOverlay, Obj.Index(window))
        E("Saving Config...")
    end

    signals.CancelButtonClicked = function(caller)
        Obj.Delete(screenOverlay, Obj.Index(window))
        E("Config Closed")
    end

end

functions['directStore'] = function(args)

    -- check to see if the plugin has been installed or not
    if (isempty(GetVar(GV, "bbSpotsInstalled"))) then
        notInstalledWarning()
        return
    end

    local userInput = MB({
        title = "Which Q?...",
        commands = {{value = 1, name = "Ok"}},
        inputs = {{name = "Cue:", value = data, whiteFilter = "0123456789."}},
        backColor = "Global.Default",
        icon = "logo_small",
    })

    local spot = spiltString(args,",",2)
    local cue = tonumber(userInput.inputs['Cue:'])

    storeOff(spot, cue)

end

functions['wizard'] = function()

    -- check to see if the plugin has been installed or not
    -- if (isempty(GetVar(GV, "bbSpotsInstalled"))) then
    --     notInstalledWarning()
    --     return
    -- end


    -- 'import' showfile variables into plugin
    -- local fixtures = {}
    -- local spots = {
    --     spot1 = GetVar(GV, "bbSpot1"),
    --     spot2 = GetVar(GV, "bbSpot2"),
    --     spot3 = GetVar(GV, "bbSpot3"),
    --     spot4 = GetVar(GV, "bbSpot4"),
    --     spot5 = GetVar(GV, "bbSpot5"),
    --     spot6 = GetVar(GV, "bbSpot6"),
    -- }


    local window, display = baseWindow()

    local titleBar = window:Append("TitleBar")
    local titleButton = titleBar:Append("TitleButton")
    local configButton = titleBar:Append("TitleButton")
    local closeButton = titleBar:Append("CloseButton")

    local dialogFrame = window:Append("DialogFrame")
    local subTitle = dialogFrame:Append("UIObject")

    local checkBoxGrid = dialogFrame:Append("UILayoutGrid")
    local checkSpot1 = checkBoxGrid:Append("CheckBox")
    local checkSpot2 = checkBoxGrid:Append("CheckBox")
    local checkSpot3 = checkBoxGrid:Append("CheckBox")
    local checkSpot4 = checkBoxGrid:Append("CheckBox")
    local checkSpot5 = checkBoxGrid:Append("CheckBox")
    local checkSpot6 = checkBoxGrid:Append("CheckBox")

    local cueIntGrid = dialogFrame:Append("UILayoutGrid")
    local cueTitle = cueIntGrid:Append("UIObject")
    local cueText = cueIntGrid:Append("LineEdit")
    local intensityTitle = cueIntGrid:Append("UIObject")
    local intensityText = cueIntGrid:Append("LineEdit")

    local characterTitle = dialogFrame:Append("UIObject")
    local characterSelect = dialogFrame:Append("Button")
    local colourTitle = dialogFrame:Append("UIObject")
    local colourSelect = dialogFrame:Append("Button")
    local sizeTitle = dialogFrame:Append("UIObject")
    local sizeSelect = dialogFrame:Append("Button")

    local buttonGrid = dialogFrame:Append("UILayoutGrid")
    local applyButton = buttonGrid:Append("Button")
    local cancelButton = buttonGrid:Append("Button")

    local function displayConfig()
        -- Create the dialog base.
        local dialogWidth = 650
        window.Name = "Followspot Wizard"
        window.H = "0"
        window.W = dialogWidth
        window.MaxSize = string.format("%s,%s", display.W * 0.8, display.H)
        window.MinSize = string.format("%s,0", dialogWidth - 100)
        window.Columns = 1
        window.Rows = 2
        window[1][1].SizePolicy = "Fixed"
        window[1][1].Size = "60"
        window[1][2].SizePolicy = "Stretch"
        window.AutoClose = "No"
        window.CloseOnEscape = "Yes"

        -- Create the title bar.
        titleBar.Columns = 3;
        titleBar.Rows = 1;
        titleBar.Anchors = "0,0";
        titleBar[2][2].SizePolicy = "Fixed";
        titleBar[2][2].Size = "50";
        titleBar[2][3].SizePolicy = "Fixed";
        titleBar[2][3].Size = "50";
        titleBar.Texture = "corner1";

        titleButton.Text = "BBLX - Followspot Wizard";
        titleButton.Texture = "corner1";
        titleButton.Anchors = "0,0";
        titleButton.Icon = "object_fixture2";

        configButton.Anchors = "1,0";
        configButton.Icon = "setup";
        configButton.HasHover = "Yes"
        configButton.PluginComponent = handles

        closeButton.Anchors = "2,0";
        closeButton.Texture = "corner2";

        -- Create the dialog's main frame.
        dialogFrame.H = "100%";
        dialogFrame.W = "100%";
        dialogFrame.Columns = 1;
        dialogFrame.Rows = 13;
        dialogFrame.Anchors = "0,1"
        dialogFrame[1][1].SizePolicy = "Fixed";
        dialogFrame[1][1].Size = "60";
        dialogFrame[1][2].SizePolicy = "Fixed";
        dialogFrame[1][2].Size = "120";
        dialogFrame[1][3].SizePolicy = "Fixed";
        dialogFrame[1][3].Size = "135";
        dialogFrame[1][4].SizePolicy = "Fixed";
        dialogFrame[1][4].Size = "60";
        dialogFrame[1][5].SizePolicy = "Fixed";
        dialogFrame[1][5].Size = "60";
        dialogFrame[1][6].SizePolicy = "Fixed";
        dialogFrame[1][6].Size = "60";
        dialogFrame[1][7].SizePolicy = "Fixed";
        dialogFrame[1][7].Size = "60";
        dialogFrame[1][8].SizePolicy = "Fixed";
        dialogFrame[1][8].Size = "60";
        dialogFrame[1][9].SizePolicy = "Fixed";
        dialogFrame[1][9].Size = "60";
        dialogFrame[1][10].SizePolicy = "Fixed";
        dialogFrame[1][10].Size = "120";

        -- Create a sub title.
        -- This is row 1 of the dialogFrame.
        subTitle.Text = "Which Spots?..."
        subTitle.ContentDriven = "Yes"
        subTitle.ContentWidth = "No"
        subTitle.TextAutoAdjust = "No"
        subTitle.Anchors = "0,0"
        subTitle.Padding = {
            left = 20,
            right = 20,
            top = 15,
            bottom = 15
        }
        subTitle.Font = "Medium20"
        subTitle.HasHover = "No"
        subTitle.BackColor = colorTransparent

        -- Create the checkbox grid.
        -- This is row 2 of the dialogFrame.
        checkBoxGrid.Columns = 3
        checkBoxGrid.Rows = 2
        checkBoxGrid.Anchors = "0,1"
        checkBoxGrid.Margin = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 5
        }

        checkSpot1.Anchors = "0,0"
        checkSpot1.Text = "Spot 1"
        checkSpot1.Tooltip = "spot1"
        checkSpot1.TextalignmentH = "Left"
        checkSpot1.State = 0
        checkSpot1.PluginComponent = handles
        checkSpot1.ColorIndicator = colorRed
        checkSpot1.Visible = true

        checkSpot2.Anchors = "1,0"
        checkSpot2.Text = "Spot 2"
        checkSpot2.Tooltip = "spot2"
        checkSpot2.TextalignmentH = "Left";
        checkSpot2.State = 0;
        checkSpot2.PluginComponent = handles
        checkSpot2.ColorIndicator = colorYellow
        checkSpot2.Visible = true

        checkSpot3.Anchors = "2,0"
        checkSpot3.Text = "Spot 3"
        checkSpot3.Tooltip = "spot3"
        checkSpot3.TextalignmentH = "Left";
        checkSpot3.State = 0;
        checkSpot3.PluginComponent = handles
        checkSpot3.ColorIndicator = colorGreen
        checkSpot3.Visible = true

        checkSpot4.Anchors = "0,1"
        checkSpot4.Text = "Spot 4"
        checkSpot4.Tooltip = "spot4"
        checkSpot4.TextalignmentH = "Left";
        checkSpot4.State = 0;
        checkSpot4.PluginComponent = handles
        checkSpot4.ColorIndicator = colorCyan
        checkSpot4.Visible = true

        checkSpot5.Anchors = "1,1"
        checkSpot5.Text = "Spot 5"
        checkSpot5.Tooltip = "spot5"
        checkSpot5.TextalignmentH = "Left";
        checkSpot5.State = 0;
        checkSpot5.PluginComponent = handles
        checkSpot5.ColorIndicator = colorBlue
        checkSpot5.Visible = true

        checkSpot6.Anchors = "2,1"
        checkSpot6.Text = "Spot 6"
        checkSpot6.Tooltip = "spot6"
        checkSpot6.TextalignmentH = "Left";
        checkSpot6.State = 0;
        checkSpot6.PluginComponent = handles
        checkSpot6.ColorIndicator = colorMagenta
        checkSpot6.Visible = true

        -- Create the Cue Intensity grid.
        -- This is row 3 of the dialogFrame.
        cueIntGrid.Columns = 2
        cueIntGrid.Rows = 2
        cueIntGrid.Anchors = "0,2"
        cueIntGrid.Margin = {
            left = 0,
            right = 0,
            top = 15,
            bottom = 0
        }

        -- Create a sub title.
        -- This is row 1 col 1 of the grid.
        cueTitle.Text = "Cue"
        cueTitle.ContentDriven = "Yes"
        cueTitle.ContentWidth = "No"
        cueTitle.TextAutoAdjust = "No"
        cueTitle.Anchors = "0,0"
        cueTitle.Padding = {
            left = 30,
            right = 30,
            top = 15,
            bottom = 15
        }
        cueTitle.Font = "Medium20"
        cueTitle.HasHover = "No"
        cueTitle.BackColor = colorTransparent

        -- Create a Number Input.
        -- This is row 2 col 1 of the grid.
        cueText.TextAutoAdjust = "Yes"
        cueText.Anchors = "0,1"
        cueText.Margin = {
            left = 30,
            right = 30,
            top = 0,
            bottom = 0
        }
        cueText.Padding = "5,5"
        cueText.Font = "Regular20"
        cueText.Filter = "0123456789."
        cueText.VkPluginName = "TextInputNumOnly"
        cueText.Content = ""
        cueText.MaxTextLength = 8
        cueText.HideFocusFrame = "Yes"
        cueText.PluginComponent = handles

        -- Create a sub title.
        -- This is row 1 col 2 of the grid.
        intensityTitle.Text = "Intensity"
        intensityTitle.ContentDriven = "Yes"
        intensityTitle.ContentWidth = "No"
        intensityTitle.TextAutoAdjust = "No"
        intensityTitle.Anchors = "1,0"
        intensityTitle.Padding = {
            left = 30,
            right = 30,
            top = 15,
            bottom = 15
        }
        intensityTitle.Font = "Medium20"
        intensityTitle.HasHover = "No"
        intensityTitle.BackColor = colorTransparent

        -- Create a Number Input.
        -- This is row 2 col 2 of the grid.
        intensityText.TextAutoAdjust = "Yes"
        intensityText.Anchors = "1,1"
        intensityText.Margin = {
            left = 30,
            right = 30,
            top = 0,
            bottom = 0
        }
        intensityText.Padding = "5,5"
        intensityText.Font = "Regular20"
        intensityText.Filter = "0123456789"
        intensityText.VkPluginName = "TextInputNumOnly"
        intensityText.Content = ""
        intensityText.MaxTextLength = 3
        intensityText.HideFocusFrame = "Yes"
        intensityText.PluginComponent = handles

        -- Create a sub title.
        -- This is row 4 of the dialogFrame.
        characterTitle.Text = "Which Character?..."
        characterTitle.ContentDriven = "Yes"
        characterTitle.ContentWidth = "No"
        characterTitle.TextAutoAdjust = "No"
        characterTitle.Anchors = "0,3"
        characterTitle.Padding = {
            left = 20,
            right = 20,
            top = 15,
            bottom = 15
        }
        characterTitle.Font = "Medium20"
        characterTitle.HasHover = "No"
        characterTitle.BackColor = colorTransparent

        -- Create a Button.
        -- This is row 5 of the dialogFrame.
        characterSelect.Anchors = "0,4"
        characterSelect.Margin = {
            left = 60,
            right = 60,
            top = 0,
            bottom = 0
        }
        characterSelect.Font = "Regular24"
        characterSelect.Name= "Character"
        characterSelect.Text = "..."
        characterSelect.PluginComponent = handles

        -- Create a sub title.
        -- This is row 6 of the dialogFrame.
        colourTitle.Text = "What Colour?..."
        colourTitle.ContentDriven = "Yes"
        colourTitle.ContentWidth = "No"
        colourTitle.TextAutoAdjust = "No"
        colourTitle.Anchors = "0,5"
        colourTitle.Padding = {
            left = 20,
            right = 20,
            top = 15,
            bottom = 15
        }
        colourTitle.Font = "Medium20"
        colourTitle.HasHover = "No"
        colourTitle.BackColor = colorTransparent

        -- Create a Button.
        -- This is row 7 of the dialogFrame.
        colourSelect.Anchors = "0,6"
        colourSelect.Margin = {
            left = 60,
            right = 60,
            top = 0,
            bottom = 0
        }
        colourSelect.Font = "Regular24"
        colourSelect.Name= "Colour"
        colourSelect.Text = "..."
        colourSelect.PluginComponent = handles

        -- Create a sub title.
        -- This is row 8 of the dialogFrame.
        sizeTitle.Text = "What Size?..."
        sizeTitle.ContentDriven = "Yes"
        sizeTitle.ContentWidth = "No"
        sizeTitle.TextAutoAdjust = "No"
        sizeTitle.Anchors = "0,7"
        sizeTitle.Padding = {
            left = 20,
            right = 20,
            top = 15,
            bottom = 15
        }
        sizeTitle.Font = "Medium20"
        sizeTitle.HasHover = "No"
        sizeTitle.BackColor = colorTransparent

        -- Create a Button.
        -- This is row 9 of the dialogFrame.
        sizeSelect.Anchors = "0,8"
        sizeSelect.Margin = {
            left = 60,
            right = 60,
            top = 0,
            bottom = 0
        }
        sizeSelect.Font = "Regular24"
        sizeSelect.Name= "Size"
        sizeSelect.Text = "..."
        sizeSelect.PluginComponent = handles

        -- Create the button grid.
        -- This is row 10 of the dialogFrame.
        buttonGrid.Columns = 2
        buttonGrid.Rows = 1
        buttonGrid.Anchors = "0,9"
        buttonGrid.Margin = {
            left = 0,
            right = 0,
            top = 40,
            bottom = 0
        }

        applyButton.Anchors = "0,0"
        applyButton.Textshadow = 1;
        applyButton.HasHover = "Yes";
        applyButton.Text = "Apply";
        applyButton.Font = "Medium20";
        applyButton.TextalignmentH = "Centre";
        applyButton.PluginComponent = handles

        cancelButton.Anchors = "1,0"
        cancelButton.Textshadow = 1;
        cancelButton.HasHover = "Yes";
        cancelButton.Text = "Cancel";
        cancelButton.Font = "Medium20";
        cancelButton.TextalignmentH = "Centre";
        cancelButton.PluginComponent = handles
        cancelButton.Visible = "Yes"
    end

    displayConfig()

    if GetVar(GV, "bbSpot1") == "0" then checkSpot1.Visible = false end
    if GetVar(GV, "bbSpot2") == "0" then checkSpot2.Visible = false end
    if GetVar(GV, "bbSpot3") == "0" then checkSpot3.Visible = false end
    if GetVar(GV, "bbSpot4") == "0" then checkSpot4.Visible = false end
    if GetVar(GV, "bbSpot5") == "0" then checkSpot5.Visible = false end
    if GetVar(GV, "bbSpot6") == "0" then checkSpot6.Visible = false end

    configButton.Clicked = "ConfigButtonClicked"
    checkSpot1.Clicked = "SpotToggled"
    checkSpot2.Clicked = "SpotToggled"
    checkSpot3.Clicked = "SpotToggled"
    checkSpot4.Clicked = "SpotToggled"
    checkSpot5.Clicked = "SpotToggled"
    checkSpot6.Clicked = "SpotToggled"
    characterSelect.Clicked = "presetPopup"
    colourSelect.Clicked = "presetPopup"
    colourSelect.Clicked = "presetPopup"
    applyButton.Clicked = "ApplyButtonClicked"
    cancelButton.Clicked = "CancelButtonClicked"


    -- Handlers
    signals.ConfigButtonClicked = function(caller)
        functions['config']()
    end

    signals.SpotToggled = function(caller)
        caller.State = 1 - caller.State
        local v = spots[caller.Tooltip]
        if (caller.State == 1) and not (v == 0) then fixtures[caller.Tooltip] = v end
        if (caller.State == 0) then fixtures[caller.Tooltip] = nil end
    end

    signals.presetPopup = function(caller)
        local itemlist = getPresets(
            GetVar(GV, "bb" .. caller.name .. "Pool"),
            GetVar(GV, "bb" .. caller.name .. "Start"),
            GetVar(GV, "bb" .. caller.name .. "End")
        )

        local _, choice = PI{title = caller.Name, caller = caller:GetDisplay(), items = itemlist, selectedValue = caller.Text}
        caller.Text = choice or caller.Text
    end

    signals.VerbToggled = function(caller)
        caller.State = 1 - caller.State
        if (caller.State == 1) then alreadyOn = true end
        if (caller.State == 0) then alreadyOn = false end
    end

    signals.ApplyButtonClicked = function(caller)
        Obj.Delete(screenOverlay, Obj.Index(window))
        E("Wizard Closed")
    end

    signals.CancelButtonClicked = function(caller)
        Obj.Delete(screenOverlay, Obj.Index(window))
        E("Wizard Closed")
    end

end


-- ****************************************************************
-- caller function
-- ****************************************************************

local function main(display,argument)
    if argument then
        functions[spiltString(argument,",",1)](argument)
    else
        functions['install']()
    end
end

return main;