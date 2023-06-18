extends Area2D;

var score;
var rand_num;
var basic_enemy;
var fast_enemy;
var tough_enemy;
var shield_enemy;
var powerUp_enemy;
var pause=false;
var zoom = 1;
var offset = 0;
var enemytype=1;
var killstreak = 0;
var streakscore = 0;
var enemylimit = 10;
var killstreakduration = 2;
var enemyCount = {
	"EnemyBasic": 10,
	"EnemyFast": 5,
	"EnemyTough": 5,
	"EnemyShield": 3,
	"EnemyPowerUp": 1
}

onready var musicList = [];
onready var lastPlayed = null;
onready var cam = get_node("../Player/Camera2D");
onready var streaklabel = get_node("../CanvasLayer/Control/KillStreakLabel");
onready var streakprogress = get_node("../CanvasLayer/Control/ProgressBarStreak");
onready var streakpointlabel = get_node("../CanvasLayer/Control/StreakPointsLabel");

func _ready():
	randomize();
	$CollisionShape2D.shape.extents.x=$Bg.texture.get_width();
	var room_s = $CollisionShape2D.shape.extents.x;
	$"/root/Global".register_room_size(room_s);
	$"/root/Global".register_pause(pause);
	
	loadSongs();
	levelSelector();

func _process(_delta):
	playMusic();
	displayScore();
	scoreTracker();
	displayKillStreak();
	handleKillStreak();
	
	if(Input.is_action_just_pressed("fullscreen")):
		OS.window_fullscreen = !OS.window_fullscreen;

func _on_Timer_timeout():

	if($"/root/Global".pause==false):
		var rand_enemy;

		rand_enemy = randomEnemy(rand_enemy);
		
		rand_num = randi()%2;
		if($"/root/Global".numofenemies<enemylimit and (get_tree().get_nodes_in_group(rand_enemy.name).size()-1)<enemyCount[rand_enemy.name]):
			if(rand_num>0):
				rand_enemy.set_position(Vector2($CollisionShape2D.shape.extents.x,$"/root/Global".player.position.y+16));
				get_node("../").add_child(rand_enemy);
			else:
				rand_enemy.set_position(Vector2(0-128,$"/root/Global".player.position.y+16));
				get_node("../").add_child(rand_enemy);
				
			$"/root/Global".numofenemies+=1;

func playMusic():
	$MusicPlayer.volume_db=$"/root/Global".musicvol;
	if(!$MusicPlayer.playing or Input.is_action_just_pressed("skipSong")):
		var rand = randi() % len(musicList);
		while(rand==lastPlayed):
			rand = randi() % len(musicList);
		lastPlayed=rand;
		$MusicPlayer.stream=musicList[rand];
		$MusicPlayer.play();

func displayScore():
	score = $"/root/Global".score;
	get_node("../CanvasLayer/Control/RichTextLabel").bbcode_text="[center]"+str(score)+"[/center]";

func scoreTracker():
	if(score<200):
		enemytype=1;
		enemylimit=15;
		$Timer.wait_time=1;
	elif(score<600):
		enemytype=2;
		enemylimit=20;
		$Timer.wait_time=0.8;
	elif(score<1000):
		enemytype=3;
		enemylimit=25;
	elif(score<1400):
		enemytype=4;
		enemylimit=30;
		$Timer.wait_time=0.5;
	elif(score<1600):
		enemytype=5;
		enemylimit=50;

func loadSongs():
	var dir = Directory.new()
	dir.open("res://Music/")
	dir.list_dir_begin()
	
	for i in range(0,20):
			var file_name = dir.get_next();
			if(file_name.get_extension()=="import" and !"MENU" in file_name):
				musicList.append(ResourceLoader.load("res://Music/"+file_name.get_basename()));

func randomEnemy(rand):
	match randi()%enemytype:
		0:
			basic_enemy = preload("res://Scenes/EnemyBasic.tscn").instance();
			rand = basic_enemy;
		1:
			fast_enemy = preload("res://Scenes/EnemyFast.tscn").instance();
			rand = fast_enemy;
		2:
			tough_enemy = preload("res://Scenes/EnemyTough.tscn").instance();
			rand = tough_enemy;
		3:
			shield_enemy = preload("res://Scenes/EnemyShield.tscn").instance();
			rand = shield_enemy;
		4:
			powerUp_enemy = preload("res://Scenes/EnemyPowerUp.tscn").instance();
			rand = powerUp_enemy;
	return rand;

func displayKillStreak():
	streakprogress.value=$StreakTimer.time_left;
	streaklabel.bbcode_text="[center]"+str(killstreak)+"[center]";
	streakpointlabel.bbcode_text="[center]SCORE: "+str(streakscore)+"[center]";

func handleKillStreak():
	if($"/root/Global".extendstreak==1):
		killstreak+=1;
		$StreakTimer.start(killstreakduration);
		streakprogress.max_value=killstreakduration;
		
		if(killstreak>2):
			if(killstreakduration>1):
				killstreakduration-=0.1;
			streaklabel.visible=true;
			streakprogress.visible=true;
			streakpointlabel.visible=false;
		
		$"/root/Global".extendstreak=0;
		
	elif($"/root/Global".extendstreak==0.5):
		if(!$StreakTimer.is_stopped()):
			var temp = $StreakTimer.time_left;
			if((temp+0.2)>2):temp=1.8;
			$StreakTimer.start(temp+0.2);
		$"/root/Global".extendstreak=0;

func levelSelector():

	match $"/root/Global".selectedlevel:
		"Rooftops":
			$"../CityDay".visible=true;
		
		"Woods":
			$"../Woods".visible=true;
		
		"Neon":
			$"../Neon".visible=true;

func _on_StreakTimer_timeout():
	if(killstreak>2):
		streakscore=floor((10*(float(killstreak)/3)));
		$"/root/Global".score+=streakscore;
		streakpointlabel.visible=true;
	killstreak=0;
	killstreakduration=2;
	streaklabel.visible=false;
	streakprogress.visible=false;

