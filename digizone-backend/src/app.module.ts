import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CartModule } from './cart/cart.module'; // Import CartModule here
import config from 'config';
import { UsersModule } from './users/users.module';
// import { ElasticsearchConfigModule } from './products/elastic.module';
import { ProductsModule } from './products/products.module';
import { OrderModule } from './orders/orders.module';
import { PaymentsModule } from './payments/payments.module';
import { StripeModule } from './payments/stripe.module';
import { TopChartsModule } from 'src/topchart/top-chart.module';
import { FavoriteModule } from 'src/favorite/favorite.module';
import { TrackingModule } from 'src/tracking/tracking.module';
// Import delivery-related modules
import { DeliveryService } from 'src/delivery/delivery.service';
import { Delivery, DeliverySchema } from 'src/shared/schema/delivery.schema';
import { DeliveryController } from 'src/delivery/delivery.controller';
import { MQService } from 'src/delivery/mq.service';
// Import ChatModule and Chat schema
import { Chat, ChatSchema } from 'src/shared/schema/chat.schema';
import { ChatModule } from './chat/chat.module';
// Import EmailModule and NotificationModule
import { EmailModule } from 'src/email/email.module'; // Adjust the path as necessary
import { NotificationModule } from 'src/notification/notification.module'; // Adjust the path as necessary

@Module({
  imports: [
    MongooseModule.forRoot(config.get('mongoDbUrl'), {
      w: 1,
      retryWrites: true,
      maxPoolSize: 10,
    }),
    UsersModule,
    ProductsModule,
    // ElasticsearchConfigModule,
    OrderModule,
    CartModule,
    PaymentsModule,
    StripeModule,
    TopChartsModule,
    FavoriteModule,
    TrackingModule,
    MongooseModule.forFeature([{ name: Delivery.name, schema: DeliverySchema }]), // Add Delivery Schema
    ChatModule, // Add ChatModule here
    MongooseModule.forFeature([{ name: Chat.name, schema: ChatSchema }]), // Add Chat Schema if needed
    EmailModule, // Add EmailModule here
    NotificationModule, // Add NotificationModule here
  ],
  controllers: [AppController, DeliveryController], // Add DeliveryController
  providers: [AppService, DeliveryService, MQService], // Add DeliveryService and MQService
})
export class AppModule {}