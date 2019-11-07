
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
	if !IsFirstTimePredicted() or CLIENT then return end
    local tr = self.Owner:GetEyeTrace().Entity
    if tr:GetClass() == "prop_vehicle_jeep" and self.Owner:GetPos():DistToSqr( tr:GetPos() ) < 40000 then
    	if tr:GetNWInt( "AM_VehicleHealth" ) < tr:GetNWInt( "AM_VehicleMaxHealth" ) then
			if tr:GetNWInt( "AM_VehicleHealth" ) <= 0 then
				tr:Fire( "turnon", "", 0.01 )
			end
    		AM_AddHealth( tr, 10 )
            self:SendWeaponAnim( ACT_VM_SWINGMISS )
            self.Owner:SetAnimation( PLAYER_ATTACK1 )
    		AM_Notify( self.Owner, "Vehicle Health: "..tr:GetNWInt( "AM_VehicleHealth" ) )
        else
            AM_Notify( self.Owner, "Vehicle is at max health!" )
    	end
    end
    self:SetNextPrimaryFire( CurTime() + 0.5 )
end

function SWEP:SecondaryAttack()
	if !IsFirstTimePredicted() or CLIENT then return end
    local tr = self.Owner:GetEyeTrace().Entity
    if tr:GetClass() == "prop_vehicle_jeep" and self.Owner:GetPos():DistToSqr( tr:GetPos() ) < 40000 then
		AM_RepairTire( tr )
		self:SendWeaponAnim( ACT_VM_SWINGMISS )
        self.Owner:SetAnimation( PLAYER_ATTACK1 )
    	tr:EmitSound( "physics/rubber/rubber_tire_impact_hard"..math.random( 1, 3 )..".wav" )
		AM_Notify( self.Owner, "Vehicle tires repaired." )
    end
    self:SetNextSecondaryFire( CurTime() + 0.5 )
end
