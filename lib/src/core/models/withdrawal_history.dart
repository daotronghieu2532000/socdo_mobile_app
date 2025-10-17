class WithdrawalHistory {
  final int id;
  final double amount;
  final String amountFormatted;
  final String bankAccount;
  final String bankName;
  final String accountHolder;
  final String status;
  final String statusText;
  final String createdAt;
  final int createdTimestamp;
  final String? processedAt;
  final String? notes;

  const WithdrawalHistory({
    required this.id,
    required this.amount,
    required this.amountFormatted,
    required this.bankAccount,
    required this.bankName,
    required this.accountHolder,
    required this.status,
    required this.statusText,
    required this.createdAt,
    required this.createdTimestamp,
    this.processedAt,
    this.notes,
  });

  factory WithdrawalHistory.fromJson(Map<String, dynamic> json) {
    // Handle status object
    String statusCode = '';
    String statusText = '';
    if (json['status'] is Map<String, dynamic>) {
      final statusObj = json['status'] as Map<String, dynamic>;
      statusCode = statusObj['code']?.toString() ?? '';
      statusText = statusObj['text'] ?? '';
    } else {
      statusCode = json['status']?.toString() ?? '';
      statusText = json['status_text'] ?? '';
    }

    return WithdrawalHistory(
      id: json['id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      amountFormatted: json['amount_formatted'] ?? '',
      bankAccount: json['bank_account'] ?? '',
      bankName: json['bank_name'] ?? '',
      accountHolder: json['account_holder'] ?? '',
      status: statusCode,
      statusText: statusText,
      createdAt: json['created_at'] ?? '',
      createdTimestamp: json['created_timestamp'] ?? 0,
      processedAt: json['processed_at'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'amount_formatted': amountFormatted,
      'bank_account': bankAccount,
      'bank_name': bankName,
      'account_holder': accountHolder,
      'status': status,
      'status_text': statusText,
      'created_at': createdAt,
      'created_timestamp': createdTimestamp,
      'processed_at': processedAt,
      'notes': notes,
    };
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';
}
