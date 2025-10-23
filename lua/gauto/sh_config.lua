GAuto.Vehicles = {}

game.AddParticles( "particles/vehicle.pcf" )
game.AddParticles( "particles/fire_01.pcf" )
PrecacheParticleSystem( "WheelDust" )
PrecacheParticleSystem( "burning_engine_fire" )
PrecacheParticleSystem( "smoke_burning_engine_01" )

--Feature toggles
CreateConVar( "gauto_health_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Vehicles will take damage." )
CreateConVar( "gauto_damage_explosion_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE } , "Vehicles explode when their health reaches 0." )
CreateConVar( "gauto_brake_lock_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Brakes will stay locked when the driver holds jump while exiting." )
CreateConVar( "gauto_wheel_lock_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Front wheels will remain turned when the driver exits the vehicle." )
CreateConVar( "gauto_seats_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Supported vehicles will spawn with passenger seats." )
CreateConVar( "gauto_horn_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Drivers will be able to sound a horn by pressing a specific button." )
CreateConVar( "gauto_lock_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Drivers will be able to lock their vehicles by pressing a specific button." )
CreateConVar( "gauto_lock_alarm_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Lockpicking a vehicle in DarkRP will sound an alarm." )
CreateConVar( "gauto_tire_damage_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Vehicle tires will take damage and eventually pop." )
CreateConVar( "gauto_fuel_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Vehicles will consume fuel and stop working when out of fuel." )
CreateConVar( "gauto_cruise_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Drivers will be able to activate cruise control by pressing a specific button." )
CreateConVar( "gauto_particles_enabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Particles such as engine smoke and wheel dust will be emitted." )

--Health & Damage
CreateConVar( "gauto_phys_damage_multiplier", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Multiplier for physical damage done to vehicles. Does nothing if gauto_health_enabled is disabled." )
CreateConVar( "gauto_bullet_damage_multiplier", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Multiplier for vehicle bullet damage. Does nothing if gauto_health_enabled is disabled." )
CreateConVar( "gauto_player_damage_multiplier", 0.35, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Damage multiplier for players in vehicles." )
CreateConVar( "gauto_tire_health", 10, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Amount of health each wheel/tire has." )
CreateConVar( "gauto_charring_time", 120, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "How long a vehicle has to be on fire for until it becomes charred and permanently disabled. Set to -1 to disable. (Requires VFire)" )
CreateConVar( "gauto_explode_remove_time", 600, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Time it takes in seconds for a destroyed vehicle to get removed. Set to -1 to disable." )
CreateConVar( "gauto_no_fuel_god", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Vehicles that are out of fuel cannot be damaged." )
CreateConVar( "gauto_health_override", 0, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Amount of health every vehicle spawns with no matter what. Set to 0 to disable." )

--Fuel
CreateConVar( "gauto_fuel_amount", 100, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Amount of fuel vehicles spawn with." )
CreateConVar( "gauto_fuel_loss_rate", 0.5, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "How fast fuel should drain when the throttle is being pressed." )

--Spikestrip
CreateConVar( "gauto_spike_model", "models/props_phx/mechanics/slider2.mdl", { FCVAR_ARCHIVE }, "The model of the spikestrip." )
CreateConVar( "gauto_spike_model_offset", 90, { FCVAR_ARCHIVE }, "Yaw offset that the spikestrip should be placed at." )

--Passenger Seats
CreateConVar( "gauto_driver_seat", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Players will automatically enter the drivers seat if it is not taken. If set to 0, players will enter the closest detected seat." )
CreateConVar( "gauto_auto_passenger", 1, { FCVAR_ARCHIVE }, "Unsupported vehicles will receive a single passenger seat next to the driver, if there is room for one." )

--Blacklisted models that shouldn't be affected by GAuto, such as trains or other vehicles that use prop_vehicle_jeep as their base
GAuto.Blacklist = {
	["models/nova/airboat_seat.mdl"] = true, --Default gmod seat models
	["models/nova/chair_office01.mdl"] = true,
	["models/nova/chair_office02.mdl"] = true,
	["models/nova/chair_plastic01.mdl"] = true,
	["models/nova/chair_wood01.mdl"] = true,
	["models/nova/jalopy_seat.mdl"] = true,
	["models/nova/jeep_seat.mdl"] = true,
	["models/sligwolf/truck/trailer_semi_car.mdl"] = true, --Sligwolf trailers
	["models/sligwolf/truck/trailer_semi_cargo_door.mdl"] = true,
	["models/sligwolf/truck/trailer_semi_box.mdl"] = true,
	["models/sligwolf/truck/trailer_semi_tanker.mdl"] = true,
	["models/sligwolf/truck/trailer_dolly.mdl"] = true,
	["models/sligwolf/truck/trailer_tandem_empty.mdl"] = true,
	["models/sligwolf/truck/trailer_tandem_cargo_door.mdl"] = true,
	["models/sligwolf/truck/trailer_tandem_box.mdl"] = true,
	["models/sligwolf/truck/trailer_tandem_tanker.mdl"] = true,
	["models/sligwolf/truck/trailer_heavy_car.mdl"] = true,
	["models/sligwolf/truck/trailer_heavy_container.mdl"] = true,
	["models/sligwolf/truck/trailer_heavy_train.mdl"] = true,
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
