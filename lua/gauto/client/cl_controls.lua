CreateClientConVar( "gauto_horn_key", KEY_J, true, false, "Sets the key for the horn." )
CreateClientConVar( "gauto_lock_key", KEY_N, true, false, "Sets the key for locking the doors." )
CreateClientConVar( "gauto_cruise_key", KEY_V, true, false, "Sets the key for toggling cruise control." )
CreateClientConVar( "gauto_engine_key", KEY_P, true, false, "Sets the key for toggling the engine." )
CreateClientConVar( "gauto_eject_modifier", KEY_LALT, true, false, "Sets the modifier key that needs to be held while pressing a number key to kick a passenger out." )
CreateClientConVar( "gauto_hud_mph", 1, true, false, "Enable or disable displaying speed on the HUD in MPH. Disable to set to KPH." )
CreateClientConVar( "gauto_disable_hud", 0, true, false, "Prevents the HUD from rendering if enabled." )

--Spawn menu category icon
list.Set( "ContentCategoryIcons", "GAuto", "icon16/car.png" )

hook.Add( "PopulateToolMenu", "GAuto_ControlMenu", function()
	spawnmenu.AddToolMenuOption( "Options", "GAuto", "GAutoControls", "Controls", "", "", function( panel )
		panel:AddControl( "Header", { --This is deprecated but all default gmod tools still use it?
			Description = "Change your GAuto controls here."
		} )
		panel:AddControl( "Numpad", {
			Label = "Horn Key",
			Command = "gauto_horn_key",
			Label2 = "Lock Key",
			Command2 = "gauto_lock_key"
		} )
		panel:AddControl( "Numpad", {
			Label = "Cruise Control Key",
			Command = "gauto_cruise_key",
			Label2 = "Engine Toggle Key",
			Command2 = "gauto_engine_key"
		} )
		panel:AddControl( "Numpad", {
			Label = "Eject Modifier Key",
			Command = "gauto_eject_modifier"
		} )
		panel:CheckBox( "Display speed on HUD in MPH", "gauto_hud_mph" )
	end )
end )
