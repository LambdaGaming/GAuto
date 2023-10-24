if ( SERVER and game.SinglePlayer() ) or CLIENT then
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

	local function KeyPressDown( ply, key )
		if IsFirstTimePredicted() then
			if ply:InVehicle() then
				if key == GetConVar( "GAuto_Control_LockKey" ):GetInt() then
					if CLIENT then
						net.Start( "GAuto_VehicleLock" )
						net.SendToServer()
					else
						GAuto.VehicleLock( nil, ply )
					end
				end
				if key == GetConVar( "GAuto_Control_HornKey" ):GetInt() then
					if CLIENT then
						net.Start( "GAuto_VehicleHorn" )
						net.SendToServer()
					else
						GAuto.VehicleHorn( nil, ply )
					end
				end
				if key == GetConVar( "GAuto_Control_CruiseKey" ):GetInt() then
					if CLIENT then
						net.Start( "GAuto_CruiseControl" )
						net.SendToServer()
					else
						GAuto.CruiseControl( nil, ply )
					end
				end
				if key == GetConVar( "GAuto_Control_EngineKey" ):GetInt() then
					if CLIENT then
						net.Start( "GAuto_EngineToggle" )
						net.SendToServer()
					else
						GAuto.EngineToggle( nil, ply )
					end
				end
				for k,v in pairs( seatbuttons ) do
					if key == v[1] then
						if CLIENT and input.IsKeyDown( GetConVar( "GAuto_Control_EjectModifier" ):GetInt() ) then
							if key == KEY_1 then
								GAuto.Notify( "You can't eject yourself!" )
								return
							end
							if CLIENT then
								net.Start( "GAuto_EjectPassenger" )
								net.WriteInt( v[2], 32 )
								net.SendToServer()
							else
								GAuto.EjectPassenger( nil, ply, v[2] )
							end
						else
							if CLIENT then
								net.Start( "GAuto_ChangeSeats" )
								net.WriteInt( v[2], 32 )
								net.SendToServer()
							else
								GAuto.ChangeSeats( nil, ply, v[2] )
							end
						end
					end
				end
			end
		end
	end
	hook.Add( "PlayerButtonDown", "GAuto_KeyPressDown", KeyPressDown )
	
	local function KeyPressUp( ply, key )
		if IsFirstTimePredicted() then
			if ply:InVehicle() then
				if key == GetConVar( "GAuto_Control_HornKey" ):GetInt() then
					if CLIENT then
						net.Start( "GAuto_VehicleHornStop" )
						net.SendToServer()
					else
						GAuto.VehicleHornStop( nil, ply )
					end
				end
			end
		end
	end
	hook.Add( "PlayerButtonUp", "GAuto_KeyPressUp", KeyPressUp )
end
