local function AM_InitGChroma()
	if GChroma_Loaded then
		local keys = {
			GChroma_KeyConvert( GetConVar( "AM_Control_HornKey" ):GetInt() ),
			GChroma_KeyConvert( GetConVar( "AM_Control_LockKey" ):GetInt() ),
			GChroma_KeyConvert( GetConVar( "AM_Control_CruiseKey" ):GetInt() ),
			GChroma_KeyConvert( GetConVar( "AM_Control_EngineKey" ):GetInt() )
		}
		for k,v in pairs( keys ) do
			GChroma_SetDeviceColorEx( GCHROMA_DEVICE_KEYBOARD, GCHROMA_COLOR_WHITE, v, 0 )
		end
	end
end
net.Receive( "AM_InitGChroma", AM_InitGChroma )
