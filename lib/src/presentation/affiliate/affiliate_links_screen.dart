import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../core/services/affiliate_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/models/affiliate_link.dart';
import '../../core/utils/format_utils.dart';
import '../product/product_detail_screen.dart';

class AffiliateLinksScreen extends StatefulWidget {
  const AffiliateLinksScreen({super.key});

  @override
  State<AffiliateLinksScreen> createState() => _AffiliateLinksScreenState();
}

class _AffiliateLinksScreenState extends State<AffiliateLinksScreen> {
  final AffiliateService _affiliateService = AffiliateService();
  final AuthService _authService = AuthService();
  List<AffiliateLink> _links = [];
  List<AffiliateLink> _filteredLinks = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  bool _hasMoreData = true;
  final Map<int, bool> _followBusy = {}; // spId -> loading
  int? _currentUserId;

  // Filters & search
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _onlyHasLink = false;
  String _sortBy = 'newest';
  bool _isFilterVisible = false;
  DateTime _lastSearchChange = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _initUser();
    _searchController.addListener(() {
      _searchQuery = _searchController.text.trim();
      // Debounce search ~500ms
      final now = DateTime.now();
      _lastSearchChange = now;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (now == _lastSearchChange) {
          _loadLinks(refresh: true);
        }
      });
    });
  }

  Future<void> _initUser() async {
    final user = await _authService.getCurrentUser();
    setState(() {
      _currentUserId = user?.userId;
    });
    _loadLinks();
  }

  Future<void> _loadLinks({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMoreData = true;
        _links.clear();
      });
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Không dùng cache, gọi API trực tiếp để đảm bảo data luôn mới nhất
      print('🔄 Fetching from AffiliateService (no cache)...');
      final result = await _affiliateService.getMyLinks(
        userId: _currentUserId,
        page: _currentPage,
        limit: 50,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        sortBy: _sortBy,
        onlyHasLink: _onlyHasLink,
      );
      
      if (mounted) {
        setState(() {
          if (result != null && result['links'] != null) {
            final newLinks = result['links'] as List<AffiliateLink>;
            if (refresh) {
              _links = newLinks;
            } else {
              _links.addAll(newLinks);
            }
            _applyFilters();
            final pagination = result['pagination'];
            _hasMoreData = _currentPage < pagination['total_pages'];
            _currentPage++;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Lỗi khi tải dữ liệu: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    // Client-side filtering cho các filter không cần gọi API
    List<AffiliateLink> list = List.of(_links);

    if (_onlyHasLink) {
      list = list.where((l) => l.shortLink.isNotEmpty).toList();
    }

    setState(() {
      _filteredLinks = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Affiliate của tôi'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _loadLinks(refresh: true),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Làm mới',
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isFilterVisible = !_isFilterVisible;
              });
            },
            icon: Icon(
              _isFilterVisible ? Icons.filter_list_off_rounded : Icons.filter_list_rounded,
              color: _hasActiveFilters() ? const Color(0xFFFF6B35) : null,
            ),
            tooltip: _isFilterVisible ? 'Ẩn bộ lọc' : 'Hiện bộ lọc',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Panel
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            height: _isFilterVisible ? null : 0,
            child: _isFilterVisible ? _buildModernFilterPanel() : const SizedBox.shrink(),
          ),
          
          // Main Content
          Expanded(
            child: _isLoading && _links.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _error != null && _links.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _loadLinks(refresh: true),
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : _filteredLinks.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.link_off,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Chưa có link nào',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Tạo link affiliate để bắt đầu kiếm hoa hồng',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _loadLinks(refresh: true),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _filteredLinks.length + (_hasMoreData ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index == _filteredLinks.length) {
                                  if (_hasMoreData && !_isLoading) {
                                    _loadLinks();
                                  }
                                  return const Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Center(child: CircularProgressIndicator()),
                                  );
                                }
                                final link = _filteredLinks[index];
                                return _buildLinkCard(link);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkCard(AffiliateLink link) {
    final bool hasShort = link.shortLink.isNotEmpty;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEAEAEA)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: product info + follow checkbox
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailScreen(productId: link.spId),
                  ),
                );
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      link.productImage,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          link.productTitle,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                         Row(
                           children: [
                             Text(
                               FormatUtils.formatCurrency(link.productPrice.toInt()),
                               style: const TextStyle(
                                 fontSize: 16,
                                 fontWeight: FontWeight.bold,
                                 color: Color(0xFFFF6B35),
                               ),
                             ),
                             if (link.oldPrice > link.productPrice) ...[
                               const SizedBox(width: 8),
                               Text(
                                 FormatUtils.formatCurrency(link.oldPrice.toInt()),
                                 style: const TextStyle(
                                   fontSize: 12,
                                   color: Color(0xFF999999),
                                   decoration: TextDecoration.lineThrough,
                                 ),
                               ),
                               const SizedBox(width: 8),
                               Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                 decoration: BoxDecoration(
                                   color: const Color(0xFFFF6B35),
                                   borderRadius: BorderRadius.circular(2),
                                 ),
                                 child: Text(
                                   'GIẢM ${link.discountPercent}%',
                                   style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600),
                                 ),
                               ),
                             ],
                           ],
                         ),
                         const SizedBox(height: 4),
                         _buildCommissionRange(link),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Tap để xem chi tiết',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Follow checkbox
                   SizedBox(
                     height: 24,
                     width: 24,
                     child: _followBusy[link.spId] == true
                         ? const CircularProgressIndicator(strokeWidth: 2)
                        : Checkbox(
                            value: true,
                            onChanged: (v) async {
                              setState(() { _followBusy[link.spId] = true; });
                              final result = await _affiliateService.toggleFollow(
                                userId: _currentUserId ?? 0,
                                spId: link.spId,
                                shopId: link.shopId,
                                follow: v ?? true,
                              );
                              
                              if (!mounted) return;
                              setState(() { _followBusy[link.spId] = false; });
                              
                              // Nếu unfollow thành công
                              if (result != null && result['success'] == true && (v ?? true) == false) {
                                // Loại bỏ card khỏi danh sách ngay lập tức
                                setState(() { 
                                  _links.removeWhere((l) => l.spId == link.spId);
                                  _applyFilters();
                                });
                                
                                // Hiển thị thông báo
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Đã bỏ theo dõi sản phẩm'),
                                    backgroundColor: Colors.orange,
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                             },
                           ),
                   ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Short link
            // Links: full (utm) then short (if any)
             Row(
               children: [
                 Expanded(child: _buildLinkRow(link.fullLink)),
                 const SizedBox(width: 8),
                 _buildShareButton(() => _showShareDialogForLink(link)),
               ],
             ),
            if (hasShort) ...[
              const SizedBox(height: 8),
               Row(
                 children: [
                   Expanded(child: _buildLinkRow(link.shortLink)),
                   const SizedBox(width: 8),
                   _buildShareButton(() => _showShareDialogForLink(link)),
                 ],
               ),
            ],
            const SizedBox(height: 16),
            
            // Statistics
            Row(
              children: [
                Expanded(child: _buildStatItemSmall(icon: Icons.visibility, label: 'Click', value: '${link.clicks}')),
                Expanded(child: _buildStatItemSmall(icon: Icons.shopping_cart, label: 'Đơn', value: '${link.orders}')),
                Expanded(child: _buildStatItemSmall(icon: Icons.percent, label: 'CVR', value: link.conversionRateText)),
                Expanded(child: _buildStatItemSmall(icon: Icons.monetization_on, label: 'Hoa hồng', value: FormatUtils.formatCurrency(link.commission.toInt()))),
              ],
            ),
            const SizedBox(height: 12),
            
            // Created date
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Đã thêm: ${link.createdAt}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItemSmall({required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6C757D)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212529),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF6C757D),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkRow(String url) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        children: [
          const Icon(Icons.link, size: 14, color: Color(0xFF6C757D)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              url,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF212529),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: url));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Đã copy link!'),
                  backgroundColor: const Color(0xFF28A745),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            child: const Icon(Icons.copy, size: 16, color: Color(0xFF6C757D)),
          ),
        ],
      ),
    );
  }

  // Share button similar style with products dialog (simple for links list)
  Widget _buildShareButton(VoidCallback onTap) {
    return SizedBox(
      height: 36,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.share, size: 16),
        label: const Text('Chia sẻ', style: TextStyle(fontSize: 12)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          foregroundColor: const Color(0xFF1976D2),
          side: const BorderSide(color: Color(0xFF1976D2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  // Share dialog (giống bên sản phẩm)
  void _showShareDialogForLink(AffiliateLink link) {
    final affiliateUrl = link.fullLink.isNotEmpty ? link.fullLink : link.shortLink;
    final shareText = _buildShareTextForLink(link);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text('Chia sẻ sản phẩm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 12),
              Center(
                child: _shareIconButton(Icons.share, 'Chia sẻ', () {
                  _shareWithImage(link, shareText, affiliateUrl);
                }),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _shareIconButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF2FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF1976D2), size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF666666))),
        ],
      ),
    );
  }

  String _buildShareTextForLink(AffiliateLink link) {
    // Nội dung tương tự bên sản phẩm
    final price = FormatUtils.formatCurrency(link.productPrice.toInt());
    final old = link.oldPrice > link.productPrice ? ' (Giảm ${link.discountPercent}%)' : '';
    final commissionText = _commissionRangeText(link);
    final oldPriceText = link.oldPrice > link.productPrice 
        ? '\n💸 Giá gốc: ${FormatUtils.formatCurrency(link.oldPrice.toInt())}'
        : '';
    
    // Add more context about the product
    final statsText = link.clicks > 0 || link.orders > 0 
        ? '\n📊 Thống kê: ${link.clicks} clicks, ${link.orders} đơn hàng'
        : '';
    
    return '🔥 ${link.productTitle}$old\n💰 Giá: $price$oldPriceText\n$commissionText$statsText\n\n👉 Mua ngay để nhận ưu đãi tốt nhất!\n\n📱 Tải app Socdo để mua hàng với giá tốt nhất!';
  }

  // Commission range badge and text (reuse logic like products)
  Widget _buildCommissionRange(AffiliateLink link) {
    final text = _commissionRangeText(link);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFE1F5FE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(_extractPercent(link) ?? '—', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 11, color: Color(0xFF1976D2), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String? _extractPercent(AffiliateLink link) {
    // Find first percentage commission
    for (final c in link.commissionInfo) {
      if (c.type == 'phantram') {
        return '${c.value.toStringAsFixed(0)}%';
      }
    }
    return null;
  }

  void _shareWithImage(AffiliateLink link, String shareText, String affiliateUrl) async {
    // Debug: Check if productImage is available
    print('🚀 [SHARE] Starting share for link: ${link.productTitle}');
    print('🔍 [DEBUG] Product Image URL: ${link.productImage}');
    print('🔍 [DEBUG] Product Image Empty: ${link.productImage.isEmpty}');
    print('🔍 [DEBUG] Product Title: ${link.productTitle}');
    print('🔍 [DEBUG] Affiliate URL: $affiliateUrl');
    print('📝 [SHARE] Share text length: ${shareText.length}');
    
    try {
      // Try to share with image if available
      if (link.productImage.isNotEmpty) {
        print('🖼️ [SHARE] Attempting to share with image: ${link.productImage}');
        
        // Download image to temporary file
        final imageFile = await _downloadImageToTemp(link.productImage);
        if (imageFile != null) {
          print('✅ [SHARE] Image downloaded successfully: ${imageFile.path}');
          print('📊 [SHARE] Image file size: ${await imageFile.length()} bytes');
          
          // Method 1: Try sharing both together (preferred)
          try {
            print('📤 [SHARE] Method 1: Sharing both together...');
            await Share.shareXFiles(
              [XFile(imageFile.path)],
              text: '$shareText\n\n$affiliateUrl',
              subject: link.productTitle,
            );
            print('✅ [SHARE] Combined sharing completed');
            return;
          } catch (e) {
            print('❌ [SHARE] Combined sharing failed: $e');
            print('🔄 [SHARE] Trying sequential method...');
          }
          
          // Method 2: Try sharing text first, then image (fallback)
          try {
            print('📤 [SHARE] Method 2: Sharing text first...');
            // Share text first
            await Share.share(
              '$shareText\n\n$affiliateUrl',
              subject: link.productTitle,
            );
            print('✅ [SHARE] Text shared successfully');
            
            // Small delay then share image
            print('⏳ [SHARE] Waiting 2 seconds before sharing image...');
            await Future.delayed(const Duration(milliseconds: 2000));
            
            // Share image separately
            print('📤 [SHARE] Method 2: Sharing image separately...');
            await Share.shareXFiles(
              [XFile(imageFile.path)],
              text: '',
            );
            print('✅ [SHARE] Image shared successfully');
            print('✅ [SHARE] Sequential sharing completed');
            return;
          } catch (e) {
            print('❌ [SHARE] Sequential sharing failed: $e');
            print('🔄 [SHARE] Falling back to text-only...');
          }
        } else {
          print('❌ [SHARE] Failed to download image, falling back to text-only');
        }
      } else {
        print('⚠️ [SHARE] No image available, using text-only sharing');
      }
      
      // Fallback to text-only sharing
      print('📤 [SHARE] Fallback: Text-only sharing...');
      Share.share(
        '$shareText\n\n$affiliateUrl',
        subject: link.productTitle,
      );
      print('✅ [SHARE] Text-only sharing completed');
    } catch (e) {
      print('❌ [SHARE] Error sharing: $e');
      print('🔄 [SHARE] Final fallback: Text-only sharing...');
      // If image sharing fails, fallback to text-only
      Share.share(
        '$shareText\n\n$affiliateUrl',
        subject: link.productTitle,
      );
      print('✅ [SHARE] Final fallback completed');
    }
  }


  Future<File?> _downloadImageToTemp(String imageUrl) async {
    try {
      print('📥 [DOWNLOAD] Starting download: $imageUrl');
      
      // Validate URL
      if (!imageUrl.startsWith('http')) {
        print('❌ [DOWNLOAD] Invalid URL format: $imageUrl');
        return null;
      }
      
      // Add timeout and headers
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          'Accept': 'image/*',
        },
      ).timeout(const Duration(seconds: 30));
      
      print('📊 [DOWNLOAD] HTTP Status: ${response.statusCode}');
      print('📊 [DOWNLOAD] Content-Type: ${response.headers['content-type']}');
      print('📊 [DOWNLOAD] Content-Length: ${response.headers['content-length']}');
      
      if (response.statusCode == 200) {
        final tempDir = await getTemporaryDirectory();
        final fileName = 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.bodyBytes);
        
        final fileSize = await file.length();
        print('✅ [DOWNLOAD] Image saved to: ${file.path}');
        print('📊 [DOWNLOAD] File size: $fileSize bytes');
        
        // Validate file size
        if (fileSize < 100) {
          print('⚠️ [DOWNLOAD] File size too small, might be corrupted');
          return null;
        }
        
        return file;
      } else {
        print('❌ [DOWNLOAD] HTTP error: ${response.statusCode}');
        print('❌ [DOWNLOAD] Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');
      }
    } catch (e) {
      print('❌ [DOWNLOAD] Error downloading image: $e');
      print('❌ [DOWNLOAD] Error type: ${e.runtimeType}');
    }
    return null;
  }

  String _commissionRangeText(AffiliateLink link) {
    double? minCommission;
    double? maxCommission;
    double minPrice = link.productPrice;
    double maxPrice = link.oldPrice > link.productPrice ? link.oldPrice : link.productPrice * 1.2;
    for (final c in link.commissionInfo) {
      if (c.type == 'phantram') {
        final minC = (minPrice * c.value / 100).roundToDouble();
        final maxC = (maxPrice * c.value / 100).roundToDouble();
        minCommission = minCommission == null ? minC : (minC < minCommission ? minC : minCommission);
        maxCommission = maxCommission == null ? maxC : (maxC > maxCommission ? maxC : maxCommission);
      } else {
        minCommission = minCommission == null ? c.value : (c.value < minCommission ? c.value : minCommission);
        maxCommission = maxCommission == null ? c.value : (c.value > maxCommission ? c.value : maxCommission);
      }
    }
    if (minCommission == null || maxCommission == null) return '💎 Hoa hồng: —';
    return '💎 Hoa hồng: ${FormatUtils.formatCurrency(minCommission.toInt())} → ${FormatUtils.formatCurrency(maxCommission.toInt())}';
  }

  Widget _buildModernFilterPanel() {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm sản phẩm...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.grey[400],
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear_rounded,
                          color: Colors.grey[400],
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _searchQuery = '';
                          _loadLinks(refresh: true);
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFFF6B35),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _loadLinks(refresh: true),
            ),
          ),
          
          // Filter Chips Row
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Has Link Filter
                  _buildFilterChip(
                    icon: Icons.link_rounded,
                    label: 'Có link rút gọn',
                    isSelected: _onlyHasLink,
                    onTap: () {
                      setState(() {
                        _onlyHasLink = !_onlyHasLink;
                      });
                      _applyFilters();
                    },
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Sort Buttons
                  _buildSortButton('Mới nhất', 'newest', Icons.new_releases_rounded),
                  const SizedBox(width: 8),
                  _buildSortButton('Giá ↑', 'price_asc', Icons.trending_up_rounded),
                  const SizedBox(width: 8),
                  _buildSortButton('Giá ↓', 'price_desc', Icons.trending_down_rounded),
                  const SizedBox(width: 8),
                  _buildSortButton('Hoa hồng ↑', 'commission_asc', Icons.monetization_on_rounded),
                  const SizedBox(width: 8),
                  _buildSortButton('Hoa hồng ↓', 'commission_desc', Icons.money_off_rounded),
                  const SizedBox(width: 8),
                  _buildSortButton('Click ↑', 'clicks_desc', Icons.trending_up_rounded),
                  const SizedBox(width: 8),
                  _buildSortButton('Click ↓', 'clicks_asc', Icons.trending_down_rounded),
                  
                  // Clear Filters
                  if (_hasActiveFilters()) ...[
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      icon: Icons.clear_all_rounded,
                      label: 'Xóa bộ lọc',
                      isSelected: false,
                      backgroundColor: Colors.red[50],
                      textColor: Colors.red[600],
                      iconColor: Colors.red[600],
                      onTap: _clearAllFilters,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFFF6B35) 
              : backgroundColor ?? const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFFFF6B35) 
                : const Color(0xFFE9ECEF),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected 
                  ? Colors.white 
                  : iconColor ?? Colors.grey[600],
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected 
                    ? Colors.white 
                    : textColor ?? Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortButton(String label, String value, IconData icon) {
    final isSelected = _sortBy == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _sortBy = value;
        });
        _loadLinks(refresh: true);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFFF6B35) 
              : const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFFFF6B35) 
                : const Color(0xFFE9ECEF),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected 
                  ? Colors.white 
                  : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isSelected 
                    ? Colors.white 
                    : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasActiveFilters() {
    return _searchQuery.isNotEmpty || 
           _onlyHasLink ||
           _sortBy != 'newest';
  }

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      _onlyHasLink = false;
      _sortBy = 'newest';
    });
    _loadLinks(refresh: true);
  }
}

