
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Spikestrip"
ENT.Author = "Lambda Gaming"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "Automod"

function ENT:SpawnFunction( ply, tr )
	if !tr.Hit then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 1
	local ent = ents.Create( "automod_spikestrip" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
    self:SetModel( "models/props_wasteland/dockplank01b.mdl" )
	self:SetMoveType( MOVETYPE_NONE )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetMaterial( "models/debug/debugwhite" )
	self:SetColor( Color( 109, 109, 109 ) )

	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetUseType( SIMPLE_USE )

		local e = ents.Create( "prop_dynamic" )
		e:SetModel( "models/props_phx/mechanics/slider2.mdl" )
		e:SetPos( self:GetPos() )
		e:SetAngles( self:GetAngles() + Angle( 0, 90, 0 ) )
		e:SetParent( self )
		e:Spawn()

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
	if (phys:IsValid()) then
		phys:Wake()
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
	if IsValid( ent ) and ent:IsVehicle() then
		local vehmodel = ent:GetModel()
		if AM_Config_Blacklist[vehmodel] then return end
		local numwheel = 0
		for i = 1, ent:GetWheelCount() do
			if !IsValid( ent:GetWheel( i ) ) then return end
			local wheelpos = ent:GetWheel( i ):GetPos():Length()
			local entpos = self:GetPos():Length()
			if wheelpos and wheelpos < entpos then --Checks to see what wheel is closest to the strip since there's no easy way of finding out which wheel is actually touching
				entpos = wheelpos
				numwheel = i
				AM_PopTire( ent, numwheel ) --Currently always targets the front right wheel and not the others, even when the back wheels touch first, needs fixed
				self.SpikeCooldown = CurTime() + 1
				break
			end
		end
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