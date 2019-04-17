
AddCSLuaFile()

SWEP.PrintName = "Vehicle Repair Tool"
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
    local tr = self.Owner:GetEyeTrace().Entity
    if tr:GetClass() == "prop_vehicle_jeep" then
    	if tr:GetNWInt( "AM_VehicleHealth" ) < tr:GetNWInt( "AM_VehicleMaxHealth" ) then
    		tr:SetNWInt( "AM_VehicleHealth" , math.Clamp( tr:GetNWInt( "AM_VehicleHealth" ) + 2, 0, tr:GetNWInt( "AM_VehicleMaxHealth" ) ) )
    		self.Owner:ChatPrint( "Vehicle Health: "..tr:GetNWInt( "AM_VehicleHealth" ) )
    	end
    end
    self:SetNextPrimaryFire( CurTime() + 0.5 )
end

function SWEP:SecondaryAttack()
end