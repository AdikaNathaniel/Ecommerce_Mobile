

import { Schema, Document } from 'mongoose';
import { Types } from 'mongoose'; // For ObjectId typing

export interface Cart extends Document {
  productId: Types.ObjectId; // Use ObjectId instead of string
  quantity: number;
}

export const CartSchema = new Schema<Cart>({
  productId: { 
    type: Schema.Types.ObjectId, 
    required: true,
    unique: true // Ensure product can only be added once to the cart
  },
  quantity: { 
    type: Number, 
    required: true, 
    default: 1 
  },
});
