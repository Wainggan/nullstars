var _cam = game_camera_get()
draw_set_font(ft_sign)
draw_text(_cam.x + 16, _cam.y + 32, instance_number(obj_Exists))