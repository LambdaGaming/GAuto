if ( SERVER and game.SinglePlayer() ) or CLIENT then
	local seatbuttons = {
		[KEY_1] = 1,
		[KEY_2] = 2,
		[KEY_3] = 3,
		[KEY_4] = 4,
		[KEY_5] = 5,
		[KEY_6] = 6,
		[KEY_7] = 7,
		[KEY_8] = 8,
		[KEY_9] = 9,
		[KEY_0] = 10
	}

	hook.Add( "PlayerButtonDown", "GAuto_KeyPressDown", function( ply, key )
		if IsFirstTimePredicted() and ply:InVehicle() then
			if key == cvars.Number( "gauto_lock_key" ) then
				if CLIENT then
					net.Start( "GAuto_VehicleLock" )
					net.SendToServer()
				else
					GAuto.VehicleLock( nil, ply )
				end
			elseif key == cvars.Number( "gauto_horn_key" ) then
				if CLIENT then
					net.Start( "GAuto_VehicleHorn" )
					net.SendToServer()
				else
					GAuto.VehicleHorn( nil, ply )
				end
			elseif key == cvars.Number( "gauto_cruise_key" ) then
				if CLIENT then
					net.Start( "GAuto_CruiseControl" )
					net.SendToServer()
				else
					GAuto.CruiseControl( nil, ply )
				end
			elseif key == cvars.Number( "gauto_engine_key" ) then
				if CLIENT then
					net.Start( "GAuto_EngineToggle" )
					net.SendToServer()
				else
					GAuto.EngineToggle( nil, ply )
				end
			elseif seatbuttons[key] then
				if CLIENT and input.IsKeyDown( cvars.Number( "gauto_eject_modifier" ) ) then
					if key == KEY_1 then
						GAuto.Notify( "You can't eject yourself!" )
						return
					end
					net.Start( "GAuto_EjectPassenger" )
					net.WriteInt( seatbuttons[key], 32 )
					net.SendToServer()
				else
					if CLIENT then
						net.Start( "GAuto_ChangeSeats" )
						net.WriteInt( seatbuttons[key], 32 )
						net.SendToServer()
					else
						GAuto.ChangeSeats( nil, ply, seatbuttons[key] )
					end
				end
			end
		end
	end )
	
	hook.Add( "PlayerButtonUp", "GAuto_KeyPressUp", function( ply, key )
		if IsFirstTimePredicted() and ply:InVehicle() then
			if key == cvars.Number( "gauto_horn_key" ) then
				if CLIENT then
					net.Start( "GAuto_VehicleHornStop" )
					net.SendToServer()
				else
					GAuto.VehicleHornStop( nil, ply )
				end
			end
		end
	end )
end
