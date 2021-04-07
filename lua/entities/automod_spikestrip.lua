
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Spikestrip"
ENT.Author = "Lambda Gaming"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "Automod"

function ENT:SpawnFunction( ply, tr, name )
	if !tr.Hit then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	local ent = ents.Create( name )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
    self:SetModel( "models/fwhykay/hot_pursuit/props/spike_strip/police_spike.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )

	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )

		if DarkRP then --RP support that removes the spikestrip after 10 minutes to prevent abuse, should work with any DarkRP-based gamemode even if it's name was changed
			if !timer.Exists( "Spike_Remove_Timer"..self:EntIndex() ) then
				timer.Create( "Spike_Remove_Timer"..self:EntIndex(), 600, 1, function()
					if !IsValid( self:GetOwner() ) then --Checks to see if the player is still on the server
						self:Remove()
						return
					end
					if self:GetOwner():isCP() then --Makes sure the player is still a cop so a civi doesn't get a free spikestrip
						self:GetOwner():Give( "weapon_spiketrap" )
						AM_Notify( self:GetOwner(), "Your spikestrip has been removed. It has been put back into your weapon slot." )
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

function ENT:Use( activator, caller )
	if self:GetOwner() == activator then
		if DarkRP and !activator:isCP() then --Prevents former cops from taking back their old strips as a civi
			AM_Notify( activator, "You are no longer a cop, your old spikestrip will be removed." )
			self:Remove()
			return
		end
		activator:Give( "weapon_spikestrip" )
		activator:SelectWeapon( "weapon_spikestrip" )
		AM_Notify( activator, "You have collected your spikestrip." )
		self:Remove()
	else
		AM_Notify( activator, "This spikestrip is owned by "..self:GetOwner():Nick().." and will be automatically removed in "..string.ToMinutesSeconds( timer.TimeLeft( "Spike_Remove_Timer"..self:EntIndex() ) ).."." )
	end
end

function ENT:StartTouch( ent )
	if self.SpikeCooldown and self.SpikeCooldown > CurTime() then return end
	if IsValid( ent ) then
		local class = ent:GetClass()
		if class == "prop_vehicle_jeep" then
			if IsBlacklisted( ent ) then return end
			local wheelpos = {}
			for i = 0, ent:GetWheelCount() - 1 do
				local wheel = ent:GetWheel( i )
				if !IsValid( wheel ) then return end
				local sqrpos = wheel:GetPos():DistToSqr( self:GetPos() )
				table.insert( wheelpos, { i, sqrpos } )
			end
			table.sort( wheelpos, function( a, b ) return a[2] < b[2] end ) --Checks to see what wheel is closest to the strip since there's no easy way of finding out which wheel is actually touching
			AM_PopTire( ent, wheelpos[1][1] )
		elseif class == "gmod_sent_vehicle_fphysics_wheel" then --Simfphy's support
			ent:SetDamaged( true )
		end
		self.SpikeCooldown = CurTime() + 1
	end
end

function ENT:OnRemove()
	if timer.Exists( "Spike_Remove_Timer"..self:EntIndex() ) then timer.Remove( "Spike_Remove_Timer"..self:EntIndex() ) end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end