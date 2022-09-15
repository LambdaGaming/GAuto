
AddCSLuaFile()

SWEP.PrintName = "Vehicle Repair Tool"
SWEP.Category = "Automod"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Base = "weapon_base"
SWEP.Author = "Lambda Gaming"
SWEP.Slot = 2

SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/weapons/w_crowbar.mdl"
SWEP.DrawCrosshair = false

SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true

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
			AM_AddHealth( tr, 1 )
			self:SendWeaponAnim( ACT_VM_SWINGMISS )
			self.Owner:SetAnimation( PLAYER_ATTACK1 )
		end
	end
	self:SetNextPrimaryFire( CurTime() + 0.1 )
end

function SWEP:SecondaryAttack()
	if !IsFirstTimePredicted() or CLIENT then return end
	local tr = self.Owner:GetEyeTrace().Entity
	if tr:GetClass() == "prop_vehicle_jeep" and self.Owner:GetPos():DistToSqr( tr:GetPos() ) < 40000 then
		local rand = math.random( 1, 3 )
		AM_RepairTire( tr )
		self:SendWeaponAnim( ACT_VM_SWINGMISS )
	    self.Owner:SetAnimation( PLAYER_ATTACK1 )
		tr:EmitSound( "physics/rubber/rubber_tire_impact_hard"..rand..".wav" )
		AM_Notify( self.Owner, "Vehicle tires repaired." )
	end
	self:SetNextSecondaryFire( CurTime() + 0.5 )
end

function SWEP:Think()
	if self.Owner:KeyDown( IN_ATTACK ) then
		if self.snd and self.sndcooldown and self.sndcooldown > CurTime() then return end
		local rand = math.random( 1, 5 )
		self.snd = CreateSound( self, "ambient/materials/dinnerplates"..rand..".wav" )
		if !self.snd:IsPlaying() then
			self.snd:Play()
			self.sndcooldown = CurTime() + 1
		end
	else
		if self.snd and self.snd:IsPlaying() then
			self.snd:Stop()
		end
	end
end

if CLIENT then
	local function DrawRepairHUD()
		local posw = ScrW() / 2 - 75
		local posh = ScrH() / 2 - 10
		local ply = LocalPlayer()
		local tr = ply:GetEyeTrace().Entity
		local wep = ply:GetActiveWeapon()

		if !IsValid( wep ) or !IsValid( tr ) then return end

		local wepclass = wep:GetClass()
		local vehpos = ply:GetPos():DistToSqr( tr:GetPos() )
		local maxhealth = tr:GetNWInt( "AM_VehicleMaxHealth" )
		if !IsValid( tr ) or !tr:IsVehicle() or ply:InVehicle() or wepclass != "weapon_repair" or vehpos > 40000 then return end
		if maxhealth > 0 then
			local health = tr:GetNWInt( "AM_VehicleHealth" )
			local health25 = maxhealth * 0.25
			local health75 = maxhealth * 0.75
			draw.RoundedBox( 8, posw, posh, 160, 40, Color( 30, 30, 30, 254 ) )
			if health <= health25 then
				surface.SetTextColor( 255, 0, 0 )
			elseif health > health25 and health < health75 then
				surface.SetTextColor( 196, 145, 2 )
			else
				surface.SetTextColor( color_white )
			end
			surface.SetTextPos( posw + 5, posh + 10 )
			surface.DrawText( "Vehicle Health: "..health )
		end
	end
	hook.Add( "HUDPaint", "AM_RepairHUD", DrawRepairHUD )
end