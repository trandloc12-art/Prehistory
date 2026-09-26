class_name PlayerData
extends Resource

# ==========================================================================
# res://scripts/player_data/player_data.gd — DATA (Resource)
# (Tổng hợp chi tiết Player_Enemy, mục 8-9: PlayerData chỉ chứa CẤU HÌNH,
#  KHÔNG chứa logic. Không gọi take_damage()/die()/_ready() ở đây.)
# ==========================================================================

# TODO 1: HP tối đa, PlayerHealthModel.setup() sẽ đọc giá trị này.
@export var max_health: int = 100

# TODO 2: Tốc độ di chuyển, PlayerMovementModel.setup() sẽ đọc giá trị này.
@export var move_speed: float = 150.0

# TODO 3: Sát thương mỗi lần đánh, PlayerAttackModel.setup() sẽ đọc giá trị này.
@export var attack_damage: int = 10

# TODO 4: Thời gian hồi chiêu giữa 2 lần attack (giây).
@export var attack_cooldown: float = 0.5

# TODO 5: Sau khi có 4 biến trên, tạo file player_data.tres:
#   FileSystem -> chuột phải -> New Resource... -> PlayerData -> Save
#   rồi gán vào @export var data: PlayerData của player.gd (Inspector).
