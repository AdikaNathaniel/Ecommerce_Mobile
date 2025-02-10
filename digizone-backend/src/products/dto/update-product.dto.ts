export interface UpdateProductDto {
    productName: string;
    description: string;
    image: string;
    category: string;
    platformType: string;
    baseType: string;
    productUrl: string;
    downloadUrl: string;
    avgRating: number;
    // price: number;
    highlights: string[];
  }