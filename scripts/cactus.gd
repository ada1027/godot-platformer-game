extends RigidBody2D

var players_touching = []
var damage_tick_cooldown = 1

var frozen = false

func _on_area_2d_body_entered(body):
	if !self.players_touching.has(body) and body.is_in_group("players"):
		self.players_touching.append(body)

func _on_area_2d_body_exited(body):
	self.players_touching.erase(body)
	
func _physics_process(delta):
	if !frozen:
		if self.damage_tick_cooldown < 0:
			self.damage_tick_cooldown = 0
		else:
			self.damage_tick_cooldown -= delta
		for body in self.players_touching:
			if self.damage_tick_cooldown < 0:
				body.health -= 10
				self.damage_tick_cooldown = 1
