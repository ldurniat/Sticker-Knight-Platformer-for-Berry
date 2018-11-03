
-- Module/class for platfomer hero

-- Use this as a template to build an in-game hero 
local fx = require( "com.ponywolf.ponyfx" )
local composer = require( "composer" )

-- Define module
local M = {}

function M.new( object )	
	-- Get the current scene
	local scene = composer.getScene( composer.getSceneName( "current" ) )
	local sounds = scene.sounds

	local visual = object
	visual.anchorY = 0.77

	-- Keyboard control
	local max, acceleration, left, right, flip = 375, 5000, 0, 0, 0
	local lastEvent = {}
	local function key( event )
		local phase = event.phase
		local name = event.keyName
		if ( phase == lastEvent.phase ) and ( name == lastEvent.keyName ) then return false end  -- Filter repeating keys
		if phase == "down" then
			if "left" == name or "a" == name then
				left = -acceleration
				flip = -0.133
			end
			if "right" == name or "d" == name then
				right = acceleration
				flip = 0.133
			elseif "space" == name or "buttonA" == name or "button1" == name then
				visual:jump()
			end
			if not ( left == 0 and right == 0 ) and not visual.jumping then
				visual:setSequence( "walk" )
				visual:play()
			end
		elseif phase == "up" then
			if "left" == name or "a" == name then left = 0 end
			if "right" == name or "d" == name then right = 0 end
			if left == 0 and right == 0 and not visual.jumping then
				visual:setSequence("idle")
			end
		end
		lastEvent = event
	end

	function visual:jump()
		if not self.jumping then
			self:applyLinearImpulse( 0, -550 )
			self:setSequence( "jump" )
			self.jumping = true
		end
	end

	function visual:hurt()
		fx.flash( self )
		audio.play( sounds.hurt[math.random(2)] )
		if self.shield:damage() <= 0 then
			-- We died
			fx.fadeOut( function()
				composer.gotoScene( "scene.refresh", { params = { map = self.filename } } )
			end, 1500, 1000 )
			visual.isDead = true
			visual.isSensor = true
			self:applyLinearImpulse( 0, -500 )
			-- Death animation
			visual:setSequence( "ouch" )
			self.xScale = 1
			transition.to( self, { xScale = -1, time = 750, transition = easing.continuousLoop, iterations = -1 } )
			-- Remove all listeners
			self:finalize()
		end
	end

	function visual:collision( event )
		local phase = event.phase
		local other = event.other
		local y1, y2 = self.y + 50, other.y - ( other.type == "enemy" and 25 or other.height/2 )
		local vx, vy = self:getLinearVelocity()
		if phase == "began" then
			if not self.isDead and ( other.type == "blob" or other.type == "enemy" ) then
				if y1 < y2 then
					-- Hopped on top of an enemy
					other:die()
				elseif not other.isDead then
					-- They attacked us
					self:hurt()
				end
			elseif self.jumping and vy > 0 and not self.isDead then
				-- Landed after jumping
				self.jumping = false
				if not ( left == 0 and right == 0 ) and not visual.jumping then
					visual:setSequence( "walk" )
					visual:play()
				else
					self:setSequence( "idle" )
				end
			end
		end
	end

	function visual:preCollision( event )
		local other = event.other
		local y1, y2 = self.y + 50, other.y - other.height/2
		if event.contact and ( y1 > y2 ) then
			-- Don't bump into one way platforms
			if other.floating then
				event.contact.isEnabled = false
			else
				event.contact.friction = 0.1
			end
		end
	end

	local function enterFrame()
		-- Do this every frame
		local vx, vy = visual:getLinearVelocity()
		local dx = left + right
		if visual.jumping then dx = dx / 4 end
		if ( dx < 0 and vx > -max ) or ( dx > 0 and vx < max ) then
			visual:applyForce( dx or 0, 0, visual.x, visual.y )
		end
		-- Turn around
		visual.xScale = math.min( 1, math.max( visual.xScale + flip, -1 ) )
	end

	function visual:finalize()
		-- On remove, cleanup visual, or call directly for non-visual
		visual:removeEventListener( "preCollision" )
		visual:removeEventListener( "collision" )
		Runtime:removeEventListener( "enterFrame", enterFrame )
		Runtime:removeEventListener( "key", key )
	end

	-- Add a finalize listener (for display objects only, comment out for non-visual)
	visual:addEventListener( "finalize" )

	-- Add our enterFrame listener
	Runtime:addEventListener( "enterFrame", enterFrame )

	-- Add our key/joystick listeners
	Runtime:addEventListener( "key", key )

	-- Add our collision listeners
	visual:addEventListener( "preCollision" )
	visual:addEventListener( "collision" )

	-- Return visual
	--visual.name = "hero"
	--visual.type = "hero"
	return visual
end

return M
