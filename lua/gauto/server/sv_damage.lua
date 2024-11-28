function GAuto.DestroyCheck( veh ) --Disables the engine and sets the vehicle on fire if it's health is 0
	if veh:GetNWInt( "GAuto_VehicleHealth" ) <= 0 and !veh:GetNWBool( "GAuto_HasExploded" ) then
		local GAuto_ExplosionEnabled = GetConVar( "GAuto_Config_DamageExplosionEnabled" ):GetBool()
		local GAuto_ExplodeRemoveTime = GetConVar( "GAuto_Config_ExplodeRemoveTime" ):GetInt()
		local GAuto_CharringTime = GetConVar( "GAuto_Config_CharringTime" ):GetInt()
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

function GAuto.SmokeCheck( veh )
	local health = veh:GetNWInt( "GAuto_VehicleHealth" )
	local maxhealth = veh:GetNWInt( "GAuto_VehicleMaxHealth" )
	if health > ( maxhealth * 0.3 ) or health <= 0 then
		if veh:GetNWBool( "GAuto_IsSmoking" ) then
			veh:SetNWBool( "GAuto_IsSmoking", false )
		end
	else
		if !veh:GetNWBool( "GAuto_IsSmoking" ) then
			veh:SetNWBool( "GAuto_IsSmoking", true )
		end
	end
end

function GAuto.ToggleGodMode( veh )
	local enabled = veh:GetNWBool( "GodMode" )
	if enabled then
		veh:SetNWBool( "GodMode", false )
		return
	end
	veh:SetNWBool( "GodMode", true )
end

function GAuto.GodModeEnabled( veh )
	return veh:GetNWBool( "GodMode" )
end

function GAuto.TakeDamage( veh, dam ) --Takes away health from the vehicle, also runs the destroy check every time the health is set
	local GAuto_HealthEnabled = GetConVar( "GAuto_Config_HealthEnabled" ):GetBool()
	if GAuto_HealthEnabled and !GAuto.GodModeEnabled( veh ) and dam > 0.5 then
		if veh.DamageCooldown and veh.DamageCooldown > CurTime() then return end
		local health = veh:GetNWInt( "GAuto_VehicleHealth" )
		local maxhealth = veh:GetNWInt( "GAuto_VehicleMaxHealth" )
		local roundhp = math.Round( health - dam )
		local newhp = math.Clamp( roundhp, 0, maxhealth )
		veh:SetNWInt( "GAuto_VehicleHealth", newhp )
		GAuto.DestroyCheck( veh )
		GAuto.SmokeCheck( veh )
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
	GAuto.SmokeCheck( veh )
end

function GAuto.SetFuel( veh, amount )
	if GAuto.IsBlackListed( veh ) then return end
	local GAuto_FuelAmount = GetConVar( "GAuto_Config_FuelAmount" ):GetInt()
	local clampedamount = math.Clamp( amount, 0, GAuto_FuelAmount )
	veh:SetNWInt( "GAuto_FuelAmount", clampedamount )
	if amount > 0 and veh.NoFuel then
		veh.NoFuel = false
		veh:Fire( "turnon", "", 0.01 )
		if GAuto.GodModeEnabled( veh ) then GAuto.ToggleGodMode( veh ) end
	end
end

function GAuto.PopTire( veh, wheel )
	local GAuto_TirePopEnabled = GetConVar( "GAuto_Config_TirePopEnabled" ):GetBool()
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
	local GAuto_TirePopEnabled = GetConVar( "GAuto_Config_TirePopEnabled" ):GetBool()
	local GAuto_TireHealth = GetConVar( "GAuto_Config_TireHealth" ):GetInt()
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
	local GAuto_TirePopEnabled = GetConVar( "GAuto_Config_TirePopEnabled" ):GetBool()
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
	local GAuto_ExplosionEnabled = GetConVar( "GAuto_Config_DamageExplosionEnabled" ):GetBool()
	local GAuto_ExplodeRemoveTime = GetConVar( "GAuto_Config_ExplodeRemoveTime" ):GetInt()
	local GAuto_CharringTime = GetConVar( "GAuto_Config_CharringTime" ):GetInt()
	local e = ents.Create( "prop_physics" )
	e:SetPos( veh:GetPos() )
	e:SetModel( veh:GetModel() )
	e:SetAngles( veh:GetAngles() )
	e:SetColor( Color( 128, 128, 128 ) )
	e:SetMaterial( "models/props_foliage/tree_deciduous_01a_trunk" )
	e:Spawn()
	veh:Remove()
	if GAuto_ExplodeRemoveTime >= 0 then
		timer.Simple( GAuto_ExplodeRemoveTime, function()
			if IsValid( veh ) then veh:Remove() end
		end )
	end
end

local function ProcessDamage( ent, dmg )
	local GAuto_HealthEnabled = GetConVar( "GAuto_Config_HealthEnabled" ):GetBool()
	local GAuto_BulletDamageEnabled = GetConVar( "GAuto_Config_BulletDamageEnabled" ):GetBool()
	local GAuto_ScalePlayerDamage = GetConVar( "GAuto_Config_ScalePlayerDamage" ):GetBool()
	if GAuto_HealthEnabled then
		if ent:IsOnFire() then return end --Prevent car from constantly igniting itself if it's on fire
		if GAuto.IsDrivable( ent ) then
			if dmg:IsBulletDamage() and GAuto_BulletDamageEnabled then
				GAuto.TakeDamage( ent, dmg:GetDamage() * 450 )
				GAuto.PopCheck( dmg, ent )
			else
				GAuto.TakeDamage( ent, dmg:GetDamage() )
			end
		end
		if ent:IsVehicle() and ent.seat then
			for k,v in pairs( ent.seat ) do
				if !IsValid( v ) then return end
				local driver = v:GetDriver()
				if IsValid( driver ) then
					if GAuto_ScalePlayerDamage then dmg:ScaleDamage( 0.35 ) end
					driver:TakeDamage( dmg:GetDamage() ) --Fix for passengers not taking damage
				end
			end
		end
		if GAuto_ScalePlayerDamage and ent:IsPlayer() then
			if dmg:GetAttacker():IsVehicle() then
				dmg:SetDamageType( DMG_VEHICLE )
			end
			if dmg:IsDamageType( DMG_VEHICLE ) or ( ent:InVehicle() and dmg:IsDamageType( DMG_BLAST ) ) then
				dmg:ScaleDamage( 0.35 ) --Scales damage for drivers, passengers, and players who are hit by vehicles
				return dmg
			end
		end
	end
end
hook.Add( "EntityTakeDamage", "GAuto_TakeDamage", ProcessDamage )

hook.Add( "vFireEntityStartedBurning", "GAuto_OnIgnite", function( ent )
	local GAuto_ExplosionEnabled = GetConVar( "GAuto_Config_DamageExplosionEnabled" ):GetBool()
	local GAuto_CharringTime = GetConVar( "GAuto_Config_CharringTime" ):GetInt()
	if GAuto_ExplosionEnabled and GAuto_CharringTime >= 0 and !GAuto.IsBlackListed( ent ) and !timer.Exists( "GAuto_VehicleExplode"..ent:EntIndex() ) then
		timer.Create( "GAuto_VehicleExplode"..ent:EntIndex(), GAuto_CharringTime, 1, function()
			if !IsValid( ent ) then return end
			GAuto.Explode( veh )
			GAuto.CreateCharredProp( veh )
		end )
	end
end )

hook.Add( "vFireEntityStoppedBurning", "GAuto_OnExtinguish", function( ent )
	if !GAuto.IsBlackListed( ent ) and timer.Exists( "GAuto_VehicleExplode"..ent:EntIndex() ) then
		timer.Remove( "GAuto_VehicleExplode"..ent:EntIndex() )
	end
end )
