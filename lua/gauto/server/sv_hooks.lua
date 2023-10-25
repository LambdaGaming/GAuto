local allowedSurfaces = {
	["grass"] = true,
	["dirt"] = true,
	["sand"] = true,
	["snow"] = true
}

local function VehicleThink( ply, veh, mv )
	if GAuto.IsBlackListed( veh ) then return end
	local vel = veh:GetVelocity():Length()
	local GAuto_ParticlesEnabled = GetConVar( "GAuto_Config_ParticlesEnabled" ):GetBool()
	if veh.FuelInit and !veh.NoFuel and IsValid( veh:GetDriver() ) then
		local GAuto_FuelEnabled = GetConVar( "GAuto_Config_FuelEnabled" ):GetBool()
		local GAuto_NoFuelGod = GetConVar( "GAuto_Config_NoFuelGod" ):GetBool()
		local GAuto_FuelLoss = GetConVar( "GAuto_Config_FuelLoss" ):GetFloat()
		if !veh.FuelCooldown then veh.FuelCooldown = 0 end
		if vel > 100 then
			if GAuto_FuelEnabled and !veh:GetNWBool( "IsGAutoSeat" ) and veh.FuelCooldown > CurTime() then
				if veh:GetThrottle() >= 0.1 then
					veh.FuelLoss = GAuto_FuelLoss
				end
				local fuellevel = veh:GetNWInt( "GAuto_FuelAmount" )
				if fuellevel > 0 then
					veh:SetNWInt( "GAuto_FuelAmount", fuellevel - veh.FuelLoss )
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
				local data = util.GetSurfaceData( id )
				if allowedSurfaces[data.name] and vel > 100 then
					veh.particles[i]:Fire( "Start" )
					continue
				end
			end
			veh.particles[i]:Fire( "Stop" )
		end
	end
end
hook.Add( "VehicleMove", "GAuto_VehicleThink", VehicleThink )

local function KeyPressServer( ply, key )
	if ply:InVehicle() then
		local veh = ply:GetVehicle()
		if veh:GetNWBool( "IsGAutoSeat" ) and key == IN_USE then --Fix to get players out of passenger seats. Without this, players will enter the closest passenger seat without a way of getting out
			ply:ExitVehicle()
			ply.GAuto_SeatCooldown = CurTime() + 1
		end
	end
end
hook.Add( "KeyPress", "GAuto_KeyPressServer", KeyPressServer )

local function CanEnterVehicle( ply, veh, role )
	if ply.GAuto_SeatCooldown and ply.GAuto_SeatCooldown > CurTime() and !ply.IsSwitching then
		return false --Cooldown to make sure players don't unlock their car the instant they exit it
	end 
end
hook.Add( "CanPlayerEnterVehicle", "GAuto_CanEnterVehicle", CanEnterVehicle )

local function EnteredVehicle( ply, veh, role )
	if veh:GetNWBool( "IsGAutoSeat" ) then veh:SetCameraDistance( 5 ) end --Sets camera distance relatively close to the default driver's seat distance
end
hook.Add( "PlayerEnteredVehicle", "GAuto_EnteredVehicle", EnteredVehicle )

local function LeaveVehicle( ply, ent )
	ent.GAuto_ExitCooldown = CurTime() + 1
	if GAuto.IsBlackListed( ent ) or ent:GetNWBool( "IsGAutoSeat" ) then return end
	local GAuto_WheelLockEnabled = GetConVar( "GAuto_Config_WheelLockEnabled" ):GetBool()
	local GAuto_BrakeLockEnabled = GetConVar( "GAuto_Config_BrakeLockEnabled" ):GetBool()
	local GAuto_ParticlesEnabled = GetConVar( "GAuto_Config_ParticlesEnabled" ):GetBool()
	if GAuto_BrakeLockEnabled then
		if ply:KeyDown( IN_JUMP ) then --Activates the parking brake if the player is holding the jump button when they exit
			ent:Fire( "HandBrakeOn", "", 0.01 )
			ent:EmitSound( "gauto/brake.mp3" )
		else
			ent:Fire( "HandBrakeOff", "", 0.01 )
		end
	end
	if GAuto_WheelLockEnabled then
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
	if GAuto_ParticlesEnabled and ent.particles then
		local count = ent:GetWheelCount() - 1
		for i = 0, count do
			ent.particles[i]:Fire( "Stop" )
		end
	end
	if ent:GetNWBool( "CruiseActive" ) then
		ent:SetNWBool( "CruiseActive", false )
	end
	if ent.GAuto_CarHorn then ent.GAuto_CarHorn:Stop() end
end
hook.Add( "PlayerLeaveVehicle", "GAuto_LeaveVehicle", LeaveVehicle )

local function PlayerUseVeh( ply, ent )
	if !IsValid( ply ) or GAuto.IsBlackListed( ent ) then return end
	if ent:GetClass() == "prop_vehicle_jeep" then
		local GAuto_SeatsEnabled = GetConVar( "GAuto_Config_SeatsEnabled" ):GetBool()
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
			if GetConVar( "GAuto_Config_DriverSeat" ):GetBool() and !IsValid( ent:GetDriver() ) then
				ply:EnterVehicle( ent )
				return
			end
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
				GAuto.Notify( ply, "All seats in this vehicle are occupied." )
			end
		end
		ply.GAuto_SeatCooldown = CurTime() + 1 --Prevents players from sometimes teleporting to the last detected seat instead of the first
	end
end
hook.Add( "PlayerUse", "GAuto_PlayerUseVeh", PlayerUseVeh )

local function Lockpick( ply, ent, trace )
	local GAuto_AlarmEnabled = GetConVar( "GAuto_Config_LockAlarmEnabled" ):GetBool()
	if !GAuto_AlarmEnabled or GAuto.IsBlackListed( ent ) then return end
	if ent:IsVehicle() and ent:GetClass() == "prop_vehicle_jeep" then
		ent:EmitSound( "gauto/alarm.mp3" )
	end
end
hook.Add( "lockpickStarted", "GAuto_Lockpick", Lockpick )

local function LockpickFinish( ply, success, ent )
	local GAuto_AlarmEnabled = GetConVar( "GAuto_Config_LockAlarmEnabled" ):GetBool()
	if !GAuto_AlarmEnabled or GAuto.IsBlackListed( ent ) then return end
	if ent:IsVehicle() and ent:GetClass() == "prop_vehicle_jeep" then
		if success then
			ent:SetNWBool( "GAuto_DoorsLocked", false )
			ent:SetNWEntity( "GAuto_LockOwner", nil )
		end
	end
end
hook.Add( "onLockpickCompleted", "GAuto_LockpickFinish", LockpickFinish )

local function CruiseThink()
	for k,v in ipairs( ents.FindByClass( "prop_vehicle_jeep*" ) ) do
		if GAuto.IsBlackListed( v ) then return end
		if v:GetNWBool( "CruiseActive" ) then
			v:SetThrottle( v:GetNWInt( "CruiseSpeed" ) )
		end
	end
end
hook.Add( "Think", "GAuto_CruiseThink", CruiseThink )

local function CruiseController( ply, key )
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
end
hook.Add( "KeyPress", "GAuto_CruiseController", CruiseController )
