AddCSLuaFile()

SWEP.PrintName = "Vehicle Repair Tool"
SWEP.Category = "GAuto"
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

SWEP.SndCooldown = 0
SWEP.NextThinkTime = 0

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
	if !IsFirstTimePredicted() or CLIENT then return end
	local tr = self.Owner:GetEyeTrace().Entity
	if tr:GetClass() == "prop_vehicle_jeep" and self.Owner:GetPos():DistToSqr( tr:GetPos() ) < 40000 then
		local rand = math.random( 1, 3 )
		GAuto.RepairTire( tr )
		self:SendWeaponAnim( ACT_VM_SWINGMISS )
	    self.Owner:SetAnimation( PLAYER_ATTACK1 )
		tr:EmitSound( "physics/rubber/rubber_tire_impact_hard"..rand..".wav" )
		GAuto.Notify( self.Owner, "Vehicle tires repaired." )
	end
	self:SetNextSecondaryFire( CurTime() + 0.5 )
end

if SERVER then
	function SWEP:Think()
		if self.NextThinkTime > CurTime() then return end
		if self.Owner:KeyDown( IN_ATTACK ) then
			local tr = self.Owner:GetEyeTrace().Entity
			if tr:GetClass() == "prop_vehicle_jeep" and self.Owner:GetPos():DistToSqr( tr:GetPos() ) < 40000 then
				if tr:GetNWInt( "GAuto_VehicleHealth" ) < tr:GetNWInt( "GAuto_VehicleMaxHealth" ) then
					if tr:GetNWInt( "GAuto_VehicleHealth" ) <= 0 then
						tr:Fire( "turnon", "", 0.01 )
					end
					GAuto.AddHealth( tr, 1 )
					self:SendWeaponAnim( ACT_VM_SWINGMISS )
					self.Owner:SetAnimation( PLAYER_ATTACK1 )
				end
				if self.SndCooldown < CurTime() then
					local rand = math.random( 1, 5 )
					self.snd = CreateSound( self, "ambient/materials/dinnerplates"..rand..".wav" )
					if !self.snd:IsPlaying() then
						self.snd:Play()
						self.SndCooldown = CurTime() + 1
					end
				end
			end
		else
			if self.snd and self.snd:IsPlaying() then
				self.snd:Stop()
			end
		end
		self.NextThinkTime = CurTime() + 0.1
	end
end

if CLIENT then
	local function DrawRepairHUD()
		local ply = LocalPlayer()
		local wep = ply:GetActiveWeapon()
		if IsValid( wep ) and wep:GetClass() != "weapon_gauto_repair" then return end
		
		local posw = ScrW() / 2 - 95
		local posh = ScrH() / 2 - 20
		local tr = ply:GetEyeTrace().Entity
		local vehpos = ply:GetPos():DistToSqr( tr:GetPos() )
		local health = tr:GetNWInt( "GAuto_VehicleHealth" )
		local maxhealth = tr:GetNWInt( "GAuto_VehicleMaxHealth" )
		local health25 = maxhealth * 0.25
		local health75 = maxhealth * 0.75
		draw.RoundedBox( 4, posw, posh, 190, 40, Color( 30, 30, 30, 230 ) )
		surface.SetFont( "GAuto_HUDFont1" )
		surface.SetTextPos( posw + 15, posh + 10 )
		surface.SetTextColor( color_white )
		
		if IsValid( tr ) and tr:IsVehicle() and maxhealth <= 0 then
			surface.DrawText( "Vehicle damage disabled." )
		elseif IsValid( tr ) and tr:IsVehicle() and vehpos <= 40000 then
			if health <= health25 then
				surface.SetTextColor( 255, 0, 0 )
			elseif health > health25 and health < health75 then
				surface.SetTextColor( 196, 145, 2 )
			end
			surface.DrawText( "Vehicle Health: "..health )
		else
			surface.DrawText( "No vehicle detected." )
		end
	end
	hook.Add( "HUDPaint", "GAuto_RepairHUD", DrawRepairHUD )
end
