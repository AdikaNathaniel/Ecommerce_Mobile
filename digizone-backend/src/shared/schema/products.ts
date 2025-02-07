import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export enum categoryType {
  operatingSystem = 'Operating System',
  applicationSoftware = 'Application Software',
}

export enum platformType {
  windows = 'Windows',
  mac = 'Mac',
  linux = 'Linux',
  android = 'Android',
  ios = 'iOS',
  ubuntu = 'Ubuntu',
}

export enum baseType {
  computer = 'Computer',
  mobile = 'Mobile',
}

@Schema({ timestamps: true })
export class Feedbackers extends Document {
  @Prop({ required: true })
  customerId: string;

  @Prop({ required: true })
  customerName: string;

  @Prop({ required: true, min: 1, max: 5 })
  rating: number;

  @Prop({ required: true })
  feedbackMsg: string;
}

export const FeedbackSchema = SchemaFactory.createForClass(Feedbackers);

@Schema({ timestamps: true })
export class SkuDetails extends Document {
  @Prop({ required: true })
  skuName: string;

  @Prop({ required: true, default: 0 })
  price: number;

  @Prop({ default: 0 }) // Default validity to avoid null
  validity: number;

  @Prop({ default: false }) // Default to false to avoid null
  lifetime: boolean;

  @Prop({ default: '' }) // Avoid null issues with empty string
  stripePriceId: string;

  @Prop({ default: '' }) // Avoid null issues
  skuCode: string;
}

export const SkuDetailsSchema = SchemaFactory.createForClass(SkuDetails);

@Schema({ timestamps: true })
export class Products extends Document {
  @Prop({ required: true })
  productName: string;

  @Prop({ required: true })
  description: string;

  @Prop({
    default:
      'https://us.123rf.com/450wm/pavelstasevich/pavelstasevich1811/pavelstasevich181101027/112815900-no-image-available-icon-flat-vector.jpg?ver=6',
  })
  image: string;

  @Prop({
    required: true,
    type: String,
    enum: Object.values(categoryType),
  })
  category: categoryType;

  @Prop({
    required: true,
    type: String,
    enum: Object.values(platformType),
  })
  platformType: platformType;

  @Prop({
    required: true,
    type: String,
    enum: Object.values(baseType),
  })
  baseType: baseType;

  @Prop({ default: '' }) // Ensure no null values
  productUrl: string;

  @Prop({ default: '' }) // Ensure no null values
  downloadUrl: string;

  @Prop({ default: 0 }) // Default to 0 to prevent null issues
  avgRating: number;

  @Prop({ type: [FeedbackSchema], default: [] }) // Ensure an empty array
  feedbackDetails: Feedbackers[];

  @Prop({ type: [SkuDetailsSchema], default: [] }) // Ensure an empty array
  skuDetails: SkuDetails[];

  @Prop({ type: Object, default: {} }) // Default to empty object
  imageDetails: Record<string, any>;

  @Prop({ type: [Object], default: [] }) // Default to empty array
  requirementSpecification: Record<string, any>[];

  @Prop({ type: [String], default: [] }) // Default to empty array
  highlights: string[];

  @Prop({ default: '' }) // Ensure no null values
  stripeProductId: string;
}

export const ProductSchema = SchemaFactory.createForClass(Products);
