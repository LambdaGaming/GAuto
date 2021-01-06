util.AddNetworkString( "AM_InitGChroma" )
local function AM_InitGChroma( ply, veh )
	if GChroma_Loaded then
		if !veh:GetNWBool( "IsAutomodSeat" ) and veh.seat then
			local tbl = {}
			table.insert( tbl, GChroma_ResetDevice( GCHROMA_DEVICE_ALL ) )
			table.insert( tbl, GChroma_SetDeviceColor( GCHROMA_DEVICE_ALL, Vector( 25, 25, 25 ) ) )
			for k,v in pairs( veh.seat ) do
				local color
				if IsValid( v:GetDriver() ) then
					color = GCHROMA_COLOR_RED
				else
					color = GCHROMA_COLOR_WHITE
				end
				table.insert( tbl, GChroma_SetDeviceColorEx( GCHROMA_DEVICE_KEYBOARD, GCHROMA_COLOR_RED, GCHROMA_KEY_1, 0 ) )
				table.insert( tbl, GChroma_SetDeviceColorEx( GCHROMA_DEVICE_KEYBOARD, color, _G["GCHROMA_KEY_"..k + 1], 0 ) ) --Seat keys will light up red if they are occupied
			end
			GChroma_SendFunctions( ply, tbl )
			net.Start( "AM_InitGChroma" ) --Init the rest of the lights client-side to avoid sending an unnecessary amount of net messages
			net.Send( ply )
		end
	end
end

local function AM_GChromaEnteredVehicle( ply, veh, role )
	if GChroma_Loaded then
		if veh:GetNWBool( "IsAutomodSeat" ) then
			local parent = veh:GetParent()
			local driver = parent:GetDriver()
			if IsValid( driver ) and GChroma_Loaded then
				local tbl = {}
				table.insert( tbl, GChroma_SetDeviceColorEx( GCHROMA_DEVICE_KEYBOARD, GCHROMA_COLOR_RED, _G["GCHROMA_KEY_"..veh.ID + 1], 0 ) )
				GChroma_SendFunctions( driver, tbl )
			end
		else
			AM_InitGChroma( ply, veh )
		end
	end
end
hook.Add( "PlayerEnteredVehicle", "AM_GChromaEnteredVehicle", AM_GChromaEnteredVehicle )

local function AM_GChromaLeaveVehicle( ply, ent )
	if GChroma_Loaded then
		if ent:GetNWBool( "IsAutomodSeat" ) then
			local parent = ent:GetParent()
			local driver = parent:GetDriver()
			if IsValid( driver ) and GChroma_Loaded then
				local tbl = {}
				table.insert( tbl, GChroma_SetDeviceColorEx( GCHROMA_DEVICE_KEYBOARD, GCHROMA_COLOR_WHITE, _G["GCHROMA_KEY_"..ent.ID + 1], 0 ) )
				GChroma_SendFunctions( driver, tbl )
			end
		else
			if GChroma_PlayerModule_Loaded then
				net.Start( "GChromaPlayerInit" )
				net.Send( ply )
				return
			end
			local tbl = {}
			table.insert( tbl, GChroma_ResetDevice( GCHROMA_DEVICE_ALL ) )
			GChroma_SendFunctions( ply, tbl )
		end
	end
end
hook.Add( "PlayerLeaveVehicle", "AM_GChromaLeaveVehicle", AM_GChromaLeaveVehicle )
