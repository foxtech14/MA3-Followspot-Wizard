-- BBLX Followspot Wizard v1
-- By Michael Fox
-- xx-xx-24

-- ****************************************************************
-- Feature To-Do list
-- ****************************************************************

-- Store preset information
-- Label cue
-- Set cue fade time
-- user input validation -> messagebox popup with errors
-- create function to store intensity [inprogress]
-- creat function to store nips [inprogress]


-- add spot pickup [in progress]
-- add FTB (if @ 0 only store dimmer)
-- if int empty -> CHANGE description
-- cue time macros

-- ****************************************************************
-- USER CONFIG AREA - ONLY EDIT THIS BIT
-- ****************************************************************

-- SEQUENCES FOR EACH SPOT
local spotSeq = {
    spot1 = 11,
    spot2 = 12,
    spot3 = 13,
    spot4 = 14,
    spot5 = 15,
    spot6 = 16
}


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

local presetPopup = {
    characters = {}, -- preset pool 2
    colours = {}, -- preset pool 4
    sizes = {} -- preset pool 6
}


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


-- ****************************************************************
-- general functions
-- ****************************************************************

local function getPresets(p, a, s, e)
    for i = s, e do
        local preset = DataPool().PresetsPool[p][i]
        local label = string.format("%s | %s", i, preset)
        presetPopup[a][i] = label
    end
    presetPopup[a][0] = "..."
end

local function storeInt(seq, cue, fix, int)
    E("=> => @ " .. int .. "%")
    C(string.format("Fixture %s At  %s", fix, int))
end

local function storeNips(seq, cue, fix, pos, col, size)
    E("=> => @ Position Preset: " .. pos)
    C(string.format("Fixture %s At Preset 2.%s", fix, pos))

    E("=> => @ Colour Preset: " .. col)
    C(string.format("Fixture %s At Preset 4.%s", fix, col))

    E("=> => @ Focus Preset: " .. size)
    C(string.format("Fixture %s At Preset 6.%s", fix, size))
end


-- ****************************************************************
-- config windows
-- ****************************************************************

local function configSpots()
    E("Configuring Spots...")

    local spots = {0,0,0,0,0,0}

    for i = 1, 6 do
        local title = "Spot " .. i
        local data = GetVar(GV, "bbSpot"..i)

        local userInput = MB({
            title = title,
            commands = {{value = 1, name = "Ok"}},
            inputs = {{name = "Fixture", value = data, whiteFilter = "0123456789"}},
            backColor = "Global.Default",
            icon = "logo_small",
        })

        local result = userInput.inputs['Fixture']
        local fixture = tonumber(result)
        SetVar(GV, "bbSpot"..i, fixture)
        E("=> Spot " .. i .. " is now Fixture " .. fixture)
    end

    E("Config Saved!")
end

local function configCharacters()
    E("Configuring Characters...")

    -- get current values from global variables
    local startCharacter = GetVar(GV, "bbCharactersStart")
    local endCharacter = GetVar(GV, "bbCharactersEnd")

    -- input dialog for user input for first preset
    local userInputStart = MB({
        title = "First Character Postion Preset",
        commands = {{value = 1, name = "Ok"}},
        inputs = {{name = "Preset", value = startCharacter, whiteFilter = "0123456789"}},
        backColor = "Global.Default",
        icon = "logo_small",
    })

    -- set global variable for first preset
    local startCharacter = userInputStart.inputs['Preset']
    local firstPreset = tonumber(startCharacter)
    SetVar(GV, "bbCharactersStart", firstPreset)
    E("=> First Character Postion Preset is now: " .. firstPreset)

    -- input dialog for user input for last preset
    local userInputEnd = MB({
        title = "Last Character Postion Preset",
        commands = {{value = 1, name = "Ok"}},
        inputs = {{name = "Preset", value = endCharacter, whiteFilter = "0123456789"}},
        backColor = "Global.Default",
        icon = "logo_small",
    })

    -- set global variable for last preset
    local endCharacter = userInputEnd.inputs['Preset']
    local lastPreset = tonumber(endCharacter)
    SetVar(GV, "bbCharactersEnd", lastPreset)
    E("=> Last Character Postion Preset is now: " .. lastPreset)

    E("Config Saved!")
end

local function configColours()
    E("Configuring Colours...")

    -- get current values from global variables
    local startColour = GetVar(GV, "bbColoursStart")
    local endColour = GetVar(GV, "bbColoursEnd")

    -- input dialog for user input for first preset
    local userInputStart = MB({
        title = "First Colour Preset",
        commands = {{value = 1, name = "Ok"}},
        inputs = {{name = "Preset", value = startColour, whiteFilter = "0123456789"}},
        backColor = "Global.Default",
        icon = "logo_small",
    })

    -- set global variable for first preset
    local startColour = userInputStart.inputs['Preset']
    local firstPreset = tonumber(startColour)
    SetVar(GV, "bbColoursStart", firstPreset)
    E("=> First Colour Preset is now: " .. firstPreset)

    -- input dialog for user input for last preset
    local userInputEnd = MB({
        title = "Last Colour Preset",
        commands = {{value = 1, name = "Ok"}},
        inputs = {{name = "Preset", value = endColour, whiteFilter = "0123456789"}},
        backColor = "Global.Default",
        icon = "logo_small",
    })

    -- set global variable for last preset
    local endColour = userInputEnd.inputs['Preset']
    local lastPreset = tonumber(endColour)
    SetVar(GV, "bbColoursEnd", lastPreset)
    E("=> Last Colour Preset is now: " .. lastPreset)

    E("Config Saved!")
end

local function configSizes()
    E("Configuring Sizes...")

    -- get current values from global variables
    local startSize = GetVar(GV, "bbSizesStart")
    local endSize = GetVar(GV, "bbSizesEnd")

    -- input dialog for user input for first preset
    local userInputStart = MB({
        title = "First Size Preset",
        commands = {{value = 1, name = "Ok"}},
        inputs = {{name = "Preset", value = startSize, whiteFilter = "0123456789"}},
        backColor = "Global.Default",
        icon = "logo_small",
    })

    -- set global variable for first preset
    local startSize = userInputStart.inputs['Preset']
    local firstPreset = tonumber(startSize)
    SetVar(GV, "bbSizesStart", firstPreset)
    E("=> First Size Preset is now: " .. firstPreset)

    -- input dialog for user input for last preset
    local userInputEnd = MB({
        title = "Last Size Preset",
        commands = {{value = 1, name = "Ok"}},
        inputs = {{name = "Preset", value = endSize, whiteFilter = "0123456789"}},
        backColor = "Global.Default",
        icon = "logo_small",
    })

    -- set global variable for last preset
    local endSize = userInputEnd.inputs['Preset']
    local lastPreset = tonumber(endSize)
    SetVar(GV, "bbSizesEnd", lastPreset)
    E("=> Last Size Preset is now: " .. lastPreset)

    E("Config Saved!")
end


-- ****************************************************************
-- master config windows
-- ****************************************************************

local function config()

    local functions = {
        [1] = configSpots,
        [2] = configCharacters,
        [3] = configColours,
        [4] = configSizes
    }

    local i,t = PI({
        title = "Config",
        caller = GetFocusDisplay(),
        items = {"Spots","Characters","Colour","Sizes"}
    })

    if not isempty(i) then
        local func = functions[i+1]
        if(func) then
            func()
        end
    end

end

local function firstConfig()

    SetVar(GV, "bbSpot1", 0)
    SetVar(GV, "bbSpot2", 0)
    SetVar(GV, "bbSpot3", 0)
    SetVar(GV, "bbSpot4", 0)
    SetVar(GV, "bbSpot5", 0)
    SetVar(GV, "bbSpot6", 0)
    SetVar(GV, "bbCharactersStart", 1)
    SetVar(GV, "bbCharactersEnd", 2)
    SetVar(GV, "bbColoursStart", 1)
    SetVar(GV, "bbColoursEnd", 2)
    SetVar(GV, "bbSizesStart", 1)
    SetVar(GV, "bbSizesEnd", 2)

    configSpots()
    configCharacters()
    configColours()
    configSizes()

    SetVar(GV, "spotsLaunched", "true")

end


-- ****************************************************************
-- main function
-- ****************************************************************

local function main()

    -- check to see if this is the first launch in a show
    if (isempty(GetVar(GV, "spotsLaunched"))) then
        E("Initial Config Started")
        firstConfig() -- run inital config
    end

    local alreadyOn = false

    -- 'import' showfile variables into plugin
    local fixtures = {}
    local spots = {
        spot1 = GetVar(GV, "bbSpot1"),
        spot2 = GetVar(GV, "bbSpot2"),
        spot3 = GetVar(GV, "bbSpot3"),
        spot4 = GetVar(GV, "bbSpot4"),
        spot5 = GetVar(GV, "bbSpot5"),
        spot6 = GetVar(GV, "bbSpot6"),
    }

    local posStart = tonumber(GetVar(GV, "bbCharactersStart"))
    local posEnd = tonumber(GetVar(GV, "bbCharactersEnd"))
    local colStart = tonumber(GetVar(GV, "bbColoursStart"))
    local colEnd = tonumber(GetVar(GV, "bbColoursEnd"))
    local sizeStart = tonumber(GetVar(GV, "bbSizesStart"))
    local sizeEnd = tonumber(GetVar(GV, "bbSizesEnd"))

    getPresets(2, "characters", posStart, posEnd)
    getPresets(4, "colours", colStart, colEnd)
    getPresets(6, "sizes", sizeStart, sizeEnd)


    -- Get the index of the display on which to create the dialog.
    local displayIndex = Obj.Index(GetFocusDisplay())
    if displayIndex > 5 then
        displayIndex = 1
    end

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

    -- Get the overlay.
    local display = GetDisplayByIndex(displayIndex)
    local screenOverlay = display.ScreenOverlay

    -- Delete any UI elements currently displayed on the overlay.
    screenOverlay:ClearUIChildren()

    local window = screenOverlay:Append("BaseInput")

    local titleBar = window:Append("TitleBar")
    local titleButton = titleBar:Append("TitleButton")
    local configButton = titleBar:Append("TitleButton")
    local closeButton = titleBar:Append("CloseButton")

    local dialogFrame = window:Append("DialogFrame")
    local subTitle = dialogFrame:Append("UIObject")

    local checkBoxGrid = dialogFrame:Append("UILayoutGrid")
    local checkBox1 = checkBoxGrid:Append("CheckBox")
    local checkBox2 = checkBoxGrid:Append("CheckBox")
    local checkBox3 = checkBoxGrid:Append("CheckBox")
    local checkBox4 = checkBoxGrid:Append("CheckBox")
    local checkBox5 = checkBoxGrid:Append("CheckBox")
    local checkBox6 = checkBoxGrid:Append("CheckBox")

    local intensityTitle = dialogFrame:Append("UIObject")
    local lineEdit1 = dialogFrame:Append("LineEdit")
    local characterTitle = dialogFrame:Append("UIObject")
    local button1 = dialogFrame:Append("Button")
    local colourTitle = dialogFrame:Append("UIObject")
    local button2 = dialogFrame:Append("Button")
    local sizeTitle = dialogFrame:Append("UIObject")
    local button3 = dialogFrame:Append("Button")
    local cueTitle = dialogFrame:Append("UIObject")
    local lineEdit2 = dialogFrame:Append("LineEdit")
    local checkBox7 = dialogFrame:Append("CheckBox")

    local buttonGrid = dialogFrame:Append("UILayoutGrid")
    local applyButton = buttonGrid:Append("Button")
    local cancelButton = buttonGrid:Append("Button")

    function displayConfig()
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
        configButton.Clicked = "ConfigButtonClicked"

        closeButton.Anchors = "2,0";
        closeButton.Texture = "corner2";

        -- Create the dialog's main frame.
        dialogFrame.H = "100%";
        dialogFrame.W = "100%";
        dialogFrame.Columns = 1;
        dialogFrame.Rows = 14;
        dialogFrame.Anchors = "0,1"
        dialogFrame[1][1].SizePolicy = "Fixed";
        dialogFrame[1][1].Size = "60";
        dialogFrame[1][2].SizePolicy = "Fixed";
        dialogFrame[1][2].Size = "120";
        dialogFrame[1][3].SizePolicy = "Fixed";
        dialogFrame[1][3].Size = "60";
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
        dialogFrame[1][10].Size = "60";
        dialogFrame[1][11].SizePolicy = "Fixed";
        dialogFrame[1][11].Size = "60";
        dialogFrame[1][12].SizePolicy = "Fixed";
        dialogFrame[1][12].Size = "60";
        dialogFrame[1][13].SizePolicy = "Fixed";
        dialogFrame[1][13].Size = "100";
        dialogFrame[1][14].SizePolicy = "Fixed";
        dialogFrame[1][14].Size = "120";

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

        checkBox1.Anchors = "0,0"
        checkBox1.Text = "Spot 1"
        checkBox1.Tooltip = "spot1"
        checkBox1.TextalignmentH = "Left"
        checkBox1.State = 0
        checkBox1.PluginComponent = handles
        checkBox1.ColorIndicator = colorRed

        checkBox2.Anchors = "1,0"
        checkBox2.Text = "Spot 2"
        checkBox2.Tooltip = "spot2"
        checkBox2.TextalignmentH = "Left";
        checkBox2.State = 0;
        checkBox2.PluginComponent = handles
        checkBox2.Clicked = "SpotToggled"
        checkBox2.ColorIndicator = colorYellow

        checkBox3.Anchors = "2,0"
        checkBox3.Text = "Spot 3"
        checkBox3.Tooltip = "spot3"
        checkBox3.TextalignmentH = "Left";
        checkBox3.State = 0;
        checkBox3.PluginComponent = handles
        checkBox3.Clicked = "SpotToggled"
        checkBox3.ColorIndicator = colorGreen

        checkBox4.Anchors = "0,1"
        checkBox4.Text = "Spot 4"
        checkBox4.Tooltip = "spot4"
        checkBox4.TextalignmentH = "Left";
        checkBox4.State = 0;
        checkBox4.PluginComponent = handles
        checkBox4.Clicked = "SpotToggled"
        checkBox4.ColorIndicator = colorCyan

        checkBox5.Anchors = "1,1"
        checkBox5.Text = "Spot 5"
        checkBox5.Tooltip = "spot5"
        checkBox5.TextalignmentH = "Left";
        checkBox5.State = 0;
        checkBox5.PluginComponent = handles
        checkBox5.Clicked = "SpotToggled"
        checkBox5.ColorIndicator = colorBlue

        checkBox6.Anchors = "2,1"
        checkBox6.Text = "Spot 6"
        checkBox6.Tooltip = "spot6"
        checkBox6.TextalignmentH = "Left";
        checkBox6.State = 0;
        checkBox6.PluginComponent = handles
        checkBox6.Clicked = "SpotToggled"
        checkBox6.ColorIndicator = colorMagenta

        -- Create a sub title.
        -- This is row 3 of the dialogFrame.
        intensityTitle.Text = "What Intensity?..."
        intensityTitle.ContentDriven = "Yes"
        intensityTitle.ContentWidth = "No"
        intensityTitle.TextAutoAdjust = "No"
        intensityTitle.Anchors = "0,2"
        intensityTitle.Padding = {
            left = 20,
            right = 20,
            top = 15,
            bottom = 15
        }
        intensityTitle.Font = "Medium20"
        intensityTitle.HasHover = "No"
        intensityTitle.BackColor = colorTransparent

        -- Create a Number Input.
        -- This is row 4 of the dialogFrame.
        lineEdit1.Prompt = "Intensity: "
        lineEdit1.TextAutoAdjust = "Yes"
        lineEdit1.Anchors = "0,3"
        lineEdit1.Margin = {
            left = 60,
            right = 60,
            top = 0,
            bottom = 0
        }
        lineEdit1.Padding = "5,5"
        lineEdit1.Font = "Regular20"
        lineEdit1.Filter = "0123456789"
        lineEdit1.VkPluginName = "TextInputNumOnly"
        lineEdit1.Content = ""
        lineEdit1.MaxTextLength = 3
        lineEdit1.HideFocusFrame = "Yes"
        lineEdit1.PluginComponent = handles

        -- Create a sub title.
        -- This is row 5 of the dialogFrame.
        characterTitle.Text = "Which Character?..."
        characterTitle.ContentDriven = "Yes"
        characterTitle.ContentWidth = "No"
        characterTitle.TextAutoAdjust = "No"
        characterTitle.Anchors = "0,4"
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
        -- This is row 6 of the dialogFrame.
        button1.Anchors = "0,5"
        button1.Margin = {
            left = 60,
            right = 60,
            top = 0,
            bottom = 0
        }
        button1.Font = "Regular24"
        button1.Name, button1.Text = "characters", "..."
        button1.PluginComponent, button1.Clicked = handles, "presetPopup"

        -- Create a sub title.
        -- This is row 7 of the dialogFrame.
        colourTitle.Text = "What Colour?..."
        colourTitle.ContentDriven = "Yes"
        colourTitle.ContentWidth = "No"
        colourTitle.TextAutoAdjust = "No"
        colourTitle.Anchors = "0,6"
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
        -- This is row 8 of the dialogFrame.
        button2.Anchors = "0,7"
        button2.Margin = {
            left = 60,
            right = 60,
            top = 0,
            bottom = 0
        }
        button2.Font = "Regular24"
        button2.Name, button2.Text = "colours", "..."
        button2.PluginComponent, button2.Clicked = handles, "presetPopup"

        -- Create a sub title.
        -- This is row 9 of the dialogFrame.
        sizeTitle.Text = "What Size?..."
        sizeTitle.ContentDriven = "Yes"
        sizeTitle.ContentWidth = "No"
        sizeTitle.TextAutoAdjust = "No"
        sizeTitle.Anchors = "0,8"
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
        -- This is row 10 of the dialogFrame.
        button3.Anchors = "0,9"
        button3.Margin = {
            left = 60,
            right = 60,
            top = 0,
            bottom = 0
        }
        button3.Font = "Regular24"
        button3.Name, button3.Text = "sizes", "..."
        button3.PluginComponent, button3.Clicked = handles, "presetPopup"


        -- Create a sub title.
        -- This is row 11 of the dialogFrame.
        cueTitle.Text = "What Cue?..."
        cueTitle.ContentDriven = "Yes"
        cueTitle.ContentWidth = "No"
        cueTitle.TextAutoAdjust = "No"
        cueTitle.Anchors = "0,10"
        cueTitle.Padding = {
            left = 20,
            right = 20,
            top = 15,
            bottom = 15
        }
        cueTitle.Font = "Medium20"
        cueTitle.HasHover = "No"
        cueTitle.BackColor = colorTransparent

        -- Create a Number Input.
        -- This is row 12 of the dialogFrame.
        lineEdit2.Prompt = "Cue: "
        lineEdit2.TextAutoAdjust = "Yes"
        lineEdit2.Anchors = "0,11"
        lineEdit2.Margin = {
            left = 60,
            right = 60,
            top = 0,
            bottom = 0
        }
        lineEdit2.Padding = "5,5"
        lineEdit2.Font = "Regular20"
        lineEdit2.Filter = "0123456789."
        lineEdit2.VkPluginName = "TextInputNumOnly"
        lineEdit2.Content = ""
        lineEdit2.MaxTextLength = 8
        lineEdit2.HideFocusFrame = "Yes"
        lineEdit2.PluginComponent = handles

        -- Create a Number Input.
        -- This is row 12 of the dialogFrame.
        checkBox7.Anchors = "0,12"
        checkBox7.Margin = {
            left = 180,
            right = 180,
            top = 40,
            bottom = 0
        }
        checkBox7.Text = "ALREADY ON?"
        checkBox7.TextalignmentH = "Centre"
        checkBox7.State = 0
        checkBox7.PluginComponent = handles
        checkBox7.Clicked = "VerbToggled"

        -- Create the button grid.
        -- This is row 14 of the dialogFrame.
        buttonGrid.Columns = 2
        buttonGrid.Rows = 1
        buttonGrid.Anchors = "0,13"
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
        applyButton.Clicked = "ApplyButtonClicked"

        cancelButton.Anchors = "1,0"
        cancelButton.Textshadow = 1;
        cancelButton.HasHover = "Yes";
        cancelButton.Text = "Cancel";
        cancelButton.Font = "Medium20";
        cancelButton.TextalignmentH = "Centre";
        cancelButton.PluginComponent = handles
        cancelButton.Clicked = "CancelButtonClicked"
        cancelButton.Visible = "Yes"
    end

    displayConfig()

    checkBox1.Clicked = "SpotToggled"


    -- Handlers
    signals.ConfigButtonClicked = function(caller)
        E("Config Started...")
        config()
        E("Config Ended...")
    end

    signals.SpotToggled = function(caller)
        caller.State = 1 - caller.State
        local v = spots[caller.Tooltip]
        if (caller.State == 1) and not (v == 0) then fixtures[caller.Tooltip] = v end
        if (caller.State == 0) then fixtures[caller.Tooltip] = nil end
    end

    signals.presetPopup = function(caller)
        local itemlist = presetPopup[caller.Name]
        local _, choice = PI{title = caller.Name, caller = caller:GetDisplay(), items = itemlist, selectedValue = caller.Text}
        caller.Text = choice or caller.Text
    end

    signals.VerbToggled = function(caller)
        caller.State = 1 - caller.State
        if (caller.State == 1) then alreadyOn = true end
        if (caller.State == 0) then alreadyOn = false end
    end

    signals.ApplyButtonClicked = function(caller)
        if (applyButton.BackColor == colorBackground) then
            applyButton.BackColor = colorBackgroundPlease
        else
            applyButton.BackColor = colorBackground
        end

        E("Resetting Programmer")
        C("ClearAll")

        local cue = tonumber(lineEdit2.Content)
        local intensity = tonumber(lineEdit1.Content)
        local character = button1.Text
        local colour = button2.Text
        local size = button3.Text

        local storingInt = false
        local storingPos = false
        local storingCol = false
        local storingSiz = false

        local errors = ""
        local verb = ""

        -- Validation

        if (next(fixtures) == nil) then
            errors = errors .. "Please select at least 1 Spot \n"
        end

        if (cue == nil) then
            errors = errors .. "Please enter a valid Cue Number \n"
        end

        if (intensity == nil and alreadyOn == false) then
            errors = errors .. "Please enter an intensity or un-check 'Already On' \n"
        end

        -- Storing

        if (errors == "") then
            if not (intensity == nil) then
                storingInt = true

                if (intensity > 100) then
                    intensity = 100
                end

                if (intensity > 0) then
                    if not (character == "...") then
                        character = spiltString(character, " | ", 0)
                        storingPos = true
                    end

                    if not (colour == "...") then
                        colour = spiltString(colour, " | ", 0)
                        storingCol = true
                    end

                    if not (size == "...") then
                        size = spiltString(size, " | ", 0)
                        storingSiz = true
                    end
                end
            end

            E("Storing Cue: " .. cue)

            for l, f in pairs(fixtures) do
                E("=> Storing Fixture: " .. f .. " (" .. l .. ") ...")
                E("=> Sequence: " .. spotSeq[l])

                if (storingInt) then
                    C(string.format("Fixture %s at %s", f, intensity))
                end

                if (storingPos) then
                    C(string.format("Fixture %s at Preset 'Position'.%s", f, character))
                end

                if (storingCol == nil) then
                    C(string.format("Fixture %s at Preset 'Color'.%s", f, colour))
                end

                if (storingSiz == nil) then
                    C(string.format("Fixture %s at Preset 'Focus'.%s", f, size))
                end

                C(string.format("Store Sequence %s Cue %s", spotSeq[l], cue))
            end

            E("Storing Complete")
            Obj.Delete(screenOverlay, Obj.Index(window))
            E("Wizard Closed")
        end

        -- Error Displaying
        applyButton.BackColor = colorBackground
        Confirm("Something went wrong!", errors)
    end

    signals.CancelButtonClicked = function(caller)
        Obj.Delete(screenOverlay, Obj.Index(window))
        E("Wizard Closed")
    end

end

return main;

-- ****************************************************************
-- Cue Label Guide
-- ****************************************************************

-- structure ->
-- fade character @ location | size | ?colour?

-- FADE
-- CHANGE
-- FTB
