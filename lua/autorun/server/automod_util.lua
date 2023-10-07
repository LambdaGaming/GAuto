
util.AddNetworkString( "AM_Notify" )
function AM_Notify( ply, text, broadcast )
	if broadcast then
		net.Start( "AM_Notify" )
		net.WriteString( text )
		net.Broadcast()
		return
	end
	net.Start( "AM_Notify" )
	net.WriteString( text )
	net.Send( ply )
end

function AM_TrimModel( model )
	if isstring( model ) then
		local removemodel = string.gsub( model, "models/", "" )
		local removeextention = string.StripExtension( removemodel )
		local replaceslash = string.Replace( removeextention, "/", "%" )
		return replaceslash
	end
	return ""
end

function AM_SaveAllVehicles()
	for k,v in pairs( AM_Vehicles ) do
		timer.Simple( 0.5, function()
			local slashfix = AM_TrimModel( k )
			if file.Exists( "addons/Automod/data_static/automod/vehicles/"..slashfix..".json", "GAME" ) then
				print( "[Automod] File for '"..k.."' already exists. Skipping." )
				return
			end
			if !file.Exists( "automod/vehicles", "DATA" ) then file.CreateDir( "automod/vehicles" ) end
			file.Write( "automod/vehicles/"..slashfix..".json", util.TableToJSON( v, true ) )
			print( "[Automod] Successfully saved '"..k.."' to file." )
		end )
	end
end

local function AM_SaveVehicle( model )
	if AM_Vehicles[model] then
		local slashfix = AM_TrimModel( model )
		if file.Exists( "automod/vehicles/"..slashfix..".json", "DATA" ) or file.Exists( "addons/Automod/data_static/automod/vehicles/"..slashfix..".json", "GAME" ) then
			print( "[Automod] This vehicle has already been saved. Delete it's data file and try again if you're saving a newer version." )
			return
		end
		file.Write( "automod/vehicles/"..slashfix..".json", util.TableToJSON( AM_Vehicles[model], true ) )
		print( "[Automod] Successfully saved "..model.." to Automod files." )
	else
		MsgC( Color( 255, 0, 0 ), "[Automod] ERROR: The specified model doesn't seem to exist. Check your spelling and vehicle tables." )
	end
end
concommand.Add( "AM_SaveVehicle", function( ply, cmd, args )
	if IsValid( ply ) and !ply:IsSuperAdmin() then
		AM_Notify( ply, "Only superadmins and server operators can access this command!" )
		return
	end
	if #args > 1 then
		MsgC( Color( 255, 0, 0 ), "[Automod] ERROR: Please only enter 1 argument." )
		return
	end
	AM_SaveVehicle( args[1] )
end )

local shouldsave = gmsave.ShouldSaveEntity
function gmsave.ShouldSaveEntity( ent, t ) --Finding decent documentation on this function was such a pain, especially now that the facepunch forums are gone
	if ent:GetNWBool( "IsAutomodSeat" ) then return false end --Should prevent the seats from duping themselves after loading a save
	return shouldsave( ent, t )
end
