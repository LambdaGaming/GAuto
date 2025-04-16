GAuto.Vehicles = {}

game.AddParticles( "particles/vehicle.pcf" )
game.AddParticles( "particles/fire_01.pcf" )
PrecacheParticleSystem( "WheelDust" )
PrecacheParticleSystem( "burning_engine_fire" )
PrecacheParticleSystem( "smoke_burning_engine_01" )

CreateConVar( "gauto_health_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Vehicles will take damage." )
CreateConVar( "gauto_bullet_damage_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Vehicles will take bullet damage. Does nothing if gauto_health_enabled is disabled." )
CreateConVar( "gauto_damage_explosion_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE } , "Vehicles explode when their health reaches 0.")
CreateConVar( "gauto_charring_time", 120, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "How long a vehicle has to be on fire for until it becomes charred and permanently disabled. Set to -1 to disable. (Requires VFire)" )
CreateConVar( "gauto_explode_remove_time", 600, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Time it takes in seconds for a destroyed vehicle to get removed. Set to -1 to disable." )
CreateConVar( "gauto_scale_player_damage", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Damage that players take while in a vehicle will be scaled down." )
CreateConVar( "gauto_brake_lock_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Brakes will lock up and prevent the vehicle from moving if the driver holds jump while exiting." )
CreateConVar( "gauto_wheel_lock_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Wheels will remain turned when the driver exits the vehicle." )
CreateConVar( "gauto_seats_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Supported vehicles will spawn with passenger seats." )
CreateConVar( "gauto_horn_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Drivers will be able to sound a horn by pressing a specific button." )
CreateConVar( "gauto_lock_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Drivers will be able to lock their vehicles by pressing a specific button." )
CreateConVar( "gauto_lock_alarm_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Lockpicking a vehicle in DarkRP will sound an alarm." )
CreateConVar( "gauto_tire_damage_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Vehicle tires will take damage and eventually pop." )
CreateConVar( "gauto_tire_health", 10, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Amount of health each wheel/tire has." )
CreateConVar( "gauto_fuel_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Vehicles will consume fuel and stop working when out of fuel." )
CreateConVar( "gauto_fuel_amount", 100, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Amount of fuel vehicles spawn with." )
CreateConVar( "gauto_no_fuel_god", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Vehicles that are out of fuel cannot be damaged." )
CreateConVar( "gauto_cruise_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Drivers will be able to activate cruise control by pressing a specific button." )
CreateConVar( "gauto_health_override", 0, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Amount of health every vehicle spawns with no matter what. Set to 0 to disable." )
CreateConVar( "gauto_driver_seat", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Players will automatically enter the drivers seat if it is not taken. If set to 0, players will enter the closest detected seat." )
CreateConVar( "gauto_spike_model", "models/props_phx/mechanics/slider2.mdl", { FCVAR_ARCHIVE }, "The model of the spikestrip." )
CreateConVar( "gauto_spike_model_offset", 90, { FCVAR_ARCHIVE }, "Yaw offset that the spikestrip should be placed at." )
CreateConVar( "gauto_fuel_loss_rate", 0.5, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "How fast fuel should drain when the throttle is pressed. You probably shouldn't touch this unless you know what you're doing." )
CreateConVar( "gauto_auto_passenger", 1, { FCVAR_ARCHIVE }, "Unsupported vehicles will receive a single passenger seat next to the driver, if there is room for one." )
CreateConVar( "gauto_particles_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Particles such as engine smoke and wheel dust will be emitted." )

--Blacklisted models that shouldn't be affected by GAuto, such as trains or other vehicles that use prop_vehicle_jeep as their base
GAuto.Blacklist = {
	["models/nova/airboat_seat.mdl"] = true, --Default gmod seat models
	["models/nova/chair_office01.mdl"] = true,
	["models/nova/chair_office02.mdl"] = true,
	["models/nova/chair_plastic01.mdl"] = true,
	["models/nova/chair_wood01.mdl"] = true,
	["models/nova/jalopy_seat.mdl"] = true,
	["models/nova/jeep_seat.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer001.mdl"] = true, --Sligwolf trailers
	["models/sligwolf/truck/swtrucktrailer002.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer003.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer004.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer005.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer006.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer007.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer008.mdl"] = true,
	["models/sligwolf/truck/swtrucktrailer009.mdl"] = true,
	["models/sligwolf/truck/swtruck_camper.mdl"] = true,
	["models/sligwolf/tractor/tractor_trailer.mdl"] = true,
	["models/lonewolfie/trailer_glass.mdl"] = true, --LW trailers
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

--Will allow airboats, jeeps that aren't in the list, and prisoner pods that are GAuto passenger seats
function GAuto.IsBlackListed( veh )
	if !IsValid( veh ) or !veh:IsVehicle() then return true end
	local class = veh:GetClass()
	local model = veh:GetModel()
	if GAuto.Blacklist[model] and class == "prop_vehicle_jeep" then
		return true
	end
	if class == "prop_vehicle_prisoner_pod" and !veh:GetNWBool( "IsGAutoSeat" ) then
		return true
	end
	if veh.fphysSeat then
		--Avoid interference with Simfphys
		return true
	end
	return false
end

--Will allow all jeeps and airboats
function GAuto.IsDrivable( ent )
	return IsValid( ent ) and ( ent:GetClass() == "prop_vehicle_jeep" or ent:GetClass() == "prop_vehicle_airboat" )
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
