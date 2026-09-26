class_name PlayerAttackModel
extends RefCounted

# ==========================================================================
# res://scripts/combat/attack.gd — MODEL (logic thuần túy, KHÔNG phải Node)
# (Technical Architecture mục 6.1, 8-9)
#
# Model chỉ trả lời 2 câu hỏi:
#   1. attack() -> có được phép tấn công ngay bây giờ không? (bool)
#   2. calculate_damage() -> lượng damage của lần tấn công này? (int)
#
# Model KHÔNG tạo DamageEvent, KHÔNG gọi EventSystem — việc đó thuộc về
# player.gd (Coordinator), vì Model không được biết về Node/Scene/Event.
# ==========================================================================

# TODO 1: sát thương mặc định, setup() sẽ ghi đè bằng data.attack_damage
var attack_damage: int = 10

# TODO 2: thời gian hồi chiêu (giây), setup() sẽ ghi đè bằng data.attack_cooldown
var attack_cooldown: float = 0.5

# TODO 3: mốc thời gian (ms) của lần attack gần nhất — dùng Time.get_ticks_msec()
#         thay vì delta, vì RefCounted không có _process(delta) riêng.
var _last_attack_time_msec: int = -999999999


func setup(damage: int, cooldown: float = 0.5) -> void:
	# TODO 4: nhận attack_damage / attack_cooldown từ PlayerData
	attack_damage = damage
	attack_cooldown = cooldown


func attack() -> bool:
	# TODO 5: 1 Input (thời điểm hiện tại) -> 1 Output (output) -> 1 Return
	var output := false

	var now_msec := Time.get_ticks_msec()
	var elapsed_sec := float(now_msec - _last_attack_time_msec) / 1000.0

	# TODO 6: chỉ cho attack nếu đã hết cooldown; nếu được thì reset mốc thời gian
	if elapsed_sec >= attack_cooldown:
		_last_attack_time_msec = now_msec
		output = true

	return output


func calculate_damage() -> int:
	# TODO 7: hiện tại trả thẳng attack_damage; đây là chỗ mở rộng sau này
	#         (combo, buff, crit...) mà KHÔNG cần sửa player.gd, vì
	#         player.gd chỉ gọi calculate_damage() và dùng kết quả.
	return attack_damage
