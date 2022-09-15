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
    self:SetModel( GetConVar( "AM_Config_SpikeModel" ):GetString() )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )
		if DarkRP then --RP support that removes the spikestrip after 10 minutes to prevent abuse, should work with any DarkRP-based gamemode even if it's name was changed
			local index = self:EntIndex()
			if !timer.Exists( "Spike_Remove_Timer"..index ) then
				timer.Create( "Spike_Remove_Timer"..index, 600, 1, function()
					if !IsValid( self:GetOwner() ) then --Checks to see if the player is still on the server
						self:Remove()
						return
					end
					if self:GetOwner():isCP() then --Makes sure the player is still a cop so a civi doesn't get a free spikestrip
						self:GetOwner():Give( "weapon_spiketrap" )
						AM_Notify( self:GetOwner(), "Your spikestrip has been returned to you." )
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
			AM_Notify( activator, "You are no longer a cop. Your old spikestrip will be removed." )
			self:Remove()
			return
		end
		activator:Give( "weapon_spikestrip" )
		activator:SelectWeapon( "weapon_spikestrip" )
		AM_Notify( activator, "You have collected your spikestrip." )
		self:Remove()
	else
		local nick = self:GetOwner():Nick()
		local index = self:EntIndex()
		local time = string.ToMinutesSeconds( timer.TimeLeft( "Spike_Remove_Timer"..index ) )
		AM_Notify( activator, "This spikestrip is owned by "..nick.." and will be automatically removed in "..time.."." )
	end
end

function ENT:StartTouch( ent )
	if self.SpikeCooldown and self.SpikeCooldown > CurTime() then return end
	if AM_IsBlackListed( ent ) then return end
	local class = ent:GetClass()
	if class == "prop_vehicle_jeep" then
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

function ENT:OnRemove()
	local index = self:EntIndex()
	if timer.Exists( "Spike_Remove_Timer"..index ) then timer.Remove( "Spike_Remove_Timer"..index ) end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end
