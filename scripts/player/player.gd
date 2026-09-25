# =============================================================================
# player.gd
# -----------------------------------------------------------------------------
# Vai trò: Coordinator (MVP) — theo "Technical Architecture" mục 6.1
#   -> player.gd là bộ não trung tâm: nhận Input, kiểm tra State,
#      gọi trực tiếp movement()/attack()/take_damage()/die(), cập nhật Node.
#   -> KHÔNG tách controller/ + model/ cho tới khi đạt điều kiện mục 6.2
#      (file > 200-300 dòng khó điều hướng, hoặc logic cần tái sử dụng ở entity khác).
#
# Vai trò dữ liệu/giao tiếp: theo "Tổng hợp chi tiết .gd/.tres/Event" mục 13-21
#   -> Player đọc thông số cấu hình từ PlayerData (.tres), không hard-code số.
#   -> Player KHÔNG bị Enemy gọi trực tiếp take_damage(); Player tự nhận
#      DamageEvent qua EventSystem rồi mới gọi HealthComponent.take_damage().
#   -> Player KHÔNG tự gọi die(); HealthComponent phát signal "died",
#      Player chỉ lắng nghe và phản ứng.
# =============================================================================

class_name Player
extends CharacterBody2D
const SPEED = 150.0


# -----------------------------------------------------------------------------
# STATE — theo Technical Architecture mục 7 (State Management)
# -----------------------------------------------------------------------------
# TODO: Khai báo enum State: IDLE, MOVING, ATTACKING, HURT, DEAD
#   - Dùng để chặn hành vi xung đột, ví dụ khi DEAD thì không cho Movement/Attack.
# TODO: Khai báo biến var current_state: State = State.IDLE
# TODO: (tuỳ chọn) hàm set_state(new_state) -> void để đổi state có kiểm soát
#   thay vì gán current_state trực tiếp ở nhiều chỗ.


# -----------------------------------------------------------------------------
# DATA (Resource) — theo Tổng hợp chi tiết mục 8-9, 14
# -----------------------------------------------------------------------------
# TODO: @export var data: PlayerData
#   - PlayerData là Resource (.gd riêng, xem player_data.gd) chứa các thông số
#     cấu hình: max_health, max_stamina, attack_damage, move_speed...
#   - Gán player_data.tres vào biến này trong Inspector.
#   - Player chỉ ĐỌC data.xxx, KHÔNG hard-code số liệu trong player.gd.


# -----------------------------------------------------------------------------
# NODE REFERENCES — theo Technical Architecture mục 4 (Scene/Node - Player)
# -----------------------------------------------------------------------------
# TODO: @onready var sprite: Sprite2D = $Sprite2D
# TODO: @onready var collision_shape: CollisionShape2D = $CollisionShape2D
# TODO: @onready var animation_player: AnimationPlayer = get_node_or_null("AnimationPlayer")
#   - Dùng get_node_or_null + validate ở _ready() theo mục 12 (Error Handling)
# TODO: @onready var attack_area: Area2D = $AttackArea
#   - AttackArea: phát hiện enemy khi tấn công (Technical Architecture mục 4)
# TODO: @onready var camera: Camera2D = $Camera2D
# TODO: @onready var health: HealthComponent = $HealthComponent
#   - HealthComponent xử lý HP, xem health_component.gd (Tổng hợp chi tiết mục 10)


# -----------------------------------------------------------------------------
# LIFECYCLE — _ready()
# -----------------------------------------------------------------------------
func _ready() -> void:
	# TODO: Validate các @onready node quan trọng (animation_player, health...);
	#   nếu null thì push_error() theo mẫu ở Technical Architecture mục 12.
	# TODO: health.setup(data.max_health)
	#   - Khởi tạo current_health = max_health lấy từ PlayerData (.tres)
	#     (Tổng hợp chi tiết mục 13-14).
	# TODO: EventSystem.damage_event_created.connect(_on_damage_event)
	#   - Đăng ký lắng nghe DamageEvent để Player tự kiểm tra event.target
	#     (Tổng hợp chi tiết mục 11-12, 16-17). KHÔNG để Enemy gọi
	#     Player.take_damage() trực tiếp.
	# TODO: health.died.connect(_on_died)
	#   - Player không tự gọi die(); chỉ lắng nghe signal "died" từ
	#     HealthComponent (Tổng hợp chi tiết mục 18).
	pass


# -----------------------------------------------------------------------------
# INPUT / PHYSICS PROCESS
# -----------------------------------------------------------------------------
# TODO: func _physics_process(delta: float) -> void:
#   - Đọc input WASD/Vector2 (Checklist thực hành Player, Technical Architecture mục 18)
#   - Kiểm tra current_state (nếu DEAD/ATTACKING thì không cho di chuyển tuỳ thiết kế)
#   - Gọi movement(input_direction) để lấy velocity, rồi move_and_slide()
#   - Cập nhật current_state = State.MOVING / State.IDLE tương ứng
#   - Gọi update_animation() (nếu có) để đồng bộ animation với state
	pass


# -----------------------------------------------------------------------------
# MOVEMENT — nguyên tắc "1 Input -> 1 Output -> 1 Return" (mục 5)
# -----------------------------------------------------------------------------
# TODO: func movement(input_direction: Vector2) -> Vector2:
#   - 1 input (input_direction), xử lý nội bộ, 1 biến output, đúng 1 return.
#   - output = input_direction.normalized() * data.move_speed
#   - KHÔNG hard-code move_speed; lấy từ data.move_speed (PlayerData .tres).
func _physics_process(delta: float) -> void:
	# Lấy hướng di chuyển từ 4 action đã tạo (trả về Vector2, đã tự chuẩn hóa)
	var input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	velocity = input_direction * SPEED
	move_and_slide()

	# Đổi hướng nhìn của sprite theo hướng di chuyển (tùy chọn, xóa nếu chưa cần)
	if input_direction.x != 0:
		$Sprite2D.flip_h = input_direction.x < 0
	pass


# -----------------------------------------------------------------------------
# ATTACK — theo mục 6.1, 8, 9, 13 (Technical Architecture)
# -----------------------------------------------------------------------------
# TODO: func attack() -> bool:
#   - Kiểm tra current_state có cho phép attack không (không attack khi DEAD/HURT...)
#   - Phát animation attack (animation_player.play("attack") có validate null)
#   - Xác định enemy/target trong AttackArea (get_overlapping_bodies()...)
#   - Với mỗi target hợp lệ: tạo DamageEvent(self, target, data.attack_damage)
#     rồi EventSystem.send_damage(event) — KHÔNG gọi target.take_damage() trực tiếp
#     (Tổng hợp chi tiết mục 15, 22: "Player gọi Enemy.take_damage()" là điều KHÔNG nên làm).
#   - output: true nếu attack được kích hoạt hợp lệ, false nếu không.
#   - Đây là "1 Input -> 1 Output -> 1 Return": input ngầm là state/target hiện tại,
#     output là bool.
	pass


# -----------------------------------------------------------------------------
# NHẬN DAMAGE QUA EVENT — theo Tổng hợp chi tiết mục 16-17
# -----------------------------------------------------------------------------
# TODO: func _on_damage_event(event: DamageEvent) -> void:
#   - if event.target != self: return   (Player chỉ phản ứng Event dành cho mình)
#   - health.take_damage(event.amount)
#   - (tuỳ chọn) đổi current_state = State.HURT, phát animation "hurt"
#   - HealthComponent tự lo việc trừ HP và phát signal health_changed/died;
#     player.gd KHÔNG tự trừ current_health ở đây (tránh trùng logic).
	pass


# -----------------------------------------------------------------------------
# DIE — Player không tự gọi die(), chỉ phản ứng signal "died" (mục 18)
# -----------------------------------------------------------------------------
# TODO: func _on_died() -> void:
#   - current_state = State.DEAD
#   - Vô hiệu hoá input/collision/attack theo thiết kế
#   - Phát animation "die" (validate animation_player trước khi play)
#   - print("Player died") hoặc gọi thêm logic game-over/respawn nếu cần
	pass


# -----------------------------------------------------------------------------
# ANIMATION HELPER — theo mục 12 (Error Handling) + kết nối animation với State
# -----------------------------------------------------------------------------
# TODO: func update_animation() -> void:  (hoặc play_xxx_animation() riêng lẻ)
#   - Validate animation_player == null trước, push_error() nếu thiếu
#     (đúng mẫu play_attack_animation() ở Technical Architecture mục 12).
#   - Chọn animation theo current_state (idle/move/attack/hurt/die).
	pass


# -----------------------------------------------------------------------------
# GHI CHÚ / CHECKLIST TRƯỚC KHI COI FILE NÀY LÀ XONG (đối chiếu 2 tài liệu)
# -----------------------------------------------------------------------------
# [ ] Mỗi function có đúng 1 input logic, 1 output rõ ràng, 1 return duy nhất.
# [ ] player.gd chỉ đóng vai trò Coordinator — không tự chứa logic tính damage
#     phức tạp (đó là việc của AttackModel/HealthComponent khi cần tách).
# [ ] Player không gọi Enemy.take_damage() trực tiếp — luôn qua DamageEvent + EventSystem.
# [ ] Player không tự trừ HP hay tự gọi die() — luôn qua HealthComponent + signal.
# [ ] Có validate cho các @onready node (animation_player, health...) kèm push_error().
# [ ] State được cập nhật nhất quán, tránh hành vi xung đột (attack khi đang DEAD...).
# [ ] Nếu file này vượt ~200-300 dòng hoặc logic cần tái sử dụng ở entity khác
#     (Enemy/Dinosaur) -> cân nhắc tách PlayerController + PlayerAttackModel
#     theo Technical Architecture mục 6.2 (không tách sớm khi chưa cần).
