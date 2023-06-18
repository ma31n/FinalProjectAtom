extends KinematicBody2D

var speed = 600;
var move = Vector2(0,0);
var anim  = "idle"
var enemydestroyable = false;
var cooldowntime = 5;
var cooldownfinisher=10;
var charge_build_up=0;
var charge_cooldown=10;
var spinningtimer = 1;
var lastpos = self.position;
var hp = 3;
var reverse = 1;
var playerdamage = {
	"attack":5,
	"runningAttack":1,
	"attack_slide":0.3,
	"attack_prespecial2":1000,
	"attack_special1":1000,
	"attack_special2":1000,
	"run":0,
	"idle":0
}
var sfxplayer;
var sfxList = {};

func _ready():
	$"/root/Global".register_player(self);
	loadSFX();

func _physics_process(_delta):
	sfxplayer=$"/root/Global".sfxplayer;
	$AudioPlayer.volume_db=$"/root/Global".sfxvol;
	screenWrap();
	movement();
	updateProgressBars();

func _on_AnimatedSprite_animation_finished():

	if(anim=="attack"):
		anim="idle";
		enemydestroyable = false;
	
	elif(anim=="attack_prespecial1"):
		$AnimatedSprite.play("attack_special1");
		charge_build_up=0;
		anim = $AnimatedSprite.animation;
		move.x=$AnimatedSprite.scale.x*speed;
		$CollisionShape2D.set_disabled(true);
		$Area2DHit.set_monitoring(false);
		enemydestroyable = true;
		
		$AudioPlayer.stream=sfxList["player_run_fast"];
		$AudioPlayer.play();
		
	elif(anim=="attack_prespecial2"):
		enemydestroyable=false;
		if($"/root/Global".pause==true):
			
			$AudioPlayer.stream=sfxList["player_fastslashes"];
			$AudioPlayer.play();
			
			$AnimatedSprite.play("attack_special2");
			$FinisherCooldown.start(cooldownfinisher);
		else:
			anim="idle";
			
	elif(anim=="attack_special2"):
		anim="idle";
		enemydestroyable = false;
		$"/root/Global".pause=false;
		$AudioPlayer.stop();

	elif(anim=="hurt"):
		anim="idle"
		$"/root/Global".hurt=false;
	
	elif(anim=="attack_slide"):
		anim="idle";
		enemydestroyable = false;
		$AudioPlayer.stop();

func _on_AnimatedSprite_frame_changed():
	if(anim=="attack"):
		enemydestroyable=true;
	
	elif(anim=="attack_prespecial2"):
		if($"/root/Global".pause==true):
			$AudioPlayer.stream=sfxList["player_fastslashes"];
			$AudioPlayer.play();
			$AnimatedSprite.play("attack_special2");
			$FinisherCooldown.start(cooldownfinisher);
			anim=$AnimatedSprite.animation;

func _on_Area2DHit_area_entered(area):
	if(area.get_name()=="Area2DEnemyBasic"):
		hp=hp-1;
		
		if(hp>0):
			$"/root/Global".hurt=true;
			$AnimatedSprite.play("hurt");
			$AudioPlayer.stream=sfxList["player_hurt"];
			$AudioPlayer.play();
			move.x=0;
			anim = $AnimatedSprite.animation;

func _on_runningAttackTimer_timeout():
	anim="idle";
	enemydestroyable = false;
	$runningAttackCooldown.start(cooldowntime);
	$AudioPlayer.stop();

func screenWrap():
	var screen_size = $"/root/Global".room_size;
	if self.position.x > screen_size:
		self.position.x = -128
	if self.position.x < -128:
		self.position.x = screen_size

func movement():
	if(Input.is_action_pressed("reverse")):
		reverse=-1;
	else:
		reverse=1;

	if(!anim.begins_with("attack") and anim!="hurt"):
		
		#RUNNING
		if(Input.is_action_pressed("ui_left")):
			running(-1);
		elif(Input.is_action_pressed("ui_right")):
			running(1);
		else:
			move.x=0;
			if(anim!="runningAttack"):
				$AnimatedSprite.play("idle");
				anim = $AnimatedSprite.animation;
			if(anim=="idle"):
				$AudioPlayer.stop();

		#BASIC ATTACK	
		if(Input.is_action_just_pressed("hit") and (move.x==0 or $runningAttackCooldown.time_left>0)):
			reverseAttack();
			$AnimatedSprite.play("attack");
			anim = $AnimatedSprite.animation;
			move.x=0;
			$AudioPlayer.stream=sfxList["player_swish"];
			$AudioPlayer.play();
		
		#SPINNING ATTACK
		elif(Input.is_action_just_pressed("hit") and anim=="run"):
			if($runningAttackTimer.time_left==0 and floor($runningAttackCooldown.time_left)==0):
				$AudioPlayer.stream=sfxList["player_spin"];
				$AudioPlayer.play();
				$AnimatedSprite.play("runningAttack");
				anim = $AnimatedSprite.animation;
				enemydestroyable=true;
				$runningAttackTimer.start(spinningtimer);

		#CHARGING ATTACK
		elif(Input.is_action_just_pressed("Special1") and anim!="runningAttack" and charge_build_up==charge_cooldown):
			if(anim!="attack_prespecial1" and anim!="attack_special1"):
				reverseAttack();
				
				$AnimatedSprite.play("attack_prespecial1");
				anim = $AnimatedSprite.animation;
				move.x=0;
				lastpos = self.position;
	
		#FINISHER
		elif(Input.is_action_just_pressed("Special2") and anim!="runningAttack" and $FinisherCooldown.time_left==0):
			reverseAttack();
			
			$AnimatedSprite.play("attack_prespecial2");
			anim = $AnimatedSprite.animation;
			move.x=0;
			enemydestroyable=true;
		#SLIDE
		elif(Input.is_action_just_pressed("slide") and anim!="runningAttack" and move.x!=0):
			reverseAttack();
			$AudioPlayer.stream=sfxList["player_slide"];
			$AudioPlayer.play();
			$AnimatedSprite.play("attack_slide");
			anim = $AnimatedSprite.animation;
			enemydestroyable=true;
	#move.x=move.x;
	move_and_slide(move);
	
	#CHARGING ATTACK STOP
	if(self.position.distance_to(lastpos)<2 and anim=="attack_special1"):
		anim="idle";
		enemydestroyable = false;
		$CollisionShape2D.set_disabled(false);
		$Area2DHit.set_monitoring(true);

func running(direction):
	move.x=speed*direction;
	if(anim!="runningAttack"):
		if($AudioPlayer.stream!=sfxList["player_run"] or $AudioPlayer.playing==false):
			$AudioPlayer.stream=sfxList["player_run"];
			$AudioPlayer.play();
		$AnimatedSprite.play("run");
		anim = $AnimatedSprite.animation;

	if($Area2DAttack/AttackCollisionShape2D.position.x*direction<0):
		$Area2DAttack/AttackCollisionShape2D.position.x *= -1;
		$Area2DAttack2/AttackCollisionShape2D.position.x *= -1;
			
	$AnimatedSprite.scale.x=direction;

func reverseAttack():
	if(reverse==-1):
		$Area2DAttack/AttackCollisionShape2D.position.x *= -1;
		$Area2DAttack2/AttackCollisionShape2D.position.x *= -1;
		$AnimatedSprite.scale.x=$AnimatedSprite.scale.x*reverse;

func updateProgressBars():
	var spin = get_node("../CanvasLayer/Control/ProgressBarSpin");
	var finisher = get_node("../CanvasLayer/Control/ProgressBarFinisher");
	var charge = get_node("../CanvasLayer/Control/ProgressBarCharging");
	if($runningAttackTimer.time_left>0):
		spin.value=$runningAttackTimer.time_left;
		spin.max_value=spinningtimer;
	else:
		spin.value=cooldowntime-$runningAttackCooldown.time_left;
		spin.max_value=cooldowntime;
		
	finisher.value=cooldownfinisher-$FinisherCooldown.time_left;
	
	charge.value=charge_build_up;

func loadSFX():
	var dir = Directory.new()
	dir.open("res://SFX/")
	dir.list_dir_begin()

	for i in range(0,50):
			var file_name = dir.get_next();
			if(file_name.get_extension()=="import" and "player" in file_name):
				sfxList[file_name.get_basename().get_basename()]=ResourceLoader.load("res://SFX/"+file_name.get_basename());
