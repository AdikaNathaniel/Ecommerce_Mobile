import { BadRequestException, Inject, Injectable } from '@nestjs/common';
// import Stripe from 'stripe'; // Commented out Stripe import
import { ProductRepository } from 'src/shared/repositories/product.respository';
import { Products } from 'src/shared/schema/products';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { GetProductQueryDto } from './dto/get-product-query-dto';
import qs2m from 'qs-to-mongo';
import cloudinary from 'cloudinary';
import config from 'config';
import { unlinkSync } from 'fs';
import { ProductSkuDto, ProductSkuDtoArr } from './dto/product-sku.dto';
import { OrdersRepository } from 'src/shared/repositories/order.repository';

@Injectable()
export class ProductsService {
  constructor(
    @Inject(ProductRepository) private readonly productDB: ProductRepository,
    @Inject(OrdersRepository) private readonly orderDB: OrdersRepository,
    // @Inject('STRIPE_CLIENT') private readonly stripeClient: Stripe, // Commented out Stripe client
  ) {
    cloudinary.v2.config({
      cloud_name: config.get('cloudinary.cloud_name'),
      api_key: config.get('cloudinary.api_key'),
      api_secret: config.get('cloudinary.api_secret'),
    });
  }

  async createProduct(createProductDto: CreateProductDto): Promise<{
    message: string;
    result: Products;
    success: boolean;
  }> {
    try {
      // create a product in stripe
      // if (!createProductDto.stripeProductId) {
      //   const createdProductInStripe = await this.stripeClient.products.create({
      //     name: createProductDto.productName,
      //     description: createProductDto.description,
      //   });
      //   createProductDto.stripeProductId = createdProductInStripe.id;
      // }

      const createdProductInDB = await this.productDB.create(createProductDto);
      return {
        message: 'Product created successfully',
        result: createdProductInDB,
        success: true,
      };
    } catch (error) {
      throw error;
    }
  }

  async findAllProducts(query: GetProductQueryDto) {
    try {
      let callForHomePage = false;

      if (query.homepage) {
        callForHomePage = true;
      }

      console.log('Received Query:', query);

      delete query.homepage;

      const { criteria, options, links } = qs2m(query);

      console.log('Converted Criteria:', criteria);
      console.log('Converted Options:', options);

      if (callForHomePage) {
        const products = await this.productDB.findProductWithGroupBy();
        console.log('Products for Homepage:', products);

        return {
          message:
            products.length > 0
              ? 'Products fetched successfully'
              : 'No products found',
          result: products,
          success: true,
        };
      }

      const { totalProductCount, products } = await this.productDB.find(criteria, options);
      console.log('Paginated Products:', products);

      return {
        message:
          products.length > 0
            ? 'Products fetched successfully'
            : 'No products found',
        result: {
          metadata: {
            skip: options.skip || 0,
            limit: options.limit || 10,
            total: totalProductCount,
            pages: options.limit
              ? Math.ceil(totalProductCount / options.limit)
              : 1,
            links: links('/', totalProductCount),
          },
          products,
        },
        success: true,
      };
    } catch (error) {
      console.error('Error fetching products:', error);
      throw error;
    }
  }

  async findOneProduct(id: string): Promise<{
    message: string;
    result: { product: Products; relatedProducts: Products[] };
    success: boolean;
  }> {
    try {
      const product: Products = await this.productDB.findOne({ _id: id });
      if (!product) {
        throw new Error('Product does not exist');
      }
      const relatedProducts: Products[] =
        await this.productDB.findRelatedProducts({
          category: product.category,
          _id: { $ne: id },
        });

      return {
        message: 'Product fetched successfully',
        result: { product, relatedProducts },
        success: true,
      };
    } catch (error) {
      throw error;
    }
  }

  async updateProduct(
    id: string,
    updateProductDto: CreateProductDto,
  ): Promise<{
    message: string;
    result: Products;
    success: boolean;
  }> {
    try {
      const productExist = await this.productDB.findOne({ _id: id });
      if (!productExist) {
        throw new Error('Product does not exist');
      }
      const updatedProduct = await this.productDB.findOneAndUpdate(
        { _id: id },
        updateProductDto,
      );
      // if (!updateProductDto.stripeProductId)
      //   await this.stripeClient.products.update(productExist.stripeProductId, {
      //     name: updateProductDto.productName,
      //     description: updateProductDto.description,
      //   });
      return {
        message: 'Product updated successfully',
        result: updatedProduct,
        success: true,
      };
    } catch (error) {
      throw error;
    }
  }

  async removeProductByName(productName: string): Promise<{
    message: string;
    success: boolean;
    result: null;
  }> {
    try {
      const productExist = await this.productDB.findOne({ productName });
      if (!productExist) {
        throw new Error('Product does not exist');
      }
      await this.productDB.findOneAndDelete({ productName });
      // await this.stripeClient.products.del(productExist.stripeProductId);
      return {
        message: 'Product deleted successfully',
        success: true,
        result: null,
      };
    } catch (error) {
      throw error;
    }
  }

  async uploadProductImage(
    id: string,
    file: any,
  ): Promise<{
    message: string;
    success: boolean;
    result: string;
  }> {
    try {
      const product = await this.productDB.findOne({ _id: id });
      if (!product) {
        throw new Error('Product does not exist');
      }
      if (product.imageDetails?.public_id) {
        await cloudinary.v2.uploader.destroy(product.imageDetails.public_id, {
          invalidate: true,
        });
      }

      const resOfCloudinary = await cloudinary.v2.uploader.upload(file.path, {
        folder: config.get('cloudinary.folderPath'),
        public_id: `${config.get('cloudinary.publicId_prefix')}${Date.now()}`,
        transformation: [
          {
            width: config.get('cloudinary.bigSize').toString().split('X')[0],
            height: config.get('cloudinary.bigSize').toString().split('X')[1],
            crop: 'fill',
          },
          { quality: 'auto' },
        ],
      });
      unlinkSync(file.path);
      await this.productDB.findOneAndUpdate(
        { _id: id },
        {
          imageDetails: resOfCloudinary,
          image: resOfCloudinary.secure_url,
        },
      );

      // await this.stripeClient.products.update(product.stripeProductId, {
      //   images: [resOfCloudinary.secure_url],
      // });

      return {
        message: 'Image uploaded successfully',
        success: true,
        result: resOfCloudinary.secure_url,
      };
    } catch (error) {
      throw error;
    }
  }

  async updateProductSku(productId: string, data: ProductSkuDtoArr) {
    try {
      const product = await this.productDB.findOne({ _id: productId });
      if (!product) {
        throw new Error('Product does not exist');
      }

      const skuCode = Math.random().toString(36).substring(2, 5) + Date.now();
      for (let i = 0; i < data.skuDetails.length; i++) {
        if (!data.skuDetails[i].stripePriceId) {
          // const stripPriceDetails = await this.stripeClient.prices.create({
          //   unit_amount: data.skuDetails[i].price * 100,
          //   currency: 'inr',
          //   product: product.stripeProductId,
          //   metadata: {
          //     skuCode: skuCode,
          //     lifetime: data.skuDetails[i].lifetime + '',
          //     productId: productId,
          //     price: data.skuDetails[i].price,
          //     productName: product.productName,
          //     productImage: product.image,
          //   },
          // });
          // data.skuDetails[i].stripePriceId = stripPriceDetails.id;
        }
        data.skuDetails[i].skuCode = skuCode;
      }

      const result = await this.productDB.findOneAndUpdate(
        { _id: productId },
        { $push: { skuDetails: data.skuDetails } },
      );

      return {
        message: 'Product sku updated successfully',
        success: true,
        result,
      };
    } catch (error) {
      throw error;
    }
  }

  async updateProductSkuById(
    productId: string,
    skuId: string,
    data: ProductSkuDto,
  ) {
    try {
      const product = await this.productDB.findOne({ _id: productId });
      if (!product) {
        throw new Error('Product does not exist');
      }

      const sku = product.skuDetails.find((sku) => sku._id == skuId);
      if (!sku) {
        throw new Error('Sku does not exist');
      }

      if (data.price !== sku.price) {
        // const priceDetails = await this.stripeClient.prices.create({
        //   unit_amount: data.price * 100,
        //   currency: 'inr',
        //   product: product.stripeProductId,
        //   metadata: {
        //     skuCode: sku.skuCode,
        //     lifetime: data.lifetime + '',
        //     productId: productId,
        //     price: data.price,
        //     productName: product.productName,
        //     productImage: product.image,
        //   },
        // });

        // data.stripePriceId = priceDetails.id;
      }

      const dataForUpdate = {};
      for (const key in data) {
        if (data.hasOwnProperty(key)) {
          dataForUpdate[`skuDetails.$.${key}`] = data[key];
        }
      }

      const result = await this.productDB.findOneAndUpdate(
        { _id: productId, 'skuDetails._id': skuId },
        { $set: dataForUpdate },
      );

      return {
        message: 'Product sku updated successfully',
        success: true,
        result,
      };
    } catch (error) {
      throw error;
    }
  }

  async addProductSkuLicense(
    productId: string,
    skuId: string,
    licenseKey: string,
  ) {
    try {
      const product = await this.productDB.findOne({ _id: productId });
      if (!product) {
        throw new Error('Product does not exist');
      }

      const sku = product.skuDetails.find((sku) => sku._id == skuId);
      if (!sku) {
        throw new Error('Sku does not exist');
      }

      const result = await this.productDB.createLicense(
        productId,
        skuId,
        licenseKey,
      );

      return {
        message: 'License key added successfully',
        success: true,
        result: result,
      };
    } catch (error) {
      throw error;
    }
  }

  async updateProductByName(
    productName: string,
    updateProductDto: UpdateProductDto,
  ): Promise<{
    message: string;
    result: Products;
    success: boolean;
  }> {
    try {
      const productExist = await this.productDB.findOne({ productName });
      if (!productExist) {
        throw new Error('Product does not exist');
      }
  
      // Create update data object with all properties
      const updateData = {
        productName: updateProductDto.productName,
        description: updateProductDto.description,
        image: updateProductDto.image,
        category: updateProductDto.category,
        platformType: updateProductDto.platformType,
        baseType: updateProductDto.baseType,
        productUrl: updateProductDto.productUrl,
        downloadUrl: updateProductDto.downloadUrl,
        avgRating: updateProductDto.avgRating,
        // price: updateProductDto.price,
        highlights: updateProductDto.highlights,
        updatedAt: new Date()
      };
  
      const updatedProduct = await this.productDB.findOneAndUpdate(
        { productName },
        { $set: updateData },
        // { new: true } // This option returns the updated document
      );
  
      return {
        message: 'Product updated successfully',
        result: updatedProduct,
        success: true,
      };
    } catch (error) {
      throw error;
    }
  }
  

  async removeProductSkuLicense(id: string) {
    try {
      const result = await this.productDB.removeLicense({ _id: id });

      return {
        message: 'License key removed successfully',
        success: true,
        result: result,
      };
    } catch (error) {
      throw error;
    }
  }

  async getProductSkuLicenses(productId: string, skuId: string) {
    try {
      const product = await this.productDB.findOne({ _id: productId });
      if (!product) {
        throw new Error('Product does not exist');
      }

      const sku = product.skuDetails.find((sku) => sku._id == skuId);
      if (!sku) {
        throw new Error('Sku does not exist');
      }

      const result = await this.productDB.findLicense({
        product: productId,
        productSku: skuId,
      });

      return {
        message: 'Licenses fetched successfully',
        success: true,
        result: result,
      };
    } catch (error) {
      throw error;
    }
  }

  async updateProductSkuLicense(
    productId: string,
    skuId: string,
    licenseKeyId: string,
    licenseKey: string,
  ) {
    try {
      const product = await this.productDB.findOne({ _id: productId });
      if (!product) {
        throw new Error('Product does not exist');
      }

      const sku = product.skuDetails.find((sku) => sku._id == skuId);
      if (!sku) {
        throw new Error('Sku does not exist');
      }

      const result = await this.productDB.updateLicense(
        { _id: licenseKeyId },
        { licenseKey: licenseKey },
      );

      return {
        message: 'License key updated successfully',
        success: true,
        result: result,
      };
    } catch (error) {
      throw error;
    }
  }

  async addProductReview(
    productId: string,
    rating: number,
    review: string,
    user: Record<string, any>,
  ) {
    try {
      if (!user?._id) {
        throw new BadRequestException('Invalid user data');
      }

      const product = await this.productDB.findOne({ _id: productId });
      if (!product) {
        throw new Error('Product does not exist');
      }

      // Initialize feedbackDetails if undefined
      if (!Array.isArray(product.feedbackDetails)) {
        product.feedbackDetails = [];
      }

      const existingReview = product.feedbackDetails.find(
        (value) => value?.customerId === user._id.toString()
      );

      if (existingReview) {
        throw new BadRequestException(
          'You have already given a review for this product'
        );
      }

      const order = await this.orderDB.findOne({
        customerId: user._id,
        'orderedItems.productId': productId,
      });

      if (!order) {
        throw new BadRequestException('You have not purchased this product');
      }

      const ratings: any[] = [];
      product.feedbackDetails.forEach((comment: { rating: any }) =>
        ratings.push(comment.rating),
      );

      let avgRating = String(rating);
      if (ratings.length > 0) {
        avgRating = (ratings.reduce((a, b) => a + b) / ratings.length).toFixed(
          2,
        );
      }

      const reviewDetails = {
        rating: rating,
        feedbackMsg: review,
        customerId: user._id,
        customerName: user.name,
      };

      const result = await this.productDB.findOneAndUpdate(
        { _id: productId },
        { $set: { avgRating }, $push: { feedbackDetails: reviewDetails } },
      );

      return {
        message: 'Product review added successfully',
        success: true,
        result,
      };
    } catch (error) {
      throw error;
    }
  }

  async removeProductReview(productId: string, reviewId: string) {
    try {
      const product = await this.productDB.findOne({ _id: productId });
      if (!product) {
        throw new Error('Product does not exist');
      }

      const review = product.feedbackDetails.find(
        (review) => review._id == reviewId,
      );
      if (!review) {
        throw new Error('Review does not exist');
      }

      const ratings: any[] = [];
      product.feedbackDetails.forEach((comment) => {
        if (comment._id.toString() !== reviewId) {
          ratings.push(comment.rating);
        }
      });

      let avgRating = '0';
      if (ratings.length > 0) {
        avgRating = (ratings.reduce((a, b) => a + b) / ratings.length).toFixed(
          2,
        );
      }

      const result = await this.productDB.findOneAndUpdate(
        { _id: productId },
        { $set: { avgRating }, $pull: { feedbackDetails: { _id: reviewId } } },
      );

      return {
        message: 'Product review removed successfully',
        success: true,
        result,
      };
    } catch (error) {
      throw error;
    }
  }
}