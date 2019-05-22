
--Health and damage convars
local AM_HealthEnabled = GetConVar( "AM_Config_HealthEnabled" ):GetBool()
local AM_BulletDamageEnabled = GetConVar( "AM_Config_BulletDamageEnabled" ):GetBool()
local AM_ExplosionEnabled = GetConVar( "AM_Config_DamageExplosionEnabled" ):GetBool()
local AM_ExplodeRemoveEnabled = GetConVar( "AM_Config_ExplodeRemoveEnabled" ):GetBool()
local AM_ExplodeRemoveTime = GetConVar( "AM_Config_ExplodeRemoveTime" ):GetInt()

--All other convars
local AM_WheelLockEnabled = GetConVar( "AM_Config_WheelLockEnabled" ):GetBool()
local AM_DoorLockEnabled = GetConVar( "AM_Config_LockEnabled" ):GetBool()
local AM_BrakeLockEnabled = GetConVar( "AM_Config_BrakeLockEnabled" ):GetBool()
local AM_SeatsEnabled = GetConVar( "AM_Config_SeatsEnabled" ):GetBool()
local AM_HornEnabled = GetConVar( "AM_Config_HornEnabled" ):GetBool()
local AM_AlarmEnabled = GetConVar( "AM_Config_LockAlarmEnabled" ):GetBool()


function AM_HornSound( model ) --Finds the set horn sound for the specified model, returns a default sound if none is found
	for k,v in pairs( AM_Vehicles ) do
		if k == model then
			if v.HornSound then
				return v.HornSound
			end
			return "automod/carhorn.wav"
		end
	end
end

function AM_VehicleHealth( model ) --Does the same as above but with the vehicle's health
	for k,v in pairs( AM_Vehicles ) do
		if k == model then
			if v.MaxHealth then
				return v.MaxHealth
			end
			return 100
		end
	end
end

function AM_EnginePos( model ) --Does the same as above but with the vehicle's engine position
	for k,v in pairs( AM_Vehicles ) do
		if k == model then
			if v.EnginePos then
				return v.EnginePos
			end
			return Vector( 0, 0, 0 )
		end
	end
end

function AM_NumSeats( veh ) --Returns the number of passenger seats that are attached to the vehicle
	if !veh:IsVehicle() or veh:GetClass() != "prop_vehicle_jeep" or !veh.seat then
		return 0
	end
	return #veh.seat
end

function AM_DestroyCheck( veh ) --Disables the engine and sets the vehicle on fire if it's health is 0
	if veh:GetNWInt( "AM_VehicleHealth" ) <= 0 then
		veh:Fire( "turnoff", "", 0.01 )
		veh:Ignite()
		veh:SetNWBool( "AM_IsSmoking", true )
	end
end

function AM_TakeDamage( veh, dam ) --Takes away health from the vehicle, also runs the destroy check every time the health is set
	if !AM_HealthEnabled then return end
	local health = veh:GetNWInt( "AM_VehicleHealth" )
	local maxhealth = veh:GetNWInt( "AM_VehicleMaxHealth" )
	veh:SetNWInt( "AM_VehicleHealth", math.Clamp( math.Round( health - dam, 0, maxhealth ), 2 ) )
	AM_DestroyCheck( veh )
end

function AM_AddHealth( veh, hp ) --Adds health to the vehicle, nothing special
	local health = veh:GetNWInt( "AM_VehicleHealth" )
	local maxhealth = veh:GetNWInt( "AM_VehicleMaxHealth" )
	veh:SetNWInt( math.Clamp( math.Round( health + hp, 0, maxhealth ), 2 ) )
end

function AM_Notify( ply, color, text )
	ply:SendLua( [[ chat.AddText( Color( 180, 0, 0, 255 ), "[Automod]: ", color, text ) ]] )
end

hook.Add( "OnEntityCreated", "AM_InitVehicle", function( ent )
	if !IsValid( ent ) then return end
	timer.Simple( 0.1, function() --Small timer because the model isn't seen the instant this hook is called
		if !IsValid( ent ) then return end
		local vehmodel = ent:GetModel()
		if ent:IsVehicle() and ent:GetClass() == "prop_vehicle_jeep" then
			if table.HasValue( AM_Config_Blacklist, vehmodel ) then return end --Prevents blacklisted models from being affected
			if AM_HealthEnabled then
				ent:SetNWInt( "AM_VehicleHealth", AM_VehicleHealth( vehmodel ) ) --Sets vehicle health if the health system is enabled
				ent:SetNWInt( "AM_VehicleMaxHealth", AM_VehicleHealth( vehmodel ) )
				ent:SetNWBool( "AM_IsSmoking", false )
				ent:SetNWVector( "AM_EnginePos", AM_EnginePos( vehmodel ) )
				ent:AddCallback( "PhysicsCollide", function( ent, data )
					local vel = data.OurOldVelocity:Length()
					if vel > 1000 then --Temporary until I can find a better way to take physical damage
						--if data.HitEntity:IsWorld() then return end
						AM_TakeDamage( ent, veh % 10 + 20 )
					end
				end )
			end
			if AM_HornEnabled then
				ent:SetNWString( "AM_HornSound", AM_HornSound( vehmodel ) ) --Sets horn sound of the setting is enabled
			end
			if AM_DoorLockEnabled then
				ent:SetNWBool( "AM_DoorsLocked", false ) --Sets door lock status if the setting is enabled
			end
			if AM_SeatsEnabled then
				if !AM_Vehicles or !AM_Vehicles[vehmodel] or !AM_Vehicles[vehmodel].Seats then return end
				local vehseats = AM_Vehicles[vehmodel].Seats
				ent.seat = {}
				for i=1, table.Count( vehseats ) do
					ent.seat[i] = ents.Create( "prop_vehicle_prisoner_pod" )
					ent.seat[i]:SetModel( "models/nova/airboat_seat.mdl" )
					ent.seat[i]:SetParent( ent )
					ent.seat[i]:SetPos( ent:LocalToWorld( vehseats[i].pos ) )
					ent.seat[i]:SetAngles( ent:LocalToWorldAngles( vehseats[i].ang ) )
					ent.seat[i]:Spawn()
					ent.seat[i]:SetKeyValue( "limitview", 0 )
					ent.seat[i]:SetVehicleEntryAnim( false )
					--ent.seat[i]:SetNoDraw( true )
					ent.seat[i]:SetNotSolid( true )
					ent.seat[i]:DrawShadow( false )
					table.Merge( ent.seat[i], { HandleAnimation = function( _, ply )
						return ply:SelectWeightedSequence( ACT_HL2MP_SIT )
					end } )
					ent.seat[i]:GetPhysicsObject():EnableMotion( false )
					ent.seat[i]:GetPhysicsObject():SetMass(1)
					ent:DeleteOnRemove( ent.seat[i] )
				end
			end
		end
	end )
end )

hook.Add( "KeyPress", "AM_KeyPressServer", function( ply, key )
	if ply:InVehicle() then
		if AM_WheelLockEnabled then
			if key == IN_MOVELEFT then
				ply.laststeer = -1
			elseif key == IN_MOVERIGHT then
				ply.laststeer = 1
			elseif key == IN_FORWARD then
				ply.laststeer =  0
			end
		end
	end
	if ply:InVehicle() and ply:GetVehicle():GetClass() == "prop_vehicle_prisoner_pod" then --Fix to get players out of passenger seats. Without this, players will enter the closest passenger seat without a way of getting out
		if key == IN_USE then
			ply:ExitVehicle()
			ply.AM_SeatCooldown = CurTime() + 1
		end
	end
end )

hook.Add( "CanPlayerEnterVehicle", "AM_CanEnterVehicle", function( ply, veh, role )
	if ply.AM_SeatCooldown and ply.AM_SeatCooldown > CurTime() then return false end --Cooldown to make sure players don't unlock their car the instant they exit it
end )

hook.Add( "Think", "AM_VehicleThink", function()
	for k,v in pairs( ents.FindByClass( "prop_vehicle_jeep" ) ) do
		if !IsValid( v ) or v == nil then return end
		if !v:IsEngineStarted() then --This part is a mess but it seems to be working fine so i'm leaving it for now
			if v.laststeer == 1 then
				if v:GetSteering() == -1 then return end
				v:SetSteering( 1, 1 )
			elseif v.laststeer == -1 then
				if v:GetSteering() == 1 then return end
				v:SetSteering( -1, 1 )
			elseif v.laststeer == 0 then
				if v:GetSteering() == 0 then return end
				v:SetSteering( 0, 0 )
			end
		end
	end
end )

hook.Add( "PlayerLeaveVehicle", "AM_LeaveVehicle", function( ply, ent )
	ent.AM_ExitCooldown = CurTime() + 0.5
	if AM_BrakeLockEnabled then
		if ply:KeyDown( IN_JUMP ) then --Activates the parking brake if the player is holding the jump button when they exit
			ent:Fire( "HandBrakeOn", "", 0.01 )
			ent:EmitSound( "automod/brake.mp3" )
		else
			ent:Fire( "HandBrakeOff", "", 0.01 )
		end
	end
	if AM_WheelLockEnabled then
		if ply.laststeer == 1 then
			ent.laststeer = 1
		elseif ply.laststeer == -1 then
			ent.laststeer = -1
		elseif ply.laststeer == 0 then
			ent.laststeer = 0
		end
	end
end )

hook.Add( "EntityTakeDamage", "AM_TakeDamage", function( ent, dmg )
	if AM_HealthEnabled then
		if ent:IsOnFire() then return end --Prevent car from constantly igniting itself if it's on fire
		local d = dmg:GetDamage()
		if ent:GetClass() == "prop_vehicle_jeep" then
			if dmg:IsBulletDamage() and AM_BulletDamageEnabled then
				AM_TakeDamage( ent, d * 50 )
			else
				AM_TakeDamage( ent, d )
			end
		end
	end
end )

hook.Add( "PlayerUse", "AM_PlayerUseVeh", function( ply, ent )
	if !IsValid( ply ) or !IsValid( ent ) then return end
	if ent:GetClass() == "prop_vehicle_jeep" then
		if ent.AM_ExitCooldown and ent.AM_ExitCooldown > CurTime() then return end
		if ent:GetNWBool( "AM_DoorsLocked" ) then
			if ent:GetNWEntity( "AM_LockOwner" ) == ply then
				ent:Fire( "Unlock", "", 0.01 )
				ent:SetNWBool( "AM_DoorsLocked", false )
				ent:SetNWEntity( "AM_LockOwner", nil )
				AM_Notify( ply, color_white, "Vehicle unlocked." )
			end
		end
		if !ent:GetNWBool( "AM_DoorsLocked" ) and AM_SeatsEnabled then
			//if ply:InVehicle() then ply:ExitVehicle() return end
			if !IsValid( ent:GetDriver() ) then return end
			local seat = ent.seat[1]
			if !IsValid( seat ) then return end
			local dist = ( seat:GetPos() - ply:GetPos() ):Length()
			for i=1, table.Count( ent.seat ) do
				local distance = ( ent.seat[i]:GetPos() - ply:GetPos() ):Length()
				if distance < dist then
					ply:EnterVehicle( ent.seat[i] )
				end
			end
		end
	end
end )

hook.Add( "lockpickStarted", "AM_Lockpick", function( ply, ent, trace )
	if !AM_AlarmEnabled then return end
	if ent:IsVehicle() and ent:GetClass() == "prop_vehicle_jeep" then
		ent:EmitSound( "automod/alarm.mp3" )
	end
end )

util.AddNetworkString( "AM_VehicleLock" )
net.Receive( "AM_VehicleLock", function( len, ply )
	if IsFirstTimePredicted() then
		if IsValid( ply ) and ply:IsPlayer() then
			if !ply:GetVehicle():GetNWBool( "AM_DoorsLocked" ) then
				AM_Notify( ply, color_white, "Vehicle locked." )
				ply:GetVehicle():Fire( "Lock", "", 0.01 )
				ply:GetVehicle():SetNWBool( "AM_DoorsLocked", true )
				ply:GetVehicle():SetNWEntity( "AM_LockOwner", ply )
			else
				AM_Notify( ply, color_white, "Vehicle unlocked." )
				ply:GetVehicle():Fire( "Unlock", "", 0.01 )
				ply:GetVehicle():SetNWBool( "AM_DoorsLocked", false )
			end
		end
	end
end )

util.AddNetworkString( "AM_VehicleHorn" )
net.Receive( "AM_VehicleHorn", function( len, ply )
	if AM_HornEnabled then
		if IsValid( ply ) and ply:IsPlayer() then
			local veh = ply:GetVehicle()
			veh.AM_CarHorn = CreateSound( veh, veh:GetNWString( "AM_HornSound" ) )
			if veh.AM_CarHorn:IsPlaying() then return end
			veh.AM_CarHorn:Play()
		end
	end
end )

util.AddNetworkString( "AM_VehicleHornStop" )
net.Receive( "AM_VehicleHornStop", function( len, ply )
	local veh = ply:GetVehicle()
	if !IsValid( veh ) then return end
	if !veh.AM_CarHorn then return end
	if veh.AM_CarHorn:IsPlaying() then veh.AM_CarHorn:Stop() end
end )

util.AddNetworkString( "AM_ChangeSeats" )
net.Receive( "AM_ChangeSeats", function( len, ply )
	local key = net.ReadInt()
	local veh = ply:GetVehicle()
	local vehparent = veh:GetParent()
	local driver = veh:GetDriver()
	if !IsValid( veh ) then return end
	if veh:GetClass() == "prop_vehicle_jeep" then
		if key == KEY_1 then
			AM_Notify( ply, color_white, "Seat change failed, you selected the seat you are already sitting in." )
			return
		else
			if IsValid( veh.seat[key] ) then
				if !IsValid( veh.seat[key]:GetDriver() ) then
					ply:EnterVehicle( veh.seat[key] )
				else
					AM_Notify( ply, color_white, "Seat change failed, selected seat is already taken." )
					return
				end
			else
				AM_Notify( ply, color_white, "Seat change failed, selected seat doesn't exist." )
				return
			end
		end
	else
		if vehparent.seat[key] == veh then
			AM_Notify( ply, color_white, "Seat change failed, you selected the seat you are already sitting in." )
		end
		if IsValid( vehparent.seat[key] ) then	
			if !IsValid( veh.seat[key]:GetDriver() ) then
				ply:EnterVehicle( veh.seat[key] )
			else
				AM_Notify( ply, color_white, "Seat change failed, selected seat is already taken." )
				return
			end
		else
			AM_Notify( ply, color_white, "Seat change failed, selected seat doesn't exist." )
			return
		end
	end
end )
