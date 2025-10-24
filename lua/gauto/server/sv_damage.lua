function GAuto.DestroyCheck( veh ) --Disables the engine and sets the vehicle on fire if it's health is 0
	if veh:GetNWInt( "GAuto_VehicleHealth" ) <= 0 and !veh:GetNWBool( "GAuto_HasExploded" ) then
		local GAuto_ExplosionEnabled = GetConVar( "gauto_damage_explosion_enabled" ):GetBool()
		local GAuto_ExplodeRemoveTime = GetConVar( "gauto_explode_remove_time" ):GetInt()
		local GAuto_CharringTime = GetConVar( "gauto_charring_time" ):GetInt()
		veh:Fire( "turnoff", "", 0.01 )
		if vFireInstalled then --Only ignites the vehicle if VFire is installed since otherwise it looks weird
			veh:Ignite()
		end
		if GAuto_ExplosionEnabled then
			GAuto.Explode( veh )
			if ( !vFireInstalled or GAuto_CharringTime < 0 ) and GAuto_ExplodeRemoveTime >= 0 then
				timer.Simple( GAuto_ExplodeRemoveTime, function()
					if IsValid( veh ) then veh:Remove() end
				end )
			end
		end
		veh:SetNWBool( "GAuto_HasExploded", true )
		hook.Run( "GAuto_OnVehicleDestroyed", veh )
	end
end

function GAuto.UpdateDamageEffects( veh )
	if !GetConVar( "gauto_particles_enabled" ):GetBool() then return end
	local health = veh:GetNWInt( "GAuto_VehicleHealth" )
	local maxHealth = veh:GetNWInt( "GAuto_VehicleMaxHealth" )
	local canFlame = health == 0
	local canSmoke = health <= ( maxHealth * 0.3 ) and health > 0
	local fire = veh.particles.engineFire
	local smoke = veh.particles.engineSmoke
	if canFlame then
		smoke:Fire( "Stop" )
		fire:Fire( "Start" )
	elseif canSmoke then
		smoke:Fire( "Start" )
		fire:Fire( "Stop" )
	else
		smoke:Fire( "Stop" )
		fire:Fire( "Stop" )
	end
end

function GAuto.ToggleGodMode( veh )
	local enabled = veh:GetNWBool( "GodMode" )
	veh:SetNWBool( "GodMode", !enabled )
end

function GAuto.GodModeEnabled( veh )
	return veh:GetNWBool( "GodMode" )
end

function GAuto.TakeDamage( veh, dam ) --Takes away health from the vehicle, also runs the destroy check every time the health is set
	local GAuto_HealthEnabled = GetConVar( "gauto_health_enabled" ):GetBool()
	if GAuto_HealthEnabled and !GAuto.GodModeEnabled( veh ) and dam >= 0.1 then
		if veh.DamageCooldown and veh.DamageCooldown > CurTime() then return end
		local health = veh:GetNWInt( "GAuto_VehicleHealth" )
		local maxhealth = veh:GetNWInt( "GAuto_VehicleMaxHealth" )
		local roundhp = math.Round( health - dam, 2 )
		local newhp = math.Clamp( roundhp, 0, maxhealth )
		veh:SetNWInt( "GAuto_VehicleHealth", newhp )
		GAuto.DestroyCheck( veh )
		GAuto.UpdateDamageEffects( veh )
		hook.Run( "GAuto_OnTakeDamage", veh, dam )
	end
end

function GAuto.AddHealth( veh, hp ) --Adds health to the vehicle, nothing special
	local health = veh:GetNWInt( "GAuto_VehicleHealth" )
	local maxhealth = veh:GetNWInt( "GAuto_VehicleMaxHealth" )
	local roundhp = math.Round( health + hp, 2 )
	local newhp = math.Clamp( roundhp, 0, maxhealth )
	if veh:GetNWBool( "GAuto_HasExploded" ) then
		veh:SetNWBool( "GAuto_HasExploded", false )
	end
	veh:SetNWInt( "GAuto_VehicleHealth", newhp )
	hook.Run( "GAuto_OnAddHealth", veh, hp )
	GAuto.UpdateDamageEffects( veh )
end

function GAuto.SetFuel( veh, amount )
	if GAuto.IsBlackListed( veh ) then return end
	local GAuto_FuelAmount = GetConVar( "gauto_fuel_amount" ):GetInt()
	local clampedamount = math.Clamp( amount, 0, GAuto_FuelAmount )
	veh:SetNWInt( "GAuto_FuelAmount", clampedamount )
	if amount > 0 and veh.NoFuel then
		veh.NoFuel = false
		veh:Fire( "turnon", "", 0.01 )
		if GAuto.GodModeEnabled( veh ) then GAuto.ToggleGodMode( veh ) end
	end
end

function GAuto.PopTire( veh, wheel )
	local GAuto_TirePopEnabled = GetConVar( "gauto_tire_damage_enabled" ):GetBool()
	if GAuto_TirePopEnabled and !GAuto.IsBlackListed( veh ) then
		local canPop = hook.Run( "GAuto_CanPopTire", veh, wheel )
		if canPop == false then return end

		--Simulates the tire slowly losing air
		local spring = 500.1
		local deflatesound = CreateSound( veh, "ambient/gas/steam2.wav" )
		local index = veh:EntIndex()
		deflatesound:Play()
		deflatesound:ChangeVolume( 0.8 )
		deflatesound:FadeOut( 12 )
		timer.Create( "GAuto_PopTimer"..index..wheel, 1, 12, function()
			if spring > 499 and IsValid( veh ) then
				spring = spring - 0.1
				veh:SetSpringLength( wheel, spring )
			end
		end )

		veh:EmitSound( "HL1/ambience/steamburst1.wav" )
		veh.WheelHealth = veh.WheelHealth or {}
		veh.WheelHealth[wheel] = 0
		hook.Run( "GAuto_OnTirePopped", veh, wheel )
	end
end

function GAuto.PopCheck( dmg, veh )
	local GAuto_TirePopEnabled = GetConVar( "gauto_tire_damage_enabled" ):GetBool()
	local GAuto_TireHealth = GetConVar( "gauto_tire_health" ):GetInt()
	if GAuto_TirePopEnabled and !GAuto.IsBlackListed( veh ) then
		local pos = dmg:GetDamagePosition()
		local dmgamount = dmg:GetDamage() * 300
		for i = 0, veh:GetWheelCount() - 1 do
			local wheel = veh:GetWheel( i )
			if !IsValid( wheel ) or ( veh.WheelHealth and veh.WheelHealth[i] and veh.WheelHealth[i] <= 0 ) then
				--Don't try to pop a tire that's invalid or already popped
				continue
			end
			local dist = wheel:GetPos():DistToSqr( pos )
			local diameter = veh:GetWheelBaseHeight( i ) * 16 --Increase diameter since the base height doesn't cover the whole visible wheel
			if dist <= diameter then --Only deal damage if the bullets hit within the wheel's diameter
				veh.WheelHealth = veh.WheelHealth or {}
				veh.WheelHealth[i] = ( veh.WheelHealth[i] or GAuto_TireHealth ) - dmgamount
				if veh.WheelHealth[i] <= 0 then
					GAuto.PopTire( veh, i )
				end
			end
		end
	end
end

function GAuto.RepairTire( veh, wheel )
	local GAuto_TirePopEnabled = GetConVar( "gauto_tire_damage_enabled" ):GetBool()
	if GAuto_TirePopEnabled and !GAuto.IsBlackListed( veh ) then
		if wheel then
			veh:SetSpringLength( wheel, 500.1 )
			veh:GetWheel( wheel ):SetDamping( 0, 0 )
			veh.WheelHealth[wheel] = nil
			hook.Run( "GAuto_OnTireRepaired", veh, wheel )
			return
		end
		for i = 0, veh:GetWheelCount() - 1 do
			veh:SetSpringLength( i, 500.1 )
			veh:GetWheel( i ):SetDamping( 0, 0 )
			veh.WheelHealth = {}
			hook.Run( "GAuto_OnTireRepaired", veh, -1 )
		end
	end
end

function GAuto.Explode( veh )
	local eng = veh:GetAttachment( veh:LookupAttachment( "vehicle_engine" ) )
	local offset = veh:GetNWVector( "GAuto_EngineOffset" )
	local e = ents.Create( "env_explosion" )
	e:SetPos( eng and ( eng.Pos + offset ) or vector_origin )
	e:Spawn()
	e:SetKeyValue( "iMagnitude", 50 )
	e:Fire( "Explode", 0, 0 )
end

function GAuto.CreateCharredProp( veh )
	local eng = veh:GetAttachment( veh:LookupAttachment( "vehicle_engine" ) )
	local offset = veh:GetNWVector( "GAuto_EngineOffset" )
	local engPos = eng and ( eng.Pos + offset ) or vector_origin
	local GAuto_ExplodeRemoveTime = GetConVar( "gauto_explode_remove_time" ):GetInt()
	local e = ents.Create( "prop_physics" )
	e:SetPos( veh:GetPos() )
	e:SetModel( veh:GetModel() )
	e:SetAngles( veh:GetAngles() )
	e:SetColor( Color( 128, 128, 128 ) )
	e:SetMaterial( "models/props_foliage/tree_deciduous_01a_trunk" )
	e:Spawn()
	veh:Remove()
	local smoke = GAuto.CreateParticleEffect( e, "smoke_exhaust_01", engPos )
	smoke:Fire( "Start" )
	if GAuto_ExplodeRemoveTime >= 0 then
		timer.Simple( GAuto_ExplodeRemoveTime, function()
			if IsValid( veh ) then veh:Remove() end
		end )
	end
end

local function ProcessDamage( ent, dmg )
	local GAuto_HealthEnabled = GetConVar( "gauto_health_enabled" ):GetBool()
	local GAuto_BulletDamageMultiplier = GetConVar( "gauto_bullet_damage_multiplier" ):GetFloat()
	local GAuto_PlayerDamageMultiplier = GetConVar( "gauto_player_damage_multiplier" ):GetFloat()
	if GAuto_HealthEnabled then
		if ent:IsOnFire() then return end --Prevent car from constantly igniting itself if it's on fire
		if GAuto.IsDrivable( ent ) then
			if dmg:IsDamageType( DMG_BULLET + DMG_SLASH + DMG_CLUB ) then
				GAuto.TakeDamage( ent, 0.5 * GAuto_BulletDamageMultiplier )
				GAuto.PopCheck( dmg, ent )
			else
				GAuto.TakeDamage( ent, dmg:GetDamage() )
			end
		end
		if ent:IsPlayer() then
			if dmg:GetAttacker():IsVehicle() then
				dmg:SetDamageType( DMG_VEHICLE )
			end
			if dmg:IsDamageType( DMG_VEHICLE ) or ( ent:InVehicle() and dmg:IsDamageType( DMG_BLAST ) ) then
				--Scales damage for drivers and players who are hit by vehicles
				dmg:ScaleDamage( GAuto_PlayerDamageMultiplier )
			end

			--Make sure passengers take damage too
			local veh = ent:GetVehicle()
			if IsValid( veh ) and veh.seat then
				for k,v in pairs( veh.seat ) do
					if !IsValid( v ) then continue end
					local driver = v:GetDriver()
					if IsValid( driver ) then
						driver:TakeDamage( dmg:GetDamage() )
					end
				end
			end
		end
	end
end
hook.Add( "EntityTakeDamage", "GAuto_TakeDamage", ProcessDamage )

hook.Add( "vFireEntityStartedBurning", "GAuto_OnIgnite", function( ent )
	local GAuto_ExplosionEnabled = GetConVar( "gauto_damage_explosion_enabled" ):GetBool()
	local GAuto_CharringTime = GetConVar( "gauto_charring_time" ):GetInt()
	if GAuto_ExplosionEnabled and GAuto_CharringTime >= 0 and !GAuto.IsBlackListed( ent ) and !timer.Exists( "GAuto_VehicleExplode"..ent:EntIndex() ) then
		timer.Create( "GAuto_VehicleExplode"..ent:EntIndex(), GAuto_CharringTime, 1, function()
			if !IsValid( ent ) then return end
			GAuto.Explode( ent )
			GAuto.CreateCharredProp( ent )
		end )
	end
end )

hook.Add( "vFireEntityStoppedBurning", "GAuto_OnExtinguish", function( ent )
	if !GAuto.IsBlackListed( ent ) and timer.Exists( "GAuto_VehicleExplode"..ent:EntIndex() ) then
		timer.Remove( "GAuto_VehicleExplode"..ent:EntIndex() )
	end
end )
