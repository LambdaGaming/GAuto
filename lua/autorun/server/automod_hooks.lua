
local AM_FuelEnabled = GetConVar( "AM_Config_FuelEnabled" ):GetBool()
local AM_NoFuelGod = GetConVar( "AM_Config_NoFuelGod" ):GetBool()
local AM_WheelLockEnabled = GetConVar( "AM_Config_WheelLockEnabled" ):GetBool()
local AM_SeatsEnabled = GetConVar( "AM_Config_SeatsEnabled" ):GetBool()
local AM_AlarmEnabled = GetConVar( "AM_Config_LockAlarmEnabled" ):GetBool()
local AM_BrakeLockEnabled = GetConVar( "AM_Config_BrakeLockEnabled" ):GetBool()

local function AM_VehicleThink( ply, veh, mv )
	if IsValid( veh ) then
		if IsBlacklisted( veh ) then return end
		local vel = veh:GetVelocity():Length()
		if !veh.FuelInit or veh.NoFuel or !IsValid( veh:GetDriver() ) then return end
		if !veh.FuelCooldown then veh.FuelCooldown = 0 end

		if vel > 100 and veh:GetThrottle() >= 0.1 then
			veh.FuelLoss = 0.5
		end

		if vel > 100 then
			local wheelpopped = veh:GetNWInt( "AM_WheelPopped" )
			if wheelpopped > 0 then
				local maxdamping = math.Clamp( veh:GetWheel( wheelpopped ):GetDamping() + 0.01, 0, 40 ) --Simulates tire slowly losing air
				veh:GetWheel( wheelpopped ):SetDamping( maxdamping, maxdamping )
			end

			if AM_FuelEnabled and !veh:GetNWBool( "IsAutomodSeat" ) then
				if veh.FuelCooldown and veh.FuelCooldown > CurTime() then return end
				local fuellevel = veh:GetNWInt( "AM_FuelAmount" )
				if fuellevel > 0 then
					veh:SetNWInt( "AM_FuelAmount", fuellevel - veh.FuelLoss )
					veh.FuelCooldown = CurTime() + 5
					veh.NoFuel = false
				else
					if AM_NoFuelGod then
						AM_ToggleGodMode( veh )
					end
					veh:Fire( "turnoff", "", 0.01 )
					veh:EmitSound( "ambient/materials/cartrap_rope"..math.random( 1, 3 )..".wav" )
					veh.NoFuel = true
					AM_Notify( ply, "Your vehicle has run out of fuel!" )
				end
			end
		end
	end
end
hook.Add( "VehicleMove", "AM_VehicleThink", AM_VehicleThink )

local function AM_KeyPressServer( ply, key )
	if ply:InVehicle() then
		local veh = ply:GetVehicle()
		if veh:GetNWBool( "IsAutomodSeat" ) and key == IN_USE then --Fix to get players out of passenger seats. Without this, players will enter the closest passenger seat without a way of getting out
			ply:ExitVehicle()
			ply.AM_SeatCooldown = CurTime() + 1
		end
	end
end
hook.Add( "KeyPress", "AM_KeyPressServer", AM_KeyPressServer )

local function AM_CanEnterVehicle( ply, veh, role )
	if ply.AM_SeatCooldown and ply.AM_SeatCooldown > CurTime() and !ply.IsSwitching then
		return false --Cooldown to make sure players don't unlock their car the instant they exit it
	end 
end
hook.Add( "CanPlayerEnterVehicle", "AM_CanEnterVehicle", AM_CanEnterVehicle )

local function AM_EnteredVehicle( ply, veh, role )
	if veh:GetNWBool( "IsAutomodSeat" ) then veh:SetCameraDistance( 5 ) end --Sets camera distance relatively close to the default driver's seat distance
end
hook.Add( "PlayerEnteredVehicle", "AM_EnteredVehicle", AM_EnteredVehicle )

local function AM_LeaveVehicle( ply, ent )
	ent.AM_ExitCooldown = CurTime() + 1
	if IsBlacklisted( ent ) or ent:GetNWBool( "IsAutomodSeat" ) then return end
	if AM_BrakeLockEnabled then
		if ply:KeyDown( IN_JUMP ) then --Activates the parking brake if the player is holding the jump button when they exit
			ent:Fire( "HandBrakeOn", "", 0.01 )
			ent:EmitSound( "automod/brake.mp3" )
		else
			ent:Fire( "HandBrakeOff", "", 0.01 )
		end
	end
	if AM_WheelLockEnabled then
		local steering = ent:GetSteering()
		timer.Simple( 0.01, function() --Small timer because it otherwise won't register
			if !IsValid( ent ) then return end
			if steering == 1 then
				ent:SetSteering( 1, 1 )
			elseif steering == -1 then
				ent:SetSteering( -1, 1 )
			elseif steering == 0 then
				ent:SetSteering( 0, 0 )
			end
		end )
	end
	if ent:GetNWBool( "CruiseActive" ) then
		ent:SetNWBool( "CruiseActive", false )
	end
end
hook.Add( "PlayerLeaveVehicle", "AM_LeaveVehicle", AM_LeaveVehicle )

local function AM_PlayerUseVeh( ply, ent )
	if !IsValid( ply ) or !IsValid( ent ) then return end
	if IsBlacklisted( ent ) then return end
	if ent:GetClass() == "prop_vehicle_jeep" then
		if ent.AM_ExitCooldown and ent.AM_ExitCooldown > CurTime() then return end
		if ent:GetNWBool( "AM_DoorsLocked" ) then
			if ent:GetNWEntity( "AM_LockOwner" ) == ply then
				ent:Fire( "Unlock", "", 0.01 )
				ent:SetNWBool( "AM_DoorsLocked", false )
				ent:SetNWEntity( "AM_LockOwner", nil )
				AM_Notify( ply, "Vehicle unlocked." )
			else
				if ent.LockedNotifyCooldown and ent.LockedNotifyCooldown > CurTime() then return end
				AM_Notify( ply, "This vehicle is locked." )
				ent.LockedNotifyCooldown = CurTime() + 1
			end
		end
		if !ent:GetNWBool( "AM_DoorsLocked" ) and AM_SeatsEnabled then
			if ply:InVehicle() or !ent.seat then return end
			local starttime = CurTime()
			local seatlist = { ent } --Throw the driver's seat in with the passenger seats incase the vehicle doesn't have a driver
			local foundseat = false
			for k,v in pairs( ent.seat ) do
				table.insert( seatlist, v ) --FINALLY found a better working method, probably not the best but it works and I don't see a drop in performance so it's good enough
			end
			table.sort( seatlist, function( a, b ) return ply:WorldToLocal( a:GetPos() ):Length() < ply:WorldToLocal( b:GetPos() ):Length() end )
			for i = 1, #seatlist do
				if IsValid( seatlist[i] ) and !IsValid( seatlist[i]:GetDriver() ) then --Make sure the closest seat doesn't have a driver, and if it does, pick the next closest seat
					ply:EnterVehicle( seatlist[i] )
					foundseat = true
					break
				end
			end
			if !foundseat then
				AM_Notify( ply, "All seats in this vehicle are occupied." )
			end
		end
		ply.AM_SeatCooldown = CurTime() + 1 --Prevents players from sometimes teleporting to the last detected seat instead of the first
	end
end
hook.Add( "PlayerUse", "AM_PlayerUseVeh", AM_PlayerUseVeh )

local function AM_Lockpick( ply, ent, trace )
	if !AM_AlarmEnabled then return end
	if IsBlacklisted( ent ) then return end
	if ent:IsVehicle() and ent:GetClass() == "prop_vehicle_jeep" then
		ent:EmitSound( "automod/alarm.mp3" )
	end
end
hook.Add( "lockpickStarted", "AM_Lockpick", AM_Lockpick )

local function AM_LockpickFinish( ply, success, ent )
	if !AM_AlarmEnabled then return end
	if IsBlacklisted( ent ) then return end
	if ent:IsVehicle() and ent:GetClass() == "prop_vehicle_jeep" then
		if success then
			ent:SetNWBool( "AM_DoorsLocked", false )
			ent:SetNWEntity( "AM_LockOwner", nil )
		end
	end
end
hook.Add( "onLockpickCompleted", "AM_LockpickFinish", AM_LockpickFinish )

local function AM_CruiseThink()
	for k,v in pairs( ents.FindByClass( "prop_vehicle_jeep" ) ) do
		if !IsValid( v ) then return end
		if v:GetNWBool( "CruiseActive" ) then
			v:SetThrottle( v.CruiseSpeed )
		end
	end
end
hook.Add( "Think", "AM_CruiseThink", AM_CruiseThink )

local function AM_CruiseController( ply, key )
	if !IsFirstTimePredicted() then return end
	if ply:InVehicle() then
		local veh = ply:GetVehicle()
		if veh:GetNWBool( "CruiseActive" ) then
			if key == IN_JUMP then
				veh:SetNWBool( "CruiseActive", false )
				AM_Notify( ply, "Cruise control is now disabled." )
			end
			if key == IN_FORWARD then
				veh.CruiseSpeed = math.Clamp( veh.CruiseSpeed + 0.10, 0.05, 1 )
			end
			if key == IN_BACK then
				veh.CruiseSpeed = math.Clamp( veh.CruiseSpeed - 0.10, 0.05, 1 )
			end
		end
	end
end
hook.Add( "KeyPress", "AM_CruiseController", AM_CruiseController )
