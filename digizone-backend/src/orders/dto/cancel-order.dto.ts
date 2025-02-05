import { IsNotEmpty } from 'class-validator';

export class CancelOrderDto {
  @IsNotEmpty()
  orderId: string;
}