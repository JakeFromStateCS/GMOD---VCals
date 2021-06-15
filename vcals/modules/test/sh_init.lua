/*
	Test module
*/
MODULE = MODULE or {};
MODULE.Name = "Test";
MODULE.Hooks = {};
MODULE.Nets = {};

if( CLIENT ) then
	function MODULE.Hooks:HUDPaint()
		
	end;
end;

function MODULE.Nets:Test( data )
	print( "Test module:", data );
end;