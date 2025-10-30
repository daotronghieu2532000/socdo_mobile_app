-- ========================================
-- SỬA LỖI LẤY ẢNH SẢN PHẨM TRONG TRIGGER
-- ========================================
-- Vấn đề: Một số đơn hàng có product_image = "[{" thay vì đường dẫn ảnh
-- Nguyên nhân: Logic parse JSON không xử lý đúng các trường hợp khác nhau
-- Giải pháp: Cải thiện logic parse và fallback sang bảng sanpham

SET collation_connection = 'utf8_general_ci';

-- Xóa trigger cũ
DROP TRIGGER IF EXISTS tr_donhang_status_update;

-- ========================================
-- TRIGGER MỚI VỚI LOGIC XỬ LÝ ẢNH TỐT HƠN
-- ========================================
DELIMITER $$

CREATE TRIGGER tr_donhang_status_update 
AFTER UPDATE ON donhang 
FOR EACH ROW 
BEGIN
    DECLARE product_title VARCHAR(255) DEFAULT '';
    DECLARE product_image TEXT DEFAULT '';
    DECLARE product_price INT DEFAULT 0;
    DECLARE first_product_id VARCHAR(255) DEFAULT '';
    DECLARE notification_title VARCHAR(255) DEFAULT '';
    DECLARE notification_content TEXT DEFAULT '';
    DECLARE priority VARCHAR(20) DEFAULT 'medium';
    DECLARE temp_image TEXT DEFAULT '';
    DECLARE temp_id VARCHAR(20) DEFAULT '';
    
    IF OLD.status != NEW.status THEN
        -- BƯỚC 1: Lấy ID sản phẩm đầu tiên từ JSON
        -- Xử lý nhiều định dạng: {"1258": {...}} hoặc [{"id":5863,...}] hoặc {"5684_0": {...}}
        
        -- Thử format 1: Object với key là số ({"1258": {...}})
        IF NEW.sanpham LIKE '%":{%' THEN
            SET temp_id = SUBSTRING_INDEX(
                SUBSTRING_INDEX(NEW.sanpham, '":', 1), 
                '"', -1
            );
            -- Nếu temp_id chứa dấu gạch dưới (vd: "5684_0"), lấy phần trước
            IF LOCATE('_', temp_id) > 0 THEN
                SET first_product_id = SUBSTRING_INDEX(temp_id, '_', 1);
            ELSE
                SET first_product_id = temp_id;
            END IF;
        -- Thử format 2: Array ([{"id":5863,...}])
        ELSEIF NEW.sanpham LIKE '%[{%' AND NEW.sanpham LIKE '%"id":%' THEN
            SET first_product_id = SUBSTRING_INDEX(
                SUBSTRING_INDEX(NEW.sanpham, '"id":', 2), 
                '"id":', -1
            );
            SET first_product_id = SUBSTRING_INDEX(first_product_id, ',', 1);
            SET first_product_id = TRIM(BOTH ' ' FROM first_product_id);
        END IF;
        
        -- BƯỚC 2: Lấy thông tin từ JSON
        -- Lấy title
        IF NEW.sanpham LIKE '%"tieu_de":"%' THEN
            SET product_title = SUBSTRING_INDEX(
                SUBSTRING_INDEX(NEW.sanpham, '"tieu_de":"', 2), 
                '"tieu_de":"', -1
            );
            SET product_title = SUBSTRING_INDEX(product_title, '"', 1);
        END IF;
        
        -- Lấy ảnh - thử cả "minh_hoa" và "anh_chinh"
        SET temp_image = '';
        
        -- Thử "minh_hoa" trước
        IF NEW.sanpham LIKE '%"minh_hoa":"%' THEN
            SET temp_image = SUBSTRING_INDEX(
                SUBSTRING_INDEX(NEW.sanpham, '"minh_hoa":"', 2), 
                '"minh_hoa":"', -1
            );
            SET temp_image = SUBSTRING_INDEX(temp_image, '"', 1);
            
            -- Kiểm tra xem có hợp lệ không (không bắt đầu bằng [ hoặc {)
            IF temp_image NOT LIKE '[%' AND temp_image NOT LIKE '{%' AND temp_image != '' THEN
                SET product_image = temp_image;
            END IF;
        END IF;
        
        -- Nếu chưa có ảnh, thử "anh_chinh"
        IF (product_image = '' OR product_image IS NULL) AND NEW.sanpham LIKE '%"anh_chinh":"%' THEN
            SET temp_image = SUBSTRING_INDEX(
                SUBSTRING_INDEX(NEW.sanpham, '"anh_chinh":"', 2), 
                '"anh_chinh":"', -1
            );
            SET temp_image = SUBSTRING_INDEX(temp_image, '"', 1);
            
            IF temp_image NOT LIKE '[%' AND temp_image NOT LIKE '{%' AND temp_image != '' THEN
                SET product_image = temp_image;
            END IF;
        END IF;
        
        -- Lấy giá
        IF NEW.sanpham LIKE '%"gia_moi":"%' THEN
            SET temp_image = SUBSTRING_INDEX(
                SUBSTRING_INDEX(NEW.sanpham, '"gia_moi":"', 2), 
                '"gia_moi":"', -1
            );
            SET temp_image = SUBSTRING_INDEX(temp_image, '"', 1);
            SET temp_image = REPLACE(temp_image, ',', '');
            SET product_price = CAST(temp_image AS UNSIGNED);
        END IF;
        
        -- BƯỚC 3: Fallback - Nếu thiếu thông tin, join với bảng sanpham
        IF (product_title = '' OR product_image = '' OR product_price = 0) AND first_product_id != '' AND CAST(first_product_id AS UNSIGNED) > 0 THEN
            SELECT 
                s.tieu_de, 
                s.minh_hoa, 
                CAST(REPLACE(COALESCE(s.gia_moi, '0'), ',', '') AS UNSIGNED)
            INTO 
                product_title, 
                product_image, 
                product_price
            FROM sanpham s 
            WHERE s.id = CAST(first_product_id AS UNSIGNED)
            LIMIT 1;
            
            -- Nếu vẫn không có, dùng giá trị mặc định
            IF product_title = '' OR product_title IS NULL THEN
                SET product_title = 'Sản phẩm';
            END IF;
            
            IF product_image = '' OR product_image IS NULL THEN
                SET product_image = '';
            END IF;
            
            IF product_price = 0 OR product_price IS NULL THEN
                SET product_price = NEW.tongtien;
            END IF;
        END IF;
        
        -- Kiểm tra lại giá trị mặc định
        IF product_title = '' OR product_title IS NULL THEN
            SET product_title = 'Sản phẩm';
        END IF;
        
        IF product_image = '' OR product_image IS NULL OR product_image LIKE '[%' OR product_image LIKE '{%' THEN
            SET product_image = '';
        END IF;
        
        IF product_price = 0 OR product_price IS NULL THEN
            SET product_price = NEW.tongtien;
        END IF;
        
        -- Tạo nội dung thông báo
        CASE NEW.status
            WHEN 1 THEN
                SET notification_title = 'Đơn hàng đã được xác nhận';
                SET notification_content = CONCAT('Đơn hàng "', product_title, '" đã được xác nhận thành công. Chúng tôi sẽ chuẩn bị hàng và giao đến bạn sớm nhất. Cảm ơn bạn đã tin tưởng!');
                SET priority = 'medium';
            WHEN 2 THEN
                SET notification_title = 'Đơn hàng đang được giao';
                SET notification_content = CONCAT('Đơn hàng "', product_title, '" đang được giao hàng. Vui lòng chuẩn bị nhận hàng và thanh toán khi nhận được. Cảm ơn bạn!');
                SET priority = 'high';
            WHEN 3 THEN
                SET notification_title = 'Đơn hàng đã giao thành công';
                SET notification_content = CONCAT('Đơn hàng "', product_title, '" đã được giao thành công. Cảm ơn bạn đã mua sắm tại cửa hàng của chúng tôi!');
                SET priority = 'medium';
            WHEN 4 THEN
                SET notification_title = 'Đơn hàng đã bị hủy';
                SET notification_content = CONCAT('Rất tiếc, đơn hàng "', product_title, '" đã bị hủy. Nếu bạn có thắc mắc, vui lòng liên hệ với chúng tôi để được hỗ trợ.');
                SET priority = 'high';
            WHEN 5 THEN
                SET notification_title = 'Đơn hàng đã hoàn trả';
                SET notification_content = CONCAT('Đơn hàng "', product_title, '" đã được hoàn trả thành công. Số tiền sẽ được chuyển về tài khoản của bạn trong thời gian sớm nhất.');
                SET priority = 'high';
            ELSE
                SET notification_title = 'Cập nhật đơn hàng';
                SET notification_content = CONCAT('Đơn hàng "', product_title, '" đã được cập nhật trạng thái. Vui lòng kiểm tra chi tiết trong ứng dụng.');
        END CASE;
        
        -- Insert notification
        INSERT INTO notification_mobile (
            user_id, type, title, content, data, related_id, related_type, priority, is_read, created_at
        ) VALUES (
            NEW.user_id, 'order', notification_title, notification_content,
            CONCAT('{"order_id":', NEW.id, ',"order_code":"', NEW.ma_don, '","product_title":"', product_title, '","product_image":"', product_image, '","product_price":', product_price, ',"old_status":', OLD.status, ',"new_status":', NEW.status, ',"total_amount":', NEW.tongtien, '}'),
            NEW.id, 'order', priority, 0, UNIX_TIMESTAMP()
        );
    END IF;
END$$

DELIMITER ;

-- ========================================
-- KIỂM TRA KẾT QUẢ
-- ========================================
SHOW TRIGGERS LIKE 'tr_donhang_status_update';
SELECT 'Trigger đã được cập nhật với logic xử lý ảnh tốt hơn!' as 'Status';

