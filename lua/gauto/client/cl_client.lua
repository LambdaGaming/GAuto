function GAuto.Notify( text )
	local textcolor1 = Color( 180, 0, 0, 255 )
	local textcolor2 = color_white
	chat.AddText( textcolor1, "[GAuto]: ", textcolor2, text )
end

net.Receive( "GAuto_Notify", function()
	local text = net.ReadString()
	GAuto.Notify( text )
end )

local smokevelocity = Vector( 0, 0, 50 )
local function SmokeThink()
	local GAuto_ParticlesEnabled = GetConVar( "gauto_particles_enabled" ):GetBool()
	if !GAuto_ParticlesEnabled then return end
	local ply = LocalPlayer()
	local pos = ply:GetPos()
	local find = ents.FindInSphere( pos, 2000 )
	for k,v in ipairs( find ) do
		if !string.find( v:GetClass(), "prop_vehicle_jeep" ) then continue end
		local eng = v:GetAttachment( v:LookupAttachment( "vehicle_engine" ) )
		if !eng or eng.Pos == vector_origin then continue end
		if v:GetNWBool( "GAuto_IsSmoking" ) then
			local rand = math.random( 1, 9 )
			local offset = v:GetNWVector( "GAuto_EngineOffset" )
			local pos = eng.Pos + offset
			local emitter = ParticleEmitter( pos )
			local smoke = emitter:Add( "particle/smokesprites_000"..rand, pos )
			local dietime = math.Rand( 0.6, 1.3 )
			local startsize = math.random( 0, 5 )
			local endsize = math.random( 33, 55 )
			smoke:SetVelocity( smokevelocity )
			smoke:SetDieTime( dietime )
			smoke:SetStartSize( startsize )
			smoke:SetEndSize( endsize )
			smoke:SetColor( 72, 72, 72 )
			emitter:Finish()
		end
	end
end
hook.Add( "Think", "GAuto_SmokeThink", SmokeThink )
