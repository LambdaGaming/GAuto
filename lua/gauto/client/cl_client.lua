function GAuto.Notify( text )
	local textcolor1 = Color( 180, 0, 0, 255 )
	local textcolor2 = color_white
	chat.AddText( textcolor1, "[GAuto]: ", textcolor2, text )
end

net.Receive( "GAuto_Notify", function()
	local text = net.ReadString()
	GAuto.Notify( text )
end )
