function AM_DestroyCheck( veh ) --Disables the engine and sets the vehicle on fire if it's health is 0
	if veh:GetNWInt( "AM_VehicleHealth" ) <= 0 and !veh:GetNWBool( "AM_HasExploded" ) then
		local AM_ExplosionEnabled = GetConVar( "AM_Config_DamageExplosionEnabled" ):GetBool()
		local AM_ExplodeRemoveEnabled = GetConVar( "AM_Config_ExplodeRemoveEnabled" ):GetBool()
		local AM_ExplodeRemoveTime = GetConVar( "AM_Config_ExplodeRemoveTime" ):GetInt()
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
			if AM_ExplodeRemoveEnabled then
				timer.Simple( AM_ExplodeRemoveTime, function()
					if IsValid( veh ) then veh:Remove() end
				end )
			end
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
	local AM_HealthEnabled = GetConVar( "AM_Config_HealthEnabled" ):GetBool()
	if AM_HealthEnabled and AM_GodModeEnabled( veh ) and dam > 0.5 and ( veh.DamageCooldown and veh.DamageCooldown > CurTime() ) then
		local health = veh:GetNWInt( "AM_VehicleHealth" )
		local maxhealth = veh:GetNWInt( "AM_VehicleMaxHealth" )
		local roundhp = math.Round( health - dam )
		local newhp = math.Clamp( roundhp, 0, maxhealth )
		veh:SetNWInt( "AM_VehicleHealth", newhp )
		AM_DestroyCheck( veh )
		AM_SmokeCheck( veh )
		hook.Run( "AM_OnTakeDamage", veh, dam )
	end
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

function AM_SetFuel( veh, amount )
	if AM_IsBlackListed( veh ) then return end
	local AM_FuelAmount = GetConVar( "AM_Config_FuelAmount" ):GetInt()
	local clampedamount = math.Clamp( amount, 0, AM_FuelAmount )
	veh:SetNWInt( "AM_FuelAmount", clampedamount )
	if amount > 0 and veh.NoFuel then
		veh.NoFuel = false
		veh:Fire( "turnon", "", 0.01 )
		if AM_GodModeEnabled( veh ) then AM_ToggleGodMode( veh ) end
	end
end

function AM_PopTire( veh, wheel )
	local AM_TirePopEnabled = GetConVar( "AM_Config_TirePopEnabled" ):GetBool()
	if AM_TirePopEnabled and !AM_IsBlackListed( veh ) and veh:IsVehicle() then
		if veh.WheelHealth and veh.WheelHealth[wheel] and veh.WheelHealth[wheel] <= 0 then
			return --Don't try to pop a tire that's already popped
		end

		--Simulates the tire slowly losing air
		local spring = 500.1
		local deflatesound = CreateSound( veh, "ambient/gas/steam2.wav" )
		local index = veh:EntIndex()
		deflatesound:Play()
		deflatesound:ChangeVolume( 0.8 )
		deflatesound:FadeOut( 12 )
		timer.Create( "AM_PopTimer"..index..wheel, 1, 12, function()
			if spring > 499 and IsValid( veh ) then
				spring = spring - 0.1
				veh:SetSpringLength( wheel, spring )
			end
		end )

		veh:EmitSound( "HL1/ambience/steamburst1.wav" )
		veh.WheelHealth = veh.WheelHealth or {}
		veh.WheelHealth[wheel] = 0
	end
end

function AM_PopCheck( dmg, veh )
	local AM_TirePopEnabled = GetConVar( "AM_Config_TirePopEnabled" ):GetBool()
	local AM_TireHealth = GetConVar( "AM_Config_TireHealth" ):GetInt()
	if AM_TirePopEnabled and !AM_IsBlackListed( veh ) then
		local pos = dmg:GetDamagePosition()
		local dmgamount = dmg:GetDamage() * 300
		for i = 0, veh:GetWheelCount() - 1 do
			local wheel = veh:GetWheel( i )
			if IsValid( wheel ) then
				if veh.WheelHealth and veh.WheelHealth[i] and veh.WheelHealth[i] <= 0 then
					return --Don't try to pop a tire that's already popped
				end
				local dist = wheel:GetPos():DistToSqr( pos )
				local diameter = veh:GetWheelBaseHeight( i )
				local diametersqr = diameter * diameter
				if dist <= diametersqr then --Only deal damage if the bullets hit within the wheel's diameter
					veh.WheelHealth = veh.WheelHealth or {}
					veh.WheelHealth[i] = ( veh.WheelHealth[i] or AM_TireHealth ) - dmgamount
					if veh.WheelHealth[i] <= 0 then
						AM_PopTire( veh, i )
					end
				end
			end
		end
	end
end

function AM_RepairTire( veh )
	local AM_TirePopEnabled = GetConVar( "AM_Config_TirePopEnabled" ):GetBool()
	if AM_TirePopEnabled and !AM_IsBlackListed( veh ) and veh:IsVehicle() then
		local vehmodel = veh:GetModel()
		for i = 0, veh:GetWheelCount() - 1 do
			veh:SetSpringLength( i, 500.1 )
			veh:GetWheel( i ):SetDamping( 0, 0 )
			veh.WheelHealth = {}
		end
	end
end

local function AM_ProcessDamage( ent, dmg )
	local AM_HealthEnabled = GetConVar( "AM_Config_HealthEnabled" ):GetBool()
	local AM_BulletDamageEnabled = GetConVar( "AM_Config_BulletDamageEnabled" ):GetBool()
	local AM_ScalePlayerDamage = GetConVar( "AM_Config_ScalePlayerDamage" ):GetBool()
	if AM_HealthEnabled then
		if AM_IsBlackListed( ent ) or ent:IsOnFire() then return end --Prevent car from constantly igniting itself if it's on fire
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
				if !IsValid( v ) then return end
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
end
hook.Add( "EntityTakeDamage", "AM_TakeDamage", AM_ProcessDamage )
