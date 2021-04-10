util.AddNetworkString( "AM_VehicleLock" )
local function AM_VehicleLock( len, ply )
	if IsFirstTimePredicted() then
		local veh = ply:GetVehicle()
		if AM_IsBlackListed( veh ) then return end
		if !veh:GetNWBool( "AM_DoorsLocked" ) then
			AM_Notify( ply, "Vehicle locked." )
			veh:Fire( "Lock", "", 0.01 )
			veh:SetNWBool( "AM_DoorsLocked", true )
			veh:SetNWEntity( "AM_LockOwner", ply )
		else
			AM_Notify( ply, "Vehicle unlocked." )
			veh:Fire( "Unlock", "", 0.01 )
			veh:SetNWBool( "AM_DoorsLocked", false )
		end
	end
end
net.Receive( "AM_VehicleLock", AM_VehicleLock )

util.AddNetworkString( "AM_VehicleHorn" )
local function AM_VehicleHorn( len, ply )
	local AM_HornEnabled = GetConVar( "AM_Config_HornEnabled" ):GetBool()
	if AM_HornEnabled then
		local veh = ply:GetVehicle()
		if AM_IsBlackListed( veh ) then return end
		veh.AM_CarHorn = CreateSound( veh, veh:GetNWString( "AM_HornSound" ) )
		if !veh.AM_CarHorn:IsPlaying() then
			veh.AM_CarHorn:Play()
		end
	end
end
net.Receive( "AM_VehicleHorn", AM_VehicleHorn )

util.AddNetworkString( "AM_VehicleHornStop" )
local function AM_VehicleHornStop( len, ply )
	local veh = ply:GetVehicle()
	if !IsValid( veh ) then return end
	if !veh.AM_CarHorn then return end
	if veh.AM_CarHorn:IsPlaying() then veh.AM_CarHorn:Stop() end
end
net.Receive( "AM_VehicleHornStop", AM_VehicleHornStop )

util.AddNetworkString( "AM_CruiseControl" )
local function AM_CruiseControl( len, ply )
	local AM_CruiseEnabled = GetConVar( "AM_Config_CruiseEnabled" ):GetBool()
	if AM_CruiseEnabled then
		local veh = ply:GetVehicle()
		if AM_IsBlackListed( veh ) or veh.EngineDisabled then return end
		local cruiseactive = veh:GetNWBool( "CruiseActive" )
		if cruiseactive then
			veh:SetNWBool( "CruiseActive", false )
			AM_Notify( ply, "Cruise control is now disabled." )
			return
		end
		veh:SetNWBool( "CruiseActive", true )
		AM_Notify( ply, "Cruise control is now enabled. Press forward/backward to increase/decrease cruise speed." )
		veh.CruiseSpeed = 0.05
	end
end
net.Receive( "AM_CruiseControl", AM_CruiseControl )

util.AddNetworkString( "AM_ChangeSeats" )
local function AM_ChangeSeats( len, ply )
	local key = net.ReadInt( 32 )
	local veh = ply:GetVehicle()
	if AM_IsBlackListed( veh ) then return end
	local vehparent = veh:GetParent()
	local driver = veh:GetDriver()
	local realseat = key - 1 --Need to subtract 1 since the driver's seat doesn't count as a passenger seat
	if veh:GetClass() == "prop_vehicle_jeep" then
		if key == 1 then
			AM_Notify( ply, "Seat change failed, you selected the seat you are already sitting in." )
			return
		else
			if veh.seat and IsValid( veh.seat[realseat] ) then
				if !IsValid( veh.seat[realseat]:GetDriver() ) then
					ply.IsSwitching = true --Fix for players getting kicked out while the seat cooldown is in effect
					ply:ExitVehicle() --Have to quickly exit the vehicle then enter the new one, or the old vehicle will still think it has a driver
					ply:EnterVehicle( veh.seat[realseat] )
					ply:SetEyeAngles( Angle( veh.seat[realseat]:GetAngles():Normalize() ) + Angle( 0, 90, 0 ) ) --Fix for the seats setting random eye angles
					ply.IsSwitching = false
				else
					AM_Notify( ply, "Seat change failed, selected seat is already taken." )
					return
				end
			else
				AM_Notify( ply, "Seat change failed, selected seat doesn't exist. Vehicle may not be currently supported." )
				return
			end
		end
	else
		if key == 1 then
			if !IsValid( vehparent:GetDriver() ) then
				ply.IsSwitching = true
				ply:ExitVehicle()
				ply:EnterVehicle( vehparent )
				ply:SetEyeAngles( Angle( vehparent:GetAngles():Normalize() ) + Angle( 0, 90, 0 ) )
				ply.IsSwitching = false
				return
			else
				AM_Notify( ply, "Seat change failed, selected seat is already taken." )
				return
			end
		end
		if vehparent.seat[realseat] == veh then
			AM_Notify( ply, "Seat change failed, you selected the seat you are already sitting in." )
			return
		end
		if IsValid( vehparent ) and vehparent.seat and IsValid( vehparent.seat[realseat] ) then	
			if !IsValid( vehparent.seat[realseat]:GetDriver() ) then
				ply.IsSwitching = true
				ply:ExitVehicle()
				ply:EnterVehicle( vehparent.seat[realseat] )
				ply:SetEyeAngles( Angle( vehparent.seat[realseat]:GetAngles():Normalize() ) + Angle( 0, 90, 0 ) )
				ply.IsSwitching = false
			else
				AM_Notify( ply, "Seat change failed, selected seat is already taken." )
				return
			end
		else
			AM_Notify( ply, "Seat change failed, selected seat doesn't exist." )
			return
		end
	end
end
net.Receive( "AM_ChangeSeats", AM_ChangeSeats )

util.AddNetworkString( "AM_EjectPassenger" )
local function AM_EjectPassenger( len, ply )
	local key = net.ReadInt( 32 )
	local veh = ply:GetVehicle()
	local realseat = key - 1
	if AM_IsBlackListed( veh ) then return end
	if veh:GetClass() == "prop_vehicle_jeep" then
		if veh.seat and IsValid( veh.seat[realseat] ) then
			local passenger = veh.seat[realseat]:GetDriver()
			if IsValid( passenger ) then
				local nick = ply:Nick()
				local passengernick = passenger:Nick()
				passenger:ExitVehicle()
				AM_Notify( ply, "Ejected "..passengernick.." from the vehicle." )
				AM_Notify( passenger, "You have been ejected from the vehicle by "..nick.."." )
			else
				AM_Notify( ply, "Passenger ejection failed, selected seat doesn't have a passenger." )
			end
		else
			AM_Notify( ply, "Passenger ejection failed, selected seat doesn't exist." )
		end
	else
		AM_Notify( ply, "Passenger ejection failed, only the driver can eject passengers." )
	end
end
net.Receive( "AM_EjectPassenger", AM_EjectPassenger )

util.AddNetworkString( "AM_EngineToggle" )
local function AM_EngineToggle( len, ply )
	if ply:InVehicle() then
		local veh = ply:GetVehicle()
		local AM_HealthEnabled = GetConVar( "AM_Config_HealthEnabled" ):GetBool()
		local AM_FuelEnabled = GetConVar( "AM_Config_FuelEnabled" ):GetBool()
		if AM_IsBlackListed( veh ) then return end
		if AM_HealthEnabled and veh:GetNWInt( "AM_VehicleHealth" ) <= 0 then return end --Don't want players turning the car back on when it's supposed to be damaged or out of fuel
		if AM_FuelEnabled and veh:GetNWInt( "AM_FuelAmount" ) <= 0 then return end
		if veh.EngineDisabled then
			veh:Fire( "turnon", "", 0.01 )
			veh.EngineDisabled = false
		else
			veh:Fire( "turnoff", "", 0.01 )
			veh.EngineDisabled = true
		end
	end
end
net.Receive( "AM_EngineToggle", AM_EngineToggle )
