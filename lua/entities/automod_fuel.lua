
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Fuel Can"
ENT.Author = "Lambda Gaming"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "Automod"

function ENT:SpawnFunction( ply, tr, name )
	if !tr.Hit then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 5
	local ent = ents.Create( name )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
    self:SetModel( "models/props_junk/gascan001a.mdl" )
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	if SERVER then
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetHealth( 25 )
	end
 
    local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.FuelPercent = 0.75
end

local function AM_Splash( ent )
	local ed = EffectData()
	ed:SetOrigin( ent:GetPos() )
	ed:SetNormal( VectorRand() )
	ed:SetMagnitude( 3 )
	ed:SetScale( 1 )
	ed:SetRadius( 3 )
	util.Effect( "watersplash", ed )
end

function ENT:StartTouch( ent )
	if ent:GetClass() == "prop_vehicle_jeep" then
		local fuel = ent:GetNWInt( "AM_FuelAmount" )
		local maxfuel = GetConVar( "AM_Config_FuelAmount" ):GetInt()
		local fuelpercent = self.FuelPercent
		if fuel >= maxfuel then return end
		AM_SetFuel( ent, fuel + ( maxfuel * fuelpercent ) )
		AM_Splash( self )
		self:Remove()
	end
end

function ENT:OnTakeDamage( dmg )
	self:SetHealth( self:Health() - dmg:GetDamage() )
	if self:Health() <= 0 and ( dmg:GetDamageType() == DMG_BULLET or dmg:GetDamageType() == DMG_BLAST ) then
		local cans = #ents.FindByClass( "automod_fuel" )
		if cans > 3 then self:Remove() AM_Splash( self ) return end --Prevents a chain of explosions from going off, causing the server to freeze or crash if VFire is installed
		self:Explode()
	end
end

function ENT:Explode()
	if self.Exploding then return end
	self.Exploding = true
	local explosion = ents.Create( "env_explosion" )			
	explosion:SetPos( self:GetPos() )
	explosion:SetKeyValue( "iMagnitude", 200 )
	explosion:Spawn()
	explosion:Activate()
	explosion:Fire( "Explode", 0, 0 )
	self:Remove()
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end