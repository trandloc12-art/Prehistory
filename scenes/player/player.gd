extends CharacterBody2D

const SPEED = 150.0

func _physics_process(delta: float) -> void:
	# Lấy hướng di chuyển từ 4 action đã tạo (trả về Vector2, đã tự chuẩn hóa)
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	velocity = input_direction * SPEED
	move_and_slide()

	# Đổi hướng nhìn của sprite theo hướng di chuyển (tùy chọn, xóa nếu chưa cần)
	if input_direction.x != 0:
		$Sprite2D.flip_h = input_direction.x < 0
