
-- Extends an visual to act as a pickup

-- Define module
local M = {}

local composer = require( "composer" )

function M.new( object )
	if not object then error( "ERROR: Expected display visual" ) end

	local visual = object

	-- Get scene and sounds
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local sounds = scene.sounds

	function visual:collision( event )

		local phase, other = event.phase, event.other
		if phase == "began" and other.type == "hero" then
			audio.play( sounds.coin )
			scene.score:add( 100 )
			display.remove( object )
		end
	end

	visual._y = visual.y
	transition.from( visual, { y = visual._y - 16, transition = easing.outBounce, time = 500, iterations = -1 } )
	visual:addEventListener( "collision" )

	return visual
end

return M
