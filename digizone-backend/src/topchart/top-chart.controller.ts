import {
    Controller,
    Get,
    Post,
    Body,
    Param,
    Delete,
    Put,
    Query,
    HttpCode,
    HttpStatus,
  } from '@nestjs/common';
  import { TopChartsService } from 'src/topchart/top-chart.service';
  import { CreateTopChartDto } from 'src/users/dto/create-top-chart.dto';
  import { UpdateTopChartDto } from 'src/users/dto/update-top-chart.dto';
  
  @Controller('top-charts')
  export class TopChartsController {
    constructor(private readonly topChartsService: TopChartsService) {}
  
    @Post()
    async create(@Body() createTopChartDto: CreateTopChartDto) {
      return await this.topChartsService.create(createTopChartDto);
    }
  
    @Get()
    async findAll() {
      return await this.topChartsService.findAll();
    }
  
    @Get(':id')
    async findOne(@Param('id') id: string) {
      return await this.topChartsService.findOne(id);
    }
  
    @Put(':id')
    async update(
      @Param('id') id: string,
      @Body() updateTopChartDto: UpdateTopChartDto,
    ) {
      return await this.topChartsService.update(id, updateTopChartDto);
    }
  
    @Delete(':id')
    async remove(@Param('id') id: string) {
      return await this.topChartsService.remove(id);
    }
  
    @Get('filter/category')
    async filterByCategory(@Query('category') category: string) {
      return await this.topChartsService.filterByCategory(category);
    }
  }