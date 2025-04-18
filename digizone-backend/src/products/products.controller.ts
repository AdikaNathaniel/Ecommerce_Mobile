import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  UseInterceptors,
  UploadedFile,
  Req,
} from '@nestjs/common';
import { ProductsService } from './products.service';
import { CreateProductDto } from './dto/create-product.dto';
import { UpdateProductDto } from './dto/update-product.dto';
import { Roles } from 'src/shared/middleware/role.decorators';
import { userTypes } from 'src/shared/schema/users';
import { GetProductQueryDto } from './dto/get-product-query-dto';
import { FileInterceptor } from '@nestjs/platform-express';
import config from 'config';
import { ProductSkuDto, ProductSkuDtoArr } from './dto/product-sku.dto';

@Controller('products')
export class ProductsController {
  constructor(private readonly productsService: ProductsService) {}

  @Post()
  async create(@Body() createProductDto: CreateProductDto) {
    return await this.productsService.createProduct(createProductDto);
  }

  @Get()
  findAll(@Query() query: GetProductQueryDto) {
    return this.productsService.findAllProducts(query);
  }

  @Get(':id')
  async findOne(@Param('id') id: string) {
    return this.productsService.findOneProduct(id);
  }

  @Patch(':id')
  @Roles(userTypes.ADMIN, userTypes.SELLER)
  async update(
    @Param('id') id: string,
    @Body() updateProductDto: CreateProductDto,
  ) {
    return await this.productsService.updateProduct(id, updateProductDto);
  }

  @Delete('name/:productName')
  removeByName(@Param('productName') productName: string) {
    return this.productsService.removeProductByName(productName);
  }

  @Post('/:id/image')
  @Roles(userTypes.ADMIN)
  @UseInterceptors(
    FileInterceptor('productImage', {
      dest: config.get('fileStoragePath'),
      limits: {
        fileSize: 3145728, // 3 MB
      },
    }),
  )
  async uploadProductImage(
    @Param('id') id: string,
    @UploadedFile() file: ParameterDecorator,
  ) {
    return await this.productsService.uploadProductImage(id, file);
  }

  @Post('update/:productName')
  updateByName(
    @Param('productName') productName: string,
    @Body() updateProductDto: UpdateProductDto,
  ) {
    return this.productsService.updateProductByName(productName, updateProductDto);
  }
}

  // @Post('/:productId/skus')
  // @Roles(userTypes.ADMIN)
  // async updateProductSku(
  //   @Param('productId') productId: string,
  //   @Body() updateProductSkuDto: ProductSkuDtoArr,
  // ) {
  //   return await this.productsService.updateProductSku(
  //     productId,
  //     updateProductSkuDto,
  //   );
  // }

  // @Put('/:productId/skus/:skuId')
  // @Roles(userTypes.ADMIN)
  // async updateProductSkuById(
  //   @Param('productId') productId: string,
  //   @Param('skuId') skuId: string,
  //   @Body() updateProductSkuDto: ProductSkuDto,
  // ) {
  //   return await this.productsService.updateProductSkuById(
  //     productId,
  //     skuId,
  //     updateProductSkuDto,
  //   );
  // }

  // @Post('/:productId/skus/:skuId/licenses')
  // @Roles(userTypes.ADMIN)
  // async addProductSkuLicense(
  //   @Param('productId') productId: string,
  //   @Param('skuId') skuId: string,
  //   @Body('licenseKey') licenseKey: string,
  // ) {
  //   return await this.productsService.addProductSkuLicense(
  //     productId,
  //     skuId,
  //     licenseKey,
  //   );
  // }

  // @Get('/:productId/skus/:skuId/licenses')
  // @Roles(userTypes.ADMIN)
  // async getProductSkuLicenses(
  //   @Param('productId') productId: string,
  //   @Param('skuId') skuId: string,
  // ) {
  //   return await this.productsService.getProductSkuLicenses(productId, skuId);
  // }

  // @Put('/:productId/skus/:skuId/licenses/:licenseKeyId')
  // @Roles(userTypes.ADMIN)
  // async updateProductSkuLicense(
  //   @Param('productId') productId: string,
  //   @Param('skuId') skuId: string,
  //   @Param('licenseKeyId') licenseKeyId: string,
  //   @Body('licenseKey') licenseKey: string,
  // ) {
  //   return await this.productsService.updateProductSkuLicense(
  //     productId,
  //     skuId,
  //     licenseKeyId,
  //     licenseKey,
  //   );
  // }

  // @Post('/:productId/reviews')
  // @Roles(userTypes.CUSTOMER)
  // async addProductReview(
  //   @Param('productId') productId: string,
  //   @Body('rating') rating: number,
  //   @Body('review') review: string,
  //   @Req() req: any,
  // ) {
  //   return await this.productsService.addProductReview(
  //     productId,
  //     rating,
  //     review,
  //     req.user,
  //   );
  // }

  // @Delete('/:productId/reviews/:reviewId')
  // async removeProductReview(
  //   @Param('productId') productId: string,
  //   @Param('reviewId') reviewId: string,
  // ) {
  //   return await this.productsService.removeProductReview(productId, reviewId);
  // }
// }