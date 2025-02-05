import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose'; // We need to import Types for ObjectId
import { Cart } from './cart.schema';

@Injectable()
export class CartService {
  constructor(
    @InjectModel('Cart') private readonly cartModel: Model<Cart>,
  ) {}

  // Add product to cart
  async addToCart(productId: string): Promise<Cart> {
    // Convert productId to ObjectId
    const productObjectId = new Types.ObjectId(productId);

    // Check if product already exists in the cart
    const existingProduct = await this.cartModel.findOne({ productId: productObjectId });
    if (existingProduct) {
      throw new Error('Product already in cart');
    }

    const newProduct = new this.cartModel({
      productId: productObjectId,
      quantity: 1, // default quantity can be 1 when added to the cart
    });
    
    return await newProduct.save();
  }

  // Remove product from cart
  async removeFromCart(productId: string): Promise<void> {
    const productObjectId = new Types.ObjectId(productId);

    const result = await this.cartModel.deleteOne({ productId: productObjectId });

    if (result.deletedCount === 0) {
      throw new NotFoundException(`Product with id ${productId} not found in cart`);
    }
  }

  // Get all products from the cart
  async getAllProducts(): Promise<Cart[]> {
    return await this.cartModel.find().exec();
  }
}
