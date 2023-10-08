util.AddNetworkString( "GAuto_InitGChroma" )
local function InitGChroma( ply, veh )
	if gchroma then
		if !veh:GetNWBool( "IsGAutoSeat" ) and veh.seat then
			gchroma.ResetDevice( GCHROMA_DEVICE_ALL )
			gchroma.SetDeviceColor( GCHROMA_DEVICE_ALL, Vector( 25, 25, 25 ) )
			gchroma.SetDeviceColorEx( GCHROMA_DEVICE_KEYBOARD, GCHROMA_COLOR_RED, GCHROMA_KEY_1, 0 )
			for k,v in pairs( veh.seat ) do
				local color
				local num = k < 9 and k + 1 or 0
				if IsValid( v:GetDriver() ) then
					color = GCHROMA_COLOR_RED
				else
					color = GCHROMA_COLOR_WHITE
				end
				gchroma.SetDeviceColorEx( GCHROMA_DEVICE_KEYBOARD, color, _G["GCHROMA_KEY_"..num], 0 ) --Seat keys will light up red if they are occupied
			end
			gchroma.SendFunctions( ply )
			net.Start( "GAuto_InitGChroma" ) --Init the rest of the lights client-side for user-specific key binds
			net.Send( ply )
		end
	end
end

local function GChromaEnteredVehicle( ply, veh, role )
	if gchroma then
		if veh:GetNWBool( "IsGAutoSeat" ) then
			local parent = veh:GetParent()
			local driver = parent:GetDriver()
			gchroma.ResetDevice( GCHROMA_DEVICE_ALL )
			if IsValid( driver ) then
				gchroma.SetDeviceColorEx( GCHROMA_DEVICE_KEYBOARD, GCHROMA_COLOR_RED, GCHROMA_KEY_1, 0 )
			else
				gchroma.SetDeviceColorEx( GCHROMA_DEVICE_KEYBOARD, GCHROMA_COLOR_WHITE, GCHROMA_KEY_1, 0 )
			end
			for k,v in pairs( parent.seat ) do
				local color
				local num = k < 9 and k + 1 or 0
				if IsValid( v:GetDriver() ) then
					color = GCHROMA_COLOR_RED
				else
					color = GCHROMA_COLOR_WHITE
				end
				gchroma.SetDeviceColorEx( GCHROMA_DEVICE_KEYBOARD, color, _G["GCHROMA_KEY_"..num], 0 )
			end
			gchroma.SendFunctions( ply )
		else
			InitGChroma( ply, veh )
		end
	end
end
hook.Add( "PlayerEnteredVehicle", "GAuto_GChromaEnteredVehicle", GChromaEnteredVehicle )

local function GChromaLeaveVehicle( ply, ent )
	if gchroma and !ply.IsSwitching then
		if GChroma_PlayerModuleLoaded then
			net.Start( "GChromaPlayerInit" )
			net.Send( ply )
			return
		end
		gchroma.ResetDevice( GCHROMA_DEVICE_ALL )
		gchroma.SendFunctions( ply )
	end
end
hook.Add( "PlayerLeaveVehicle", "GAuto_GChromaLeaveVehicle", GChromaLeaveVehicle )
