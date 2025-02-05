import { IsString, IsNumber, IsNotEmpty } from 'class-validator';

export class UpdateCartDto {
  @IsString()
  @IsNotEmpty()
  productName: string;

  @IsNumber()
  @IsNotEmpty()
  quantity: number;
}