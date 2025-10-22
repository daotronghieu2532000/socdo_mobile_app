<link rel="stylesheet" href="https://socdo.cdn.vccloud.vn/skin/css/cart-animation.css?v=<?php echo time(); ?>">
<script src="https://socdo.cdn.vccloud.vn/js/cart-animation.js?v=<?php echo time(); ?>"></script>
<!-- // NHATUPDATE 3092025: Mobile Bottom Navigation Menu -->

<div class="mobile-bottom-nav" id="mobileBottomNav">
    <div class="mobile-nav-container">
        <!-- Trang chủ -->
        <!-- <a href="/" class="mobile-nav-item active" id="navHome">
            <div class="mobile-nav-icon">
                <i class="fa fa-home"></i>
            </div>
            <div class="mobile-nav-text">Trang chủ</div>
        </a> -->

        <!-- Danh mục -->
        <a href="#" class="mobile-nav-item" id="navCategory">
            <div class="mobile-nav-icon">
                <i class="fa fa-th-large"></i>
            </div>
            <div class="mobile-nav-text">Danh mục</div>
        </a>
        <!-- Đơn hàng -->
        <a href="#" class="mobile-nav-item" id="navOrder">
            <div class="mobile-nav-icon">
                <i class="fa fa-shopping-bag"></i>
            </div>
            <div class="mobile-nav-text">Đơn hàng</div>
        </a>

        <!-- Affiliate -->
        <a href="#" class="mobile-nav-item" id="navAffiliate">
            <div class="mobile-nav-icon">
                <i class="fa fa-handshake-o"></i>
            </div>
            <div class="mobile-nav-text">Affiliate</div>
        </a>

        <!-- Giỏ hàng -->
        <a href="#" class="mobile-nav-item" id="navCart">
            <div class="mobile-nav-icon">
                <i class="fa fa-shopping-cart"></i>
            </div>
            <div class="mobile-nav-text">Giỏ hàng</div>
            <div class="mobile-nav-cart-badge" id="cartBadge">
                <?php echo count((array)$_SESSION['cart']);?>
            </div>
        </a>

        <!-- Đặt mua button -->
        <a href="#" class="mobile-nav-buy-button" id="navBuy" onclick="handleMobileBuy()">
            <div class="mobile-nav-buy-text" id="buyText">Đặt mua <span class="count_item">(0)</span></div>
            <div class="mobile-nav-buy-price" id="buyPrice">0₫</div>
        </a>
    </div>
</div>

<!-- Universal Loading Spinner -->
<div id="universalLoadingSpinner" class="universal-loading-spinner">
    <div style="text-align: center;">
        <div class="universal-spinner"></div>
        <div class="universal-loading-text">Đang xử lý...</div>
        <div class="universal-loading-subtitle">Vui lòng đợi trong giây lát</div>
    </div>
</div>

<!-- NHATUPDATE 3092025: Mobile Category & Brand Popup -->
<div class="mobile-category-popup" id="mobileCategoryPopup">
    <div class="popup-content">
        <!-- Content sẽ được load từ box_show_category_brand.tpl -->
        <div id="mobileCategoryContent">
            <!-- Loading state -->
            <div class="mobile-category-loading">
                <div class="loading-spinner">
                    <i class="fa fa-spinner fa-spin"></i>
                </div>
                <div class="loading-text">Đang tải danh mục...</div>
            </div>
        </div>
    </div>
</div>

<!-- NHATUPDATE 3092025: Mobile Order Popup -->
<div class="mobile-order-popup" id="mobileOrderPopup">
    <div class="popup-content">
        <!-- Content sẽ được load từ box_show_order.tpl -->
        <div id="mobileOrderContent">
            <!-- Loading state -->
            <div class="mobile-order-loading">
                <div class="loading-spinner">
                    <i class="fa fa-spinner fa-spin"></i>
                </div>
                <div class="loading-text">Đang tải đơn hàng...</div>
            </div>
        </div>
    </div>
</div>

<!-- NHATUPDATE 3092025: Mobile Order Detail Popup -->
<div class="mobile-order-detail-popup" id="mobileOrderDetailPopup">
    <div class="popup-content">
        <!-- Content sẽ được load từ box_show_order_detail.tpl -->
        <div id="mobileOrderDetailContent">
            <!-- Loading state -->
            <div class="mobile-order-loading">
                <div class="loading-spinner">
                    <i class="fa fa-spinner fa-spin"></i>
                </div>
                <div class="loading-text">Đang tải chi tiết...</div>
            </div>
        </div>
    </div>
</div>

<!-- NHATUPDATE 3092025: Mobile Cart Popup -->
<div class="mobile-cart-popup" id="mobileCartPopup">
    <div class="popup-content">
        <!-- Content sẽ được load từ box_show_cart.tpl -->
        <div id="mobileCartContent">
            <!-- Loading state -->
            <div class="mobile-order-loading">
                <div class="loading-spinner">
                    <i class="fa fa-spinner fa-spin"></i>
                </div>
                <div class="loading-text">Đang tải giỏ hàng...</div>
            </div>
        </div>
    </div>
</div>

<!-- NHATUPDATE 1012025: Mobile Affiliate Popup -->
<div class="mobile-affiliate-popup" id="mobileAffiliatePopup">
    <div class="popup-content">
        <!-- Content sẽ được load từ box_show_affiliate.tpl -->
        <div id="mobileAffiliateContent">
            <!-- Loading state -->
            <div class="mobile-order-loading">
                <div class="loading-spinner">
                    <i class="fa fa-spinner fa-spin"></i>
                </div>
                <div class="loading-text">Đang tải affiliate...</div>
            </div>
        </div>
    </div>
</div>

<div id="custom-confirm">
    <div class="popup-box">
        <p id="popup-message" style="margin-bottom: 15px;">Bạn có chắc muốn hủy đơn?</p>
        <div class="popup-actions">
            <button id="popup-cancel">Hủy</button>
            <button id="popup-ok">Đồng ý</button>

        </div>
    </div>
</div>
<div id="toast"></div>
<script>
    function showPopup(message, callback) {
        $('#popup-message').text(message);
        $('#custom-confirm').addClass('active');

        $('#popup-ok').off('click').on('click', function () {
            $('#custom-confirm').removeClass('active');
            callback(true);
        });

        $('#popup-cancel').off('click').on('click', function () {
            $('#custom-confirm').removeClass('active');
            callback(false);
        });
    }
    function showToast(message, type = "success") {
        const toast = $("#toast");
        toast.removeClass().addClass("toast-message show toast-" + type).text(message);

        setTimeout(() => {
            toast.removeClass("show");
        }, 3000);
    }

    function yeuCauHuyDon() {
        showPopup("Bạn có muốn yêu cầu hủy đơn hàng này không?", function (confirmed) {
            if (!confirmed) return;

            const id = $('input[name=id]').val();
            const $btn = $('.status.request_cancel');

            $btn.text("Đang gửi yêu cầu...").css({
                background: "#6c757d",
                cursor: "not-allowed"
            });

            $.ajax({
                url: '/process.php',
                type: 'POST',
                data: {
                    action: 'update_order_status',
                    id: id,
                    status: 3
                },
                dataType: 'json',
                success: function (res) {
                    if (res.success) {
                        $btn.text("Đã gửi yêu cầu hủy").css("background", "#28a745");
                        showToast("Hủy đơn thành công!", "success");
                        setTimeout(() => location.reload(), 1500);
                    } else {
                        $btn.text("Yêu cầu hủy đơn").css({
                            background: "#dc3545",
                            cursor: "pointer"
                        });
                        showToast(res.message || "Không thể hủy đơn.", "error");
                    }
                },
                error: function () {
                    $btn.text("Yêu cầu hủy đơn").css({
                        background: "#dc3545",
                        cursor: "pointer"
                    });
                    showToast("Lỗi khi gửi yêu cầu hủy đơn.", "error");
                }

            });
        });
    }
    // NHATUPDATE 3092025: Mobile Navigation Functions
    // ✅ CHỈ CHẠY TRÊN MOBILE
    function isMobileDevice() {
        return window.innerWidth <= 768 || /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
    }

    $(document).ready(function () {
        // ✅ CHỈ khởi tạo mobile navigation khi ở mobile
        if (isMobileDevice()) {
            // Initialize mobile navigation
            initMobileNavigation();
            setActiveNavItem();

            // Initialize popup functionality
            initMobileCategoryPopup();
            initMobileOrderPopup();
            initMobileCartPopup();
            initMobileCartCheckboxes();
            initMobileAffiliatePopup();

            // ✅ Load số lượng ban đầu cho nút "Đặt mua"
            loadBuyButtonData();
        }
    });

    function initMobileNavigation() {
        // Show/hide based on screen size
        function toggleMobileNav() {
            if (window.innerWidth <= 768) {
                $('#mobileBottomNav').show();
            } else {
                $('#mobileBottomNav').hide();
            }
        }
        toggleMobileNav();
        $(window).resize(toggleMobileNav);
    }

    function setActiveNavItem() {
        var currentPath = window.location.pathname;
        var activeItem = '';

        // Remove all active classes
        $('.mobile-nav-item').removeClass('active');

        // Set active based on current page
        if (currentPath === '/' || currentPath.includes('index')) {
            activeItem = '#navHome';
        } else if (currentPath.includes('san-pham') || currentPath.includes('category')) {
            activeItem = '#navCategory';
        } else if (currentPath.includes('affiliate') || currentPath.includes('affiliate')) {
            activeItem = '#navAffiliate';
        } else if (currentPath.includes('shopcart') || currentPath.includes('cart')) {
            activeItem = '#navCart';
        } else if (currentPath.includes('don-hang') || currentPath.includes('order') || currentPath.includes('order-detail')) {
            activeItem = '#navOrder';
        }


        if (activeItem) {
            $(activeItem).addClass('active');
        }
    }

    function handleMobileBuy() {
        // ✅ CHỈ xử lý trên mobile
        if (!isMobileDevice()) {
            return;
        }

        // ✅ Hiển thị loading spinner toàn màn hình
        showUniversalLoadingSpinner('Đang chuyển đến thanh toán...', 'Vui lòng đợi trong giây lát');

        // ✅ Kiểm tra số lượng sản phẩm đã chọn từ session
        $.ajax({
            url: '/process.php',
            type: 'POST',
            data: {
                action: 'get_cart_active_count'
            },
            dataType: 'json',
            success: function (response) {
                if (response.ok == 1) {
                    if (response.count === 0) {
                        // ✅ Ẩn loading nếu không có sản phẩm
                        hideUniversalLoadingSpinner();
                        showToast('Vui lòng chọn ít nhất một sản phẩm để mua', 'warning');
                        return;
                    }
                    // Có sản phẩm đã chọn → Redirect checkout
                    window.location.href = '/checkout.html';
                }
            },
            error: function () {
                // ✅ Ẩn loading nếu có lỗi
                hideUniversalLoadingSpinner();
                showToast('Lỗi kết nối', 'error');
            }
        });
    }

    function formatPrice(price) {
        return new Intl.NumberFormat('vi-VN').format(price);
    }

    // Universal loading spinner functions
    function showUniversalLoadingSpinner(text = 'Đang xử lý...', subtitle = 'Vui lòng đợi trong giây lát') {
        const spinner = document.getElementById('universalLoadingSpinner');
        if (spinner) {
            // Update text content
            const textElement = spinner.querySelector('.universal-loading-text');
            const subtitleElement = spinner.querySelector('.universal-loading-subtitle');

            if (textElement) textElement.textContent = text;
            if (subtitleElement) subtitleElement.textContent = subtitle;

            spinner.classList.add('show');

            // Auto hide after 5 seconds as fallback
            setTimeout(() => {
                hideUniversalLoadingSpinner();
            }, 1000);
        }
    }

    function hideUniversalLoadingSpinner() {
        const spinner = document.getElementById('universalLoadingSpinner');
        if (spinner) {
            spinner.classList.remove('show');
        }
    }

    // Hide universal spinner when page is fully loaded
    window.addEventListener('load', function () {
        hideUniversalLoadingSpinner();
    });

    // Hide universal spinner when user navigates back
    window.addEventListener('pageshow', function (event) {
        if (event.persisted) {
            hideUniversalLoadingSpinner();
        }
    });

    // NHATUPDATE 3092025: Mobile Category Popup Functions
    function initMobileCategoryPopup() {
        // Bind click event to category nav item
        $(document).on('click', '#navCategory', function (e) {
            e.preventDefault();
            openMobileCategoryPopup();
        });

        // Close popup when clicking outside
        $(document).on('click', '.mobile-category-popup', function (e) {
            if (e.target === this) {
                closeMobileCategoryPopup();
            }
        });

        // Prevent popup content clicks from closing popup
        $(document).on('click', '.popup-content', function (e) {
            e.stopPropagation();
        });

        // Handle escape key
        $(document).on('keydown', function (e) {
            if (e.key === 'Escape') {
                closeMobileCategoryPopup();
            }
        });
    }

    // NHATUPDATE 3092025: Mobile Order Popup Functions
    function initMobileOrderPopup() {
        // Bind click event to order nav item
        $(document).on('click', '#navOrder', function (e) {
            e.preventDefault();
            openMobileOrderPopup();
        });

        // Close popup when clicking outside
        $(document).on('click', '.mobile-order-popup', function (e) {
            if (e.target === this) {
                closeMobileOrderPopup();
            }
        });

        // Prevent popup content clicks from closing popup
        $(document).on('click', '.mobile-order-popup .popup-content', function (e) {
            e.stopPropagation();
        });

        // Handle escape key
        $(document).on('keydown', function (e) {
            if (e.key === 'Escape') {
                closeMobileOrderPopup();
            }
        });
    }

    function openMobileCategoryPopup() {
        var $popup = $('#mobileCategoryPopup');
        var $content = $('#mobileCategoryContent');

        // Show popup first
        $popup.addClass('show');
        $('body').css('overflow', 'hidden');

        // Load content from box_show_category_brand.tpl via AJAX
        $content.html(`
        <div class="mobile-category-loading">
            <div class="loading-spinner">
                <i class="fa fa-spinner fa-spin"></i>
            </div>
            <div class="loading-text">Đang tải danh mục...</div>
        </div>
    `);

        // AJAX call to load category data
        $.ajax({
            url: '/process.php',
            type: 'POST',
            data: {
                action: 'show_mobile_category_brand'
            },
            dataType: 'json',
            success: function (response) {
                if (response.ok) {
                    // Replace content with loaded HTML
                    $content.html(response.html);
                } else {
                    $content.html(`
                    <div class="mobile-category-loading">
                        <div class="loading-text">Không thể tải danh mục</div>
                    </div>
                `);
                }
            },
            error: function () {
                $content.html(`
                <div class="mobile-category-loading">
                    <div class="loading-text">Lỗi kết nối</div>
                </div>
            `);
            }
        });
    }

    function closeMobileCategoryPopup() {
        var $popup = $('#mobileCategoryPopup');
        $popup.removeClass('show');
        $('body').css('overflow', '');
    }

    function openMobileOrderPopup() {
        var $popup = $('#mobileOrderPopup');
        var $content = $('#mobileOrderContent');

        // Show popup first
        $popup.addClass('show');
        $('body').css('overflow', 'hidden');

        // Load content from box_show_order.tpl via AJAX
        $content.html(`
        <div class="mobile-order-loading">
            <div class="loading-spinner">
                <i class="fa fa-spinner fa-spin"></i>
            </div>
            <div class="loading-text">Đang tải đơn hàng...</div>
        </div>
    `);

        // AJAX call to load order data
        $.ajax({
            url: '/process.php',
            type: 'POST',
            data: {
                action: 'show_mobile_order'
            },
            dataType: 'json',
            success: function (response) {
                if (response.ok) {
                    // Replace content with loaded HTML
                    $content.html(response.html);
                } else {
                    $content.html(`
                    <div class="mobile-order-loading">
                        <div class="loading-text">Không thể tải đơn hàng</div>
                    </div>
                `);
                }
            },
            error: function () {
                $content.html(`
                <div class="mobile-order-loading">
                    <div class="loading-text">Lỗi kết nối</div>
                </div>
            `);
            }
        });
    }

    function closeMobileOrderPopup() {
        var $popup = $('#mobileOrderPopup');
        $popup.removeClass('show');
        $('body').css('overflow', '');
    }

    $(window).on('popstate', function () {
        setActiveNavItem();
    });

    // NHATUPDATE 1012025: Mobile Affiliate Navigation - Open Popup thay vì redirect
    // Click handler được đặt trong initMobileAffiliatePopup()


    // NHATUPDATE 3092025: Mobile Order Detail Popup Functions
    function initMobileOrderDetailPopup() {
        // Bind click event ONLY inside mobile order popup/list, not on don_hang page
        $(document).on('click', '.mobile-order-popup .btn-view-detail, .mobileorder-order-container .btn-view-detail', function (e) {
            e.preventDefault();
            var href = $(this).attr('href') || '';
            var orderId = href.split('id=').pop();
            if (!orderId) return;
            openMobileOrderDetailPopup(orderId);
        });

        // Close popup when clicking outside
        $(document).on('click', '.mobile-order-detail-popup', function (e) {
            if (e.target === this) {
                closeMobileOrderDetailPopup();
            }
        });

        // Prevent popup content clicks from closing popup
        $(document).on('click', '.mobile-order-detail-popup .popup-content', function (e) {
            e.stopPropagation();
        });

        // Handle escape key
        $(document).on('keydown', function (e) {
            if (e.key === 'Escape' && $('#mobileOrderDetailPopup').hasClass('show')) {
                closeMobileOrderDetailPopup();
            }
        });
    }

    function openMobileOrderDetailPopup(orderId) {
        var $popup = $('#mobileOrderDetailPopup');
        var $content = $('#mobileOrderDetailContent');

        // Hide order list popup
        $('#mobileOrderPopup').removeClass('show');

        // Show detail popup
        $popup.addClass('show');
        $('body').css('overflow', 'hidden');

        // Load content from box_show_order_detail.tpl via AJAX
        $content.html(`
        <div class="mobile-order-loading">
            <div class="loading-spinner">
                <i class="fa fa-spinner fa-spin"></i>
            </div>
            <div class="loading-text">Đang tải chi tiết...</div>
        </div>
    `);

        // AJAX call to load order detail data
        $.ajax({
            url: '/process.php',
            type: 'POST',
            data: {
                action: 'show_mobile_order_detail',
                order_id: orderId
            },
            dataType: 'json',
            success: function (response) {
                if (response.ok) {
                    // Replace content with loaded HTML
                    $content.html(response.html);
                } else {
                    $content.html(`
                    <div class="mobile-order-loading">
                        <div class="loading-text">Không thể tải chi tiết đơn hàng</div>
                    </div>
                `);
                }
            },
            error: function () {
                $content.html(`
                <div class="mobile-order-loading">
                    <div class="loading-text">Lỗi kết nối</div>
                </div>
            `);
            }
        });
    }

    function closeMobileOrderDetailPopup() {
        var $popup = $('#mobileOrderDetailPopup');
        $popup.removeClass('show');

        // Show order list popup again
        $('#mobileOrderPopup').addClass('show');
        $('body').css('overflow', 'hidden');
    }

    // Initialize order detail popup on document ready
    $(document).ready(function () {
        // ✅ CHỈ khởi tạo trên mobile
        if (isMobileDevice()) {
            initMobileOrderDetailPopup();
        }
    });

    // NHATUPDATE 3092025: Mobile Cart Popup Functions
    function initMobileCartPopup() {
        // Bind click event to cart nav item
        $(document).on('click', '#navCart', function (e) {
            e.preventDefault();
            openMobileCartPopup();
        });

        // Close popup when clicking outside
        $(document).on('click', '.mobile-cart-popup', function (e) {
            if (e.target === this) {
                closeMobileCartPopup();
            }
        });

        // Prevent popup content clicks from closing popup
        $(document).on('click', '.mobile-cart-popup .popup-content', function (e) {
            e.stopPropagation();
        });

        // Handle escape key
        $(document).on('keydown', function (e) {
            if (e.key === 'Escape' && $('#mobileCartPopup').hasClass('show')) {
                closeMobileCartPopup();
            }
        });
    }

    function openMobileCartPopup() {
        var $popup = $('#mobileCartPopup');
        var $content = $('#mobileCartContent');

        // Show popup first
        $popup.addClass('show');
        $('body').css('overflow', 'hidden');

        // Load content from box_show_cart.tpl via AJAX
        $content.html(`
        <div class="mobile-order-loading">
            <div class="loading-spinner">
                <i class="fa fa-spinner fa-spin"></i>
            </div>
            <div class="loading-text">Đang tải giỏ hàng...</div>
        </div>
    `);

        // AJAX call to load cart data
        $.ajax({
            url: '/process.php',
            type: 'POST',
            data: {
                action: 'show_mobile_cart'
            },
            dataType: 'json',
            success: function (response) {
                if (response.ok) {
                    // Replace content with loaded HTML
                    $content.html(response.html);

                    // Initialize cart totals after loading content
                    // Use setTimeout to ensure DOM is ready
                    setTimeout(function () {
                        // ✅ Bỏ tích checkbox "Chọn tất cả" trước (vì HTML có checked sẵn)
                        $('#select-all-mobile').prop('checked', false);

                        // ✅ Auto check tất cả sản phẩm nếu chưa có SP nào checked
                        var hasAnyChecked = $('.mobile-cart-product-item .product-checkbox:checked').length > 0;
                        if (!hasAnyChecked) {
                            // Lần đầu load → Check tất cả
                            $('.mobile-cart-product-item .product-checkbox').prop('checked', true);
                            $('.mobile-cart-shop-section .shop-checkbox').prop('checked', true);
                        }

                        // ✅ Đồng bộ checkbox shop dựa trên trạng thái sản phẩm
                        syncShopCheckboxes();

                        // ✅ QUAN TRỌNG: Cập nhật "Chọn tất cả" SAU CÙNG (dựa trên số lượng thực tế)
                        updateSelectAllStatus();
                        updateMobileCartTotal();
                    }, 100);
                } else {
                    $content.html(`
                    <div class="mobile-order-loading">
                        <div class="loading-text">Không thể tải giỏ hàng</div>
                    </div>
                `);
                }
            },
            error: function () {
                $content.html(`
                <div class="mobile-order-loading">
                    <div class="loading-text">Lỗi kết nối</div>
                </div>
            `);
            }
        });
    }

    function closeMobileCartPopup() {
        var $popup = $('#mobileCartPopup');

        // ✅ Lưu trạng thái checkbox vào session trước khi đóng
        var allProducts = [];
        $('.mobile-cart-product-item').each(function () {
            var $checkbox = $(this).find('.product-checkbox');
            var spId = $(this).data('sp-id');
            var plId = $(this).data('pl');
            var isChecked = $checkbox.is(':checked');

            // ✅ FIX: Cho phép pl = 0 (sản phẩm không phân loại)
            if (typeof spId !== 'undefined' && typeof plId !== 'undefined') {
                allProducts.push({
                    sp_id: spId,
                    pl: plId,
                    is_active: isChecked
                });
            }
        });

        // Lưu vào session
        if (allProducts.length > 0) {
            $.ajax({
                url: '/process.php',
                type: 'POST',
                data: {
                    action: 'update_cart_active_status',
                    products: JSON.stringify(allProducts)
                },
                async: false  // Đợi lưu xong mới đóng
            });
        }

        $popup.removeClass('show');
        $('body').css('overflow', '');

        // ✅ Reload nút "Đặt mua" sau khi đóng
        loadBuyButtonData();
    }

    // NHATUPDATE 1012025: Mobile Affiliate Popup Functions
    function initMobileAffiliatePopup() {
        // Bind click event to affiliate nav item
        $(document).on('click', '#navAffiliate', function (e) {
            e.preventDefault();
            openMobileAffiliatePopup();
        });

        // Close popup when clicking outside
        $(document).on('click', '.mobile-affiliate-popup', function (e) {
            if (e.target === this) {
                closeMobileAffiliatePopup();
            }
        });

        // Prevent popup content clicks from closing popup
        $(document).on('click', '.mobile-affiliate-popup .popup-content', function (e) {
            e.stopPropagation();
        });

        // Handle escape key
        $(document).on('keydown', function (e) {
            if (e.key === 'Escape' && $('#mobileAffiliatePopup').hasClass('show')) {
                closeMobileAffiliatePopup();
            }
        });
    }

    function openMobileAffiliatePopup() {
        var $popup = $('#mobileAffiliatePopup');
        var $content = $('#mobileAffiliateContent');

        // Show popup first
        $popup.addClass('show');
        $('body').css('overflow', 'hidden');

        // Load content from box_show_affiliate.tpl via AJAX
        $content.html(`
        <div class="mobile-order-loading">
            <div class="loading-spinner">
                <i class="fa fa-spinner fa-spin"></i>
            </div>
            <div class="loading-text">Đang tải affiliate...</div>
        </div>
    `);

        // AJAX call to load affiliate data
        $.ajax({
            url: '/process.php',
            type: 'POST',
            data: {
                action: 'show_mobile_affiliate'
            },
            dataType: 'json',
            success: function (response) {
                if (response.ok) {
                    // Replace content with loaded HTML
                    $content.html(response.html);
                } else {
                    // Nếu có HTML trả về (ví dụ: thông báo chưa đăng nhập với nút), hiển thị nó
                    if (response.html) {
                        $content.html(response.html);
                    } else {
                        $content.html(`
                        <div class="mobile-order-loading">
                            <div class="loading-text">` + (response.thongbao || 'Không thể tải affiliate') + `</div>
                        </div>
                    `);
                    }
                }
            },
            error: function () {
                $content.html(`
                <div class="mobile-order-loading">
                    <div class="loading-text">Lỗi kết nối</div>
                </div>
            `);
            }
        });
    }


    function closeMobileAffiliatePopup() {
        var $popup = $('#mobileAffiliatePopup');
        $popup.removeClass('show');
        $('body').css('overflow', '');
    }

    // NHATUPDATE 3092025: Mobile Cart Product Functions
    function changeQuantityMobile(button, change) {
        var $item = $(button).closest('.mobile-cart-product-item');
        var $input = $item.find('.mobile-cart-quantity-input');
        var currentQty = parseInt($input.val());
        var newQty = currentQty + change;

        if (newQty < 1) {
            // Nếu số lượng < 1 thì hiển thị popup xác nhận xóa
            showDeleteConfirmMobile($item);
            return;
        }

        var spId = $item.data('sp-id');
        var plId = $item.data('pl');
        var finalPrice = parseFloat($item.data('final-price'));

        // Cập nhật UI ngay lập tức (optimistic update)
        $input.val(newQty);
        var newTotal = finalPrice * newQty;
        $item.find('.mobile-cart-product-total').text(formatPrice(newTotal));

        // ✅ QUAN TRỌNG: Cập nhật CẢ attribute VÀ data cache
        $item.attr('data-total', newTotal);  // Update HTML attribute
        $item.data('total', newTotal);       // Update jQuery data cache

        // Cập nhật summary ngay lập tức
        updateMobileCartTotal();

        // Gọi API cập nhật số lượng (không cần thông báo)
        $.ajax({
            url: '/process.php',
            type: 'POST',
            data: {
                action: 'update_shopcart',
                sp_id: spId,
                pl: plId,
                quantity: newQty
            },
            dataType: 'json',
            success: function (response) {
                if (response.ok != 1) {
                    // Nếu lỗi thì revert lại UI
                    $input.val(currentQty);
                    var oldTotal = finalPrice * currentQty;
                    $item.find('.mobile-cart-product-total').text(formatPrice(oldTotal));

                    // ✅ Revert CẢ attribute VÀ data cache
                    $item.attr('data-total', oldTotal);  // Revert HTML attribute
                    $item.data('total', oldTotal);       // Revert jQuery data cache

                    // Revert summary
                    updateMobileCartTotal();

                    // Hiển thị lỗi nếu có
                    if (response.thongbao) {
                        showToast('Lỗi: ' + response.thongbao, 'error');
                    }
                } else {
                    // Thành công - trigger cart updated event
                    $(document).trigger('cartUpdated');
                }
            },
            error: function (xhr, status, error) {
                // Nếu lỗi kết nối thì revert lại UI
                $input.val(currentQty);
                var oldTotal = finalPrice * currentQty;
                $item.find('.mobile-cart-product-total').text(formatPrice(oldTotal));

                // ✅ Revert CẢ attribute VÀ data cache
                $item.attr('data-total', oldTotal);  // Revert HTML attribute
                $item.data('total', oldTotal);       // Revert jQuery data cache

                // Revert summary
                updateMobileCartTotal();

                showToast('Lỗi kết nối máy chủ', 'error');
            }
        });
    }

    function deleteProductMobile(button) {
        var $item = $(button).closest('.mobile-cart-product-item');
        showDeleteConfirmMobile($item);
    }

    function showDeleteConfirmMobile($item) {
        showPopup("Xóa sản phẩm khỏi giỏ hàng?", function (confirmed) {
            if (!confirmed) return;

            var spId = $item.data('sp-id');
            var plId = $item.data('pl');

            // Gọi API xóa sản phẩm trước
            $.ajax({
                url: '/process.php',
                type: 'POST',
                data: {
                    action: 'delete_cart_item',
                    sp_id: spId,
                    pl: plId
                },
                dataType: 'json',
                success: function (response) {
                    if (response.ok == 1) {
                        // ✅ 1. Cập nhật badge số lượng giỏ hàng ở bottom nav (API trả về total_cart)
                        if (response.total_cart !== undefined) {
                            $(".mobile-bottom-nav .mobile-nav-cart-badge").html(response.total_cart);
                            // ✅ 2. Cập nhật title trong popup header "Giỏ hàng (X)"
                            $('.mobile-cart-popup .popup-header .title').html('Giỏ hàng (' + response.total_cart + ')');
                            // ✅ 3. Cập nhật label "Chọn Tất Cả (X)" (sẽ được cập nhật lại sau)
                        }

                        // ✅ 4. Lấy shop section TRƯỚC KHI xóa item
                        var $shopSection = $item.closest('.mobile-cart-shop-section');
                        var shopName = $shopSection.find('.shop-badge').text().trim() || 'Shop không tên';

                        // ✅ 5. Xóa item khỏi UI
                        $item.fadeOut(300, function () {
                            $(this).remove();

                            // ✅ 6. Kiểm tra shop này còn sản phẩm nào không (SAU KHI đã xóa item hoàn toàn)
                            var remainingProducts = $shopSection.find('.mobile-cart-product-item').length;

                            if (remainingProducts === 0) {
                                // ✅ 7. Không còn sản phẩm → Xóa luôn TOÀN BỘ mobile-cart-shop-section
                                $shopSection.fadeOut(300, function () {
                                    $(this).remove();

                                    // ✅ 8. Kiểm tra giỏ hàng có trống không
                                    var remainingShops = $('.mobile-cart-shop-section').length;

                                    if (remainingShops === 0) {
                                        checkEmptyCart();
                                    }

                                    updateMobileCartTotal();
                                    updateSelectAllStatus();
                                });
                            } else {
                                // ✅ 9. Còn sản phẩm → Chỉ cập nhật total và sync checkbox
                                updateMobileCartTotal();
                                updateSelectAllStatus();
                                syncShopCheckboxes();
                            }
                        });

                        // Trigger cart updated event
                        $(document).trigger('cartUpdated');
                    } else {
                        // Nếu lỗi thì hiển thị thông báo
                        if (response.thongbao) {
                            showToast('Lỗi: ' + response.thongbao, 'error');
                        }
                    }
                },
                error: function (xhr, status, error) {
                    showToast('Lỗi kết nối máy chủ', 'error');
                }
            });
        });
    }
    function updateMobileCartTotal() {
        var total = 0;
        var count = 0;

        // Chỉ tính các sản phẩm được chọn
        $('.mobile-cart-product-item').each(function () {
            var $checkbox = $(this).find('.product-checkbox');
            var itemTotal = parseFloat($(this).data('total') || 0);
            var isChecked = $checkbox.is(':checked');

            if (isChecked) {
                total += itemTotal;
                count++;
            }
        });

        $('#mobile-cart-summary-amount').text(formatPrice(total));
        $('#mobile-cart-summary-label').text('Tổng cộng (' + count + ' sản phẩm):');

        // ✅ Cập nhật nút "Đặt mua"
        updateBuyButtonCount(count, total);

        // Trigger cart updated event để cập nhật mobile nav
        $(document).trigger('cartUpdated');
    }

    // ✅ Cập nhật số lượng và giá nút "Đặt mua"
    function updateBuyButtonCount(count, total) {
        $('.count_item').text('(' + count + ')');
        $('#buyPrice').text(formatPrice(total));

        if (count > 0) {
            $('#navBuy').css('opacity', '1');
        } else {
            $('#navBuy').css('opacity', '0.6');
        }
    }

    // ✅ Load số lượng từ session cho nút "Đặt mua"
    function loadBuyButtonData() {
        $.ajax({
            url: '/process.php',
            type: 'POST',
            data: {
                action: 'get_cart_active_count'
            },
            dataType: 'json',
            success: function (response) {
                if (response.ok == 1) {
                    updateBuyButtonCount(response.count, response.total);
                }
            }
        });
    }

    function checkEmptyCart() {
        if ($('.mobile-cart-shop-section').length === 0) {
            $('#mobileCartContent').html('<div style="padding: 50px 20px; text-align: center; color: #888;"><i class="fa fa-shopping-cart" style="font-size: 48px; margin-bottom: 15px; opacity: 0.3;"></i><br>Giỏ hàng trống</div>');
            $('.mobile-cart-popup .cart-footer').hide();
        }
    }
    function formatPrice(price) {
        return new Intl.NumberFormat('vi-VN').format(price) + ' ₫';
    }
    // NHATUPDATE 3092025: Mobile Cart Checkbox Functions
    function initMobileCartCheckboxes() {
        // Select all checkbox
        $(document).on('change', '#select-all-mobile', function () {
            var isChecked = $(this).is(':checked');
            $('.mobile-cart-product-item .product-checkbox').prop('checked', isChecked);
            $('.mobile-cart-shop-section .shop-checkbox').prop('checked', isChecked);
            updateMobileCartTotal();
        });

        // Shop checkbox
        $(document).on('change', '.mobile-cart-shop-section .shop-checkbox', function () {
            var $shopSection = $(this).closest('.mobile-cart-shop-section');
            var isChecked = $(this).is(':checked');
            $shopSection.find('.product-checkbox').prop('checked', isChecked);
            updateSelectAllStatus();
            updateMobileCartTotal();
        });

        // Individual product checkbox
        $(document).on('change', '.mobile-cart-product-item .product-checkbox', function () {
            var $shopSection = $(this).closest('.mobile-cart-shop-section');
            var $shopCheckbox = $shopSection.find('.shop-checkbox');
            var checkedProducts = $shopSection.find('.product-checkbox:checked').length;
            var totalProducts = $shopSection.find('.product-checkbox').length;

            // Update shop checkbox status
            $shopCheckbox.prop('checked', checkedProducts === totalProducts);

            updateSelectAllStatus();
            updateMobileCartTotal();
        });
    }

    function updateSelectAllStatus() {
        var totalProducts = $('.mobile-cart-product-item .product-checkbox').length;
        var checkedProducts = $('.mobile-cart-product-item .product-checkbox:checked').length;

        if (totalProducts === 0) {
            $('#select-all-mobile').prop('checked', false);
            // ✅ Update số lượng trong label "Chọn Tất Cả"
            $('.select-all-label span').text('Chọn Tất Cả (0)');
            // ✅ Update title popup header
            $('.mobile-cart-popup .popup-header .title').html('Giỏ hàng (0)');
            return;
        }

        // ✅ CHỈ tích "Chọn tất cả" khi TẤT CẢ sản phẩm đều được chọn
        var allChecked = (totalProducts > 0 && totalProducts === checkedProducts);
        $('#select-all-mobile').prop('checked', allChecked);

        // ✅ Update số lượng trong label "Chọn Tất Cả (X)"
        $('.select-all-label span').text('Chọn Tất Cả (' + totalProducts + ')');
    }

    // ✅ Đồng bộ checkbox shop với trạng thái sản phẩm
    function syncShopCheckboxes() {
        $('.mobile-cart-shop-section').each(function () {
            var $shopSection = $(this);
            var $shopCheckbox = $shopSection.find('.shop-checkbox');
            var totalProducts = $shopSection.find('.product-checkbox').length;
            var checkedProducts = $shopSection.find('.product-checkbox:checked').length;

            // Shop checkbox được tích NẾU TẤT CẢ sản phẩm trong shop đều được tích
            $shopCheckbox.prop('checked', totalProducts > 0 && checkedProducts === totalProducts);
        });
    }

     function proceedToCheckout() {
        var checkedProducts = [];
        var allProducts = [];
        $('.mobile-cart-product-item').each(function () {
            var $checkbox = $(this).find('.product-checkbox');
            var $item = $(this);
            var spId = $item.data('sp-id');
            var plId = $item.data('pl');
            var isChecked = $checkbox.is(':checked');
            if (typeof spId !== 'undefined' && typeof plId !== 'undefined') {
                allProducts.push({
                    sp_id: spId,
                    pl: plId,
                    is_active: isChecked
                });
                if (isChecked) {
                    checkedProducts.push({
                        sp_id: spId,
                        pl: plId
                    });
                }
            }
        });

        if (checkedProducts.length === 0) {
            showToast('Vui lòng chọn ít nhất một sản phẩm để thanh toán', 'warning');
            return;
        }

        showUniversalLoadingSpinner('Đang chuyển đến thanh toán...', 'Vui lòng đợi trong giây lát');
        $.ajax({
            url: '/process.php',
            type: 'POST',
            data: {
                action: 'update_cart_active_status',
                products: JSON.stringify(allProducts)
            },
            dataType: 'json',
            success: function (response) {
                if (response.ok == 1) {
                    closeMobileCartPopup();
                    window.location.href = '/checkout.html';
                } else {
                    hideUniversalLoadingSpinner();
                    showToast(response.thongbao || 'Có lỗi xảy ra', 'error');
                }
            },
            error: function (xhr, status, error) {
                hideUniversalLoadingSpinner();
                showToast('Lỗi kết nối máy chủ', 'error');
            }
        });
    }


</script>

<!-- Box popup chia sẻ -->
<div class="box_pop_share">
    <div class="box_pop_share_content">
        <div class="title_box">
            <span class="text">CHIA SẺ MXH</span>
            <span><i class="fa fa-close"></i></span>
        </div>
        <div class="content_box">
            <div class="list_dinhkem">
                <div class="li_dinhkem">Đăng kèm:</div>
                <div class="li_dinhkem">
                    <input type="checkbox" checked="checked" name="rut_gon" value="" id="rut_gon">
                    <label for="rut_gon">Link Affiliate</label>
                </div>
                <div class="li_dinhkem">
                    <input type="checkbox" checked="checked" name="mobile_share" value="" id="mobile_share">
                    <label for="mobile_share">Số điện thoại</label>
                </div>
                <div class="li_dinhkem">
                    <input type="checkbox" checked="checked" name="include_images" value="" id="include_images">
                    <label for="include_images">Bao gồm ảnh</label>
                </div>
            </div>
            <div class="list_tab_noidung">
            </div>
            <div class="list_share_sanpham">
            </div>
            <div class="action_product">
                <a href="javascript:;" class="bg_green share_button_laptop" noidung_id=""><i class="fa fa-copy"></i>
                    Sao chép</a>
                <a href="javascript:;" class="bg_orange share_button_now" noidung_id=""><i class="fa fa-share"></i>
                    Chia sẻ ngay</a>
            </div>
            <div style="text-align: center; margin-top: 10px; font-size: 12px; color: #666;">
                <i class="fa fa-info-circle"></i> Tự động sao chép cả văn bản và ảnh - chỉ cần 1 lần Ctrl+V
            </div>
        </div>
    </div>
</div>

<button class="button_top" id="go_button">TOP</button>
<script type="text/javascript" src="https://socdo.cdn.vccloud.vn/js/jquery.countdown.js"></script>
<script src="https://socdo.cdn.vccloud.vn/swiper/swiper.min.js"></script>
<script type="text/javascript" src="https://socdo.cdn.vccloud.vn/js/jquery.priceformat.min.js"></script>
<script type="text/javascript" src="https://socdo.cdn.vccloud.vn/js/demo_price.js"></script>
<!-- <script type="text/javascript" src="/js/lazyload.min.js"></script> -->
<script src="https://socdo.cdn.vccloud.vn/js/process.js?t=<?php echo time();?>"></script>
<div class="load_overlay" style="display: none;"></div>
<div class="load_process" style="display: none;">
    <div class="load_content">
        <img src="https://socdo.cdn.vccloud.vn/images/load.gif" alt="loading" width="70">
        <div class="load_note">Hệ thống đang xử lý</div>
    </div>
</div>

{mobile_menu}
<div class="box_pop" id="box_pop_confirm">
    <div class="box_pop_content">
        <div class="pop_content">
            <div class="li_input" style="font-style: italic;text-align: center;">
                <span style="font-style: italic;text-align: center;font-size: 20px;color: red;font-weight: 700;"
                    id="title_confirm"></span>
            </div>
        </div>
        <div class="li_input text_note" style="font-style: italic;text-align: center;width: 100%;">
            <span style="font-style: italic;font-family: Arial">Bạn có chắc chắn thực hiện hàng động này!</span>
        </div>
        <div class="pop_button">
            <div class="text_center">
                <button id="button_thuchien" action="" post_id="" loai="">Thực hiện</button>
                <button class="button_cancel bg_blue">Hủy</button>
            </div>
        </div>
    </div>
</div>

<div id="popup-cart" class="modal fade in" role="dialog" style="display: none;z-index: 99999;">
    <div id="popup-cart-desktop" class="clearfix">
        <div class="title-popup-cart">
            <i class="ion ion-md-notifications-outline" aria-hidden="true"></i> Bạn đã thêm <span
                class="cart-popup-name"></span> vào giỏ hàng
        </div>
        <div class="title-quantity-popup">
            <a href="/gio-hang.html">Giỏ hàng của bạn có <span class="cart-popup-count">{total_cart}</span> sản phẩm</a>
        </div>
        <div class="content-popup-cart clearfix">
            <div style="overflow-x: auto;" class="scroll">
                <div style="width: 800px">
                    <div class="thead-popup">
                        <div style="width: 55%;" class="text-left">Sản phẩm</div>
                        <div style="width: 15%;" class="text-center">Đơn giá</div>
                        <div style="width: 15%;" class="text-center">Số lượng</div>
                        <div style="width: 15%;" class="text-center">Thành tiền</div>
                    </div>
                    <div class="tbody-popup"></div>
                </div>
            </div>
            <div class="tfoot-popup">
                <div class="tfoot-popup-1 clearfix">
                    <!-- <div class="pull-left popupcon">
                        <a class="btn-continue" title="Tiếp tục mua hàng"><span><span><i class="fa fa-caret-left"
                                        aria-hidden="true"></i> Tiếp tục mua hàng</span></span></a>
                    </div> -->
                    <div class="pull-right popup-total">
                        <p>Thành tiền: <span class="total-price">{tongtien}₫</span></p>
                    </div>
                </div>
                <div class="tfoot-popup-2 clearfix list_button_action">
                    <a class="button" style="width: calc(99% - 5px);border-radius: 4px !important;" title="Giỏ hàng"
                        href="/gio-hang.html"><span>Giỏ hàng</span></a>
                    <a class="button btn-proceed-checkout bg_blue" title="Thanh toán đơn hàng"
                        href="/gio-hang.html"><span>Thanh toán đơn hàng</span></a>
                </div>
            </div>
        </div>
        <a title="Close" class="quickview-close close-window" href="javascript:;"><i class="ion ion-ios-close"></i></a>
    </div>
</div>


<div class="box_note">
    <div class="note_title">Thông báo <i class="fa fa-close"></i></div>
    <div class="note_content"></div>
</div>

<div class="box_nnc">
    <div class="box_nnc_content">
        <div class="content">
            <div class="box_title">Đăng ký Nhà bán <span><i class="fa fa-close"></i></span></div>
            <div class="form_nnc">
                <div class="tr_form" style="font-style: italic;">
                    Quý đối tác muốn hợp tác phân phối sản phẩm trên nền tảng của Sóc Đỏ, vui lòng để lại thông tin!
                    Chúng tôi sẽ liên hệ lại trong thời gian sớm nhất! <br>Xin chân thành cảm ơn!
                </div>
                <div class="tr_form">
                    <div class="col_tr_50">
                        <label>Họ và tên <span class="color_red">(*)</span>:</label>
                        <input type="text" name="ho_ten" placeholder="Nhập họ và tên">
                    </div>
                    <div class="col_tr_50">
                        <label>Số điện thoại <span class="color_red">(*)</span>:</label>
                        <input type="text" name="dien_thoai" placeholder="Nhập số điện thoại liên hệ">
                    </div>
                </div>
                <div class="tr_form">
                    <label>Địa chỉ <span class="color_red">(*)</span>:</label>
                    <input type="text" name="dia_chi" placeholder="Nhập địa chỉ liên hệ">
                </div>
                <div class="tr_form">
                    <div class="col_tr_50">
                        <label>Email <span class="color_red">(*)</span>:</label>
                        <input type="text" name="email" placeholder="Nhập địa chỉ email liên hệ">
                    </div>
                    <div class="col_tr_50">
                        <label>Website công ty <span class="color_red">(*)</span>:</label>
                        <input type="text" name="cong_ty" placeholder="Nhập website công ty">
                    </div>
                </div>
                <div class="tr_form">
                    <label>Ngành hàng kinh doanh <span class="color_red">(*)</span>:</label>
                    <textarea name="nganh_hang" placeholder="Nhập ngành hàng kinh doanh"></textarea>
                </div>
                <div class="tr_form">
                    <label>Ghi chú:</label>
                    <textarea name="ghi_chu" placeholder="Nhập nội dung ghi chú"></textarea>
                </div>
                <div class="tr_form">
                    <button name="dangky_nnc">Hoàn Thành</button>
                </div>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">
    $(document).ready(function () {
        $(window).scroll(function () {
            if ($(window).width() > 979) {
                if ($(this).scrollTop() > 120) {
                    $('#go_button').fadeIn();
                    $('.top_ok').hide();
                    $('.sub-header').hide();
                    $('.top-header').hide();

                } else {
                    $('#go_button').fadeOut();
                    $('.top_ok').show();
                    $('.sub-header').show();
                    $('.top-header').show();
                }
            }

        });
        $('#go_button').on('click', function () {
            var top_download = $('body').offset().top;
            $('html,body').stop().animate({ scrollTop: top_download - 150 }, 500, 'swing',
                function () { });
        });
        if ($('.note_top').length > 0) {
            setTimeout(function () {
                $.ajax({
                    url: '/process.php',
                    type: 'post',
                    data: {
                        action: 'load_note',
                    },
                    success: function (kq) {
                        var info = JSON.parse(kq);
                        $('.note_top .num').show();
                        $('.note_top .num').html(info.total);
                    }
                });
            }, 1200);
        }
    });
</script>
<script>
    var quickview_Top = new Swiper('.quickview_big', {
        spaceBetween: 10,
        navigation: {
            nextEl: '.box_quickview .next',
            prevEl: '.box_quickview .prev',
        },
        slidesPerView: 1,
        centeredSlides: true,
        centeredSlidesBounds: true,
        loop: true,
        loopedSlides: 4
    });
    var quickview_Thumbs = new Swiper('.quickview_small', {
        spaceBetween: 10,
        centeredSlides: true,
        slidesPerView: 4,
        centeredSlidesBounds: true,
        touchRatio: 0.2,
        slideToClickedSlide: true,
        loop: true,
        loopedSlides: 4
    });
    quickview_Top.controller.control = quickview_Thumbs;
    quickview_Thumbs.controller.control = quickview_Top;
</script>

<script>
    if (/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)) { document.getElementById("linkzalo").href = "https://zalo.me/{hotline_number}"; }
</script>

<!-- Popup tổng hợp chat với NCC -->
<div id="client-chat-popup"
    style="display: none; position: fixed; bottom: 100px; right: 10px; width: 370px; max-height: 540px; background: #fff; border-radius: 16px; box-shadow: 0 8px 32px rgba(0,0,0,0.18); z-index: 99999; flex-direction: column; overflow: hidden; border: 1.5px solid #eaf6ff;">
    <div
        style="background: linear-gradient(135deg, #144e8d, #3592ff); color: #fff; padding: 16px; font-size: 17px; font-weight: 600; display: flex; align-items: center; justify-content: space-between; border-radius: 16px 16px 0 0;">
        <span><i class="fa fa-comments"></i> Chat với Nhà bán </span>
        <button id="close-client-chat-popup"
            style="background: none; border: none; color: #fff; font-size: 22px; cursor: pointer;">×</button>
    </div>
    <div id="client-chat-list"
        style="flex: 1; overflow-y: auto; background: #f7fafd; min-height: 120px; max-height: 350px;"></div>
    <div id="client-chat-detail" style="display: none; flex-direction: column; height: 350px; background: #f7fafd;">
        <div
            style="background: #f8f9fa; padding: 1px 3px; border-bottom: 1px solid #e0e0e0; display: flex; align-items: center; flex-shrink: 0;">
            <button id="back-to-client-chat-list"
                style="background: none; border: none; color: #ee4d2d; font-size: 16px; cursor: pointer; padding: 8px; margin-right: 10px; border-radius: 4px;"><i
                    class="fa fa-arrow-left"></i></button>
            <span id="client-chat-ncc-name" style="font-weight: 600; color: #333;"></span>
        </div>
        <div id="client-chat-messages"
            style="flex: 1; overflow-y: auto; padding: 16px; background: #f8f9fa;height: 230px; max-height: 230px;">
        </div>
        <div
            style="background: white; border-top: 1px solid #e0e0e0; padding: 12px 16px; flex-shrink: 0; display: flex; align-items: center; gap: 8px;">
            <input type="text" id="client-chat-input" placeholder="Nhập tin nhắn..."
                style="flex: 1; border: 1px solid #ddd; border-radius: 20px; padding: 8px 16px; outline: none; font-size: 14px;"
                onkeypress="if(event.keyCode==13) sendClientMessage()">
            <button onclick="sendClientMessage()"
                style="background: #ee4d2d; color: white; border: none; border-radius: 50%; width: 36px; height: 36px; cursor: pointer; display: flex; align-items: center; justify-content: center; font-size: 16px;"><i
                    class="fa fa-paper-plane"></i></button>
        </div>
    </div>
</div>
<!-- <script src="https://cdn.socket.io/4.8.1/socket.io.min.js"></script> -->
<script>
    window._currentUserId = <?php echo isset($_SESSION['user_id']) ? (int)$_SESSION['user_id'] : 0; ?>;
    $(document).ready(function () {
        window.is_logged_in =  <?php echo isset($_SESSION['user_id']) ? (int)$_SESSION['user_id'] : 0; ?>;
       function isMobileDevice() {
            return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
        }
        // Xử lý nút chat nổi
        $('#open-client-chat-popup').off('click').on('click', function (e) {
            if (typeof window.is_logged_in !== 'undefined' && window.is_logged_in == 0) {
                if (isMobileDevice()) {
                    // Nếu là mobile và chưa đăng nhập, chuyển hướng đến trang đăng nhập
                    window.location.href = '/dang-nhap.html';
                } else {
                    // Nếu là PC và chưa đăng nhập, hiển thị popup đăng nhập
                    if ($('.box_show_login').length) {
                        $('.box_show_login').fadeIn(200);
                    }
                }
                return false;
            } else {
                $('#client-chat-popup').fadeIn(180);
                loadClientChatList();
                updateClientChatBadge(0);
            }
        });
        // Đóng popup chat
        $('#close-client-chat-popup').on('click', function () {
            $('#client-chat-popup').fadeOut(120);
            $('#client-chat-detail').hide();
            $('#client-chat-list').show();
        });
        // Quay lại danh sách chat
        $('#back-to-client-chat-list').on('click', function () {
            $('#client-chat-detail').hide();
            $('#client-chat-list').show();
        });
    });



    function loadClientChatList() {
        $('#client-chat-list').html('<div style="padding: 30px; text-align: center; color: #888;">Đang tải danh sách chat...</div>');
        $.ajax({
            url: '/api/chat_ncc.php',
            type: 'POST',
            data: { action: 'list_sessions' },
            success: function (res) {
                let data = res;
                if (typeof res === 'string') {
                    try { data = JSON.parse(res); } catch (e) { data = []; }
                }  
                 if (!data || !data.length) {
                    $('#client-chat-list').html('<div style="padding: 30px; text-align: center; color: #888;">Bạn chưa có đoạn chat nào.</div>');
                    updateClientChatBadge(0);
                    return;
                } 
                
                let html = '<div class="list-chat-ncc-shopee">';
                let totalUnread = 0; // Đếm tổng số tin chưa đọc
                data.forEach(function (session) {
                    totalUnread += parseInt(session.unread_count || 0); // Cộng dồn số tin chưa đọc
                    html += `<div class="chat-item-ncc-shopee" data-session="${session.session_id}" data-ncc="${session.ncc_id}" onclick="openClientChatDetail('${session.session_id}', '${session.ncc_id}', '${session.ncc_name}')">
                             <div class="chat-avatar-ncc"><img src="${session.ncc_avatar || '/uploads/avatar/avatar_nhaban.jpg'}" alt=""></div>
                             <div class="chat-info-ncc">
                             <div class="chat-name-ncc">${session.ncc_name}</div>
                             <div class="chat-preview-ncc">${session.last_message || ''}</div>
                             </div>
                             <div class="chat-meta-ncc">
                        <div class="chat-time-ncc">${session.last_time || ''}</div>
                        ${session.unread_count > 0 ? `<span class="chat-unread-badge">${session.unread_count}</span>` : ''}
                    </div>
                  </div>`;
                });
                html += '</div>';
                $('#client-chat-list').html(html);

                // Cập nhật badge tổng số tin chưa đọc
                updateClientChatBadge(totalUnread);
            },
            error: function () {
                $('#client-chat-list').html('<div style="padding: 30px; text-align: center; color: #888;">Không tải được danh sách chat.</div>');
            }
        });
    }



    
    // --- MỞ KHUNG CHAT CHI TIẾT VỚI NCC ---
    function openClientChatDetail(session_id, ncc_id, ncc_name) {
        $('#client-chat-list').hide();
        $('#client-chat-detail').show();
        $('#client-chat-ncc-name').text(ncc_name);
        $('#client-chat-messages').html('<div style="padding: 30px; text-align: center; color: #888;">Đang tải tin nhắn...</div>');

        // Đánh dấu đã đọc khi mở chat chi tiết
        $.ajax({
            url: '/api/chat_ncc.php',
            type: 'POST',
            data: {
                action: 'mark_read',
                session_id: session_id,
                user_type: 'customer'
            },
            success: function (res) {
                // Reload lại danh sách để cập nhật badge
                loadClientChatList();
            }
        });

        // Gọi API lấy lịch sử chat
        $.ajax({
            url: '/api/chat_ncc.php',
            type: 'POST',
            data: { action: 'get_messages', session_id: session_id },
            success: function (res) {
                let data = res;
                if (typeof res === 'string') {
                    try { data = JSON.parse(res); } catch (e) { data = []; }
                }
                let html = '';
                if (!data || !data.length) {
                    html = '<div style="padding: 30px; text-align: center; color: #888;">Chưa có tin nhắn nào.</div>';
                } else {
                    data.forEach(function (msg) {
                        html += `<div style="margin-bottom: 10px; text-align: ${msg.is_me ? 'right' : 'left'};">
                        <span style="display: inline-block; background: ${msg.is_me ? '#3592ff' : '#f1f1f1'}; color: ${msg.is_me ? '#fff' : '#333'}; border-radius: 16px;text-align: justify; padding: 7px 16px;width: auto; height: auto; font-size: 14px;">${msg.message}</span>
                        <div style="font-size: 11px; color: #888; margin-top: 2px;">${msg.time}</div>
                    </div>`;
                    });
                }
                $('#client-chat-messages').html(html);
                $('#client-chat-messages').scrollTop($('#client-chat-messages')[0].scrollHeight);
            },
            error: function () {
                $('#client-chat-messages').html('<div style="padding: 30px; text-align: center; color: #888;">Không tải được tin nhắn.</div>');
            }
        });
        // Lưu session_id, ncc_id vào biến toàn cục để gửi tin nhắn
        window._clientChatSessionId = session_id;
        window._clientChatNccId = ncc_id;
    }



    // --- GỬI TIN NHẮN ---
    function sendClientMessage() {
        var msg = $('#client-chat-input').val().trim();
        if (!msg) return;
        $('#client-chat-input').val('');
        var customer_id = window._currentUserId || 0; // cần gán biến này khi user login
        var ncc_id = window._clientChatNccId;
        // Gửi qua API để lưu DB
        $.ajax({
            url: '/api/chat_ncc.php',
            type: 'POST',
            data: {
                action: 'send_message',
                session_id: window._clientChatSessionId,
                ncc_id: ncc_id,
                customer_id: customer_id,
                message: msg
            },
            success: function (res) {
                // Emit socket để realtime cho NCC
                socket.emit('client_send_message', {
                    session_id: window._clientChatSessionId,
                    ncc_id: ncc_id,
                    customer_id: customer_id,
                    message: msg
                });
                // Reload lại tin nhắn
                openClientChatDetail(window._clientChatSessionId, ncc_id, $('#client-chat-ncc-name').text());
            }
        });
    }
    
   var socket = io('https://chat.socdo.vn', { transports: ['websocket'] });

    if (typeof socket !== 'undefined') {
        socket.on('server_send_message', function (data) {
            // Nếu popup đang mở và đang ở đúng khung chat chi tiết, tự động thêm tin nhắn
            if ($('#client-chat-popup').is(':visible') &&
                $('#client-chat-detail').is(':visible') &&
                window._clientChatSessionId == data.session_id) {
                // Thêm tin nhắn vào khung chat
                let html = `<div style="margin-bottom: 10px; text-align: ${data.is_me ? 'right' : 'left'};">
                <span style="display: inline-block; background: ${data.is_me ? '#3592ff' : '#f1f1f1'}; color: ${data.is_me ? '#fff' : '#333'}; border-radius: 16px; padding: 7px 16px; max-width: 80%; font-size: 14px;">${data.message}</span>
                <div style="font-size: 11px; color: #888; margin-top: 2px;">${data.time}</div>
            </div>`;
                $('#client-chat-messages').append(html);
                $('#client-chat-messages').scrollTop($('#client-chat-messages')[0].scrollHeight);
            } else {
                // Nếu đang ở list chat hoặc popup ẩn, reload lại danh sách để cập nhật badge
                if ($('#client-chat-popup').is(':visible')) {
                    loadClientChatList(); // Reload để cập nhật cả list và badge tổng
                }
            }
            updateTotalUnreadBadge(); // Cập nhật badge realtime
        });
    }

    // --- CẬP NHẬT BADGE SỐ LƯỢNG TIN CHƯA ĐỌC ---
    function updateClientChatBadge(count) {
        if (count > 0) {
            $('#chat-badge-client').text(count).show();
        } else {
            $('#chat-badge-client').hide();
        }
    }

    // --- HÀM TÍNH TỔNG SỐ TIN CHƯA ĐỌC (GỌI RIÊNG KHI CẦN) ---
    function updateTotalUnreadBadge() {
        $.ajax({
            url: '/api/chat_ncc.php',
            type: 'POST',
            data: { action: 'list_sessions' },
            success: function (res) {
                let data = res;
                if (typeof res === 'string') {
                    try { data = JSON.parse(res); } catch (e) { data = []; }
                }
                let totalUnread = 0;
                data.forEach(function (session) {
                    totalUnread += parseInt(session.unread_count || 0);
                });
                updateClientChatBadge(totalUnread);
            }
        });
    }

    // --- Khi mở popup, reset badge về 0 (giả lập đã đọc hết) ---
    $('#open-client-chat-popup').on('click', function () {
        // Không reset badge ngay, để loadClientChatList() tính toán chính xác
    });

    // --- GỬI TIN NHẮN QUA SOCKET.IO (KHÁCH HÀNG) ---
    // Đã tích hợp ở sendClientMessage()

    // --- TẠO PHIÊN CHAT KHI BẤM "CHAT NGAY" Ở SẢN PHẨM ---
    window.openClientChatWithNCC = function (ncc_id, ncc_name, ncc_avatar) {
        // 1. Hiện popup chat nếu chưa mở
        if (!$('#client-chat-popup').is(':visible')) {
            $('#client-chat-popup').fadeIn(180);
        }
        // 2. Gọi API tạo session nếu chưa có, sau đó mở khung chat chi tiết
        $.ajax({
            url: '/api/chat_ncc.php',
            type: 'POST',
            data: {
                action: 'create_session',
                ncc_id: ncc_id
            },
            success: function (res) {
                let data = res;
                if (typeof res === 'string') {
                    try { data = JSON.parse(res); } catch (e) { data = []; }
                }
                if (data && data.status == 1 && data.session_id) {
                    openClientChatDetail(data.session_id, ncc_id, ncc_name);
                }
            },
            error: function () {
                alert('Lỗi kết nối máy chủ khi tạo phiên chat.');
            }
        });
    };
</script>
<script>
    $(document).ready(function () {
        // Load badge tổng số tin chưa đọc khi trang load xong
        //updateTotalUnreadBadge();
    });
    document.addEventListener("DOMContentLoaded", function() {
        const specialLink = document.querySelector('a[href="https://socdo.vn/dangky-banhang.html"]');
        if (specialLink) {
            specialLink.classList.add("bold-black");
        }
    });

</script>