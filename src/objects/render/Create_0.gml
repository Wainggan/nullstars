
application_surface_draw_enable(false);

depth = 10;

mode = 0

surf_lights = -1;
surf_lights_buffer = -1;
surf_mask = -1;
surf_background = -1;

surf_layer_0 = -1;
surf_layer_1 = -1;
surf_layer_2 = -1;
surf_layer_outline = -1;

surf_ping = -1;
surf_pong = -1;

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


p = [
	spr_grade_base,
	spr_grade_decorrelation_1,
	spr_grade_decorrelation_2,
	spr_grade_decorrelation_3,
	spr_grade_muddy,
	spr_grade_snow,
	spr_grade_saturate,
	spr_grade_cracked,
	spr_grade_meltingpot,
	spr_grade_contrast_lightness,
	spr_grade_bump_yellow,
	spr_grade_mild,
	spr_grade_waterfall,
]
