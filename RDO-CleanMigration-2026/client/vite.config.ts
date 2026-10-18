import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  base: '/app/',
  build: {
    outDir: '../RDO-CleanMigration-2026/RdoApp.Core/wwwroot/app',
    emptyOutDir: true,
  },
  server: {
    proxy: {
      '/api': {
        target: 'https://localhost:7176',
        changeOrigin: true,
        secure: false,
      },
      '/Account': {
        target: 'https://localhost:7176',
        changeOrigin: true,
        secure: false,
      },
      '/Obra': {
        target: 'https://localhost:7176',
        changeOrigin: true,
        secure: false,
      },
    },
  },
})
