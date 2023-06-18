extends Node2D

var levels = ["Rooftops", "Woods", "Neon"];
var globepos ={
	"Rooftops": Vector3(0,-45,-20),
	"Woods": Vector3(-30,-140,-10),
	"Neon": Vector3(20,-270,20)
}
var selected = 0;

onready var musicList = [];
var lastPlayed;

func _ready():
	loadSongs();
	$"/root/Global".score=0;
	$"/root/Global".speedup=1;
	$"/root/Global".numofenemies=0;
	$"/root/Global".hurt=false;
	$"/root/Global".selectedlevel="Rooftops";

func _process(_delta):

	if(Input.is_action_just_pressed("fullscreen")):
		OS.window_fullscreen = !OS.window_fullscreen;
		
	$UI/RichTextLabel.bbcode_text="[center]"+levels[selected]+"[center]";
	playMusic();
	var tw = create_tween();
	tw.tween_property($Viewport/Globe/StaticBody,"rotation_degrees",globepos[levels[selected]],1);
	
	if(Input.is_action_just_pressed("ui_left")):
		prevPressed();
	elif(Input.is_action_just_pressed("ui_right")):
		nextPressed();
	elif(Input.is_action_just_pressed("hit")):
		start();

func _on_Button_pressed():
	start();

func _on_Previous_pressed():
	prevPressed();

func _on_Next_pressed():
	nextPressed();

func nextPressed():
	selected+=1;
	if(selected>2):selected=0;
	$"/root/Global".selectedlevel=levels[selected];
	
func prevPressed():
	selected-=1;
	if(selected<0):selected=2;
	$"/root/Global".selectedlevel=levels[selected];

func start():
	get_tree().change_scene("res://Scenes/Main.tscn");

func loadSongs():
	var dir = Directory.new()
	dir.open("res://Music/")
	dir.list_dir_begin()
	for i in range(0,20):
			var file_name = dir.get_next();
			if(file_name.get_extension()=="import" and "MENU" in file_name):
				musicList.append(ResourceLoader.load("res://Music/"+file_name.get_basename()));
	
func playMusic():
	$AudioPlayer2D.volume_db=$"/root/Global".musicvol;
	if(!$AudioPlayer2D.playing or Input.is_action_just_pressed("skipSong")):
		var rand = randi() % len(musicList);
		while(rand==lastPlayed):
			rand = randi() % len(musicList);
		lastPlayed=rand;
		$AudioPlayer2D.stream=musicList[rand];
		$AudioPlayer2D.play();
