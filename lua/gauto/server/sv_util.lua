util.AddNetworkString( "GAuto_Notify" )
function GAuto.Notify( ply, text, broadcast )
	if broadcast then
		net.Start( "GAuto_Notify" )
		net.WriteString( text )
		net.Broadcast()
		return
	end
	net.Start( "GAuto_Notify" )
	net.WriteString( text )
	net.Send( ply )
end

function GAuto.TrimModel( model )
	if isstring( model ) then
		local removemodel = string.gsub( model, "models/", "" )
		local removeextention = string.StripExtension( removemodel )
		local replaceslash = string.Replace( removeextention, "/", "%" )
		return replaceslash
	end
	return ""
end

function GAuto.SaveAllVehicles()
	for k,v in pairs( GAuto.Vehicles ) do
		timer.Simple( 0.5, function()
			local slashfix = GAuto.TrimModel( k )
			if file.Exists( "data_static/gauto/vehicles/"..slashfix..".json", "THIRDPARTY" ) then
				print( "[GAuto] File for '"..k.."' already exists. Skipping." )
				return
			end
			if !file.Exists( "gauto/vehicles", "DATA" ) then file.CreateDir( "gauto/vehicles" ) end
			file.Write( "gauto/vehicles/"..slashfix..".json", util.TableToJSON( v, true ) )
			print( "[GAuto] Successfully saved '"..k.."' to file." )
		end )
	end
end

local function SaveVehicle( model )
	if GAuto.Vehicles[model] then
		local slashfix = GAuto.TrimModel( model )
		if file.Exists( "gauto/vehicles/"..slashfix..".json", "DATA" ) or file.Exists( "data_static/gauto/vehicles/"..slashfix..".json", "THIRDPARTY" ) then
			print( "[GAuto] This vehicle has already been saved. Delete it's data file and try again if you're saving a newer version." )
			return
		end
		file.Write( "gauto/vehicles/"..slashfix..".json", util.TableToJSON( GAuto.Vehicles[model], true ) )
		print( "[GAuto] Successfully saved "..model.." to GAuto files." )
	else
		MsgC( Color( 255, 0, 0 ), "[GAuto] ERROR: The specified model doesn't seem to exist. Check your spelling and vehicle tables." )
	end
end
concommand.Add( "GAuto_SaveVehicle", function( ply, cmd, args )
	if IsValid( ply ) and !ply:IsSuperAdmin() then
		GAuto.Notify( ply, "Only superadmins and server operators can access this command!" )
		return
	end
	if #args > 1 then
		MsgC( Color( 255, 0, 0 ), "[GAuto] ERROR: Please only enter 1 argument." )
		return
	end
	SaveVehicle( args[1] )
end )

local shouldsave = gmsave.ShouldSaveEntity
function gmsave.ShouldSaveEntity( ent, t ) --Finding decent documentation on this function was such a pain, especially now that the facepunch forums are gone
	if ent:GetNWBool( "IsGAutoSeat" ) then return false end --Should prevent the seats from duping themselves after loading a save
	return shouldsave( ent, t )
end
