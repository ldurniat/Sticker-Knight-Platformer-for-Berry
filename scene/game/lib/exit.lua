
-- Extends an object to load a new map

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
			other.isDead = true
			other.linearDamping = 8
			audio.play( sounds.door )
			self.fill.effect = "filter.exposure"

			transition.to( self.fill.effect, { time = 666, exposure = -5, onComplete = function()
				fx.fadeOut( function()
					composer.gotoScene( "scene.refresh", { params = { nextMap = self.nextMap, score = scene.score:get() } } )
				end )
			end } )
		end
	end

	visual:addEventListener( "collision" )
	return visual
end

return M
