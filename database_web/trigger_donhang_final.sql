-- Xóa trigger cũ trước
DROP TRIGGER IF EXISTS tr_donhang_status_update;

-- Tạo trigger mới với syntax đúng cho MariaDB
DELIMITER $$

CREATE TRIGGER tr_donhang_status_update 
AFTER UPDATE ON donhang 
FOR EACH ROW 
BEGIN
    -- Khai báo tất cả biến ở đầu
    DECLARE product_title VARCHAR(255) DEFAULT '';
    DECLARE product_image TEXT DEFAULT '';
    DECLARE product_price INT DEFAULT 0;
    DECLARE first_product_id VARCHAR(255) DEFAULT '';
    DECLARE notification_title VARCHAR(255) DEFAULT '';
    DECLARE notification_content TEXT DEFAULT '';
    DECLARE priority VARCHAR(20) DEFAULT 'medium';
    
    -- Chỉ tạo thông báo khi status thay đổi
    IF OLD.status != NEW.status THEN
        -- Lấy ID sản phẩm đầu tiên từ field sanpham
        SET first_product_id = SUBSTRING_INDEX(NEW.sanpham, ',', 1);
        
        -- Nếu không có dấu phẩy, lấy toàn bộ
        IF first_product_id = NEW.sanpham THEN
            SET first_product_id = NEW.sanpham;
        END IF;
        
        -- Lấy thông tin sản phẩm
        SELECT s.tieu_de, s.minh_hoa, s.gia 
        INTO product_title, product_image, product_price
        FROM sanpham s 
        WHERE s.id = CAST(first_product_id AS UNSIGNED)
        LIMIT 1;
        
        -- Nếu không tìm thấy sản phẩm, dùng thông tin mặc định
        IF product_title = '' THEN
            SET product_title = 'Sản phẩm';
            SET product_image = '';
            SET product_price = NEW.tongtien;
        END IF;
        
        -- Xác định nội dung thông báo chuyên nghiệp
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
        
        -- Tạo thông báo
        INSERT INTO notification_mobile (
            user_id, 
            type, 
            title, 
            content, 
            data, 
            related_id, 
            related_type, 
            priority, 
            is_read, 
            created_at
        ) VALUES (
            NEW.user_id,
            'order',
            notification_title,
            notification_content,
            CONCAT('{"order_id":', NEW.id, ',"order_code":"', NEW.ma_don, '","product_title":"', product_title, '","product_image":"', product_image, '","product_price":', product_price, ',"old_status":', OLD.status, ',"new_status":', NEW.status, ',"total_amount":', NEW.tongtien, '}'),
            NEW.id,
            'order',
            priority,
            0,
            UNIX_TIMESTAMP()
        );
    END IF;
END$$

DELIMITER ;
