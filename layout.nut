//
// Boardwalk
// Theme by Mahuti
// vs. 1.2
//

class UserConfig {

	</ label="Show scanlines", 
		help="Shows scanlines over the Snap", 
		options="Yes,No", 
		order=2 /> 
		enable_crt="No";
		
    </ label="T-Molding Color", 
		help="Choose a specific t-molding color, or set it to change randomly.", 
		options="random,blue,black,yellow,red,white,orange,blue,light green,dark green,purple,pink,hot pink", 
		order=3 /> 
		tmolding_color="random";
		
    </ label="Enable lighted marquee effect", 
		help="Show the Marquee lit up", 
		options="Yes,No", 
		order=3 /> 
		enable_Lmarquee="No";
		
    </ label="Show Wheel Images", 
		help="Show animated wheel. Animated wheel may slow the display.", 
		options="Yes,No", 
		order=3 /> 
		show_wheel="No";
    
    </ label="Show Display Name", 
		help="Show the name of the display. Useful for differentiating display-based categories.", 
		options="Yes,No", 
		order=3 /> 
		show_display="No";
        
    </ label="Scaling", 
		help="Controls how the layout should be scaled. Stretch will fill the entire space. Scale will scale up/down to fit the space with potential cropping of non-critical elements (eg. backgrounds).", 
		options="stretch,scale,no scale", 
		order=3 /> 
		scale="stretch";
}
 

local config = fe.get_config();

// layout was built in photoshop. all numbers in this used are based off of the photoshop file's size. 
local base_width = 1440.0; // make sure this number is followed by .0 to make it a float. 
local base_height = 1080.0; // see note above. 

// modules
fe.load_module("fade");
fe.load_module("file"); 
fe.load_module("preserve-art"); 

local scale = config["scale"];

// width conversion factor
local xconv = fe.layout.width / base_width; 
// height conversion factor
local yconv = fe.layout.height / base_height; 
if (scale=="scale")
{
	if (fe.layout.height < base_height)
	{
		xconv = yconv; 
	}
	else
	{
		yconv = xconv; 
	}
}
if (scale=="no scale")
{
	xconv = 1; 
	yconv = 1; 
}


// get a width value converted using conversion factor
function width( num )
{	
    return num * xconv; 
}
// get a height value converted using conversion factor
function height( num )
{
    return num * yconv; 
}
// get a x position converted using conversion factor
 
function xpos( num, float = "left", right_num=0, object_width=0)
{
	if (scale=="stretch" || scale=="no scale")
	{
	    return num * xconv; 
	}
	else
	{
		if (float == "left")
		{
			return num * xconv; 
		}
		else
		{
			local size_difference = 0; 
 		 	if (base_width > fe.layout.width)
			{
				size_difference = base_width - fe.layout.width; 
			}
			return (fe.layout.width - (object_width*xconv)-(right_num * xconv) - size_difference); 
		}
	}
} 

 
 // get the y position value converted using conversion factor
function ypos( num, float = "top"  )
{
	if (scale=="stretch")
	{
		return num * yconv; 
	}
	else
	{
		if (float == "top")
		{
			return num * yconv; 
		}
		else
		{
			if (base_height > fe.layout.height)
			{
				// if base width is larger than layout width, 
				// assume the image/item should just be cropped on the right, rather than slid to the left possibly causing overlap
				return ( (base_height - fe.layout.height) + num); 
			}
			else
			{
				return num * yconv; 
			}
		}
	}
}

function random(minNum, maxNum) {
    return floor(((rand() % 1000 ) / 1000.0) * (maxNum - (minNum - 1)) + minNum);
}
function randomf(minNum, maxNum) {
    return (((rand() % 1000 ) / 1000.0) * (maxNum - minNum) + minNum).tofloat();
}
function random_file(path) {
	
	local dir = DirectoryListing( path );  
	local dir_array = []; 
	foreach ( key, value in dir.results )
	{
		try
	    {
	        local name = value.slice( path.len() + 1, value.len() );
 
			// bad mac!
			if (name.find("._") == null)
			{
				dir_array.append(value); 
			}

	    }catch ( e )
	    {
	        // print(  value );
	    }
	}
	return dir_array[random(0, dir_array.len()-1)]; 
}

///////////////////////////////////////////////////////
//					ARCADE BACKGROUNDS 
///////////////////////////////////////////////////////

local bg = PreserveImage( random_file("arcade"), 0, 0, fe.layout.width, fe.layout.height );
bg.set_fit_or_fill( "fill" );
bg.set_anchor( ::Anchor.Top );
 
 
///////////////////////////////////////////////////////
//					MARQUEE
///////////////////////////////////////////////////////
 
// marquee
local marquee = fe.add_artwork("marquee", xpos(28),ypos(13), width(953), height(299));
marquee.trigger = Transition.EndNavigation;

// light from the marquee
if ( config["enable_Lmarquee"] == "Yes" )
{
    local shader = fe.add_shader( Shader.Fragment "bloom_shader.frag" );
	shader.set_texture_param("bgl_RenderedTexture"); 
	marquee.shader = shader;
}
 
///////////////////////////////////////////////////////
// 					T-Molding
///////////////////////////////////////////////////////

local tmolding = fe.add_image("tmolding.png" , xpos(0),ypos(0), width(1440), height(1080));

local color_array = [
	[101,241,250,"blue"],
	[1,1,1,"black"],
	[255,221,0,"yellow"],
	[253,43,78,"red"],
	[255,255,255,"white"],
	[255,117,5,"orange"],
	[28,71,177,"blue"],
	[28,176,43,"light green"],
	[36,87,41,"dark green"],
	[119,0,255,"purple"],
	[235,157,223,"pink"],
	[255,0,123,"hot pink"]
]; 
 

if (config["tmolding_color"]=="random")
{
	local temp_color = color_array[random(0, color_array.len()-1)]; 
	
	tmolding.red = temp_color[0]; 
	tmolding.green = temp_color[1]; 
	tmolding.blue = temp_color[2]; 
}else
{
	foreach (index, item in color_array) {
	    if (item[3] == config["tmolding_color"]) {
			tmolding.red = color_array[index][0]; 
			tmolding.green = color_array[index][1]; 
			tmolding.blue = color_array[index][2]; 
		}
	}
}
 

///////////////////////////////////////////////////////
// 					Marquee Lighting
///////////////////////////////////////////////////////

// light from the marquee
if ( config["enable_Lmarquee"] != "Yes" )
{
	local arcade_front = fe.add_image("cabinet_with_marquee_shadow.png" , xpos(0),ypos(0), width(1440), height(1080));
}
else
{
	local arcade_front = fe.add_image("cabinet.png" , xpos(0),ypos(0), width(1440), height(1080));
}

///////////////////////////////////////////////////////
// 					SNAP
///////////////////////////////////////////////////////

// create surface for snap
local surface_snap = fe.add_surface( width(808), height(685 ));

local snap = FadeArt("snap",  0, 0, width(808), height(685), surface_snap);
snap.trigger = Transition.EndNavigation;
snap.preserve_aspect_ratio = true;

// position and pinch surface of snap
surface_snap.set_pos(xpos(99),ypos(396), width(808), height(683));
surface_snap.pinch_x = xpos(-77);
 

///////////////////////////////////////////////////////
// 					SNAP Overlays
///////////////////////////////////////////////////////

// scanlines
if ( config["enable_crt"] == "Yes" )
{
	local scanline = fe.add_image( "scanline.png", xpos(99),ypos(396), width(808), height(683));
}
 
///////////////////////////////////////////////////////
// 					BEZEL
///////////////////////////////////////////////////////

// create surface for bezel
local surface_bezel = fe.add_surface( width(813), height(685 ));
local bezel = FadeArt("bezel", 0, 0, width(813), height(685), surface_bezel);
bezel.trigger = Transition.EndNavigation;
bezel.preserve_aspect_ratio = false;

// shadow
surface_bezel.add_image( "snap-shadow.png", xpos(0),ypos(0), width(813), height(685));

// position and pinch surface of bezel
surface_bezel.set_pos(xpos(99),ypos(396));
surface_bezel.pinch_x = xpos(-77); 


///////////////////////////////////////////////////////
// 					WHEEL
///////////////////////////////////////////////////////

if ( config["show_wheel"] == "Yes" )
{
    fe.load_module( "conveyor" );

	local wheel_x = [ xpos(1152,"right"), xpos(1144.8,"right"), xpos(1088.64,"right"), xpos(1044,"right"),xpos(1008,"right"), xpos(979.2,"right"), xpos(921.6,"right"), xpos(979.2,"right"), xpos(1008,"right"), xpos(1044,"right"), xpos(1088.64,"right"), xpos(1094.4,"right"), ]; 
	local wheel_y = [ ypos(-237.6), ypos(-113.4), 0, ypos(113.4), ypos(232.2), ypos(351), ypos(470.88), ypos(658.8),ypos(777.6), ypos(896.4), ypos(1009.8), ypos(1069.2), ];
	local wheel_w = [ width(259.2), width(259.2), width(259.2), width(259.2), width(259.2), width(259.2), width(345.6), width(259.2), width(259.2), width(259.2), width(259.2), width(259.2), ];
	local wheel_a = [  80,  80,  80,  80,  80,  80, 255,  80,  80,  80,  80,  80, ];
	local wheel_h = [  height(114.4),  height(114.4),  height(114.4),  height(114.4),  height(114.4), height(114.4), height(183.6),  height(114.4),  height(114.4),  height(114.4),  height(114.4),  height(114.4), ];
	local wheel_r = [  30,  25,  20,  15,  10,   5,   0, -10, -15, -20, -25, -30, ];
	local num_arts = 8;

	class WheelEntry extends ConveyorSlot
	{
		constructor()
		{
			base.constructor( ::fe.add_artwork( "wheel" ) );
		}

		function on_progress( progress, var )
		{
			local p = progress / 0.1;
			local slot = p.tointeger();
			p -= slot;
		
			slot++;

			if ( slot < 0 ) slot=0;
			if ( slot >=10 ) slot=10;

			m_obj.x = wheel_x[slot] + p * ( wheel_x[slot+1] - wheel_x[slot] );
			m_obj.y = wheel_y[slot] + p * ( wheel_y[slot+1] - wheel_y[slot] );
			m_obj.width = wheel_w[slot] + p * ( wheel_w[slot+1] - wheel_w[slot] );
			m_obj.height = wheel_h[slot] + p * ( wheel_h[slot+1] - wheel_h[slot] );
			m_obj.rotation = wheel_r[slot] + p * ( wheel_r[slot+1] - wheel_r[slot] );
			m_obj.alpha = wheel_a[slot] + p * ( wheel_a[slot+1] - wheel_a[slot] );
		}
	};

	local wheel_entries = [];
	for ( local i=0; i<num_arts/2; i++ )
		wheel_entries.push( WheelEntry() );

	local remaining = num_arts - wheel_entries.len();

	// we do it this way so that the last wheelentry created is the middle one showing the current
	// selection (putting it at the top of the draw order)
	for ( local i=0; i<remaining; i++ )
	wheel_entries.insert( num_arts/2, WheelEntry() );

	local conveyor = Conveyor();
	conveyor.set_slots( wheel_entries );
	conveyor.transition_ms = 50;
	try { conveyor.transition_ms = config["transition_ms"].tointeger(); } catch ( e ) { }

 
}

/*
fe.add_text( "layout width" + fe.monitors[0].width, 20, 20, 200, 20 );
fe.add_text( "layout height" + fe.layout.height, 20, 40, 200, 20 );
*/ 

///////////////////////////////////////////////////////
//					DISPLAY NAME
///////////////////////////////////////////////////////

function dname()
{
	local current_display = fe.displays[fe.list.display_index];
	return current_display.name;
}
 
if ( config["show_display"] == "Yes" )
{
	local show_display = fe.add_text( "[!dname]", xpos(2), ypos(5), width(250), height(40));
	show_display.charsize = 24;
	show_display.set_rgb(247, 35, 0);  
}
