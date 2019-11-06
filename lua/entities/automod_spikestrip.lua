
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
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetMaterial( "models/shiny" )
	self:SetColor( Color( 109, 109, 109 ) )
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		local e = ents.Create( "prop_dynamic" )
		e:SetModel( "models/props_phx/mechanics/slider2.mdl" )
		e:SetPos( self:GetPos() )
		e:SetAngles( self:GetAngles() + Angle( 0, 90, 0 ) )
		e:SetParent( self )
		e:Spawn()
	end
 
    local phys = self:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
end

function ENT:Use( activator, caller )
	activator:Give( self:GetClass() )
	self:Remove()
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
				AM_PopTire( ent, numwheel ) --Currently always targets the front right wheel and not the others, even when the back wheels touch first
				self.SpikeCooldown = CurTime() + 1
				break
			end
		end
	end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end