function GAuto.Notify( text )
	local textcolor1 = Color( 180, 0, 0, 255 )
	local textcolor2 = color_white
	chat.AddText( textcolor1, "[GAuto]: ", textcolor2, text )
end

net.Receive( "GAuto_Notify", function()
	local text = net.ReadString()
	GAuto.Notify( text )
end )

surface.CreateFont( "GAuto_HUDFont1", {
	font = "Roboto",
	size = 18
} )

surface.CreateFont( "GAuto_HUDFont2", {
	font = "Roboto",
	size = 12
} )

local HUDPositions = {
	Background = { ScrW() - 190, ScrH() - 520 },
	Health = { ScrW() - 185, ScrH() - 510 },
	Line1 = { ScrW() - 185, ScrH() - 490 },
	Fuel = { ScrW() - 185, ScrH() - 480 },
	Line2 = { ScrW() - 185, ScrH() - 460 },
	Lock = { ScrW() - 185, ScrH() - 450 },
	Line3 = { ScrW() - 185, ScrH() - 430 },
	Cruise = { ScrW() - 185, ScrH() - 420 },
	Cruise2 = { ScrW() - 185, ScrH() - 400 },
	Line4 = { ScrW() - 185, ScrH() - 380 },
	AddonName = { ScrW() - 185, ScrH() - 375 }
}

local function CalcPercentage( x, y )
	local p = x / y
	local realp = p * 100
	return realp
end

local color_gray = Color( 30, 30, 30, 230 )
local function HUDStuff()
	local ply = LocalPlayer()
	local vehicle = ply:GetVehicle()
	if ply:InVehicle() and GAuto.IsDrivable( vehicle ) then
		local vehhealth = vehicle:GetNWInt( "GAuto_VehicleHealth" )
		local vehmaxhealth = vehicle:GetNWInt( "GAuto_VehicleMaxHealth" )
		local godenabled = vehicle:GetNWBool( "GodMode" )
		local GAuto_FuelAmount = GetConVar( "gauto_fuel_amount" ):GetInt()
		local GAuto_FuelEnabled = GetConVar( "gauto_fuel_enabled" ):GetBool()
		
		local background = HUDPositions.Background
		local health = HUDPositions.Health
		local line1 = HUDPositions.Line1
		local fuel = HUDPositions.Fuel
		local line2 = HUDPositions.Line2
		local lock = HUDPositions.Lock
		local line3 = HUDPositions.Line3
		local cruise = HUDPositions.Cruise
		local cruise2 = HUDPositions.Cruise2
		local line4 = HUDPositions.Line4
		local name = HUDPositions.AddonName

		draw.RoundedBox( 4, background[1], background[2], 154, 160, color_gray )
		surface.SetFont( "GAuto_HUDFont1" )

		if godenabled then
			surface.SetTextColor( 0, 255, 0 )
		elseif vehhealth <= vehmaxhealth * 0.25 then
			surface.SetTextColor( 255, 0, 0, 255 )
		else
			surface.SetTextColor( color_white )
		end
		surface.SetDrawColor( color_white )
		surface.SetTextPos( health[1], health[2] )
		if vehmaxhealth > 0 then
			local percent = CalcPercentage( vehhealth, vehmaxhealth )
			surface.DrawText( "Health: "..math.Round( percent, 2 ).."%" )
		else
			surface.DrawText( "Health Disabled" )
		end
		surface.DrawLine( line1[1], line1[2], line1[1] + 144, line1[2] )
		
		if GAuto_FuelEnabled then
			local fuel50 = GAuto_FuelAmount * 0.5
			local fuel25 = GAuto_FuelAmount * 0.25
			local fuellevel = vehicle:GetNWInt( "GAuto_FuelAmount" )
			local fuelPercentage = CalcPercentage( fuellevel, GAuto_FuelAmount )
			if fuellevel < fuel50 and fuellevel >= fuel25 then
				surface.SetTextColor( 196, 145, 2 )
			elseif fuellevel < fuel25 then
				surface.SetTextColor( 255, 0, 0 )
			else
				surface.SetTextColor( color_white )
			end
			surface.SetTextPos( fuel[1], fuel[2] )
			surface.DrawText( "Fuel: "..math.Round( fuelPercentage, 2 ).."%" )
		else
			surface.SetTextColor( color_white )
			surface.SetTextPos( fuel[1], fuel[2] )
			surface.DrawText( "Fuel Disabled" )
		end
		surface.DrawLine( line2[1], line2[2], line2[1] + 144, line2[2] )

		surface.SetTextColor( color_white )
		surface.SetTextPos( lock[1], lock[2] )
		if vehicle:GetNWBool( "GAuto_DoorsLocked" ) then
			surface.SetTextColor( color_white )
			surface.DrawText( "Doors: Locked" )
		else
			surface.SetTextColor( 196, 145, 2 )
			surface.DrawText( "Doors: Unlocked" )
		end
		surface.DrawLine( line3[1], line3[2], line3[1] + 144, line3[2] )

		surface.SetTextColor( color_white )
		surface.SetTextPos( cruise[1], cruise[2] )
		if vehicle:GetNWBool( "CruiseActive" ) then
			surface.SetTextColor( 0, 255, 0 )
			local velocity = vehicle:GetVelocity():Length()
			local speed = 0
			local throttle = vehicle:GetNWInt( "CruiseSpeed" )
			local realthrottle = math.Round( throttle * 100 )
			local label = ""
			if GetConVar( "gauto_cruise_mph" ):GetBool() then
				speed = math.Round( velocity * 3600 / 63360 * 0.75 )
				label = "MPH"
			else
				speed = math.Round( velocity * 3600 * 0.0000254 * 0.75 )
				label = "KPH"
			end
			surface.DrawText( "Cruise Control:" )
			surface.SetTextPos( cruise2[1], cruise2[2] )
			surface.DrawText( speed.." "..label.." ("..realthrottle.."%)" )
		else
			surface.DrawText( "Cruise Control: Off" )
		end
		surface.DrawLine( line4[1], line4[2], line4[1] + 144, line4[2] )
		
		surface.SetTextColor( color_white )
		surface.SetFont( "GAuto_HUDFont2" )
		surface.SetTextPos( name[1], name[2] )
		surface.DrawText( "GAuto v"..GAuto.Version.." by OPGman" )
	end
end
hook.Add( "HUDPaint", "GAuto_HUDStuff", HUDStuff )
