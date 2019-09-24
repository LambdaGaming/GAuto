
AddCSLuaFile()

SWEP.PrintName = "Tow Tool"
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

function SWEP:Initialize()
	self:SetHoldType( "melee2" )
end

function SWEP:PrimaryAttack()
	if !IsFirstTimePredicted() or CLIENT then return end
    local tr = self.Owner:GetEyeTrace().Entity
	if self.Owner:GetPos():DistToSqr( tr:GetPos() ) > 90000 then return end
    if tr:GetClass() == "prop_vehicle_jeep" and AM_HasTowPos( tr:GetModel() ) then --Check to make sure the vehicle is a valid tow truck
    	self.Owner:SetAnimation( PLAYER_ATTACK1 )
		if !tr.TowAttached then
			local trace = util.TraceLine( {
				start = tr:GetPos() + Vector( 0, 0, 30 ),
				endpos = tr:GetPos() + tr:GetAngles():Forward() * -300
			} )
			if IsValid( trace.Entity ) and trace.Entity != tr.Entity and !AM_Config_Blacklist[trace.Entity:GetModel()] then
				local frontpos = trace.Entity:NearestPoint( trace.Entity:GetPos() + Vector(0, 0, 12.5) + trace.Entity:GetForward() * 500 )
				constraint.Rope( tr.Entity, trace.Entity, 0, 0, Vector(0, -133.3848, 73.9280), trace.Entity:WorldToLocal( frontpos ), 60, 0, 17000, 1.5, "cable/cable2", false )
				tr.TowAttached = true
			else
				AM_Notify( self.Owner, "ERROR: The target vehicle is either too far away or has a blacklisted model!" )
			end
		else
			constraint.RemoveConstraints( tr, "Rope" )
			tr.TowAttached = false
		end
    end
    self:SetNextPrimaryFire( CurTime() + 1 )
end
