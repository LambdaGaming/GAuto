
local AM_HealthEnabled = GetConVar( "AM_Config_HealthEnabled" ):GetInt()
local AM_WheelLockEnabled = GetConVar( "AM_Config_WheelLockEnabled" ):GetInt()
local AM_DoorLockEnabled = GetConVar( "AM_Config_LockEnabled" ):GetInt()
local AM_BrakeLockEnabled = GetConVar( "AM_Config_BrakeLockEnabled" ):GetInt()
local AM_SeatsEnabled = GetConVar( "AM_Config_SeatsEnabled" ):GetInt()
local AM_HornEnabled = GetConVar( "AM_Config_HornEnabled" ):GetInt()

function AM_HornSound( model )
	for k,v in pairs( AM_Vehicles ) do
		if k == model then
			return v.HornSound
		end
	end
end

function AM_VehicleHealth( model )
	for k,v in pairs( AM_Vehicles ) do
		if k == model then
			return v.MaxHealth
		end
	end
end

hook.Add( "OnEntityCreated", "AM_InitVehicle", function( ent )
	if !IsValid( ent ) then return end
	timer.Simple( 0.1, function() --Small timer because the model isn't seen the instant this hook is called
		if !IsValid( ent ) then return end
		if ent:GetModel() == "models/nova/airboat_seat.mdl" then return end --Prevents seats from being able to be locked and such
		local vehmodel = ent:GetModel()
		if ent:GetClass() == "prop_vehicle_jeep" then
			if AM_HealthEnabled > 0 then
				ent:SetNWInt( "AM_VehicleHealth", tonumber(AM_VehicleHealth( vehmodel )) ) --Sets vehicle health if the health system is enabled
				ent:SetNWInt( "AM_VehicleMaxHealth", tonumber(AM_VehicleHealth( vehmodel )) )
			end
			if AM_HornEnabled > 0 then
				ent:SetNWString( "AM_HornSound", AM_HornSound( vehmodel ) )
			end
			if AM_DoorLockEnabled > 0 then
				ent:SetNWBool( "AM_DoorsLocked", false ) --Sets door lock status if the setting is enabled
			end
			if AM_SeatsEnabled > 0 then
				if !AM_Vehicles or !AM_Vehicles[vehmodel] or !AM_Vehicles[vehmodel].Seats then return end
				local vehseats = AM_Vehicles[vehmodel].Seats
				ent.seat = {}
				for i=1, table.Count( vehseats ) do
					ent.seat[i] = ents.Create( "prop_vehicle_prisoner_pod" )
					ent.seat[i]:SetModel( "models/nova/airboat_seat.mdl" )
					ent.seat[i]:SetParent( ent )
					ent.seat[i]:SetPos( ent:WorldToLocal( vehseats[i].pos ) )
					ent.seat[i]:SetAngles( ent:WorldToLocalAngles( vehseats[i].ang ) )
					ent.seat[i]:Spawn()
					ent.seat[i]:SetKeyValue( "limitview", 0 )
					--ent.seat[i]:SetNoDraw( true )
					--ent.seat[i]:SetNotSolid( true )
					ent.seat[i]:DrawShadow( false )
					table.Merge( ent.seat[i], { HandleAnimation = function( _, ply )
						return ply:SelectWeightedSequence( ACT_HL2MP_SIT )
					end } )
					ent.seat[i]:GetPhysicsObject():EnableMotion( false )
					ent.seat[i]:GetPhysicsObject():EnableDrag(false) 
					ent.seat[i]:GetPhysicsObject():SetMass(1)
					ent:DeleteOnRemove( ent.seat[i] )
				end
			end
		end
		ent.AMReady = true --Lets the addon know when the vehicle is fully initialized
	end )
end )

hook.Add( "KeyPress", "AM_KeyPressServer", function( ply, key )
	if !ply:InVehicle() then return end
	if AM_WheelLockEnabled then
		if key == IN_MOVELEFT then
			ply.laststeer = -1
		elseif key == IN_MOVERIGHT then
			ply.laststeer = 1
		elseif key == IN_FORWARD then
			ply.laststeer = 0
		end
	end
end )

hook.Add( "Think", "AM_VehicleThink", function()
	for k,v in pairs( ents.FindByClass( "prop_vehicle_jeep" ) ) do
		if !IsValid( v ) or v == nil then return end
		if !v:IsEngineStarted() then
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
	ent.exitcooldown = CurTime() + 0.5
	if AM_BrakeLockEnabled > 0 then
		if ply:KeyDown( IN_JUMP ) then
			ent:Fire( "HandBrakeOn", "", 0.01 )
			ent:EmitSound( "automod/brake.mp3" )
		else
			ent:Fire( "HandBrakeOff", "", 0.01 )
		end
	end
	if AM_WheelLockEnabled > 0 then
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
	print(true)
	if AM_HealthEnabled > 0 then
		local d = dmg:GetDamage()
		if ent:GetClass() == "prop_vehicle_jeep" then
			ent:SetNWInt( "AM_VehicleHealth", ent:GetNWInt( "AM_VehicleHealth" ) - d )
		end
	end
end )

hook.Add( "PlayerUse", "AM_PlayerUseVeh", function( ply, ent )
	if !IsValid( ply ) or !IsValid( ent ) then return end
	if ent:GetClass() == "prop_vehicle_jeep" then
		if ent.exitcooldown and ent.exitcooldown > CurTime() then return end
		if ent:GetNWBool( "AM_DoorsLocked" ) then
			if ent:GetNWEntity( "AM_LockOwner" ) == ply then
				ent:Fire( "Unlock", "", 0.01 )
				ent:SetNWBool( "AM_DoorsLocked", false )
				ent:SetNWEntity( "AM_LockOwner", nil )
				ply:ChatPrint( "Vehicle unlocked." )
			end
		end
		if !ent:GetNWBool( "AM_DoorsLocked" ) then
			local entdist = ply:GetPos():DistToSqr( ent:GetPos() )
			if !ent.seat then return end
			for i = 1, table.Count( ent.seat ) do
				local seatdist = ply:GetPos():DistToSqr( ent.seat[i]:GetPos() )
				--if seatdist < entdist then
					ply:EnterVehicle( ent.seat[2] )
				--end
			end
		end
	end
end )

util.AddNetworkString( "AM_VehicleLock" )
net.Receive( "AM_VehicleLock", function( len, ply )
	if IsFirstTimePredicted() then
		if IsValid( ply ) and ply:IsPlayer() then
			if !ply:GetVehicle():GetNWBool( "AM_DoorsLocked" ) then
				ply:ChatPrint( "Vehicle locked." )
				if SERVER then
					ply:GetVehicle():Fire( "Lock", "", 0.01 )
				end
				ply:GetVehicle():SetNWBool( "AM_DoorsLocked", true )
				ply:GetVehicle():SetNWEntity( "AM_LockOwner", ply )
			else
				ply:ChatPrint( "Vehicle unlocked." )
				if SERVER then
					ply:GetVehicle():Fire( "Unlock", "", 0.01 )
				end
				ply:GetVehicle():SetNWBool( "AM_DoorsLocked", false )
			end
		end
	end
end )

util.AddNetworkString( "AM_VehicleHorn" )
net.Receive( "AM_VehicleHorn", function( len, ply )
	if AM_HornEnabled > 0 then
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