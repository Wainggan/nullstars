
#macro INPUT obj_input.manager

manager = new InputManager(0, 0.2);

manager.create_input("horizontal")
.add_keyboard_axis(vk_left, vk_right)
.add_keyboard_axis(ord("A"), ord("D"))
.add_gamepad_stick(gp_axislh);

manager.create_input("vertical")
.add_keyboard_axis(vk_up, vk_down)
.add_keyboard_axis(ord("W"), ord("S"))
.add_gamepad_stick(gp_axislv);

manager.create_input("left")
.add_keyboard_key(vk_left)
.add_keyboard_key(ord("A"))
.add_gamepad_stick_virtual(gp_axislh, -1)
.add_gamepad_button(gp_padl)
manager.create_input("right")
.add_keyboard_key(vk_right)
.add_keyboard_key(ord("D"))
.add_gamepad_stick_virtual(gp_axislh, 1)
.add_gamepad_button(gp_padr)
manager.create_input("up")
.add_keyboard_key(vk_up)
.add_keyboard_key(ord("W"))
.add_gamepad_stick_virtual(gp_axislv, -1, 0.2)
.add_gamepad_button(gp_padu)
manager.create_input("down")
.add_keyboard_key(vk_down)
.add_keyboard_key(ord("S"))
.add_gamepad_stick_virtual(gp_axislv, 1, 0.2)
.add_gamepad_button(gp_padd)

manager.create_input("jump")
.add_keyboard_key(ord("Z"))
.add_keyboard_key(ord("C"))
.add_keyboard_key(ord("J"))
.add_keyboard_key(ord("L"))
.add_gamepad_button(gp_face1)
.add_gamepad_button(gp_face4)

manager.create_input("dash")
.add_keyboard_key(ord("X"))
.add_keyboard_key(ord("K"))
.add_gamepad_button(gp_face2)
.add_gamepad_button(gp_face3)

manager.create_input("grab")
.add_keyboard_key(vk_shift)
.add_keyboard_key(vk_space)
.add_gamepad_shoulder_virtual(gp_shoulderl)
.add_gamepad_shoulder_virtual(gp_shoulderr)
