extends RigidBody2D

var sprite: AnimatedSprite2D = null
var players_touching = []

var initial_position = Vector2.ZERO
var platform_speed = 50
var platform_distance = 100
var direction = 1
var directionarray = [1,-1]

var frozen = false

func _ready():
	self.sprite = self.get_node("AnimatedSprite2D")
	self.initial_position = self.position
	direction = directionarray.pick_random()

func _physics_process(delta):
	if self.players_touching.size() >= 1:
		self.sprite.animation = "stepped"
	else:
		self.sprite.animation = "unstepped"
	
	if !frozen:
		var delta_pos = Vector2.ZERO
		delta_pos.x = platform_speed*direction*delta
		self.position += delta_pos
		# Move players as well so they don't slide off
		for player in players_touching:
			player.position += delta_pos
		# Change direction of moving platform after reaching the end
		if self.position.distance_to(self.initial_position) >= platform_distance:
			direction = -direction

func _on_area_2d_body_entered(body):
	if !players_touching.has(body) and body.is_in_group("players") and body.position.y < self.position.y:
		self.players_touching.append(body)

func _on_area_2d_body_exited(body):
	self.players_touching.erase(body)
