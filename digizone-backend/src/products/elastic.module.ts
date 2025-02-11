// // elasticsearch.module.ts
// import { Module } from '@nestjs/common';
// import { ElasticsearchModule } from '@nestjs/elasticsearch';

// @Module({
//   imports: [
//     ElasticsearchModule.register({
//       node: 'http://localhost:9200',
//       auth: {
//         username: 'elastic',
//         password: 'jnM6wir1j7h+gbJOMN-j'
//       },
//       headers: {
//         'Authorization': 'Bearer  eyJ2ZXIiOiI4LjE0LjAiLCJhZHIiOlsiMTAuMjAuODIuMTkxOjkyMDAiXSwiZmdyIjoiZTdjMzM0ZmIwMDU2ZDE1ZjAyOTAxNGY0MjljYzAzYzJmYTRjYmI5MzJiYTRlYzExYWIzY2ZlNmEwOTYwMGUwNyIsImtleSI6IkhndlE3NVFCbUF2VWtoMi1ieE4yOkE2V1NrV2tUUWxxM29hYS1YTFp1dWcifQ=='
//       },
//       tls: {
//         rejectUnauthorized: false // Use this only if you're dealing with self-signed certificates
//       }
//     })
//   ],
//   exports: [ElasticsearchModule]
// })
// export class ElasticsearchConfigModule {}