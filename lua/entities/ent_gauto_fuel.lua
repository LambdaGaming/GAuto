AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Fuel Can"
ENT.Author = "OPGman"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "GAuto"

function ENT:Initialize()
    self:SetModel( "models/props_junk/gascan001a.mdl" )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	if SERVER then
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetHealth( 25 )
	end
	self:PhysWake()
	self.FuelPercent = 0.75
end

function ENT:Splash()
	local ed = EffectData()
	ed:SetOrigin( self:GetPos() )
	ed:SetNormal( VectorRand() )
	ed:SetMagnitude( 3 )
	ed:SetScale( 1 )
	ed:SetRadius( 3 )
	util.Effect( "watersplash", ed )
end

function ENT:StartTouch( ent )
	if GAuto.IsDrivable( ent ) then
		local fuel = ent:GetNWInt( "GAuto_FuelAmount" )
		local maxFuel = cvars.Number( "gauto_fuel_amount" )
		local fuelPercent = self.FuelPercent
		if fuel >= maxFuel then return end
		GAuto.SetFuel( ent, fuel + ( maxFuel * fuelPercent ) )
		self:Splash()
		self:Remove()
	end
end

function ENT:OnTakeDamage( dmg )
	self:SetHealth( self:Health() - dmg:GetDamage() )
	if self:Health() <= 0 and ( dmg:GetDamageType() == DMG_BULLET or dmg:GetDamageType() == DMG_BLAST ) then
		local cans = #ents.FindByClass( "ent_gauto_fuel" )
		if cans > 3 then
			--Prevents a chain of explosions from going off, causing the server to freeze or crash if VFire is installed
			self:Remove()
			self:Splash()
			return
		end
		self:Explode()
	end
end

function ENT:Explode()
	if self.Exploding then return end
	self.Exploding = true
	local explosion = ents.Create( "env_explosion" )			
	explosion:SetPos( self:GetPos() )
	explosion:SetKeyValue( "iMagnitude", 150 )
	explosion:Spawn()
	explosion:Activate()
	explosion:Fire( "Explode", 0, 0 )
	self:Remove()
end
