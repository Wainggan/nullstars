
#macro RELEASE false
#macro Release:RELEASE true

gml_release_mode(RELEASE);

global.defs = {
	terminal_vel: 5
}

global.config = {
	_demonstrate: false,
	graphics_lights: true,
	graphics_lights_shadow: true,
	graphics_lights_rimblur: true,
	graphics_atmosphere_particles: true,
	graphics_atmosphere_overlay: true,
	graphics_reflectables: true,
	graphics_post_outline: true,
	graphics_post_grading: true,
	graphics_up_bubble_wobble: true,
	graphics_up_bubble_outline: true,
	graphics_up_bubble_spike: true,
	slow: false,
}


#macro WIDTH 960
#macro HEIGHT 540

#macro TILESIZE 16

#macro GAME_RENDER_LIGHT_SIZE 2048
#macro GAME_RENDER_LIGHT_KERNEL 256

#macro GAME_BUBBLE_PARITY 8
