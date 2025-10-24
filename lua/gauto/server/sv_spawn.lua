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
		error( "Invalid argument for GAuto.LoadVehicle()." )
		return
	end
	local slashfix = GAuto.TrimModel( model )
	local findvehicle = file.Read( "data_static/gauto/vehicles/"..slashfix..".json", "THIRDPARTY" )
	local findvehicleextra = file.Read( "gauto/vehicles/"..slashfix..".json", "DATA" )
	local finalJson = findvehicle != nil and findvehicle or findvehicleextra
	if finalJson == nil then
		MsgC( color_red, "[GAuto] Warning: '"..model.."' is unsupported. Certain features will be limited or unavailable.\n" )
		return
	end
	GAuto.Vehicles[model] = util.JSONToTable( finalJson )
end

local function PhysicsCollide( veh, data )
	local speed = data.Speed
	local hitent = data.HitEntity
	if IsValid( hitent:GetPhysicsObject() ) and hitent:GetPhysicsObject():GetMass() < 300 and !hitent:IsWorld() then
		return
	end
	for k,v in pairs( constraint.GetTable( veh ) ) do
		--Prevents objects that may be part of the vehicle from damaging it
		if v.Ent1 == hitent then return end
	end
	--Not at all realistic especially since mass isn't a factor, but it provides a good balance between too spongy and too fragile
	local GAuto_PhysDamageMultiplier = GetConVar( "gauto_phys_damage_multiplier" ):GetFloat()
	local formula = ( speed / 98 ) * GAuto_PhysDamageMultiplier
	if speed > 400 then
		if hitent:IsPlayer() or hitent:IsNPC() then return end
		GAuto.TakeDamage( veh, formula )
	end
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
				ent:SetNWInt( "GAuto_VehicleHealth", GAuto.VehicleHealth( vehmodel ) )
				ent:SetNWInt( "GAuto_VehicleMaxHealth", GAuto.VehicleHealth( vehmodel ) )
			end
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
						ent.seat[i] = ents.Create( "prop_vehicle_prisoner_pod" )
						ent.seat[i]:SetModel( "models/nova/airboat_seat.mdl" )
						ent.seat[i]:SetParent( ent )
						ent.seat[i]:SetPos( ent:LocalToWorld( vehseats[i].pos ) )
						ent.seat[i]:SetAngles( ent:LocalToWorldAngles( vehseats[i].ang ) )
						ent.seat[i]:Spawn()
						ent.seat[i]:SetKeyValue( "limitview", 0 ) --Disable prisoner pod view
						ent.seat[i]:SetVehicleEntryAnim( false ) --Disable long entry animation
						ent.seat[i]:SetNoDraw( true )
						ent.seat[i]:SetNotSolid( true )
						ent.seat[i]:DrawShadow( false )
						ent.seat[i]:AddEFlags( EFL_NO_THINK_FUNCTION ) --Disable think function to reduce network usage
						table.Merge( ent.seat[i], { HandleAnimation = function( _, ply )
							--Set player sitting anim, taken from the Gmod wiki
							return ply:SelectWeightedSequence( ACT_HL2MP_SIT )
						end } )
						ent:DeleteOnRemove( ent.seat[i] )
						ent.seat[i]:SetNWBool( "IsGAutoSeat", true )
						ent.seat[i].VehicleTable = {} --Prevents Photon console spam
						ent.seat[i].ID = index
						ent.seat[i].DoNotDuplicate = true --Prevent seats from being duped since they'll spawn twice
					end
				end
			end
		end
		if GAuto_ParticlesEnabled then
			ent.particles = { wheel = {} }
			for i = 0, ent:GetWheelCount() - 1 do
				local wheel = ent:GetWheel( i )
				local height = ent:GetWheelTotalHeight( i )
				local pos = wheel:GetPos() + Vector( 0, 0, -height )
				ent.particles.wheel[i] = GAuto.CreateParticleEffect( ent, "WheelDust", pos )
			end
			local eng = ent:GetAttachment( ent:LookupAttachment( "vehicle_engine" ) )
			local offset = ent:GetNWVector( "GAuto_EngineOffset" )
			local enginePos = eng.Pos + offset
			ent.particles.engineSmoke = GAuto.CreateParticleEffect( ent, "smoke_burning_engine_01", enginePos )
			ent.particles.engineFire = GAuto.CreateParticleEffect( ent, "burning_engine_fire", enginePos )
		end
	end )
end
hook.Add( "OnEntityCreated", "GAuto_InitVehicle", InitVehicle )
