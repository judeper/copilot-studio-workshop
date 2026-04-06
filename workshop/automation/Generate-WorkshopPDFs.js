/**
 * Generate-WorkshopPDFs.js
 *
 * Converts workshop Markdown content into 10 branded PDF files:
 *   Student:      S1 (Welcome), S2 (Day 1 Workbook), S3 (Day 2 Workbook), S4 (Dev Lab)
 *   Facilitator:  F1 (Guide), F2 (Readiness Pack), F3 (Validation), F4 (Timing), F5 (Splitting), F6 (Slides)
 *
 * Usage:  node Generate-WorkshopPDFs.js [--only S1,F2,...]
 */

const fs = require('fs');
const path = require('path');
const { marked } = require('marked');
const puppeteer = require('puppeteer');

// ---------------------------------------------------------------------------
// Paths
// ---------------------------------------------------------------------------
const WORKSHOP = path.resolve(__dirname, '..');
const OUT_DIR = path.join(WORKSHOP, 'pdf-output');
const LABS_DIR = path.join(WORKSHOP, 'labs');

// ---------------------------------------------------------------------------
// PDF definitions
// ---------------------------------------------------------------------------
const PDF_DEFS = [
  // ---- Student PDFs ----
  {
    id: 'S1',
    filename: '01-Student-Welcome-and-Overview.pdf',
    title: 'Welcome & Overview',
    subtitle: 'Copilot Studio Workshop — Participant Guide',
    audience: 'Student',
    sources: [rel('participant-guide/welcome-and-overview.md')],
  },
  {
    id: 'S2',
    filename: '02-Student-Workbook-Day1-Foundation.pdf',
    title: 'Day 1 — Foundation Track',
    subtitle: 'Student Workbook · Labs 00–12',
    audience: 'Student',
    sources: [
      rel('participant-guide/day1-foundation-guide.md'),
      ...labReadmes(0, 12),
    ],
  },
  {
    id: 'S3',
    filename: '03-Student-Workbook-Day2-Enterprise.pdf',
    title: 'Day 2 — Enterprise Track',
    subtitle: 'Student Workbook · Labs 13–24',
    audience: 'Student',
    sources: [
      rel('participant-guide/day2-enterprise-guide.md'),
      ...labReadmes(13, 24),
    ],
  },
  {
    id: 'S4',
    filename: '04-Student-Workbook-Optional-Developer-Lab.pdf',
    title: 'Optional Developer Lab',
    subtitle: 'Student Workbook · Lab 25 — VS Code Extension',
    audience: 'Student',
    sources: labReadmes(25, 25),
  },
  // ---- Facilitator PDFs ----
  {
    id: 'F1',
    filename: '01-Facilitator-Guide.pdf',
    title: 'Facilitator Guide',
    subtitle: 'Copilot Studio Workshop — Delivery Flow & Recovery',
    audience: 'Facilitator',
    sources: [rel('facilitator-guide/facilitator-guide.md')],
  },
  {
    id: 'F2',
    filename: '02-Facilitator-Environment-Readiness-Pack.pdf',
    title: 'Environment Readiness Pack',
    subtitle: 'Environment Checklist + Morning-of Smoke Tests',
    audience: 'Facilitator',
    sources: [
      rel('facilitator-guide/environment-checklist.md'),
      rel('tests/environment-smoke-tests.md'),
    ],
  },
  {
    id: 'F3',
    filename: '03-Facilitator-Session-Splitting-Guide.pdf',
    title: 'Session Splitting Guide',
    subtitle: 'Alternative Delivery Formats (8-Session & 6-Session)',
    audience: 'Facilitator',
    sources: [rel('assets/session-splitting-guide.md')],
  },
  {
    id: 'F4',
    filename: '04-Facilitator-Lab-Timing-Guide.pdf',
    title: 'Lab Timing Guide',
    subtitle: 'Minute-by-Minute Schedule — Day 1 & Day 2',
    audience: 'Facilitator',
    sources: [rel('assets/lab-timing-guide.md')],
  },
  {
    id: 'F5',
    filename: '05-Facilitator-Slide-Deck-Outline.pdf',
    title: 'Slide Deck Outline',
    subtitle: 'Speaker Notes & Transitions — Day 1 & Day 2',
    audience: 'Facilitator',
    sources: [rel('assets/slide-deck-outline.md')],
  },
  {
    id: 'F6',
    filename: '06-Facilitator-Lab-Validation-Reference.pdf',
    title: 'Lab Validation & Troubleshooting',
    subtitle: 'Per-Lab Success Criteria · Labs 00–24',
    audience: 'Facilitator',
    sources: [rel('tests/validation-checklist.md')],
  },
];

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
function rel(p) {
  return path.join(WORKSHOP, ...p.split('/'));
}

function labReadmes(from, to) {
  const results = [];
  for (let i = from; i <= to; i++) {
    const num = String(i).padStart(2, '0');
    const dir = fs.readdirSync(LABS_DIR).find((d) => d.startsWith(`lab-${num}`));
    if (dir) results.push(path.join(LABS_DIR, dir, 'README.md'));
  }
  return results;
}

function readMd(filePath) {
  if (!fs.existsSync(filePath)) {
    console.warn(`  ⚠ Missing: ${filePath}`);
    return '';
  }
  return fs.readFileSync(filePath, 'utf-8');
}

/** Resolve image references relative to the Markdown file's directory */
function resolveImages(md, mdDir) {
  return md.replace(/!\[([^\]]*)\]\(([^)]+)\)/g, (_match, alt, src) => {
    if (/^https?:\/\//.test(src)) return _match;
    const abs = path.resolve(mdDir, src);
    if (!fs.existsSync(abs)) return _match;
    const ext = path.extname(abs).slice(1).toLowerCase();
    const mime = ext === 'svg' ? 'image/svg+xml' : `image/${ext === 'jpg' ? 'jpeg' : ext}`;
    const b64 = fs.readFileSync(abs).toString('base64');
    return `![${alt}](data:${mime};base64,${b64})`;
  });
}

function buildHtml(def) {
  const sections = def.sources.map((src) => {
    const raw = readMd(src);
    const resolved = resolveImages(raw, path.dirname(src));
    return marked.parse(resolved);
  });

  const audienceColor = def.audience === 'Student' ? '#0078d4' : '#107c10';
  const audienceLabel = def.audience === 'Student' ? '📘 Student' : '📗 Facilitator';

  return `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<style>
  @page {
    margin: 20mm 18mm 22mm 18mm;
    @bottom-center {
      content: counter(page);
      font-size: 9pt;
      color: #666;
    }
  }
  body {
    font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
    font-size: 11pt;
    line-height: 1.55;
    color: #1a1a1a;
    max-width: 100%;
  }
  /* Cover page */
  .cover {
    page-break-after: always;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    min-height: 85vh;
    text-align: center;
  }
  .cover .audience-label {
    display: inline-block;
    padding: 4px 14px;
    border-radius: 4px;
    font-size: 10pt;
    font-weight: 600;
    color: #fff;
    background: ${audienceColor};
    margin-bottom: 24px;
  }
  .cover h1 {
    font-size: 28pt;
    font-weight: 700;
    margin: 0 0 12px 0;
    color: #1a1a1a;
  }
  .cover .subtitle {
    font-size: 13pt;
    color: #555;
    margin-bottom: 32px;
  }
  .cover .meta {
    font-size: 9.5pt;
    color: #888;
  }
  /* Content */
  h1 { font-size: 20pt; color: ${audienceColor}; border-bottom: 2px solid ${audienceColor}; padding-bottom: 4px; margin-top: 28px; }
  h2 { font-size: 16pt; color: #333; margin-top: 22px; }
  h3 { font-size: 13pt; color: #444; margin-top: 18px; }
  h4 { font-size: 11.5pt; color: #555; margin-top: 14px; }
  code {
    font-family: 'Cascadia Code', 'Consolas', monospace;
    font-size: 9.5pt;
    background: #f4f4f4;
    padding: 1px 4px;
    border-radius: 3px;
  }
  pre {
    background: #f6f8fa;
    border: 1px solid #e1e4e8;
    border-radius: 6px;
    padding: 12px 16px;
    overflow-x: auto;
    font-size: 9pt;
    line-height: 1.45;
  }
  pre code { background: none; padding: 0; }
  table {
    border-collapse: collapse;
    width: 100%;
    margin: 12px 0;
    font-size: 10pt;
  }
  th, td {
    border: 1px solid #d0d7de;
    padding: 6px 10px;
    text-align: left;
  }
  th { background: #f6f8fa; font-weight: 600; }
  tr:nth-child(even) { background: #fafbfc; }
  blockquote {
    margin: 12px 0;
    padding: 8px 16px;
    border-left: 4px solid ${audienceColor};
    background: #f8f9fa;
    color: #333;
  }
  blockquote strong { color: ${audienceColor}; }
  img {
    max-width: 100%;
    height: auto;
    border: 1px solid #e1e4e8;
    border-radius: 6px;
    margin: 8px 0;
  }
  hr {
    border: none;
    border-top: 1px solid #d0d7de;
    margin: 24px 0;
  }
  .section-break {
    page-break-before: always;
  }
  a { color: ${audienceColor}; text-decoration: none; }
  ul, ol { padding-left: 24px; }
  li { margin-bottom: 3px; }
</style>
</head>
<body>
  <div class="cover">
    <div class="audience-label">${audienceLabel}</div>
    <h1>${def.title}</h1>
    <div class="subtitle">${def.subtitle}</div>
    <div class="meta">Copilot Studio Workshop &middot; Generated ${new Date().toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric' })}</div>
  </div>
  ${sections.map((html, i) => `<div class="${i > 0 ? 'section-break' : ''}">${html}</div>`).join('\n')}
</body>
</html>`;
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
async function main() {
  // Parse --only filter
  const onlyArg = process.argv.find((a) => a.startsWith('--only'));
  let filter = null;
  if (onlyArg) {
    const val = onlyArg.includes('=') ? onlyArg.split('=')[1] : process.argv[process.argv.indexOf(onlyArg) + 1];
    filter = val.split(',').map((s) => s.trim().toUpperCase());
  }

  const defs = filter ? PDF_DEFS.filter((d) => filter.includes(d.id.toUpperCase())) : PDF_DEFS;

  if (!fs.existsSync(OUT_DIR)) fs.mkdirSync(OUT_DIR, { recursive: true });

  console.log(`\n📄 Generating ${defs.length} PDF(s) → ${OUT_DIR}\n`);

  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  for (const def of defs) {
    const label = `[${def.id}] ${def.filename}`;
    process.stdout.write(`  ⏳ ${label} ...`);

    try {
      const html = buildHtml(def);
      const page = await browser.newPage();
      await page.setContent(html, { waitUntil: 'networkidle0', timeout: 60000 });
      await page.pdf({
        path: path.join(OUT_DIR, def.filename),
        format: 'A4',
        printBackground: true,
        displayHeaderFooter: true,
        headerTemplate: `<div style="font-size:8pt;color:#999;width:100%;text-align:center;padding:4px 18mm 0 18mm;">
          <span>${def.audience === 'Student' ? '📘' : '📗'} ${def.title} — Copilot Studio Workshop</span>
        </div>`,
        footerTemplate: `<div style="font-size:8pt;color:#999;width:100%;text-align:center;padding:0 18mm 4px 18mm;">
          Page <span class="pageNumber"></span> of <span class="totalPages"></span>
        </div>`,
        margin: { top: '28mm', bottom: '22mm', left: '18mm', right: '18mm' },
      });
      await page.close();
      console.log(' ✅');
    } catch (err) {
      console.log(` ❌ ${err.message}`);
    }
  }

  await browser.close();
  console.log(`\n✅ Done. PDFs saved to: ${OUT_DIR}\n`);
}

main().catch((err) => {
  console.error('Fatal:', err);
  process.exit(1);
});
