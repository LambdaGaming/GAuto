AddCSLuaFile()

SWEP.PrintName = "Spikestrip"
SWEP.Category = "GAuto"
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
	local owner = self:GetOwner()
	local tr = owner:GetEyeTrace()
	local hitpos = tr.HitPos
    if owner:GetPos():DistToSqr( hitpos ) < 10000 then
		if !self.SpawnedSpike then
			local rand = math.random( 1, 3 )
			local e = ents.Create( "ent_gauto_spikestrip" )
			local offset = owner:GetAngles().y + GetConVar( "GAuto_Config_SpikeModelOffset" ):GetInt()
			e:SetPos( hitpos )
			e:SetAngles( Angle( 0, offset, 0 ) )
			e:Spawn()
			e:SetOwner( owner )
			e:EmitSound( "physics/metal/metal_grate_impact_soft"..rand..".wav" )
			GAuto.Notify( owner, "You have placed your spikestrip." )
			self:Remove()
		end
    end
    self:SetNextPrimaryFire( CurTime() + 0.5 )
end
