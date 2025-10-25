<?php
class class_spx extends class_manage {
    // Khai báo properties của class
    private $app_id;
    private $app_secret;
    private $app_id_test;
    private $app_secret_test;
    private $user_id;
    private $user_id_test;
    private $user_secret;
    private $user_secret_test;
    private $api_url;
    private $api_url_test;

    function __construct() {
        // Gán giá trị cho properties
        $this->app_id_test = 1000163;
        $this->app_secret_test = "903b57f5dce15ba6bcfb1a28efeb4c39e74a9afa091b4f6e9f49733d195ffd55";
        $this->app_id = 100316;
        $this->app_secret = "9aeb340364b9395350b4615b4fd6dcea0535a4678e090f7338a9e45eeffec246";
        $this->user_id_test = 247078109611447;
        $this->user_secret_test = "fd7d82d5-8d75-48d0-b4bd-df9a2eb7e9c1";
        $this->user_id = 84124515838605;
        $this->user_secret = "7838384b-2f1d-43bd-8d64-7f929fad562e";
        $this->api_url = "https://spx.vn/open/api/v1/";
        $this->api_url_test = "https://test-stable.spx.vn/open/api/v1/";
    }

    // Hàm chuẩn hóa chuỗi JSON (loại bỏ BOM, ký tự lạ, kiểm tra hợp lệ)
    function chuan_hoa_json($json_str) {
        // Loại bỏ BOM nếu có
        $json_str = preg_replace('/^\xEF\xBB\xBF/', '', $json_str);
        // Loại bỏ các ký tự không in được ở đầu/cuối
        $json_str = trim($json_str);
        // Thử decode để kiểm tra hợp lệ
        $data = json_decode($json_str, true);
        if (json_last_error() === JSON_ERROR_NONE) {
            // Nếu hợp lệ, encode lại để chuẩn hóa format
            return json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        } else {
            // Nếu không hợp lệ, trả về false
            return false;
        }
    }

    // Hàm gửi POST request sử dụng curl
    function curl_post($url, $data, $headers = array()) {
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
        if (!empty($headers)) {
            curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        } else {
            curl_setopt($ch, CURLOPT_HTTPHEADER, array(
                'Content-Type: application/json'
            ));
        }
        $result = curl_exec($ch);
        if (curl_errno($ch)) {
            curl_close($ch);
            return false;
        }
        curl_close($ch);
        return $result;
    }

    // Hàm gửi GET request sử dụng curl
    function curl_get($url, $headers = array()) {
        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        if (!empty($headers)) {
            curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
        }
        $result = curl_exec($ch);
        if (curl_errno($ch)) {
            curl_close($ch);
            return false;
        }
        curl_close($ch);
        return $result;
    }

    // Hàm tạo check-sign cho SPX API
    // $data: mảng dữ liệu cần gửi
    // Trả về chuỗi check_sign
    function generate_check_sign($data, $timestamp, $random_num, $live) {
        if ($live) {
            $app_id = $this->app_id;
            $app_secret = $this->app_secret;
        } else {
            $app_id = $this->app_id_test;
            $app_secret = $this->app_secret_test;
        }
        $string_to_hash = sprintf("%s_%s_%s_%s", $app_id, $timestamp, $random_num, json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES));
        $check_sign = hash_hmac("sha256", $string_to_hash, $app_secret);
        return $check_sign;
    }

    function create_account($phone, $email, $live) {
        $data = [
            "phone" => $phone,
            "email" => $email
        ];
        $url = $live ? $this->api_url . "account/create" : $this->api_url_test . "account/create";
        $app_id = $live ? $this->app_id : $this->app_id_test;
        $app_secret = $live ? $this->app_secret : $this->app_secret_test;
        $timestamp = (string)time();
        $random_num = (string)rand(1, (int)$timestamp);
        $check_sign = $this->generate_check_sign($data, $timestamp, $random_num, $live);
        $headers = [
            "app-id: $app_id",
            "check-sign: $check_sign",
            "timestamp: $timestamp",
            "random-num: $random_num",
            "Content-Type: application/json"
        ];
        $result = $this->curl_post($url, json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES), $headers);
        return $result;
    }

    function get_pickup_time($live) {
        if ($live) {
            $url = $this->api_url . "order/get_pickup_time";
            $user_id = $this->user_id;
            $user_secret = $this->user_secret;
            $app_id = $this->app_id;
            $app_secret = $this->app_secret;
        } else {
            $url = $this->api_url_test . "order/get_pickup_time";
            $user_id = $this->user_id_test;
            $user_secret = $this->user_secret_test;
            $app_id = $this->app_id_test;
            $app_secret = $this->app_secret_test;
        }
        $data = [
            "user_id" => $user_id,
            "user_secret" => $user_secret,
            "service_type" => 1
        ];
        $timestamp = (string)time();
        $random_num = (string)rand(1, (int)$timestamp);
        $check_sign = $this->generate_check_sign($data, $timestamp, $random_num, $live);
        $headers = [
            "app-id: $app_id",
            "check-sign: $check_sign",
            "timestamp: $timestamp",
            "random-num: $random_num",
            "Content-Type: application/json"
        ];
        $result = $this->curl_post($url, json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES), $headers);
        return $result;
    }

    function get_fee($order_data, $live) {
        if ($live) {
            $url = $this->api_url . "order/batch_check_order";
            $user_id = $this->user_id;
            $user_secret = $this->user_secret;
            $app_id = $this->app_id;
            $app_secret = $this->app_secret;
        } else {
            $url = $this->api_url_test . "order/batch_check_order";
            $user_id = $this->user_id_test;
            $user_secret = $this->user_secret_test;
            $app_id = $this->app_id_test;
            $app_secret = $this->app_secret_test;
        }
        if (empty($order_data)) {
            $data = [
                "user_id" => $user_id,
                "user_secret" => $user_secret,
                "orders" => [
                    [
                        "order_id" => "1",
                        "base_info" => [
                            "service_type" => 1
                        ],
                        "sender_info" => [
                            "sender_state" => "TP. Hồ Chí Minh",
                            "sender_city" => "Quận Bình Thạnh",
                            "sender_district" => "Phường 26",
                            "sender_name" => "sender test",
                            "sender_phone" => "84987654321",
                            "sender_detail_address" => "1"
                        ],
                        "fulfillment_info" => [
                            "payment_role" => 1,
                            "cod_collection" => 1,
                            "cod_amount" => 100,
                            "high_value_processing_collection" => 0,
                            "collect_type" => 1,
                            "collect_insurance" => 0,
                            "pickup_time" => 1758272400,
                            "pickup_time_range_id" => 1,
                            "allow_mutual_check" => 0,
                            "allow_try_on" => 0,
                            "voucher_code" => null
                        ],
                        "deliver_info" => [
                            "deliver_state" => "Hà Nam",
                            "deliver_city" => "Huyện Bình Lục",
                            "deliver_district" => "Thị Trấn Bình Mỹ",
                            "deliver_name" => "deliver test",
                            "deliver_phone" => "84987654321",
                            "deliver_detail_address" => "1",
                            "deliver_instruction" => "1"
                        ],
                        "parcel_info" => [
                            "parcel_weight" => 0.5,
                            "parcel_length" => 60,
                            "parcel_width" => 60,
                            "parcel_height" => 10,
                            "parcel_item_name" => "Dao cạo râu",
                            "parcel_item_quantity" => 1,
                            "express_insured_value" => 0
                        ],
                        "vas_info" => [
                            "vas_types" => [
                                "1"
                            ],
                            "collect_fee_amount" => 10000
                        ]
                    ]
                ]
            ];
        } else {
            $data = [
                "user_id" => $user_id,
                "user_secret" => $user_secret,
                "orders" => $order_data
            ];
        }
        $timestamp = (string)time();
        $random_num = (string)rand(1, (int)$timestamp);
        $check_sign = $this->generate_check_sign($data, $timestamp, $random_num, $live);
        $headers = [
            "app-id: $app_id",
            "check-sign: $check_sign",
            "timestamp: $timestamp",
            "random-num: $random_num",
            "Content-Type: application/json"
        ];
        $result = $this->curl_post($url, json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES), $headers);
        return $result;
    }

    function create_order($order_data, $live) {
        if ($live) {
            $url = $this->api_url . "order/batch_create_order";
            $user_id = $this->user_id;
            $user_secret = $this->user_secret;
            $app_id = $this->app_id;
            $app_secret = $this->app_secret;
        } else {
            $url = $this->api_url_test . "order/batch_create_order";
            $user_id = $this->user_id_test;
            $user_secret = $this->user_secret_test;
            $app_id = $this->app_id_test;
            $app_secret = $this->app_secret_test;
        }
        if (empty($order_data)) {
            $data = [
                "user_id" => $user_id,
                "user_secret" => $user_secret,
                "orders" => [
                    [
                        "order_id" => "1345",
                        "base_info" => [
                            "service_type" => 1
                        ],
                        "sender_info" => [
                            "sender_state" => "TP. Hồ Chí Minh",
                            "sender_city" => "Quận Bình Thạnh",
                            "sender_district" => "Phường 26",
                            "sender_name" => "sender test",
                            "sender_phone" => "84987654321",
                            "sender_detail_address" => "1"
                        ],
                        "fulfillment_info" => [
                            "payment_role" => 1,
                            "cod_collection" => 1,
                            "cod_amount" => 100,
                            "high_value_processing_collection" => 0,
                            "collect_type" => 1,
                            "collect_insurance" => 0,
                            "pickup_time" => 1758272400,
                            "pickup_time_range_id" => 1,
                            "allow_mutual_check" => 0,
                            "allow_try_on" => 0,
                            "voucher_code" => null
                        ],
                        "deliver_info" => [
                            "deliver_state" => "Hà Nam",
                            "deliver_city" => "Huyện Bình Lục",
                            "deliver_district" => "Thị Trấn Bình Mỹ",
                            "deliver_name" => "deliver test",
                            "deliver_phone" => "84987654321",
                            "deliver_detail_address" => "1",
                            "deliver_instruction" => "1"
                        ],
                        "parcel_info" => [
                            "parcel_weight" => 0.5,
                            "parcel_length" => 60,
                            "parcel_width" => 60,
                            "parcel_height" => 10,
                            "parcel_item_name" => "Dao cạo râu",
                            "parcel_item_quantity" => 1,
                            "express_insured_value" => 0
                        ],
                        "vas_info" => [
                            "vas_types" => [
                                "1"
                            ],
                            "collect_fee_amount" => 10000
                        ]
                    ]
                ]
            ];
        } else {
            $data = [
                "user_id" => $user_id,
                "user_secret" => $user_secret,
                "orders" => $order_data
            ];
        }
        $timestamp = (string)time();
        $random_num = (string)rand(1, (int)$timestamp);
        $check_sign = $this->generate_check_sign($data, $timestamp, $random_num, $live);
        $headers = [
            "app-id: $app_id",
            "check-sign: $check_sign",
            "timestamp: $timestamp",
            "random-num: $random_num",
            "Content-Type: application/json"
        ];
        $result = $this->curl_post($url, json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES), $headers);
        return $result;
    }

    function cancel_order($order_id, $live) {
        if ($live) {
            $url = $this->api_url . "order/batch_cancel_order";
            $user_id = $this->user_id;
            $user_secret = $this->user_secret;
            $app_id = $this->app_id;
            $app_secret = $this->app_secret;
        } else {
            $url = $this->api_url_test . "order/batch_cancel_order";
            $user_id = $this->user_id_test;
            $user_secret = $this->user_secret_test;
            $app_id = $this->app_id_test;
            $app_secret = $this->app_secret_test;
        }
        $data = [
            "user_id" => $user_id,
            "user_secret" => $user_secret,
            "tracking_no_list" => [$order_id]
        ];
        $timestamp = (string)time();
        $random_num = (string)rand(1, (int)$timestamp);
        $check_sign = $this->generate_check_sign($data, $timestamp, $random_num, $live);
        $headers = [
            "app-id: $app_id",
            "check-sign: $check_sign",
            "timestamp: $timestamp",
            "random-num: $random_num",
            "Content-Type: application/json"
        ];
        $result = $this->curl_post($url, json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES), $headers);
        return $result;
    }

    function search_order($order_id, $order_id_list, $live) {
        if ($live) {
            $url = $this->api_url . "order/batch_search_order";
            $user_id = $this->user_id;
            $user_secret = $this->user_secret;
            $app_id = $this->app_id;
            $app_secret = $this->app_secret;
        } else {
            $url = $this->api_url_test . "order/batch_search_order";
            $user_id = $this->user_id_test;
            $user_secret = $this->user_secret_test;
            $app_id = $this->app_id_test;
            $app_secret = $this->app_secret_test;
        }
        $data = [
            "user_id" => $user_id,
            "user_secret" => $user_secret,
            "tracking_no_list" => is_array($order_id) ? $order_id : [$order_id],
            "order_id_list" => is_array($order_id_list) ? $order_id_list : [$order_id_list],
            "batch_no" => null
        ];
        $timestamp = (string)time();
        $random_num = (string)rand(1, (int)$timestamp);
        $check_sign = $this->generate_check_sign($data, $timestamp, $random_num, $live);
        $headers = [
            "app-id: $app_id",
            "check-sign: $check_sign",
            "timestamp: $timestamp",
            "random-num: $random_num",
            "Content-Type: application/json"
        ];
        $result = $this->curl_post($url, json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES), $headers);
        return $result;
    }

    function get_link_print($order_id, $live) {
        if ($live) {
            $url = $this->api_url . "order/batch_get_shipping_label";
            $user_id = $this->user_id;
            $user_secret = $this->user_secret;
            $app_id = $this->app_id;
            $app_secret = $this->app_secret;
        } else {
            $url = $this->api_url_test . "order/batch_get_shipping_label";
            $user_id = $this->user_id_test;
            $user_secret = $this->user_secret_test;
            $app_id = $this->app_id_test;
            $app_secret = $this->app_secret_test;
        }
        $data = [
            "user_id" => $user_id,
            "user_secret" => $user_secret,
            "tracking_no_list" => is_array($order_id) ? $order_id : [$order_id]
        ];
        $timestamp = (string)time();
        $random_num = (string)rand(1, (int)$timestamp);
        $check_sign = $this->generate_check_sign($data, $timestamp, $random_num, $live);
        $headers = [
            "app-id: $app_id",
            "check-sign: $check_sign",
            "timestamp: $timestamp",
            "random-num: $random_num",
            "Content-Type: application/json"
        ];
        $result = $this->curl_post($url, json_encode($data, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES), $headers);
        return $result;
    }

    function get_tax($can_nang, $tien_hang, $tinh_gui, $mien_gui, $tinh_nhan, $mien_nhan, $cod = false, $giao_lai = false) {
        // Chuyển đổi trọng lượng từ gram sang kg
        $can_nang_kg = $can_nang / 1000;
        
        // Xác định loại vận chuyển dựa trên địa điểm
        $loai_van_chuyen = $this->xac_dinh_loai_van_chuyen($tinh_gui, $mien_gui, $tinh_nhan, $mien_nhan);
        
        // Tính phí ship cơ bản theo trọng lượng
        if ($can_nang_kg <= 0.5) {
            $phi_ship = 12000; // 0-0.5kg: 12,000 VND
        } else if ($can_nang_kg <= 1) {
            $phi_ship = 12000; // 0.5-1kg: 12,000 VND
        } else if ($can_nang_kg <= 2) {
            $phi_ship = 15000; // 1-2kg: 15,000 VND
        } else if ($can_nang_kg <= 3) {
            // 2-3kg
            if ($loai_van_chuyen == 'noi_tinh' || $loai_van_chuyen == 'noi_mien') {
                $phi_ship = 20000; // 20,000 VND cho nội tỉnh/nội miền
            } else {
                $phi_ship = 25000; // 25,000 VND cho đặc biệt/liên miền
            }
        } else if ($can_nang_kg <= 4) {
            // 3-4kg
            if ($loai_van_chuyen == 'noi_tinh' || $loai_van_chuyen == 'noi_mien') {
                $phi_ship = 25000; // 25,000 VND cho nội tỉnh/nội miền
            } else {
                $phi_ship = 35000; // 35,000 VND cho đặc biệt/liên miền
            }
        } else if ($can_nang_kg <= 5) {
            // 4-5kg
            if ($loai_van_chuyen == 'noi_tinh' || $loai_van_chuyen == 'noi_mien') {
                $phi_ship = 30000; // 30,000 VND cho nội tỉnh/nội miền
            } else {
                $phi_ship = 45000; // 45,000 VND cho đặc biệt/liên miền
            }
        } else if ($can_nang_kg <= 6) {
            // 5-6kg
            if ($loai_van_chuyen == 'noi_tinh' || $loai_van_chuyen == 'noi_mien') {
                $phi_ship = 35000; // 35,000 VND cho nội tỉnh/nội miền
            } else {
                $phi_ship = 55000; // 55,000 VND cho đặc biệt/liên miền
            }
        } else if ($can_nang_kg <= 7) {
            // 6-7kg
            if ($loai_van_chuyen == 'noi_tinh' || $loai_van_chuyen == 'noi_mien') {
                $phi_ship = 40000; // 40,000 VND cho nội tỉnh/nội miền
            } else {
                $phi_ship = 65000; // 65,000 VND cho đặc biệt/liên miền
            }
        } else if ($can_nang_kg <= 8) {
            // 7-8kg
            if ($loai_van_chuyen == 'noi_tinh' || $loai_van_chuyen == 'noi_mien') {
                $phi_ship = 45000; // 45,000 VND cho nội tỉnh/nội miền
            } else {
                $phi_ship = 75000; // 75,000 VND cho đặc biệt/liên miền
            }
        } else if ($can_nang_kg <= 10) {
            // 9-10kg
            if ($loai_van_chuyen == 'noi_tinh' || $loai_van_chuyen == 'noi_mien') {
                $phi_ship = 50000; // 50,000 VND cho nội tỉnh/nội miền
            } else {
                $phi_ship = 85000; // 85,000 VND cho đặc biệt/liên miền
            }
        } else {
            // Trên 10kg: phí cơ bản 10kg + phí vượt kg
            if ($loai_van_chuyen == 'noi_tinh' || $loai_van_chuyen == 'noi_mien') {
                $phi_co_ban = 50000; // Phí cơ bản 10kg
                $can_vuot = $can_nang_kg - 10;
                $phi_vuot = ceil($can_vuot) * 5000; // +5,000 VND/kg vượt
            } else {
                $phi_co_ban = 85000; // Phí cơ bản 10kg
                $can_vuot = $can_nang_kg - 10;
                $phi_vuot = ceil($can_vuot) * 10000; // +10,000 VND/kg vượt
            }
            $phi_ship = $phi_co_ban + $phi_vuot;
        }
        
        // Phí thu hộ COD (miễn phí theo bảng giá mới)
        $phi_cod = 0;
        
        // Phí giao lại (miễn phí theo bảng giá mới)
        $phi_giao_lai = 0;
        
        // Phí bảo hiểm đơn hàng
        $phi_baohiem = 0;
        if ($tien_hang >= 3000000) { // Đơn hàng >= 3,000,000 VND
            $phi_baohiem = 25000; // 25,000 VND phí bảo hiểm
        }
        // Đơn dưới 3,000,000 VND: miễn phí
        
        // Phí hoàn (miễn phí theo bảng giá mới)
        $phi_hoan = 0;
        
        // Tổng phí
        $phi_tong = $phi_ship + $phi_cod + $phi_giao_lai + $phi_baohiem;
        
        $info = array(
            'phi_ship' => $phi_ship,
            'phi_cod' => $phi_cod,
            'phi_giao_lai' => $phi_giao_lai,
            'phi_baohiem' => $phi_baohiem,
            'phi_hoan' => $phi_hoan,
            'phi_tong' => $phi_tong,
            'loai_van_chuyen' => $loai_van_chuyen,
            'can_nang_kg' => $can_nang_kg
        );
        
        return json_encode($info);
    }
    
    // Hàm xác định loại vận chuyển
    private function xac_dinh_loai_van_chuyen($tinh_gui, $mien_gui, $tinh_nhan, $mien_nhan) {
        // Nội tỉnh: cùng tỉnh/thành phố
        if ($tinh_gui == $tinh_nhan) {
            return 'noi_tinh';
        }
        
        // Nội miền: cùng miền
        if ($mien_gui == $mien_nhan) {
            return 'noi_mien';
        }
        
        // Đặc biệt: giữa các thành phố lớn (Hà Nội, TP.HCM, Đà Nẵng)
        $thanh_pho_lon = ['Hà Nội', 'TP. Hồ Chí Minh', 'Đà Nẵng', 'Hanoi', 'Ho Chi Minh City', 'Da Nang'];
        if (in_array($tinh_gui, $thanh_pho_lon) && in_array($tinh_nhan, $thanh_pho_lon)) {
            return 'dac_biet';
        }
        
        // Liên miền: các trường hợp còn lại
        return 'lien_mien';
    }
}
?>