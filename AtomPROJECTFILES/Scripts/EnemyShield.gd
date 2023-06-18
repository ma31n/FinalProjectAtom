extends KinematicBody2D


var move = Vector2(0,0);

onready var player;

onready var shieldenemy = {
	"health":10,
	"speed":300,
	"kickback":900,
	"points": 20
};

onready var current_enemy;
var kicked = false;
var kickbackfall = 10;

onready var ogspeed;
onready var ogkickback;
var extrakickback=150;

var sfxList={};

func _ready():
	add_to_group("EnemyShield");
	loadSFX();
	current_enemy=shieldenemy;
	$Control/ProgressBar.max_value=current_enemy.health;
	$Control/ProgressBar.value=current_enemy.health;
	ogspeed=current_enemy.speed;
	ogkickback=current_enemy.kickback;

func _physics_process(_delta):
	$AudioPlayer.volume_db=$"/root/Global".sfxvol;
	player = $"/root/Global".player;
	$Control/ProgressBar.value=current_enemy.health;
	shaderDisplay();
	movement();
	kick_back();
	hit_reg();


func reg_kill():
	$"/root/Global".score+=current_enemy.points;
	$"/root/Global".killedenemy=self.name;
	$"/root/Global".numofenemies-=1;
	$"/root/Global".extendstreak=1;
	if(player.anim!="attack_special1" and player.charge_build_up<player.charge_cooldown):player.charge_build_up+=1;
	if(player.anim=="attack_prespecial2"):
		$"/root/Global".pause=true;
	else:
		$"/root/Global".sfxplayer.stream=sfxList["enemy_death"];
		$"/root/Global".sfxplayer.play();
	queue_free();

func movement():
	if($"/root/Global".pause==false):
		self.set_visible(true); 

		#MOVEMENT
		if(player.get_position()>self.get_position()):
			$AnimatedSprite.scale.x=1;
		else:
			$AnimatedSprite.scale.x=-1;
		
		move.x=current_enemy.speed*$AnimatedSprite.scale.x*$"/root/Global".speedup;

		if($"/root/Global".hurt==false):move_and_slide(move);
	else:

		self.position.x=self.position.x-($AnimatedSprite.scale.x*3);
		
	if($"/root/Global".hurt==true):
		self.position.x=self.position.x-($AnimatedSprite.scale.x*2);

func hit_reg():
	if($Area2DEnemyBasic.overlaps_area(player.get_node("Area2DAttack"))):
		if(player.enemydestroyable==true and player.anim!="hurt"):
			if(player.anim!="attack_prespecial2"):$"/root/Global".shakescreen=true;
			if(player.anim=="attack_slide"):
				current_enemy.health-=player.playerdamage[player.anim]*2;
				$AudioPlayer.stream=sfxList["enemy_hit_short"];
				$AudioPlayer.play();
				dmgIndicator();
			
			if(current_enemy.health<=0 or player.anim=="attack_prespecial2" or player.anim=="attack_special1"):
				reg_kill();
			else:
				kicked=true;
				$"/root/Global".extendstreak=0.5;
				if(player.anim=="runningAttack" or player.anim=="attack_slide"):current_enemy.kickback=ogkickback+extrakickback;
	
	elif($Area2DEnemyBasic.overlaps_area(player.get_node("Area2DAttack2")) and player.anim=="runningAttack"):
		if(player.enemydestroyable==true and player.anim!="hurt"):
				kicked=true;
				$"/root/Global".extendstreak=0.5;
				current_enemy.kickback=ogkickback+extrakickback;

func kick_back():
	if(current_enemy.kickback>0 and kicked==true):
		current_enemy.speed=-current_enemy.kickback;
		current_enemy.kickback-=kickbackfall;
	else:
		current_enemy.speed=ogspeed;
		kicked=false;
		current_enemy.kickback=ogkickback;

func dmgIndicator():
	var indicator = preload("res://Scenes/DMG_Indicator.tscn").instance();
	indicator.position=Vector2(self.position.x, self.position.y-200);
	get_node("../").add_child(indicator);
	indicator.showDmgPoint(player.playerdamage[player.anim]*2);

func shaderDisplay():
	if($"/root/Global".shakescreen==false or (kicked==true and !player.anim=="attack_slide")):
		$AnimatedSprite.material.set_shader_param("flashState", 0);
	elif(kicked==true and $"/root/Global".shakescreen==true):
		$AnimatedSprite.material.set_shader_param("flashState", 1);

func loadSFX():

	var dir = Directory.new()
	dir.open("res://SFX/")
	dir.list_dir_begin()

	for i in range(0,50):
			var file_name = dir.get_next();
			if(file_name.get_extension()=="import" and "enemy" in file_name):
				sfxList[file_name.get_basename().get_basename()]=ResourceLoader.load("res://SFX/"+file_name.get_basename());
