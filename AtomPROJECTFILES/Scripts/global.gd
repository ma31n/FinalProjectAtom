extends Node

var player;
var score = 0;
var room_size;
var pause;
var killedenemy;
var hurt = false;
var numofenemies = 0;
var speedup = 1;
var extendstreak = 0;
var shakescreen = false;
var selectedlevel = "Rooftops";
var musicvol = 0;
var sfxvol = 0;
var sfxplayer;

func _ready():
	pass
	
func register_player(in_player):
	player = in_player;

func register_score(in_score):
	score = in_score;

func register_room_size(in_room_size):
	room_size = in_room_size;

func register_pause(in_pause):
	pause = in_pause;

func register_kill(in_kill):
	killedenemy = in_kill;

func register_hurt(in_hurt):
	hurt = in_hurt;

func register_numofenemies(in_numoe):
	numofenemies = in_numoe;

func register_speedup(in_speedup):
	speedup = in_speedup;

func register_hitstreak(in_extendstreak):
	extendstreak = in_extendstreak;

func register_selectedlevel(in_selectedlevel):
	selectedlevel = in_selectedlevel;

func register_musicovl(in_musicvol):
	musicvol=in_musicvol;

func register_sfxplayer(in_sfxplayer):
	sfxplayer = in_sfxplayer;

func regist_sfxvol(in_sfxvol):
	sfxvol = in_sfxvol;
