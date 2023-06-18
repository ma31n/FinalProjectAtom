extends ColorRect

var speed = 0.1;

func _ready():
	pass

func _process(_delta):
	var tw = create_tween();
	var tw2 = create_tween();

	if($"/root/Global".player.hp==0):
		tw.tween_property(self,"rect_size",Vector2(1024,600),speed);
		tw2.tween_property(self,"rect_position", Vector2(0,0),speed);
		$RichTextLabel2.bbcode_text="[center]Score: "+str($"/root/Global".score)+"[center]";
		get_tree().paused=true;
		
	else:
		tw.tween_property(self,"rect_size",Vector2(1024,0),speed);
		tw2.tween_property(self,"rect_position", Vector2(0,300),speed);

	if(self.rect_size.y>0):
		self.visible=true;
	else:
		self.visible=false;


func _on_RetryButton_pressed():
	$"/root/Global".score=0;
	$"/root/Global".speedup=1;
	$"/root/Global".numofenemies=0;
	$"/root/Global".hurt=false;
	get_tree().paused=false;
	print($"/root/Global".score);
	get_tree().reload_current_scene();

func _on_MainMenuButton_pressed():
	get_tree().paused=false;
	get_tree().change_scene("res://Scenes/MainMenu.tscn");
