import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CartModule } from './cart/cart.module'; // Import CartModule here
import config from 'config';
import { UsersModule } from './users/users.module';
import { ProductsModule } from './products/products.module';
import { OrderModule } from './orders/orders.module';
import { PaymentsModule } from './payments/payments.module';
import { StripeModule } from './payments/stripe.module';

// Import delivery-related modules
import { DeliveryService } from 'src/delivery/delivery.service';
import { Delivery, DeliverySchema } from 'src/shared/schema/delivery.schema';
import { DeliveryController } from 'src/delivery/delivery.controller';
import { MQService } from 'src/delivery/mq.service';

@Module({
  imports: [
    MongooseModule.forRoot(config.get('mongoDbUrl'), {
      w: 1,
      retryWrites: true,
      maxPoolSize: 10,
    }),
    UsersModule,
    ProductsModule,
    OrderModule,
    CartModule,
    PaymentsModule,
    StripeModule,
    MongooseModule.forFeature([{ name: Delivery.name, schema: DeliverySchema }]), // Add Delivery Schema
  ],
  controllers: [AppController, DeliveryController], // Add DeliveryController
  providers: [AppService, DeliveryService, MQService], // Add DeliveryService and MQService
})
export class AppModule {}
