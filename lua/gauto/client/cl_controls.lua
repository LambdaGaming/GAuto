CreateClientConVar( "GAuto_Control_HornKey", KEY_J, true, false, "Sets the key for the horn." )
CreateClientConVar( "GAuto_Control_LockKey", KEY_N, true, false, "Sets the key for locking the doors." )
CreateClientConVar( "GAuto_Control_CruiseKey", KEY_V, true, false, "Sets the key for toggling cruise control." )
CreateClientConVar( "GAuto_Control_EngineKey", KEY_P, true, false, "Sets the key for toggling the engine." )
CreateClientConVar( "GAuto_Control_EjectModifier", KEY_LALT, true, false, "Sets the modifier key that needs to be held while pressing a number key to kick a passenger out." )
CreateClientConVar( "GAuto_Config_CruiseMPH", 1, true, false, "Enable or disable displaying cruise speed in MPH. Disable to set to KPH." )

local function ControlMenu()
	spawnmenu.AddToolMenuOption( "Options", "GAuto", "GAutoControls", "Controls", "", "", function( panel )
		panel:AddControl( "Header", { --This is deprecated but all default gmod tools still use it?
			Description = "Change your GAuto controls here."
		} )
		panel:AddControl( "Numpad", {
			Label = "Horn Key",
			Command = "GAuto_Control_HornKey",
			Label2 = "Lock Key",
			Command2 = "GAuto_Control_LockKey"
		} )
		panel:AddControl( "Numpad", {
			Label = "Cruise Control Key",
			Command = "GAuto_Control_CruiseKey",
			Label2 = "Engine Toggle Key",
			Command2 = "GAuto_Control_EngineKey"
		} )
		panel:AddControl( "Numpad", {
			Label = "Eject Modifier Key",
			Command = "GAuto_Control_EjectModifier"
		} )
		panel:CheckBox( "Cruise Control: Display in MPH", "GAuto_Config_CruiseMPH" )
	end )
end
hook.Add( "PopulateToolMenu", "GAuto_ControlMenu", ControlMenu )
