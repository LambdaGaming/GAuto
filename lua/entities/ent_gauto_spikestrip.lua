AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Spikestrip"
ENT.Author = "OPGman"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "GAuto"

local vehicles = {
	["prop_vehicle_jeep"] = true,
	["prop_vehicle_jeep_old"] = true,
	["jeep_owned_by_reckless_driver_kleiner"] = true
}

function ENT:SpawnFunction( ply, tr, name )
	if ( !tr.Hit ) then return end
	local pos = tr.HitPos + tr.HitNormal
	local offset = ply:GetAngles().y + cvars.Number( "gauto_spike_model_offset" )
	local e = ents.Create( name )
	e:SetPos( pos )
	e:SetAngles( Angle( 0, offset, 0 ) )
	e:Spawn()
	e:Activate()
	e:SetOwner( ply )
	return e
end

function ENT:Initialize()
    self:SetModel( cvars.String( "gauto_spike_model" ) )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
		if DarkRP then
			--Removes the spikestrip after 10 minutes to prevent abuse, works with any DarkRP-based gamemode
			local index = self:EntIndex()
			if !timer.Exists( "Spike_Remove_Timer"..index ) then
				timer.Create( "Spike_Remove_Timer"..index, 600, 1, function()
					local owner = self:GetOwner()
					if IsValid( owner ) and owner:isCP() then
						owner:Give( "weapon_gauto_spikestrip" )
						GAuto.Notify( owner, "Your spikestrip has been returned to you." )
					end
					self:Remove()
				end )
			end
		end
	end
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:EnableMotion( false )
	end
end

function ENT:Use( ply )
	if !IsValid( self:GetOwner() ) then
		GAuto.Notify( ply, "The owner of this spikestrip has disconnected. Removing." )
		self:EmitSound( "items/ammocrate_close.wav" )
		self:Remove()
		return
	end
	if self:GetOwner() == ply then
		if DarkRP and !ply:isCP() then
			GAuto.Notify( ply, "You are no longer a cop. Your old spikestrip will be removed." )
			self:Remove()
			return
		end
		ply:Give( "weapon_gauto_spikestrip" )
		ply:SelectWeapon( "weapon_gauto_spikestrip" )
		GAuto.Notify( ply, "You have collected your spikestrip." )
		self:EmitSound( "items/ammocrate_close.wav" )
		self:Remove()
	else
		local nick = self:GetOwner():Nick()
		local index = self:EntIndex()
		local time = string.ToMinutesSeconds( timer.TimeLeft( "Spike_Remove_Timer"..index ) )
		GAuto.Notify( ply, "This spikestrip is owned by "..nick.." and will be automatically removed in "..time.."." )
	end
end

function ENT:StartTouch( ent )
	if GAuto.IsBlackListed( ent ) then return end
	local class = ent:GetClass()
	if vehicles[class] then
		--Checks to see what wheel is closest to the strip since there's no easy way of finding out which wheel is actually touching
		local wheelPos = {}
		for i = 0, ent:GetWheelCount() - 1 do
			local wheel = ent:GetWheel( i )
			if !IsValid( wheel ) then return end
			local sqrPos = wheel:GetPos():DistToSqr( self:GetPos() )
			table.insert( wheelPos, { i, sqrPos } )
		end
		table.sort( wheelPos, function( a, b ) return a[2] < b[2] end )
		GAuto.PopTire( ent, wheelPos[1][1] )
	elseif class == "gmod_sent_vehicle_fphysics_wheel" then --Simfphys support
		ent:SetDamaged( true )
	elseif class == "lvs_wheeldrive_wheel" or scripted_ents.IsBasedOn( class, "lvs_wheeldrive_wheel" ) then --LVS support
		ent:SetSuspensionHeight( -1 )
		ent:SetSuspensionStiffness( 1 )
	elseif ent.IsGlideVehicle then --Glide support
		local wheelPos = {}
		for i = 1, #ent.wheels do
			local wheel = ent.wheels[i]
			if !IsValid( wheel ) then return end
			local sqrPos = wheel:GetPos():DistToSqr( self:GetPos() )
			table.insert( wheelPos, { i, sqrPos } )
		end
		table.sort( wheelPos, function( a, b ) return a[2] < b[2] end )
		ent.wheels[wheelPos[1][1]]:Blow()
	end
end

function ENT:OnRemove()
	local index = self:EntIndex()
	if timer.Exists( "Spike_Remove_Timer"..index ) then timer.Remove( "Spike_Remove_Timer"..index ) end
end
