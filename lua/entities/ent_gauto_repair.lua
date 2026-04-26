AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Vehicle Repair Kit"
ENT.Author = "OPGman"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "GAuto"

function ENT:Initialize()
    self:SetModel( "models/Items/HealthKit.mdl" )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
	end
	self:PhysWake()
	self.HealthPercent = 0.3
end

local function Spark( ent )
	local ed = EffectData()
	ed:SetOrigin( ent:GetPos() )
	ed:SetNormal( VectorRand() )
	ed:SetMagnitude( 3 )
	ed:SetScale( 1 )
	ed:SetRadius( 3 )
	util.Effect( "Sparks", ed )
end

function ENT:StartTouch( ent )
	if GAuto.IsDrivable( ent ) then
		local health = ent:GetNWInt( "GAuto_VehicleHealth" )
		local maxHealth = ent:GetNWInt( "GAuto_VehicleMaxHealth" )
		local healthPercent = self.HealthPercent
		if health >= maxHealth then return end
		if health <= 0 then
			ent:Fire( "turnon", "", 0.01 )
		end
		GAuto.AddHealth( ent, maxHealth * healthPercent )
		Spark( self )
		self:EmitSound( "items/smallmedkit1.wav" )
		self:Remove()
	end
end
