import { Schema, Document } from 'mongoose';
import { Prop, SchemaFactory, Schema as SchemaDecorator } from '@nestjs/mongoose';

@SchemaDecorator({ timestamps: true })
export class Favorite extends Document {
  @Prop({ required: true })
  productName: string;

//   @Prop({ required: true })
//   price: number;

//   @Prop({ required: true })
//   status: string; 

  @Prop({ required: true })
  image: string;

  @Prop({ required: true })
  category: string;
}

export const FavoriteSchema = SchemaFactory.createForClass(Favorite);