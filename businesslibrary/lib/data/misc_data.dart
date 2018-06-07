class LineItem {
  String item;
  double price, quantity, lineAmount;

  LineItem({this.item, this.price, this.quantity, this.lineAmount});
  LineItem.fromJSON(Map data) {
    this.item = data['item'];
    this.price = data['price'];
    this.quantity = data['quantity'];
    this.lineAmount = data['lineAmount'];
  }
  Map<String, dynamic> toJson() => <String, dynamic>{
        'item': item,
        'price': price,
        'quantity': quantity,
        'lineAmount': lineAmount,
      };
}

class BaseParticipant {}
