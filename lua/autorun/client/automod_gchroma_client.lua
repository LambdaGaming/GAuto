local function AM_InitGChroma()
	if gchroma.Loaded then
		local keys = {
			gchroma.KeyConvert( GetConVar( "AM_Control_HornKey" ):GetInt() ),
			gchroma.KeyConvert( GetConVar( "AM_Control_LockKey" ):GetInt() ),
			gchroma.KeyConvert( GetConVar( "AM_Control_CruiseKey" ):GetInt() ),
			gchroma.KeyConvert( GetConVar( "AM_Control_EngineKey" ):GetInt() )
		}
		for k,v in pairs( keys ) do
			gchroma.SetDeviceColorEx( GCHROMA_DEVICE_KEYBOARD, GCHROMA_COLOR_WHITE, v, 0 )
		end
		gchroma.CreateEffect( true )
	end
end
net.Receive( "AM_InitGChroma", AM_InitGChroma )
