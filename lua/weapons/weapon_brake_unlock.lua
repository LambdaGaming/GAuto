
AddCSLuaFile()

SWEP.PrintName = "Brake Release Tool"
SWEP.Category = "Automod"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Base = "weapon_base"
SWEP.Author = "Lambda Gaming"
SWEP.Slot = 3

SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false

SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false

function SWEP:PrimaryAttack()
	if !IsFirstTimePredicted() then return end
    local tr = self.Owner:GetEyeTrace().Entity
	local pos = tr:GetPos()
	if self.Owner:GetPos():DistToSqr( pos ) > 90000 then return end
    if tr:GetClass() == "prop_vehicle_jeep" then
		local rand = math.random( 1, 3 )
    	if SERVER then
    		tr:Fire( "HandBrakeOff", "", 0.01 )
    		self.Owner:ChatPrint( "Brakes released." )
    	end
    	tr:EmitSound( "physics/metal/metal_box_impact_soft"..rand..".wav" )
    end
    self:SetNextPrimaryFire( CurTime() + 1 )
end
