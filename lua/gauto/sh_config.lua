GAuto.Vehicles = {}

game.AddParticles( "particles/vehicle.pcf" )
game.AddParticles( "particles/fire_01.pcf" )
PrecacheParticleSystem( "WheelDust" )
PrecacheParticleSystem( "burning_engine_fire" )
PrecacheParticleSystem( "smoke_burning_engine_01" )

CreateConVar( "GAuto_Config_HealthEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Vehicles will take damage." )
CreateConVar( "GAuto_Config_BulletDamageEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Vehicles will take bullet damage. Does nothing if GAuto_Config_HealthEnabled is disabled." )
CreateConVar( "GAuto_Config_DamageExplosionEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE } , "Vehicles explode when their health reaches 0.")
CreateConVar( "GAuto_Config_ExplodeRemoveEnabled", 0, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Destroyed vehicles are removed a certain amount of time after exploding." )
CreateConVar( "GAuto_Config_ExplodeRemoveTime", 600, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Time it takes in seconds for a destroyed vehicle to get removed. GAuto_Config_ExplodeRemoveEnabled must be set to 1 for this to work." )
CreateConVar( "GAuto_Config_ScalePlayerDamage", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Damage that players take while in a vehicle will be scaled down." )
CreateConVar( "GAuto_Config_BrakeLockEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Brakes will lock up and prevent the vehicle from moving if the driver holds jump while exiting." )
CreateConVar( "GAuto_Config_WheelLockEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Wheels will remain turned when the driver exits the vehicle." )
CreateConVar( "GAuto_Config_SeatsEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Supported vehicles will spawn with passenger seats." )
CreateConVar( "GAuto_Config_HornEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Drivers will be able to sound a horn by pressing a specific button." )
CreateConVar( "GAuto_Config_LockEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Drivers will be able to lock their vehicles by pressing a specific button." )
CreateConVar( "GAuto_Config_LockAlarmEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Lockpicking a vehicle in DarkRP will sound an alarm." )
CreateConVar( "GAuto_Config_TirePopEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Vehicle tires will take damage and eventually pop." )
CreateConVar( "GAuto_Config_TireHealth", 10, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Amount of health each wheel/tire has." )
CreateConVar( "GAuto_Config_FuelEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Vehicles will consume fuel and stop working when out of fuel." )
CreateConVar( "GAuto_Config_FuelAmount", 100, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Amount of fuel vehicles spawn with." )
CreateConVar( "GAuto_Config_NoFuelGod", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Vehicles that are out of fuel cannot be damaged." )
CreateConVar( "GAuto_Config_CruiseEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Drivers will be able to activate cruise control by pressing a specific button." )
CreateConVar( "GAuto_Config_HealthOverride", 0, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Amount of health every vehicle spawns with no matter what. Set to 0 to disable." )
CreateConVar( "GAuto_Config_DriverSeat", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Players will automatically enter the drivers seat if it is not taken. If set to 0, players will enter the closest detected seat." )
CreateConVar( "GAuto_Config_SpikeModel", "models/props_phx/mechanics/slider2.mdl", { FCVAR_ARCHIVE }, "The model of the spikestrip." )
CreateConVar( "GAuto_Config_SpikeModelOffset", 90, { FCVAR_ARCHIVE }, "Yaw offset that the spikestrip should be placed at." )
CreateConVar( "GAuto_Config_FuelLoss", 0.5, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "How fast fuel should drain when the throttle is pressed. You probably shouldn't touch this unless you know what you're doing." )
CreateConVar( "GAuto_Config_AutoPassenger", 1, { FCVAR_ARCHIVE }, "Unsupported vehicles will receive a single passenger seat next to the driver, if there is room for one." )
CreateConVar( "GAuto_Config_ParticlesEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Particles such as engine smoke and wheel dust will be emitted." )

--Blacklisted models that shouldn't be affected by GAuto, such as trains or other vehicles that use prop_vehicle_jeep as their base
GAuto.Blacklist = {
	["models/nova/airboat_seat.mdl"] = true, --Default gmod seat models
	["models/nova/chair_office01.mdl"] = true,
	["models/nova/chair_office02.mdl"] = true,
	["models/nova/chair_plastic01.mdl"] = true,
	["models/nova/chair_wood01.mdl"] = true,
	["models/nova/jalopy_seat.mdl"] = true,
	["models/nova/jeep_seat.mdl"] = true,
	["models/sligwolf/westernloco/western_locov2.mdl"] = true, --Sligwolf models (since his addons have their own mini vehicle system)
	["models/sligwolf/truck/swtruck001.mdl"] = true,
	["models/sligwolf/truck/swtruck002.mdl"] = true,
	["models/sligwolf/truck/swtruck003.mdl"] = true,
	["models/sligwolf/truck/swtruck004.mdl"] = true,
	["models/sligwolf/truck/swtruck005.mdl"] = true,
	["models/sligwolf/truck/swtruck006.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer001.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer002.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer003.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer004.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer005.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer006.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer007.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer008.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer009.mdl"] = true,
	["models/sligwolf/truck/swtruck_camper.mdl"] = true,
	["models/sligwolf/diesel/dieselv2.mdl"] = true,
	["models/sligwolf/diesel/diesel_wagon.mdl"] = true,
	["models/sligwolf/diesel/diesel_wagon2.mdl"] = true,
	["models/sligwolf/diesel/diesel_wagon3.mdl"] = true,
	["models/sligwolf/unique_props/seat.mdl"] = true,
	["models/sligwolf/garbagetruck/sw_truck.mdl"] = true,
	["models/sligwolf/tram/tram.mdl"] = true,
	["models/sligwolf/tram/tram_half.mdl"] = true,
	["models/sligwolf/forklift_truck/forklift_truck.mdl"] = true,
	["models/lonewolfie/trailer_glass.mdl"] = true, --LW trailers (so they can't get damaged and explode)
	["models/lonewolfie/trailer_livestock.mdl"] = true,
	["models/lonewolfie/trailer_panel.mdl"] = true,
	["models/lonewolfie/trailer_profiliner.mdl"] = true,
	["models/lonewolfie/trailer_schmied.mdl"] = true,
	["models/lonewolfie/trailer_transporter.mdl"] = true,
	["models/lonewolfie/trailer_truck.mdl"] = true,
	["models/sentry/trailers/bevtrailer.mdl"] = true, --SGM trailers
	["models/sentry/trailers/boatcarrier.mdl"] = true,
	["models/sentry/trailers/carcarrier.mdl"] = true,
	["models/sentry/trailers/stortrailer.mdl"] = true,
	["models/sentry/trailers/tanker.mdl"] = true,
	["models/sentry/fuel_trailer.mdl"] = true,
	["models/sentry/boxlong_trailer.mdl"] = true,
	["models/tdmcars/por_tricycle.mdl"] = true, --TDM Porsche tricycle
	["models/tdmcars/gtav/baletrailer.mdl"] = true, --TDM GTA 5 trailers/bikes
	["models/tdmcars/gtav/bmx.mdl"] = true,
	["models/tdmcars/gtav/camper_trailer.mdl"] = true,
	["models/tdmcars/gtav/tribike.mdl"] = true
}

function GAuto.IsBlackListed( veh )
	if !IsValid( veh ) then return true end --Return blacklisted if the vehicle isn't valid to avoid running IsValid twice
	local class = veh:GetClass()
	local model = veh:GetModel()
	if GAuto.Blacklist[model] and class == "prop_vehicle_jeep" and !veh:GetNWBool( "IsGAutoSeat" ) then
		return true
	end
	if class == "prop_vehicle_prisoner_pod" and !veh:GetNWBool( "IsGAutoSeat" ) then
		return true
	end
	if veh.fphysSeat then --Avoid interference with Simfphys
		return true
	end
	return false
end

--Template vehicle table
--You can this to create your own configs for testing or personal use
--[[
GAuto.Vehicles[""] = {
	HornSound = "gauto/carhorn.wav",
	MaxHealth = 100,
	Seats = {
		{
			pos = ,
			ang = Angle( 0, 0, 0 )
		}
	}
}
]]
