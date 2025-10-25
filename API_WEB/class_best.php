<?php
class class_best {
    // Khai báo properties của class
    private $link_live;
    private $token_live;
    private $link_test;
    private $token_test;
    function __construct() {
        // Gán giá trị cho properties
        $this->link_live = 'https://api.best-inc.vn';
        $this->token_live = 'YOUR_BEST_LIVE_TOKEN';
        $this->link_test = 'https://api-test.best-inc.vn';
        $this->token_test = 'YOUR_BEST_TEST_TOKEN';
    }
    
    // Tính phí ship BEST theo bảng giá
    function get_tax($can_nang, $tien_hang, $tinh_gui, $mien_gui, $tinh_nhan, $mien_nhan, $cod = false, $giao_lai = false) {
        // Kiểm tra nội miền hay liên miền
        $is_noi_mien = ($tinh_gui == $tinh_nhan || $mien_gui == $mien_nhan);
        
        // Tính phí ship cơ bản theo trọng lượng (gram)
        // Cột 1: Nội miền, Cột 2: Liên miền
        if ($can_nang <= 500) { // 0-0.5kg
            $phi_ship = $is_noi_mien ? 18000 : 20000;
        } else if ($can_nang <= 1000) { // 0.5-1kg  
            $phi_ship = $is_noi_mien ? 18000 : 20000;
        } else if ($can_nang <= 2000) { // 1-2kg
            $phi_ship = $is_noi_mien ? 20000 : 25000;
        } else if ($can_nang <= 3000) { // 2-3kg
            $phi_ship = $is_noi_mien ? 25000 : 30000;
        } else if ($can_nang <= 4000) { // 3-4kg
            $phi_ship = $is_noi_mien ? 30000 : 35000;
        } else if ($can_nang <= 5000) { // 4-5kg
            $phi_ship = $is_noi_mien ? 35000 : 40000;
        } else if ($can_nang <= 6000) { // 5-6kg
            $phi_ship = $is_noi_mien ? 40000 : 50000;
        } else if ($can_nang <= 7000) { // 6-7kg
            $phi_ship = $is_noi_mien ? 45000 : 55000;
        } else if ($can_nang <= 8000) { // 7-8kg
            $phi_ship = $is_noi_mien ? 50000 : 60000;
        } else if ($can_nang <= 10000) { // 8-10kg (bao gồm cả 9-10kg)
            $phi_ship = $is_noi_mien ? 50000 : 60000;
        } else { // >10kg
            $can_vuot = ceil(($can_nang - 10000) / 1000);
            $phi_co_ban = $is_noi_mien ? 50000 : 60000; // Phí cơ bản 10kg
            $phi_vuot_kg = $is_noi_mien ? 6000 : 8000; // +6k/kg nội miền, +8k/kg liên miền
            $phi_ship = $phi_co_ban + ($can_vuot * $phi_vuot_kg);
        }
        
        // Phí thu hộ COD
        $phi_cod = 0;
        if ($cod) {
            $phi_cod = $is_noi_mien ? 45000 : 55000; // 45k nội miền, 55k liên miền
        }
        
        // Phí giao lại
        $phi_giao_lai = 0;
        if ($giao_lai) {
            $kg_giao_lai = ceil($can_nang / 1000);
            $phi_giao_lai = $is_noi_mien ? ($kg_giao_lai * 4000) : ($kg_giao_lai * 5000); // +4k/kg nội miền, +5k/kg liên miền
        }
        
        // Phí bảo hiểm (miễn phí theo bảng giá)
        $phi_baohiem = 0;
        
        // Phí hoàn
        $phi_hoan = 8000;
        
        // Tổng phí
        $phi_tong = $phi_ship + $phi_cod + $phi_giao_lai + $phi_baohiem;
        
        $info = array(
            'phi_ship' => $phi_ship,
            'phi_cod' => $phi_cod,
            'phi_giao_lai' => $phi_giao_lai,
            'phi_baohiem' => $phi_baohiem,
            'phi_hoan' => $phi_hoan,
            'phi_tong' => $phi_tong,
            'is_noi_mien' => $is_noi_mien
        );
        
        return json_encode($info);
    }
}
?>
