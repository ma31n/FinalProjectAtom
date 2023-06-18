extends VSlider

func _ready():
	self.value=$"/root/Global".musicvol+50;

func _on_VolumeSlider_value_changed(value):
	$"/root/Global".musicvol=value-50;
	if(value==0):
		$"/root/Global".musicvol=-100;
