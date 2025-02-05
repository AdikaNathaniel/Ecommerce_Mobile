import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Cart, CartDocument } from 'src/shared/schema/cart.schema';
import { AddToCartDto } from 'src/products/dto/add-to-cart.dto';
import { UpdateCartDto } from 'src/products/dto/update-cart.dto'; // Import your new DTO

@Injectable()
export class CartService {
  constructor(@InjectModel(Cart.name) private cartDB: Model<CartDocument>) {}

  // ✅ Add to Cart (Prevents duplicate items)
  async addToCart(addToCartDto: AddToCartDto) {
    try {
      const { productName, quantity } = addToCartDto;

      // Check if the product already exists in the cart
      const existingCartItem = await this.cartDB.findOne({ productName });

      if (existingCartItem) {
        throw new BadRequestException('Product is already in the cart');
      }

      // Add new product to cart
      const newCartItem = new this.cartDB({
        productName,
        quantity,
      });

      await newCartItem.save();

      return {
        message: 'Product added to cart successfully',
        success: true,
        result: newCartItem,
      };
    } catch (error) {
      throw new BadRequestException(error.message);
    }
  }

  // ✅ Remove from Cart
  async removeFromCart(productName: string) {
    try {
      const deletedItem = await this.cartDB.findOneAndDelete({ productName });

      if (!deletedItem) {
        throw new BadRequestException('Product not found in the cart');
      }

      return {
        message: 'Product removed from cart successfully',
        success: true,
      };
    } catch (error) {
      throw new BadRequestException(error.message);
    }
  }

  // ✅ Update Cart Item Quantity
  async updateCartItem(updateCartDto: UpdateCartDto) {
    try {
      const { productName, quantity } = updateCartDto;

      const updatedItem = await this.cartDB.findOneAndUpdate(
        { productName },
        { quantity },
        { new: true } // Return the updated document
      );

      if (!updatedItem) {
        throw new BadRequestException('Product not found in the cart');
      }

      return {
        message: 'Cart item updated successfully',
        success: true,
        result: updatedItem,
      };
    } catch (error) {
      throw new BadRequestException(error.message);
    }
  }

  // ✅ Get all Cart Items
  async getCartItems() {
    try {
      const cartItems = await this.cartDB.find();

      return {
        message: 'Cart items retrieved successfully',
        success: true,
        result: cartItems,
      };
    } catch (error) {
      throw new BadRequestException(error.message);
    }
  }
}