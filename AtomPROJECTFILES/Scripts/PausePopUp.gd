extends ColorRect

var speed = 0.1;

func _ready():
	pass

func _process(_delta):

	if(Input.is_action_just_pressed("Pause")):
		var tw = create_tween();
		var tw2 = create_tween();

		if(get_tree().paused==false):
			get_tree().paused=true;
			
			tw.tween_property(self,"rect_size",Vector2(1024,200),speed);
			tw2.tween_property(self,"rect_position", Vector2(0,200),speed);

		else:
			get_tree().paused=false;
			
			tw.tween_property(self,"rect_size",Vector2(1024,0),speed);
			tw2.tween_property(self,"rect_position", Vector2(0,300),speed);

	if(self.rect_size.y>0):
		self.visible=true;
	else:
		self.visible=false;


func _on_Button_pressed():
	get_tree().paused=false;
	get_tree().change_scene("res://Scenes/MainMenu.tscn");
