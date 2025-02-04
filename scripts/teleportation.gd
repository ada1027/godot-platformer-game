extends RigidBody2D

var sprite: AnimatedSprite2D = null
var players_touching = []

var frozen = false

func _ready():
	self.sprite = self.get_node("AnimatedSprite2D")

func _physics_process(delta):
	if self.players_touching.size() >= 1:
		self.sprite.animation = "stepped"
	else:
		self.sprite.animation = "unstepped"
	
	if !frozen:
		for p in players_touching:
			var rp = self.get_parent().platforms.pick_random()
			p.position = Vector2(rp.position.x, rp.position.y - 6.5	)

func _on_area_2d_body_entered(body):
	if !players_touching.has(body) and body.is_in_group("players") and body.position.y < self.position.y:
		self.players_touching.append(body)

func _on_area_2d_body_exited(body):
	self.players_touching.erase(body)
