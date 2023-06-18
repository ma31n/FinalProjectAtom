extends Camera2D

var shake = 5;

func _ready():
	pass

func _process(_delta):
	if($"/root/Global".shakescreen==true and $ShakeTimer.time_left==0):
		$ShakeTimer.start(0.1);
	
	if(!$ShakeTimer.is_stopped()):
		self.offset=Vector2(rand_range(-shake,shake), rand_range(-shake,shake));

func _on_ShakeTimer_timeout():
	self.offset=Vector2(0,0);
	$"/root/Global".shakescreen=false;
