extends RigidBody2D

const running_speed = 125
const jumping_impulse = 600
const jumping_cooldown = 0.25

const freeze_cooldown = 20
const freeze_radius = 150
const freeze_duration = 5

const knockback_cooldown = 15
const knockback_radius = 150
const knockback_impulse_multiplier = 200

var freeze_time = -freeze_cooldown
var freeze_position = Vector2()

var knockback_time = -knockback_cooldown

var sprite: AnimatedSprite2D;

var platforms_touching = []
var jumping_time = 0
var health = 100

var sun = null

func _ready():
	self.sprite = self.get_node("AnimatedSprite2D")
	self.sprite.animation = "running"
	self.sprite.play()
	
	self.sun = get_parent().get_node("Sun")

func _physics_process(delta):
	if sun.energy < -0.4:
		$Lantern.visible = true
	else:
		$Lantern.visible = false
	
	if jumping_time < jumping_cooldown:
		jumping_time += delta
	else:
		jumping_time = jumping_cooldown
	if Input.is_key_pressed(KEY_RIGHT) or Input.is_key_pressed(KEY_D):
		self.linear_velocity.x = running_speed
	elif Input.is_key_pressed(KEY_LEFT) or Input.is_key_pressed(KEY_A):
		self.linear_velocity.x = -running_speed
	if self.platforms_touching.size() >= 1 and jumping_time == jumping_cooldown:
		if Input.is_key_pressed(KEY_UP) or Input.is_key_pressed(KEY_W):
			self.apply_impulse(Vector2(0, -jumping_impulse))
			jumping_time = 0
	
	if Input.is_key_pressed(KEY_Q):
		freeze_ability()
	if Input.is_key_pressed(KEY_E):
		knockback_ability()
	
	var time = Time.get_unix_time_from_system()
	var frozen = false
	if time - freeze_time <= freeze_duration:
		frozen = true
	else:
		frozen = false
	for cactus in get_parent().cacti:
		if is_instance_valid(cactus) and cactus.position.distance_to(freeze_position) <= freeze_radius:
			cactus.frozen = frozen
	for enemy in get_parent().enemies:
		if is_instance_valid(enemy) and enemy.position.distance_to(freeze_position) <= freeze_radius:
			enemy.frozen = frozen
	for projectile in get_parent().projectiles:
		if is_instance_valid(projectile) and projectile.position.distance_to(freeze_position) <= freeze_radius:
			projectile.frozen = frozen
	for platform in get_parent().platforms:
		if is_instance_valid(platform) and platform.position.distance_to(freeze_position) <= freeze_radius:
			platform.frozen = frozen

func _on_area_2d_body_entered(body):
	if !platforms_touching.has(body) and (body.is_in_group("platforms") or body.is_in_group("moving") or body.is_in_group("teleportation") or body.is_in_group("floors")) and body.position.y > self.position.y:
		self.platforms_touching.append(body)

func _on_area_2d_body_exited(body):
	self.platforms_touching.erase(body)

func freeze_ability():
	var time = Time.get_unix_time_from_system()
	if time - freeze_time >= freeze_cooldown:
		freeze_position = position
		freeze_time = time
		
func knockback_ability():
	var time = Time.get_unix_time_from_system()
	if time - knockback_time >= knockback_cooldown:
		for cactus in get_parent().cacti:
			if is_instance_valid(cactus) and cactus.position.distance_to(position) <= knockback_radius:
				cactus.freeze = false
				cactus.lock_rotation = false
				cactus.apply_impulse(position.direction_to(cactus.position) * knockback_impulse_multiplier)
		for enemy in get_parent().enemies:
			if is_instance_valid(enemy) and enemy.position.distance_to(position) <= knockback_radius:
				enemy.freeze = false
				enemy.lock_rotation = false
				enemy.apply_impulse(position.direction_to(enemy.position) * knockback_impulse_multiplier)
		for projectile in get_parent().projectiles:
			if is_instance_valid(projectile) and projectile.position.distance_to(position) <= knockback_radius:
				projectile.apply_impulse(position.direction_to(projectile.position) * knockback_impulse_multiplier)
		
		knockback_time = time
