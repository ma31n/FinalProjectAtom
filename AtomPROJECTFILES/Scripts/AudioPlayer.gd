extends AudioStreamPlayer2D

func _ready():
	$"/root/Global".register_sfxplayer(self);

func _process(_delta):
	self.volume_db=$"/root/Global".sfxvol;
