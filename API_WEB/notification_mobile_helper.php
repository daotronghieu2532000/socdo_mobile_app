<?php
/**
 * Notification Helper cho Mobile App
 * Tự động tạo thông báo cho các sự kiện trong hệ thống
 */

class NotificationMobileHelper {
    private $conn;
    
    public function __construct($connection) {
        $this->conn = $connection;
    }
    
    /**
     * Tạo thông báo mới
     */
    public function createNotification($user_id, $type, $title, $content, $data = null, $related_id = null, $related_type = null, $priority = 'medium') {
        $user_id = intval($user_id);
        $type = addslashes(trim($type));
        $title = addslashes(trim($title));
        $content = addslashes(trim($content));
        $priority = addslashes(trim($priority));
        $related_id = $related_id ? intval($related_id) : 'NULL';
        $related_type = $related_type ? "'" . addslashes(trim($related_type)) . "'" : 'NULL';
        $data_json = $data ? "'" . addslashes(json_encode($data)) . "'" : 'NULL';
        $current_time = time();
        
        $query = "INSERT INTO notification_mobile (user_id, type, title, content, data, related_id, related_type, priority, is_read, created_at) 
                  VALUES ('$user_id', '$type', '$title', '$content', $data_json, $related_id, $related_type, '$priority', 0, '$current_time')";
        
        return mysqli_query($this->conn, $query);
    }
    
    /**
     * Thông báo đơn hàng mới
     */
    public function notifyNewOrder($user_id, $order_id, $order_code, $total_amount) {
        $title = "Đơn hàng mới #$order_code";
        $content = "Bạn vừa đặt đơn hàng #$order_code với tổng giá trị " . number_format($total_amount) . "₫. Đơn hàng đang được xử lý.";
        
        $data = array(
            'order_id' => $order_id,
            'order_code' => $order_code,
            'total_amount' => $total_amount
        );
        
        return $this->createNotification($user_id, 'order', $title, $content, $data, $order_id, 'order', 'high');
    }
    
    /**
     * Thông báo thay đổi trạng thái đơn hàng
     */
    public function notifyOrderStatusChange($user_id, $order_id, $order_code, $old_status, $new_status) {
        $status_names = array(
            0 => 'Chờ xác nhận',
            1 => 'Đã xác nhận',
            2 => 'Đang giao hàng',
            3 => 'Đã giao hàng',
            4 => 'Đã hủy',
            5 => 'Hoàn trả'
        );
        
        $old_status_name = isset($status_names[$old_status]) ? $status_names[$old_status] : 'Không xác định';
        $new_status_name = isset($status_names[$new_status]) ? $status_names[$new_status] : 'Không xác định';
        
        $title = "Cập nhật đơn hàng #$order_code";
        $content = "Đơn hàng #$order_code đã chuyển từ '$old_status_name' sang '$new_status_name'.";
        
        $data = array(
            'order_id' => $order_id,
            'order_code' => $order_code,
            'old_status' => $old_status,
            'new_status' => $new_status,
            'old_status_name' => $old_status_name,
            'new_status_name' => $new_status_name
        );
        
        $priority = ($new_status == 2) ? 'high' : 'medium'; // Đang giao hàng = high priority
        
        return $this->createNotification($user_id, 'order', $title, $content, $data, $order_id, 'order', $priority);
    }
    
    /**
     * Thông báo đơn hàng affiliate mới
     */
    public function notifyNewAffiliateOrder($user_id, $order_id, $order_code, $commission_amount) {
        $title = "Đơn hàng Affiliate mới #$order_code";
        $content = "Bạn có đơn hàng affiliate #$order_code với hoa hồng " . number_format($commission_amount) . "₫.";
        
        $data = array(
            'order_id' => $order_id,
            'order_code' => $order_code,
            'commission_amount' => $commission_amount
        );
        
        return $this->createNotification($user_id, 'affiliate_order', $title, $content, $data, $order_id, 'affiliate_order', 'high');
    }
    
    /**
     * Thông báo nạp tiền
     */
    public function notifyDeposit($user_id, $amount, $method = 'Chuyển khoản') {
        $title = "Nạp tiền thành công";
        $content = "Bạn đã nạp " . number_format($amount) . "₫ vào tài khoản qua $method.";
        
        $data = array(
            'amount' => $amount,
            'method' => $method,
            'transaction_type' => 'deposit'
        );
        
        return $this->createNotification($user_id, 'deposit', $title, $content, $data, null, null, 'medium');
    }
    
    /**
     * Thông báo rút tiền
     */
    public function notifyWithdrawal($user_id, $amount, $status = 'pending', $method = 'Chuyển khoản') {
        $status_names = array(
            'pending' => 'Chờ duyệt',
            'approved' => 'Đã duyệt',
            'rejected' => 'Từ chối',
            'completed' => 'Hoàn thành'
        );
        
        $status_name = isset($status_names[$status]) ? $status_names[$status] : $status;
        
        $title = "Yêu cầu rút tiền " . $status_name;
        $content = "Yêu cầu rút " . number_format($amount) . "₫ qua $method đã được $status_name.";
        
        $data = array(
            'amount' => $amount,
            'status' => $status,
            'status_name' => $status_name,
            'method' => $method,
            'transaction_type' => 'withdrawal'
        );
        
        $priority = ($status == 'rejected') ? 'high' : 'medium';
        
        return $this->createNotification($user_id, 'withdrawal', $title, $content, $data, null, null, $priority);
    }
    
    /**
     * Thông báo voucher mới
     */
    public function notifyNewVoucher($user_id, $voucher_code, $discount_amount, $expired_date) {
        $title = "Voucher mới: $voucher_code";
        $content = "Bạn có voucher mới $voucher_code giảm " . number_format($discount_amount) . "₫. Hạn sử dụng đến " . date('d/m/Y', $expired_date) . ".";
        
        $data = array(
            'voucher_code' => $voucher_code,
            'discount_amount' => $discount_amount,
            'expired_date' => $expired_date
        );
        
        return $this->createNotification($user_id, 'voucher_new', $title, $content, $data, null, 'coupon', 'medium');
    }
    
    /**
     * Thông báo voucher sắp hết hạn
     */
    public function notifyVoucherExpiring($user_id, $voucher_code, $discount_amount, $expired_date) {
        $title = "Voucher sắp hết hạn: $voucher_code";
        $content = "Voucher $voucher_code giảm " . number_format($discount_amount) . "₫ sẽ hết hạn vào " . date('d/m/Y H:i', $expired_date) . ". Hãy sử dụng ngay!";
        
        $data = array(
            'voucher_code' => $voucher_code,
            'discount_amount' => $discount_amount,
            'expired_date' => $expired_date,
            'hours_left' => ceil(($expired_date - time()) / 3600)
        );
        
        return $this->createNotification($user_id, 'voucher_expiring', $title, $content, $data, null, 'coupon', 'high');
    }
    
    /**
     * Kiểm tra và tạo thông báo voucher sắp hết hạn (chạy cron job)
     */
    public function checkExpiringVouchers() {
        $current_time = time();
        $one_day_later = $current_time + (24 * 3600); // 1 ngày sau
        
        // Lấy danh sách voucher sắp hết hạn trong 24h
        $query = "SELECT c.*, u.user_id 
                  FROM coupon c 
                  JOIN user_info u ON c.shop = u.shop 
                  WHERE c.expired > '$current_time' 
                  AND c.expired <= '$one_day_later' 
                  AND c.status = 1";
        
        $result = mysqli_query($this->conn, $query);
        
        $notified_count = 0;
        while ($row = mysqli_fetch_assoc($result)) {
            // Kiểm tra xem đã thông báo chưa
            $check_query = "SELECT id FROM notification_mobile 
                           WHERE user_id = '{$row['user_id']}' 
                           AND type = 'voucher_expiring' 
                           AND related_id IS NULL 
                           AND data LIKE '%\"voucher_code\":\"{$row['ma']}\"%'
                           AND created_at > " . ($current_time - 3600); // Trong 1 giờ qua
            
            $check_result = mysqli_query($this->conn, $check_query);
            
            if (mysqli_num_rows($check_result) == 0) {
                $this->notifyVoucherExpiring(
                    $row['user_id'], 
                    $row['ma'], 
                    $row['giam'], 
                    $row['expired']
                );
                $notified_count++;
            }
        }
        
        return $notified_count;
    }
    
    /**
     * Lấy số lượng thông báo chưa đọc
     */
    public function getUnreadCount($user_id, $type = null) {
        $user_id = intval($user_id);
        $where_clause = "user_id = '$user_id' AND is_read = 0";
        
        if ($type) {
            $type = addslashes(trim($type));
            $where_clause .= " AND type = '$type'";
        }
        
        $query = "SELECT COUNT(*) as count FROM notification_mobile WHERE $where_clause";
        $result = mysqli_query($this->conn, $query);
        
        if ($result) {
            $row = mysqli_fetch_assoc($result);
            return intval($row['count']);
        }
        
        return 0;
    }
}

// Sử dụng:
// $notificationHelper = new NotificationMobileHelper($conn);
// $notificationHelper->notifyNewOrder($user_id, $order_id, $order_code, $total_amount);
?>
