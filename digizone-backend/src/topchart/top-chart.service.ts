import { Injectable, Inject } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { TopChart } from 'src/shared/schema/top-chart.schema';
import { CreateTopChartDto } from 'src/users/dto/create-top-chart.dto';
import { UpdateTopChartDto } from 'src/users/dto/update-top-chart.dto';

@Injectable()
export class TopChartsService {
  constructor(
    @InjectModel(TopChart.name) private readonly topChartModel: Model<TopChart>,
  ) {}

  async create(createTopChartDto: CreateTopChartDto) {
    try {
      const createdTopChart = new this.topChartModel(createTopChartDto);
      await createdTopChart.save();

      return {
        success: true,
        message: 'Product created successfully',
        result: createdTopChart,
      };
    } catch (error) {
      throw error;
    }
  }

  async findAll() {
    try {
      const topCharts = await this.topChartModel.find().exec();

      return {
        success: true,
        message: 'Products retrieved successfully',
        result: topCharts,
      };
    } catch (error) {
      throw error;
    }
  }

  async findOne(id: string) {
    try {
      const product = await this.topChartModel.findById(id).exec();
      if (!product) {
        return {
          success: false,
          message: 'Product not found',
          result: null,
        };
      }

      return {
        success: true,
        message: 'Product retrieved successfully',
        result: product,
      };
    } catch (error) {
      throw error;
    }
  }

  async update(id: string, updateTopChartDto: UpdateTopChartDto) {
    try {
      const updatedProduct = await this.topChartModel.findByIdAndUpdate(
        id,
        updateTopChartDto,
        { new: true },
      );

      if (!updatedProduct) {
        return {
          success: false,
          message: 'Product not found',
          result: null,
        };
      }

      return {
        success: true,
        message: 'Product updated successfully',
        result: updatedProduct,
      };
    } catch (error) {
      throw error;
    }
  }

  async remove(id: string) {
    try {
      const deletedProduct = await this.topChartModel.findByIdAndDelete(id);

      if (!deletedProduct) {
        return {
          success: false,
          message: 'Product not found',
          result: null,
        };
      }

      return {
        success: true,
        message: 'Product deleted successfully',
        result: deletedProduct,
      };
    } catch (error) {
      throw error;
    }
  }

  async filterByCategory(category: string) {
    try {
      const products = await this.topChartModel.find({ category }).exec();

      return {
        success: true,
        message: 'Products filtered by category successfully',
        result: products,
      };
    } catch (error) {
      throw error;
    }
  }
}