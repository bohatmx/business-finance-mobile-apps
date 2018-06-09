class Item {
  String itemId, item, purchaseOrder;
  String price, quantity, amount;

  Item(
      {this.item,
      this.itemId,
      this.price,
      this.quantity,
      this.amount,
      this.purchaseOrder});

  Item.fromJson(Map data) {
    this.item = data['item'];
    this.price = data['price'];
    this.quantity = data['quantity'];
    this.amount = data['lineAmount'];
    this.purchaseOrder = data['purchaseOrder'];
    this.itemId = data['itemId'];
  }

  Map<String, String> toJson() => <String, String>{
        'item': item,
        'price': price,
        'quantity': quantity,
        'lineAmount': amount,
        'purchaseOrder': purchaseOrder,
        'itemId': itemId,
      };
}
