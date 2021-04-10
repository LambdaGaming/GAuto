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
	return vector_origin
end

function AM_LoadVehicle( model )
	local color_red = Color( 255, 0, 0 )
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
				ent:AddCallback( "PhysicsCollide", function( veh, data )
					local speed = data.Speed
					local hitent = data.HitEntity
					if IsValid( hitent:GetPhysicsObject() ) and hitent:GetPhysicsObject():GetMass() < 300 and !hitent:IsWorld() then
						return
					end
					if constraint.FindConstraintEntity( hitent, "Weld" ) == veh or constraint.FindConstraintEntity( hitent, "Rope" ) == veh then --Prevent roped and welded entities from causing damage
						return
					end
					local formula = speed / 98
					if speed > 500 then
						if hitent:IsPlayer() or hitent:IsNPC() then return end
						AM_TakeDamage( veh, formula )
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
				ent.FuelLoss = 0
				ent.FuelInit = true --Fix for some vehicles running out of fuel as soon as they spawn
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
					ent.seat[i].ID = i --Useful for identifying the seat without having to use loops
				end
			end
		end
	end )
end
hook.Add( "OnEntityCreated", "AM_InitVehicle", AM_InitVehicle )
