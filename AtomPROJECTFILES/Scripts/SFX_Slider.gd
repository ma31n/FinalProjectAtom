extends VSlider

func _ready():
	self.value=$"/root/Global".sfxvol+50;

func _on_SFX_Slider_value_changed(value):
	$"/root/Global".sfxvol=value-50;
	if(value==0):
		$"/root/Global".sfxvol=-100;
