AddCSLuaFile()

GAuto = {}

for _,v in pairs( file.Find( "gauto/*", "LUA" ) ) do
	include( "gauto/"..v )
	AddCSLuaFile( "gauto/"..v )
end

for _,v in pairs( file.Find( "gauto/client/*", "LUA" ) ) do
	AddCSLuaFile( "gauto/client/"..v )
	if CLIENT then
		include( "gauto/client/"..v )
	end
end

if SERVER then
	for _,v in pairs( file.Find( "gauto/server/*", "LUA" ) ) do
		include( "gauto/server/"..v )
	end
end
