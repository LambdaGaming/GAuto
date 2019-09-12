
local AM_HornKey = GetConVar( "AM_Control_HornKey" ):GetInt()
local AM_LockKey = GetConVar( "AM_Control_LockKey" ):GetInt()

net.Receive( "AM_Notify", function( len, ply )
	local text = net.ReadString()
	local textcolor1 = Color( 180, 0, 0, 255 )
	local textcolor2 = color_white
	chat.AddText( textcolor1, "[Automod]: ", textcolor2, text )
end )

surface.CreateFont( "AM_HUDFont1", {
	font = "Roboto",
	size = 18
} )

surface.CreateFont( "AM_HUDFont2", {
	font = "Roboto",
	size = 14
} )

hook.Add( "HUDPaint", "AM_HUDStuff", function() --Main HUD, needs adjusted so it works alongside photon and seat weaponizer mods
	local ply = LocalPlayer()
	if ply:InVehicle() then
		local vehicle = ply:GetVehicle()
		local vehhealth = vehicle:GetNWInt( "AM_VehicleHealth" )
		local vehmaxhealth = vehicle:GetNWInt( "AM_VehicleMaxHealth" )
		if vehicle:GetClass() == "prop_vehicle_jeep" then
			draw.RoundedBox( 5, 1500, ScrH() - 155, 200, 150, Color( 5, 5, 5, 245 ) )
			surface.SetFont( "AM_HUDFont1" )

			if vehicle:GetNWBool( "AM_IsSmoking" ) then
				surface.SetTextColor( 255, 0, 0, 255 )
			else
				surface.SetTextColor( 255, 255, 255, 255 )
			end

			surface.SetTextPos( 1541, ScrH() - 155 )

		    if vehicle:GetNWInt( "AM_VehicleMaxHealth" ) > 0 then
			    surface.DrawText( "Health: "..math.Round( vehhealth ).."/"..vehmaxhealth )
			else
				surface.DrawText( "Health Disabled" )
			end
			surface.SetTextPos( 1540, ScrH() - 135 )
			if vehicle:GetNWBool( "AM_DoorsLocked" ) then
				surface.SetTextColor( 255, 255, 255, 255 )
			    surface.DrawText( "Doors: Locked" )
			else
				surface.SetTextColor( 196, 145, 2, 255 )
				surface.DrawText( "Doors: Unlocked" )
			end

			surface.SetFont( "AM_HUDFont2" )
			surface.SetTextColor( 255, 255, 255, 255 )
			surface.SetTextPos( 1500, ScrH() - 100 )
			surface.DrawText( "AUTOMOD BETA" )
			surface.SetTextPos( 1500, ScrH() - 80 )
			surface.DrawText( "Suggestions are greatly appreciated!" )
			surface.SetTextPos( 1500, ScrH() - 60 )
			surface.DrawText( "(This HUD is unfinished.)" )
		end
	end
end )

local seatbuttons = {
	{ KEY_1, 1 },
	{ KEY_2, 2 },
	{ KEY_3, 3 },
	{ KEY_4, 4 },
	{ KEY_5, 5 },
	{ KEY_6, 6 },
	{ KEY_7, 7 },
	{ KEY_8, 8 },
	{ KEY_9, 9 }
}
hook.Add( "PlayerButtonDown", "AM_KeyPressDown", function( ply, key )
	if IsFirstTimePredicted() then
		if ply:InVehicle() then
			if key == AM_LockKey then
				net.Start( "AM_VehicleLock" )
				net.SendToServer()
			end
			if key == AM_HornKey then
				net.Start( "AM_VehicleHorn" )
				net.SendToServer()
			end
			for k,v in pairs( seatbuttons ) do
				if key == v[1] then
					net.Start( "AM_ChangeSeats" )
					net.WriteString( tostring( v[2] ) ) --Converting it to a string here because using ints make weird things happen
					net.SendToServer()
				end
			end
		end
	end
end )

hook.Add( "PlayerButtonUp", "AM_KeyPressUp", function( ply, key )
	if IsFirstTimePredicted() then
		if ply:InVehicle() then
			if key == AM_HornKey then
				net.Start( "AM_VehicleHornStop" )
				net.SendToServer() --Not sure if this the most optimised way to do this
			end
		end
	end
end )

hook.Add( "Think", "AM_SmokeThink", function()
	local ply = LocalPlayer()
	for k,v in pairs( ents.FindByClass( "prop_vehicle_jeep" ) ) do
		if v:GetNWBool( "AM_IsSmoking" ) then
			local carpos = v:GetPos()
			local plypos = ply:GetPos()
			if plypos:DistToSqr( carpos ) < 4000000 then --Only displays particles if the player is within a certain distance of the vehicle, helps with optimization
				local pos = v:LocalToWorld( v:GetNWVector( "AM_EnginePos" ) )
				local smoke = ParticleEmitter( pos ):Add( "particle/smokesprites_000"..math.random( 1, 9 ), pos )
				smoke:SetVelocity( Vector( 0, 0, 50 ) )
				smoke:SetDieTime( math.Rand( 0.6, 1.3 ) )
				smoke:SetStartSize( math.random( 0, 5 ) )
				smoke:SetEndSize( math.random( 33, 55 ) )
				smoke:SetColor( 72, 72, 72 )
			end
		end
	end
end )