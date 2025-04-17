--Will allow airboats, jeeps that aren't in the list, and prisoner pods that are GAuto passenger seats
function GAuto.IsBlackListed( veh )
	if !IsValid( veh ) or !veh:IsVehicle() then return true end
	local class = veh:GetClass()
	local model = veh:GetModel()
	if GAuto.Blacklist[model] and class == "prop_vehicle_jeep" then
		return true
	end
	if class == "prop_vehicle_prisoner_pod" and !veh:GetNWBool( "IsGAutoSeat" ) then
		return true
	end
	if veh.fphysSeat then
		--Avoid interference with Simfphys
		return true
	end
	return false
end

--Will allow all jeeps and airboats
function GAuto.IsDrivable( ent )
	return IsValid( ent ) and ( ent:GetClass() == "prop_vehicle_jeep" or ent:GetClass() == "prop_vehicle_airboat" )
end

if SERVER then
	util.AddNetworkString( "GAuto_Notify" )
	function GAuto.Notify( ply, text )
		net.Start( "GAuto_Notify" )
		net.WriteString( text )
		net.Send( ply )
	end

	function GAuto.TrimModel( model )
		if isstring( model ) then
			local removeModel = string.gsub( model, "models/", "" )
			local removeExtension = string.StripExtension( removeModel )
			local replaceSlash = string.Replace( removeExtension, "/", "%" )
			return replaceSlash
		end
		return ""
	end
end
