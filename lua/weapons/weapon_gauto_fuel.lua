AddCSLuaFile()

SWEP.PrintName = "Vehicle Fuel Can"
SWEP.Category = "GAuto"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Base = "weapon_base"
SWEP.Author = "OPGman"
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

SWEP.NextThinkTime = 0

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

if SERVER then
	function SWEP:Think()
		if self.NextThinkTime > CurTime() then return end
		local GAuto_FuelEnabled = cvars.Bool( "gauto_fuel_enabled" )
		if !GAuto_FuelEnabled then return end
		if self.Owner:KeyDown( IN_ATTACK ) then
			local tr = self.Owner:GetEyeTrace().Entity
			local pos = tr:GetPos()
			if GAuto.IsDrivable( tr ) and self.Owner:GetPos():DistToSqr( pos ) < 40000 then
				local fuel = tr:GetNWInt( "GAuto_FuelAmount" )
				if fuel < 100 then
					GAuto.SetFuel( tr, fuel + 1 )
				end
				self.snd = CreateSound( self, "ambient/water/water_flow_loop1.wav" )
				if !self.snd:IsPlaying() then
					self.snd:Play()
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
	local model = ClientsideModel( SWEP.WorldModel )
	model:SetNoDraw( true )
	function SWEP:DrawWorldModel()
		local owner = self:GetOwner()
		if IsValid( owner ) then
			local offsetVec = Vector( 5, 0, 12 )
			local offsetAng = Angle( 0, -100, 190 )
			local bone = owner:LookupBone( "ValveBiped.Bip01_R_Hand" )
			if !bone then return end
			
			local matrix = owner:GetBoneMatrix( bone )
			if !matrix then return end

			local pos, ang = LocalToWorld( offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles() )
			model:SetPos( pos )
			model:SetAngles( ang )
			model:SetupBones()
		else
			model:SetPos( self:GetPos() )
			model:SetAngles( self:GetAngles() )
		end
		model:DrawModel()
	end

	function SWEP:DrawHUD()
		local ply = self:GetOwner()
		if ply:InVehicle() then return end
		local tr = ply:GetEyeTrace().Entity
		local GAuto_FuelEnabled = cvars.Bool( "gauto_fuel_enabled" )
		local w = ScrW() / 2 - 95
		local h = ScrH() / 2 - 20
		local pos = ply:GetPos():DistToSqr( tr:GetPos() )
		local maxFuel = cvars.Number( "gauto_fuel_amount" )
		local fuel = tr:GetNWInt( "GAuto_FuelAmount" )
		local fuel25 = maxFuel * 0.25
		local fuel75 = maxFuel * 0.75
		draw.RoundedBox( 4, w, h, 190, 40, Color( 30, 30, 30, 230 ) )
		surface.SetFont( "GAuto_HUDFont1" )
		surface.SetTextPos( w + 15, h + 10 )
		surface.SetTextColor( color_white )

		if !GAuto_FuelEnabled then
			surface.DrawText( "Vehicle fuel disabled." )
		elseif GAuto.IsDrivable( tr ) and pos <= 40000 then
			if GAuto_FuelEnabled and fuel <= fuel25 then
				surface.SetTextColor( 255, 0, 0 )
			elseif fuel > fuel25 and fuel < fuel75 then
				surface.SetTextColor( 196, 145, 2 )
			end
			surface.DrawText( "Vehicle Fuel Level: "..math.Round( fuel, 2 ).."%" )
		else
			surface.DrawText( "No vehicle detected." )
		end
	end
end
