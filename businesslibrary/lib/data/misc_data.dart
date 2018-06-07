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

class BaseParticipant {
  //common methods???
  String getUUID() {
    var uuid = new Uuid();
    // Generate a v1 (time-based) id
    String m = uuid.v1();
    return m;
  }
}

class Uuid {
  String v1() {
    return 'stuff to figure out later';
  }
}
