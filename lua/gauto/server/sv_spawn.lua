local color_red = Color( 255, 0, 0 )

function GAuto.HornSound( model )
	if GAuto.Vehicles[model] and GAuto.Vehicles[model].HornSound then
		return GAuto.Vehicles[model].HornSound
	end
	return "gauto/carhorn.wav"
end

function GAuto.VehicleHealth( model )
	if GAuto.Vehicles[model] and GAuto.Vehicles[model].MaxHealth then
		return GAuto.Vehicles[model].MaxHealth
	end
	return 100
end

function GAuto.EngineOffset( model )
	if GAuto.Vehicles[model] and GAuto.Vehicles[model].EngineOffset then
		return GAuto.Vehicles[model].EngineOffset
	end
	return vector_origin
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
	if findvehicle == nil and findvehicleextra == nil then
		MsgC( color_red, "[GAuto] Warning: '"..model.."' is unsupported. Everything will still work, but passenger seats will be limited or unavailable.\n" )
		return
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
		if GAuto.IsBlackListed( ent ) or !GAuto.IsDrivable( ent ) then return end --Prevents blacklisted models from being affected
		local vehmodel = ent:GetModel()
		local GAuto_HealthEnabled = GetConVar( "gauto_health_enabled" ):GetBool()
		local GAuto_HealthOverride = GetConVar( "gauto_health_override" ):GetInt()
		local GAuto_HornEnabled = GetConVar( "gauto_horn_enabled" ):GetBool()
		local GAuto_DoorLockEnabled = GetConVar( "gauto_lock_enabled" ):GetBool()
		local GAuto_FuelEnabled = GetConVar( "gauto_fuel_enabled" ):GetBool()
		local GAuto_FuelAmount = GetConVar( "gauto_fuel_amount" ):GetInt()
		local GAuto_SeatsEnabled = GetConVar( "gauto_seats_enabled" ):GetBool()
		local GAuto_ParticlesEnabled = GetConVar( "gauto_particles_enabled" ):GetBool()
		if !GAuto.Vehicles[vehmodel] then
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
			ent:SetNWVector( "GAuto_EngineOffset", GAuto.EngineOffset( vehmodel ) )
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
			ent.FuelCooldown = 0
		end
		if GAuto_SeatsEnabled then
			if ( !GAuto.Vehicles[vehmodel] or !GAuto.Vehicles[vehmodel].Seats ) and GetConVar( "gauto_auto_passenger" ):GetBool() then
				local attachment = ent:GetAttachment( ent:LookupAttachment( "vehicle_driver_eyes" ) )
				if attachment then
					local driverPos = ent:WorldToLocal( attachment.Pos )
					driverPos:Sub( Vector( driverPos.x * 2, 0, 35 ) )
					if math.abs( driverPos.x ) > 5 then --Don't spawn seat if players would be too close to each other
						if !GAuto.Vehicles[vehmodel] then
							GAuto.Vehicles[vehmodel] = {}
						end
						GAuto.Vehicles[vehmodel].Seats = { { pos = driverPos, ang = angle_zero } } --Add single passenger seat as a fallback if vehicle isn't supported
					end
				end
			end
			if GAuto.Vehicles[vehmodel] and GAuto.Vehicles[vehmodel].Seats then
				local vehseats = GAuto.Vehicles[vehmodel].Seats
				local numseats = table.Count( vehseats )
				if numseats > 0 then
					ent.seat = {}
					for i=1, numseats do
						GAuto.SpawnSeat( i, ent, vehseats[i].pos, vehseats[i].ang )
					end
				end
			end
		end
		if GAuto_ParticlesEnabled then
			ent.particles = {}
			for i = 0, ent:GetWheelCount() - 1 do
				local wheel = ent:GetWheel( i )
				local height = ent:GetWheelTotalHeight( i )
				ent.particles[i] = ents.Create( "info_particle_system" )
				ent.particles[i]:SetKeyValue( "effect_name", "WheelDust" )
				ent.particles[i]:SetKeyValue( "start_active", 0 )
				ent.particles[i]:SetOwner( ent )
				ent.particles[i]:SetPos( wheel:GetPos() + Vector( 0, 0, -height ) )
				ent.particles[i]:SetAngles( wheel:GetAngles() )
				ent.particles[i]:Spawn()
				ent.particles[i]:Activate()
				ent.particles[i]:SetParent( ent )
				ent.particles[i].DoNotDuplicate = true
			end
		end
	end )
end
hook.Add( "OnEntityCreated", "GAuto_InitVehicle", InitVehicle )
