import { site } from '../data/siteConfig.js';

export function GET() {
  return new Response(
    `User-agent: *\nAllow: /\nAllow: /llms.txt\n\nSitemap: ${site.url}/sitemap-index.xml\n`,
    { headers: { 'Content-Type': 'text/plain; charset=utf-8' } },
  );
}
