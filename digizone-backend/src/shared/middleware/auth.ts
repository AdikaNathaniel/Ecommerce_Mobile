import {
  Inject,
  Injectable,
  NestMiddleware,
  UnauthorizedException,
} from '@nestjs/common';
import { NextFunction, Request, Response } from 'express';
import { UserRepository } from '../repositories/user.repository';
import { decodeAuthToken } from '../utility/token-generator';

@Injectable()
export class AuthMiddleware implements NestMiddleware {
  constructor(
    @Inject(UserRepository) private readonly userDB: UserRepository,
  ) {}

  async use(req: Request | any, res: Response, next: NextFunction) {
    try {
      console.log('AuthMiddleware', req.headers);

      // Allow access to specific public routes
      if (this.isPublicRoute(req.path, req.method) || this.isCsrfSkippedRoute(req.originalUrl)) {
        return next();
      }

      const token = req.cookies._digi_auth_token;
      if (!token) {
        // Check if the user can access without a token
        if (this.isRoleAllowedWithoutToken(req.path, req.method, req.user)) {
          return next();
        }
        throw new UnauthorizedException('Missing auth token');
      }

      const decodedData: any = decodeAuthToken(token);
      const user = await this.userDB.findById(decodedData.id);
      if (!user) {
        throw new UnauthorizedException('Unauthorized');
      }

      user.password = undefined;
      req.user = user;

      // Check again if the user's role allows them to access without a token
      if (this.isRoleAllowedWithoutToken(req.path, req.method, user)) {
        return next();
      }

      next();
    } catch (error) {
      throw new UnauthorizedException(error.message);
    }
  }

  private isRoleAllowedWithoutToken(path: string, method: string, user: any): boolean {
    // Routes where certain roles can bypass authentication
    const allowedRoutes = [
      { path: '/api/v1/products', method: 'POST' }, // Allow product creation
      { path: '/api/v1/products', method: 'DELETE' }, // Allow product deletion
    ];

    const isAllowedRoute = allowedRoutes.some(route => path === route.path && method === route.method);

    // Allow only if the user exists and is either a Seller or an Admin
    if (isAllowedRoute && user && (user.role === 'Seller' || user.role === 'Admin')) {
      return true;
    }

    return false;
  }

  private isPublicRoute(path: string, method: string): boolean {
    const publicRoutes = [
      // App routes
      { path: '/api/v1', method: 'GET' },
      { path: '/api/v1/test', method: 'GET' },
      { path: '/api/v1/csrf-token', method: 'GET' },

      // User routes
      { path: '/api/v1/users', method: 'POST' }, // signup
      { path: '/api/v1/users', method: 'GET' }, // get all users
      { path: '/api/v1/users/login', method: 'POST' },
      { path: '/api/v1/users/verify-email', method: 'GET' },
      { path: '/api/v1/users/send-otp-email', method: 'GET' },
      { path: '/api/v1/users/logout', method: 'PUT' },
      { path: '/api/v1/users/forgot-password', method: 'GET' },
      { path: '/api/v1/users/update-name-password', method: 'PATCH' },
      { path: '/api/v1/users', method: 'DELETE' },

      // Product routes
      { path: '/api/v1/products', method: 'GET' }, // View all products
      { path: '/api/v1/products/', method: 'GET' }, // View single product
      { path: '/api/v1/products/', method: 'PATCH' },
      { path: '/api/v1/products/', method: 'DELETE' },

      // Order routes
      { path: '/api/v1/orders/webhook', method: 'POST' }
    ];

    return publicRoutes.some(route => {
      const pathMatch = path.startsWith(route.path);
      return pathMatch && method === route.method;
    });
  }

  private isCsrfSkippedRoute(url: string): boolean {
    return url.includes('/orders/webhook');
  }
}
