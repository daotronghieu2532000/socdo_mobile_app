-- ========================================
-- SỬA LỖI COLLATION CHO TẤT CẢ TRIGGER
-- ========================================

-- Xóa tất cả trigger cũ
DROP TRIGGER IF EXISTS tr_donhang_status_update;
DROP TRIGGER IF EXISTS tr_lichsu_chitieu_insert;
DROP TRIGGER IF EXISTS tr_coupon_insert;
DROP TRIGGER IF EXISTS tr_sanpham_aff_insert;

-- ========================================
-- 1. TRIGGER CHO BẢNG DONHANG (Đơn hàng)
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
    
    IF OLD.status != NEW.status THEN
        -- Lấy ID sản phẩm đầu tiên từ JSON trong field sanpham
        SET first_product_id = '';
        
        -- Parse JSON để lấy ID sản phẩm đầu tiên
        SET first_product_id = SUBSTRING_INDEX(
            SUBSTRING_INDEX(NEW.sanpham, '":', 1), 
            '"', -1
        );
        
        -- Lấy thông tin sản phẩm từ JSON
        SET product_title = SUBSTRING_INDEX(
            SUBSTRING_INDEX(NEW.sanpham, '"tieu_de":"', 2), 
            '"tieu_de":"', -1
        );
        SET product_title = SUBSTRING_INDEX(product_title, '"', 1);
        
        SET product_image = SUBSTRING_INDEX(
            SUBSTRING_INDEX(NEW.sanpham, '"minh_hoa":"', 2), 
            '"minh_hoa":"', -1
        );
        SET product_image = SUBSTRING_INDEX(product_image, '"', 1);
        
        SET product_price = SUBSTRING_INDEX(
            SUBSTRING_INDEX(NEW.sanpham, '"gia_moi":"', 2), 
            '"gia_moi":"', -1
        );
        SET product_price = SUBSTRING_INDEX(product_price, '"', 1);
        SET product_price = REPLACE(product_price, ',', '');
        SET product_price = CAST(product_price AS UNSIGNED);
        
        -- Tạo nội dung thông báo với COLLATE utf8_general_ci
        CASE NEW.status
            WHEN 1 THEN
                SET notification_title = 'Đơn hàng đã được xác nhận' COLLATE utf8_general_ci;
                SET notification_content = CONCAT('Đơn hàng "', product_title COLLATE utf8_general_ci, '" đã được xác nhận thành công. Chúng tôi sẽ chuẩn bị hàng và giao đến bạn sớm nhất. Cảm ơn bạn đã tin tưởng!') COLLATE utf8_general_ci;
                SET priority = 'medium';
            WHEN 2 THEN
                SET notification_title = 'Đơn hàng đang được giao' COLLATE utf8_general_ci;
                SET notification_content = CONCAT('Đơn hàng "', product_title COLLATE utf8_general_ci, '" đang được giao hàng. Vui lòng chuẩn bị nhận hàng và thanh toán khi nhận được. Cảm ơn bạn!') COLLATE utf8_general_ci;
                SET priority = 'high';
            WHEN 3 THEN
                SET notification_title = 'Đơn hàng đã giao thành công' COLLATE utf8_general_ci;
                SET notification_content = CONCAT('Đơn hàng "', product_title COLLATE utf8_general_ci, '" đã được giao thành công. Cảm ơn bạn đã mua sắm tại cửa hàng của chúng tôi!') COLLATE utf8_general_ci;
                SET priority = 'medium';
            WHEN 4 THEN
                SET notification_title = 'Đơn hàng đã bị hủy' COLLATE utf8_general_ci;
                SET notification_content = CONCAT('Rất tiếc, đơn hàng "', product_title COLLATE utf8_general_ci, '" đã bị hủy. Nếu bạn có thắc mắc, vui lòng liên hệ với chúng tôi để được hỗ trợ.') COLLATE utf8_general_ci;
                SET priority = 'high';
            WHEN 5 THEN
                SET notification_title = 'Đơn hàng đã hoàn trả' COLLATE utf8_general_ci;
                SET notification_content = CONCAT('Đơn hàng "', product_title COLLATE utf8_general_ci, '" đã được hoàn trả thành công. Số tiền sẽ được chuyển về tài khoản của bạn trong thời gian sớm nhất.') COLLATE utf8_general_ci;
                SET priority = 'high';
            ELSE
                SET notification_title = 'Cập nhật đơn hàng' COLLATE utf8_general_ci;
                SET notification_content = CONCAT('Đơn hàng "', product_title COLLATE utf8_general_ci, '" đã được cập nhật trạng thái. Vui lòng kiểm tra chi tiết trong ứng dụng.') COLLATE utf8_general_ci;
        END CASE;
        
        -- Insert notification với COLLATE utf8_general_ci
        INSERT INTO notification_mobile (
            user_id, type, title, content, data, related_id, related_type, priority, is_read, created_at
        ) VALUES (
            NEW.user_id, 'order', 
            notification_title COLLATE utf8_general_ci,
            notification_content COLLATE utf8_general_ci,
            CONCAT('{"order_id":', NEW.id, ',"order_code":"', NEW.ma_don, '","product_title":"', product_title COLLATE utf8_general_ci, '","product_image":"', product_image COLLATE utf8_general_ci, '","product_price":', product_price, ',"old_status":', OLD.status, ',"new_status":', NEW.status, ',"total_amount":', NEW.tongtien, '}') COLLATE utf8_general_ci,
            NEW.id, 'order', priority, 0, UNIX_TIMESTAMP()
        );
    END IF;
END$$

-- ========================================
-- 2. TRIGGER CHO BẢNG LICHSU_CHITIEU (Nạp/Rút tiền)
-- ========================================
CREATE TRIGGER tr_lichsu_chitieu_insert 
AFTER INSERT ON lichsu_chitieu 
FOR EACH ROW 
BEGIN
    DECLARE notification_title VARCHAR(255) DEFAULT '';
    DECLARE notification_content TEXT DEFAULT '';
    DECLARE notification_type VARCHAR(50) DEFAULT '';
    DECLARE priority VARCHAR(20) DEFAULT 'medium';
    
    IF NEW.noidung LIKE '%nạp%' OR NEW.noidung LIKE '%deposit%' THEN
        SET notification_title = 'Nạp tiền thành công' COLLATE utf8_general_ci;
        SET notification_content = CONCAT('Chúc mừng! Bạn đã nạp thành công ', FORMAT(NEW.sotien, 0), '₫ vào tài khoản. Số dư hiện tại đã được cập nhật. Cảm ơn bạn!') COLLATE utf8_general_ci;
        SET notification_type = 'deposit' COLLATE utf8_general_ci;
        SET priority = 'medium';
        
        INSERT INTO notification_mobile (
            user_id, type, title, content, data, related_id, related_type, priority, is_read, created_at
        ) VALUES (
            NEW.user_id, notification_type COLLATE utf8_general_ci, notification_title COLLATE utf8_general_ci, notification_content COLLATE utf8_general_ci,
            CONCAT('{"amount":', NEW.sotien, ',"method":"Chuyển khoản","transaction_type":"deposit","balance_after":', NEW.sotien, '}') COLLATE utf8_general_ci,
            NEW.id, 'transaction', priority, 0, UNIX_TIMESTAMP()
        );
        
    ELSEIF NEW.noidung LIKE '%rút%' OR NEW.noidung LIKE '%withdrawal%' THEN
        SET notification_title = 'Yêu cầu rút tiền đã được gửi' COLLATE utf8_general_ci;
        SET notification_content = CONCAT('Yêu cầu rút ', FORMAT(NEW.sotien, 0), '₫ của bạn đã được gửi thành công. Chúng tôi sẽ xử lý trong thời gian sớm nhất và thông báo lại cho bạn. Cảm ơn!') COLLATE utf8_general_ci;
        SET notification_type = 'withdrawal' COLLATE utf8_general_ci;
        SET priority = 'medium';
        
        INSERT INTO notification_mobile (
            user_id, type, title, content, data, related_id, related_type, priority, is_read, created_at
        ) VALUES (
            NEW.user_id, notification_type COLLATE utf8_general_ci, notification_title COLLATE utf8_general_ci, notification_content COLLATE utf8_general_ci,
            CONCAT('{"amount":', NEW.sotien, ',"status":"pending","method":"Chuyển khoản","transaction_type":"withdrawal","estimated_time":"1-3 ngày làm việc"}') COLLATE utf8_general_ci,
            NEW.id, 'transaction', priority, 0, UNIX_TIMESTAMP()
        );
    END IF;
END$$

-- ========================================
-- 3. TRIGGER CHO BẢNG COUPON (Voucher mới)
-- ========================================
CREATE TRIGGER tr_coupon_insert 
AFTER INSERT ON coupon 
FOR EACH ROW 
BEGIN
    INSERT INTO notification_mobile (
        user_id, type, title, content, data, related_id, related_type, priority, is_read, created_at
    ) 
    SELECT 
        u.user_id, 
        'voucher_new' COLLATE utf8_general_ci,
        CONCAT('Voucher mới: ', NEW.ma COLLATE utf8_general_ci) COLLATE utf8_general_ci,
        CONCAT('🎉 Tin vui! Bạn có voucher mới "', NEW.ma COLLATE utf8_general_ci, '" giảm ', FORMAT(NEW.giam, 0), '₫. Hạn sử dụng đến ', DATE_FORMAT(FROM_UNIXTIME(NEW.expired), '%d/%m/%Y'), '. Đừng bỏ lỡ cơ hội tiết kiệm này nhé!') COLLATE utf8_general_ci,
        CONCAT('{"voucher_code":"', NEW.ma COLLATE utf8_general_ci, '","discount_amount":', NEW.giam, ',"expired_date":', NEW.expired, ',"shop_id":', NEW.shop, ',"min_order":', IFNULL(NEW.dieu_kien, 0), '}') COLLATE utf8_general_ci,
        NEW.id, 'coupon', 'medium', 0, UNIX_TIMESTAMP()
    FROM user_info u 
    WHERE u.shop = NEW.shop AND u.active = 1;
END$$

-- ========================================
-- 4. TRIGGER CHO BẢNG SANPHAM_AFF (Affiliate)
-- ========================================
CREATE TRIGGER tr_sanpham_aff_insert 
AFTER INSERT ON sanpham_aff 
FOR EACH ROW 
BEGIN
    INSERT INTO notification_mobile (
        user_id, type, title, content, data, related_id, related_type, priority, is_read, created_at
    ) 
    SELECT 
        u.user_id, 
        'affiliate_order' COLLATE utf8_general_ci,
        CONCAT('Sản phẩm affiliate mới: ', NEW.tieu_de COLLATE utf8_general_ci) COLLATE utf8_general_ci,
        CONCAT('💰 Cơ hội kiếm tiền mới! Sản phẩm "', NEW.tieu_de COLLATE utf8_general_ci, '" đã được thêm vào chương trình affiliate với hoa hồng hấp dẫn. Hãy chia sẻ ngay để kiếm thêm thu nhập nhé!') COLLATE utf8_general_ci,
        CONCAT('{"product_title":"', NEW.tieu_de COLLATE utf8_general_ci, '","shop_id":', NEW.shop, ',"date_start":', NEW.date_start, ',"date_end":', NEW.date_end, ',"commission_rate":"10%"}') COLLATE utf8_general_ci,
        NEW.id, 'affiliate_product', 'high', 0, UNIX_TIMESTAMP()
    FROM user_info u 
    WHERE u.aff = '1' AND u.active = 1;
END$$

DELIMITER ;

-- ========================================
-- HOÀN THÀNH SỬA COLLATION
-- ========================================
