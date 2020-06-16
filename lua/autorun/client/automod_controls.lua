
CreateClientConVar( "AM_Control_HornKey", KEY_H, true, false, "Sets the key for the horn." )
CreateClientConVar( "AM_Control_LockKey", KEY_N, true, false, "Sets the key for locking the doors." )
CreateClientConVar( "AM_Control_CruiseKey", KEY_B, true, false, "Sets the key for toggling cruise control." )
CreateClientConVar( "AM_Control_EngineKey", KEY_P, true, false, "Sets the key for toggling the engine." )
CreateClientConVar( "AM_Control_EjectModifier", KEY_LALT, true, false, "Sets the modifier key that needs to be held while pressing a number key to kick a passenger out." )
CreateClientConVar( "AM_Config_CruiseMPH", 1, true, false, "Enable or disable displaying cruise speed in MPH. Disable to set to KPH." )

local function AM_ControlMenu()
	spawnmenu.AddToolMenuOption( "Options", "Automod", "AutomodControls", "Controls", "", "", function( panel )
		panel:AddControl( "Header", { --This is deprecated but all default gmod tools still use it?
			Description = "Change your Automod controls here."
		} )
		panel:AddControl( "Numpad", {
			Label = "Horn Key",
			Command = "AM_Control_HornKey",
			Label2 = "Lock Key",
			Command2 = "AM_Control_LockKey"
		} )
		panel:AddControl( "Numpad", {
			Label = "Cruise Control Key",
			Command = "AM_Control_CruiseKey",
			Label2 = "Engine Toggle Key",
			Command2 = "AM_Control_EngineKey"
		} )
		panel:AddControl( "Numpad", {
			Label = "Eject Modifier Key",
			Command = "AM_Control_EjectModifier"
		} )
		panel:CheckBox( "Cruise Control: Display in MPH", "AM_Config_CruiseMPH" )
	end )
end
hook.Add( "PopulateToolMenu", "AM_ControlMenu", AM_ControlMenu )

local seatbuttons = {
	{ KEY_1, 1 },
	{ KEY_2, 2 },
	{ KEY_3, 3 },
	{ KEY_4, 4 },
	{ KEY_5, 5 },
	{ KEY_6, 6 },
	{ KEY_7, 7 },
	{ KEY_8, 8 },
	{ KEY_9, 9 },
	{ KEY_0, 10 }
}

local function AM_KeyPressDown( ply, key )
	if IsFirstTimePredicted() then
		if ply:InVehicle() then
			if key == GetConVar( "AM_Control_LockKey" ):GetInt() then
				net.Start( "AM_VehicleLock" )
				net.SendToServer()
			end
			if key == GetConVar( "AM_Control_HornKey" ):GetInt() then
				net.Start( "AM_VehicleHorn" )
				net.SendToServer()
			end
			if key == GetConVar( "AM_Control_CruiseKey" ):GetInt() then
				net.Start( "AM_CruiseControl" )
				net.SendToServer()
			end
			if key == GetConVar( "AM_Control_EngineKey" ):GetInt() then
				net.Start( "AM_EngineToggle" )
				net.SendToServer()
			end
			for k,v in pairs( seatbuttons ) do
				if key == v[1] then
					if input.IsKeyDown( GetConVar( "AM_Control_EjectModifier" ):GetInt() ) then
						if key == KEY_1 then
							AM_Notify( "You can't eject yourself!" )
							return
						end
						net.Start( "AM_EjectPassenger" )
						net.WriteInt( v[2], 32 )
						net.SendToServer()
					else
						net.Start( "AM_ChangeSeats" )
						net.WriteInt( v[2], 32 )
						net.SendToServer()
					end
				end
			end
		end
	end
end
hook.Add( "PlayerButtonDown", "AM_KeyPressDown", AM_KeyPressDown )

local function AM_KeyPressUp( ply, key )
	if IsFirstTimePredicted() then
		if ply:InVehicle() then
			if key == GetConVar( "AM_Control_HornKey" ):GetInt() then
				net.Start( "AM_VehicleHornStop" )
				net.SendToServer() --Not sure if this the most optimised way to do this
			end
		end
	end
end
hook.Add( "PlayerButtonUp", "AM_KeyPressUp", AM_KeyPressUp )
