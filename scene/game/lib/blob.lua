
-- Module/class for platfomer animal/blob
-- Use this as a template to build an in-game animal/blob

-- Define module
local M = {}

local composer = require( "composer" )

function M.new( object )
	if not object then error( "ERROR: Expected display object" ) end

	-- Get scene and sounds
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local sounds = scene.sounds
	local visual = object

	visual.anchorY = 0.5

	function visual:die()
		audio.play( sounds.squish )
		self.isFixedRotation = false
		self.isSensor = true
		self:applyLinearImpulse( 0, -100 )
		self.isDead = true
	end

	function visual:preCollision( event )
		local other = event.other
		local y1, y2 = self.y, other.y - other.height/2
		if event.contact and ( y1 > y2 ) then
			-- Don't bump into one way platforms
			if other.floating then
				event.contact.isEnabled = false
			else
				event.contact.friction = 0.1
			end
		end
	end

	local max, direction, flip, timeout, idle = 200, 750, -0.133, 0, 0
	direction = direction * ( ( visual.xScale < 0 ) and 1 or -1 )
	flip = flip * ( ( visual.xScale < 0 ) and 1 or -1 )

	local function enterFrame()

		-- Do this every frame
		local vx, vy = visual:getLinearVelocity()
		local dx = direction
		if visual.jumping then dx = dx / 4 end
		if ( dx < 0 and vx > -max ) or ( dx > 0 and vx < max ) then
			visual:applyForce( dx or 0, 0, visual.x, visual.y )
		end

		-- Bumped
		if math.abs( vx ) < 1 then
			timeout = timeout + 1
			if timeout > 30 then
				timeout = 0
				direction, flip = -direction, -flip
			end
		end

		-- Breathe
		idle = idle + 0.08
		visual.yScale = 1 + ( 0.075 * math.sin( idle ) )

		-- Turn around
		visual.xScale = math.min( 1, math.max( visual.xScale + flip, -1 ) )
	end

	function visual:finalize()
		-- On remove, cleanup visual, or call directly for non-visual
		Runtime:removeEventListener( "enterFrame", enterFrame )
		visual = nil
	end

	-- Add a finalize listener (for display objects only; comment out for non-visual)
	visual:addEventListener("finalize")

	-- Add our enterFrame listener
	Runtime:addEventListener( "enterFrame", enterFrame )

	-- Add our collision listener
	visual:addEventListener( "preCollision" )

	-- Return visual
	return visual
end

return M
