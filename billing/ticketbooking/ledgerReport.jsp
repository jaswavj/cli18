<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,java.text.SimpleDateFormat,java.text.DecimalFormat"%>
<%!
/** state[0]=due (agent owes), state[1]=advance (we owe agent) */
private void applyLedgerRunningRow(String partyType, String chargeType, String txnType,
        double bill, double paid, double[] state) {
    if ("BALANCE_COLLECT".equals(chargeType)) {
        double amt = paid;
        double c = Math.min(amt, state[0]); state[0] -= c; amt -= c;
        c = Math.min(amt, state[1]); state[1] -= c; amt -= c;
        if (amt > 0.005) state[1] += amt;
    } else if ("BALANCE_PAY".equals(chargeType)) {
        double amt = paid;
        double p = Math.min(amt, state[1]); state[1] -= p; amt -= p;
        if (amt > 0.005) state[0] += amt;
    } else if ("ADVANCE_COLLECT".equals(chargeType)) {
        state[1] -= Math.min(paid, state[1]);
    } else if ("ADVANCE_PAID".equals(chargeType)) {
        state[0] += paid;
    } else if ("ADVANCE_CREDIT".equals(chargeType)) {
        state[1] += paid;
    } else if (bill > 0.005) {
        double unpaid = Math.max(0, bill - paid);
        if ("DR".equals(txnType) || "SELL_AGENT".equals(partyType)) state[0] += unpaid;
        else if ("CR".equals(txnType) || "BUY_AGENT".equals(partyType)) state[1] += unpaid;
    }
}

private String runningBalanceClass(double runDue, double runAdvance) {
    if (runDue > 0.005) return "due";
    if (runAdvance > 0.005) return "credit";
    return "zero";
}

private double runningBalanceAmount(double runDue, double runAdvance) {
    if (runDue > 0.005) return runDue;
    if (runAdvance > 0.005) return runAdvance;
    return 0;
}
%>
<jsp:useBean id="billing" class="billing.billingBean" />
<jsp:useBean id="userb" class="user.userBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}
String ctx = request.getContextPath();
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
String today    = sdf.format(new java.util.Date());
String fromDate = request.getParameter("fromDate");
String toDate   = request.getParameter("toDate");
String agentIdP  = request.getParameter("agentFilter");
if (fromDate  == null || fromDate.isEmpty())  fromDate  = today;
if (toDate    == null || toDate.isEmpty())    toDate    = today;
int agentFilterId = 0;
try { if (agentIdP != null && !agentIdP.isEmpty()) agentFilterId = Integer.parseInt(agentIdP); } catch (Exception e) {}

Vector agents   = billing.getTicketAgents();
Vector payModes = billing.getTicketPaymentModes();
Vector allRows  = billing.getTicketLedgerReport(fromDate, toDate, agentFilterId);
Vector rows = allRows;
Vector agentAcctTotals = billing.getAgentAccountTotals(agentFilterId);
double totalAdvance = agentAcctTotals.size() > 0 ? Double.parseDouble(agentAcctTotals.get(0).toString()) : 0;
double totalAgentDue = agentAcctTotals.size() > 1 ? Double.parseDouble(agentAcctTotals.get(1).toString()) : 0;
String selectedAgentName = "";
if (agentFilterId > 0) {
    for (int _ai = 0; _ai < agents.size(); _ai++) {
        Vector _ag = (Vector) agents.get(_ai);
        if (Integer.parseInt(_ag.get(0).toString()) == agentFilterId) {
            selectedAgentName = _ag.get(1).toString();
            break;
        }
    }
}
boolean agentSelected = agentFilterId > 0;
Vector companyDet = userb.getCompanyDetails();
String companyName = (companyDet.size() > 1 && companyDet.get(1) != null) ? companyDet.get(1).toString() : "";
String companyAddr = (companyDet.size() > 2 && companyDet.get(2) != null) ? companyDet.get(2).toString() : "";
java.text.SimpleDateFormat dpFmt = new java.text.SimpleDateFormat("dd/MM/yyyy");
java.text.SimpleDateFormat iFmt  = new java.text.SimpleDateFormat("yyyy-MM-dd");
String fromDisp = fromDate, toDisp = toDate;
try { fromDisp = dpFmt.format(iFmt.parse(fromDate)); } catch (Exception e) {}
try { toDisp   = dpFmt.format(iFmt.parse(toDate));   } catch (Exception e) {}

DecimalFormat df = new DecimalFormat("0.00");

double totalBill = 0, totalPaid = 0, lastBal = 0;
String lastBalCls = "zero";
double[] runState = new double[]{0, 0};
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Ticket Ledger</title>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<%@ include file="/assets/common/head.jsp" %>
<style>
:root {
    --navy:#1a2744;--navy2:#243159;--violet:#5c4d8a;--violet-d:#4a3d78;
    --gold:#c9922a;--gold-d:#a87520;--bg:#eef1f7;--card:#ffffff;
    --border:#d1d9e6;--border-l:#e8edf5;--text:#0f172a;--muted:#64748b;
    --inp-bg:#f8fafc;--green:#059669;--red:#dc2626;--r:8px;--r-sm:5px;
    --shadow:0 2px 12px rgba(0,0,0,.10);--shadow-sm:0 1px 4px rgba(0,0,0,.07);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
html,body{height:100%;font-family:'Segoe UI',system-ui,sans-serif;font-size:13px;background:var(--bg);color:var(--text);}
.tw{display:flex;flex-direction:column;height:100vh;height:100dvh;overflow:hidden;}
.tw-nav{flex-shrink:0;}
.tw-body{flex:1;min-height:0;overflow-y:auto;padding:12px 14px 20px;}
.tw-body::-webkit-scrollbar{width:5px;}
.tw-body::-webkit-scrollbar-thumb{background:var(--violet);border-radius:3px;}

/* Header */
.rpt-hdr{flex-shrink:0;background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);padding:10px 16px;display:flex;align-items:center;gap:10px;flex-wrap:wrap;box-shadow:0 2px 8px rgba(0,0,0,.25);}
.rpt-title{display:flex;align-items:center;gap:9px;color:#fff;font-size:15px;font-weight:800;letter-spacing:.4px;flex-shrink:0;}
.rpt-title i{color:var(--gold);font-size:17px;}
.hdr-divider{width:1px;height:28px;background:rgba(255,255,255,.2);flex-shrink:0;}
.hdr-spacer{flex:1;}

/* Field / Button (reuse) */
.fg{display:flex;flex-direction:column;gap:3px;min-width:0;}
.fg-lbl{font-size:10px;font-weight:700;color:rgba(255,255,255,.7);text-transform:uppercase;letter-spacing:.5px;white-space:nowrap;}
.fg-inp,.fg-sel{height:33px;border:1.5px solid rgba(255,255,255,.25);border-radius:var(--r-sm);padding:0 9px;background:rgba(255,255,255,.12);color:#fff;font-size:13px;outline:none;}
.fg-inp::placeholder{color:rgba(255,255,255,.4);}
.fg-inp:focus,.fg-sel:focus{border-color:var(--gold);background:rgba(255,255,255,.18);}
.fg-sel option{background:#1a2744;color:#fff;}
.bb{display:inline-flex;align-items:center;gap:6px;height:33px;padding:0 15px;border-radius:var(--r-sm);font-size:12px;font-weight:700;cursor:pointer;border:1.5px solid transparent;transition:all .15s;white-space:nowrap;}
.bb-gold{background:var(--gold);color:#fff;border-color:var(--gold);}
.bb-gold:hover{background:var(--gold-d);}

/* Summary chips */
.sum-row{display:flex;gap:10px;flex-wrap:wrap;margin-bottom:12px;}
.sum-chip{background:var(--card);border-radius:var(--r-sm);border:1px solid var(--border-l);padding:10px 16px;display:flex;flex-direction:column;gap:8px;min-width:180px;flex:1;max-width:320px;box-shadow:var(--shadow-sm);}
.sum-chip-top{display:flex;align-items:flex-start;justify-content:space-between;gap:10px;}
.sum-chip-body{display:flex;flex-direction:column;gap:3px;}
.sum-chip-lbl{font-size:10px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.5px;}
.sum-chip-val{font-size:18px;font-weight:800;}
.sum-chip.chip-advance .sum-chip-val{color:var(--green);}
.sum-chip.chip-agent-due .sum-chip-val{color:var(--red);}
.btn-chip{display:inline-flex;align-items:center;gap:5px;padding:6px 12px;border-radius:var(--r-sm);font-size:11px;font-weight:700;cursor:pointer;border:none;transition:background .15s;white-space:nowrap;flex-shrink:0;}
.btn-chip-pay{background:var(--green);color:#fff;}
.btn-chip-pay:hover{background:#047857;}
.btn-chip-collect{background:var(--red);color:#fff;}
.btn-chip-collect:hover{background:#b91c1c;}

/* Table */
.tbl-wrap{background:var(--card);border-radius:var(--r);border:1px solid var(--border-l);box-shadow:var(--shadow-sm);overflow-x:auto;}
.rpt-table{width:100%;min-width:900px;border-collapse:collapse;font-size:12.5px;}
.rpt-table thead tr{background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);}
.rpt-table thead th{padding:10px 10px;color:#fff;font-weight:700;text-transform:uppercase;font-size:10.5px;letter-spacing:.4px;white-space:nowrap;text-align:left;}
.rpt-table tbody tr{border-bottom:1px solid var(--border-l);transition:background .1s;}
.rpt-table tbody tr.ledger-row{cursor:pointer;}
.rpt-table tbody tr.ledger-row:hover{background:#eef2ff;}
.detail-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px 16px;}
.detail-item{display:flex;flex-direction:column;gap:2px;}
.detail-item.full{grid-column:1/-1;}
.detail-lbl{font-size:10px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;}
.detail-val{font-size:13px;font-weight:600;color:var(--text);word-break:break-word;}
.detail-val.amt-green{color:var(--green);}
.detail-val.amt-red{color:var(--red);}
.modal-box.detail-box{width:480px;max-width:96vw;}
.rpt-table tbody td{padding:9px 10px;vertical-align:middle;}
.rpt-table tbody tr:last-child{border-bottom:none;}
.rpt-table tfoot tr{background:#f1f5f9;border-top:2px solid var(--border);}
.rpt-table tfoot td{padding:9px 10px;font-weight:800;font-size:12.5px;}

/* Badges */
.badge{display:inline-block;padding:2px 7px;border-radius:3px;font-size:10px;font-weight:700;letter-spacing:.3px;}
.badge-buy{background:#fff3e0;color:#bf6000;border:1px solid #ffe0b2;}
.badge-sell{background:#e8f5e9;color:#1b5e20;border:1px solid #c8e6c9;}
.badge-cust{background:#e3f2fd;color:#0d47a1;border:1px solid #bbdefb;}
.badge-dr{background:#e8f5e9;color:#1b5e20;}
.badge-cr{background:#fff3e0;color:#bf6000;}
.bal-cell{font-weight:700;}
.bal-cell.zero{color:var(--green);}
.bal-cell.due{color:var(--red);}
.bal-cell.credit{color:var(--green);}
.bb-print{background:rgba(255,255,255,.15);color:#fff;border-color:rgba(255,255,255,.35);}
.bb-print:hover{background:rgba(255,255,255,.25);}
.pax-list{font-size:10px;line-height:1.5;color:var(--text);}
.pax-list .pax-item{white-space:normal;word-break:break-word;}
.rpt-table .col-pax{width:200px;max-width:200px;min-width:120px;}
.rpt-table .col-tkt{white-space:nowrap;min-width:90px;}
.rpt-table .col-date{white-space:nowrap;min-width:90px;}
.rpt-table .col-party{min-width:110px;}
.rpt-table .col-amt{white-space:nowrap;min-width:80px;}
.rpt-table .col-bal{white-space:nowrap;min-width:80px;}
.print-header{display:none;}
@media print{
  .tw-nav,.rpt-hdr,.sum-row,.no-print{display:none!important;}
  .tw,.tw-body{height:auto!important;overflow:visible!important;}
  .tbl-wrap{box-shadow:none;border:none;overflow:visible!important;}
  .rpt-table{min-width:unset!important;font-size:10px;}
  .rpt-table thead tr{background:#1a2744!important;-webkit-print-color-adjust:exact;print-color-adjust:exact;}
  .rpt-table thead th{color:#fff!important;padding:5px 6px!important;}
  body{background:#fff;font-size:11px;}
  .tw-body{padding:4px 6px!important;overflow:visible!important;}
  .rpt-table tbody td{padding:4px 6px!important;}
  .print-header{display:flex!important;}
  *{-webkit-print-color-adjust:exact!important;print-color-adjust:exact!important;}
  @page{size:A4 landscape;margin:8mm 8mm;}
}

/* Modal */
.modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:2000;align-items:center;justify-content:center;}
.modal-overlay.active{display:flex;}
.modal-box{background:#fff;border-radius:var(--r);width:360px;max-width:95vw;box-shadow:0 8px 32px rgba(0,0,0,.25);overflow:hidden;}
.modal-head{background:linear-gradient(135deg,var(--navy),var(--navy2));padding:12px 16px;display:flex;align-items:center;justify-content:space-between;}
.modal-head-title{color:#fff;font-weight:800;font-size:13px;display:flex;align-items:center;gap:8px;}
.modal-head-title i{color:var(--gold);}
.modal-close{background:none;border:none;color:rgba(255,255,255,.7);font-size:18px;cursor:pointer;line-height:1;}
.modal-close:hover{color:#fff;}
.modal-body{padding:16px;display:flex;flex-direction:column;gap:12px;}
.mfg{display:flex;flex-direction:column;gap:4px;}
.mfg label{font-size:10.5px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;}
.mfg input,.mfg select{height:34px;border:1.5px solid var(--border);border-radius:var(--r-sm);padding:0 10px;font-size:13px;outline:none;width:100%;}
.mfg input:focus,.mfg select:focus{border-color:var(--violet);}
.modal-foot{padding:12px 16px;display:flex;gap:8px;justify-content:flex-end;border-top:1px solid var(--border-l);}
.info-row{background:#fafafa;border-radius:var(--r-sm);padding:8px 12px;font-size:12px;color:var(--text);}
.info-row span{font-weight:700;}
.mfg textarea{border:1.5px solid var(--border);border-radius:var(--r-sm);padding:8px 10px;font-size:13px;outline:none;width:100%;resize:vertical;min-height:72px;font-family:inherit;}
.mfg textarea:focus{border-color:var(--violet);}
</style>
</head>
<body>
<div class="tw">
  <div class="tw-nav"><%@ include file="/assets/navbar/navbar.jsp" %></div>

  <!-- HEADER -->
  <div class="rpt-hdr">
    <div class="rpt-title">
      <i class="fa-solid fa-book-open"></i>
      <span>TICKET LEDGER</span>
    </div>
    <div class="hdr-divider"></div>

    <form method="get" action="" style="display:contents;">
      <div class="fg">
        <div class="fg-lbl">From Date</div>
        <input type="date" name="fromDate" class="fg-inp" value="<%=fromDate%>" style="width:135px;">
      </div>
      <div class="fg">
        <div class="fg-lbl">To Date</div>
        <input type="date" name="toDate" class="fg-inp" value="<%=toDate%>" style="width:135px;">
      </div>
      <div class="fg">
        <div class="fg-lbl">Agent</div>
        <select name="agentFilter" class="fg-sel" style="width:140px;">
          <option value="0">All Agents</option>
          <%for (int i = 0; i < agents.size(); i++) { Vector a = (Vector) agents.get(i);%>
          <option value="<%=a.get(0)%>" <%=(agentFilterId == Integer.parseInt(a.get(0).toString()) ? "selected" : "")%>><%=a.get(1)%></option>
          <%}%>
        </select>
      </div>
      <button type="submit" class="bb bb-gold">
        <i class="fa-solid fa-magnifying-glass"></i> Search
      </button>
    </form>

    <div class="hdr-spacer"></div>
    <button class="bb bb-print no-print" onclick="window.print()">
      <i class="fa-solid fa-print"></i> Print
    </button>
  </div>

  <!-- PRINT HEADER (visible only when printing) -->
  <div class="print-header" style="display:none;align-items:center;gap:14px;padding:10px 16px;background:linear-gradient(135deg,#1a2744 0%,#243159 100%);border-bottom:3px solid #c9922a;margin-bottom:8px;">
    <div style="flex:1;">
      <div style="color:#c9922a;font-size:18px;font-weight:900;letter-spacing:1px;text-transform:uppercase;"><%=companyName%></div>
      <%if (!companyAddr.isEmpty()){%><div style="color:rgba(255,255,255,.75);font-size:12px;margin-top:2px;"><%=companyAddr%></div><%}%>
    </div>
    <div style="text-align:right;color:rgba(255,255,255,.7);font-size:11px;">
      <div style="font-weight:700;color:#fff;font-size:13px;">Ticket Ledger Report</div>
      <div style="margin-top:3px;"><%=fromDisp%> &nbsp;to&nbsp; <%=toDisp%></div>
    </div>
  </div>

  <!-- BODY -->
  <div class="tw-body">

    <!-- Summary -->
    <div class="sum-row">
      <div class="sum-chip chip-advance">
        <div class="sum-chip-top">
          <div class="sum-chip-body">
            <div class="sum-chip-lbl">Agent Advance (We Have to Pay)</div>
            <div class="sum-chip-val">&#8377;<%=df.format(totalAdvance)%></div>
          </div>
          <% if (agentSelected) { %>
          <button type="button" class="btn-chip btn-chip-pay no-print" onclick="openAgentModal('PAY')">
            <i class="fa-solid fa-money-bill-wave"></i> Pay
          </button>
          <% } %>
        </div>
      </div>
      <div class="sum-chip chip-agent-due">
        <div class="sum-chip-top">
          <div class="sum-chip-body">
            <div class="sum-chip-lbl">Balance (Agent Has to Pay)</div>
            <div class="sum-chip-val">&#8377;<%=df.format(totalAgentDue)%></div>
          </div>
          <% if (agentSelected) { %>
          <button type="button" class="btn-chip btn-chip-collect no-print" onclick="openAgentModal('COLLECT')">
            <i class="fa-solid fa-coins"></i> Collect
          </button>
          <% } %>
        </div>
      </div>
    </div>

    <!-- Table -->
    <div class="tbl-wrap">
      <table class="rpt-table">
        <thead>
          <tr>
            <th>#</th>
            <th class="col-date">Date</th>
            <th class="col-tkt">Ticket / PNR</th>
            <th class="col-pax">Passengers</th>
            <th class="col-party">Party</th>
            <th>Type</th>
            <th>DR/CR</th>
            <th class="col-amt">Bill Amt</th>
            <th class="col-amt">Paid Amt</th>
            <th>Mode</th>
            <th>Txn No</th>
            <th class="col-bal">Balance</th>
          </tr>
        </thead>
        <tbody>
        <%
        if (rows.isEmpty()) {
        %>
          <tr><td colspan="12" style="text-align:center;padding:30px;color:var(--muted);">
            <i class="fa-solid fa-inbox" style="font-size:24px;display:block;margin-bottom:8px;"></i>
            No ledger entries found for this period.
          </td></tr>
        <%
        } else {
          int sno = 1;
          for (int i = 0; i < rows.size(); i++) {
            Vector r = (Vector) rows.get(i);
            int bookingId   = r.get(0) != null ? Integer.parseInt(r.get(0).toString()) : 0;
            String tktNo      = r.get(1) != null ? r.get(1).toString() : "-";
            String pnr        = r.get(2) != null ? r.get(2).toString() : "-";
            String partyType  = r.get(3) != null ? r.get(3).toString() : "";
            String partyDisp  = r.get(4) != null ? r.get(4).toString() : "-";
            double bill  = r.get(5) != null ? Math.abs(Double.parseDouble(r.get(5).toString())) : 0;
            double paid  = r.get(6) != null ? Math.abs(Double.parseDouble(r.get(6).toString())) : 0;
            String fdate = r.get(8) != null ? r.get(8).toString() : "";
            String txnTime = r.size() > 17 && r.get(17) != null ? r.get(17).toString().trim() : "";
            String payModeName   = r.get(11) != null ? r.get(11).toString() : "";
            String lastTxnNo     = r.get(12) != null ? r.get(12).toString() : "";
            String pName         = r.get(13) != null ? r.get(13).toString() : "";
            String txnType       = r.get(14) != null ? r.get(14).toString() : "";
            String remarks       = r.size() > 15 && r.get(15) != null ? r.get(15).toString() : "";
            String chargeType    = r.size() > 16 && r.get(16) != null ? r.get(16).toString() : "";
            String ledgerId      = r.size() > 18 && r.get(18) != null ? r.get(18).toString() : "";
            String remarksAttr   = remarks.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace("'","&#39;");
            String pNameAttr     = pName.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace("'","&#39;");
            String partyDispAttr = partyDisp.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace("'","&#39;");

            String ptBadge = "badge-cust";
            String ptLabel = partyType;
            if ("BUY_AGENT".equals(partyType))       { ptBadge = "badge-buy";  ptLabel = "Buy Agent"; }
            else if ("SELL_AGENT".equals(partyType)) { ptBadge = "badge-sell"; ptLabel = "Sell Agent"; }
            else if ("AGENT_ACCOUNT".equals(partyType)) { ptBadge = "badge-sell"; ptLabel = "Agent Account"; }
            else if ("CUSTOMER".equals(partyType))   { ptBadge = "badge-cust"; ptLabel = "Customer"; }

            String typeLabel = chargeType;
            if ("BALANCE_PAY".equals(chargeType)) typeLabel = "Pay Balance";
            else if ("ADVANCE_PAID".equals(chargeType)) typeLabel = "Advance Paid";
            else if ("BALANCE_COLLECT".equals(chargeType)) typeLabel = "Balance Collect";
            else if ("ADVANCE_COLLECT".equals(chargeType)) typeLabel = "Advance Collect";
            else if ("ADVANCE_CREDIT".equals(chargeType)) typeLabel = "Advance Credit";
            else if ("ORIGINAL".equals(chargeType) || chargeType.isEmpty()) typeLabel = "Ticket";
            else if (chargeType.length() > 0) typeLabel = chargeType.replace('_', ' ');

            String txnBadge = "DR".equals(txnType) ? "badge-dr" : "badge-cr";

            if (bill > 0.005) totalBill += bill;
            totalPaid += paid;
            applyLedgerRunningRow(partyType, chargeType, txnType, bill, paid, runState);
            double bal = runningBalanceAmount(runState[0], runState[1]);
            String balCls = runningBalanceClass(runState[0], runState[1]);
            lastBal = bal;
            lastBalCls = balCls;
            String ptLabelAttr = ptLabel.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace("'","&#39;");
            String typeLabelAttr = typeLabel.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace("'","&#39;");
            String tktNoAttr = tktNo.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace("'","&#39;");
            String pnrAttr = pnr.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace("'","&#39;");
            String modeAttr = payModeName.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace("'","&#39;");
            String txnNoAttr = lastTxnNo.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace("'","&#39;");
        %>
          <tr class="ledger-row no-print"
              onclick="openLedgerDetail(this)"
              data-ledger-id="<%=ledgerId%>"
              data-booking-id="<%=bookingId%>"
              data-date="<%=fdate%>"
              data-time="<%=txnTime%>"
              data-ticket="<%=tktNoAttr%>"
              data-pnr="<%=pnrAttr%>"
              data-passengers="<%=pNameAttr%>"
              data-party="<%=partyDispAttr%>"
              data-party-type="<%=partyType%>"
              data-party-label="<%=ptLabelAttr%>"
              data-type="<%=typeLabelAttr%>"
              data-txn-type="<%=txnType%>"
              data-bill="<%=df.format(bill)%>"
              data-paid="<%=df.format(paid)%>"
              data-mode="<%=modeAttr%>"
              data-txn-no="<%=txnNoAttr%>"
              data-remarks="<%=remarksAttr%>"
              data-run-bal="<%=df.format(bal)%>"
              data-run-bal-cls="<%=balCls%>">
            <td style="color:var(--muted);"><%=sno++%></td>
            <td style="white-space:nowrap;">
              <div><%=fdate%></div>
              <% if (!txnTime.isEmpty()) { %><div style="font-size:10px;color:var(--muted);margin-top:2px;"><%=txnTime%></div><% } %>
            </td>
            <td>
              <div style="font-weight:700;color:var(--gold);"><%=tktNo%></div>
              <div style="font-size:11px;color:var(--muted);"><%=pnr%></div>
            </td>
            <td>
              <div class="pax-list">
              <%
                String[] paxArr = pName.isEmpty() ? new String[0] : pName.split(",");
                for (int pi = 0; pi < paxArr.length; pi++) {
                  String pax = paxArr[pi].trim();
                  if (!pax.isEmpty()) {
              %><div class="pax-item"><i class="fa-solid fa-user" style="font-size:9px;color:var(--muted);margin-right:3px;"></i><%=pax%></div><%
                  }
                }
                if (paxArr.length == 0) { %><span style="color:var(--muted);">—</span><% }
              %>
              </div>
            </td>
            <td>
              <span class="badge <%=ptBadge%>"><%=ptLabel%></span>
              <div style="font-size:12px;margin-top:3px;font-weight:600;"><%=partyDisp%></div>
            </td>
            <td><%=typeLabel%></td>
            <td><span class="badge <%=txnBadge%>"><%=txnType%></span></td>
            <td style="font-weight:600;">&#8377;<%=df.format(bill)%></td>
            <td style="color:var(--green);font-weight:600;">&#8377;<%=df.format(paid)%></td>
            <td style="font-size:11px;color:var(--text);"><%=payModeName.isEmpty() ? "-" : payModeName%></td>
            <td style="font-size:11px;color:var(--violet);font-weight:600;">
              <%=lastTxnNo.isEmpty() ? "<span style='color:var(--muted);'>—</span>" : lastTxnNo%>
            </td>
            <td class="bal-cell <%=balCls%>">&#8377;<%=df.format(Math.abs(bal))%></td>
          </tr>
        <%
          }
        }
        %>
        </tbody>
        <tfoot>
          <tr>
            <td colspan="7" style="color:var(--muted);">TOTALS</td>
            <td>&#8377;<%=df.format(totalBill)%></td>
            <td style="color:var(--green);">&#8377;<%=df.format(totalPaid)%></td>
            <td></td><td></td>
            <td class="bal-cell <%=lastBalCls%>">&#8377;<%=df.format(lastBal)%></td>
          </tr>
        </tfoot>
      </table>
    </div>

    <div style="height:20px;"></div>
  </div><!-- /tw-body -->
</div><!-- /tw -->

<!-- ── LEDGER DETAIL MODAL ── -->
<div class="modal-overlay" id="ledgerDetailModal">
  <div class="modal-box detail-box">
    <div class="modal-head">
      <div class="modal-head-title"><i class="fa-solid fa-receipt"></i> Ledger Details</div>
      <button class="modal-close" onclick="closeLedgerDetail()">&times;</button>
    </div>
    <div class="modal-body" id="ledgerDetailBody"></div>
    <div class="modal-foot">
      <button class="bb bb-gold" onclick="closeLedgerDetail()">Close</button>
    </div>
  </div>
</div>

<!-- ── AGENT PAY / COLLECT MODAL ── -->
<div class="modal-overlay" id="agentModal">
  <div class="modal-box">
    <div class="modal-head">
      <div class="modal-head-title" id="agentModalTitle"><i class="fa-solid fa-money-bill-wave"></i> Pay Advance</div>
      <button class="modal-close" onclick="closeAgentModal()">&times;</button>
    </div>
    <div class="modal-body">
      <div class="info-row" id="agentModalInfo"></div>
      <div class="mfg">
        <label>Date</label>
        <input type="date" id="agentTxnDate" value="<%=today%>">
      </div>
      <div class="mfg">
        <label id="agentAmountLabel">Amount to Pay</label>
        <input type="number" step="0.01" id="agentAmount" placeholder="0.00">
      </div>
      <div class="mfg">
        <label>Payment Mode</label>
        <select id="agentMode" onchange="handleAgentModeChange()">
          <option value="">— Select Mode —</option>
          <%for (int i = 0; i < payModes.size(); i++) { Vector pm = (Vector) payModes.get(i);%>
          <option value="<%=pm.get(0)%>" data-cash="<%=pm.get(1).toString().toLowerCase().contains("cash") ? "1" : "0"%>"><%=pm.get(1)%></option>
          <%}%>
        </select>
      </div>
      <div class="mfg" id="agentTxnRow" style="display:none;">
        <label>Transaction No <span style="color:#dc2626;">*</span></label>
        <input type="text" id="agentTxnNo" placeholder="Txn / Ref No for online payment">
      </div>
      <div class="mfg">
        <label>Notes <span style="color:#dc2626;">*</span></label>
        <textarea id="agentNotes" placeholder="Enter payment / collection notes"></textarea>
      </div>
    </div>
    <div class="modal-foot">
      <button class="bb" style="background:#f1f5f9;color:var(--text);border-color:var(--border);" onclick="closeAgentModal()">Cancel</button>
      <button class="bb bb-gold" id="agentSubmitBtn" onclick="saveAgentTxn()"><i class="fa-solid fa-money-bill-wave"></i> Pay</button>
    </div>
  </div>
</div>

<script>
const ctx = '<%=ctx%>';
const agentId = <%=agentFilterId%>;
const agentName = '<%=selectedAgentName.replace("'", "\\'")%>';
const agentAdvance = <%=totalAdvance%>;
const agentDue = <%=totalAgentDue%>;
let _agentAction = 'PAY';

function openLedgerDetail(row) {
  if (!row || !row.dataset) return;
  const d = row.dataset;
  const balCls = d.runBalCls || 'zero';
  const balColor = balCls === 'due' ? 'var(--red)' : 'var(--green)';
  const dateTime = d.date + (d.time ? ' &nbsp;' + d.time : '');

  document.getElementById('ledgerDetailBody').innerHTML =
    '<div class="detail-grid">' +
      detailItem('Ledger ID', d.ledgerId || '—') +
      detailItem('Date &amp; Time', dateTime) +
      detailItem('Ticket No', d.ticket || '—') +
      detailItem('PNR', d.pnr || '—') +
      detailItem('Booking ID', d.bookingId && d.bookingId !== '0' ? d.bookingId : '—') +
      detailItem('Party Type', d.partyLabel || d.partyType || '—') +
      detailItem('Agent / Party', d.party || '—') +
      detailItem('Entry Type', d.type || '—') +
      detailItem('DR / CR', d.txnType || '—') +
      detailItem('Bill Amount', '&#8377;' + (d.bill || '0.00'), 'amt') +
      detailItem('Paid Amount', '&#8377;' + (d.paid || '0.00'), 'amt-green') +
      detailItem('Payment Mode', d.mode || '—') +
      detailItem('Transaction No', d.txnNo || '—') +
      detailItem('Running Balance', '&#8377;' + (d.runBal || '0.00'), null, balColor) +
      detailItem('Passengers', d.passengers || '—', 'full') +
      detailItem('Remarks', d.remarks || '—', 'full') +
    '</div>';

  document.getElementById('ledgerDetailModal').classList.add('active');
}

function detailItem(label, value, cls, color) {
  let valCls = 'detail-val';
  if (cls === 'amt-green') valCls += ' amt-green';
  else if (cls === 'amt') valCls += '';
  const style = color ? ' style="color:' + color + ';"' : (cls === 'amt-green' ? ' style="color:var(--green);"' : '');
  const colCls = cls === 'full' ? ' detail-item full' : ' detail-item';
  return '<div class="' + colCls.trim() + '"><div class="detail-lbl">' + label + '</div><div class="' + valCls + '"' + style + '>' + (value || '—') + '</div></div>';
}

function closeLedgerDetail() {
  document.getElementById('ledgerDetailModal').classList.remove('active');
}

function openAgentModal(action) {
  if (!agentId) {
    alert('Please select a particular agent first.');
    return;
  }
  _agentAction = action;
  const isPay = action === 'PAY';
  const titleEl = document.getElementById('agentModalTitle');
  const infoEl = document.getElementById('agentModalInfo');
  const amtLbl = document.getElementById('agentAmountLabel');
  const submitBtn = document.getElementById('agentSubmitBtn');

  titleEl.innerHTML = isPay
    ? '<i class="fa-solid fa-money-bill-wave"></i> Pay Advance'
    : '<i class="fa-solid fa-coins"></i> Collect Balance';
  infoEl.innerHTML =
    'Agent: <span>' + agentName + '</span>' +
    ' &nbsp;|&nbsp; Advance: <span style="color:#dc2626;">&#8377;' + agentAdvance.toFixed(2) + '</span>' +
    ' &nbsp;|&nbsp; Balance: <span style="color:#059669;">&#8377;' + agentDue.toFixed(2) + '</span>';
  if (amtLbl) amtLbl.textContent = isPay ? 'Amount to Pay' : 'Amount to Collect';
  submitBtn.innerHTML = isPay
    ? '<i class="fa-solid fa-money-bill-wave"></i> Pay'
    : '<i class="fa-solid fa-coins"></i> Collect';

  document.getElementById('agentAmount').value = '';
  document.getElementById('agentMode').value = '';
  document.getElementById('agentTxnRow').style.display = 'none';
  document.getElementById('agentTxnNo').value = '';
  document.getElementById('agentNotes').value = '';
  document.getElementById('agentModal').classList.add('active');
}

function closeAgentModal() {
  document.getElementById('agentModal').classList.remove('active');
}

function handleAgentModeChange() {
  const sel = document.getElementById('agentMode');
  const opt = sel.options[sel.selectedIndex];
  const isOnline = sel.value && opt.getAttribute('data-cash') === '0';
  document.getElementById('agentTxnRow').style.display = isOnline ? '' : 'none';
  if (!isOnline) document.getElementById('agentTxnNo').value = '';
}

function saveAgentTxn() {
  const amt = parseFloat(document.getElementById('agentAmount').value);
  const mode = document.getElementById('agentMode').value;
  const date = document.getElementById('agentTxnDate').value;
  const txnNo = document.getElementById('agentTxnNo').value.trim();
  const notes = document.getElementById('agentNotes').value.trim();

  if (!amt || amt <= 0) { alert('Enter a valid amount'); return; }
  if (!mode) { alert('Select a payment mode'); return; }
  if (!date) { alert('Select a date'); return; }
  if (!notes) { alert('Enter notes'); return; }
  const opt = document.getElementById('agentMode').options[document.getElementById('agentMode').selectedIndex];
  if (opt.getAttribute('data-cash') === '0' && !txnNo) { alert('Enter Transaction No for online payment'); return; }

  const params = new URLSearchParams();
  params.set('agentId', agentId);
  params.set('action', _agentAction);
  params.set('amount', amt);
  params.set('payModeId', mode);
  params.set('txnDate', date);
  params.set('txnNo', txnNo);
  params.set('notes', notes);

  fetch(ctx + '/ticketbooking/agentAccountPayCollect.jsp', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: params.toString()
  })
  .then(r => r.text())
  .then(d => {
    if (d.trim() === 'SUCCESS') {
      closeAgentModal();
      location.reload();
    } else {
      alert('Error: ' + d);
    }
  })
  .catch(err => alert('Error: ' + err.message));
}

document.getElementById('agentModal').addEventListener('click', function(e) {
  if (e.target === this) closeAgentModal();
});

document.getElementById('ledgerDetailModal').addEventListener('click', function(e) {
  if (e.target === this) closeLedgerDetail();
});

// Auto-collapse sidebar on page load (desktop only)
document.addEventListener('DOMContentLoaded', function() {
    if (window.innerWidth > 768) {
        var sb = document.getElementById('sidebar');
        if (sb) sb.classList.add('hidden');
        document.body.classList.add('sidebar-hidden');
    }
});
</script>
</body>
</html>
