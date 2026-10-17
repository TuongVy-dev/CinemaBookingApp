class DemoPaymentResult {
  const DemoPaymentResult({
    required this.bookingId,
    required this.paymentId,
    required this.paymentStatus,
    required this.amount,
    required this.message,
    this.ticketId,
  });

  final String bookingId;
  final String paymentId;
  final String paymentStatus;
  final int amount;
  final String? ticketId;
  final String message;

  bool get isSuccessful => paymentStatus.toUpperCase() == 'PAID';
}

enum DemoPaymentOutcome {
  success,
  failed;

  String get apiValue => name.toUpperCase();
}
