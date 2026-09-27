class_name PlayerHealthModel
extends Node

# ==========================================================================
# model/health.gd — MODEL (Node con của Player, vì cần phát signal)
# (Tổng hợp chi tiết Player_Enemy mục 10 — tương đương HealthComponent,
#  đổi tên PlayerHealthModel để khớp @onready var health: PlayerHealthModel
#  = $PlayerHealthModel trong player.gd)
#
# Đây là NODE (extends Node), khác với movement/attack (RefCounted), vì:
#  - Cần phát signal (health_changed, died) để player.gd lắng nghe.
#  - Cần đặt làm Node con trong player.tscn để dùng $PlayerHealthModel.
#
# HealthModel không biết nguồn damage đến từ đâu (Enemy/Trap/Poison...),
# không tự gọi die() — chỉ emit "died", việc gọi die() là của player.gd
# (_on_died(), xem mục 18).
# ==========================================================================

signal health_changed(current_health: int, max_health: int)
signal died

var max_health: int = 0
var current_health: int = 0


func setup(value: int) -> void:
	max_health = value
	current_health = max_health
	health_changed.emit(current_health, max_health)


func take_damage(amount: int) -> void:
	current_health -= amount

	if current_health < 0:
		current_health = 0

	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		died.emit()


func heal(amount: int) -> void:
	# Không nằm trong 2 tài liệu gốc, thêm sẵn vì HP thường cần hồi máu
	# (potion, regen...). Xoá nếu không dùng đến.
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)


func is_dead() -> bool:
	return current_health <= 0
