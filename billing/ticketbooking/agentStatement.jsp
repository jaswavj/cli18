<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,java.text.SimpleDateFormat"%>
<jsp:useBean id="billing" class="billing.billingBean" />
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
String agentIdP = request.getParameter("agentId");
String ticketWiseP = request.getParameter("ticketWise");
if (fromDate == null || fromDate.isEmpty()) fromDate = today;
if (toDate   == null || toDate.isEmpty())   toDate   = today;
boolean showTicketWise = "1".equals(ticketWiseP);
int agentId = 0;
try { if (agentIdP != null && !agentIdP.isEmpty()) agentId = Integer.parseInt(agentIdP); } catch (Exception e) {}

Vector agents = billing.getTicketAgents();

// Company name (use direct instantiation to avoid duplicate bean with navbar.jsp)
String companyName = "MOULANA AIR TRAVELS";
String companyAddress = "";
try {
    user.userBean uBean = new user.userBean();
    Vector companyInfo = uBean.getCompanyDetails();
    if (companyInfo != null && companyInfo.size() > 1 && companyInfo.get(1) != null)
        companyName = companyInfo.get(1).toString();
    if (companyInfo != null && companyInfo.size() > 2 && companyInfo.get(2) != null)
        companyAddress = companyInfo.get(2).toString();
} catch (Exception e) { /* use default */ }

// Data (only load when agent is selected)
Vector rows = new Vector();
Vector ledgerRows = new Vector();
String selectedAgentName = "";
if (agentId > 0) {
    rows = billing.getAgentStatement(fromDate, toDate, agentId);
    ledgerRows = billing.getTicketLedgerReport(fromDate, toDate, agentId);

    // Get agent name from OPEN row
    if (rows.size() > 0) {
        Vector firstRow = (Vector) rows.get(0);
        selectedAgentName = firstRow.get(11) != null ? firstRow.get(11).toString() : "";
    }
    if (selectedAgentName.isEmpty()) {
        for (int i = 0; i < agents.size(); i++) {
            Vector a = (Vector) agents.get(i);
            if (a.get(0).toString().equals(String.valueOf(agentId))) {
                selectedAgentName = a.get(1).toString(); break;
            }
        }
    }
}

// Format date for display e.g. 07/05/2026
java.text.SimpleDateFormat dpFmt = new java.text.SimpleDateFormat("dd/MM/yyyy");
java.text.SimpleDateFormat iFmt  = new java.text.SimpleDateFormat("yyyy-MM-dd");
String fromDisp = fromDate, toDisp = toDate;
try { fromDisp = dpFmt.format(iFmt.parse(fromDate)); } catch (Exception e) {}
try { toDisp   = dpFmt.format(iFmt.parse(toDate));   } catch (Exception e) {}

// Totals from TOTAL row
String totalDrStr = "0.00", totalCrStr = "0.00", closingBal = "0.00", closingDir = "NIL";
if (rows.size() > 0) {
    Vector lastRow = (Vector) rows.get(rows.size() - 1);
    if ("TOTAL".equals(lastRow.get(0))) {
        totalDrStr  = lastRow.get(3).toString();
        totalCrStr  = lastRow.get(4).toString();
        closingBal  = lastRow.get(5).toString();
        closingDir  = lastRow.get(6).toString();
    }
}

// Ticket-wise summary from ledger (includes cancelled tickets)
java.util.LinkedHashMap ticketPayMap = new java.util.LinkedHashMap();
for (int i = 0; i < ledgerRows.size(); i++) {
    Vector lr = (Vector) ledgerRows.get(i);
    int bookingId = 0;
    try { bookingId = lr.get(0) != null ? Integer.parseInt(lr.get(0).toString()) : 0; } catch (Exception e) { bookingId = 0; }
    if (bookingId <= 0) continue;

    String partyType = lr.get(3) != null ? lr.get(3).toString() : "";
    if (!"BUY_AGENT".equals(partyType) && !"SELL_AGENT".equals(partyType)) continue;

    String chargeType = lr.size() > 16 && lr.get(16) != null ? lr.get(16).toString() : "";
    boolean isCancelledBk = lr.size() > 20 && "1".equals(String.valueOf(lr.get(20)));
    boolean isCancelRow = "CANCEL_CHARGE".equals(chargeType);
    if (isCancelledBk && !isCancelRow) continue;

    String side = "BUY_AGENT".equals(partyType) ? "BUY" : "SELL";
    String mapKey = String.valueOf(bookingId) + "|" + side;

    String tktNo = lr.get(1) != null ? lr.get(1).toString() : "-";
    String pnr = lr.get(2) != null ? lr.get(2).toString() : "-";
    String pName = lr.size() > 13 && lr.get(13) != null ? lr.get(13).toString() : "-";
    String txnDate = lr.get(8) != null ? lr.get(8).toString() : "";
    String payMode = lr.size() > 11 && lr.get(11) != null ? lr.get(11).toString() : "";
    double cancelChg = lr.size() > 19 && lr.get(19) != null ? Math.abs(Double.parseDouble(lr.get(19).toString())) : 0;
    double rowBill = lr.get(5) != null ? Math.abs(Double.parseDouble(lr.get(5).toString())) : 0;
    double paidAmt = lr.get(6) != null ? Math.abs(Double.parseDouble(lr.get(6).toString())) : 0;

    java.util.Map info = (java.util.Map) ticketPayMap.get(mapKey);
    if (info == null) {
        info = new java.util.HashMap();
        info.put("bookingId", String.valueOf(bookingId));
        info.put("side", side);
        info.put("ticketNo", tktNo);
        info.put("pnr", pnr);
        info.put("passengerName", pName.isEmpty() ? "-" : pName);
        info.put("bill", new Double(0));
        info.put("paid", new Double(0));
        info.put("isCancelled", isCancelRow ? "1" : "0");
        info.put("lastPayDate", "");
        info.put("entries", new java.util.ArrayList());
        info.put("sortDate", txnDate);
        info.put("sortId", String.valueOf(bookingId));
        ticketPayMap.put(mapKey, info);
    }

    if (isCancelRow) {
        info.put("bill", new Double(cancelChg));
        info.put("paid", new Double(rowBill));
        info.put("balance", new Double(Math.abs(billing.getBookingCancelPendingBalance(bookingId, partyType))));
        info.put("isCancelled", "1");
        if (!txnDate.isEmpty()) info.put("sortDate", txnDate);
    } else {
        double oldBill = ((Double) info.get("bill")).doubleValue();
        double oldPaid = ((Double) info.get("paid")).doubleValue();
        info.put("bill", new Double(oldBill + rowBill));
        info.put("paid", new Double(oldPaid + paidAmt));
        double billTot = ((Double) info.get("bill")).doubleValue();
        double paidTot = ((Double) info.get("paid")).doubleValue();
        info.put("balance", new Double(Math.max(0, billTot - paidTot)));
    }

    if (paidAmt > 0.005) {
        java.util.List entries = (java.util.List) info.get("entries");
        entries.add((txnDate.isEmpty() ? "-" : txnDate) + " | " + (payMode.isEmpty() ? "-" : payMode) + " | " + String.format("%.2f", paidAmt));
        String prevDate = info.get("lastPayDate") != null ? info.get("lastPayDate").toString() : "";
        if (!txnDate.isEmpty() && (prevDate.isEmpty() || txnDate.compareTo(prevDate) > 0)) info.put("lastPayDate", txnDate);
    } else if (txnDate.isEmpty() == false && (info.get("lastPayDate") == null || info.get("lastPayDate").toString().isEmpty())) {
        info.put("lastPayDate", txnDate);
    }
}
java.util.List ticketPayList = new java.util.ArrayList(ticketPayMap.values());
java.util.Collections.sort(ticketPayList, new java.util.Comparator() {
    public int compare(Object o1, Object o2) {
        java.util.Map a = (java.util.Map) o1;
        java.util.Map b = (java.util.Map) o2;
        String d1 = a.get("sortDate") != null ? a.get("sortDate").toString() : "";
        String d2 = b.get("sortDate") != null ? b.get("sortDate").toString() : "";
        int c = d1.compareTo(d2);
        if (c != 0) return c;
        return a.get("sortId").toString().compareTo(b.get("sortId").toString());
    }
});
double tpTotalBill = 0, tpTotalPaid = 0, tpTotalBalance = 0;
for (int ti = 0; ti < ticketPayList.size(); ti++) {
    java.util.Map info = (java.util.Map) ticketPayList.get(ti);
    tpTotalBill += ((Double) info.get("bill")).doubleValue();
    tpTotalPaid += ((Double) info.get("paid")).doubleValue();
    if (info.get("balance") != null) tpTotalBalance += ((Double) info.get("balance")).doubleValue();
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Agent Statement</title>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<%@ include file="/assets/common/head.jsp" %>
<style>
:root{
    --navy:#1a2744;--navy2:#243159;--violet:#5c4d8a;--violet-d:#4a3d78;
    --gold:#c9922a;--gold-d:#a87520;--bg:#eef1f7;--card:#ffffff;
    --border:#d1d9e6;--border-l:#e8edf5;--text:#0f172a;--muted:#64748b;
    --inp-bg:#f8fafc;--green:#059669;--red:#dc2626;--r:8px;--r-sm:5px;
    --shadow:0 2px 12px rgba(0,0,0,.10);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
html,body{height:100%;font-family:'Segoe UI',system-ui,sans-serif;font-size:13px;background:var(--bg);color:var(--text);}
.tw{display:flex;flex-direction:column;height:100vh;height:100dvh;overflow:hidden;}
.tw-nav{flex-shrink:0;}
.tw-body{flex:1;min-height:0;overflow-y:auto;padding:12px 14px 20px;}
.tw-body::-webkit-scrollbar{width:5px;}
.tw-body::-webkit-scrollbar-thumb{background:var(--violet);border-radius:3px;}

/* Filter bar */
.filter-card{background:var(--card);border-radius:var(--r);padding:14px 16px;box-shadow:var(--shadow);display:flex;flex-wrap:wrap;gap:10px;align-items:flex-end;margin-bottom:14px;}
.filter-card label{display:block;font-size:11px;font-weight:600;color:var(--muted);margin-bottom:4px;}
.filter-card input,.filter-card select{height:34px;border:1px solid var(--border);border-radius:var(--r-sm);padding:0 10px;font-size:12px;background:var(--inp-bg);color:var(--text);outline:none;min-width:160px;}
.filter-card input:focus,.filter-card select:focus{border-color:var(--violet);}
.btn-search{height:34px;padding:0 20px;border:none;border-radius:var(--r-sm);background:var(--violet);color:#fff;font-size:12px;font-weight:600;cursor:pointer;}
.btn-search:hover{background:var(--violet-d);}
.btn-print{height:34px;padding:0 16px;border:none;border-radius:var(--r-sm);background:var(--navy);color:#fff;font-size:12px;font-weight:600;cursor:pointer;display:flex;align-items:center;gap:6px;}
.btn-print:hover{background:var(--navy2);}
.chk-wrap{display:flex;align-items:center;gap:8px;height:34px;padding:0 10px;border:1px solid var(--border);border-radius:var(--r-sm);background:var(--inp-bg);}
.chk-wrap input[type="checkbox"]{width:15px;height:15px;accent-color:var(--violet);}
.chk-wrap label{margin:0;font-size:12px;font-weight:600;color:var(--text);cursor:pointer;user-select:none;}

/* Statement container */
.stmt-wrap{background:var(--card);border-radius:var(--r);box-shadow:var(--shadow);overflow:hidden;}

/* Statement header */
.stmt-header{background:var(--navy);color:#fff;padding:14px 20px;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px;}
.stmt-header .co-name{font-size:16px;font-weight:700;letter-spacing:.5px;}
.stmt-header .ac-name{font-size:12px;opacity:.85;margin-top:2px;}
.stmt-header .period{font-size:12px;text-align:right;line-height:1.7;}

/* Table */
.stmt-table{width:100%;border-collapse:collapse;}
.stmt-table thead th{background:var(--navy2);color:#fff;padding:8px 10px;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;white-space:nowrap;}
.stmt-table th.num,.stmt-table td.num{text-align:right;}
.stmt-table td{padding:6px 10px;font-size:12px;border-bottom:1px solid var(--border-l);vertical-align:top;}
.stmt-table tr:hover td{background:#f5f7ff;}
.stmt-table tr.row-open td{background:#fffbf0;font-style:italic;}
.stmt-table tr.row-total td{background:var(--navy);color:#fff;font-weight:700;font-size:12px;}
.stmt-table tr.row-total:hover td{background:var(--navy);}
.stmt-table tr.row-pax td{background:#fafcff;border-bottom:1px dotted #e0e6f0;}
.stmt-table tr.row-pax:hover td{background:#f0f4ff;}

.particulars-main{font-weight:600;color:var(--text);}
.particulars-sub{font-size:11px;color:var(--muted);margin-top:2px;}
.particulars-route{font-size:11px;color:var(--violet);font-weight:600;margin-top:1px;}
.pax-label{font-size:11px;color:var(--muted);font-style:italic;}
.bal-dr{color:var(--red);font-weight:600;}
.bal-cr{color:var(--green);font-weight:600;}
.bal-nil{color:var(--muted);}
.dr-amt{color:#b45309;font-weight:600;}
.cr-amt{color:var(--green);font-weight:600;}
.badge-party{font-size:9px;padding:1px 5px;border-radius:3px;font-weight:700;margin-left:4px;}
.badge-buy{background:#fff3e0;color:#e65100;}
.badge-sell{background:#e8f5e9;color:#2e7d32;}
.badge-cust{background:#e3f2fd;color:#1565c0;}

/* Summary chips */
.summary-row{display:flex;gap:10px;flex-wrap:wrap;padding:12px 16px;border-bottom:1px solid var(--border);}
.s-chip{flex:1;min-width:120px;background:var(--bg);border-radius:var(--r-sm);padding:8px 12px;text-align:center;}
.s-chip .s-lbl{font-size:10px;font-weight:700;color:var(--muted);text-transform:uppercase;}
.s-chip .s-val{font-size:16px;font-weight:700;margin-top:2px;}
.s-chip.chip-dr .s-val{color:var(--red);}
.s-chip.chip-cr .s-val{color:var(--green);}
.s-chip.chip-bal .s-val{color:var(--violet);}

/* Ticket-wise payment summary */
.ticket-pay-wrap{margin-top:12px;border-top:1px solid var(--border);padding:12px 12px 0;}
.ticket-pay-title{font-size:13px;font-weight:700;color:var(--navy);margin-bottom:8px;display:flex;align-items:center;gap:6px;}
.ticket-pay-note{font-size:11px;color:var(--muted);margin-bottom:8px;}
.tp-table{width:100%;border-collapse:collapse;}
.tp-table th{background:#eef2ff;color:#1e293b;padding:7px 8px;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.3px;border-bottom:1px solid #dbe5f2;white-space:nowrap;}
.tp-table td{padding:7px 8px;font-size:11px;border-bottom:1px solid #edf2f7;vertical-align:top;}
.tp-table th.num,.tp-table td.num{text-align:right;}
.tp-col-passenger{font-size:10px;color:var(--muted);line-height:1.35;}
.tp-mode-lines{font-size:10px;line-height:1.45;color:var(--muted);}
.tp-bal-pos{color:var(--red);font-weight:700;}
.tp-bal-zero{color:var(--green);font-weight:700;}
.tp-fbal-pos{color:var(--red);font-weight:800;}
.tp-fbal-zero{color:var(--green);font-weight:800;}
.tp-table tfoot td{padding:8px;font-weight:800;font-size:12px;border-top:2px solid var(--border);background:#f1f5f9;-webkit-print-color-adjust:exact;print-color-adjust:exact;}
.tp-table tfoot .tp-total-lbl{text-align:right;color:var(--navy);letter-spacing:.3px;}

/* Empty */
.empty-state{padding:60px 20px;text-align:center;color:var(--muted);}
.empty-state i{font-size:40px;opacity:.3;margin-bottom:10px;}

/* Print styles */
@media print {
    .tw-nav,.filter-card,.btn-print,.no-print{display:none!important;}
    html,body{height:auto;background:#fff;font-size:11pt;}
    .tw,.tw-body{height:auto;overflow:visible;}
    .print-header{display:flex!important;}
    .stmt-wrap{box-shadow:none;border-radius:0;}
    .stmt-header{background:#1a2744!important;-webkit-print-color-adjust:exact;print-color-adjust:exact;}
    .stmt-table thead th{background:#243159!important;-webkit-print-color-adjust:exact;print-color-adjust:exact;}
    .stmt-table tr.row-total td{background:#1a2744!important;color:#fff!important;-webkit-print-color-adjust:exact;print-color-adjust:exact;}
    .stmt-table td{padding:4px 8px;font-size:10pt;}
    .stmt-table tr:hover td{background:transparent;}

    /* Ticket-wise print — show all columns */
    .ticket-pay-wrap{padding:0!important;margin-top:8px!important;border-top:none!important;}
    .ticket-pay-note{font-size:9pt!important;margin-bottom:6px!important;}
    .tp-table{width:100%!important;table-layout:auto;font-size:8pt!important;}
    .tp-table th,.tp-table td{padding:3px 5px!important;white-space:normal!important;word-break:break-word;}
    .tp-col-entries{font-size:7.5pt!important;line-height:1.35;}

    * { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
    @page{size:A4 landscape;margin:8mm 8mm;}
}
</style>
</head>
<body>
<div class="tw">

<!-- PRINT-ONLY HEADER -->
<div class="print-header" style="display:none;align-items:center;gap:14px;padding:10px 16px;background:linear-gradient(135deg,#1a2744 0%,#243159 100%);border-bottom:3px solid #c9922a;margin-bottom:8px;">
    <div style="flex:1;">
        <div style="color:#c9922a;font-size:18px;font-weight:900;letter-spacing:1px;text-transform:uppercase;"><%=companyName%></div>
        <%if (!companyAddress.isEmpty()){%><div style="color:rgba(255,255,255,.75);font-size:12px;margin-top:2px;"><%=companyAddress%></div><%}%>
    </div>
    <div style="text-align:right;color:rgba(255,255,255,.7);font-size:11px;">
        <div style="font-weight:700;color:#fff;">Agent Statement</div>
        <div style="color:#c9922a;font-weight:700;font-size:13px;margin-top:2px;"><%=selectedAgentName%></div>
        <div><%=fromDisp%> &nbsp;to&nbsp; <%=toDisp%></div>
    </div>
</div>

<div class="tw-nav"><%@ include file="/assets/navbar/navbar.jsp" %></div>
<div class="tw-body">

<!-- Filter -->
<form method="GET" action="" class="filter-card no-print">
    <div>
        <label>From Date</label>
        <input type="date" name="fromDate" value="<%=fromDate%>">
    </div>
    <div>
        <label>To Date</label>
        <input type="date" name="toDate" value="<%=toDate%>">
    </div>
    <div>
        <label>Agent <span style="color:var(--red)">*</span></label>
        <select name="agentId" required style="min-width:200px;">
            <option value="">-- Select Agent --</option>
            <% for (int i = 0; i < agents.size(); i++) {
                Vector ag = (Vector) agents.get(i);
                String aId   = ag.get(0) != null ? ag.get(0).toString() : "";
                String aName = ag.get(1) != null ? ag.get(1).toString() : "";
                boolean sel  = aId.equals(String.valueOf(agentId));
            %>
            <option value="<%=aId%>" <%=sel?"selected":""%>><%=aName%></option>
            <% } %>
        </select>
    </div>
    <div>
        <label>&nbsp;</label>
        <div class="chk-wrap">
            <input type="checkbox" id="ticketWise" name="ticketWise" value="1" <%=showTicketWise?"checked":""%>>
            <label for="ticketWise">Show Ticket-wise List</label>
        </div>
    </div>
    <button type="submit" class="btn-search"><i class="fa-solid fa-magnifying-glass" style="margin-right:5px;"></i>View Statement</button>
    <% if (agentId > 0 && rows.size() > 1) { %>
    <button type="button" class="btn-print" onclick="window.print()"><i class="fa-solid fa-print"></i>Print</button>
    <% } %>
</form>

<% if (agentId == 0) { %>
<!-- No agent selected -->
<div class="stmt-wrap">
    <div class="empty-state">
        <i class="fa-solid fa-book-open"></i>
        <div style="font-size:15px;font-weight:600;margin-bottom:6px;">Select an Agent</div>
        <div style="font-size:12px;">Choose an agent and date range to view the account statement.</div>
    </div>
</div>
<% } else { %>

<!-- Statement -->
<div class="stmt-wrap" id="stmtArea">

    <!-- Header -->
    

    <% if (!showTicketWise) { %>
    <% // Count TXN rows only (excluding OPEN and TOTAL)
       int txnCount = 0;
       for (int i = 0; i < rows.size(); i++) {
           Vector r = (Vector) rows.get(i);
           if ("TXN".equals(r.get(0))) txnCount++;
       }
    %>

    <% if (txnCount == 0) { %>
    <div class="empty-state">
        <i class="fa-solid fa-inbox"></i>
        <div style="font-size:14px;font-weight:600;margin-bottom:6px;">No Transactions Found</div>
        <div style="font-size:12px;">No ledger entries for <%=selectedAgentName%> in this period.</div>
    </div>
    <% } else { %>

    <!-- Summary chips -->
    <div class="summary-row no-print">
        <div class="s-chip chip-dr">
            <div class="s-lbl">Total DR (Charged)</div>
            <div class="s-val"><%=totalDrStr%></div>
        </div>
        <div class="s-chip chip-cr">
            <div class="s-lbl">Total CR (Received)</div>
            <div class="s-val"><%=totalCrStr%></div>
        </div>
        <div class="s-chip chip-bal">
            <div class="s-lbl">Closing Balance</div>
            <div class="s-val <%="DR".equals(closingDir)?"bal-dr":"CR".equals(closingDir)?"bal-cr":"bal-nil"%>">
                <%=closingBal%> <span style="font-size:11px;"><%="NIL".equals(closingDir)?"":closingDir%></span>
            </div>
        </div>
        <div class="s-chip">
            <div class="s-lbl">Transactions</div>
            <div class="s-val" style="color:var(--navy);"><%=txnCount%></div>
        </div>
    </div>

    <!-- Table -->
    <div style="overflow-x:auto;">
    <table class="stmt-table">
        <thead>
            <tr>
                <th style="width:88px;">Date</th>
                <th style="width:90px;">Vou.Number</th>
                <th>Particulars</th>
                <th class="num" style="width:110px;">Dr.Amount</th>
                <th class="num" style="width:110px;">Cr.Amount</th>
                <th class="num" style="width:130px;">Balance</th>
            </tr>
        </thead>
        <tbody>
        <%
        for (int i = 0; i < rows.size(); i++) {
            Vector r = (Vector) rows.get(i);
            String rowType   = r.get(0) != null ? r.get(0).toString() : "";
            String txnDate   = r.get(1) != null ? r.get(1).toString() : "";
            String vouNo     = r.get(2) != null ? r.get(2).toString() : "";
            String drAmt     = r.get(3) != null ? r.get(3).toString() : "";
            String crAmt     = r.get(4) != null ? r.get(4).toString() : "";
            String balance   = r.get(5) != null ? r.get(5).toString() : "";
            String balDir    = r.get(6) != null ? r.get(6).toString() : "";
            String partMain  = r.get(7) != null ? r.get(7).toString() : "";
            String route     = r.get(8) != null ? r.get(8).toString() : "";
            String flightInf = r.get(9) != null ? r.get(9).toString() : "";
            String extraPax  = r.get(10) != null ? r.get(10).toString() : "";
            String pType     = r.get(12) != null ? r.get(12).toString() : "";
            String remarks   = r.get(13) != null ? r.get(13).toString() : "";
            String billAmt   = r.get(14) != null ? r.get(14).toString() : "";

            String balCls = "DR".equals(balDir) ? "bal-dr" : "CR".equals(balDir) ? "bal-cr" : "bal-nil";
            String balDisplay = "NIL".equals(balDir) ? "0.00" : balance + " " + balDir;

            if ("OPEN".equals(rowType)) {
        %>
        <tr class="row-open">
            <td style="color:var(--muted);font-size:11px;">b/f</td>
            <td style="color:var(--muted);font-size:11px;">Opening Balance</td>
            <td></td>
            <td class="num dr-amt"><%=drAmt.isEmpty()?"":drAmt%></td>
            <td class="num cr-amt"><%=crAmt.isEmpty()?"":crAmt%></td>
            <td class="num <%=balCls%>"><%=balDisplay%></td>
        </tr>
        <%
            } else if ("TOTAL".equals(rowType)) {
        %>
        <tr class="row-total">
            <td colspan="3" style="text-align:right;letter-spacing:.5px;">TOTAL</td>
            <td class="num"><%=drAmt%></td>
            <td class="num"><%=crAmt%></td>
            <td class="num <%=balCls%>" style="color:#fff;"><%=balDisplay%></td>
        </tr>
        <%
            } else {
                // Determine party badge
                String badgeCls = "", badgeLbl = "";
                if ("BUY_AGENT".equals(pType))   { badgeCls="badge-buy";  badgeLbl="Buy";  }
                else if ("SELL_AGENT".equals(pType)) { badgeCls="badge-sell"; badgeLbl="Sell"; }
                else if ("CUSTOMER".equals(pType))   { badgeCls="badge-cust"; badgeLbl="Cust"; }
        %>
        <tr style="cursor:pointer;" onclick="showRemarkModal(<%=i%>)"
            data-vou="<%=vouNo.replace("\"","&quot;")%>"
            data-date="<%=txnDate%>"
            data-part="<%=partMain.replace("\"","&quot;").replace("'","&#39;")%>"
            data-flight="<%=flightInf.replace("\"","&quot;")%>"
            data-route="<%=route%>"
            data-bill="<%=billAmt%>"
            data-remark="<%=remarks.replace("\"","&quot;").replace("'","&#39;")%>">
            <td style="white-space:nowrap;color:var(--muted);"><%=txnDate%></td>
            <td style="white-space:nowrap;font-size:11px;">
                <%=vouNo%>
                <% if (!badgeLbl.isEmpty()) { %><span class="badge-party <%=badgeCls%>"><%=badgeLbl%></span><% } %>
            </td>
            <td>
                <div class="particulars-main"><%=partMain%></div>
                <% if (!flightInf.isEmpty()) { %><div class="particulars-sub"><%=flightInf%></div><% } %>
                <% if (!route.isEmpty()) { %><div class="particulars-route"><%=route%></div><% } %>
            </td>
            <td class="num dr-amt"><%=drAmt.isEmpty()?"":drAmt%></td>
            <td class="num cr-amt"><%=crAmt.isEmpty()?"":crAmt%></td>
            <td class="num <%=balCls%>"><%=balDisplay%></td>
        </tr>
        <%
                // Extra passengers as sub-rows
                if (!extraPax.isEmpty()) {
                    String[] paxList = extraPax.split("\\|\\|");
                    for (int p = 0; p < paxList.length; p++) {
                        String paxName = paxList[p].trim();
                        if (paxName.isEmpty()) continue;
        %>
        <tr class="row-pax">
            <td></td>
            <td class="pax-label">pax-<%=(p+2)%></td>
            <td><div class="particulars-main" style="font-size:11px;"><%=paxName%></div></td>
            <td></td><td></td><td></td>
        </tr>
        <%
                    }
                }
            } // end TXN row
        } // end for
        %>
        </tbody>
    </table>
    </div>
    <% } // end txnCount > 0 %>
    <% } // end !showTicketWise %>

        <% if (showTicketWise && ticketPayList.size() > 0) { %>
        <div class="ticket-pay-wrap">
            <div class="ticket-pay-title"><i class="fa-solid fa-money-check-dollar" style="color:var(--gold);"></i>Ticket-wise Payment & Balance</div>
            <div class="ticket-pay-note">Shows each ticket bill, paid amount, balance, and payment history (includes cancelled tickets with cancel charge).</div>
            <div style="overflow-x:auto;">
                <table class="tp-table">
                    <thead>
                        <tr>
                            <th style="width:90px;">Ticket</th>
                            <th class="tp-col-pnr" style="width:90px;">PNR</th>
                            <th class="tp-col-passenger" style="width:150px;">Passenger Name</th>
                            <th style="width:70px;">Side</th>
                            <th class="num tp-col-bill" style="width:90px;">Bill / Charge</th>
                            <th class="num tp-col-paid" style="width:90px;">Paid / Refund</th>
                            <th class="num tp-col-balance" style="width:90px;">Balance</th>
                            <th class="tp-col-last" style="width:105px;">Date</th>
                            <th class="tp-col-entries">Payment Entries (Date | Mode | Amount)</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (int ti = 0; ti < ticketPayList.size(); ti++) {
                           java.util.Map info = (java.util.Map) ticketPayList.get(ti);
                           String side = info.get("side") != null ? info.get("side").toString() : "SELL";
                           String tktNo = info.get("ticketNo") != null ? info.get("ticketNo").toString() : "-";
                           String pnr = info.get("pnr") != null ? info.get("pnr").toString() : "-";
                           String passengerName = info.get("passengerName") != null ? info.get("passengerName").toString() : "-";
                           boolean isCancelled = "1".equals(info.get("isCancelled"));
                           double billV = ((Double) info.get("bill")).doubleValue();
                           double paidV = ((Double) info.get("paid")).doubleValue();
                           double balV = info.get("balance") != null ? ((Double) info.get("balance")).doubleValue() : 0;
                           String lastPay = info.get("lastPayDate") != null ? info.get("lastPayDate").toString() : "";
                           java.util.List entries = (java.util.List) info.get("entries");
                           String balCls = Math.abs(balV) < 0.005 ? "tp-bal-zero" : "tp-bal-pos";
                           String sideBadge = "BUY".equals(side) ? "badge-buy" : "badge-sell";
                    %>
                        <tr>
                            <td style="font-weight:700;color:var(--gold);"><%=tktNo%><% if (isCancelled) { %> <span style="font-size:9px;color:var(--red);">(Cancelled)</span><% } %></td>
                            <td class="tp-col-pnr"><%=pnr%></td>
                            <td class="tp-col-passenger"><%=passengerName%></td>
                            <td><span class="badge-party <%=sideBadge%>"><%=side%></span></td>
                            <td class="num tp-col-bill"><%=String.format("%.2f", billV)%></td>
                            <td class="num tp-col-paid" style="color:var(--green);font-weight:700;"><%=String.format("%.2f", paidV)%></td>
                            <td class="num tp-col-balance <%=balCls%>"><%=String.format("%.2f", balV)%></td>
                            <td class="tp-col-last" style="white-space:nowrap;"><%=lastPay.isEmpty() ? "-" : lastPay%></td>
                            <td class="tp-col-entries">
                                <% if (entries == null || entries.size() == 0) { %>
                                    <span class="tp-mode-lines">-</span>
                                <% } else { %>
                                    <div class="tp-mode-lines">
                                    <% for (int ei = 0; ei < entries.size(); ei++) { %>
                                        <div><%=entries.get(ei)%></div>
                                    <% } %>
                                    </div>
                                <% } %>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                    <tfoot>
                        <tr>
                            <td colspan="4" class="tp-total-lbl">TOTAL</td>
                            <td class="num tp-col-bill"><%=String.format("%.2f", tpTotalBill)%></td>
                            <td class="num tp-col-paid" style="color:var(--green);"><%=String.format("%.2f", tpTotalPaid)%></td>
                            <td class="num tp-col-balance <%=Math.abs(tpTotalBalance) < 0.005 ? "tp-fbal-zero" : "tp-fbal-pos"%>"><%=String.format("%.2f", tpTotalBalance)%></td>
                            <td colspan="2"></td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </div>
        <% } %>

        <% if (showTicketWise && ticketPayList.size() == 0) { %>
        <div class="ticket-pay-wrap">
            <div class="ticket-pay-title"><i class="fa-solid fa-money-check-dollar" style="color:var(--gold);"></i>Ticket-wise Payment & Balance</div>
            <div class="ticket-pay-note">No ticket-wise payment entries found for the selected filters.</div>
        </div>
        <% } %>
</div>
<% } // end agentId > 0 %>

</div><!-- tw-body -->
</div><!-- tw -->

<script>
function showRemarkModal(idx) {
    var row = document.querySelector('tr[onclick="showRemarkModal(' + idx + ')"]');
    if (!row) return;
    var vou     = row.dataset.vou     || '';
    var date    = row.dataset.date    || '';
    var part    = row.dataset.part    || '';
    var flight  = row.dataset.flight  || '';
    var route   = row.dataset.route   || '';
    var bill    = row.dataset.bill    || '';
    var remark  = row.dataset.remark  || '';

    var html = '<table style="width:100%;border-collapse:collapse;font-size:13px;text-align:left;">';
    if (vou)    html += '<tr><td style="padding:4px 8px;color:#64748b;width:40%">Voucher</td><td style="padding:4px 8px;font-weight:600;">' + vou + '</td></tr>';
    if (date)   html += '<tr><td style="padding:4px 8px;color:#64748b;">Date</td><td style="padding:4px 8px;">' + date + '</td></tr>';
    if (part)   html += '<tr><td style="padding:4px 8px;color:#64748b;">Particulars</td><td style="padding:4px 8px;">' + part + '</td></tr>';
    if (route)  html += '<tr><td style="padding:4px 8px;color:#5c4d8a;font-weight:600;">Route</td><td style="padding:4px 8px;color:#5c4d8a;font-weight:600;">' + route + '</td></tr>';
    if (flight) html += '<tr><td style="padding:4px 8px;color:#64748b;">Flight Info</td><td style="padding:4px 8px;">' + flight + '</td></tr>';
    if (bill)   html += '<tr><td style="padding:4px 8px;color:#64748b;">Bill Amount</td><td style="padding:4px 8px;font-weight:700;color:#b45309;">&#8377; ' + bill + '</td></tr>';
    html += '<tr><td style="padding:8px 8px 4px;color:#64748b;vertical-align:top;">Remarks</td><td style="padding:8px 8px 4px;">';
    html += remark ? ('<span style="font-weight:600;color:#0f172a;">' + remark + '</span>') : '<span style="color:#94a3b8;font-style:italic;">No remarks</span>';
    html += '</td></tr></table>';

    Swal.fire({
        title: 'Transaction Detail',
        html: html,
        icon: null,
        confirmButtonText: 'Close',
        confirmButtonColor: '#1a2744',
        width: 420
    });
}
</script>
</body>
</html>
