class_name HealthComponent
extends Node

# TODO: 2 signal
# signal health_changed(current_health, max_health)  # bắn ra mỗi khi HP thay đổi
# signal died                                          # bắn ra khi HP <= 0

# TODO: 2 biến trạng thái runtime
# var max_health: int
# var current_health: int

# TODO: hàm setup(value) — gọi 1 lần khi Player/Enemy _ready()
# func setup(value: int) -> void:
#     - gán max_health = value
#     - gán current_health = max_health
#     - emit health_changed

# TODO: hàm take_damage(amount) — nơi DUY NHẤT được trừ HP trong toàn hệ thống
# func take_damage(amount: int) -> void:
#     - current_health -= amount, clamp không cho âm (dùng max(...,0))
#     - emit health_changed(current_health, max_health)
#     - nếu current_health <= 0 -> emit died

# Lưu ý khi code thật (theo mục "1 Input -> 1 Output -> 1 Return"):
# - Component này KHÔNG được biết nguồn damage là ai (Enemy/Trap/Poison...).
# - KHÔNG gọi ngược Player/Enemy, chỉ phát signal.
# - Có thể cân nhắc thêm hàm heal(amount) sau này (không có trong tài liệu gốc,
#   chỉ là hướng mở rộng ở mục 25 - HealEvent).
