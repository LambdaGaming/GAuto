local color_red = Color( 255, 0, 0 )

function GAuto.HornSound( model ) --Finds the set horn sound for the specified model, returns a default sound if none is found
	if GAuto.Vehicles[model] and GAuto.Vehicles[model].HornSound then
		return GAuto.Vehicles[model].HornSound
	end
	return "gauto/carhorn.wav"
end

function GAuto.VehicleHealth( model ) --Does the same as above but with the vehicle's health
	if GAuto.Vehicles[model] and GAuto.Vehicles[model].MaxHealth then
		return GAuto.Vehicles[model].MaxHealth
	end
	return 100
end

function GAuto.LoadVehicle( model )
	if !model then
		MsgC( color_red, "[GAuto] ERROR: Invalid argument for GAuto.LoadVehicle()." )
		return
	end
	local slashfix = GAuto.TrimModel( model )
	local findvehicle = file.Read( "data_static/gauto/vehicles/"..slashfix..".json", "THIRDPARTY" )
	local findvehicleextra = file.Read( "gauto/vehicles/"..slashfix..".json", "DATA" )
	local filefoundinmaindir = false
	if findvehicle == nil then
		print( "[GAuto] GAuto file not found in addon data directory. Checking main data directory." )
		if findvehicleextra == nil then
			MsgC( color_red, "[GAuto] Warning! The model '"..model.."' is unsupported. Everything will still work but passenger seats will be limited.\n" )
			return
		end
	else
		filefoundinmaindir = true
	end
	if filefoundinmaindir then
		GAuto.Vehicles[model] = util.JSONToTable( findvehicle )
	else
		GAuto.Vehicles[model] = util.JSONToTable( findvehicleextra )
	end
	print( "[GAuto] Successfully loaded '"..model.."' from GAuto files." )
end

local function PhysicsCollide( veh, data )
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
		GAuto.TakeDamage( veh, formula )
	end
end

function GAuto.SpawnSeat( index, ent, pos, ang )
	ent.seat[index] = ents.Create( "prop_vehicle_prisoner_pod" )
	ent.seat[index]:SetModel( "models/nova/airboat_seat.mdl" )
	ent.seat[index]:SetParent( ent )
	ent.seat[index]:SetPos( ent:LocalToWorld( pos ) ) --Gotta keep the vectors local to the vehicle so the seats always spawn in the right place, no matter where the vehicle is on the map
	ent.seat[index]:SetAngles( ent:LocalToWorldAngles( ang ) )
	ent.seat[index]:Spawn()
	ent.seat[index]:SetKeyValue( "limitview", 0 ) --Disables the limited view that you get with the default prisoner pods
	ent.seat[index]:SetVehicleEntryAnim( false ) --Disables the long entry animation
	ent.seat[index]:SetNoDraw( true )
	ent.seat[index]:SetNotSolid( true )
	ent.seat[index]:DrawShadow( false )
	ent.seat[index]:AddEFlags( EFL_NO_THINK_FUNCTION ) --Disables the entity's think function to reduce network usage
	table.Merge( ent.seat[index], { HandleAnimation = function( _, ply )
		return ply:SelectWeightedSequence( ACT_HL2MP_SIT ) --Sets the animation to the sitting animation, taken from the Gmod wiki
	end } )
	ent:DeleteOnRemove( ent.seat[index] )
	ent.seat[index]:SetNWBool( "IsGAutoSeat", true )
	ent.seat[index].VehicleTable = {} --Prevents photon from spamming console when it can't find each seat's VehicleTable
	ent.seat[index].ID = index --Useful for identifying the seat without having to use loops
	ent.seat[index].DoNotDuplicate = true --Prevents seats from spawning twice if the vehicle is duped or saved
end

local function InitVehicle( ent )
	timer.Simple( 0.1, function() --Small timer because the model isn't seen the instant this hook is called
		if GAuto.IsBlackListed( ent ) then return end --Prevents blacklisted models from being affected
		local vehmodel = ent:GetModel()
		if ent:IsVehicle() and ent:GetClass() == "prop_vehicle_jeep" then
			local GAuto_HealthEnabled = GetConVar( "GAuto_Config_HealthEnabled" ):GetBool()
			local GAuto_HealthOverride = GetConVar( "GAuto_Config_HealthOverride" ):GetInt()
			local GAuto_HornEnabled = GetConVar( "GAuto_Config_HornEnabled" ):GetBool()
			local GAuto_DoorLockEnabled = GetConVar( "GAuto_Config_LockEnabled" ):GetBool()
			local GAuto_FuelEnabled = GetConVar( "GAuto_Config_FuelEnabled" ):GetBool()
			local GAuto_FuelAmount = GetConVar( "GAuto_Config_FuelAmount" ):GetInt()
			local GAuto_SeatsEnabled = GetConVar( "GAuto_Config_SeatsEnabled" ):GetBool()
			if !GAuto.Vehicles[vehmodel] then
				print( "[GAuto] Vehicle table not found. Attempting to load from file..." )
				GAuto.LoadVehicle( vehmodel ) --Tries to load the vehicle from file if it doesn't exist in memory
			end
			if GAuto_HealthEnabled then
				if GAuto_HealthOverride > 0 then
					ent:SetNWInt( "GAuto_VehicleHealth", GAuto_HealthOverride )
					ent:SetNWInt( "GAuto_VehicleMaxHealth", GAuto_HealthOverride )
				else
					ent:SetNWInt( "GAuto_VehicleHealth", GAuto.VehicleHealth( vehmodel ) ) --Sets vehicle health if the health system is enabled
					ent:SetNWInt( "GAuto_VehicleMaxHealth", GAuto.VehicleHealth( vehmodel ) )
				end
				ent:SetNWBool( "GAuto_IsSmoking", false )
				ent:SetNWBool( "GAuto_HasExploded", false )
				ent:AddCallback( "PhysicsCollide", PhysicsCollide )
			end
			if GAuto_HornEnabled then
				ent:SetNWString( "GAuto_HornSound", GAuto.HornSound( vehmodel ) ) --Sets horn sound of the setting is enabled
			end
			if GAuto_DoorLockEnabled then
				ent:SetNWBool( "GAuto_DoorsLocked", false ) --Sets door lock status if the setting is enabled
			end
			if GAuto_FuelEnabled then
				ent:SetNWInt( "GAuto_FuelAmount", GAuto_FuelAmount )
				ent.FuelLoss = 0
				ent.FuelInit = true --Fix for some vehicles running out of fuel as soon as they spawn
			end
			if GAuto_SeatsEnabled then
				if ( !GAuto.Vehicles[vehmodel] or !GAuto.Vehicles[vehmodel].Seats ) and GetConVar( "GAuto_Config_AutoPassenger" ):GetBool() then
					local attachment = ent:GetAttachment( ent:LookupAttachment( "vehicle_driver_eyes" ) )
					if !attachment then return end
					local driverPos = ent:WorldToLocal( attachment.Pos )
					driverPos:Sub( Vector( driverPos.x * 2, 0, 35 ) )
					if math.abs( driverPos.x ) <= 5 then return end --Don't spawn seat if players would be too close to each other
					if !GAuto.Vehicles[vehmodel] then
						GAuto.Vehicles[vehmodel] = {}
					end
					GAuto.Vehicles[vehmodel].Seats = { { pos = driverPos, ang = angle_zero } } --Add single passenger seat as a fallback if vehicle isn't supported
				end
				local vehseats = GAuto.Vehicles[vehmodel].Seats
				local numseats = table.Count( vehseats )
				ent.seat = {}
				for i=1, numseats do
					GAuto.SpawnSeat( i, ent, vehseats[i].pos, vehseats[i].ang )
				end
			end
		end
	end )
end
hook.Add( "OnEntityCreated", "GAuto_InitVehicle", InitVehicle )
