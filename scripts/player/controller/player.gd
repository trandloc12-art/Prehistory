class_name Player
extends CharacterBody2D

# ==========================================================================
# player.gd — COORDINATOR
# (Technical Architecture, mục 6.1: giai đoạn MVP, player.gd là Coordinator
#  duy nhất — nhận Input, kiểm tra State, gọi Model, cập nhật Node)
#
# QUY TẮC:
# - File này KHÔNG chứa logic tính toán chi tiết (damage, velocity...).
#   Logic đó nằm trong các Model riêng, thư mục model/
#   (movement.gd, attack.gd, health.gd).
# - Model KHÔNG được gọi ngược lại file này.
# - Chỉ tách thêm controller/ khi player.gd > 200-300 dòng hoặc logic cần
#   tái sử dụng ở nơi khác (xem Technical Architecture mục 6.2).
#
# GHI CHÚ TẠM THỜI (giai đoạn hiện tại — chỉ làm movement trước):
# - attack_area và health CHƯA có Node tương ứng trong player.tscn.
# - Dùng get_node_or_null() thay vì $NodeName để KHÔNG bị lỗi
#   "Node not found" khi Node chưa tồn tại.
# - Mọi chỗ dùng health/attack_area đều có "if health:" / "if attack_area:"
#   bọc ngoài — khi nào bạn thêm Node thật vào scene, code sẽ TỰ chạy tiếp,
#   không cần sửa gì thêm ở đây.
# ==========================================================================

# --- Resource / Data (xem doc Player_Enemy mục 8-9) ---
@export var data: PlayerData
# TODO 0: tạo PlayerData resource class (player_data.gd, extends Resource)
#         chứa @export var max_health, move_speed, attack_damage...
#         rồi tạo player_data.tres và gán vào biến `data` trong Inspector.
#         (BẮT BUỘC phải gán, nếu không _ready() sẽ lỗi Nil ở move_speed)

# --- Node references (xem Technical Architecture mục 4) ---
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = get_node_or_null("AnimationPlayer")
# TODO 0b: attack_area/health CHƯA gắn trong scene — dùng get_node_or_null
#          để tránh lỗi "Node not found", trả về null nếu chưa có.
@onready var attack_area: Area2D = get_node_or_null("AttackArea")
@onready var camera: Camera2D = $Camera2D
@onready var health: PlayerHealthModel = get_node_or_null("PlayerHealthModel")

# --- Models (logic thuần túy, KHÔNG phải Node — RefCounted) ---
var movement_model: PlayerMovementModel
var attack_model: PlayerAttackModel

# --- State (Technical Architecture mục 7) ---
enum State {IDLE, MOVING, ATTACKING, HURT, DEAD}
var current_state: State = State.IDLE


func _ready() -> void:
	# TODO 1: khởi tạo movement_model = PlayerMovementModel.new()
	movement_model = PlayerMovementModel.new()
	movement_model.setup(data.move_speed)

	# TODO 2: khởi tạo attack_model = PlayerAttackModel.new()
	#         (tạm thời để dành, chưa setup() vì chưa cần dùng attack)
	attack_model = PlayerAttackModel.new()

	# TODO 3: health.setup(data.max_health)
	#         Bọc "if health:" vì PlayerHealthModel CHƯA gắn vào scene.
	#         Khi bạn thêm Node PlayerHealthModel vào player.tscn, dòng
	#         này sẽ TỰ chạy mà không cần sửa gì.
	if health:
		health.setup(data.max_health)
		# TODO 4: health.died.connect(_on_died)
		health.died.connect(_on_died)
	else:
		print("Player._ready(): health chưa gắn Node, bỏ qua setup (tạm thời).")

	# TODO 5 (nếu dùng kiến trúc Event toàn cục):
	#         EventSystem.damage_event_created.connect(_on_damage_event)
	#         Tạm thời COMMENT vì EventSystem (autoload) có thể chưa được
	#         tạo/đăng ký. Bỏ comment dòng dưới khi đã có EventSystem.
	# EventSystem.damage_event_created.connect(_on_damage_event)


func _physics_process(_delta: float) -> void:
	# TODO 6: nếu current_state == State.DEAD -> return (không xử lý gì thêm)
	if current_state == State.DEAD:
		return

	# TODO 7: gọi movement()
	movement()

	# TODO 8: move_and_slide()
	move_and_slide()


# --------------------------------------------------------------------
# movement()
# --------------------------------------------------------------------
func movement() -> void:
	# 1 Input → 1 Output → 1 Return (Technical Architecture mục 5)
	# TODO 9: input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var input_direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# TODO 10: velocity = movement_model.calculate_movement(input_direction)
	velocity = movement_model.calculate_movement(input_direction)
	# TODO 11: cập nhật current_state:
	#          - velocity != Vector2.ZERO -> State.MOVING
	#          - ngược lại -> State.IDLE
	#          (chỉ cập nhật nếu state hiện tại không phải ATTACKING/HURT/DEAD)
	if current_state in [State.ATTACKING, State.HURT, State.DEAD]:
		return

	if velocity != Vector2.ZERO:
		current_state = State.MOVING
	else:
		current_state = State.IDLE


# --------------------------------------------------------------------
# attack()  — TẠM THỜI CHƯA DÙNG (chưa gắn AttackArea trong scene)
# --------------------------------------------------------------------
func attack() -> bool:
	# 1 Input → 1 Output → 1 Return
	var output := false

	# TODO 12: kiểm tra State: nếu DEAD/HURT/đang ATTACKING -> return false ngay
	if current_state in [State.DEAD, State.HURT, State.ATTACKING]:
		return output

	# TODO: guard attack_area chưa gắn Node -> chưa cho attack chạy thật
	if attack_area == null:
		print("Player.attack(): attack_area chưa gắn Node, bỏ qua (tạm thời).")
		return output

	# TODO 13: output = attack_model.attack()  (Model kiểm tra điều kiện + trả bool)
	# TODO 14: nếu output == true:
	#          - damage := attack_model.calculate_damage()
	#          - tạo DamageEvent(self, target, damage)  (xem Technical Architecture mục 8-9)
	#          - EventSystem.send_damage(event)  -- KHÔNG gọi trực tiếp enemy.take_damage()
	#          - current_state = State.ATTACKING
	#          - animation_player.play("attack")
	return output


# --------------------------------------------------------------------
# take_damage()  — TẠM THỜI CHƯA DÙNG (chưa gắn PlayerHealthModel trong scene)
# --------------------------------------------------------------------
func take_damage(amount: int) -> void:
	# TODO 15: forward amount cho health.take_damage(amount)
	#          (Player KHÔNG tự trừ HP ở đây — logic trừ HP nằm trong
	#           PlayerHealthModel, xem doc Player_Enemy mục 10 & 17)
	if health == null:
		print("Player.take_damage(): health chưa gắn Node, bỏ qua (tạm thời).")
		return

	health.take_damage(amount)

	# TODO 16: nếu health.current_health > 0 -> current_state = State.HURT
	#          (State.DEAD sẽ được set trong _on_died(), không set ở đây)
	if health.current_health > 0:
		current_state = State.HURT


func _on_damage_event(event) -> void:
	# Dùng khi có EventSystem toàn cục (Technical Architecture mục 9, 11)
	# TODO 17: if event.target != self: return
	if event.target != self:
		return
	# TODO 18: take_damage(event.amount)
	take_damage(event.amount)


# --------------------------------------------------------------------
# die()  — TẠM THỜI CHƯA DÙNG (chưa gắn PlayerHealthModel trong scene)
# --------------------------------------------------------------------
func die() -> void:
	# LƯU Ý: hàm này KHÔNG nên bị gọi trực tiếp từ chỗ khác trong code.
	# Nó chỉ nên được gọi từ _on_died(), vốn được kích hoạt qua signal
	# health.died (xem doc Player_Enemy mục 18).
	# TODO 19: current_state = State.DEAD
	current_state = State.DEAD
	# TODO 20: animation_player.play("death")  (nếu có animation chết)
	if animation_player and animation_player.has_animation("death"):
		animation_player.play("death")
	# TODO 21: disable input / disable collision_shape nếu cần
	collision_shape.set_deferred("disabled", true)
	# TODO 22: set_physics_process(false)  (dừng xử lý movement/attack)
	set_physics_process(false)


func _on_died() -> void:
	# Callback được HealthComponent gọi qua signal `died` khi HP <= 0
	# TODO 23: die()
	die()
