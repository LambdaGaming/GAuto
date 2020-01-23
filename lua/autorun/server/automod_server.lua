
--Health and damage convars
local AM_HealthEnabled = GetConVar( "AM_Config_HealthEnabled" ):GetBool()
local AM_BulletDamageEnabled = GetConVar( "AM_Config_BulletDamageEnabled" ):GetBool()
local AM_ExplosionEnabled = GetConVar( "AM_Config_DamageExplosionEnabled" ):GetBool()
local AM_ExplodeRemoveEnabled = GetConVar( "AM_Config_ExplodeRemoveEnabled" ):GetBool()
local AM_ExplodeRemoveTime = GetConVar( "AM_Config_ExplodeRemoveTime" ):GetInt()
local AM_ScalePlayerDamage = GetConVar( "AM_Config_ScalePlayerDamage" ):GetBool()

--All other convars
local AM_WheelLockEnabled = GetConVar( "AM_Config_WheelLockEnabled" ):GetBool()
local AM_DoorLockEnabled = GetConVar( "AM_Config_LockEnabled" ):GetBool()
local AM_BrakeLockEnabled = GetConVar( "AM_Config_BrakeLockEnabled" ):GetBool()
local AM_SeatsEnabled = GetConVar( "AM_Config_SeatsEnabled" ):GetBool()
local AM_HornEnabled = GetConVar( "AM_Config_HornEnabled" ):GetBool()
local AM_AlarmEnabled = GetConVar( "AM_Config_LockAlarmEnabled" ):GetBool()
local AM_TirePopEnabled = GetConVar( "AM_Config_TirePopEnabled" ):GetBool()
local AM_TireHealth = GetConVar( "AM_Config_TireHealth" ):GetInt()
local AM_FuelEnabled = GetConVar( "AM_Config_FuelEnabled" ):GetBool()
local AM_FuelAmount = GetConVar( "AM_Config_FuelAmount" ):GetInt()
local AM_NoFuelGod = GetConVar( "AM_Config_NoFuelGod" ):GetBool()

function AM_HornSound( model ) --Finds the set horn sound for the specified model, returns a default sound if none is found
	for k,v in pairs( AM_Vehicles ) do
		if k == model then
			if v.HornSound then
				return v.HornSound
			end
		end
	end
	return "automod/carhorn.wav"
end

function AM_VehicleHealth( model ) --Does the same as above but with the vehicle's health
	for k,v in pairs( AM_Vehicles ) do
		if k == model then
			if v.MaxHealth then
				return v.MaxHealth
			end
		end
	end
	return 100
end

function AM_EnginePos( model ) --Does the same as above but with the vehicle's engine position
	for k,v in pairs( AM_Vehicles ) do
		if k == model then
			if v.EnginePos then
				return v.EnginePos
			end
		end
	end
	return Vector( 0, 0, 0 )
end

function AM_NumSeats( veh ) --Returns the number of passenger seats that are attached to the vehicle, currently not used for anything
	if !veh:IsVehicle() or veh:GetClass() != "prop_vehicle_jeep" or !veh.seat then
		return 0
	end
	return #veh.seat
end

function AM_DestroyCheck( veh ) --Disables the engine and sets the vehicle on fire if it's health is 0
	if veh:GetNWInt( "AM_VehicleHealth" ) <= 0 and !veh:GetNWBool( "AM_HasExploded" ) then
		veh:Fire( "turnoff", "", 0.01 )
		if vFireInstalled then --Only ignites the vehicle if VFire is installed since otherwise it looks weird
			veh:Ignite()
		end
		if AM_ExplosionEnabled then
			local e = ents.Create( "env_explosion" )
			e:SetPos( veh:LocalToWorld( veh:GetNWVector( "AM_EnginePos" ) ) )
			e:Spawn()
			e:SetKeyValue( "iMagnitude", 50 )
			e:Fire( "Explode", 0, 0 )
		end
		veh:SetNWBool( "AM_HasExploded", true )
	end
end

function AM_SmokeCheck( veh )
	local health = veh:GetNWInt( "AM_VehicleHealth" )
	local maxhealth = veh:GetNWInt( "AM_VehicleMaxHealth" )
	if health > ( maxhealth * 0.3 ) or health <= 0 then
		if veh:GetNWBool( "AM_IsSmoking" ) then
			veh:SetNWBool( "AM_IsSmoking", false )
		end
	else
		if !veh:GetNWBool( "AM_IsSmoking" ) then
			veh:SetNWBool( "AM_IsSmoking", true )
		end
	end
end

function AM_ToggleGodMode( veh )
	local enabled = veh:GetNWBool( "GodMode" )
	if enabled then
		veh:SetNWBool( "GodMode", false )
		return
	end
	veh:SetNWBool( "GodMode", true )
end

function AM_GodModeEnabled( veh )
	return veh:GetNWBool( "GodMode" )
end

function AM_TakeDamage( veh, dam ) --Takes away health from the vehicle, also runs the destroy check every time the health is set
	if !AM_HealthEnabled or AM_GodModeEnabled( veh ) then return end
	if dam < 0.5 then return end
	local health = veh:GetNWInt( "AM_VehicleHealth" )
	local maxhealth = veh:GetNWInt( "AM_VehicleMaxHealth" )
	local roundhp = math.Round( health - dam )
	local newhp = math.Clamp( roundhp, 0, maxhealth )
	veh:SetNWInt( "AM_VehicleHealth", newhp )
	AM_DestroyCheck( veh )
	AM_SmokeCheck( veh )
end

function AM_AddHealth( veh, hp ) --Adds health to the vehicle, nothing special
	local health = veh:GetNWInt( "AM_VehicleHealth" )
	local maxhealth = veh:GetNWInt( "AM_VehicleMaxHealth" )
	local roundhp = math.Round( health + hp, 2 )
	local newhp = math.Clamp( roundhp, 0, maxhealth )
	if veh:GetNWBool( "AM_HasExploded" ) then
		veh:SetNWBool( "AM_HasExploded", false )
	end
	veh:SetNWInt( "AM_VehicleHealth", newhp )
	AM_SmokeCheck( veh )
end

util.AddNetworkString( "AM_Notify" )
function AM_Notify( ply, text, broadcast )
	if broadcast then
		net.Start( "AM_Notify" )
		net.WriteString( text )
		net.Broadcast()
		return
	end
	net.Start( "AM_Notify" )
	net.WriteString( text )
	net.Send( ply )
end

local function TrimModel( model )
	if isstring( model ) then
		local removemodel = string.gsub( model, "models/", "" )
		local removeextention = string.StripExtension( removemodel )
		local replaceslash = string.Replace( removeextention, "/", "%" )
		return replaceslash
	end
	return "Invalid String"
end

function AM_SaveAllVehicles()
	for k,v in pairs( AM_Vehicles ) do
		timer.Simple( 0.5, function()
			local slashfix = TrimModel( k )
			if file.Exists( "addons/Automod/data/automod/vehicles/"..slashfix..".json", "GAME" ) then
				print( "[Automod] File for '"..k.."' already exists. Skipping." )
				return
			end
			if !file.Exists( "automod/vehicles", "DATA" ) then file.CreateDir( "automod/vehicles" ) end
			file.Write( "automod/vehicles/"..slashfix..".json", util.TableToJSON( v, true ) )
			print( "[Automod] Successfully saved '"..k.."' to file." )
		end )
	end
end

local function AM_SaveVehicle( model )
	if AM_Vehicles[model] then
		local slashfix = TrimModel( model )
		if file.Exists( "automod/vehicles/"..slashfix..".json", "DATA" ) or file.Exists( "addons/Automod/data/automod/vehicles/"..slashfix..".json", "GAME" ) then
			print( "[Automod] This vehicle has already been saved. Delete it's data file and try again if you're saving a newer version." )
			return
		end
		file.Write( "automod/vehicles/"..slashfix..".json", util.TableToJSON( AM_Vehicles[model], true ) )
		print( "[Automod] Successfully saved "..model.." to Automod files." )
	else
		MsgC( Color( 255, 0, 0 ), "[Automod] ERROR: The specified model doesn't seem to exist. Check your spelling and vehicle tables." )
	end
end
concommand.Add( "AM_SaveVehicle", function( ply, cmd, args )
	if IsValid( ply ) and !ply:IsSuperAdmin() then
		AM_Notify( ply, "Only superadmins and server operators can access this command!" )
		return
	end
	if #args > 1 then
		MsgC( Color( 255, 0, 0 ), "[Automod] ERROR: Please only enter 1 argument." )
		return
	end
	AM_SaveVehicle( args[1] )
end )

function AM_LoadVehicle( model )
	if !model then
		MsgC( Color( 255, 0, 0 ), "[Automod] ERROR: Invalid argument for AM_LoadVehicle()." )
		return
	end
	local slashfix = TrimModel( model )
	local findvehicle = file.Read( "addons/Automod/data/automod/vehicles/"..slashfix..".json", "GAME" )
	local findvehicleextra = file.Read( "automod/vehicles/"..slashfix..".json", "DATA" )
	local filefoundinmaindir = false
	if findvehicle == nil then
		print( "[Automod] Automod file not found for '"..model.."' in addon data directory. Checking main data directory." )
		if findvehicleextra == nil then
			MsgC( Color( 255, 0, 0 ), "[Automod] ERROR: Automod file not found for model '"..model.."'." )
			return
		end
	else
		filefoundinmaindir = true
	end
	if filefoundinmaindir then
		AM_Vehicles[model] = util.JSONToTable( findvehicle )
	else
		AM_Vehicles[model] = util.JSONToTable( findvehicleextra )
	end
	print( "[Automod] Successfully loaded '"..model.."' from Automod files." )
end

hook.Add( "VehicleMove", "AM_VehicleThink", function( ply, veh, mv )
	if IsValid( veh ) then
		local vel = veh:GetVelocity():Length()
		if veh.NoFuel then return end
		if !veh.FuelCooldown then veh.FuelCooldown = 0 end

		local fuelloss = 0
		if vel > 100 then
			fuelloss = 1 --Vehicle uses more fuel while in motion, takes about 8.7 minutes of constant driving to empty a tank with these numbers
		else
			fuelloss = 0.1 --Vehicle uses less fuel while idle
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
					veh:SetNWInt( "AM_FuelAmount", fuellevel - fuelloss )
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
end )

function AM_SetFuel( veh, amount )
	local clampedamount = math.Clamp( amount, 0, AM_FuelAmount )
	veh:SetNWInt( "AM_FuelAmount", clampedamount )
	if amount > 0 and veh.NoFuel then
		veh.NoFuel = false
		veh:Fire( "turnon", "", 0.01 )
		if AM_GodModeEnabled( veh ) then AM_ToggleGodMode( veh ) end
	end
end

function AM_PopTire( veh, wheel )
	if !AM_TirePopEnabled then return end
	if IsValid( veh ) and veh:IsVehicle() then
		veh:SetSpringLength( wheel, 499 )
		veh:EmitSound( "HL1/ambience/steamburst1.wav" )
		veh:SetNWInt( "AM_WheelPopped", wheel )
	end
end

function AM_PopCheck( dmg, veh )
	if !AM_TirePopEnabled then return end
	local pos = dmg:GetDamagePosition()
	local dmgamount = dmg:GetDamage() * 300
	local dist = 0
	for i = 0, veh:GetWheelCount() - 1 do
		local wheel = veh:GetWheel( i )
		if IsValid( wheel ) then
			dist = wheel:GetPos():DistToSqr( pos )
			if dist <= 400 then --Only deal damage if the bullets hit within the wheel's diameter
				veh.WheelHealth = veh.WheelHealth or {}
				veh.WheelHealth[i] = ( veh.WheelHealth[i] or AM_TireHealth ) - dmgamount
				if veh.WheelHealth[i] <= 0 then
					AM_PopTire( veh, i )
				end
			end
		end
	end
end

function AM_RepairTire( veh )
	if !AM_TirePopEnabled then return end
	if IsValid( veh ) and veh:IsVehicle() then
		local vehmodel = veh:GetModel()
		if AM_Config_Blacklist[vehmodel] then return end
		for i = 0, veh:GetWheelCount() - 1 do
			veh:SetSpringLength( 1, 500.3 )
			if veh:GetNWInt( "AM_WheelPopped" ) > 0 then
				veh:GetWheel( i ):SetDamping( 0, 0 )
				veh:SetNWInt( "AM_WheelPopped", 0 )
				veh.WheelHealth = {}
			end
		end
	end
end

hook.Add( "OnEntityCreated", "AM_InitVehicle", function( ent )
	if !IsValid( ent ) then return end
	timer.Simple( 0.1, function() --Small timer because the model isn't seen the instant this hook is called
		if !IsValid( ent ) then return end
		local vehmodel = ent:GetModel()
		if ent:IsVehicle() and ent:GetClass() == "prop_vehicle_jeep" then
			if AM_Config_Blacklist[vehmodel] then return end --Prevents blacklisted models from being affected
			if !AM_Vehicles[vehmodel] then
				print( "[Automod] Vehicle table not found. Attempting to load from file..." )
				AM_LoadVehicle( vehmodel ) --Tries to load the vehicle from file if it doesn't exist in memory
			end
			if AM_HealthEnabled then
				ent:SetNWInt( "AM_VehicleHealth", AM_VehicleHealth( vehmodel ) ) --Sets vehicle health if the health system is enabled
				ent:SetNWInt( "AM_VehicleMaxHealth", AM_VehicleHealth( vehmodel ) )
				ent:SetNWBool( "AM_IsSmoking", false )
				ent:SetNWBool( "AM_HasExploded", false )
				ent:SetNWVector( "AM_EnginePos", AM_EnginePos( vehmodel ) )
				ent:AddCallback( "PhysicsCollide", function( ent, data )
					local speed = data.Speed
					local hitent = data.HitEntity
					if IsValid( hitent:GetPhysicsObject() ) and hitent:GetPhysicsObject():GetMass() < 300 and !hitent:IsWorld() then
						return
					end
					if constraint.FindConstraintEntity( hitent, "Weld" ) == ent or constraint.FindConstraintEntity( hitent, "Rope" ) == ent then
						return
					end
					if speed > 500 then
						if hitent:IsPlayer() or hitent:IsNPC() then return end
						AM_TakeDamage( ent, speed / 98 )
					end
				end )
			end
			if AM_HornEnabled then
				ent:SetNWString( "AM_HornSound", AM_HornSound( vehmodel ) ) --Sets horn sound of the setting is enabled
			end
			if AM_DoorLockEnabled then
				ent:SetNWBool( "AM_DoorsLocked", false ) --Sets door lock status if the setting is enabled
			end
			if AM_FuelEnabled then
				ent:SetNWInt( "AM_FuelAmount", AM_FuelAmount )
			end
			if AM_SeatsEnabled then
				if !AM_Vehicles or !AM_Vehicles[vehmodel] then
					AM_Notify( nil, "Warning! The vehicle that was spawned is currently not supported by Automod!", true )
					return
				end
				if !AM_Vehicles[vehmodel].Seats then return end
				local vehseats = AM_Vehicles[vehmodel].Seats
				local numseats = table.Count( vehseats )
				ent.seat = {}
				for i=1, numseats do
					ent.seat[i] = ents.Create( "prop_vehicle_prisoner_pod" )
					ent.seat[i]:SetModel( "models/nova/airboat_seat.mdl" )
					ent.seat[i]:SetParent( ent ) --Sets the vehicle as the parent, very important for later
					ent.seat[i]:SetPos( ent:LocalToWorld( vehseats[i].pos ) ) --Gotta keep the vectors local to the vehicle so the seats always spawn in the right place, no matter where the vehicle is on the map
					ent.seat[i]:SetAngles( ent:LocalToWorldAngles( vehseats[i].ang ) )
					ent.seat[i]:Spawn()
					ent.seat[i]:SetKeyValue( "limitview", 0 ) --Disables the limited view that you get with the default prisoner pods
					ent.seat[i]:SetVehicleEntryAnim( false ) --Doesn't do anything when switching seats, but does run the animation when you press your use key on a passenger seat
					ent.seat[i]:SetNoDraw( true ) --Turns the seats invisible so it looks like you're actually sitting in the car
					ent.seat[i]:SetNotSolid( true ) --We probably don't need this but i'm putting it here anyway incase of some weird physics freakout
					ent.seat[i]:DrawShadow( false ) --Disables the shadow for the same reason as the nodraw
					table.Merge( ent.seat[i], { HandleAnimation = function( _, ply )
						return ply:SelectWeightedSequence( ACT_HL2MP_SIT ) --Sets the animation to the sitting animation, taken from the Gmod wiki
					end } )
					ent:DeleteOnRemove( ent.seat[i] )
					ent.seat[i]:SetNWBool( "IsAutomodSeat", true )
					ent.seat[i].VehicleTable = {} --Prevents photon from spamming console when it can't find each seat's VehicleTable
				end
			end
		end
	end )
end )

local shouldsave = gmsave.ShouldSaveEntity
function gmsave.ShouldSaveEntity( ent, t ) --Finding decent documentation on this function was such a pain, especially now that the facepunch forums are gone
	if ent:GetNWBool( "IsAutomodSeat" ) then return false end --Should prevent the seats from duping themselves after loading a save
	return shouldsave( ent, t )
end

hook.Add( "KeyPress", "AM_KeyPressServer", function( ply, key )
	if ply:InVehicle() then
		local veh = ply:GetVehicle()
		if veh:GetNWBool( "IsAutomodSeat" ) then --Fix to get players out of passenger seats. Without this, players will enter the closest passenger seat without a way of getting out
			if key == IN_USE then
				ply:ExitVehicle()
				ply.AM_SeatCooldown = CurTime() + 1
			end
		end
		if AM_Config_Blacklist[veh:GetModel()] then return end
		if AM_WheelLockEnabled then
			if key == IN_MOVELEFT then
				veh.laststeer = -1
			elseif key == IN_MOVERIGHT then
				veh.laststeer = 1
			elseif key == IN_FORWARD or key == IN_BACK then
				veh.laststeer =  0
			end
		end
	end
end )

hook.Add( "CanPlayerEnterVehicle", "AM_CanEnterVehicle", function( ply, veh, role )
	if ply.AM_SeatCooldown and ply.AM_SeatCooldown > CurTime() then return false end --Cooldown to make sure players don't unlock their car the instant they exit it
end )

hook.Add( "PlayerEnteredVehicle", "AM_EnteredVehicle", function( ply, veh, role )
	veh.laststeer = 0 --Resets the steering wheel straight when the player enters
	if veh:GetNWBool( "IsAutomodSeat" ) then veh:SetCameraDistance( 5 ) end --Sets camera distance relatively close to the default driver's seat distance
end )

hook.Add( "PlayerLeaveVehicle", "AM_LeaveVehicle", function( ply, ent )
	ent.AM_ExitCooldown = CurTime() + 1
	if AM_Config_Blacklist[ent:GetModel()] then return end
	if AM_BrakeLockEnabled then
		if ply:KeyDown( IN_JUMP ) then --Activates the parking brake if the player is holding the jump button when they exit
			ent:Fire( "HandBrakeOn", "", 0.01 )
			ent:EmitSound( "automod/brake.mp3" )
		else
			ent:Fire( "HandBrakeOff", "", 0.01 )
		end
	end
	if AM_WheelLockEnabled then
		timer.Simple( 0.01, function() --Small timer because it otherwise won't register
			if ent.laststeer == 1 then
				if ent:GetSteering() == -1 then return end
				ent:SetSteering( 1, 1 )
			elseif ent.laststeer == -1 then
				if ent:GetSteering() == 1 then return end
				ent:SetSteering( -1, 1 )
			elseif ent.laststeer == 0 then
				if ent:GetSteering() == 0 then return end
				ent:SetSteering( 0, 0 )
			end
		end )
	end
end )

hook.Add( "EntityTakeDamage", "AM_TakeDamage", function( ent, dmg )
	if AM_HealthEnabled then
		if ent:IsOnFire() then return end --Prevent car from constantly igniting itself if it's on fire
		if ent:GetClass() == "prop_vehicle_jeep" then
			if dmg:IsBulletDamage() and AM_BulletDamageEnabled then
				AM_TakeDamage( ent, dmg:GetDamage() * 450 )
				AM_PopCheck( dmg, ent )
			else
				AM_TakeDamage( ent, dmg:GetDamage() )
			end
		end
		if ent:IsVehicle() and ent.seat then
			for k,v in pairs( ent.seat ) do
				local driver = v:GetDriver()
				if IsValid( driver ) then
					if AM_ScalePlayerDamage then dmg:ScaleDamage( 0.35 ) end
					driver:TakeDamage( dmg:GetDamage() ) --Fix for passengers not taking damage
				end
			end
		end
		if AM_ScalePlayerDamage and ent:IsPlayer() then
			if dmg:GetAttacker():IsVehicle() then
				dmg:SetDamageType( DMG_VEHICLE )
			end
			if dmg:IsDamageType( DMG_VEHICLE ) or ( ent:InVehicle() and dmg:IsDamageType( DMG_BLAST ) ) then
				dmg:ScaleDamage( 0.35 ) --Scales damage for vehicle drivers and players who are hit by vehicles
				return dmg
			end
		end
	end
end )

hook.Add( "PlayerUse", "AM_PlayerUseVeh", function( ply, ent )
	if !IsValid( ply ) or !IsValid( ent ) then return end
	if ent:GetClass() == "prop_vehicle_jeep" then
		if ent.AM_ExitCooldown and ent.AM_ExitCooldown > CurTime() then return end
		if ent.LockedNotifyCooldown and ent.LockedNotifyCooldown > CurTime() then return end
		if ent:GetNWBool( "AM_DoorsLocked" ) then
			if ent:GetNWEntity( "AM_LockOwner" ) == ply then
				ent:Fire( "Unlock", "", 0.01 )
				ent:SetNWBool( "AM_DoorsLocked", false )
				ent:SetNWEntity( "AM_LockOwner", nil )
				AM_Notify( ply, "Vehicle unlocked." )
			else
				AM_Notify( ply, "This vehicle is locked." )
				ent.LockedNotifyCooldown = CurTime() + 1
			end
		end
		if !ent:GetNWBool( "AM_DoorsLocked" ) and AM_SeatsEnabled then
			if ply:InVehicle() then return end
			if !IsValid( ent:GetDriver() ) then return end
			local plypos = ent:WorldToLocal( ply:GetPos() ):Length()
			local numpos = 1
			for i = 1, table.Count( ent.seat ) do
				local seatpos = ent:WorldToLocal( ent.seat[i]:GetPos() ):Length()
				if seatpos and seatpos < plypos then --Checks to see what seat is closest to the player
					plypos = seatpos
					numpos = i
				end
			end
			if IsValid( ent.seat[numpos]:GetDriver() ) then
				ply:EnterVehicle( ent.seat[numpos + 1] ) --Cheap fix for players not being able to get in if there's more than 2 players in the car until I have time to redo this whole thing
			else
				ply:EnterVehicle( ent.seat[numpos] )
			end
			ply.AM_SeatCooldown = CurTime() + 1 --Prevents players from sometimes teleporting to the last detected seat instead of the first
		end
	end
end )

hook.Add( "lockpickStarted", "AM_Lockpick", function( ply, ent, trace )
	if !AM_AlarmEnabled then return end
	if AM_Config_Blacklist[ent:GetModel()] then return end
	if ent:IsVehicle() and ent:GetClass() == "prop_vehicle_jeep" then
		ent:EmitSound( "automod/alarm.mp3" )
	end
end )

hook.Add( "onLockpickCompleted", "AM_LockpickFinish", function( ply, success, ent )
	if !AM_AlarmEnabled then return end
	if AM_Config_Blacklist[ent:GetModel()] then return end
	if ent:IsVehicle() and ent:GetClass() == "prop_vehicle_jeep" then
		if success then
			ent:SetNWBool( "AM_DoorsLocked", false )
			ent:SetNWEntity( "AM_LockOwner", nil )
		end
	end
end )

util.AddNetworkString( "AM_VehicleLock" )
net.Receive( "AM_VehicleLock", function( len, ply )
	if IsFirstTimePredicted() then
		if IsValid( ply ) and ply:IsPlayer() then
			local veh = ply:GetVehicle()
			if AM_Config_Blacklist[veh:GetModel()] then return end
			if !veh:GetNWBool( "AM_DoorsLocked" ) then
				AM_Notify( ply, "Vehicle locked." )
				veh:Fire( "Lock", "", 0.01 )
				veh:SetNWBool( "AM_DoorsLocked", true )
				veh:SetNWEntity( "AM_LockOwner", ply )
			else
				AM_Notify( ply, "Vehicle unlocked." )
				veh:Fire( "Unlock", "", 0.01 )
				veh:SetNWBool( "AM_DoorsLocked", false )
			end
		end
	end
end )

util.AddNetworkString( "AM_VehicleHorn" )
net.Receive( "AM_VehicleHorn", function( len, ply )
	if AM_HornEnabled then
		if IsValid( ply ) and ply:InVehicle() then
			local veh = ply:GetVehicle()
			if AM_Config_Blacklist[veh:GetModel()] then return end
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
	local key = tonumber( net.ReadString() )
	local veh = ply:GetVehicle()
	local vehparent = veh:GetParent()
	local driver = veh:GetDriver()
	if !IsValid( veh ) then return end
	if veh:GetClass() == "prop_vehicle_jeep" then
		if key == 1 then
			AM_Notify( ply, "Seat change failed, you selected the seat you are already sitting in." )
			return
		else
			if IsValid( veh.seat[key - 1] ) then --Need to subtract 1 here since the driver's seat doesn't count as a passenger seat
				if !IsValid( veh.seat[key - 1]:GetDriver() ) then
					ply:ExitVehicle() --Have to quickly exit the vehicle then enter the new one, or the old vehicle will still think it has a driver
					ply:EnterVehicle( veh.seat[key - 1] )
					ply:SetEyeAngles( Angle( veh.seat[key - 1]:GetAngles():Normalize() ) + Angle( 0, 90, 0 ) ) --Fix for the seats setting random eye angles
				else
					AM_Notify( ply, "Seat change failed, selected seat is already taken." )
					return
				end
			else
				AM_Notify( ply, "Seat change failed, selected seat doesn't exist. Vehicle may not be currently supported." )
				return
			end
		end
	else
		if key == 1 then
			if !IsValid( vehparent:GetDriver() ) then
				ply:ExitVehicle()
				ply:EnterVehicle( vehparent )
				ply:SetEyeAngles( Angle( vehparent:GetAngles():Normalize() ) + Angle( 0, 90, 0 ) )
				return
			else
				AM_Notify( ply, "Seat change failed, selected seat is already taken." )
				return
			end
		end
		if vehparent.seat[key - 1] == veh then
			AM_Notify( ply, "Seat change failed, you selected the seat you are already sitting in." )
			return
		end
		if IsValid( vehparent ) and IsValid( vehparent.seat[key - 1] ) then	
			if !IsValid( vehparent.seat[key - 1]:GetDriver() ) then
				ply:ExitVehicle()
				ply:EnterVehicle( vehparent.seat[key - 1] )
				ply:SetEyeAngles( Angle( vehparent.seat[key - 1]:GetAngles():Normalize() ) + Angle( 0, 90, 0 ) )
			else
				AM_Notify( ply, "Seat change failed, selected seat is already taken." )
				return
			end
		else
			AM_Notify( ply, "Seat change failed, selected seat doesn't exist." )
			return
		end
	end
end )
