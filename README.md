# Zenith Stock Premium - The Luxury Inventory Ecosystem

Chào mừng bạn đến với **Zenith Stock**, một hệ thống quản lý kho hàng được tái định nghĩa với triết lý thiết kế **"Luxury Noir"** và kiến trúc **5 Lớp (5-Layer Architecture)** siêu hạng. Không chỉ là một công cụ quản lý, Zenith Stock là một trải nghiệm thị giác đỉnh cao dành cho giới tinh hoa.


## Ngôn ngữ thiết kế: "Noir Art" & Glassmorphism
Zenith Stock loại bỏ những giao diện phẳng (flat design) nhàm chán để thay thế bằng:
- **Frosted Glass Panels**: Hiệu ứng thủy tinh mờ ảo kết hợp với `BackdropFilter` tạo chiều sâu vô tận.
- **Golden Gradients**: Các điểm nhấn mạ vàng tinh tế, mang lại cảm giác sang trọng và uy quyền.
- **Staggered Animations**: Hiệu ứng chuyển động "thác đổ", các phần tử lướt nhẹ nhàng vào vị trí khi bạn tương tác.
- **Luxury Product Plates**: Thẻ sản phẩm được thiết kế như những tấm bảng kim loại cao cấp với bóng đổ đa tầng.


## Kiến trúc Hệ thống: 5-Layer Pattern
Để đảm bảo tính bảo trì và mở rộng cấp độ doanh nghiệp, hệ thống được xây dựng trên 5 lớp tách biệt hoàn toàn:
1.  **View (Giao diện)**: Thuần UI, sử dụng Flutter & GetX.
2.  **Controller (Điều khiển)**: Quán lý trạng thái và phản hồi tương tác người dùng.
3.  **Binding (Hậu cần)**: Thiết lập Dependency Injection toàn diện.
4.  **Repository (Reposi)**: Xử lý logic nghiệp vụ và phối hợp dữ liệu.
5.  **Provider (Prosi)**: Tương tác trực tiếp với Supabase Cloud.


## Công nghệ Chủ chốt
- **Frontend**: Flutter (GetX, Google Fonts, Glassmorphism UI).
- **Backend**: FastAPI (Python) - Hiệu năng cao, bảo mật chặt chẽ.
- **Database**: Supabase Cloud (PostgreSQL, RLS Security).
- **Email Alert**: Tích hợp Resend.com cho thông báo tồn kho thấp.


## Hướng dẫn Triển khai nhanh

- Tải gói: `flutter pub get`.
- Chạy: `flutter run`.






---