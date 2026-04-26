local allowedSurfaces = {
	["grass"] = true,
	["dirt"] = true,
	["sand"] = true,
	["snow"] = true,
	["antlionsand"] = true
}

hook.Add( "VehicleMove", "GAuto_VehicleThink", function( ply, veh, mv )
	if GAuto.IsBlackListed( veh ) then return end
	local vel = veh:GetVelocity():Length()
	local GAuto_ParticlesEnabled = cvars.Bool( "gauto_particles_enabled" )
	if veh.FuelInit and !veh.NoFuel and IsValid( veh:GetDriver() ) then
		local GAuto_FuelEnabled = cvars.Bool( "gauto_fuel_enabled" )
		local GAuto_NoFuelGod = cvars.Bool( "gauto_no_fuel_god" )
		local GAuto_FuelLoss = cvars.Number( "gauto_fuel_loss_rate" )
		if vel > 100 then
			if GAuto_FuelEnabled and !veh:GetNWBool( "IsGAutoSeat" ) and veh.FuelCooldown < CurTime() then
				if veh:GetThrottle() >= 0.1 then
					veh.FuelLoss = GAuto_FuelLoss
				end
				local fuelLevel = veh:GetNWInt( "GAuto_FuelAmount" )
				if fuelLevel > 0 then
					veh:SetNWInt( "GAuto_FuelAmount", fuelLevel - veh.FuelLoss )
					veh.FuelCooldown = CurTime() + 5
					veh.NoFuel = false
				else
					local rand = math.random( 1, 3 )
					if GAuto_NoFuelGod then
						GAuto.ToggleGodMode( veh )
					end
					veh:Fire( "turnoff", "", 0.01 )
					veh:EmitSound( "ambient/materials/cartrap_rope"..rand..".wav" )
					veh.NoFuel = true
					GAuto.Notify( ply, "Your vehicle has run out of fuel!" )
				end
			end
		end
	end
	if GAuto_ParticlesEnabled and veh.particles then
		local count = veh:GetWheelCount() - 1
		for i = 0, count do
			local pos, id, ground = veh:GetWheelContactPoint( i )
			if ground then
				local name = util.GetSurfacePropName( id )
				if allowedSurfaces[name] and vel > 100 then
					veh.particles.wheel[i]:Fire( "Start" )
					continue
				end
			end
			veh.particles.wheel[i]:Fire( "Stop" )
		end
	end
end )

hook.Add( "KeyPress", "GAuto_KeyPressServer", function( ply, key )
	if ply:InVehicle() then
		local veh = ply:GetVehicle()
		if veh:GetNWBool( "IsGAutoSeat" ) and key == IN_USE then
			--Without this, players will enter the closest passenger seat without a way of getting out
			ply:ExitVehicle()
			ply.GAuto_SeatCooldown = CurTime() + 1
		end
	end
end )

hook.Add( "CanPlayerEnterVehicle", "GAuto_CanEnterVehicle", function( ply, veh, role )
	if ply.GAuto_SeatCooldown and ply.GAuto_SeatCooldown > CurTime() and !ply.IsSwitching then
		return false --Cooldown to make sure players don't unlock their car the instant they exit it
	end 
end )

hook.Add( "PlayerEnteredVehicle", "GAuto_EnteredVehicle", function( ply, veh, role )
	--Sets camera distance relatively close to the default driver's seat distance
	if veh:GetNWBool( "IsGAutoSeat" ) then veh:SetCameraDistance( 5 ) end
end )

hook.Add( "PlayerLeaveVehicle", "GAuto_LeaveVehicle", function( ply, ent )
	ent.GAuto_ExitCooldown = CurTime() + 1
	if GAuto.IsBlackListed( ent ) or ent:GetNWBool( "IsGAutoSeat" ) then return end
	local GAuto_WheelLockEnabled = cvars.Bool( "gauto_wheel_lock_enabled" )
	local GAuto_BrakeLockEnabled = cvars.Bool( "gauto_brake_lock_enabled" )
	local GAuto_ParticlesEnabled = cvars.Bool( "gauto_particles_enabled" )
	if GAuto_BrakeLockEnabled then
		if ply:KeyDown( IN_JUMP ) then --Activates the parking brake if the player is holding the jump button when they exit
			ent:Fire( "HandBrakeOn", "", 0.01 )
			ent:EmitSound( "gauto/brake.mp3" )
		else
			ent:Fire( "HandBrakeOff", "", 0.01 )
		end
	end
	if GAuto_WheelLockEnabled and ent:GetClass() == "prop_vehicle_jeep" then
		if ply:KeyDown( IN_MOVERIGHT ) then
			ent:SetSteering( 1, 1 )
		elseif ply:KeyDown( IN_MOVELEFT ) then
			ent:SetSteering( -1, 1 )
		else
			ent:SetSteering( 0, 0 )
		end
	end
	if GAuto_ParticlesEnabled and ent.particles then
		local count = ent:GetWheelCount() - 1
		for i = 0, count do
			ent.particles.wheel[i]:Fire( "Stop" )
		end
	end
	if ent:GetNWBool( "CruiseActive" ) then
		ent:SetNWBool( "CruiseActive", false )
	end
	if ent.GAuto_CarHorn then ent.GAuto_CarHorn:Stop() end
end )

hook.Add( "PlayerUse", "GAuto_PlayerUseVeh", function( ply, ent )
	if !IsValid( ply ) or !GAuto.IsDrivable( ent ) or GAuto.IsBlackListed( ent ) then return end
	local GAuto_SeatsEnabled = cvars.Bool( "gauto_seats_enabled" )
	if ent.GAuto_ExitCooldown and ent.GAuto_ExitCooldown > CurTime() then return end
	if ent:GetNWBool( "GAuto_DoorsLocked" ) then
		if ent:GetNWEntity( "GAuto_LockOwner" ) == ply then
			ent:Fire( "Unlock", "", 0.01 )
			ent:SetNWBool( "GAuto_DoorsLocked", false )
			ent:SetNWEntity( "GAuto_LockOwner", nil )
			GAuto.Notify( ply, "Vehicle unlocked." )
		else
			if ent.LockedNotifyCooldown and ent.LockedNotifyCooldown > CurTime() then return end
			GAuto.Notify( ply, "This vehicle is locked." )
			ent.LockedNotifyCooldown = CurTime() + 1
		end
	end
	if !ent:GetNWBool( "GAuto_DoorsLocked" ) and GAuto_SeatsEnabled then
		if ply:InVehicle() or !ent.seat then return end
		if cvars.Bool( "gauto_driver_seat" ) and !IsValid( ent:GetDriver() ) then
			ply:EnterVehicle( ent )
			return
		end
		local seatList = { ent } --Throw the driver's seat in with the passenger seats in case the vehicle doesn't have a driver
		local foundSeat = false
		for k,v in pairs( ent.seat ) do
			table.insert( seatList, v ) --Probably not the best method but it works and I don't see a drop in performance so it's good enough
		end
		table.sort( seatList, function( a, b ) return ply:WorldToLocal( a:GetPos() ):Length() < ply:WorldToLocal( b:GetPos() ):Length() end )
		for i = 1, #seatList do
			if IsValid( seatList[i] ) and !IsValid( seatList[i]:GetDriver() ) then --Make sure the closest seat doesn't have a driver, and if it does, pick the next closest seat
				ply:EnterVehicle( seatList[i] )
				foundSeat = true
				break
			end
		end
		if !foundSeat then
			GAuto.Notify( ply, "All seats in this vehicle are taken." )
		end
	end
	ply.GAuto_SeatCooldown = CurTime() + 1 --Prevents players from sometimes teleporting to the last detected seat instead of the first
end )

hook.Add( "Think", "GAuto_CruiseThink", function()
	for k,v in ipairs( ents.FindByClass( "prop_vehicle_*" ) ) do
		if GAuto.IsBlackListed( v ) then return end
		if v:GetNWBool( "CruiseActive" ) then
			v:SetThrottle( v:GetNWInt( "CruiseSpeed" ) )
		end
	end
end )

hook.Add( "KeyPress", "GAuto_CruiseController", function( ply, key )
	if !IsFirstTimePredicted() or !ply:InVehicle() then return end
	local veh = ply:GetVehicle()
	if GAuto.IsBlackListed( veh ) then return end
	if veh:GetNWBool( "CruiseActive" ) then
		local speed = veh:GetNWInt( "CruiseSpeed" )
		if key == IN_JUMP then
			veh:SetNWBool( "CruiseActive", false )
			veh:SetNWInt( "CruiseSpeed", 0 )
			GAuto.Notify( ply, "Cruise control is now disabled." )
		end
		if key == IN_FORWARD then
			veh:SetNWInt( "CruiseSpeed", math.Clamp( speed + 0.10, 0.05, 1 ) )
		end
		if key == IN_BACK then
			veh:SetNWInt( "CruiseSpeed", math.Clamp( speed - 0.10, 0.05, 1 ) )
		end
	end
end )

--Prevent seat changing and ejection in Photon 2 vehicles due to control conflicts
local function Photon2NoSeatChange( ply, veh, seat )
	local controller = veh:GetNW2Entity( "Photon2:Controller" )
	if IsValid( controller ) then
		return false
	end
end
hook.Add( "GAuto_CanChangeSeats", "Photon2_GAuto_SeatChange", Photon2NoSeatChange )
hook.Add( "GAuto_CanEjectPassenger", "Photon2_GAuto_Eject", Photon2NoSeatChange )

--DarkRP stuff
hook.Add( "lockpickStarted", "DarkRP_GAuto_Lockpick", function( ply, ent, tr )
	local GAuto_AlarmEnabled = cvars.Bool( "gauto_lock_alarm_enabled" )
	if !GAuto_AlarmEnabled or GAuto.IsBlackListed( ent ) or !GAuto.IsDrivable( ent ) then return end
	ent:EmitSound( "gauto/alarm.mp3" )
end )

hook.Add( "onLockpickCompleted", "DarkRP_GAuto_LockpickFinish", function( ply, success, ent )
	local GAuto_AlarmEnabled = cvars.Bool( "gauto_lock_alarm_enabled" )
	if GAuto_AlarmEnabled and GAuto.IsDrivable( ent ) and success then
		ent:SetNWBool( "GAuto_DoorsLocked", false )
		ent:SetNWEntity( "GAuto_LockOwner", nil )
	end
end )

hook.Add( "onKeysLocked", "DarkRP_GAuto_KeysLocked", function( ent )
	if GAuto.IsBlackListed( ent ) then return end
	ent:SetNWBool( "GAuto_DoorsLocked", true )
end )

hook.Add( "onKeysUnlocked", "DarkRP_GAuto_KeysUnlocked", function( ent )
	if GAuto.IsBlackListed( ent ) then return end
	ent:SetNWBool( "GAuto_DoorsLocked", false )
end )

--Eject passengers when battering ram is used on vehicle
hook.Add( "onDoorRamUsed", "DarkRP_GAuto_DoorRam", function( success, ply, tr )
	local ent = tr.Entity
	if !success or !IsValid( ent ) or !ent.seat then return end
	for k,v in pairs( ent.seat ) do
		local passenger = v:GetDriver()
		if IsValid( passenger ) then
			passenger:ExitVehicle()
		end
	end
end )
