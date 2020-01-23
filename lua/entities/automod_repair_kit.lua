
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Vehicle Repair Kit"
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
    self:SetModel( "models/Items/HealthKit.mdl" )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
	end
 
    local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.HealthPercent = 0.3
end

local function AM_Spark( ent )
	local ed = EffectData()
	ed:SetOrigin( ent:GetPos() )
	ed:SetNormal( VectorRand() )
	ed:SetMagnitude( 3 )
	ed:SetScale( 1 )
	ed:SetRadius( 3 )
	util.Effect( "Sparks", ed )
end

function ENT:StartTouch( ent )
	if ent:GetClass() == "prop_vehicle_jeep" then
		local health = ent:GetNWInt( "AM_VehicleHealth" )
		local maxhealth = ent:GetNWInt( "AM_VehicleMaxHealth" )
		local healthpercent = self.HealthPercent
		if health >= maxhealth then return end
		if health <= 0 then
			ent:Fire( "turnon", "", 0.01 )
		end
		AM_AddHealth( ent, maxhealth * healthpercent )
		AM_Spark( self )
		self:EmitSound( "items/smallmedkit1.wav" )
		self:Remove()
	end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end