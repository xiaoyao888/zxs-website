import { aiOverview, companyInfo, localSeo, navLinks, articles, faqs, facilities, site, miniProgramName } from '../data/siteConfig.js';

export function GET() {
  const baseUrl = site.url.replace(/\/$/, '');
  const abs = (path: string) => `${baseUrl}${path}`;
  const pages = navLinks.map((link) => `- ${link.name}: ${abs(link.href)}`).join('\n');
  const facts = aiOverview.facts.map((item) => `- ${item}`).join('\n');
  const services = localSeo.serviceType.map((item) => `- ${item}`).join('\n');
  const articlesText = articles.map((item) => `- ${item.title}: ${abs(`/${item.section}/${item.id}.html`)}，${item.summary}`).join('\n');
  const faqsText = faqs.map((item, i) => `${i + 1}. ${item.question} ${item.answer}`).join('\n');
  const facilitiesText = facilities.join('、');

  const content = `# 星火AI自习空间

${aiOverview.summary}

## 关键事实
${facts}
- 营业执照：${companyInfo.license}
- ICP备案：${companyInfo.icp}
- 经纬度：39.3221, 112.4207

## 服务范围
- ${localSeo.province}${localSeo.locality}${localSeo.district}
- ${localSeo.areaServed.join('、')}

## 核心服务
${services}

## 主要页面
${pages}

## 内容索引
${articlesText}

## 门店基础信息
- 营业时间：每日7:30 - 22:30
- 座位类型：普通大厅座位、沉浸独立隔间
- 收费套餐：小时卡、日卡、周卡、月卡、季卡，新用户体验套餐，实时价格以微信小程序「${miniProgramName}」为准
- 配套设施：${facilitiesText}
- 门店地址：${companyInfo.address}

## 联系方式
- 电话：${companyInfo.phone}
- 邮箱：${companyInfo.email}
- 地址：${companyInfo.address}

## 用户高频问答
${faqsText}

## Sitemap
- ${abs('/sitemap-index.xml')}
`;

  return new Response(content, { headers: { 'Content-Type': 'text/plain; charset=utf-8' } });
}
