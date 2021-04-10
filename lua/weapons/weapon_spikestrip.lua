
AddCSLuaFile()

SWEP.PrintName = "Spikestrip"
SWEP.Category = "Automod"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Base = "weapon_base"
SWEP.Author = "Lambda Gaming"
SWEP.Slot = 3

SWEP.ViewModel = ""
SWEP.WorldModel = ""

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false

function SWEP:Deploy()
	self:SetHoldType( "normal" )
end

function SWEP:PrimaryAttack()
	if !IsFirstTimePredicted() or CLIENT then return end
	local tr = self.Owner:GetEyeTrace()
	local hitpos = tr.HitPos
    if self.Owner:GetPos():DistToSqr( hitpos ) < 10000 then
		if !self.SpawnedSpike then
			local rand = math.random( 1, 3 )
			local e = ents.Create( "automod_spikestrip" )
			e:SetPos( hitpos )
			e:SetAngles( Angle( 0, self.Owner:GetAngles().y, 0 ) )
			e:Spawn()
			e:SetOwner( self.Owner )
			e:EmitSound( "physics/metal/metal_grate_impact_soft"..rand..".wav" )
			AM_Notify( self.Owner, "You have placed your spikestrip." )
			self:Remove()
		end
    end
    self:SetNextPrimaryFire( CurTime() + 0.5 )
end
