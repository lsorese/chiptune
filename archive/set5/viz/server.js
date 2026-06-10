#!/usr/bin/env node
'use strict';

/**
 * Sonic Pi viz + control relay
 *
 * Setup:
 *   npm install && npm start
 *   Open http://localhost:3000 in Chrome
 *
 * For real audio scope:
 *   Install BlackHole, create a Multi-Output Device (Speakers + BlackHole 2ch),
 *   set it as system output, click "Enable Audio" in page → select BlackHole 2ch.
 */

const osc  = require('osc');
const { WebSocketServer } = require('ws');
const http = require('http');
const fs   = require('fs');
const os   = require('os');
const path = require('path');
const { execSync } = require('child_process');
const yaml = require('js-yaml');

const HTTP_PORT = 3000;
const SET_DIR   = path.resolve(__dirname, '..');

// ── Load set.yml ───────────────────────────────────────────────────────────────
function loadConfig() {
  const raw = fs.readFileSync(path.join(__dirname, 'set.yml'), 'utf8');
  const cfg = yaml.load(raw);
  const setlist = cfg.setlist.map(t => t.id);
  const trackFiles = Object.fromEntries(cfg.setlist.map(t => [t.id, t.file]));
  return { setlist, trackFiles, tracks: cfg.setlist };
}

let { setlist: SETLIST, trackFiles: TRACK_FILES, tracks: TRACKS } = loadConfig();
// Hot-reload config on SIGHUP
process.on('SIGHUP', () => {
  try {
    ({ setlist: SETLIST, trackFiles: TRACK_FILES, tracks: TRACKS } = loadConfig());
    console.log('  ↺  set.yml reloaded');
  } catch(e) { console.error('  ✗  set.yml reload failed:', e.message); }
});

// ── Read Sonic Pi's dynamic port + token from running process ─────────────────
function getSonicPiConfig() {
  try {
    const ps   = execSync('ps aux', { encoding: 'utf8' });
    const line = ps.split('\n').find(l =>
      l.includes('spider-server.rb') && l.includes(' -u ')
    );
    if (!line) return null;
    const portMatch = line.match(/-u\s+(\d+)/);
    if (!portMatch) return null;
    const fields = line.trim().split(/\s+/);
    const token  = parseInt(fields[fields.length - 1], 10);
    if (isNaN(token)) return null;
    return { port: parseInt(portMatch[1], 10), token };
  } catch {
    return null;
  }
}

// ── OSC sender (separate from receiver, OS picks local port) ───────────────────
const sender = new osc.UDPPort({ localAddress: '0.0.0.0', localPort: 0, metadata: true });
sender.open();

function sonicPiStop() {
  const cfg = getSonicPiConfig();
  if (!cfg) { console.error('  ✗  spider.log not found — is Sonic Pi running?'); return; }
  sender.send({ address: '/stop-all-jobs', args: [{ type: 'i', value: cfg.token }] },
    '127.0.0.1', cfg.port);
  console.log(`  → /stop-all-jobs  port=${cfg.port}`);
}

function sonicPiRun(code) {
  const cfg = getSonicPiConfig();
  if (!cfg) { console.error('  ✗  spider.log not found — is Sonic Pi running?'); return; }
  sender.send({
    address: '/run-code',
    args: [{ type: 'i', value: cfg.token }, { type: 's', value: code }]
  }, '127.0.0.1', cfg.port);
  console.log(`  → /run-code  port=${cfg.port}  code=${code.slice(0, 60)}`);
}

// ── HTTP server ────────────────────────────────────────────────────────────────
const server = http.createServer((req, res) => {
  if (req.url === '/' || req.url === '/index.html') {
    res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
    fs.createReadStream(path.join(__dirname, 'index.html')).pipe(res);
    return;
  }

  const m = req.url.match(/^\/track\/([a-z0-9_]+)$/i);
  if (m) {
    const file = TRACK_FILES[m[1].toLowerCase()];
    if (file) {
      res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
      fs.createReadStream(path.join(SET_DIR, file)).pipe(res);
      return;
    }
  }

  if (req.url === '/manifesto') {
    const mPath = path.join(__dirname, 'manifesto.txt');
    if (fs.existsSync(mPath)) {
      res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
      fs.createReadStream(mPath).pipe(res);
    } else {
      res.writeHead(404); res.end('manifesto.txt not found');
    }
    return;
  }

  if (req.url === '/config') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(TRACKS));
    return;
  }

  res.writeHead(404);
  res.end('not found');
});

// ── WebSocket ──────────────────────────────────────────────────────────────────
const wss = new WebSocketServer({ server });

function broadcast(obj) {
  const msg = JSON.stringify(obj);
  for (const c of wss.clients) if (c.readyState === 1) c.send(msg);
}

// Debounce: ignore rapid play/stop commands within 1.5s of the last one
let lastCmd = 0;
function debounced(fn) {
  const now = Date.now();
  if (now - lastCmd < 1500) { console.log('  (debounced)'); return; }
  lastCmd = now;
  fn();
}

wss.on('connection', (ws) => {
  ws.on('message', (raw) => {
    let msg;
    try { msg = JSON.parse(raw); } catch { return; }

    if (msg.action === 'stop') {
      debounced(() => {
        console.log('  ■  stop');
        sonicPiStop();
        broadcast({ type: 'playback', playing: false, track: null });
      });

    } else if (msg.action === 'play' && TRACK_FILES[msg.track]) {
      debounced(() => {
        console.log(`  ▶  ${msg.track}`);
        const trackPath = path.join(SET_DIR, TRACK_FILES[msg.track]);
        broadcast({ type: 'playback', playing: true, track: msg.track });
        sonicPiStop();
        setTimeout(() => sonicPiRun(`run_file "${trackPath}"`), 1200);
      });
    }
  });
});

server.listen(HTTP_PORT, () => {
  console.log(`\n  Viz  →  http://localhost:${HTTP_PORT}`);
  const cfg = getSonicPiConfig();
  if (cfg) console.log(`  SP   →  localhost:${cfg.port}  token=${cfg.token}\n`);
  else     console.log(`  SP   →  (start Sonic Pi first)\n`);
});
