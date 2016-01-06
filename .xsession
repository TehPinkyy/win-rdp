xrandr --output VGA1 --mode 1024x768	#for setting a video mode
xrandr --fb 1024x768			#not always required, sets the framebuffer size
xsetbg -center background.png &		#to set the background, comes from the xloadimage package
xset -dpms s off			#to avoid screen going blank after a while
#rdesktop SERVER			#start your application
gedit
