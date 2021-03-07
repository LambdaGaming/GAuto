util.AddNetworkString( "AM_InitGChroma" )
local function AM_InitGChroma( ply, veh )
	if gchroma then
		if !veh:GetNWBool( "IsAutomodSeat" ) and veh.seat then
			local tbl = {
				gchroma.ResetDevice( GCHROMA_DEVICE_ALL ),
				gchroma.SetDeviceColor( GCHROMA_DEVICE_ALL, Vector( 25, 25, 25 ) )
			}
			for k,v in pairs( veh.seat ) do
				local color
				if IsValid( v:GetDriver() ) then
					color = GCHROMA_COLOR_RED
				else
					color = GCHROMA_COLOR_WHITE
				end
				table.insert( tbl, gchroma.SetDeviceColorEx( GCHROMA_DEVICE_KEYBOARD, GCHROMA_COLOR_RED, GCHROMA_KEY_1, 0 ) )
				table.insert( tbl, gchroma.SetDeviceColorEx( GCHROMA_DEVICE_KEYBOARD, color, _G["GCHROMA_KEY_"..k + 1], 0 ) ) --Seat keys will light up red if they are occupied
			end
			gchroma.SendFunctions( ply, tbl )
			net.Start( "AM_InitGChroma" ) --Init the rest of the lights client-side to avoid sending an unnecessary amount of net messages
			net.Send( ply )
		end
	end
end

local function AM_GChromaEnteredVehicle( ply, veh, role )
	if gchroma then
		if veh:GetNWBool( "IsAutomodSeat" ) then
			local parent = veh:GetParent()
			local driver = parent:GetDriver()
			if IsValid( driver ) then
				local tbl = {}
				table.insert( tbl, gchroma.SetDeviceColorEx( GCHROMA_DEVICE_KEYBOARD, GCHROMA_COLOR_RED, _G["GCHROMA_KEY_"..veh.ID + 1], 0 ) )
				gchroma.SendFunctions( driver, tbl )
			end
		else
			AM_InitGChroma( ply, veh )
		end
	end
end
hook.Add( "PlayerEnteredVehicle", "AM_GChromaEnteredVehicle", AM_GChromaEnteredVehicle )

local function AM_GChromaLeaveVehicle( ply, ent )
	if gchroma then
		if ent:GetNWBool( "IsAutomodSeat" ) then
			local parent = ent:GetParent()
			local driver = parent:GetDriver()
			if IsValid( driver ) then
				local tbl = { gchroma.SetDeviceColorEx( GCHROMA_DEVICE_KEYBOARD, GCHROMA_COLOR_WHITE, _G["GCHROMA_KEY_"..ent.ID + 1], 0 ) }
				gchroma.SendFunctions( driver, tbl )
			end
		else
			if GChroma_PlayerModuleLoaded then
				net.Start( "GChromaPlayerInit" )
				net.Send( ply )
				return
			end
			local tbl = { gchroma.ResetDevice( GCHROMA_DEVICE_ALL ) }
			gchroma.SendFunctions( ply, tbl )
		end
	end
end
hook.Add( "PlayerLeaveVehicle", "AM_GChromaLeaveVehicle", AM_GChromaLeaveVehicle )
