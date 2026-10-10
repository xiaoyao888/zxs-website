import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const SITE_URL = 'https://www.mpss.cn';

export default defineConfig({
  site: SITE_URL,
  output: 'static',
  devToolbar: { enabled: false },
  build: {
    format: 'file',
    assets: 'zxs_assets',
    emptyOutDir: true,
    inlineStylesheets: 'auto',
    rollupOptions: {
      output: { manualChunks: undefined },
      plugins: [
        {
          name: 'safe-html-comment-remover',
          generateBundle(_options, bundle) {
            if (process.env.NODE_ENV !== 'production') return;
            Object.keys(bundle).forEach((fileName) => {
              if (!fileName.endsWith('.html')) return;
              const htmlAsset = bundle[fileName];
              if (htmlAsset.type === 'asset' && typeof htmlAsset.source === 'string') {
                htmlAsset.source = htmlAsset.source
                  .replace(/^\s*<!--[\s\S]*?-->\s*$/gm, '')
                  .replace(/<!--astro:end-->/g, '')
                  .replace(/<!--\s*[^>\n\r]{1,80}\s*-->/g, '');
              }
            });
          },
        },
      ],
    },
  },
  compressHTML: true,
  integrations: [
    sitemap({
      i18n: { defaultLocale: 'zh-CN', locales: { 'zh-CN': 'zh-CN' } },
      serialize(item) {
        const isHome = item.url === SITE_URL || item.url === `${SITE_URL}/`;
        return { url: item.url, changefreq: isHome ? 'weekly' : 'monthly', priority: isHome ? 1 : 0.8 };
      },
    }),
  ],
  vite: {
    resolve: { alias: { '@': path.resolve(__dirname, './src') } },
    build: {
      cssCodeSplit: true,
      minify: 'terser',
      terserOptions: { format: { comments: false }, compress: { drop_console: true, drop_debugger: true } },
      reportCompressedSize: false,
    },
  },
  server: { host: '0.0.0.0', port: 4321 },
});
