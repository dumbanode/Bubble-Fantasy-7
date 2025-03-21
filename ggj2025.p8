pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--- world
-- cameron smith
-- jan 25, 2025 - sat
imp_amount=2.5
max_imp=10

function _init()
	state_mngr:transition_to_state(
		"title")
end

function _update()
	btn_update()
	trans_emit:update()
	state_mngr:update()
end

function _draw()
	state_mngr:draw()
	trans_emit:draw()
	debug_print()
end

world={
	dim={
		max_x=105,
		min_x=18,
		max_y=119,
		min_y=0
		},
	trans={
		max_x=-1,
		min_x=-1,
		to_adjust=.7
	},
	speed=.1,
	bk_clr=0,
	gravity=1,
	traveled=0,
	coins={},
	
	
	init=function(self)
		-- init background particles
		self.b_parts_emit=part_emit:new({
			pos={
				x=0,
				y=0
			},
			dim={
				w=140,
				h=140,
			},
			part_config={
				max_parts=10,
				init_amount=10
			},
			part_to_use=part:new({
				speed=0+rnd(5),
				update_move=function(self)
					self.pos.y+=self.speed*world.speed
				end,
			}),
			r={0,3},
			life={100,1000},
			clr=13,
			parts_per_frame=1,
			active=true,
			speed={0,.2},
			parts={}
		})
		coins={}
		self.b_parts_emit:init()
		init_shops()
		init_enemies()
		self:init_floor()
		self.col_mngr=collisionmanager:init()
		for i=0,6 do
			local new_coin = coin:new({})
  	new_coin:init() -- this will set a unique random position
  	self.col_mngr:add_obj(new_coin)
		end
	
	end,
		
	update=function(self)
		self:update_field()
		self:update_floor()
		update_enemies()
		self.b_parts_emit:update()
		self:update_distance()
		self.col_mngr:update()
		--self:update_coins()
		--update_shops()
	end,
	
	update_coins=function(self)
		-- check if the plr
		-- collected coins
		collected={}
		for c in all(self.coins) do
			if check_col(c, plr) then
				add(collected, c)
			end
		end
		
		-- process each collected
		for c in all(collected) do
			del(self.coins,c)
			sfx(5)
			plr.status.coins+=1
		end
		
	
		-- move the coins down
		for c in all(self.coins) do
			result=c:update()
			if not result then
				del(self.coins,c)
			end
	 end

	 if time()%10 == 0 then
	 	self:spawn_coins()
	 end
	end,
	
	spawn_coins=function(self)
		--rand generate amount of coins
		num_to_spawn = rnd(5)
		
		if count(self.coins)<max_num_coins then 
			for i=0,num_to_spawn do
				self:spawn_coin()
			end
		end
	end,
	
	spawn_coin=function(self)
		add(
			self.coins,
			coin:new({
				pos={
					x=18+rnd(90),
					y=-10-rnd(120),
				}
			})
		)
	end,
	
	travel_num=1,
	update_distance=function(self)
		self.traveled=flr(time())
	end,
	
	update_field=function(self)
		if self.trans.max_x<0
			or self.trans.min_x<0 then
			return
		end
		
		max_x=self.dim.max_x
		to_max=self.trans.max_x
		min_x=self.dim.min_x
		to_min=self.trans.min_x
		
		to_adjust=self.trans.to_adjust
		if max_x>to_max then
			self.dim.max_x-=to_adjust
		elseif max_x<to_max then
			self.dim.max_x+=to_adjust
		end
		
		if min_x>to_min then
			self.dim.min_x-=to_adjust
		elseif min_x<to_min then
			self.dim.min_x+=to_adjust
		end
		
		self.dim.min_x=ceil(self.dim.min_x*100)/100
		self.dim.max_x=flr(self.dim.max_x*100)/100
	end,
	
	draw=function(self)
		self.b_parts_emit:draw()
		draw_enemies()
		self:draw_env()
		--draw_hud_upgrades()
		--self:draw_coins()
		self.col_mngr:draw()
		draw_shops()
		self:draw_hud()
	end,
	
	draw_coins=function(self)
		for c in all(self.coins) do
			c:draw()
		end
	end,
	
	draw_env=function(self)
		fillp(░)
		rectfill(
			0,0,
			128,10,
			13
		)
		fillp()
		self:draw_floor()
		rectfill(
			0,0,
			self.dim.min_x,
			128,
			bk_clr)
		rectfill(
			self.dim.max_x+6,
			0,
			128,
			128,
			self.bk_clr)
	end,
	
	floor={},
	init_floor=function(self)
		for i=0,15 do
			add(
				self.floor,
				{
					x=0 + (i * 8),
					y=112,
					sprite=34
				}
			)
		end
		for i=0,15 do
			add(
				self.floor,
				{
					x=0 + (i * 8),
					y=120,
					sprite=35
				}
			)
		end
	end,
	
	draw_floor=function(self)
		for f in all(self.floor) do
			spr(
			f.sprite,
			f.x,
			f.y)
		end
	end,
	
	update_floor=function(self)
		for f in all(self.floor) do
			f.y+=.1
		end
	end,
	
	draw_hud=function(self)
		self:draw_distance()
		self:draw_coin_display()
		self:draw_tut_text()
		self:draw_distance()
	end,
	
	draw_distance=function(self)
		print(
			self.traveled,0,15,7
		)
	end,
	
	draw_coin_display=function(self)
		spr(20,0,25)
		print(
			plr.status.coins,
			10,27,7)
	end,
	
	draw_tut_text=function(self)
		print("⬆️⬇️",0,50,7)
		print("⬅️➡️")
		print("move")
		
		print("")
		print("❎🅾️")
		print("dash")
	end
}


-- funky zone
obj={
	pos={
		x=0,
		y=0
	},
	dim={
		w=8,
		h=8,
	},
	sprites={
		curr_spr=-1,
	},
	status={},
	
	new=function(self,tbl)
		tbl=tbl or {}
		setmetatable(tbl,{
			__index=self
		})
		return tbl
	end,
	
	init=function(self)
		-- to be overridden
	end,
	
	draw=function(self)
		if self.sprites.curr_spr != -1 then
			spr(
				self.sprites.curr_spr,
				self.pos.x, 
				self.pos.y
			)
		end
	end,
	
	update=function(self)
		-- to be overwritten
	end
}
-->8
--helper functions
function update_timer()
	elapsed=get_elapsed()
	print(
		flr(elapsed).." cm gold:"..
		num_coins, 
		39,5,7
	)
end

function update_hud()
	update_timer()
end

move_multiple=5
enemy_multiple=10
move_inc=.25
function update_distance()
	dist_traveled.t+=1
	elapsed=get_elapsed()
	if elapsed%move_multiple==0 then
		world.speed+=move_inc
	end
	if elapsed%enemy_multiple==0 then
		update_enemy_behave()
	end
end

function get_elapsed()
	return dist_traveled.t/30
end

function debug_print()
	if world.col_mngr then
		print(
			count(
						world.col_mngr.objects
			),
			7
		)
	end
end

-- take two tables with coords
-- calculate if they collide
function check_col(
	obj_1, obj_2
)
	return obj_1.pos.x < obj_2.pos.x + obj_2.dim.w and
	 obj_1.pos.x + obj_1.dim.w > obj_2.pos.x and
		obj_1.pos.y < obj_2.pos.y + obj_2.dim.h and
		obj_1.pos.y + obj_1.dim.h > obj_2.pos.y
end

function is_in_table(spr_table, to_find)
	for key, this_spr in pairs(spr_table) do
	 if this_spr == to_find then
	     return true
	 end
	end
	return false
end

--button mgmt
--https://gist.github.com/ricop/81702becf95eb331abf1aef24b87f0c7#file-btnd-lua
do
 local state = {0,0,0,0,0,0}
 -- call this in _update! 
 btn_update=function ()
  for b=0,5 do
   if state[b+1] == 0 and btn(b) then
    state[b+1] = 1
   elseif state[b+1] == 1 then
    state[b+1] = 2
   elseif state[b+1] == 2 and not btn(b) then
    state[b+1] = 3
   elseif state[b+1] == 3 then
    state[b+1] = 0
   end
  end
 end

 btnd=function (b)
  return state[b+1] == 1
 end

 btnu=function (b)
  return state[b+1] == 3
 end
end
-->8
-- player

-- default player position
default_plr=obj:new({
	pos={
			x=50,
			y=105,
			x_imp=0,
			y_imp=0,
			move_amount=.1,
		},
		status={
			is_big=false,
			level=6,
			coins=0,
			dashing=0
		},
		sprites={
			spr_table={
				[1]={0,1},
				[2]={2,3},
				[3]={4,5}
			}
		},
		dash_config={
			dash_reset=40,
			dash_cooldown_timeout=30,
			dash_slow_timeout=5,
			dash_amount=25
		},
		
		spr_timer=30,
		big_sprite=16,
		
		init=function(self)
			dash_timer=0
			plr=default_plr
			self:set_is_big(false)
		end,
		
		set_is_big=function(self)
			self.is_big=is_big
			if is_big then
				self.w=16
				self.h=16
			else
				self.w=8
				self.h=8
			end
		end,
		
		------------
		-- update --
		------------
		last_time=-1,
		update=function(self)
			local curr_time=time()
			local elapsed=
				curr_time-self.last_time
			
			damp_impulses()
			self:update_btn()
			self:move()
			update_distance()
			
			if elapsed > 1 then
				self:update_spr()
				self.last_time=curr_time
			end
			
		end,
		
		update_btn=function(self)
			play_sfx = false
			is_dashing=self.status.dashing
			if is_dashing>0 then
				dash_timer+=1
				
				--player finished dashing
				if dash_timer>
					self.dash_config.dash_reset then
					self.status.dashing=0
					dash_timer=0
					
				--dash has come to a stop
				--disable dashing until reset
				elseif dash_timer>
					self.dash_config.dash_cooldown_timeout
					and dash_timer<
					self.dash_config.dash_reset then
					self.status.dashing=3
					
				--dash slow initial impulse
				elseif dash_timer>
					self.dash_config.dash_slow_timeout then
					self.status.dashing=2
					
				end
			end
			
			-- update x impulses
			if btnd(⬅️) then
				if is_dashing==0 then
					self.pos.x_imp = mid(-max_imp, self.pos.x_imp - imp_amount, max_imp)
				end
				play_sfx=true
			end
			
			if btnd(➡️) then
				if is_dashing==0 then
					self.pos.x_imp = mid(-max_imp, self.pos.x_imp + imp_amount, max_imp)
				end
				play_sfx=true
			end
		
			-- update y impulses	
			if btnd(⬆️) then
				if is_dashing==0 then
					self.pos.y_imp = mid(-max_imp, self.pos.y_imp - imp_amount, max_imp)
				end
				play_sfx=true
			end
			
			if btnd(⬇️) then
				if is_dashing==0 then
					self.pos.y_imp = mid(-max_imp, self.pos.y_imp + imp_amount, max_imp)
				end
				play_sfx=true
			end
			
			if btnd(5) and 
				is_dashing==0 then
				self.status.dashing=1
				self.pos.x_imp=
					-1*self.dash_config.dash_amount
				sfx(2)
			elseif btnd(4)
				and is_dashing==0 then
				self.status.dashing=1
				plr.pos.x_imp=
					self.dash_config.dash_amount
				sfx(2)
			end
			
			if play_sfx then
				-- randomly determine if
				-- we are playing sfx
				num = flr(rnd(2)) + 1
				if num==2 and 
					is_dashing==0 then
					sfx(0)
				elseif num==2 then
					sfx(3)
				end
			end
		end,
		
		move=function(self)			
			-- ensure the player doesnt
			-- clip outside
			if self.pos.x>
				world.dim.max_x then
					self.pos.x=world.dim.max_x-3
			elseif self.pos.x<
				world.dim.min_x then
				self.pos.x=world.dim.min_x+1
				
			-- update x direction
			else
				self.pos.x=
					self:update_direction(
						self.pos.x_imp,
						self.pos.x
					)
			end
			
			-- ensure the player doesnt
			-- clip outside
			if self.pos.y>
				world.dim.max_y then
				self.pos.y=world.dim.max_y
			elseif self.pos.y<
				world.dim.min_y then
				self.pos.y=
					world.dim.min_y+1
				
			-- update y direction
			else
				self.pos.y=
					self:update_direction(
						self.pos.y_imp,
						self.pos.y
					)
			end
		end,
		
		update_direction=function(
			self,imp,pos)
			to_return=pos
			val_to_use=
				self.pos.move_amount*imp
			self.val=val_to_use
			if imp>0 then
				to_return+=val_to_use
				to_return= 
					flr(to_return*10)/10
			elseif imp<0 then
				to_return+=val_to_use
				to_return=
					ceil(to_return*10)/10
			end
			return to_return
		end,

		update_spr=function(self)
			-- determine the sprite
			spr_table=
				self.sprites.spr_table[1]
				
			if not is_in_table(
				spr_table,
				self.sprites.curr_spr
			) then
				self.sprites.curr_spr=
					spr_table[1]
			else
				-- find the index in the table
				-- use the value of the next index
				local next_spr = spr_table[1]
				for i = 1, #spr_table do
					if spr_table[i] == self.sprites.curr_spr then
						-- if at the last sprite, loop back to the first, else move to the next
						next_spr = spr_table[i % #spr_table + 1]
						break
					end
				end
		
				self.sprites.curr_spr=
					next_spr
			
			end
		end,
		
		----------
		-- draw --
		----------
		draw=function(self)
			self:draw_base_spr()
			self:draw_equipmnt()
		end,
		
		-- draw player sprite
		draw_equipmnt=function(self)
			for i=2,6 do
				xoff=0
				yoff=0
				if self.status.level >= i then
					
					-- grab the equipment spr
					equip=equip_lvl[i]
					is_big=plr.status.is_big
					
					-- if the player is big,
					-- add an offset for the 
					-- equipment
					if is_big then
					 xoff+=equip.bigxoff
					end
					if is_big then
						yoff+=equip.bigyoff
					end
					
					spr(
						equip.sprite,
						plr.pos.x +
							(equip.xoff+xoff),
						plr.pos.y
							+ (equip.yoff+yoff)
					)
				end
			end
		end,

		draw_base_spr=function(self)
			if self.is_big then
				spr(self.big_sprite, self.pos.x, self.pos.y, 2, 2)
			else
				spr(self.sprites.curr_spr, 
				self.pos.x, self.pos.y)
			end
		end		

})

-- reset the player
function init_plr()
	plr=default_plr
	plr:init()
end

-- move to a world class?
--max_x=105
--max_x=80
--min_x=18
--min_x=30

--max_y=119
--min_y=0

-- equipment level sprites
equip_lvl={
	[2]={
		sprite=50,
		xoff=2,
		yoff=2,
		bigxoff=8,
		bigyoff=6
	},
	[3]={
		sprite=51,
		xoff=-2,
		yoff=2,
		bigxoff=0,
		bigyoff=6
	},
	[4]={
		sprite=52,
		xoff=0,
		yoff=-4,
		bigxoff=4,
		bigyoff=0
	},
	[5]={
		sprite=53,
		xoff=-1,
		yoff=-6,
		bigxoff=4,
		bigyoff=0
	},
	[6]={
		sprite=54,
		xoff=-2,
		yoff=-8,
		bigxoff=4,
		bigyoff=0
	},
}





-->8
-- pickupable

-- create a base class
-- for all pickupables
-- on_collision()

collisionmanager=
{
	init=function(self)
		self.objects={}
		return self
	end,
	
	add_obj=function(self,to_add)
		add(self.objects,to_add)
	end,
	
	update=function(self)
		self:update_objects()
		self:check_col()
	end,
	
	update_objects=function(self)
		for obj in all(self.objects) do
			obj:update()
		end
	end,
	
	check_col=function(self)
		to_remove = {}
		-- check if each obj has
		-- collided with player
		for obj in all(self.objects) do
			if check_col(plr, obj) then
				-- exec callback
				result=obj:on_collide()
				-- check if remove
				if not result then
					add(to_remove, obj)
				end
			end
		end
		
		-- remove elements
		for obj in all(to_remove) do
			del(self.objects, obj)
		end
	end,
	
	draw=function(self)
		for obj in all(self.objects) do
			obj:draw()
		end
	end,
	
}

collidable=obj:new({
	on_collide=function(self)
	end
})

coin=collidable:new({
	on_collide=function(self)
		sfx(5)
		plr.status.coins+=1
		return false
	end,

	init=function(self)
		self.pos={
					x=18+rnd(90),
					y=-10-rnd(120),
		}
		return self
	end,
	
	update=function(self)
		self.pos.y+=world.speed
	 if self.pos.y>130 then
	 	return false
	 end
	 return true
	end,
	
	draw=function(self)
		spr(
			20,
			self.pos.x,
			self.pos.y
		)
	end
})

-------------------------

-- spawn powerups and coins
max_num_coins=20

coin_bak=obj:new({
	update=function(self)
		self.pos.y+=world.speed
	 if self.pos.y>130 then
	 	return false
	 end
	 return true
	end,
	
	draw=function(self)
		spr(
			20,
			self.pos.x,
			self.pos.y
		)
		end
})


-- shops --
shops={}
max_shops=1
function init_shops()
	shops={}
end

function draw_shops()
	for s in all(shops) do
		spr(
			68,
			s.x,
			s.y,
			2,2
		)
	end
end

-- coins and powerups
function spawn_shops()
	chance=flr(rnd(600))
	
	if count(shops)<max_shops 
		and chance==1 then
		spawn_shop()
	end
end

function spawn_shop()
	add(
		shops,
		{
			x=18+rnd(80),
			y=-20,
			w=16,
			h=16
		}
	)
end

function update_shops()
	for s in all(shops) do
		s.y+=world_speed
		if s.y>130 then
			del(shops, s)
		end
	end
	check_shop_collision()
	spawn_shops()
end

function check_shop_collision()
	local collected={}
	-- determine any collisions
	for s in all(shops) do
		if check_col(plr, s) then
	   add(collected, s)
	  end
	end
	
	-- process each collected
	for s in all(collected) do
		if num_coins>=10 
			and plr.level<3 then
			num_coins-=10
			plr.level+=1
			del(shops,s)
			sfx(6)
		end
	end
	
end


---------------------------

function draw_hud_upgrades()
	-- draw the staff
	spr_to_use=64
	if plr.status.level>1 then
		spr_to_use=66
	end
	spr(
		spr_to_use, 
		110, 50, 2, 2)
		
	-- draw the shield
	spr_to_use=96
	if plr.status.level>2 then
		spr_to_use=98
	end
	spr(
		spr_to_use, 
		110, 70, 2, 2)
end
-->8
--game state

state={
	name="",
	
	new=function(self,tbl)
		tbl=tbl or {}
		setmetatable(tbl,{
			__index=self
		})
		return tbl
	end,
	
	init=function(self)
	end,
	
	update=function(self)
	end,
	
	draw=function(self)
	end
}

state_mngr={
	curr_state=-1,
	states={},
	
	add=function(self,state)
		self.states[state.name]=state
	end,
	
	transition_to_state=function(
		self, name_of_state)
		-- set the current state
		print(count(self.states))
		self.curr_state=
			self.states[name_of_state]
		-- initialize the state
		self.curr_state:init()
	end,
	
	update=function(self)
		self.curr_state:update()
	end,

	draw=function(self)
		self.curr_state:draw()
	end	
}


-------------------------------
-- state declarations --


title=state:new({
	name="title",
	timer=0,
	
	update=function(self)
		if btnu(4) or btnu(5) then
			sfx(2)
			trans_emit:set_active(true)
			self.timer=30
		end
		
		if self.timer>0 then
			self.timer-=1
			if self.timer<=0 then
				state_mngr:transition_to_state(
					"game"
				)
			end
		end
	end,
	
	draw=function(self)
		cls()
		print(
			"bubble fantasy 7",
			32,80,7
		)
		print("    press ❎")
		
		print(
			"created by: cameron smith",
			15,110
		)
		print("  global game jam 2025")
		map()
	end
})

state_mngr:add(title)

game=state:new({
	name="game",
	
	init=function(self)
		dist_traveled={
			m=0,
			t=0
		}
		world:init()
		init_plr()
		num_coins=0
		--setup_particles()
		world:
		init_floor()
	end,
	
	update=function(self)
		world:update()
		update_hud()
		plr:update()
		update_timer()
	end,
	
	draw=function(self)
		cls(1)
		world:draw()
		
		-- update the player sprite
		if plr.spr_timer>10 then
			plr.spr_timer=0
		else
			plr.spr_timer+=1
		end
		
		plr:draw()
		--debug_print()
	end
	
})

state_mngr:add(game)

game_over=state:new({
	name="game_over",
	
	init=function(self)
		world:init()
		self.score=get_elapsed()
		sfx(1)
	end,
	
	update=function(self)
		if btnu(4) or btnu(5) then
			state_mngr:transition_to_state(
				"title")
		end
	end,
	
	draw=function(self)
		cls(4)
		print(
			"you died sorry",
			30,
			54
		)
		print("score: "..flr(score)..
		"cm")
		print("gold: "..num_coins)
		print("press ❎ to restart")
	end
})

state_mngr:add(game_over)
-->8
--particles

-- single particle
part=obj:new({
	dim={
		w=0,
		h=0,
		r=0
	},
	speed=rnd(1),
	curr_life=0,
	lifetime=100,
	clr=1,
	gravity=1,
	
	update=function(self)
		-- update current life
		self.curr_life+=1
		
		-- move up
		self:update_move()
		
	end,
	
	update_move=function(self)
		self.pos.y+=
			(self.speed*self.gravity)
	end,
	
	max_bound=138,
	min_bound=-10,
	check_remove=function(self)
		-- check y pos
		if self.pos.y>self.max_bound
			or self.pos.y<self.min_bound do
			return true
			
		-- check x pos
		elseif self.pos.x>self.max_bound
			or self.pos.x<self.min_bound do
			return true
		
		
		-- check lifetime
		elseif self.curr_life>self.lifetime do
			return true
		end
		
		-- shouldnt remove
		return false
	end,
	
	draw=function(self)
		circ(
			self.pos.x,
			self.pos.y,
			self.dim.r, 
			self.clr)
	end
})

-- particle emitter
part_emit=obj:new({
	pos={
		x=0,
		y=0
	},
	dim={
		w=10,
		h=10,
	},
	speed={2,6},
	active=false,
	one_shot=false,
	parts={},
	r={1,4},
	clr=12,
	life={10,30},
	part_to_use=part,
	part_config={
		max_parts=500,
		init_amount=15
	},
	
	curr_time=0,
	one_shot_timeout=15,
	taper=false,
	gravity=1,
	
	init=function(self)
		amount=self.part_config.init_amount
		for i=0,amount do
			self:spawn_particle()
		end
	end,
	
	set_active=function(self, val)
		if val then
			self.curr_time=0
			self.active=true
		else
			self.active=false
		end
		
	end,
	
	update=function(self)
		self.curr_time+=1
		
		-- spawn particles
		if self.active 
			and self.one_shot then
			if self.curr_time
					<self.one_shot_timeout then
				self:spawn_particles()
			end
		elseif self.active then
			self:spawn_particles()
		end
		
		-- update each particle
		to_remove={}
		for part in all(self.parts) do
			part:update()
			if part:check_remove() then
				add(to_remove, part)
			end
		end
		
		-- remove particles
		for part in all(to_remove) do
			del(self.parts, part)
		end
	end,
	
	draw=function(self)
		for part in all(self.parts) do
			part:draw()
		end
	end,
	
	parts_per_frame=100,
	spawn_particles=function(self)
		
		max_amount=self.part_config.max_parts
		if count(self.parts)<max_amount do
			for i=1,self.parts_per_frame do
				self:spawn_particle()
			end
		end
	end,
	
	spawn_particle=function(self)
		-- calculate position
		x_to_use=self.pos.x
			+rnd(self.dim.w)
	
		y_to_use=self.pos.y
			+rnd(self.dim.h)
		
		-- calculate lifetime
		life_to_use=self.life[1]
			+rnd(self.life[2])
		
		-- calculate radius
		r_to_use=self.r[1]
			+rnd(self.r[2])
			
		perc=self.curr_time
			/self.one_shot_timeout
		
		if self.taper	then
			r_to_use=r_to_use*perc
			r_to_use=max(4.5,r_to_use)
		end
		
		--calculate speed
		speed_to_use=self.speed[1]
			+rnd(self.speed[2])

		add(
				self.parts,
				self.part_to_use:new({
					pos={
						x=x_to_use,
						y=y_to_use
					},
					dim={
						r=r_to_use
					},
					speed=speed_to_use,
					curr_life=0,
					lifetime=life_to_use,
					clr=self.clr
				})
			)
	end
})

---------------------
-- custom particles

-- bubble particle
bubble_part=part:new({
	dim={
		w=0,
		h=0,
		r=0
	},
	speed=rnd(1),
	curr_life=0,
	lifetime=100,
	clr=1,
	gravity=-1,
	
	update=function(self)
		-- update current life
		self.curr_life+=1
		
		-- move up
		self:update_move()
		
		-- check if should remove
		result=self:check_remove()
		if result then
			
		end
	end,
	
	max_bound=138,
	min_bound=-10,
	check_remove=function(self)
		-- check y pos
		if self.pos.y>self.max_bound
			or self.pos.y<self.min_bound do
			return true
			
		-- check x pos
		elseif self.pos.x>self.max_bound
			or self.pos.x<self.min_bound do
			return true
		
		
		-- check lifetime
		elseif self.curr_life>self.lifetime do
			return true
		end
		
		-- shouldnt remove
		return false
	end,
	
	draw=function(self)
		circfill(
   self.pos.x,
   self.pos.y,
   self.dim.r + 2,
   1
  )
		circfill(
			self.pos.x,
			self.pos.y,
			self.dim.r, 
			12)
		circfill(
			self.pos.x+self.dim.r/3,
			self.pos.y-self.dim.r/2,
			2, 7
		)
	end
})

-- custom emitters

-- transition emitter
trans_emit=part_emit:new({
	pos={
		x=0,
		y=128
	},
	dim={
		w=128,
		h=100,
	},
	r={5,10},
	life={10,60},
	clr=7,
	one_shot=true,
	parts_per_frame=125,
	one_shot_timeout=25,
	part_to_use=bubble_part,
	taper=true,
	gravity=-1
})
-->8
-- enemies
-- enemy declarations
enemy=obj:new({
	should_spawn=function(self)
		chance=flr(rnd(10))
		
		if chance==1 then
			return true
		end
		return false
	end
})

fish=enemy:new({
	dim={
		w=4,
		h=4,
	},
	sprites={
		curr_spr=48,
	},
	
	init=function(self)
		self.pos={
			x=18+rnd(90),
			y=-10,
		}
		self.dir=flr(rnd(2))
		self.speed=.1+rnd(2)
	end,
	
	update=function(self)
		self.pos.y+=world.speed
		
		-- change direction
		if self.pos.x<
			world.dim.min_x+4 then
			self.dir=0
		elseif self.pos.x>
			world.dim.max_x-4 then
			self.dir=1
		end
		
		-- move fish in direction
		if self.dir==0 then
			self.pos.x+=fish_move_speed
		else
			self.pos.x-=fish_move_speed
		end
	end
})

jelly=enemy:new({
	dim={
		w=4,
		h=4,
	},
	sprites={
		curr_spr=49,
	},
	
	init=function(self)
		self.pos={
			x=18+rnd(90),
			y=-10,
		}
	end,
	
	update=function(self)
		self.pos.y+=world.speed
	end,
	
	should_spawn=function(self)
		chance=flr(rnd(3))
		
		if chance==1 then
			return true
		end
		return false
	end
})

curr_enemies={}

function init_enemies()
	curr_num_fish=1
	max_fish=10
	fish_move_speed=.1
	curr_enemies={}
end

function draw_enemies()
	for e in all(curr_enemies) do
		e:draw()
	end
end

-- update the enemy behavior
function update_enemy_behave()
	if curr_num_fish<max_fish then
		curr_num_fish+=1
		fish_move_speed+=.2
	end
end

function update_enemies()
	to_remove={}
	for e in all(curr_enemies) do
		-- update each enemy
		e:update()
		
		-- remove the enemy
		-- if offscreen
		if e.pos.y>130 then
			add(to_remove, e)
		end
	end
	
	-- remove offscreen enemies
	for e in all(to_remove) do
		del(to_remove, e)
	end
	
	-- spawn more enemies
	spawn_enemies()
	if check_enemy_col() then
		state_mngr:transition_to_state(
			"game_over"
		)
		end
end

function check_enemy_col()
	for this_e in all(curr_enemies) do
	  if check_col(plr, this_e) then
	  	return true
	  end
	end
	return false
end

last_time=0
en_spawn_timeout=1
enemy_types={
	fish,jelly
	}
function spawn_enemies()
	-- spawn an ememy every
	-- second
	this_time=time()
	elapsed=this_time-last_time
	if elapsed > en_spawn_timeout do
		last_time=this_time
		
		for t in all(enemy_types) do
			if t:should_spawn() then
				e=t:new()
				e:init()
				add(
					curr_enemies,
					e
				)
			end
		end
		--spawn_jelly_fish()
	end
	
end

function spawn_fish()
	chance=flr(rnd(3))
	
	if chance==1 then
		f = fish:new()
		f:init()
		add(
				curr_enemies,
				f
			)
	end
end

function spawn_jelly_fish()
	j = jelly:new()
	j:init()
	add(
			curr_enemies,
			j
		)
end

-->8
--impulse management
impulse_manager={
	damp_imp=function(self,
		impulse,to_damp)
		if (impulse>0) then
			impulse-=to_damp
			impulse = flr(impulse*10)/10
		elseif (impulse<0) then
			impulse+=to_damp
			impulse = ceil(impulse*10)/10
		end
		return impulse
	end
}

function damp_impulses()
	plr.pos.x_imp = 
		damp_imp(plr.pos.x_imp)
		
	plr.pos.y_imp = 
		damp_imp(plr.pos.y_imp)
end

damp=.1
dash_fast_damp=.1
dash_slow_damp=1
function damp_imp(impulse)
	to_damp=damp
	--initial burst of speed
	if plr.status.dashing==1 then
		to_damp=.001
	--starting to slow down
	elseif plr.status.dashing==2 then
		to_damp=dash_slow_damp
	-- normal speed, disable dash
	elseif plr.status.dashing==3 then
		to_damp=damp
	end
	
	if plr.status.dashing!=3 then
		impulse=
			impulse_manager:damp_imp(
			impulse, to_damp)
	end
	return impulse
end
__gfx__
00777700000000000077770000000000007777000000000000000000000000000000000070000007700000070000000000000000000000000000000000000000
07000070007777000700022200777222070002220077722200000000000000000700007007000070000000000000000000000000000000000000000000000000
70070007070000707007020207000272700702020700027200000000007007000070070000000000000000000000000000000000000000000000000000000000
70700007070700707070000207070072722200020222007200077000000770000000000000000000000000000000000000007777777000000000000000000000
7000000707000070700000220700002222a2202222a2202200077000000770000000000000000000000000000000000007770000000777000000000000000000
700000070700007070000027070000202aaa20272aaa202000000000007007000070070000000000000000000000000070000000000000702222220000000000
0700007000777700070000200077772022a2202022a2272000000000000000000700007007000070000000000000007700007770000000022222220000000000
00777700000000000077772000000020022277200222002000000000000000000000000070000007700000070000070000777000000000022222222000000000
000007777770000000000000000000000077aa900000000000000000000000000000000000000000000000000000700007700000000000222211112000000000
00077000000770000000000000000000007aaa900000000000000000000000000000000000000000000000000000700077000000000000222210012200000000
0070000000000700000000000000000007aa9aa90000000000000000000000000000000000000000000000000007000770000000000000222117012200000000
0700777000000070000000000000000007aa9aa90000000000000000055000000000000000000000000000000007000700000000000000122007022200000000
070770000000007000000000000000000aaa9aa90000000000000000500500500000000000000000000000000070000000000000000000122000722200000000
700700000000000700000000000000000aaa9aa90000000000000000500505050000000000000000000000000070007000000000000000122000722000000000
7000000000000007000000000000000000aaaa900000000000055550055000500000000000000000000000000070007000000000000000122200700000000000
7000000000000007000000000000000000aaaa900000000005500005500000000000000000000000000000000070000000000000000000122220700000000000
70700000000000070000000022222222000000000000000005000000500000000000000000000000000000000070000000000000000000012220700000000000
70000000000000070000000022222222000000000000000050000000550000000000000000000000000000000070222211000000000000001220700000000000
70000000000000070000000022222222000000000000000050000005050000000000000000000000000000000072222221100000000000001220700000000000
07000000000000700000000022222222000000000000000050000050550000000000000000000000000000000022222222110000000000001220700000000000
0700000000000070000000002222222200000000000000005000050505000000000000000000000000000000022222a222211000000000001227000000000000
007000000000070000000000222222220000000000000000050050505000000000000000000000000000000022222aaa22221100000000001227000000000000
000770000007700000222202222222220000000000000000055505055000000000000000000000000000000022222aaa22221100000006061220000000000000
0000077777700000222222222222222200000000000000000005555000000000000000000000000000000000222aaaaaaa221100000060606120000000000000
07007007000ee000000000000000000000000000000000000000000000000000000000000000000000000000222aaaaa99221100000606066120000000000000
0075757000ee8e0000000222000000000000000000000000000000000000000000000000000000000000000022222aa922221160606060677120000000000000
055555500eeee8e000000202000000008eeee0003bbbb000dcccc0000000000000000000000000000000000002222aa922211606060606700120000000000000
771551500eeeeee000000002022200000888ee000333bb000dddcc00000000000000000000000000000000000022229222116060606777000120000000000000
055555770e8888e00000002222a22000008eeee0003bbbb000dcccc0000000000000000000000000000000000002222221107777777000000000000000000000
77511550020e0200000000202aaa2000888888ee333333bbddddddcc000000000000000000000000000000000000222211000000000000000000000000000000
005757000020e0200000002022a22000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00070700020e02000000002002220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000dd00dd00000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000089988998899800dd00dd00000000000000000000000000000000000000000000000000000000000000000000000000
00006060600000000000222220000000088998899889988000dd00dd000000000000000000000000000000000000000000000000000000000000000000000000
00060000060000000002222222000000088998899889988000dd00dd000000000000000000000000000000000000000000000000000000000000000000000000
00000066006000000002221122200000088998899889988000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060600600000000002210022200000004000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000
00066600606000000002210022200000004000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000022200000004000000000040000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000060600000000000002220000000f4444444444f0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000002210000000f1111111111f0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000060000000000000002120000000f1711711a91f0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000600000000000001210000000f1717171a91f0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000060000000000000002120000000f1717171a91f0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000600000000000001210000000f1711711a91f0000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000006000000000000000100000000f1111111111f0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000004444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000606060000000000022222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000600000000222222221000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000000000000002222aa2222100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0060000000000600002222aaaa222210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000022aaaaaa9a2210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0060000000000600002aaaaaa9a99210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000002aaaaa9a9a9210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00600000000006000022aaa9a9992210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000006000022229a99222210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000000000000002222992222100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000600000000222222221000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000060606000000000122222210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000011111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111155511111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111511151111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111511151111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111511151111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111177117171111117717771111117711771711177511111777111111111111111111111111100000000000000000
00000000000000000011111111111111111111117117171111171117771111171117171711171711711717111111111111111111111111100000000000000000
00000000000000000011111111111111111111117117771111171117171111171117171711171711111717111111111111111111111111100000000000000000
00000000000000000011111111111111111111117111171111171117171111171717171711171711711717111111111111111111111111100000000000000000
00000000000000000011111111111111111111177711171111117717171111177717711777177711111777111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111115551111111111111100000000000000000
00000000000000000011111111111111115551111111111111111111111111111111111111111111111111111111151115111111111111100000000000000000
00000000000000000011111111111111151115111111111111111111111111111111111111111111111111111111511111511111111111100000000000000000
00000000000000000011111111111111151115111111111111111111111111111111111111111111111111111111511111511111111111100000000000000000
00000000000000000011111111111111151115111111111111111111111111111111111111111111111111111111511111511111111111100000000000000000
00000000000000000011111111111111115551111111111111111111111111111111111111111111111111111111151115111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111115551111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111115551111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111151115111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111151115111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111151115111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111115551111111111111111111111111111111111111111111111111111111117117117111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111757571111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111115555551111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111177155151111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111115555577111111100000000000000000
00000000000000000055511111111111111111111111111111111111111111111111111111111111111111111111111177511551111111100000000000000000
00000000000000000511151111111111111111111111111111111111111111111111111111111111111111111111111111575711111111100000000000000000
00000000000000005011115111111111111111111111111111111111115111111111111111111111111111111111111111171711111111100000000000000000
00000000000000005011115111111111111111111111111111111111151511111111111111111111111111111111111111111111111111100000000000000000
00000000000000005011115111111111111111111111111111111111115111111111111111111111111111111111111111111111111111100000000000000000
07777700077777000511151111111111111111111111111111111111111111111111111111111111111111111115111111111111111111100000000000000000
77707770770007700055511111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
77000770770007700011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100022222000000000
77000770777077700011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100222222200000000
07777700077777000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100222112220000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100221002220000000
07777700077777000011111111155511111111111111111111111111111111111111111111111111111111111111111111111111111111100221002220000000
77700770770077700011111111511151111111111111111111111111111111111111111111111111111111111111111111111111111111100000002220000000
77000770770007700011111111511151111111111111111111111111111111111111111111111111111111111111111111111111111111100000002220000000
77700770770077700011111111511151111111111111111111111111111111111111111111111111111111111111111111111111111111100000002210000000
07777700077777000011111111155511111111111111111111111111111111111111111111111111111111111111111111111111111111100000002120000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000001210000000
77700770707077700011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000002120000000
77707070707070000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000001210000000
70707070707077000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000100000000
70707070777070000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
70707700070077700011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000051111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100002222220000000
00000000000000000515111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100022222222100000
077777000777770000511111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111002222aa222210000
77070770770007700011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111102222aaaa22221000
777077707707077000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111022aaaaaa9a221000
77070770770007700011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111102aaaaaa9a9921000
07777700077777000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111102aaaaa9a9a921000
000000000000000000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111022aaa9a999221000
770077700770707000111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111022229a9922221000
70707070700070700011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100222299222210000
70707770777077700011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100022222222100000
70707070007070700011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100012222221000000
77707070770070700011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100001111110000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
000000000000000000111111111111111111111111111111dcccc111111111111111111111111111111111111111111111111111111111100000000000000000
0000000000000000001111111111111111111111111111111dddcc11111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111113dcccc1111111111111111111111111111111111111111111111111111111100000000000000000
000000000000000000111111111111111111111111111111ddddddcc111111111111111111111111111111111111111111111111111111100000000000000000
0000000000000000001111111111111111111111111111111183bbbb111111111111111111111111111111111111111111111111111111100000000000000000
0000000000000000001111111111111111111111111111111333333bb11111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111118eeee11111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111888888ee1111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111171111711111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111171711722211111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111171111721211111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111112221111711211111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111122a22777112211111111111111111111111111111111111111111111111111100000000000000000
0000000000000000001111111111111111111111111111112aaa2111112111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111122a22111112111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111112221111112111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111100000000000000000
000000000000000000111111111111111111111111111111111111111111111177aa911111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111111111111111111111111111111117aaa911111111111111111111111111111111111111111100000000000000000
0000000000000000001111111111111111111111111111111111111111111117aa9aa91111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111177aa911511111111111111111117aa9aa91111111111111111111111111111111111111111100000000000000000
0000000000000000001111111111111111117aaa91111111111111111111111aaa9aa91111111111111111111111111111111111111111100000000000000000
000000000000000000111111111111111117aa9aa9111111111111111111111aaa9aa91111111111111111111111111111111111111111100000000000000000
000000000000000000111111111111111117aa9aa91111111111111111111111aaaa911111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111aaa9aa91111111111111111111111aaaa911111111111111111111111111111111111111111100000000000000000
00000000000000000011111111111111111aaa9aa977aa9111111111111111111111111111111111111111111111111111111111111111100000000000000000
000000000000000000111111111111111111aaaa917aaa9111111111111111111111111111111111111111111111111111177aa9111111100000000000000000

__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000b0c0d0e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000001b1c1d1e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000002b2c2d2e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000003b3c3d3e00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100001a05019050170500e0500e050100500c050010500105003050040500d050120500f0501305016050170501f0501c0501205006050030500005005050060500505012800138001380013800138000f100
000400000f15010150121501515017150191501a1501c1501c1501d1501d1501d1501d1501c1501c1501a150181501615014150121500f1500e1500c1500a1500915009150081500815008150041500015001150
00010000000001e65022650266502865028650276502565023650206501a650156501265012650136501465022750166501765018650186501a6501b6501d6501e6501d6501b6501865018650196501b6501c650
00020000097700c7700f7701077011770137701477016770177701877017770167701577014770137701277011770107700f7700d7700b7700977008770077700777006770067700677007770077700007000070
000700000000023350283502a3502c3502e3502e3502e3502e3502d3502a350233501c3501a3501b3501c350203502135026350293502d3502b35027350203501d3501f350233502835029350273502635000000
000100001055010550105500f5500f5500f5200f55028500295002a5002b7503175024750247502475024750247502e7502d7501f4001d4001d400123003a000360003600036000350003500035000310001b100
00030000053500535006350083500a3500d35010350143501b3500e350103501235015350183501c350223502c350343500f350113501535017350193501c3501f35023350293502d35031350313503335038350
00020000206502565024650246502565026650266502665026650256502565024650236502265021650206501f6501e6501c6501b65019650186501765017650166501565014650136501265011650106500f650
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0020000018f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
