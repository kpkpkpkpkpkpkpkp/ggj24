extends TextureRect




func dir_pressed(target_page):
	if target_page==0:
		$AboutPage2.visible=false
	if target_page==1:
		$AboutPage2.visible=true
		$AboutPage2/AboutPage3.visible=false
	if target_page==2:
		$AboutPage2.visible=true
		$AboutPage2/AboutPage3.visible=true
		
