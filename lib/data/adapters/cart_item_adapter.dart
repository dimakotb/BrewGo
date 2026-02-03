import 'package:hive/hive.dart';
import 'dart:convert';
import '../models/cart_item.dart';

class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 1;

  @override
  CartItem read(BinaryReader reader) {
    final jsonString = reader.readString();
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return CartItem.fromMap(map);
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    final jsonString = json.encode(obj.toMap());
    writer.writeString(jsonString);
  }
}
