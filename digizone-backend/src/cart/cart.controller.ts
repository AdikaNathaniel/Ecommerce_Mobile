// src/cart/cart.controller.ts

import { Controller, Post, Delete, Get, Param } from '@nestjs/common';
import { CartService } from './cart.service';

@Controller('cart')
export class CartController {
  constructor(private readonly cartService: CartService) {}

  // Add a product to the cart
  @Post('add/:productId')
  async addToCart(@Param('productId') productId: string) {
    try {
      const cart = await this.cartService.addToCart(productId);
      return { success: true, cart };
    } catch (error) {
      return { success: false, message: error.message };
    }
  }

  // Remove a product from the cart
  @Delete('remove/:productId')
  async removeFromCart(@Param('productId') productId: string) {
    try {
      await this.cartService.removeFromCart(productId);
      return { success: true, message: 'Product removed from cart' };
    } catch (error) {
      return { success: false, message: error.message };
    }
  }

  // Get all products in the cart
  @Get()
  async getAllProducts() {
    const products = await this.cartService.getAllProducts();
    return { success: true, products };
  }
}
