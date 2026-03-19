<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1.0"/>
<title>FLUX — work terminal</title>
<link href="https://fonts.googleapis.com/css2?family=DM+Mono:ital,wght@0,300;0,400;0,500;1,300;1,400&display=swap" rel="stylesheet"/>
<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.1/chart.umd.min.js"></script>
<style>
:root {
  --bg:       #f2f0e8;
  --bg2:      #eceae0;
  --surface:  #e6e3d8;
  --ink:      #1a1a14;
  --ink2:     #4a4a3a;
  --ink3:     #8a8a72;
  --ink4:     #b0ae98;
  --green:    #2d6a2d;
  --green2:   #4a9e4a;
  --green-bg: #d8ecd8;
  --amber:    #8a5a00;
  --amber-bg: #f0e4c0;
  --red:      #8a2020;
  --red-bg:   #f0d0d0;
  --border:   #c8c5b0;
  --border2:  #aaa890;
  --mono:     'DM Mono', 'Courier New', monospace;
  --radius:   0px;
}
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html { scroll-behavior: smooth; }
 
/* ── Cursor ── */
* { cursor: none !important; }
#cur {
  position: fixed; pointer-events: none; z-index: 9999;
  transform: translate(-50%,-50%);
  width: 20px; height: 20px;
  transition: transform 0.1s;
}
#cur::before {
  content: '+';
  font-family: var(--mono);
  font-size: 20px;
  font-weight: 300;
  color: var(--green);
  position: absolute;
  top: 50%; left: 50%;
  transform: translate(-50%,-50%);
  line-height: 1;
}
#cur.on-btn::before { content: '█'; font-size: 14px; color: var(--ink); }
#cur.clicking { transform: translate(-50%,-50%) scale(0.8); }
 
/* ── Scanline overlay ── */
body::after {
  content: '';
  position: fixed; inset: 0;
  background: repeating-linear-gradient(
    0deg,
    transparent,
    transparent 2px,
    rgba(0,0,0,0.015) 2px,
    rgba(0,0,0,0.015) 4px
  );
  pointer-events: none; z-index: 9000;
}
 
body {
  font-family: var(--mono);
  background: var(--bg);
  color: var(--ink);
  min-height: 100vh;
  line-height: 1.6;
  -webkit-font-smoothing: antialiased;
  overflow-x: hidden;
}
 
/* ── Layout: sidebar + main ── */
.shell {
  display: grid;
  grid-template-columns: 220px 1fr;
  grid-template-rows: auto 1fr;
  min-height: 100vh;
}
 
/* ── Topbar ── */
.topbar {
  grid-column: 1 / -1;
  border-bottom: 2px solid var(--ink);
  padding: 0.9rem 1.75rem;
  display: flex; align-items: center; justify-content: space-between;
  background: var(--bg);
  animation: fadeDown 0.4s cubic-bezier(0.16,1,0.3,1) both;
}
.topbar-left { display: flex; align-items: baseline; gap: 1.25rem; }
.logo { font-size: 22px; font-weight: 500; letter-spacing: 4px; color: var(--ink); text-transform: uppercase; }
.logo-ver { font-size: 11px; color: var(--ink3); letter-spacing: 1px; }
.topbar-right { display: flex; align-items: center; gap: 1.5rem; }
.tb-stat { font-size: 11px; color: var(--ink3); letter-spacing: 0.5px; }
.tb-stat b { color: var(--ink2); font-weight: 500; }
.tb-date { font-size: 11px; color: var(--ink3); letter-spacing: 0.5px; }
.blink { animation: blink 1.2s step-end infinite; }
@keyframes blink { 0%,100%{opacity:1;} 50%{opacity:0;} }
 
/* ── Sidebar ── */
.sidebar {
  border-right: 2px solid var(--ink);
  padding: 2rem 0;
  background: var(--bg);
  animation: fadeRight 0.4s 0.05s cubic-bezier(0.16,1,0.3,1) both;
}
.sidebar-section { margin-bottom: 2.5rem; }
.sidebar-heading {
  font-size: 9px; letter-spacing: 3px; text-transform: uppercase;
  color: var(--ink4); padding: 0 1.5rem; margin-bottom: 8px;
}
.nav-item {
  display: flex; align-items: center; gap: 10px;
  padding: 10px 1.5rem; font-size: 13px; color: var(--ink2);
  letter-spacing: 0.5px; border: none; background: none;
  width: 100%; text-align: left; transition: all 0.15s;
  border-left: 3px solid transparent;
  position: relative;
}
.nav-item:hover { color: var(--ink); background: var(--bg2); }
.nav-item.active {
  color: var(--ink);
  background: var(--bg2);
  border-left-color: var(--green);
  font-weight: 500;
}
.nav-item.active::before {
  content: '>'; position: absolute; left: 6px;
  color: var(--green); font-size: 11px;
}
.nav-prompt { color: var(--ink4); font-size: 12px; }
 
.sidebar-score {
  padding: 1rem 1.5rem;
  border-top: 1px solid var(--border);
  margin-top: auto;
}
.score-label { font-size: 9px; letter-spacing: 3px; text-transform: uppercase; color: var(--ink4); margin-bottom: 6px; }
.score-bar-wrap { height: 4px; background: var(--surface); border: 1px solid var(--border); margin-bottom: 6px; }
.score-bar { height: 100%; background: var(--green); transition: width 0.8s cubic-bezier(0.4,0,0.2,1); width: 0%; }
.score-num { font-size: 28px; font-weight: 300; color: var(--ink); line-height: 1; }
.score-num span { font-size: 13px; color: var(--ink3); }
 
/* ── Main ── */
.main {
  padding: 3rem 3.5rem 5rem;
  overflow-y: auto;
  animation: fadeUp 0.45s 0.1s cubic-bezier(0.16,1,0.3,1) both;
}
 
/* ── Animations ── */
@keyframes fadeUp    { from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:translateY(0)} }
@keyframes fadeDown  { from{opacity:0;transform:translateY(-10px)} to{opacity:1;transform:translateY(0)} }
@keyframes fadeRight { from{opacity:0;transform:translateX(-10px)} to{opacity:1;transform:translateX(0)} }
@keyframes fadeIn    { from{opacity:0} to{opacity:1} }
@keyframes pulse     { 0%,100%{opacity:1} 50%{opacity:0} }
@keyframes slideIn   { from{opacity:0;transform:translateY(12px)} to{opacity:1;transform:translateY(0)} }
 
.section { display: none; }
.section.active { display: block; animation: fadeIn 0.25s ease both; }
 
/* ── Anchor ── */
.anchor-wrap { margin-bottom: 3.5rem; }
.prompt-line {
  font-size: 11px; color: var(--ink4); letter-spacing: 1px;
  margin-bottom: 8px; display: flex; align-items: center; gap: 8px;
}
.prompt-sym { color: var(--green); font-size: 13px; }
.anchor-input {
  background: none; border: none; outline: none;
  font-family: var(--mono); font-size: 32px; font-weight: 300;
  color: var(--ink); width: 100%; line-height: 1.3;
  caret-color: var(--green);
  border-bottom: 2px solid var(--border);
  padding-bottom: 12px;
  transition: border-color 0.25s;
}
.anchor-input:focus { border-bottom-color: var(--green); }
.anchor-input::placeholder { color: var(--ink4); }
 
/* ── Timer ── */
.timer-wrap { margin-bottom: 3rem; }
.timer-header { display: flex; align-items: baseline; gap: 1.5rem; margin-bottom: 0.5rem; }
.timer-prompt { font-size: 11px; color: var(--ink4); letter-spacing: 1px; }
.timer-display {
  font-size: 110px; font-weight: 300; line-height: 1;
  color: var(--ink); letter-spacing: -6px;
  transition: color 0.4s;
  font-variant-numeric: tabular-nums;
}
.timer-display.running { color: var(--green); }
.timer-display.done    { color: var(--green2); }
 
.timer-task-line {
  display: flex; align-items: center; gap: 10px;
  border-bottom: 1px solid var(--border);
  padding: 10px 0; margin-bottom: 1.5rem;
}
.task-prompt { font-size: 13px; color: var(--green); flex-shrink: 0; }
.task-input {
  background: none; border: none; outline: none;
  font-family: var(--mono); font-size: 16px; color: var(--ink);
  flex: 1; caret-color: var(--green);
}
.task-input::placeholder { color: var(--ink4); }
 
.timer-controls { display: flex; align-items: center; gap: 1rem; flex-wrap: wrap; }
.dur-group { display: flex; gap: 6px; }
.dur-btn {
  padding: 5px 12px; font-size: 12px; font-family: var(--mono);
  border: 1px solid var(--border); background: none; color: var(--ink3);
  letter-spacing: 0.5px; transition: all 0.15s;
}
.dur-btn:hover { border-color: var(--border2); color: var(--ink); }
.dur-btn.active { background: var(--ink); color: var(--bg); border-color: var(--ink); }
 
.cmd-btn {
  padding: 7px 20px; font-size: 13px; font-family: var(--mono);
  border: 2px solid var(--ink); background: none; color: var(--ink);
  letter-spacing: 1px; text-transform: uppercase;
  transition: all 0.15s;
}
.cmd-btn:hover, .cmd-btn.active-state { background: var(--ink); color: var(--bg); }
.cmd-btn.green-btn { border-color: var(--green); color: var(--green); }
.cmd-btn.green-btn:hover { background: var(--green); color: var(--bg); }
.cmd-btn.stop-btn { border-color: var(--border2); color: var(--ink3); }
.cmd-btn.stop-btn:hover { border-color: var(--red); color: var(--red); }
 
.progress-line {
  height: 2px; background: var(--surface);
  margin: 1.25rem 0 0; overflow: hidden;
}
.progress-fill {
  height: 100%; width: 0%; background: var(--green);
  transition: width 1s linear;
}
 
/* ── Status line ── */
.status-line {
  font-size: 12px; color: var(--ink4); letter-spacing: 0.5px;
  padding: 8px 0; min-height: 32px;
  border-top: 1px solid var(--border);
  margin-top: 10px;
  display: flex; align-items: center; gap: 6px;
}
.status-dot { width: 6px; height: 6px; border-radius: 50%; background: var(--ink4); flex-shrink: 0; }
.status-dot.running { background: var(--green); animation: pulse 1s ease-in-out infinite; }
.status-dot.done    { background: var(--green); }
 
/* ── Energy ── */
.energy-wrap { margin-bottom: 3rem; }
.section-head { font-size: 11px; letter-spacing: 2px; text-transform: uppercase; color: var(--ink4); margin-bottom: 1.25rem; display: flex; align-items: center; gap: 10px; }
.section-head::after { content: ''; flex: 1; height: 1px; background: var(--border); }
 
.energy-row { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
.e-emoji-row { display: flex; gap: 4px; }
.e-btn {
  width: 38px; height: 38px; border: 1px solid var(--border);
  background: none; font-size: 16px; display: flex;
  align-items: center; justify-content: center;
  transition: all 0.15s;
}
.e-btn:hover { border-color: var(--border2); background: var(--bg2); }
.e-btn.sel { border: 2px solid var(--green); background: var(--green-bg); }
 
.e-note-input {
  flex: 1; min-width: 120px; background: none;
  border: none; border-bottom: 1px solid var(--border);
  outline: none; font-family: var(--mono); font-size: 13px;
  color: var(--ink); padding: 6px 0; caret-color: var(--green);
}
.e-note-input::placeholder { color: var(--ink4); }
.e-note-input:focus { border-bottom-color: var(--green2); }
 
.e-log-btn {
  padding: 6px 16px; font-size: 12px; font-family: var(--mono);
  border: 1px solid var(--border2); background: none; color: var(--ink3);
  letter-spacing: 1px; transition: all 0.15s;
}
.e-log-btn:hover { border-color: var(--green); color: var(--green); }
 
/* ── Today tab lists ── */
.list-section { margin-bottom: 2.5rem; }
.list-head { display: flex; align-items: center; justify-content: space-between; margin-bottom: 1rem; }
.add-link {
  font-size: 12px; color: var(--green2); letter-spacing: 0.5px;
  border: none; background: none; font-family: var(--mono);
  text-decoration: underline; text-underline-offset: 3px;
}
 
.block-item {
  display: flex; align-items: baseline; gap: 12px;
  padding: 10px 0; border-bottom: 1px solid var(--bg2);
  font-size: 14px; animation: slideIn 0.3s ease both;
}
.block-item:last-child { border-bottom: none; }
.bi-dur { color: var(--green); font-size: 12px; min-width: 36px; flex-shrink: 0; }
.bi-task { color: var(--ink); flex: 1; }
.bi-time { color: var(--ink4); font-size: 11px; flex-shrink: 0; }
.bi-del { background: none; border: none; color: var(--ink4); font-size: 12px; padding: 0 4px; transition: color 0.15s; }
.bi-del:hover { color: var(--red); }
 
.e-item {
  display: flex; align-items: center; gap: 12px;
  padding: 9px 0; border-bottom: 1px solid var(--bg2);
  animation: slideIn 0.3s ease both;
}
.e-item:last-child { border-bottom: none; }
.ei-icon { font-size: 16px; width: 24px; flex-shrink: 0; }
.ei-time { font-size: 11px; color: var(--ink4); flex-shrink: 0; }
.ei-note { font-size: 13px; color: var(--ink2); flex: 1; font-style: italic; }
.ei-del  { background: none; border: none; color: var(--ink4); font-size: 12px; transition: color 0.15s; }
.ei-del:hover { color: var(--red); }
 
/* ── Charts ── */
.chart-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 2rem; margin-bottom: 2.5rem; }
.chart-panel { }
.chart-label { font-size: 10px; letter-spacing: 2px; text-transform: uppercase; color: var(--ink4); margin-bottom: 1rem; }
.chart-box { height: 150px; position: relative; }
 
/* ── History ── */
.hist-chart-wrap { margin-bottom: 2.5rem; }
.day-entry {
  padding: 1.25rem 0; border-bottom: 1px solid var(--border);
  animation: slideIn 0.3s ease both;
}
.day-entry:first-child { border-top: 1px solid var(--border); }
.de-head { display: flex; align-items: baseline; justify-content: space-between; margin-bottom: 6px; }
.de-date { font-size: 12px; color: var(--ink3); letter-spacing: 0.5px; }
.de-score { font-size: 12px; font-weight: 500; }
.sc-hi { color: var(--green); }
.sc-md { color: var(--amber); }
.sc-lo { color: var(--ink3); }
.de-anchor { font-size: 16px; font-weight: 300; color: var(--ink); margin-bottom: 8px; font-style: italic; }
.de-stats { display: flex; gap: 1.5rem; flex-wrap: wrap; }
.de-stat { font-size: 11px; color: var(--ink4); }
.de-stat b { color: var(--ink2); font-weight: 500; }
 
/* ── Modal (bottom sheet) ── */
.overlay {
  position: fixed; inset: 0; background: rgba(242,240,232,0.7);
  backdrop-filter: blur(4px); z-index: 200;
  display: none; align-items: flex-end; justify-content: center;
}
.overlay.open { display: flex; }
.modal {
  background: var(--bg); border-top: 3px solid var(--ink);
  padding: 2rem 2rem 3rem; width: 100%; max-width: 640px;
  animation: slideUp 0.35s cubic-bezier(0.16,1,0.3,1) both;
  max-height: 85vh; overflow-y: auto;
}
@keyframes slideUp { from{transform:translateY(100%);opacity:0;} to{transform:translateY(0);opacity:1;} }
.modal-handle { width: 36px; height: 3px; background: var(--border2); margin: 0 auto 1.5rem; }
.modal-title { font-size: 18px; font-weight: 300; letter-spacing: 2px; text-transform: uppercase; color: var(--ink); margin-bottom: 1.5rem; }
.field { margin-bottom: 16px; }
.field label { display: block; font-size: 10px; letter-spacing: 2px; text-transform: uppercase; color: var(--ink4); margin-bottom: 7px; }
.field input, .field select, .field textarea {
  width: 100%; padding: 10px 0;
  border: none; border-bottom: 1px solid var(--border2);
  background: none; font-family: var(--mono); font-size: 14px;
  color: var(--ink); outline: none; transition: border-color 0.2s;
  -webkit-appearance: none;
}
.field input:focus, .field select:focus, .field textarea:focus { border-bottom-color: var(--green); }
.field textarea { min-height: 70px; resize: vertical; }
.field-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; }
.modal-actions { display: flex; gap: 10px; justify-content: flex-end; margin-top: 1.5rem; }
.modal-btn {
  padding: 9px 22px; font-size: 12px; font-family: var(--mono);
  border: 1px solid var(--border2); background: none; color: var(--ink2);
  letter-spacing: 1px; text-transform: uppercase; transition: all 0.15s;
}
.modal-btn:hover { border-color: var(--border2); background: var(--bg2); }
.modal-btn.primary { border-color: var(--ink); background: var(--ink); color: var(--bg); }
.modal-btn.primary:hover { background: var(--ink2); }
 
.rev-row { display: flex; gap: 8px; margin-top: 6px; }
.rev-opt {
  flex: 1; padding: 10px; text-align: center;
  border: 1px solid var(--border2); background: none;
  font-family: var(--mono); font-size: 13px; color: var(--ink2);
  transition: all 0.15s;
}
.rev-opt.yes-on { border-color: var(--green); color: var(--green); background: var(--green-bg); }
.rev-opt.no-on  { border-color: var(--red);   color: var(--red);   background: var(--red-bg);   }
 
/* ── Toast ── */
.toast {
  position: fixed; bottom: 1.5rem; left: 50%;
  transform: translateX(-50%) translateY(80px);
  background: var(--ink); color: var(--bg);
  padding: 10px 22px; font-size: 12px; font-family: var(--mono);
  letter-spacing: 1px; z-index: 9998;
  transition: transform 0.3s cubic-bezier(0.16,1,0.3,1);
  pointer-events: none;
}
.toast.show { transform: translateX(-50%) translateY(0); }
 
.empty { font-size: 13px; color: var(--ink4); padding: 1.5rem 0; font-style: italic; }
 
/* ── Mobile ── */
@media(max-width:640px){
  .shell { grid-template-columns: 1fr; }
  .sidebar {
    border-right: none; border-bottom: 2px solid var(--ink);
    padding: 0.75rem 0; display: flex;
    gap: 0; overflow-x: auto;
  }
  .sidebar-section { display: flex; gap: 0; margin-bottom: 0; }
  .sidebar-heading { display: none; }
  .sidebar-score { display: none; }
  .nav-item { padding: 8px 16px; border-left: none; border-bottom: 3px solid transparent; white-space: nowrap; }
  .nav-item.active { border-left-color: transparent; border-bottom-color: var(--green); }
  .nav-item.active::before { display: none; }
  .main { padding: 1.75rem 1.25rem 5rem; }
  .timer-display { font-size: 72px; letter-spacing: -4px; }
  .chart-grid { grid-template-columns: 1fr; gap: 1.5rem; }
  .field-row { grid-template-columns: 1fr; gap: 0; }
  .topbar-right { display: none; }
}
</style>
</head>
<body>
 
<div id="cur"></div>
 
<div class="shell">
 
  <!-- Topbar -->
  <div class="topbar">
    <div class="topbar-left">
      <div class="logo">FLUX</div>
      <div class="logo-ver">v4.0 / work terminal</div>
    </div>
    <div class="topbar-right">
      <div class="tb-stat">blocks: <b id="tb-blocks">0</b></div>
      <div class="tb-stat">focused: <b id="tb-min">0</b>m</div>
      <div class="tb-stat">score: <b id="tb-score">0%</b></div>
      <div class="tb-date" id="tb-date"></div>
      <span class="blink" style="color:var(--green);font-size:16px;">█</span>
    </div>
  </div>
 
  <!-- Sidebar -->
  <aside class="sidebar">
    <div class="sidebar-section">
      <div class="sidebar-heading">navigate</div>
      <button class="nav-item active" onclick="switchTab('focus',this)">
        <span class="nav-prompt">$</span> focus
      </button>
      <button class="nav-item" onclick="switchTab('today',this)">
        <span class="nav-prompt">$</span> today
      </button>
      <button class="nav-item" onclick="switchTab('history',this)">
        <span class="nav-prompt">$</span> history
      </button>
    </div>
    <div class="sidebar-section">
      <div class="sidebar-heading">system</div>
      <button class="nav-item" onclick="openReview()">
        <span class="nav-prompt">></span> end day
      </button>
    </div>
    <div class="sidebar-score" id="sb-score">
      <div class="score-label">today's score</div>
      <div class="score-bar-wrap"><div class="score-bar" id="sb-bar"></div></div>
      <div class="score-num"><span id="sb-num">0</span><span>%</span></div>
    </div>
  </aside>
 
  <!-- Main -->
  <main class="main">
 
    <!-- FOCUS -->
    <div class="section active" id="tab-focus">
 
      <!-- Anchor -->
      <div class="anchor-wrap">
        <div class="prompt-line">
          <span class="prompt-sym">$</span>
          <span>anchor — one thing that matters most</span>
        </div>
        <input class="anchor-input" id="anchor-input" placeholder="type your anchor here_" maxlength="120"/>
      </div>
 
      <!-- Timer -->
      <div class="timer-wrap">
        <div class="timer-header">
          <div class="timer-prompt">$ timer</div>
          <div class="dur-group" id="dur-btns">
            <button class="dur-btn active" onclick="setDur(25,this)">25m</button>
            <button class="dur-btn" onclick="setDur(45,this)">45m</button>
            <button class="dur-btn" onclick="setDur(60,this)">60m</button>
            <button class="dur-btn" onclick="setDur(90,this)">90m</button>
          </div>
        </div>
        <div class="timer-display" id="timer-disp">
          <span id="t-min">25</span><span id="t-col" style="display:inline-block;">:</span><span id="t-sec">00</span>
        </div>
        <div class="timer-task-line">
          <span class="task-prompt">></span>
          <input class="task-input" id="timer-task" placeholder="working on..." maxlength="80"/>
        </div>
        <div class="timer-controls">
          <button class="cmd-btn" id="ctrl-main" onclick="timerAction()">RUN</button>
          <button class="cmd-btn stop-btn" id="ctrl-stop" onclick="stopTimer()" style="display:none;">STOP</button>
        </div>
        <div class="progress-line"><div class="progress-fill" id="prog"></div></div>
        <div class="status-line">
          <div class="status-dot" id="s-dot"></div>
          <span id="s-label">idle — ready to focus</span>
        </div>
      </div>
 
      <!-- Energy -->
      <div class="energy-wrap">
        <div class="section-head">energy check-in</div>
        <div class="energy-row">
          <div class="e-emoji-row">
            <button class="e-btn" onclick="selE(1,this)">😴</button>
            <button class="e-btn" onclick="selE(2,this)">😐</button>
            <button class="e-btn" onclick="selE(3,this)">🙂</button>
            <button class="e-btn" onclick="selE(4,this)">😀</button>
            <button class="e-btn" onclick="selE(5,this)">🔥</button>
          </div>
          <input class="e-note-input" id="e-note" placeholder="optional note..." maxlength="80"/>
          <button class="e-log-btn" onclick="logE()">log</button>
        </div>
      </div>
    </div>
 
    <!-- TODAY -->
    <div class="section" id="tab-today">
      <div class="chart-grid">
        <div class="chart-panel">
          <div class="chart-label">focus blocks</div>
          <div class="chart-box"><canvas id="c-blocks"></canvas></div>
        </div>
        <div class="chart-panel">
          <div class="chart-label">energy curve</div>
          <div class="chart-box"><canvas id="c-energy"></canvas></div>
        </div>
      </div>
 
      <div class="list-section">
        <div class="list-head">
          <div class="section-head" style="margin:0;flex:1;">focus blocks</div>
          <button class="add-link" onclick="openAddBlock()">+ add manually</button>
        </div>
        <div id="blocks-list"></div>
      </div>
 
      <div class="list-section">
        <div class="section-head">energy log</div>
        <div id="energy-list"></div>
      </div>
    </div>
 
    <!-- HISTORY -->
    <div class="section" id="tab-history">
      <div class="hist-chart-wrap">
        <div class="chart-label" style="margin-bottom:1rem;">focused minutes — last 7 days</div>
        <div style="height:180px;"><canvas id="c-hist"></canvas></div>
      </div>
      <div id="history-list"></div>
    </div>
 
  </main>
</div>
 
<!-- ADD BLOCK MODAL -->
<div class="overlay" id="add-modal">
  <div class="modal">
    <div class="modal-handle"></div>
    <div class="modal-title">add focus block</div>
    <div class="field"><label>task</label><input id="ab-task" placeholder="what did you work on?"/></div>
    <div class="field-row">
      <div class="field"><label>duration (min)</label><input id="ab-dur" type="number" min="1" max="480" placeholder="25"/></div>
      <div class="field"><label>time</label><input id="ab-time" type="time"/></div>
    </div>
    <div class="modal-actions">
      <button class="modal-btn" onclick="closeM('add-modal')">cancel</button>
      <button class="modal-btn primary" onclick="addBlock()">save</button>
    </div>
  </div>
</div>
 
<!-- REVIEW MODAL -->
<div class="overlay" id="rev-modal">
  <div class="modal">
    <div class="modal-handle"></div>
    <div class="modal-title">end of day review</div>
    <div class="field">
      <label>anchor complete?</label>
      <div class="rev-row">
        <button class="rev-opt" id="r-yes" onclick="setAnch(true)">yes ✓</button>
        <button class="rev-opt" id="r-no"  onclick="setAnch(false)">not quite</button>
      </div>
    </div>
    <div class="field"><label>biggest win</label><input id="r-win" placeholder="e.g. finished the proposal"/></div>
    <div class="field"><label>carry to tomorrow</label><textarea id="r-carry" placeholder="most important thing for tomorrow?"></textarea></div>
    <div class="modal-actions">
      <button class="modal-btn" onclick="closeM('rev-modal')">cancel</button>
      <button class="modal-btn primary" onclick="saveRev()">save day</button>
    </div>
  </div>
</div>
 
<div class="toast" id="toast"></div>
 
<script>
// ── Cursor ────────────────────────────────────────────────────────────────────
const cur=document.getElementById('cur');
document.addEventListener('mousemove',e=>{
  cur.style.left=e.clientX+'px'; cur.style.top=e.clientY+'px';
});
document.addEventListener('mousedown',()=>cur.classList.add('clicking'));
document.addEventListener('mouseup',  ()=>cur.classList.remove('clicking'));
document.addEventListener('mouseover',e=>{
  cur.classList.toggle('on-btn',!!e.target.closest('button,a,input,select,textarea'));
});
 
// ── Data ─────────────────────────────────────────────────────────────────────
const KEY='flux-v4';
let db={days:{}};
let today=new Date().toISOString().slice(0,10);
let td=()=>db.days[today]||(db.days[today]={anchor:'',blocks:[],energy:[],anchorDone:null,win:'',carry:'',score:0});
 
async function load(){try{const r=await window.storage.get(KEY);if(r&&r.value)db=JSON.parse(r.value);}catch(e){}}
async function save(){try{await window.storage.set(KEY,JSON.stringify(db));}catch(e){}}
 
// ── Utils ─────────────────────────────────────────────────────────────────────
const uid  =()=>Date.now().toString(36)+Math.random().toString(36).slice(2,5);
const pad  =n=>String(n).padStart(2,'0');
const now  =()=>{const n=new Date();return pad(n.getHours())+':'+pad(n.getMinutes());};
const fmtS =d=>new Date(d+'T00:00:00').toLocaleDateString('en-KE',{weekday:'short',month:'short',day:'numeric'});
const fmtL =d=>new Date(d+'T00:00:00').toLocaleDateString('en-KE',{weekday:'long',month:'long',day:'numeric'});
const EM   =['','😴','😐','🙂','😀','🔥'];
const EL   =['','Drained','Low','Okay','Good','Peak'];
document.getElementById('tb-date').textContent=fmtL(today);
 
// ── Timer ─────────────────────────────────────────────────────────────────────
let secs=25*60,maxS=25*60,tInt=null,run=false,paused=false,doneT=false;
 
function setDur(m,el){
  if(run)return;
  document.querySelectorAll('.dur-btn').forEach(b=>b.classList.remove('active'));
  el.classList.add('active');
  secs=m*60;maxS=m*60;doneT=false;
  upDisp();resetUI();upProg();
}
function upDisp(){
  document.getElementById('t-min').textContent=pad(Math.floor(secs/60));
  document.getElementById('t-sec').textContent=pad(secs%60);
}
function upProg(){
  const p=(run||paused)?((maxS-secs)/maxS*100):0;
  document.getElementById('prog').style.width=p+'%';
}
function setStatus(label,state){
  document.getElementById('s-label').textContent=label;
  document.getElementById('s-dot').className='status-dot'+(state?' '+state:'');
}
function resetUI(){
  document.getElementById('timer-disp').className='timer-display';
  document.getElementById('ctrl-main').textContent='RUN';
  document.getElementById('ctrl-main').className='cmd-btn';
  document.getElementById('ctrl-stop').style.display='none';
  document.querySelectorAll('.dur-btn').forEach(b=>b.style.pointerEvents='auto');
  document.getElementById('t-col').textContent=':';
  document.getElementById('t-col').style.animation='none';
  document.getElementById('t-min').textContent=pad(maxS/60);
  document.getElementById('t-sec').textContent='00';
  setStatus('idle — ready to focus','');
}
 
function timerAction(){
  if(doneT){logDone();return;}
  if(!run&&!paused)startT();
  else if(run)pauseT();
  else resumeT();
}
function startT(){
  const task=document.getElementById('timer-task').value.trim();
  if(!task){document.getElementById('timer-task').focus();toast('name your task first');return;}
  run=true;paused=false;
  document.getElementById('timer-disp').className='timer-display running';
  document.getElementById('ctrl-main').textContent='PAUSE';
  document.getElementById('ctrl-main').className='cmd-btn active-state';
  document.getElementById('ctrl-stop').style.display='inline-block';
  document.getElementById('t-col').style.animation='pulse 1s step-end infinite';
  document.querySelectorAll('.dur-btn').forEach(b=>b.style.pointerEvents='none');
  setStatus('session running — stay in flow','running');
  tInt=setInterval(tick,1000);
}
function pauseT(){
  run=false;paused=true;clearInterval(tInt);
  document.getElementById('timer-disp').className='timer-display';
  document.getElementById('ctrl-main').textContent='RESUME';
  document.getElementById('ctrl-main').className='cmd-btn';
  document.getElementById('t-col').style.animation='none';
  setStatus('paused — take a breath','');
}
function resumeT(){
  run=true;paused=false;
  document.getElementById('timer-disp').className='timer-display running';
  document.getElementById('ctrl-main').textContent='PAUSE';
  document.getElementById('ctrl-main').className='cmd-btn active-state';
  document.getElementById('t-col').style.animation='pulse 1s step-end infinite';
  setStatus('back in flow','running');
  tInt=setInterval(tick,1000);
}
function stopTimer(){
  clearInterval(tInt);run=false;paused=false;doneT=false;
  secs=maxS;upDisp();resetUI();upProg();
}
function tick(){
  if(secs<=0){timerDone();return;}
  secs--;upDisp();upProg();
}
function timerDone(){
  clearInterval(tInt);run=false;doneT=true;
  document.getElementById('timer-disp').className='timer-display done';
  document.getElementById('t-min').textContent='OK';
  document.getElementById('t-col').textContent='';
  document.getElementById('t-sec').textContent='';
  document.getElementById('ctrl-main').textContent='LOG BLOCK';
  document.getElementById('ctrl-main').className='cmd-btn green-btn';
  document.getElementById('ctrl-stop').style.display='none';
  document.getElementById('prog').style.width='100%';
  document.getElementById('prog').style.background='var(--green2)';
  document.querySelectorAll('.dur-btn').forEach(b=>b.style.pointerEvents='auto');
  setStatus('session complete — log it!','done');
  toast('session complete');
}
function logDone(){
  const task=document.getElementById('timer-task').value.trim();
  td().blocks.push({id:uid(),task,dur:Math.round(maxS/60),time:now()});
  document.getElementById('timer-task').value='';
  document.getElementById('prog').style.background='var(--green)';
  calcScore();save();renderToday();renderCharts();upMeta();stopTimer();toast('block logged');
}
 
// ── Blocks ────────────────────────────────────────────────────────────────────
function openAddBlock(){
  document.getElementById('ab-task').value='';
  document.getElementById('ab-dur').value='';
  document.getElementById('ab-time').value=now();
  openM('add-modal');
}
function addBlock(){
  const task=document.getElementById('ab-task').value.trim();
  const dur=parseInt(document.getElementById('ab-dur').value)||0;
  if(!task||!dur){toast('fill in task and duration');return;}
  td().blocks.push({id:uid(),task,dur,time:document.getElementById('ab-time').value||now()});
  calcScore();save();renderToday();renderCharts();upMeta();closeM('add-modal');toast('block added');
}
function delBlock(id){
  td().blocks=td().blocks.filter(b=>b.id!==id);
  calcScore();save();renderToday();renderCharts();upMeta();
}
 
// ── Energy ────────────────────────────────────────────────────────────────────
let selEn=0;
function selE(l,el){
  selEn=l;
  document.querySelectorAll('.e-btn').forEach(b=>{b.classList.remove('sel');});
  el.classList.add('sel');
}
function logE(){
  if(!selEn){toast('pick an energy level');return;}
  const note=document.getElementById('e-note').value.trim();
  td().energy.push({id:uid(),level:selEn,note,time:now()});
  save();renderToday();renderCharts();upMeta();
  document.getElementById('e-note').value='';
  document.querySelectorAll('.e-btn').forEach(b=>b.classList.remove('sel'));
  selEn=0;toast('energy logged');
}
function delE(id){
  td().energy=td().energy.filter(e=>e.id!==id);
  save();renderToday();renderCharts();upMeta();
}
 
// ── Score ─────────────────────────────────────────────────────────────────────
function calcScore(){
  const d=td();
  const tot=d.blocks.reduce((s,b)=>s+b.dur,0);
  const ea=d.energy.length?d.energy.reduce((s,e)=>s+e.level,0)/d.energy.length:3;
  const bs=Math.min(tot/120,1);
  const ab=d.anchorDone?0.2:0;
  d.score=Math.min(Math.round((bs*0.7+ea/5*0.3+ab)*100),100);
  upScoreUI();
}
function upScoreUI(){
  const s=td().score||0;
  document.getElementById('sb-num').textContent=s;
  document.getElementById('sb-bar').style.width=s+'%';
  document.getElementById('tb-score').textContent=s+'%';
}
function upMeta(){
  const d=td();
  const tot=d.blocks.reduce((s,b)=>s+b.dur,0);
  document.getElementById('tb-blocks').textContent=d.blocks.length;
  document.getElementById('tb-min').textContent=tot;
}
 
// ── Anchor ────────────────────────────────────────────────────────────────────
document.getElementById('anchor-input').addEventListener('input',function(){td().anchor=this.value;save();});
 
// ── Review ────────────────────────────────────────────────────────────────────
let anchDone=null;
function openReview(){
  document.getElementById('r-win').value=td().win||'';
  document.getElementById('r-carry').value=td().carry||'';
  anchDone=td().anchorDone;rRev();openM('rev-modal');
}
function setAnch(v){anchDone=v;rRev();}
function rRev(){
  document.getElementById('r-yes').className='rev-opt'+(anchDone===true?' yes-on':'');
  document.getElementById('r-no').className='rev-opt'+(anchDone===false?' no-on':'');
}
function saveRev(){
  const d=td();d.anchorDone=anchDone;
  d.win=document.getElementById('r-win').value.trim();
  d.carry=document.getElementById('r-carry').value.trim();
  calcScore();save();closeM('rev-modal');renderHistory();rHistChart();toast('day saved');
}
 
// ── Charts ────────────────────────────────────────────────────────────────────
let cB,cE,cH;
const cBase={
  responsive:true,maintainAspectRatio:false,
  plugins:{legend:{display:false},tooltip:{
    backgroundColor:'#1a1a14',borderColor:'#c8c5b0',borderWidth:1,
    titleColor:'#f2f0e8',bodyColor:'#8a8a72',padding:10,cornerRadius:0,
  }},
};
const tk={color:'#b0ae98',font:{family:'DM Mono',size:10}};
const gc='rgba(26,26,20,0.05)';
 
function renderCharts(){
  const d=td();
  const c1=document.getElementById('c-blocks').getContext('2d');
  if(cB)cB.destroy();
  cB=new Chart(c1,{type:'bar',data:{
    labels:d.blocks.map(b=>b.time||''),
    datasets:[{data:d.blocks.map(b=>b.dur),backgroundColor:'rgba(45,106,45,0.2)',borderColor:'rgba(45,106,45,0.7)',borderWidth:1,borderRadius:0}]
  },options:{...cBase,scales:{
    x:{ticks:tk,grid:{color:gc},border:{color:gc}},
    y:{ticks:tk,grid:{color:gc},border:{color:gc},beginAtZero:true},
  }}});
 
  const c2=document.getElementById('c-energy').getContext('2d');
  if(cE)cE.destroy();
  cE=new Chart(c2,{type:'line',data:{
    labels:d.energy.map(e=>e.time),
    datasets:[{data:d.energy.map(e=>e.level),borderColor:'#2d6a2d',backgroundColor:'rgba(45,106,45,0.06)',borderWidth:1.5,pointBackgroundColor:'#2d6a2d',pointRadius:3,pointHoverRadius:5,tension:0.4,fill:true}]
  },options:{...cBase,scales:{
    x:{ticks:tk,grid:{color:gc},border:{color:gc}},
    y:{min:0,max:5,ticks:{...tk,stepSize:1,callback:v=>EM[v]||v},grid:{color:gc},border:{color:gc}},
  }}});
}
 
function rHistChart(){
  const labels=[],data=[];
  for(let i=6;i>=0;i--){
    const dt=new Date();dt.setDate(dt.getDate()-i);
    const key=dt.toISOString().slice(0,10);
    labels.push(i===0?'today':dt.toLocaleDateString('en-KE',{weekday:'short'}).toLowerCase());
    const e=db.days[key];
    data.push(e?e.blocks.reduce((s,b)=>s+b.dur,0):0);
  }
  const c=document.getElementById('c-hist').getContext('2d');
  if(cH)cH.destroy();
  cH=new Chart(c,{type:'bar',data:{
    labels,
    datasets:[{data,backgroundColor:data.map((_,i)=>i===6?'rgba(45,106,45,0.4)':'rgba(26,26,20,0.07)'),borderColor:data.map((_,i)=>i===6?'rgba(45,106,45,0.9)':'rgba(26,26,20,0.15)'),borderWidth:1,borderRadius:0}]
  },options:{...cBase,scales:{
    x:{ticks:{...tk,color:'#8a8a72'},grid:{display:false},border:{color:gc}},
    y:{ticks:tk,grid:{color:gc},border:{color:gc},beginAtZero:true},
  }}});
}
 
// ── Render lists ──────────────────────────────────────────────────────────────
function renderToday(){
  const d=td();
  document.getElementById('blocks-list').innerHTML=d.blocks.length?d.blocks.map((b,i)=>`
    <div class="block-item" style="animation-delay:${i*0.04}s">
      <span class="bi-dur">[${b.dur}m]</span>
      <span class="bi-task">${b.task}</span>
      <span class="bi-time">${b.time}</span>
      <button class="bi-del" onclick="delBlock('${b.id}')">del</button>
    </div>`).join(''):'<div class="empty">// no blocks logged yet</div>';
 
  document.getElementById('energy-list').innerHTML=d.energy.length?d.energy.map((e,i)=>`
    <div class="e-item" style="animation-delay:${i*0.04}s">
      <span class="ei-icon">${EM[e.level]}</span>
      <span class="ei-time">${e.time}</span>
      <span class="ei-note">${e.note||EL[e.level]}</span>
      <button class="ei-del" onclick="delE('${e.id}')">del</button>
    </div>`).join(''):'<div class="empty">// no energy entries yet</div>';
}
 
function renderHistory(){
  const entries=Object.entries(db.days).filter(([k])=>k!==today).sort((a,b)=>b[0].localeCompare(a[0])).slice(0,30);
  const el=document.getElementById('history-list');
  if(!entries.length){el.innerHTML='<div class="empty">// no past days — check back tomorrow</div>';return;}
  el.innerHTML=entries.map(([date,d],i)=>{
    const tot=d.blocks.reduce((s,b)=>s+b.dur,0);
    const sc=d.score||0;
    const cls=sc>=70?'sc-hi':sc>=40?'sc-md':'sc-lo';
    const ea=d.energy.length?Math.round(d.energy.reduce((s,e)=>s+e.level,0)/d.energy.length):null;
    return `<div class="day-entry" style="animation-delay:${i*0.05}s">
      <div class="de-head">
        <span class="de-date">${fmtS(date)}</span>
        <span class="de-score ${cls}">${sc}%</span>
      </div>
      ${d.anchor?`<div class="de-anchor">"${d.anchor}"</div>`:''}
      <div class="de-stats">
        <span class="de-stat"><b>${d.blocks.length}</b> blocks</span>
        <span class="de-stat"><b>${tot}</b>m focused</span>
        ${ea!==null?`<span class="de-stat">energy <b>${EM[ea]}</b></span>`:''}
        ${d.anchorDone!==null?`<span class="de-stat">anchor <b>${d.anchorDone?'done':'carried'}</b></span>`:''}
        ${d.win?`<span class="de-stat">win: <b>${d.win}</b></span>`:''}
      </div>
    </div>`;
  }).join('');
}
 
// ── Tabs & Modals ─────────────────────────────────────────────────────────────
function switchTab(tab,el){
  document.querySelectorAll('.nav-item').forEach(n=>n.classList.remove('active'));
  document.querySelectorAll('.section').forEach(s=>s.classList.remove('active'));
  el.classList.add('active');
  document.getElementById('tab-'+tab).classList.add('active');
  if(tab==='today'){renderToday();renderCharts();}
  if(tab==='history'){rHistChart();renderHistory();}
}
function openM(id){document.getElementById(id).classList.add('open');document.body.style.overflow='hidden';}
function closeM(id){document.getElementById(id).classList.remove('open');document.body.style.overflow='';}
document.querySelectorAll('.overlay').forEach(o=>o.addEventListener('click',e=>{if(e.target===o)closeM(o.id);}));
 
function toast(msg){
  const t=document.getElementById('toast');
  t.textContent='> '+msg;t.classList.add('show');
  setTimeout(()=>t.classList.remove('show'),2200);
}
 
// ── Init ──────────────────────────────────────────────────────────────────────
load().then(()=>{
  document.getElementById('anchor-input').value=td().anchor||'';
  calcScore();upMeta();renderToday();
});
</script>
</body>
</html>
