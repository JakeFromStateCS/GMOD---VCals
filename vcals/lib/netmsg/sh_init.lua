/*
	Vehicle Decal System
	JakeFromStateCS
	vcals/lib/netmsg/sh_init.lua
*/
--Pass our global table to this file
VCals = VCals or {};
--Pass our global config table to this file
VCals.Config = VCals.Config or {};
VCals.Netmsg = {};
VCals.Netmsg.Stored = {};
VCals.Netmsg.Config = {
	NetName = "VCals_NetMsg",
	DataTypes = {
		["Number"] = "Double",
		["NextBot"] = "Entity",
		["Player"] = "Entity",
		["NPC"] = "Entity",
		["Table"] = "Table"
	}
}
--Register our network string
if( SERVER ) then
	util.AddNetworkString( VCals.Netmsg.Config.NetName );
end;


--[[
	VCals.Netmsg:Register( String/netName, Function/func ):
		Registers the net message
]]--
function VCals.Netmsg:Register( netName, func )
	self.Stored[netName] = func;
end;


--[[
	VCals.Netmsg:Send( Player/client, String/netName, Misc/... ):
		Handles sending of net messages
]]--
function VCals.Netmsg:Send( client, netMsg, ... )
	local tab = { ... };
	local clients = {};
	--If the client is a string, it's the net message
	if( type( client ) == "string" ) then
		tab = { netMsg };
		netMsg = client;
		client = nil;
		clients = player.GetAll();
	--If the type is a table, make sure the table consists of players
	elseif( type( client ) == "table" ) then
		for _,data in pairs( client ) do
			if( type( data ) == "Player" ) then
				table.insert( clients, data );
			end;
		end;
	--If it's just a player, then we're sending it to that person
	elseif( type( client ) == "Player" ) then
		clients = client;
	end;
	--Start the net message
	net.Start( self.Config.NetName );
		--If it's on client, we want to write localplayer so the server knows who sent it
		if( CLIENT ) then
			net.WriteEntity( LocalPlayer() );
		end;
		--Write the net function name we're calling
		net.WriteString( netMsg );
		--Define a table for the types of data we're going to send
		local dataTypes = {};
		--Loop through the data table and insert the types we'll send
		for _,data in pairs( tab ) do
			--Get the type name and use the type name defined in the config if it exists
			local typeName = type( data ):gsub( "^%l", string.upper );
			if( self.Config.DataTypes[typeName] ) then
				typeName = self.Config.DataTypes[typeName];
			end;
			--Insert that into our types to send
			table.insert( dataTypes, typeName );
		end;
		--Send the table of data types
		net.WriteTable( dataTypes );
		for index,typeName in pairs( dataTypes ) do
			local func = net["Write" .. typeName];
			local data = tab[index];
			if( func ) then
				func( data );
			end;
		end;
	if( CLIENT ) then
		net.SendToServer();
	else
		net.Send( clients );
	end;
end;

--[[
	VCals.Netmsg:Receive():
		Handles receiving net messages
]]--
function VCals.Netmsg:Receive()
	local client;
	if( SERVER ) then
		client = net.ReadEntity();
	end;
	local netMsg = net.ReadString();
	local dataTypes = net.ReadTable();
	PrintTable( dataTypes );
	local dataTable = {};
	if( client ) then
		table.insert( dataTable, client );
	end;
	for _,dataType in pairs( dataTypes ) do
		local data = net["Read" .. dataType]();
		table.insert( dataTable, data );
	end;
	if( netMsg ) then
		local func = VCals.Netmsg.Stored[netMsg];
		if( func ) then
			func( unpack( dataTable ) );
		end;
	end;
end;
net.Receive( VCals.Netmsg.Config.NetName, VCals.Netmsg.Receive );