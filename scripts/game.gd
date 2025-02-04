extends Node2D

@export var floor_scene: PackedScene = null
@export var player_scene: PackedScene = null
@export var platform_scene: PackedScene = null
@export var moving_scene: PackedScene = null
@export var teleportation_scene: PackedScene = null
@export var cactus_scene: PackedScene = null
@export var enemy_scene: PackedScene = null
@export var projectile_scene: PackedScene = null

const platform_increment = 5
const platform_y_increment = 25
const level_width = 250
const floor_space = 10
const door_space = 20
const player_death_y = 100

var floor = null
var player = null
var door = null
var platforms = []
var cacti = []
var players_in_door = []
var enemies = []
var projectiles = []

var enemy_shoot_range = 150
var enemy_shoot_interval = 1

var num_platforms = 0

var day_night_cycle_duration = 120

func _ready():
	self.create_floor()
	self.create_player()
	self.create_door()
	self.reset_game()

func reset_game():
	self.reset_player()
	for platform in self.platforms:
		if is_instance_valid(platform):
			platform.queue_free()
	self.platforms = []
	for cact in self.cacti:
		if is_instance_valid(cact):
			cact.queue_free()
	self.cacti = []
	self.enemies = []
	for projectile in self.projectiles:
		if is_instance_valid(projectile):
			projectile.queue_free()
	self.projectiles = []
	self.next_level()
	
func create_floor():
	self.floor = self.floor_scene.instantiate()
	self.add_child(floor)

func create_player():
	self.player = self.player_scene.instantiate()
	self.add_child(player)

func create_door():
	self.door = get_node("Door")

func reset_player():
	self.player.health = 100
	self.player.freeze_time -= self.player.freeze_cooldown
	self.player.position = Vector2(-self.floor_space - self.level_width / 2, -self.floor_space)
	self.player.linear_velocity = Vector2(0, 0)
	self.player.angular_velocity = 0

func next_level():
	self.num_platforms += self.platform_increment
	self.generate_platforms()
	
func generate_platforms():
	var prev_y = 0
	var prev_x = 0
	var same_direction_remaining = randi_range(3,5)
	var direction = 1
	
	for i in self.num_platforms:
		# Godot y axis is flipped
		prev_y -= platform_y_increment
		var new_platform
		var new_cactus
		var created=false
		var platform_type = randi_range(1,10)
		var generate_moving_platform = platform_type <= 2 # 20% chance
		for j in 1 if generate_moving_platform else 2:
			# Choose between the three types randomly
			if generate_moving_platform:
				new_platform = self.moving_scene.instantiate()
			elif platform_type == 3: # 10% chance
				new_platform = self.teleportation_scene.instantiate()
			else: #70% chance
				new_platform = self.platform_scene.instantiate()
				var random_float = randf_range(1,10)
				if random_float >= 2 and random_float < 4: # 20% chance
					created=true
					new_cactus = self.enemy_scene.instantiate()
					self.enemies.append(new_cactus)
				elif random_float >= 4 and random_float < 6: # 20% chance
					created=true
					new_cactus=self.cactus_scene.instantiate()
			
			prev_x += randf_range(30,80) * direction;
			same_direction_remaining -= 1
			if same_direction_remaining == 0:
				direction = -direction
				same_direction_remaining = randi_range(3,5)

			new_platform.position = Vector2(prev_x, prev_y)
			if created:
				var offset = randf_range(-7.5,7.5)
				new_cactus.position = Vector2(prev_x+offset, prev_y-7.5)
			created=false
			if new_platform:
				self.platforms.append(new_platform)
				self.add_child(new_platform)
			if new_cactus:
				self.cacti.append(new_cactus)
				self.add_child(new_cactus)
		if i == self.num_platforms - 1:
			self.door.position.x = new_platform.position.x
			self.door.position.y = prev_y - self.door_space

func _physics_process(delta):
	var x = float(Time.get_ticks_msec())/1000.0
	var brightness = 0.4 * cos((2.0*PI*x)/self.day_night_cycle_duration) - 0.4
	$Sun.energy = brightness
	if player != null and player.position.y >= player_death_y:
		self.reset_player()
	if players_in_door.size() >= 1:
		self.reset_game()
	if player.health<=0:
		self.reset_player()
	if player != null:
		for enemy in self.enemies:
			if !enemy.frozen:
				if enemy.position.distance_to(player.position) <= enemy_shoot_range:
					var now = Time.get_unix_time_from_system()
					if now - enemy.last_fired < enemy_shoot_interval:
						continue
						
					var projectile = self.projectile_scene.instantiate()
					projectile.position = enemy.position
					var direction = projectile.position.direction_to(self.player.position)
					projectile.bullet_direction = direction
					projectile.rotation = direction.angle()
					projectile.start_time = Time.get_ticks_msec()
					self.add_child(projectile)
					self.projectiles.append(projectile)
					
					enemy.last_fired = now
	

func _on_door_body_entered(body):
	if body.is_in_group("players"):
		self.players_in_door.append(body)

func _on_door_body_exited(body):
	self.players_in_door.erase(body)

