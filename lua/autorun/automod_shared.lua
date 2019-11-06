
--[[
    Features of this this system:
    1. Vehicle health system (still working out the kinks with physical damage)
    2. Brakes lock when the player exits the vehicle (can be released by a brake release swep for towing purposes)
    3. Steering wheel remains in the position it was in when the player leaves the vehicle
    4. Vehicle seat system
    5. Horns
    6. Vehicle locking system (with alarm)

	Planned features:
	1. Trailer hookup (with a tool to link a truck and a trailer)
	2. Tire popping (complete with bullet damage and spike strips)
	3. Better looking HUD (smaller box that sits on top of the photon HUD, or down in the corner if current vehicle doesn't have photon support)
	4. Customizable controls/server settings
]]

AM_Vehicles = {}

CreateConVar( "AM_Config_HealthEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Enable or disable vehicles taking damage." )
CreateConVar( "AM_Config_BulletDamageEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Enable or disable allowing vehicles to take damage from bullets." )
CreateConVar( "AM_Config_DamageExplosionEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE } , "Enable or disable vehicles exploding when their health reaches 0.")
CreateConVar( "AM_Config_ExplodeRemoveEnabled", 0, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Enable or disable destroyed vehicles being removed after a certain time." )
CreateConVar( "AM_Config_ExplodeRemoveTime", 600, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Time it takes in seconds for a destroyed vehicle to get removed. AM_Config_ExplodeRemoveEnabled must be set to 1 for this to work." )
CreateConVar( "AM_Config_ScalePlayerDamage", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Enable or disable scaling down how much damage players take when inside a vehicle." )

CreateConVar( "AM_Config_BrakeLockEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Enable or disable the brakes locking when a player exits a vehicle." )
CreateConVar( "AM_Config_WheelLockEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Enable or disable the steering wheel locking in a certain position when a player exits a vehicle." )
CreateConVar( "AM_Config_SeatsEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Enable or disable vehicles spawning with passenger seats." )
CreateConVar( "AM_Config_HornEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Enable or disable players being able to use their horns." )
CreateConVar( "AM_Config_LockEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Enable or disable players being able to lock their vehicles." )
CreateConVar( "AM_Config_LockAlarmEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Enable or disable the alarm going off when a player lockpicks a vehicle." )
CreateConVar( "AM_Config_TirePopEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Enable or disable a vehicles tires being able to be popped." )

CreateClientConVar( "AM_Control_HornKey", KEY_H, true, false, "Sets the key for the horn." )
CreateClientConVar( "AM_Control_LockKey", KEY_N, true, false, "Sets the key for locking the doors." )
