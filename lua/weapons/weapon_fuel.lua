AddCSLuaFile()

SWEP.PrintName = "Vehicle Fuel Can"
SWEP.Category = "Automod"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Base = "weapon_base"
SWEP.Author = "Lambda Gaming"
SWEP.Slot = 2

SWEP.ViewModel = ""
SWEP.WorldModel = "models/props_junk/gascan001a.mdl"
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
	local AM_FuelEnabled = GetConVar( "AM_Config_FuelEnabled" ):GetBool()
	if !AM_FuelEnabled then return end
	local tr = self.Owner:GetEyeTrace().Entity
	local pos = tr:GetPos()
	if tr:GetClass() == "prop_vehicle_jeep" and self.Owner:GetPos():DistToSqr( pos ) < 40000 then
		local fuel = tr:GetNWInt( "AM_FuelAmount" )
		if fuel < 100 then
			AM_SetFuel( tr, fuel + 1 )
		end
	end
	self:SetNextPrimaryFire( CurTime() + 0.1 )
end

function SWEP:Think()
	local AM_FuelEnabled = GetConVar( "AM_Config_FuelEnabled" ):GetBool()
	if !AM_FuelEnabled then return end
	if self.Owner:KeyDown( IN_ATTACK ) then
		self.snd = CreateSound( self, "ambient/water/water_flow_loop1.wav" )
		if !self.snd:IsPlaying() then
			self.snd:Play()
		end
	else
		if self.snd and self.snd:IsPlaying() then
			self.snd:Stop()
		end
	end
end

if CLIENT then
	local function DrawFuelHUD()
		local AM_FuelEnabled = GetConVar( "AM_Config_FuelEnabled" ):GetBool()
		local posw = ScrW() / 2 - 75
		local posh = ScrH() / 2 - 10
		local ply = LocalPlayer()
		local tr = ply:GetEyeTrace().Entity
		local wep = ply:GetActiveWeapon()

		if !IsValid( wep ) or !IsValid( tr ) then return end

		local wepclass = wep:GetClass()
		local pos = tr:GetPos()
		local vehpos = ply:GetPos():DistToSqr( pos )
		local maxfuel = 100
		if !tr:IsVehicle() or ply:InVehicle() or wepclass != "weapon_fuel" or vehpos > 40000 then return end
		if maxfuel > 0 then
			local fuel = tr:GetNWInt( "AM_FuelAmount" )
			local fuel25 = maxfuel * 0.25
			local fuel75 = maxfuel * 0.75
			draw.RoundedBox( 8, posw, posh, 190, 40, Color( 30, 30, 30, 254 ) )
			surface.SetFont( "AM_HUDFont1" )
			if AM_FuelEnabled and fuel <= fuel25 then
				surface.SetTextColor( 255, 0, 0 )
			elseif fuel > fuel25 and fuel < fuel75 then
				surface.SetTextColor( 196, 145, 2 )
			else
				surface.SetTextColor( color_white )
			end
			surface.SetTextPos( posw + 15, posh + 10 )
			
			if AM_FuelEnabled then
				surface.DrawText( "Vehicle Fuel Level: "..fuel )
			else
				surface.DrawText( "Vehicle fuel disabled." )
			end
		end
	end
	hook.Add( "HUDPaint", "AM_FuelHUD", DrawFuelHUD )
end
