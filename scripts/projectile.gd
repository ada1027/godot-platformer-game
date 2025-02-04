extends RigidBody2D

var players_touching = []
var bullet_direction = null
var start_time = 0

var frozen = false

func _ready():
	start_time = Time.get_unix_time_from_system()
	linear_velocity = 100 * bullet_direction

func _on_area_2d_body_entered(body):
	if body.is_in_group("players"):
		queue_free()
	if !self.players_touching.has(body) and body.is_in_group("players"):
		body.health -= 5
		self.players_touching.append(body)

func _on_area_2d_body_exited(body):
	self.players_touching.erase(body)

func _physics_process(delta):
	if !frozen:
		if Time.get_unix_time_from_system() - start_time > 3:
			queue_free()
