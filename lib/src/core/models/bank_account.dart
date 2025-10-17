class BankAccount {
  final int id;
  final String accountHolder;
  final String accountNumber;
  final int bankId;
  final String bankName;
  final String bankCode;
  final String bankLogo;
  final bool isDefault;
  final String createdAt;

  const BankAccount({
    required this.id,
    required this.accountHolder,
    required this.accountNumber,
    required this.bankId,
    required this.bankName,
    required this.bankCode,
    required this.bankLogo,
    required this.isDefault,
    required this.createdAt,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] ?? 0,
      accountHolder: json['account_holder'] ?? '',
      accountNumber: json['account_number'] ?? '',
      bankId: json['bank_id'] ?? 0,
      bankName: json['bank_name'] ?? '',
      bankCode: json['bank_code'] ?? '',
      bankLogo: json['bank_logo'] ?? '',
      isDefault: json['is_default'] ?? false,
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account_holder': accountHolder,
      'account_number': accountNumber,
      'bank_id': bankId,
      'bank_name': bankName,
      'bank_code': bankCode,
      'bank_logo': bankLogo,
      'is_default': isDefault,
      'created_at': createdAt,
    };
  }
}

class Bank {
  final int id;
  final String name;
  final String code;
  final String logo;

  const Bank({
    required this.id,
    required this.name,
    required this.code,
    required this.logo,
  });

  factory Bank.fromJson(Map<String, dynamic> json) {
    return Bank(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      logo: json['logo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'logo': logo,
    };
  }
}
