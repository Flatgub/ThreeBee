/// @description DevConsole Draw

//draw_circle(global.SCREEN_CENTER_X,global.SCREEN_CENTER_Y,8,false)

if global.CONSOLE_OPEN	{
	consoleSurface.set_target();
	
	draw_clear_alpha(c_black,0);
	
	draw_set_font(consoleFont);
	draw_set_colour(CONSOLE_BGCOL_A)
	
		
	draw_rectangle(-1,0,consoleWidth,consoleHeight+fontHeight+barHeight,false);
		
	draw_set_colour(c_white)
	draw_line(-1,consoleHeight,consoleWidth,consoleHeight)
	draw_line(-1,consoleHeight+fontHeight+3,consoleWidth,consoleHeight+fontHeight+2)
		
	draw_set_halign(fa_left)
	draw_set_valign(fa_top);
	
	
	var entryHeight = consoleHeight+barHeight;
	
	
	var w = string_width(pendingCommand)
	draw_set_colour(c_gray)
	draw_line(w+2,entryHeight,w+2,entryHeight+fontHeight-1)
	
	draw_set_colour(c_white)
	
	draw_text(2,entryHeight-FONT_YOFFSET,pendingCommand);
	
	var lines = global.__console_lines;
	
	var i = ds_list_size(lines)-1;
	var yy = consoleHeight-1;
	
	var altline = false;
	var lineHeight = fontHeight+2;
	
	while(yy > -16) {
		yy-=lineHeight;
		//var l = lines[| i];
		if altline {
			draw_set_colour(CONSOLE_BGCOL_B);
			draw_rectangle(-1,yy,consoleWidth,yy+lineHeight,false)
			}
		altline = !altline;
		}
		
	var yy = consoleHeight-1;
	
	while(i >= 0 && yy > -16) {
		yy-=lineHeight;
		var l = lines[| i];
		
		draw_set_colour(l.colour);
		//draw_text_ext(2,yy-1,l,-1,consoleWidth-4)
		draw_text(2,yy-1,l.text)
		i--;
		altline = !altline;
		}
		
	surface_reset_target()
	
	consoleSurface.draw(0,0);
	}
	
draw_set_colour(c_white)