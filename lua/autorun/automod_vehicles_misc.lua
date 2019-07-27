
--[[
AM_Vehicles[""] = {
	HornSound = "automod/carhorn.wav",
	MaxHealth = 100,
	EnginePos = ,
	Seats = {
		{
			pos = ,
			ang = Angle( 0, 0, 0 )
		}
	}
}
]]

AM_Vehicles["models/perrynsvehicles/bearcat_g3/bearcat_g3.mdl"] = {
	HornSound = "automod/truckhorn.mp3",
	MaxHealth = 200,
	EnginePos = Vector( 0, 75, 64 ),
	Seats = {
		{
			pos = Vector( 22, 12, 47 ),
			ang = Angle( 0, 0, 0 )
		},
		{
			pos = Vector( -22, -19, 53 ),
			ang = Angle( 0, 180, 0 )
		},
		{
			pos = Vector( 22, -21, 54 ),
			ang = Angle( 0, 180, 0 )
		},
		{
			pos = Vector( 34, -59, 51 ),
			ang = Angle( 0, 90, 0 )
		},
		{
			pos = Vector( 34, -85, 50 ),
			ang = Angle( 0, 90, 0 )
		},
		{
			pos = Vector( 34, -112, 49 ),
			ang = Angle( 0, 90, 0 )
		},
		{
			pos = Vector( -36, -64, 51 ),
			ang = Angle( 0, -90, 0 )
		},
		{
			pos = Vector( -36, -99, 51 ),
			ang = Angle( 0, -90, 0 )
		}
	}
}

AM_Vehicles["models/buggy.mdl"] = { --HL2 jeep
	HornSound = "automod/carhorn.wav",
	MaxHealth = 100,
	EnginePos = Vector( 21, 12, 63 ),
	Seats = {
		{
			pos = Vector( 15, -35, 23 ),
			ang = Angle( 0, 0, 0 )
		}
	}
}