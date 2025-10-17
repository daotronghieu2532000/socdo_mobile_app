class AffiliateDashboard {
  final int totalClicks;
  final int totalOrders;
  final double totalCommission;
  final double monthlyRevenue;
  final double conversionRate;
  final String conversionText;
  final int totalMembers;
  final double pendingCommission;
  final double withdrawableBalance;
  final double claimableAmount;

  AffiliateDashboard({
    required this.totalClicks,
    required this.totalOrders,
    required this.totalCommission,
    required this.monthlyRevenue,
    required this.conversionRate,
    required this.conversionText,
    required this.totalMembers,
    required this.pendingCommission,
    required this.withdrawableBalance,
    required this.claimableAmount,
  });

  factory AffiliateDashboard.fromJson(Map<String, dynamic> json) {
    return AffiliateDashboard(
      totalClicks: json['total_clicks'] ?? 0,
      totalOrders: json['total_orders'] ?? 0,
      totalCommission: (json['total_commission'] ?? 0).toDouble(),
      monthlyRevenue: (json['monthly_revenue'] ?? 0).toDouble(),
      conversionRate: (json['conversion_rate'] ?? 0).toDouble(),
      conversionText: json['conversion_text'] ?? 'Cần cải thiện',
      totalMembers: _parseInt(json['total_members']),
      pendingCommission: (json['pending_commission'] ?? 0).toDouble(),
      withdrawableBalance: (json['withdrawable_balance'] ?? 0).toDouble(),
      claimableAmount: (json['claimable_amount'] ?? 0).toDouble(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'total_clicks': totalClicks,
      'total_orders': totalOrders,
      'total_commission': totalCommission,
      'monthly_revenue': monthlyRevenue,
      'conversion_rate': conversionRate,
      'conversion_text': conversionText,
      'total_members': totalMembers,
      'pending_commission': pendingCommission,
      'withdrawable_balance': withdrawableBalance,
      'claimable_amount': claimableAmount,
    };
  }
}

