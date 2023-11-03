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
