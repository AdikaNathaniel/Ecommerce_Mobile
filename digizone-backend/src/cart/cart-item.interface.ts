export interface CartItem {
    productName: string;
    description?: string;
    image?: string;
    category?: string;
    platformType?: string;
    baseType?: string;
    productUrl?: string;
    downloadUrl?: string;
    requirementSpecification?: string[];
    highlights?: string[];
    stripeProductId?: string;
    feedbackDetails?: any[];
    skuDetails?: any[];
    createdAt?: Date;
    updatedAt?: Date;
  }