class_name CombatEventLog
extends Node   # TODO: xác nhận lại — Node hay RefCounted? (xem phần Báo cáo bên dưới)

# TODO: cấu trúc lưu lịch sử damage — CHƯA được tài liệu định nghĩa cụ thể,
# đây là đề xuất dựa trên nguyên tắc "Log nhấn mạnh việc lưu lại lịch sử":
# var log_entries: Array = []   # mỗi phần tử là 1 record: source, target, amount, timestamp

# TODO: hàm add_damage(source, target, amount) — được gọi khi cần lưu 1 DamageEvent vào lịch sử
# func add_damage(source, target, amount: int) -> void:
#     - tạo 1 record (dictionary hoặc class riêng) gồm source/target/amount/timestamp
#     - append vào log_entries
#     - (tuỳ chọn) print() hoặc giới hạn số lượng entry tối đa để tránh phình bộ nhớ

# TODO (tuỳ chọn, chưa bắt buộc ở MVP): hàm truy vấn lại log
# func get_log() -> Array:
#     - return log_entries

# Lưu ý khi code thật:
# - KHÔNG xử lý logic trừ HP ở đây — đó là việc của HealthComponent.
# - Đây là hệ thống RIÊNG, chỉ ghi lại, không quyết định gameplay.
# - Cần quyết định: log này được EventSystem gọi tự động mỗi khi có DamageEvent,
#   hay Controller chủ động gọi add_damage() sau khi damage đã xử lý xong?
