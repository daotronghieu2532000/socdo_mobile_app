-- ========================================
-- XÓA TẤT CẢ TRIGGER CŨ TRƯỚC KHI TẠO MỚI
-- ========================================
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
        
        -- Tìm ID đầu tiên trong JSON array
        SET first_product_id = SUBSTRING_INDEX(
            SUBSTRING_INDEX(
                SUBSTRING_INDEX(NEW.sanpham, '"id":', 2), 
                ',', 1
            ), 
            '"id":', -1
        );
        
        -- Lấy thông tin sản phẩm
        SELECT s.tieu_de, s.minh_hoa, s.gia_moi 
        INTO product_title, product_image, product_price
        FROM sanpham s 
        WHERE s.id = CAST(first_product_id AS UNSIGNED)
        LIMIT 1;
        
        IF product_title = '' THEN
            SET product_title = 'Sản phẩm';
            SET product_image = '';
            SET product_price = NEW.tongtien;
        END IF;
        
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
-- 2. TRIGGER CHO BẢNG LICHSU_CHITIEU (Nạp/Rút tiền)
-- ========================================
DELIMITER $$

CREATE TRIGGER tr_lichsu_chitieu_insert 
AFTER INSERT ON lichsu_chitieu 
FOR EACH ROW 
BEGIN
    DECLARE notification_title VARCHAR(255) DEFAULT '';
    DECLARE notification_content TEXT DEFAULT '';
    DECLARE notification_type VARCHAR(50) DEFAULT '';
    DECLARE priority VARCHAR(20) DEFAULT 'medium';
    
    IF NEW.noidung LIKE '%nạp%' OR NEW.noidung LIKE '%deposit%' THEN
        SET notification_title = 'Nạp tiền thành công';
        SET notification_content = CONCAT('Chúc mừng! Bạn đã nạp thành công ', FORMAT(NEW.sotien, 0), '₫ vào tài khoản. Số dư hiện tại đã được cập nhật. Cảm ơn bạn!');
        SET notification_type = 'deposit';
        SET priority = 'medium';
        
        INSERT INTO notification_mobile (
            user_id, type, title, content, data, related_id, related_type, priority, is_read, created_at
        ) VALUES (
            NEW.user_id, notification_type, notification_title, notification_content,
            CONCAT('{"amount":', NEW.sotien, ',"method":"Chuyển khoản","transaction_type":"deposit","balance_after":', NEW.sotien, '}'),
            NEW.id, 'transaction', priority, 0, UNIX_TIMESTAMP()
        );
        
    ELSEIF NEW.noidung LIKE '%rút%' OR NEW.noidung LIKE '%withdrawal%' THEN
        SET notification_title = 'Yêu cầu rút tiền đã được gửi';
        SET notification_content = CONCAT('Yêu cầu rút ', FORMAT(NEW.sotien, 0), '₫ của bạn đã được gửi thành công. Chúng tôi sẽ xử lý trong thời gian sớm nhất và thông báo lại cho bạn. Cảm ơn!');
        SET notification_type = 'withdrawal';
        SET priority = 'medium';
        
        INSERT INTO notification_mobile (
            user_id, type, title, content, data, related_id, related_type, priority, is_read, created_at
        ) VALUES (
            NEW.user_id, notification_type, notification_title, notification_content,
            CONCAT('{"amount":', NEW.sotien, ',"status":"pending","method":"Chuyển khoản","transaction_type":"withdrawal","estimated_time":"1-3 ngày làm việc"}'),
            NEW.id, 'transaction', priority, 0, UNIX_TIMESTAMP()
        );
    END IF;
END$$

DELIMITER ;

-- ========================================
-- 3. TRIGGER CHO BẢNG COUPON (Voucher)
-- ========================================
DELIMITER $$

CREATE TRIGGER tr_coupon_insert 
AFTER INSERT ON coupon 
FOR EACH ROW 
BEGIN
    INSERT INTO notification_mobile (
        user_id, type, title, content, data, related_id, related_type, priority, is_read, created_at
    )
    SELECT 
        u.user_id, 'voucher_new', CONCAT('Voucher mới: ', NEW.ma),
        CONCAT('🎉 Tin vui! Bạn có voucher mới "', NEW.ma, '" giảm ', FORMAT(NEW.giam, 0), '₫. Hạn sử dụng đến ', DATE_FORMAT(FROM_UNIXTIME(NEW.expired), '%d/%m/%Y'), '. Đừng bỏ lỡ cơ hội tiết kiệm này nhé!'),
        CONCAT('{"voucher_code":"', NEW.ma, '","discount_amount":', NEW.giam, ',"expired_date":', NEW.expired, ',"shop_id":', NEW.shop, ',"min_order":', IFNULL(NEW.dieu_kien, 0), '}'),
        NEW.id, 'coupon', 'medium', 0, UNIX_TIMESTAMP()
    FROM user_info u 
    WHERE u.shop = NEW.shop AND u.active = 1;
END$$

DELIMITER ;

-- ========================================
-- 4. TRIGGER CHO BẢNG SANPHAM_AFF (Affiliate)
-- ========================================
DELIMITER $$

CREATE TRIGGER tr_sanpham_aff_insert 
AFTER INSERT ON sanpham_aff 
FOR EACH ROW 
BEGIN
    INSERT INTO notification_mobile (
        user_id, type, title, content, data, related_id, related_type, priority, is_read, created_at
    )
    SELECT 
        u.user_id, 'affiliate_order', CONCAT('Sản phẩm Affiliate mới: ', NEW.tieu_de),
        CONCAT('💰 Cơ hội kiếm tiền mới! Sản phẩm "', NEW.tieu_de, '" đã được thêm vào chương trình affiliate với hoa hồng hấp dẫn. Hãy chia sẻ ngay để kiếm thêm thu nhập nhé!'),
        CONCAT('{"product_title":"', NEW.tieu_de, '","shop_id":', NEW.shop, ',"date_start":', NEW.date_start, ',"date_end":', NEW.date_end, ',"commission_rate":"10%"}'),
        NEW.id, 'affiliate_product', 'high', 0, UNIX_TIMESTAMP()
    FROM user_info u 
    WHERE u.aff = '1' AND u.active = 1;
END$$

DELIMITER ;

-- ========================================
-- 5. STORED PROCEDURE CHO VOUCHER SẮP HẾT HẠN
-- ========================================
DELIMITER $$

CREATE PROCEDURE sp_check_expiring_vouchers()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_user_id BIGINT;
    DECLARE v_ma VARCHAR(255);
    DECLARE v_giam INT;
    DECLARE v_expired INT;
    DECLARE v_shop_id INT;
    
    DECLARE cur CURSOR FOR 
        SELECT DISTINCT u.user_id, c.ma, c.giam, c.expired, c.shop
        FROM coupon c 
        JOIN user_info u ON c.shop = u.shop 
        WHERE c.expired > UNIX_TIMESTAMP() 
        AND c.expired <= (UNIX_TIMESTAMP() + 24*3600)
        AND c.status = 1
        AND NOT EXISTS (
            SELECT 1 FROM notification_mobile n 
            WHERE n.user_id = u.user_id 
            AND n.type = 'voucher_expiring' 
            AND n.data LIKE CONCAT('%"voucher_code":"', c.ma, '"%')
            AND n.created_at > (UNIX_TIMESTAMP() - 3600)
        );
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur;
    
    read_loop: LOOP
        FETCH cur INTO v_user_id, v_ma, v_giam, v_expired, v_shop_id;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        INSERT INTO notification_mobile (
            user_id, type, title, content, data, related_id, related_type, priority, is_read, created_at
        ) VALUES (
            v_user_id, 'voucher_expiring', CONCAT('Voucher sắp hết hạn: ', v_ma),
            CONCAT('⏰ Cảnh báo! Voucher "', v_ma, '" giảm ', FORMAT(v_giam, 0), '₫ sẽ hết hạn vào ', DATE_FORMAT(FROM_UNIXTIME(v_expired), '%d/%m/%Y %H:%i'), '. Hãy sử dụng ngay để không bỏ lỡ cơ hội tiết kiệm!'),
            CONCAT('{"voucher_code":"', v_ma, '","discount_amount":', v_giam, ',"expired_date":', v_expired, ',"hours_left":', CEIL((v_expired - UNIX_TIMESTAMP()) / 3600), ',"shop_id":', v_shop_id, '}'),
            NULL, 'coupon', 'high', 0, UNIX_TIMESTAMP()
        );
        
    END LOOP;
    
    CLOSE cur;
END$$

DELIMITER ;

-- ========================================
-- 6. EVENT SCHEDULER CHO VOUCHER EXPIRING
-- ========================================
SET GLOBAL event_scheduler = ON;

CREATE EVENT IF NOT EXISTS ev_check_expiring_vouchers
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_TIMESTAMP
DO
  CALL sp_check_expiring_vouchers();

-- ========================================
-- HƯỚNG DẪN TEST
-- ========================================

/*
TEST CÁC TRIGGER:

1. Đơn hàng:
   UPDATE donhang SET status = 2 WHERE id = 1;

2. Nạp tiền:
   INSERT INTO lichsu_chitieu (user_id, noidung, sotien) VALUES (1, 'nạp tiền', 100000);

3. Rút tiền:
   INSERT INTO lichsu_chitieu (user_id, noidung, sotien) VALUES (1, 'rút tiền', 50000);

4. Voucher:
   INSERT INTO coupon (ma, giam, expired, shop, status) VALUES ('TEST123', 50000, UNIX_TIMESTAMP() + 3600, 1, 1);

5. Affiliate:
   INSERT INTO sanpham_aff (tieu_de, shop, date_start, date_end, hoa_hong) VALUES ('Sản phẩm test', 1, UNIX_TIMESTAMP(), UNIX_TIMESTAMP() + 86400, 10);

6. Kiểm tra:
   SELECT * FROM notification_mobile ORDER BY created_at DESC LIMIT 10;
*/
