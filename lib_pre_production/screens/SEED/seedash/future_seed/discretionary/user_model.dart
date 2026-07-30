class RecordModel {
  final int id;
  final int allocation_id;
  final int amount;
  final String label;
  final String note;
  final String date;

  const RecordModel({
    required this.id,
    required this.allocation_id,
    required this.amount,
    required this.date,
    required this.note,
    required this.label,
  });

  factory RecordModel.fromJson(Map<String, dynamic> json) => RecordModel(
        id: json['id'],
        allocation_id: json['allocation_id'],
        note: json['note'],
        label: json['label'],
        amount: json['amount'],
        date: json['date'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'allocation_id': allocation_id,
        'date': date,
        'label': label,
        'note': note,
        'amount': amount,
      };
}
