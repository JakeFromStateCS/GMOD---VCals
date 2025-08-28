--[[
    Vehicle Decal System
    JakeFromStateCS
    vcals/lib/debug/sh_init.lua
]]--
--Pass our global table to this file
VCals = VCals or {};
--Pass our global config table to this file
VCals.Config = VCals.Config or {};
--Create the debug table
VCals.Debug = {};
VCals.Debug.Config = {
    Prefix = "vcals",
    Colors = {
        sh = Color( 255, 150, 0 ),
        cl = Color( 255, 255, 0 ),
        sv = Color( 255, 0, 0 )
    }
};

--[[
    VCals.Debug:Print( ... ):
        Prints the data passed to it
]]--
function VCals.Debug:Print( ... )
    --Only debug print if debug is true in config
    if( VCals.Config.Debug ) then
        local realm = "";
        if( SERVER and not CLIENT ) then
            realm = "sv"
        elseif( CLIENT and not SERVER ) then
            realm = "cl";
        else
            realm = "sh";
        end;
        --MsgC our realm and prefix
        MsgC( self.Config.Colors[realm], realm .. "-" .. self.Config.Prefix );
        MsgC( Color( 255, 255, 255 ), " | " );
        --Set a print color to be modified later
        local printColor = Color( 255, 255, 255 );
        --Create a table for the misc vars
        local vars = { ... };
        --Create our print vars
        local printVars = {};
        --Loop through the vars
        for varID = 1, #vars do
            local var = vars[varID];
            --Set the type of the var;
            local varType = type( var );
            --Create a print string to be modified
            local printString = "";
            --If our var is a table, it's probably a print color
            if( varType == "table" ) then
                --But just in case, make sure it has rgb
                if( var.r and var.g and var.b ) then
                    printColor = var;
                end;
            else
                --If it's not a table, then we will try to tostring it
                printString = tostring( var ) .. " ";
            end;
            --MsgC our stuff
            MsgC( printColor, printString );
        end;
        --Send a new line at the end
        MsgC( Color( 255, 255, 255 ), "\n" );
    end;
end;

function VCals.Debug:PrintTable(table)
    local maxKeyLength = 0;
    for keyName, val in pairs(table) do
        local keyLength = string.len(keyName);
        if (keyLength > maxKeyLength) then
            maxKeyLength = keyLength;
        end;
    end;
    for keyName, val in pairs(table) do
        local keyLength = string.len(keyName);
        if (keyLength < maxKeyLength) then
            local padding = string.rep(' ', maxKeyLength - keyLength);
            keyName = keyName .. padding;
        end;
        print(keyName .. ' = ' .. val);
    end;
end;