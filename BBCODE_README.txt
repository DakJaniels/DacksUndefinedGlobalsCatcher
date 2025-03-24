[size=6][b]DacksUndefinedGlobalsCatcher[/b][/size]

A powerful debugging utility for ESO (Elder Scrolls Online) add-on developers that helps catch and report undefined global variables. This tool makes it easier to track down pesky UI errors like [font=Courier New]attempt to index a nil value[/font] and other issues related to undefined globals in ESO add-ons.

[quote][b]Compatible with both PC/Gamepad and Console UI(that is ForceConsoleFlow.2 CVar)![/b] Works seamlessly whether you're using keyboard/mouse or gamepad mode.[/quote]

[size=5][b]Overview[/b][/size]

When developing ESO add-ons, one common source of errors is attempting to access undefined global variables. These errors can manifest as cryptic messages like:
[code]12345678901234567890:1: attempt to index a nil value[/code]

DacksUndefinedGlobalsCatcher helps by:
[list]
[*]Catching all attempts to access undefined global variables
[*]Displaying detailed error information including the variable name and call stack
[*]Allowing you to ignore specific globals or function patterns
[*]Providing a convenient UI for reviewing and managing errors
[/list]

[size=5][b]Screenshots[/b][/size]

[img]example.png[/img]

[size=5][b]Features[/b][/size]

[list]
[*][b]Real-time Error Detection[/b]: Catches undefined globals as they happen
[*][b]Detailed Error Reporting[/b]: Shows the exact variable that's undefined along with:
  [list]
  [*]Call stack with function names
  [*]Source file and line numbers
  [*]Local variable context when available
  [/list]
[*][b]Customizable Ignore Lists[/b]:
  [list]
  [*]Pre-configured list of common ESO UI elements to reduce noise
  [*]Add your own globals to ignore via slash commands
  [*]Add function patterns to ignore via slash commands
  [/list]
[*][b]Interactive UI[/b]:
  [list]
  [*]Resizable window with proper scrolling
  [*]Color-coded messages for better readability
  [*]Toggle visibility with a simple slash command
  [/list]
[*][b]Multi-platform Support[/b]:
  [list]
  [*]Compatible with both keyboard/mouse and gamepad (Console) UI
  [*]Automatically adapts font and UI elements to the current mode
  [/list]
[*][b]Localization Support[/b]:
  [list]
  [*]Available in multiple languages: English, German (de), Spanish (es), French (fr), Japanese (jp), Russian (ru), and Traditional Chinese (zh)
  [*]Automatically uses your game's language setting
  [/list]
[/list]

[size=5][b]Installation[/b][/size]

[list=1]
[*]Download the latest release from GitHub
[*]Extract to your ESO AddOns folder:
   [list]
   [*]Windows: [font=Courier New]Documents\Elder Scrolls Online\live\AddOns\[/font]
   [*]Mac: [font=Courier New]~/Documents/Elder Scrolls Online/live/AddOns/[/font]
   [/list]
[*]Launch ESO and enable the add-on in the add-on settings
[/list]

[size=5][b]Usage[/b][/size]

[size=4][b]Slash Commands[/b][/size]

[list]
[*][font=Courier New]/undefs[/font] - Toggle the undefined globals window
[*][font=Courier New]/undefs_list[/font] - List all ignored globals
[*][font=Courier New]/undefs_add <name>[/font] - Add a global to the ignore list
[*][font=Courier New]/undefs_remove <name>[/font] - Remove a global from the ignore list
[*][font=Courier New]/undefs_listfunc[/font] - List all ignored function patterns
[*][font=Courier New]/undefs_addfunc <pattern>[/font] - Add a function pattern to the ignore list
[*][font=Courier New]/undefs_removefunc <pattern>[/font] - Remove a function pattern from the ignore list
[*][font=Courier New]/undefs_help[/font] - Show help message with all commands
[*][font=Courier New]/rl[/font] - Shortcut for reloading the UI
[/list]

[size=4][b]Working with the Error Window[/b][/size]

When an undefined global is accessed, it will be displayed in the error window with:
[list]
[*]The number of times it has occurred
[*]The name of the undefined global
[*]A detailed call stack showing where the error happened
[*]When available, local variable context to help debug the issue
[/list]

[size=4][b]Managing Ignore Lists[/b][/size]

The add-on comes with predefined lists of globals and function patterns to ignore. These are common UI elements and functions that don't need to be reported. You can add your own entries to these lists using the slash commands.

[size=3][b]Default Ignore Lists[/b][/size]

To reduce noise, the add-on includes default ignore lists:

[b]Default Ignored Globals[/b] (over 170 entries) include:
[list]
[*]Common UI elements ([font=Courier New]ActionButton1Decoration[/font], [font=Courier New]QuickslotButton5Decoration[/font], etc.)
[*]Known addons ([font=Courier New]MasterMerchant[/font], [font=Courier New]AdvancedFilters[/font], [font=Courier New]AUI_Main[/font], etc.)
[*]Various pin types ([font=Courier New]pinType_Skyshards[/font], [font=Courier New]pinType_Treasure_Maps[/font], etc.)
[*]ESO global variables ([font=Courier New]PREVIEW_UPDATE_INTERVAL_MS[/font], [font=Courier New]TUTORIAL_TRIGGER_MOUNT_SET[/font], etc.)
[/list]

[b]Default Ignored Function Patterns[/b] include:
[list]
[*]UI creation functions ([font=Courier New]CreateControl[/font], [font=Courier New]CreateTopLevelWindow[/font], etc.)
[*]Event handlers ([font=Courier New]OnUpdate[/font], [font=Courier New]OnShow[/font], [font=Courier New]OnHide[/font], etc.)
[*]Add-on initialization functions ([font=Courier New]OnAddOnLoaded[/font], etc.)
[*]Other common patterns ([font=Courier New]ZO_WorldMapPins_Manager:AddCustomPin[/font], etc.)
[/list]

You can view the complete lists in-game by using the [font=Courier New]/undefs_list[/font] and [font=Courier New]/undefs_listfunc[/font] commands, or by examining the source code.

[size=5][b]For Add-on Developers[/b][/size]

This tool is especially useful when:
[list]
[*]Developing new add-ons
[*]Debugging existing add-ons
[*]Finding compatibility issues between add-ons
[*]Tracking down performance issues caused by repetitive errors
[/list]

[size=5][b]Credits[/b][/size]

[list]
[*]Original concept by Merlight
[*]Maintained and enhanced by @dack_janiels
[/list]

[size=5][b]License[/b][/size]

DacksUndefinedGlobalsCatcher is not created by, affiliated with, or sponsored by ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.

[size=5][b]Support & Contributions[/b][/size]

If you find a bug or have a feature request, please submit an issue on GitHub. Contributions via pull requests are welcome! 