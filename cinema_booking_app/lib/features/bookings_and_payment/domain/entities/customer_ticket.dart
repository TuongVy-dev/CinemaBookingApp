class CustomerTicket {
  const CustomerTicket({
    required this.ticketId,
    required this.bookingId,
    required this.movieTitle,
    required this.showDate,
    required this.startTime,
    required this.roomId,
    required this.seatLabels,
    required this.concessionItems,
    required this.totalAmount,
    required this.checkedIn,
  });

  final String ticketId;
  final String bookingId;
  final String movieTitle;
  final DateTime showDate;
  final String startTime;
  final String roomId;
  final List<String> seatLabels;
  final List<CustomerTicketConcession> concessionItems;
  final int totalAmount;
  final bool checkedIn;
}

class CustomerTicketConcession {
  const CustomerTicketConcession({
    required this.concessionId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.lineTotal,
  });

  final String concessionId;
  final String name;
  final int quantity;
  final int unitPrice;
  final int lineTotal;
}
