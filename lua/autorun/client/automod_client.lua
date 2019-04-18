
local AM_HealthEnabled = GetConVar( "AM_Config_HealthEnabled" ):GetBool()
local AM_WheelLockEnabled = GetConVar( "AM_Config_WheelLockEnabled" ):GetBool()
local AM_DoorLockEnabled = GetConVar( "AM_Config_LockEnabled" ):GetBool()
local AM_BrakeLockEnabled = GetConVar( "AM_Config_BrakeLockEnabled" ):GetBool()
local AM_SeatsEnabled = GetConVar( "AM_Config_SeatsEnabled" ):GetBool()

hook.Add( "HUDPaint", "AM_HUDStuff", function() --Main HUD, needs adjusted so it works alongside photon and seat weaponizer mods
	local ply = LocalPlayer()
	if ply:InVehicle() then
		local vehicle = ply:GetVehicle()
		if vehicle:GetClass() == "prop_vehicle_jeep" then
			draw.RoundedBox( 5, 1500, ScrH() - 155, 200, 150, Color(25,25,25,200) )
			surface.SetFont( "Trebuchet18" )
			surface.SetTextColor( 255, 255, 255, 255 )
			surface.SetTextPos( 1500, ScrH() - 155 )
		    if AM_HealthEnabled then
			    surface.DrawText( math.Clamp( math.Round( vehicle:GetNWInt( "AM_VehicleHealth" ), 1 ), 0, vehicle:GetNWInt( "AM_VehicleMaxHealth" ) ).."/"..vehicle:GetNWInt( "AM_VehicleMaxHealth" ) )
			else
			    surface.DrawText( "Health Disabled" )
			end
			surface.SetTextPos( 1500, ScrH() - 135 )
			if vehicle:GetNWBool( "AM_DoorsLocked" ) then
			    surface.DrawText( "Doors: Locked" )
			else
				surface.DrawText( "Doors: Unlocked" )
			end
		end
	end
end )

hook.Add( "PlayerButtonDown", "AM_KeyPressDown", function( ply, key ) --Possible alternative to using the IN_ keys, needs tested
	if IsFirstTimePredicted() then
		if ply:InVehicle() then
			if key == KEY_N then
				net.Start( "AM_VehicleLock" )
				net.SendToServer()
			end
			if key == KEY_H then
				net.Start( "AM_VehicleHorn" )
				net.SendToServer()
			end
		end
	end
end )

hook.Add( "PlayerButtonUp", "AM_KeyPressUp", function( ply, key )
	if IsFirstTimePredicted() then
		if ply:InVehicle() then
			if key == KEY_H then
				net.Start( "AM_VehicleHornStop" )
				net.SendToServer() --Not sure if this the most optimised way to do this
			end
		end
	end
end )

--[[hook.Add( "Think", "VehicleSmoke", function()
	local ply = LocalPlayer()
	
	if ent:GetClass() == "prop_vehicle_jeep" then
		if ent:GetNWBool( "AM_IsSmoking" ) then
			local smoke = ParticleEmitter( ent:GetNWVector( "AM_EnginePos" ), true)

		end
	end
end )]]