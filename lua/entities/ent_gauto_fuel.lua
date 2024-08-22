AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Fuel Can"
ENT.Author = "Lambda Gaming"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "GAuto"

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

local function Splash( ent )
	local ed = EffectData()
	ed:SetOrigin( ent:GetPos() )
	ed:SetNormal( VectorRand() )
	ed:SetMagnitude( 3 )
	ed:SetScale( 1 )
	ed:SetRadius( 3 )
	util.Effect( "watersplash", ed )
end

function ENT:StartTouch( ent )
	if GAuto.IsDrivable( ent ) then
		local fuel = ent:GetNWInt( "GAuto_FuelAmount" )
		local maxfuel = GetConVar( "GAuto_Config_FuelAmount" ):GetInt()
		local fuelpercent = self.FuelPercent
		if fuel >= maxfuel then return end
		GAuto.SetFuel( ent, fuel + ( maxfuel * fuelpercent ) )
		Splash( self )
		self:Remove()
	end
end

function ENT:OnTakeDamage( dmg )
	self:SetHealth( self:Health() - dmg:GetDamage() )
	if self:Health() <= 0 and ( dmg:GetDamageType() == DMG_BULLET or dmg:GetDamageType() == DMG_BLAST ) then
		local cans = #ents.FindByClass( "ent_gauto_fuel" )
		if cans > 3 then self:Remove() Splash( self ) return end --Prevents a chain of explosions from going off, causing the server to freeze or crash if VFire is installed
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
