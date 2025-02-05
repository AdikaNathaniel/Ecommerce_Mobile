import { Controller, Post, Delete, Get, Body, Query, Put } from '@nestjs/common';
import { CartService } from './cart.service';
import { AddToCartDto } from 'src/products/dto/add-to-cart.dto';
import { UpdateCartDto } from 'src/products/dto/update-cart.dto'; // Import your new DTO

@Controller('cart')
export class CartController {
  constructor(private readonly cartService: CartService) {}

  // ✅ Add to Cart
  @Post()
  async addToCart(@Body() addToCartDto: AddToCartDto) {
    return this.cartService.addToCart(addToCartDto);
  }

  // ✅ Remove from Cart
  @Delete()
  async removeFromCart(@Query('productName') productName: string) {
    return this.cartService.removeFromCart(productName);
  }

  // ✅ Update Cart Item Quantity
  @Put()
  async updateCartItem(@Body() updateCartDto: UpdateCartDto) {
    return this.cartService.updateCartItem(updateCartDto);
  }

  // ✅ Get All Cart Items
  @Get()
  async getCartItems() {
    return this.cartService.getCartItems();
  }
}