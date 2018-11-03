
-- Extends an object to act like spikes

-- Define module
local M = {}

local composer = require( "composer" )
local fx = require( "com.ponywolf.ponyfx" )

function M.new( object )
	if not object then error( "ERROR: Expected display object" ) end

	local visual = object
  
	-- Get current scene and sounds
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local sounds = scene.sounds

	function visual:collision( event )
		local phase, other = event.phase, event.other
		if phase == "began" and other.name == "hero" and not other.isDead then
			other:hurt()
			other:setLinearVelocity( 0, 0 )
			other:applyLinearImpulse( math.random(700) - 350, -350 )
		end
	end

	visual:addEventListener( "collision" )
	return visual
end

return M
