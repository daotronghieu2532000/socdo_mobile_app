class CommissionHistory {
  final int id;
  final String description;
  final double amount;
  final String amountFormatted;
  final double balanceBefore;
  final String balanceBeforeFormatted;
  final double balanceAfter;
  final String balanceAfterFormatted;
  final String createdAt;
  final int createdTimestamp;
  final int transferredToWithdrawable;

  const CommissionHistory({
    required this.id,
    required this.description,
    required this.amount,
    required this.amountFormatted,
    required this.balanceBefore,
    required this.balanceBeforeFormatted,
    required this.balanceAfter,
    required this.balanceAfterFormatted,
    required this.createdAt,
    required this.createdTimestamp,
    required this.transferredToWithdrawable,
  });

  factory CommissionHistory.fromJson(Map<String, dynamic> json) {
    return CommissionHistory(
      id: json['id'] ?? 0,
      description: json['description'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      amountFormatted: json['amount_formatted'] ?? '',
      balanceBefore: (json['balance_before'] ?? 0).toDouble(),
      balanceBeforeFormatted: json['balance_before_formatted'] ?? '',
      balanceAfter: (json['balance_after'] ?? 0).toDouble(),
      balanceAfterFormatted: json['balance_after_formatted'] ?? '',
      createdAt: json['created_at'] ?? '',
      createdTimestamp: json['created_timestamp'] ?? 0,
      transferredToWithdrawable: json['transferred_to_withdrawable'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'amount_formatted': amountFormatted,
      'balance_before': balanceBefore,
      'balance_before_formatted': balanceBeforeFormatted,
      'balance_after': balanceAfter,
      'balance_after_formatted': balanceAfterFormatted,
      'created_at': createdAt,
      'created_timestamp': createdTimestamp,
      'transferred_to_withdrawable': transferredToWithdrawable,
    };
  }

  bool get isPositive => amount > 0;
  bool get isNegative => amount < 0;
}
