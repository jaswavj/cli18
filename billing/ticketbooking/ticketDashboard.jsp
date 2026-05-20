<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,java.text.DecimalFormat"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}
String ctx = request.getContextPath();

// ── Year / Month selector ─────────────────────────────────────────────────
java.util.Calendar nowCal = java.util.Calendar.getInstance();
int curYear  = nowCal.get(java.util.Calendar.YEAR);
int curMonth = nowCal.get(java.util.Calendar.MONTH) + 1;

int selYear, selMonth;
try { selYear  = Integer.parseInt(request.getParameter("selYear"));  } catch(Exception _e) { selYear  = curYear;  }
try { selMonth = Integer.parseInt(request.getParameter("selMonth")); } catch(Exception _e) { selMonth = curMonth; }
// Clamp
if (selMonth < 1 || selMonth > 12) selMonth = curMonth;
if (selYear  < 2000 || selYear > curYear + 2) selYear = curYear;

String[] MONTH_NAMES = {"","January","February","March","April","May","June",
                        "July","August","September","October","November","December"};
String selMonthName = MONTH_NAMES[selMonth];

Map<String,Object> stats = billing.getTicketDashboardStats(selYear, selMonth);

DecimalFormat df   = new DecimalFormat("#,##0.00");
DecimalFormat dfI  = new DecimalFormat("#,##0");

int    todayCount   = stats.get("todayCount")   != null ? ((Number)stats.get("todayCount")).intValue()    : 0;
double todaySell    = stats.get("todaySell")    != null ? ((Number)stats.get("todaySell")).doubleValue()  : 0;
double todayBuy     = stats.get("todayBuy")     != null ? ((Number)stats.get("todayBuy")).doubleValue()   : 0;
double todayProfit  = stats.get("todayProfit")  != null ? ((Number)stats.get("todayProfit")).doubleValue(): 0;
int    monthCount   = stats.get("monthCount")   != null ? ((Number)stats.get("monthCount")).intValue()    : 0;
double monthSell    = stats.get("monthSell")    != null ? ((Number)stats.get("monthSell")).doubleValue()  : 0;
double monthBuy     = stats.get("monthBuy")     != null ? ((Number)stats.get("monthBuy")).doubleValue()   : 0;
double monthProfit  = stats.get("monthProfit")  != null ? ((Number)stats.get("monthProfit")).doubleValue(): 0;
double totalOut     = stats.get("totalOutstanding")      != null ? ((Number)stats.get("totalOutstanding")).doubleValue()      : 0;
double agentOut     = stats.get("totalAgentOutstanding") != null ? ((Number)stats.get("totalAgentOutstanding")).doubleValue() : 0;
Vector recentBookings = stats.get("recentBookings") != null ? (Vector)stats.get("recentBookings") : new Vector();
Vector weeklyChart    = stats.get("weeklyChart")    != null ? (Vector)stats.get("weeklyChart")    : new Vector();
Vector topAgentsDue      = stats.get("topAgentsDue")      != null ? (Vector)stats.get("topAgentsDue")      : new Vector();
Vector agentsReceivable  = stats.get("agentsReceivable")  != null ? (Vector)stats.get("agentsReceivable")  : new Vector();
Vector agentsPayable     = stats.get("agentsPayable")     != null ? (Vector)stats.get("agentsPayable")     : new Vector();

// Build chart JSON
StringBuilder chartLabels = new StringBuilder("[");
StringBuilder chartCounts = new StringBuilder("[");
StringBuilder chartSells  = new StringBuilder("[");
for (int i = 0; i < weeklyChart.size(); i++) {
    Vector r = (Vector)weeklyChart.get(i);
    if (i > 0) { chartLabels.append(","); chartCounts.append(","); chartSells.append(","); }
    chartLabels.append("\"").append(r.get(0)).append("\"");
    chartCounts.append(r.get(1));
    chartSells.append(r.get(2));
}
chartLabels.append("]"); chartCounts.append("]"); chartSells.append("]");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Ticket Dashboard</title>
<link rel="icon" type="image/png" href="<%= ctx %>/ticketbooking/logo.png">
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<%@ include file="/assets/common/head.jsp" %>
<style>
:root {
    --navy:     #1a2744;
    --navy2:    #243159;
    --violet:   #5c4d8a;
    --violet-d: #4a3d78;
    --gold:     #c9922a;
    --gold-d:   #a87520;
    --bg:       #eef1f7;
    --card:     #ffffff;
    --border:   #d1d9e6;
    --border-l: #e8edf5;
    --text:     #0f172a;
    --muted:    #64748b;
    --green:    #059669;
    --green-l:  #d1fae5;
    --red:      #dc2626;
    --red-l:    #fee2e2;
    --amber:    #d97706;
    --amber-l:  #fef3c7;
    --blue:     #2563eb;
    --blue-l:   #dbeafe;
    --r:        10px;
    --r-sm:     6px;
    --shadow:   0 2px 14px rgba(0,0,0,.09);
    --shadow-md:0 4px 24px rgba(0,0,0,.12);
}
*,*::before,*::after { box-sizing:border-box; margin:0; padding:0; }
html,body { height:100%; font-family:'Segoe UI',system-ui,sans-serif; font-size:13px; background:var(--bg); color:var(--text); }

/* ── Layout ── */
.tw { display:flex; flex-direction:column; height:100vh; height:100dvh; overflow:hidden; }
.tw-nav  { flex-shrink:0; }
.tw-body { flex:1; min-height:0; overflow-y:auto; padding:14px 16px 28px; }
.tw-body::-webkit-scrollbar { width:5px; }
.tw-body::-webkit-scrollbar-track { background:#f1f5f9; }
.tw-body::-webkit-scrollbar-thumb { background:var(--violet); border-radius:3px; }

/* ── Header bar ── */
.tb-header {
    background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);
    padding:12px 18px; display:flex; align-items:center; gap:12px; flex-wrap:wrap;
    box-shadow:0 2px 10px rgba(0,0,0,.28); flex-shrink:0;
}
.tb-header-icon { width:40px; height:40px; border-radius:var(--r-sm); background:rgba(201,146,42,.18); display:flex; align-items:center; justify-content:center; }
.tb-header-icon i { color:var(--gold); font-size:18px; }
.tb-header-info { flex:1; }
.tb-header-title { color:#fff; font-size:16px; font-weight:900; letter-spacing:.3px; }
.tb-header-sub   { color:rgba(255,255,255,.55); font-size:11px; margin-top:1px; }
.hdr-actions { display:flex; align-items:center; gap:8px; }
.hdr-date { color:rgba(255,255,255,.65); font-size:12px; }

/* ── Quick nav pills ── */
.qnav { display:flex; gap:8px; flex-wrap:wrap; margin-bottom:16px; }
.qnav-btn {
    display:inline-flex; align-items:center; gap:7px;
    background:var(--card); border:1.5px solid var(--border-l);
    border-radius:var(--r-sm); padding:7px 14px;
    color:var(--navy); font-size:12px; font-weight:700;
    text-decoration:none; transition:all .15s; box-shadow:var(--shadow);
}
.qnav-btn i { font-size:13px; }
.qnav-btn:hover { background:var(--violet); color:#fff; border-color:var(--violet); transform:translateY(-1px); box-shadow:0 4px 12px rgba(92,77,138,.3); }
.qnav-btn.primary { background:var(--gold); color:#fff; border-color:var(--gold); }
.qnav-btn.primary:hover { background:var(--gold-d); border-color:var(--gold-d); }

/* ── Section title ── */
.sec-title { font-size:12px; font-weight:800; color:var(--muted); text-transform:uppercase; letter-spacing:.6px; margin-bottom:10px; display:flex; align-items:center; gap:6px; }
.sec-title::after { content:''; flex:1; height:1px; background:var(--border-l); }

/* ── KPI grid ── */
.kpi-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:12px; margin-bottom:20px; }
@media(max-width:900px) { .kpi-grid { grid-template-columns:repeat(2,1fr); } }
@media(max-width:500px) { .kpi-grid { grid-template-columns:1fr 1fr; } }

.kpi-card {
    background:var(--card); border-radius:var(--r); border:1px solid var(--border-l);
    box-shadow:var(--shadow); padding:16px 18px; position:relative; overflow:hidden;
    transition:transform .15s, box-shadow .15s;
}
.kpi-card:hover { transform:translateY(-2px); box-shadow:var(--shadow-md); }
.kpi-card::before { content:''; position:absolute; top:0; left:0; right:0; height:3px; }
.kpi-card.green::before  { background:var(--green); }
.kpi-card.navy::before   { background:var(--navy); }
.kpi-card.violet::before { background:var(--violet); }
.kpi-card.gold::before   { background:var(--gold); }
.kpi-card.red::before    { background:var(--red); }
.kpi-card.blue::before   { background:var(--blue); }

.kpi-icon { width:38px; height:38px; border-radius:9px; display:flex; align-items:center; justify-content:center; margin-bottom:10px; font-size:16px; }
.kpi-icon.green  { background:var(--green-l); color:var(--green); }
.kpi-icon.navy   { background:#e0e5f0;         color:var(--navy); }
.kpi-icon.violet { background:#ede9f8;         color:var(--violet); }
.kpi-icon.gold   { background:#fef3c7;         color:var(--gold); }
.kpi-icon.red    { background:var(--red-l);    color:var(--red); }
.kpi-icon.blue   { background:var(--blue-l);   color:var(--blue); }
.kpi-label  { font-size:10.5px; font-weight:700; color:var(--muted); text-transform:uppercase; letter-spacing:.4px; }
.kpi-value  { font-size:22px; font-weight:900; color:var(--text); margin-top:2px; letter-spacing:-.5px; line-height:1.1; }
.kpi-sub    { font-size:11px; color:var(--muted); margin-top:3px; }
.kpi-value.small { font-size:17px; }

/* ── Two-column content grid ── */
.content-grid { display:grid; grid-template-columns:1fr 340px; gap:14px; margin-bottom:20px; }
@media(max-width:900px) { .content-grid { grid-template-columns:1fr; } }

/* ── Card shell ── */
.panel {
    background:var(--card); border-radius:var(--r); border:1px solid var(--border-l);
    box-shadow:var(--shadow); overflow:hidden;
}
.panel-head {
    display:flex; align-items:center; gap:9px; padding:12px 16px;
    background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);
}
.panel-head i { color:var(--gold); font-size:14px; }
.panel-head-title { color:#fff; font-size:13px; font-weight:800; flex:1; }
.panel-body { padding:14px 16px; }

/* ── Chart container ── */
.chart-wrap { position:relative; height:210px; }

/* ── Table ── */
.t-wrap { overflow-x:auto; }
.dt { width:100%; border-collapse:collapse; font-size:12px; }
.dt th { background:#f8fafc; color:var(--muted); font-weight:700; font-size:10.5px; text-transform:uppercase; letter-spacing:.4px; padding:8px 10px; border-bottom:1.5px solid var(--border); white-space:nowrap; }
.dt td { padding:8px 10px; border-bottom:1px solid var(--border-l); vertical-align:middle; }
.dt tr:last-child td { border-bottom:none; }
.dt tr:hover td { background:#f8fafc; }

.badge { display:inline-flex; align-items:center; gap:4px; padding:2px 8px; border-radius:20px; font-size:10px; font-weight:800; }
.badge-green  { background:var(--green-l); color:var(--green); }
.badge-red    { background:var(--red-l);   color:var(--red); }
.badge-amber  { background:var(--amber-l); color:var(--amber); }
.badge-blue   { background:var(--blue-l);  color:var(--blue); }
.badge-violet { background:#ede9f8;        color:var(--violet); }
.badge-navy   { background:#e0e5f0;        color:var(--navy); }

.profit-pos { color:var(--green); font-weight:800; }
.profit-neg { color:var(--red);   font-weight:800; }

/* ── Agent dues list ── */
.agent-list { display:flex; flex-direction:column; gap:8px; }
.agent-row {
    display:flex; align-items:center; gap:10px; padding:9px 12px;
    border-radius:var(--r-sm); border:1px solid var(--border-l); background:#f8fafc;
    transition:background .12s;
}
.agent-row:hover { background:#f1f5f9; }
.agent-av { width:34px; height:34px; border-radius:50%; background:var(--violet); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:900; font-size:13px; flex-shrink:0; }
.agent-info { flex:1; min-width:0; }
.agent-name { font-weight:800; color:var(--text); font-size:12px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
.agent-meta { font-size:10.5px; color:var(--muted); margin-top:1px; }
.agent-bal { text-align:right; }
.agent-bal-amt { font-weight:900; font-size:13px; }
.agent-bal-lbl { font-size:10px; color:var(--muted); }

/* ── Month summary bottom grid ── */
.month-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:12px; margin-bottom:20px; }
@media(max-width:900px) { .month-grid { grid-template-columns:repeat(2,1fr); } }
@media(max-width:480px) { .month-grid { grid-template-columns:1fr 1fr; } }
.month-card { background:var(--card); border:1px solid var(--border-l); border-radius:var(--r); box-shadow:var(--shadow); padding:13px 15px; }
.month-card-lbl  { font-size:10.5px; font-weight:700; color:var(--muted); text-transform:uppercase; letter-spacing:.4px; }
.month-card-val  { font-size:18px; font-weight:900; color:var(--text); margin-top:3px; }
.month-card-sub  { font-size:11px; color:var(--muted); margin-top:2px; }
.mc-line { width:28px; height:3px; border-radius:2px; margin-bottom:8px; }
.mc-green  { background:var(--green); }
.mc-blue   { background:var(--blue); }
.mc-violet { background:var(--violet); }
.mc-amber  { background:var(--amber); }

/* Empty state */
.empty-state { text-align:center; padding:30px 0; color:var(--muted); }
.empty-state i { font-size:32px; opacity:.3; display:block; margin-bottom:8px; }

/* ── Period filter bar ── */
.period-bar {
    background:var(--card); border-radius:var(--r); border:1px solid var(--border-l);
    box-shadow:var(--shadow); padding:10px 16px; display:flex; align-items:center;
    gap:10px; flex-wrap:wrap; margin-bottom:16px;
}
.period-bar label { font-size:12px; font-weight:700; color:var(--muted); white-space:nowrap; }
.period-select {
    padding:6px 10px; border:1.5px solid var(--border); border-radius:var(--r-sm);
    background:#fff; font-size:12px; font-weight:700; color:var(--navy);
    cursor:pointer; outline:none; min-width:110px;
}
.period-select:focus { border-color:var(--violet); }
.period-badge {
    margin-left:auto; background:linear-gradient(135deg,var(--violet),var(--navy));
    color:#fff; border-radius:var(--r-sm); padding:5px 14px;
    font-size:12px; font-weight:800; white-space:nowrap;
}
</style>
</head>
<body>
<div class="tw">
  <div class="tw-nav">
    <%@ include file="/assets/navbar/navbar.jsp" %>
  </div>

  <!-- Header -->
  <div class="tb-header">
    <div class="tb-header-icon"><i class="fas fa-plane-departure"></i></div>
    <div class="tb-header-info">
      <div class="tb-header-title">Ticket Dashboard</div>
      <div class="tb-header-sub">Moulana Air Travels &mdash; Overview</div>
    </div>
    <div class="hdr-actions">
      <span class="hdr-date" id="liveDate"></span>
    </div>
  </div>

  <div class="tw-body">

    <!-- ── Quick Navigation ─────────────────────────────────────── -->
    <div class="qnav">
      <a href="<%= ctx %>/ticketbooking/page.jsp" class="qnav-btn primary">
        <i class="fas fa-plus-circle"></i> New Booking
      </a>
      <a href="<%= ctx %>/ticketbooking/report.jsp" class="qnav-btn">
        <i class="fas fa-list-alt"></i> Ticket Report
      </a>
      <a href="<%= ctx %>/ticketbooking/ledgerReport.jsp" class="qnav-btn">
        <i class="fas fa-book-open"></i> Ledger
      </a>
      <a href="<%= ctx %>/ticketbooking/agentStatement.jsp" class="qnav-btn">
        <i class="fas fa-user-tie"></i> Agent Statement
      </a>
      <a href="<%= ctx %>/ticketbooking/pnrEnquiry.jsp" class="qnav-btn">
        <i class="fas fa-search"></i> PNR Enquiry
      </a>
      <a href="<%= ctx %>/ticketbooking/collectBalance.jsp" class="qnav-btn">
        <!-- using the payment trigger from report.jsp -->
        <i class="fas fa-money-bill-wave"></i> Collect Balance
      </a>
    </div>

    <!-- ── Period Filter ────────────────────────────────────────── -->
    <form id="periodForm" method="get" action="">
      <div class="period-bar">
        <i class="fas fa-calendar-alt" style="color:var(--violet);font-size:15px;"></i>
        <label for="selMonth">Month</label>
        <select id="selMonth" name="selMonth" class="period-select" onchange="document.getElementById('periodForm').submit()">
          <% for (int m = 1; m <= 12; m++) { %>
            <option value="<%= m %>" <%= m == selMonth ? "selected" : "" %>><%= MONTH_NAMES[m] %></option>
          <% } %>
        </select>
        <label for="selYear">Year</label>
        <select id="selYear" name="selYear" class="period-select" onchange="document.getElementById('periodForm').submit()">
          <% for (int y = curYear - 3; y <= curYear + 1; y++) { %>
            <option value="<%= y %>" <%= y == selYear ? "selected" : "" %>><%= y %></option>
          <% } %>
        </select>
        <div class="period-badge">
          <i class="fas fa-filter" style="margin-right:5px;opacity:.8;"></i><%= selMonthName %> <%= selYear %>
        </div>
      </div>
    </form>

    <!-- ── Today KPIs ───────────────────────────────────────────── -->
    <div class="sec-title"><i class="fas fa-sun" style="color:var(--gold)"></i> Today's Overview</div>
    <div class="kpi-grid" style="margin-bottom:20px;">
      <div class="kpi-card green">
        <div class="kpi-icon green"><i class="fas fa-ticket-alt"></i></div>
        <div class="kpi-label">Bookings Today</div>
        <div class="kpi-value"><%= dfI.format(todayCount) %></div>
        <div class="kpi-sub">Tickets booked</div>
      </div>
      <div class="kpi-card navy">
        <div class="kpi-icon navy"><i class="fas fa-arrow-up"></i></div>
        <div class="kpi-label">Sell Revenue</div>
        <div class="kpi-value small">&#8377;<%= df.format(todaySell) %></div>
        <div class="kpi-sub">Amount charged today</div>
      </div>
      <div class="kpi-card blue">
        <div class="kpi-icon blue"><i class="fas fa-arrow-down"></i></div>
        <div class="kpi-label">Buy Cost</div>
        <div class="kpi-value small">&#8377;<%= df.format(todayBuy) %></div>
        <div class="kpi-sub">Amount paid today</div>
      </div>
      <div class="kpi-card <%= todayProfit >= 0 ? "green" : "red" %>">
        <div class="kpi-icon <%= todayProfit >= 0 ? "green" : "red" %>"><i class="fas fa-chart-line"></i></div>
        <div class="kpi-label">Today's Profit</div>
        <div class="kpi-value small <%= todayProfit >= 0 ? "profit-pos" : "profit-neg" %>">
          &#8377;<%= df.format(Math.abs(todayProfit)) %>
        </div>
        <div class="kpi-sub"><%= todayProfit >= 0 ? "Profit" : "Loss" %></div>
      </div>
    </div>

    <!-- ── Outstanding KPIs ─────────────────────────────────────── -->
    <div class="sec-title"><i class="fas fa-exclamation-triangle" style="color:var(--amber)"></i> Outstanding Dues</div>
    <div class="kpi-grid" style="margin-bottom:20px;grid-template-columns:repeat(2,1fr);">
      <div class="kpi-card amber" style="--amber:#d97706;">
        <div class="kpi-icon gold"><i class="fas fa-users"></i></div>
        <div class="kpi-label">Total Outstanding (All Parties)</div>
        <div class="kpi-value small" style="color:var(--amber)">&#8377;<%= df.format(Math.abs(totalOut)) %></div>
        <div class="kpi-sub"><%= totalOut > 0 ? "Net receivable" : totalOut < 0 ? "Net payable" : "Fully settled" %></div>
      </div>
      <div class="kpi-card violet">
        <div class="kpi-icon violet"><i class="fas fa-user-tie"></i></div>
        <div class="kpi-label">Agent Outstanding</div>
        <div class="kpi-value small" style="color:var(--violet)">&#8377;<%= df.format(Math.abs(agentOut)) %></div>
        <div class="kpi-sub"><%= agentOut > 0 ? "Agents owe us" : agentOut < 0 ? "We owe agents" : "All settled" %></div>
      </div>
    </div>

    <!-- ── Chart + Agent dues ───────────────────────────────────── -->
    <div class="content-grid">

      <!-- Chart -->
      <div class="panel">
        <div class="panel-head">
          <i class="fas fa-chart-bar"></i>
          <span class="panel-head-title">Daily Bookings &amp; Revenue &mdash; <%= selMonthName %> <%= selYear %></span>
        </div>
        <div class="panel-body">
          <div class="chart-wrap"><canvas id="weekChart"></canvas></div>
        </div>
      </div>

      <!-- Agent dues: two stacked panels -->
      <div style="display:flex;flex-direction:column;gap:14px;">

        <!-- They owe me (Receivable) -->
        <div class="panel">
          <div class="panel-head">
            <i class="fas fa-arrow-circle-down" style="color:var(--green)"></i>
            <span class="panel-head-title">They Owe Me</span>
            <span style="margin-left:auto;font-size:11px;background:rgba(16,185,129,.15);color:#059669;padding:2px 8px;border-radius:10px;">Receivable</span>
          </div>
          <div class="panel-body">
            <% if (agentsReceivable.isEmpty()) { %>
              <div class="empty-state"><i class="fas fa-check-circle"></i> No receivables</div>
            <% } else { %>
            <div class="agent-list">
              <% for (int i = 0; i < agentsReceivable.size(); i++) {
                   Vector ar = (Vector) agentsReceivable.get(i);
                   String aName = ar.get(0).toString();
                   double aOut  = ((Number)ar.get(1)).doubleValue();
                   String aInit = aName.length() > 0 ? aName.substring(0,1).toUpperCase() : "A";
              %>
              <div class="agent-row">
                <div class="agent-av" style="background:var(--green)"><%= aInit %></div>
                <div class="agent-info">
                  <div class="agent-name"><%= aName %></div>
                  <div class="agent-meta">Pending from agent</div>
                </div>
                <div class="agent-bal">
                  <div class="agent-bal-amt profit-pos">&#8377;<%= df.format(aOut) %></div>
                  <div class="agent-bal-lbl">Receivable</div>
                </div>
              </div>
              <% } %>
            </div>
            <% } %>
          </div>
        </div>

        <!-- I owe them (Payable) -->
        <div class="panel">
          <div class="panel-head">
            <i class="fas fa-arrow-circle-up" style="color:var(--red)"></i>
            <span class="panel-head-title">I Owe Them</span>
            <span style="margin-left:auto;font-size:11px;background:rgba(239,68,68,.12);color:#dc2626;padding:2px 8px;border-radius:10px;">Payable</span>
          </div>
          <div class="panel-body">
            <% if (agentsPayable.isEmpty()) { %>
              <div class="empty-state"><i class="fas fa-check-circle"></i> No payables</div>
            <% } else { %>
            <div class="agent-list">
              <% for (int i = 0; i < agentsPayable.size(); i++) {
                   Vector ar = (Vector) agentsPayable.get(i);
                   String aName = ar.get(0).toString();
                   double aOut  = ((Number)ar.get(1)).doubleValue();
                   String aInit = aName.length() > 0 ? aName.substring(0,1).toUpperCase() : "A";
              %>
              <div class="agent-row">
                <div class="agent-av" style="background:var(--red)"><%= aInit %></div>
                <div class="agent-info">
                  <div class="agent-name"><%= aName %></div>
                  <div class="agent-meta">Due to agent</div>
                </div>
                <div class="agent-bal">
                  <div class="agent-bal-amt profit-neg">&#8377;<%= df.format(aOut) %></div>
                  <div class="agent-bal-lbl">Payable</div>
                </div>
              </div>
              <% } %>
            </div>
            <% } %>
          </div>
        </div>

      </div>
    </div>

    <!-- ── This Month Summary ───────────────────────────────────── -->
    <div class="sec-title"><i class="fas fa-calendar-alt" style="color:var(--violet)"></i> Summary &mdash; <%= selMonthName %> <%= selYear %></div>
    <div class="month-grid">
      <div class="month-card">
        <div class="mc-line mc-blue"></div>
        <div class="month-card-lbl">Total Bookings</div>
        <div class="month-card-val"><%= dfI.format(monthCount) %></div>
        <div class="month-card-sub">tickets this month</div>
      </div>
      <div class="month-card">
        <div class="mc-line mc-green"></div>
        <div class="month-card-lbl">Sell Revenue</div>
        <div class="month-card-val">&#8377;<%= df.format(monthSell) %></div>
        <div class="month-card-sub">charged to customers</div>
      </div>
      <div class="month-card">
        <div class="mc-line mc-amber"></div>
        <div class="month-card-lbl">Buy Cost</div>
        <div class="month-card-val">&#8377;<%= df.format(monthBuy) %></div>
        <div class="month-card-sub">paid to airlines / agents</div>
      </div>
      <div class="month-card">
        <div class="mc-line mc-violet"></div>
        <div class="month-card-lbl">Net Profit</div>
        <div class="month-card-val <%= monthProfit >= 0 ? "profit-pos" : "profit-neg" %>">&#8377;<%= df.format(Math.abs(monthProfit)) %></div>
        <div class="month-card-sub"><%= monthProfit >= 0 ? "Profit" : "Loss" %> this month</div>
      </div>
    </div>

    <!-- ── Bookings for selected period ────────────────────────── -->
    <div class="sec-title"><i class="fas fa-history" style="color:var(--navy)"></i> Bookings &mdash; <%= selMonthName %> <%= selYear %></div>
    <div class="panel">
      <div class="panel-head">
        <i class="fas fa-plane"></i>
        <span class="panel-head-title">Bookings in <%= selMonthName %> <%= selYear %></span>
        <a href="<%= ctx %>/ticketbooking/report.jsp" style="color:rgba(255,255,255,.7);font-size:11px;font-weight:700;text-decoration:none;">View All &rarr;</a>
      </div>
      <div class="panel-body" style="padding:0;">
        <% if (recentBookings.isEmpty()) { %>
          <div class="empty-state" style="padding:30px 0;"><i class="fas fa-inbox"></i> No bookings yet</div>
        <% } else { %>
        <div class="t-wrap">
          <table class="dt">
            <thead>
              <tr>
                <th>#</th>
                <th>Ticket No</th>
                <th>PNR</th>
                <th>Date</th>
                <th>Route</th>
                <th>Pax</th>
                <th>Customer</th>
                <th>Sell (&#8377;)</th>
                <th>Buy (&#8377;)</th>
                <th>Profit</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              <% for (int i = 0; i < recentBookings.size(); i++) {
                   Vector rb    = (Vector) recentBookings.get(i);
                   int    rbId  = ((Number)rb.get(0)).intValue();
                   String tNo   = rb.get(1).toString();
                   String pnr   = rb.get(2).toString();
                   String bDate = rb.get(3) != null ? rb.get(3).toString() : "";
                   String fCity = rb.get(4).toString();
                   String tCity = rb.get(5).toString();
                   int    seats = ((Number)rb.get(6)).intValue();
                   String cName = rb.get(7).toString();
                   double rSell = ((Number)rb.get(8)).doubleValue();
                   double rBuy  = ((Number)rb.get(9)).doubleValue();
                   double rProf = rSell - rBuy;
                   // Format date display
                   String bDisp = bDate;
                   try {
                        java.text.SimpleDateFormat sdfIn  = new java.text.SimpleDateFormat("yyyy-MM-dd");
                        java.text.SimpleDateFormat sdfOut = new java.text.SimpleDateFormat("dd/MM/yy");
                        bDisp = sdfOut.format(sdfIn.parse(bDate));
                   } catch(Exception ign) {}
              %>
              <tr>
                <td style="color:var(--muted);font-size:11px;"><%= (i+1) %></td>
                <td>
                  <% if (!tNo.isEmpty()) { %>
                    <span class="badge badge-navy"><%= tNo %></span>
                  <% } else { %><span style="color:var(--muted)">—</span><% } %>
                </td>
                <td>
                  <% if (!pnr.isEmpty()) { %>
                    <span style="font-weight:800;color:var(--violet);letter-spacing:.5px;font-size:11.5px;"><%= pnr %></span>
                  <% } else { %><span style="color:var(--muted)">—</span><% } %>
                </td>
                <td style="color:var(--muted);white-space:nowrap;"><%= bDisp %></td>
                <td>
                  <% if (!fCity.isEmpty() || !tCity.isEmpty()) { %>
                    <span style="font-weight:700;font-size:11.5px;"><%= fCity %></span>
                    <i class="fas fa-arrow-right" style="color:var(--gold);font-size:9px;margin:0 3px;"></i>
                    <span style="font-weight:700;font-size:11.5px;"><%= tCity %></span>
                  <% } else { %><span style="color:var(--muted)">—</span><% } %>
                </td>
                <td style="text-align:center;"><span class="badge badge-blue"><i class="fas fa-user" style="font-size:9px"></i> <%= seats %></span></td>
                <td style="max-width:130px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                  <%= !cName.isEmpty() ? cName : "<span style='color:var(--muted)'>—</span>" %>
                </td>
                <td style="font-weight:800;color:var(--navy);">&#8377;<%= df.format(rSell) %></td>
                <td style="color:var(--muted);">&#8377;<%= df.format(rBuy) %></td>
                <td class="<%= rProf >= 0 ? "profit-pos" : "profit-neg" %>">
                  <%= rProf >= 0 ? "+" : "" %>&#8377;<%= df.format(rProf) %>
                </td>
                <td>
                  <a href="<%= ctx %>/ticketbooking/ticketPrint.jsp?id=<%= rbId %>"
                     style="color:var(--violet);font-size:11px;font-weight:700;text-decoration:none;"
                     title="Print"><i class="fas fa-print"></i></a>
                </td>
              </tr>
              <% } %>
            </tbody>
          </table>
        </div>
        <% } %>
      </div>
    </div>

  </div><!-- tw-body -->
</div><!-- tw -->

<script>
// Live date/time
(function(){
  const el = document.getElementById('liveDate');
  function update(){
    const now = new Date();
    const opts = {weekday:'short',year:'numeric',month:'short',day:'numeric',hour:'2-digit',minute:'2-digit'};
    el.textContent = now.toLocaleDateString('en-IN',opts);
  }
  update(); setInterval(update,30000);
})();

// Daily chart
(function(){
  const labels = <%= chartLabels %>;
  const counts = <%= chartCounts %>;
  const sells  = <%= chartSells %>;

  const wrap = document.getElementById('weekChart').parentElement;
  if (!labels || labels.length === 0) {
    wrap.innerHTML = '<div class="empty-state" style="height:180px;display:flex;flex-direction:column;align-items:center;justify-content:center;">' +
      '<i class="fas fa-chart-bar" style="font-size:36px;opacity:.2;"></i>' +
      '<div style="margin-top:10px;font-size:13px;color:var(--muted);">No bookings found for this period</div></div>';
    return;
  }
  const hasData = counts.some(v => v > 0);
  const chartCtx = document.getElementById('weekChart').getContext('2d');
  new Chart(chartCtx, {
    type: 'bar',
    data: {
      labels: labels,
      datasets: [
        {
          label: 'Bookings',
          data: counts,
          backgroundColor: 'rgba(92,77,138,0.75)',
          borderColor: '#5c4d8a',
          borderWidth: 1.5,
          borderRadius: 4,
          yAxisID: 'y1'
        },
        {
          label: 'Sell (₹)',
          data: sells,
          type: 'line',
          borderColor: '#c9922a',
          backgroundColor: 'rgba(201,146,42,0.12)',
          borderWidth: 2.5,
          pointBackgroundColor: '#c9922a',
          pointRadius: 4,
          tension: 0.3,
          fill: true,
          yAxisID: 'y2'
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      interaction: { mode: 'index', intersect: false },
      plugins: {
        legend: { position:'top', labels:{ font:{size:11}, boxWidth:12, padding:14 } },
        tooltip: {
          callbacks: {
            label: function(c) {
              if (c.datasetIndex === 1) return ' ₹' + parseFloat(c.raw).toLocaleString('en-IN',{minimumFractionDigits:2});
              return ' ' + c.raw + ' booking(s)';
            }
          }
        }
      },
      scales: {
        x: { grid:{ display:false }, ticks:{ font:{size:11} } },
        y1: { position:'left',  beginAtZero:true, ticks:{ stepSize:1, font:{size:11} }, grid:{ color:'#e8edf5' }, title:{ display:true, text:'Bookings', font:{size:10} } },
        y2: { position:'right', beginAtZero:true, ticks:{ font:{size:11}, callback: v => '₹'+v.toLocaleString('en-IN') }, grid:{ drawOnChartArea:false }, title:{ display:true, text:'Revenue (₹)', font:{size:10} } }
      }
    }
  });
})();
</script>
</body>
</html>
