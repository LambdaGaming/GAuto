
function AM_Notify( text )
	local textcolor1 = Color( 180, 0, 0, 255 )
	local textcolor2 = color_white
	chat.AddText( textcolor1, "[Automod]: ", textcolor2, text )
end

net.Receive( "AM_Notify", function()
	local text = net.ReadString()
	AM_Notify( text )
end )

local function AM_SmokeThink()
	local ply = LocalPlayer()
	for k,v in pairs( ents.FindByClass( "prop_vehicle_jeep" ) ) do
		if v:GetNWBool( "AM_IsSmoking" ) then
			local carpos = v:GetPos()
			local plypos = ply:GetPos()
			if plypos:DistToSqr( carpos ) < 4000000 then --Only displays particles if the player is within a certain distance of the vehicle, helps with optimization
				local pos = v:LocalToWorld( v:GetNWVector( "AM_EnginePos" ) )
				local smoke = ParticleEmitter( pos ):Add( "particle/smokesprites_000"..math.random( 1, 9 ), pos )
				smoke:SetVelocity( Vector( 0, 0, 50 ) )
				smoke:SetDieTime( math.Rand( 0.6, 1.3 ) )
				smoke:SetStartSize( math.random( 0, 5 ) )
				smoke:SetEndSize( math.random( 33, 55 ) )
				smoke:SetColor( 72, 72, 72 )
			end
		end
	end
end
hook.Add( "Think", "AM_SmokeThink", AM_SmokeThink )

local function AM_InitGChroma()
	if GChroma_Loaded then
		local keys = {
			GChroma_KeyConvert( GetConVar( "AM_Control_HornKey" ):GetInt() ),
			GChroma_KeyConvert( GetConVar( "AM_Control_LockKey" ):GetInt() ),
			GChroma_KeyConvert( GetConVar( "AM_Control_CruiseKey" ):GetInt() ),
			GChroma_KeyConvert( GetConVar( "AM_Control_EngineKey" ):GetInt() )
		}
		for k,v in pairs( keys ) do
			GChroma_SetDeviceColorEx( GCHROMA_DEVICE_KEYBOARD, Vector( 255, 255, 255 ), v, 0 )
		end
	end
end
net.Receive( "AM_InitGChroma", AM_InitGChroma )
