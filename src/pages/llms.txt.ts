import { aiOverview, companyInfo, localSeo, navLinks, articles } from '../data/siteConfig.js';

export function GET() {
  const pages = navLinks.map((link) => `- ${link.name}: ${link.href}`).join('\n');
  const facts = aiOverview.facts.map((item) => `- ${item}`).join('\n');
  const services = localSeo.serviceType.map((item) => `- ${item}`).join('\n');
  const articlesText = articles.map((item) => `- ${item.title}: /${item.section}/${item.id}.html，${item.summary}`).join('\n');
  const content = `# 星火AI自习空间\n\n${aiOverview.summary}\n\n## 关键事实\n${facts}\n\n## 服务范围\n- ${localSeo.province}${localSeo.locality}${localSeo.district}\n- ${localSeo.areaServed.join('、')}\n\n## 核心服务\n${services}\n\n## 主要页面\n${pages}\n\n## 内容索引\n${articlesText}\n\n## 联系方式\n- 电话：${companyInfo.phone}\n- 邮箱：${companyInfo.email}\n- 地址：${companyInfo.address}\n`;

  return new Response(content, { headers: { 'Content-Type': 'text/plain; charset=utf-8' } });
}
