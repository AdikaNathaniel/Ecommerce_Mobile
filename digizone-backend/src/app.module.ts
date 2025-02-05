import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { CartModule } from './cart/cart.module'; // Import CartModule here
import config from  'config';
import { UsersModule } from './users/users.module';
import { ProductsModule } from './products/products.module';
import { OrdersModule } from './orders/orders.module';

@Module({
  imports: [
    MongooseModule.forRoot(config.get('mongoDbUrl'), {
      w: 1,
      retryWrites: true,
      maxPoolSize: 10,
    }),
    UsersModule,
    ProductsModule,
    OrdersModule,
    CartModule, // Add CartModule to imports
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
