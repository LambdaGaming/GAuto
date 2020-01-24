
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
CreateConVar( "AM_Config_TireHealth", 10, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Amount of health each wheel has." )
CreateConVar( "AM_Config_FuelEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Enable or disable vehicle gas consumption." )
CreateConVar( "AM_Config_FuelAmount", 100, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Amount of fuel vehicles spawn with." )
CreateConVar( "AM_Config_NoFuelGod", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Enable or disable vehicles enabling god mode when they run out of fuel." )
CreateConVar( "AM_Config_CruiseEnabled", 1, { FCVAR_REPLICATED, FCVAR_ARCHIVE }, "Enable or disable players being able to activate cruise control." )