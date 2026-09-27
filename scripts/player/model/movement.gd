class_name PlayerMovementModel
extends RefCounted

# ==========================================================================
# res://scripts/combat/movement.gd — MODEL (logic thuần túy, KHÔNG phải Node)
# (Technical Architecture mục 6.1: Model chứa logic tính toán, KHÔNG được
#  gọi ngược lại player.gd. Model không biết gì về Node/Scene.)
#
# Nguyên tắc: 1 Input -> 1 Output -> 1 Return (mục 5)
# ==========================================================================

# TODO 1: giá trị mặc định, sẽ bị setup() ghi đè ngay khi player.gd._ready()
#         gọi movement_model = PlayerMovementModel.new() rồi setup().
var move_speed: float = 150.0


func setup(speed: float) -> void:
	# TODO 2: nhận move_speed từ PlayerData (player.gd truyền data.move_speed vào)
	move_speed = speed


func calculate_movement(input_direction: Vector2) -> Vector2:
	# TODO 3: 1 Input (input_direction) -> 1 Output (output) -> 1 Return
	var output := Vector2.ZERO

	# TODO 4: chỉ tính velocity khi có hướng đi, tránh normalize(Vector2.ZERO)
	if input_direction != Vector2.ZERO:
		output = input_direction.normalized() * move_speed

	return output
