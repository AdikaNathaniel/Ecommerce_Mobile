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
import { TopChartsModule } from 'src/topchart/top-chart.module';
import { FavoriteModule } from 'src/favorite/favorite.module';
import { TrackingModule } from 'src/tracking/tracking.module'
// Import delivery-related modules
import { DeliveryService } from 'src/delivery/delivery.service';
import { Delivery, DeliverySchema } from 'src/shared/schema/delivery.schema';
import { DeliveryController } from 'src/delivery/delivery.controller';
import { MQService } from 'src/delivery/mq.service';
// import { DeliveryGateway } from 'src/delivery/delivery.gateway';
// import { DeliveryModule } from 'src/delivery/delivery.module';

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
    TopChartsModule,
    FavoriteModule,
    // DeliveryModule,
    TrackingModule,
    MongooseModule.forFeature([{ name: Delivery.name, schema: DeliverySchema }]), // Add Delivery Schema
  ],
  controllers: [AppController, DeliveryController], // Add DeliveryController
  providers: [AppService, DeliveryService,MQService], // Add DeliveryService and MQService
})
export class AppModule {}
