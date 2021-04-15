local color_red = Color( 255, 0, 0 )

function AM_HornSound( model ) --Finds the set horn sound for the specified model, returns a default sound if none is found
	if AM_Vehicles[model] and AM_Vehicles[model].HornSound then
		return AM_Vehicles[model].HornSound
	end
	return "automod/carhorn.wav"
end

function AM_VehicleHealth( model ) --Does the same as above but with the vehicle's health
	if AM_Vehicles[model] and AM_Vehicles[model].MaxHealth then
		return AM_Vehicles[model].MaxHealth
	end
	return 100
end

function AM_EnginePos( model ) --Does the same as above but with the vehicle's engine position
	if AM_Vehicles[model] and AM_Vehicles[model].EnginePos then
		return AM_Vehicles[model].EnginePos
	end
	return vector_origin
end

function AM_LoadVehicle( model )
	if !model then
		MsgC( color_red, "[Automod] ERROR: Invalid argument for AM_LoadVehicle()." )
		return
	end
	local slashfix = AM_TrimModel( model )
	local findvehicle = file.Read( "addons/Automod/data/automod/vehicles/"..slashfix..".json", "GAME" )
	local findvehicleextra = file.Read( "automod/vehicles/"..slashfix..".json", "DATA" )
	local filefoundinmaindir = false
	if findvehicle == nil then
		print( "[Automod] Automod file not found for '"..model.."' in addon data directory. Checking main data directory." )
		if findvehicleextra == nil then
			MsgC( color_red, "[Automod] ERROR: Automod file not found for model '"..model.."'." )
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

local function AM_PhysicsCollide( veh, data )
	local speed = data.Speed
	local hitent = data.HitEntity
	if IsValid( hitent:GetPhysicsObject() ) and hitent:GetPhysicsObject():GetMass() < 300 and !hitent:IsWorld() then
		return
	end
	for k,v in pairs( constraint.GetTable( veh ) ) do
		if v.Ent1 == hitent then return end --Prevents objects that may be part of the vehicle from damaging it
	end
	local formula = speed / 98 --Not at all realistic especially since mass isn't a factor, but it provides a good balance between too spongy and too fragile
	if speed > 500 then
		if hitent:IsPlayer() or hitent:IsNPC() then return end
		AM_TakeDamage( veh, formula )
	end
end

function AM_SpawnSeat( index, ent, pos, ang )
	ent.seat[index] = ents.Create( "prop_vehicle_prisoner_pod" )
	ent.seat[index]:SetModel( "models/nova/airboat_seat.mdl" )
	ent.seat[index]:SetParent( ent ) --Sets the vehicle as the parent, very important for later
	ent.seat[index]:SetPos( ent:LocalToWorld( pos ) ) --Gotta keep the vectors local to the vehicle so the seats always spawn in the right place, no matter where the vehicle is on the map
	ent.seat[index]:SetAngles( ent:LocalToWorldAngles( ang ) )
	ent.seat[index]:Spawn()
	ent.seat[index]:SetKeyValue( "limitview", 0 ) --Disables the limited view that you get with the default prisoner pods
	ent.seat[index]:SetVehicleEntryAnim( false ) --Doesn't do anything when switching seats, but does run the animation when you press your use key on a passenger seat
	ent.seat[index]:SetNoDraw( true ) --Turns the seats invisible so it looks like you're actually sitting in the car
	ent.seat[index]:SetNotSolid( true ) --We probably don't need this but i'm putting it here anyway incase of some weird physics freakout
	ent.seat[index]:DrawShadow( false ) --Disables the shadow for the same reason as the nodraw
	table.Merge( ent.seat[index], { HandleAnimation = function( _, ply )
		return ply:SelectWeightedSequence( ACT_HL2MP_SIT ) --Sets the animation to the sitting animation, taken from the Gmod wiki
	end } )
	ent:DeleteOnRemove( ent.seat[index] )
	ent.seat[index]:SetNWBool( "IsAutomodSeat", true )
	ent.seat[index].VehicleTable = {} --Prevents photon from spamming console when it can't find each seat's VehicleTable
	ent.seat[index].ID = index --Useful for identifying the seat without having to use loops
end

local function AM_InitVehicle( ent )
	timer.Simple( 0.1, function() --Small timer because the model isn't seen the instant this hook is called
		if AM_IsBlackListed( ent ) then return end --Prevents blacklisted models from being affected
		local vehmodel = ent:GetModel()
		if ent:IsVehicle() and ent:GetClass() == "prop_vehicle_jeep" then
			local AM_HealthEnabled = GetConVar( "AM_Config_HealthEnabled" ):GetBool()
			local AM_HealthOverride = GetConVar( "AM_Config_HealthOverride" ):GetInt()
			local AM_HornEnabled = GetConVar( "AM_Config_HornEnabled" ):GetBool()
			local AM_DoorLockEnabled = GetConVar( "AM_Config_LockEnabled" ):GetBool()
			local AM_FuelEnabled = GetConVar( "AM_Config_FuelEnabled" ):GetBool()
			local AM_FuelAmount = GetConVar( "AM_Config_FuelAmount" ):GetInt()
			local AM_SeatsEnabled = GetConVar( "AM_Config_SeatsEnabled" ):GetBool()
			if !AM_Vehicles[vehmodel] then
				print( "[Automod] Vehicle table not found. Attempting to load from file..." )
				AM_LoadVehicle( vehmodel ) --Tries to load the vehicle from file if it doesn't exist in memory
			end
			if AM_HealthEnabled then
				if AM_HealthOverride > 0 then
					ent:SetNWInt( "AM_VehicleHealth", AM_HealthOverride )
					ent:SetNWInt( "AM_VehicleMaxHealth", AM_HealthOverride )
				else
					ent:SetNWInt( "AM_VehicleHealth", AM_VehicleHealth( vehmodel ) ) --Sets vehicle health if the health system is enabled
					ent:SetNWInt( "AM_VehicleMaxHealth", AM_VehicleHealth( vehmodel ) )
				end
				ent:SetNWBool( "AM_IsSmoking", false )
				ent:SetNWBool( "AM_HasExploded", false )
				ent:SetNWVector( "AM_EnginePos", AM_EnginePos( vehmodel ) )
				ent:AddCallback( "PhysicsCollide", AM_PhysicsCollide )
			end
			if AM_HornEnabled then
				ent:SetNWString( "AM_HornSound", AM_HornSound( vehmodel ) ) --Sets horn sound of the setting is enabled
			end
			if AM_DoorLockEnabled then
				ent:SetNWBool( "AM_DoorsLocked", false ) --Sets door lock status if the setting is enabled
			end
			if AM_FuelEnabled then
				ent:SetNWInt( "AM_FuelAmount", AM_FuelAmount )
				ent.FuelLoss = 0
				ent.FuelInit = true --Fix for some vehicles running out of fuel as soon as they spawn
			end
			if AM_SeatsEnabled then
				if !AM_Vehicles or !AM_Vehicles[vehmodel] then
					MsgC( color_red, "\n[Automod] Warning! The model '"..vehmodel.."' is unsupported. Basic features will still work but passenger seats will not spawn and engines will not smoke.\n" )
					return
				end
				if !AM_Vehicles[vehmodel].Seats then return end
				local vehseats = AM_Vehicles[vehmodel].Seats
				local numseats = table.Count( vehseats )
				ent.seat = {}
				for i=1, numseats do
					AM_SpawnSeat( i, ent, vehseats[i].pos, vehseats[i].ang )
				end
			end
		end
	end )
end
hook.Add( "OnEntityCreated", "AM_InitVehicle", AM_InitVehicle )
