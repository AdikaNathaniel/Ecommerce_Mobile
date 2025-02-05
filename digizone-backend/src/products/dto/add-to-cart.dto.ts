import { IsNumber, Min, IsString } from 'class-validator';

export class AddToCartDto {
  @IsString() // This now represents the product name
  productName: string;

  @IsNumber()
  @Min(1)
  quantity: number; // Quantity of the product
}