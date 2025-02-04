extends RigidBody2D

var players_touching = []
var last_fired = 0

var frozen = false

func _on_area_2d_body_entered(body):
	if !self.players_touching.has(body) and body.is_in_group("players"):
		self.players_touching.append(body)

func _on_area_2d_body_exited(body):
	self.players_touching.erase(body)
