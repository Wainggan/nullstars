
application_surface_draw_enable(false);

depth = 10;

mode = 0

surf_lights = -1;
surf_lights_buffer = -1;
surf_mask = -1;
surf_background = -1;

surf_tiles = -1;

surf_layer_0 = -1;
surf_layer_1 = -1;
surf_layer_2 = -1;
surf_layer_outline = -1;

surf_ping = -1;
surf_ping16 = -1;
surf_pong = -1;

surf_background_rays = -1;
surf_background_lights = -1;

surf_bubbles = -1;

surf_water = -1;

surf_relection = -1;
surf_wave = -1;

surf_app = -1;
surf_compose = -1;
surf_lut = -1;

lights_ds = ds_list_create();
lights_array = [];

surface_resize(application_surface, WIDTH, HEIGHT);

background_lights_kernel = 7;
background_lights_sigma = 0.6;
background_lights_brightness = 4;

particles_ambient = part_system_create_layer("Instances", true);
part_system_automatic_update(particles_ambient, false);
part_system_automatic_draw(particles_ambient, false);

particles_layer = part_system_create_layer("Instances", true);
part_system_automatic_update(particles_layer, false);
part_system_automatic_draw(particles_layer, false);

particles_water = part_system_create_layer("Instances", true);
part_system_automatic_update(particles_water, false);
part_system_automatic_draw(particles_water, false);


lut_mode_grade = new Mode(spr_grade_base);
lut_mode_mix = new Mode(1);

game_update_windowscale(global.settings.graphic.windowscale + 1);
game_update_fullscreen(global.settings.graphic.fullscreen);

matrix_identity = matrix_build_identity();


config = {
	background: true,
	tiles_decor: true,
	
	particles_atmosphere: true,
	particles_object: true,
	particles_light: true,
	
	light_rim: true,
	light_spot: true,
	light_spot_shader: true,
	light_shadow: true,
	light_method: true,
	light_method_scissor: true,
	light_method_blur: false, // broken
	
	bubble_anim: true,
	bubble_spike: true,
	bubble_outline: true,
	
	water_anim_waves: true,
	water_anim_refract: true,
	water_outline: true,
	
	reflection_floor: true,
	reflection_back: true,
	
	post_outline: true,
	post_outline_except: true,
	post_atmosphere: true,
	post_bloom: true,
	post_abberation: true,
	post_cracks: true,
	post_lut: true,
};

