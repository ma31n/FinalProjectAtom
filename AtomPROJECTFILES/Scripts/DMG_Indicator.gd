extends RigidBody2D

var opacity = 1;

func _ready():
	randomize();
	var randdir = rand_range(-100,100);
	apply_central_impulse(Vector2(randdir,-100));



func _physics_process(_delta):
	if(opacity>0):
		self.modulate=Color(1,1,1,opacity);
		opacity-=0.005;
	else:
		queue_free();

func showDmgPoint(dmg):
	$Control/RichTextLabel.bbcode_text=str(dmg);
