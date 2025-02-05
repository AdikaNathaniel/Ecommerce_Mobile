import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Order, OrderDocument } from 'src/shared/schema/order.schema';
import { CreateOrderDto } from './dto/create-order.dto';
import { CancelOrderDto } from  'src/orders/dto/cancel-order.dto'

@Injectable()
export class OrderService {
  constructor(@InjectModel(Order.name) private orderDB: Model<OrderDocument>) {}

  // ✅ Create an Order
  async createOrder(createOrderDto: CreateOrderDto) {
    try {
      const { productName, quantity } = createOrderDto;

      const newOrder = new this.orderDB({
        productName,
        quantity,
      });

      await newOrder.save();

      return {
        message: 'Order created successfully',
        success: true,
        result: newOrder,
      };
    } catch (error) {
      throw new BadRequestException(error.message);
    }
  }

  // ✅ Cancel an Order
  async cancelOrder(cancelOrderDto: CancelOrderDto) {
    try {
      const { orderId } = cancelOrderDto;

      const deletedOrder = await this.orderDB.findByIdAndUpdate(
        orderId,
        { status: 'Cancelled' },
        { new: true } // Return the updated document
      );

      if (!deletedOrder) {
        throw new BadRequestException('Order not found');
      }

      return {
        message: 'Order cancelled successfully',
        success: true,
        result: deletedOrder,
      };
    } catch (error) {
      throw new BadRequestException(error.message);
    }
  }

  // ✅ Get All Orders
  async getAllOrders() {
    try {
      const orders = await this.orderDB.find();

      return {
        message: 'Orders retrieved successfully',
        success: true,
        result: orders,
      };
    } catch (error) {
      throw new BadRequestException(error.message);
    }
  }
}