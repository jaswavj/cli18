<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,java.text.SimpleDateFormat,java.text.DecimalFormat"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<jsp:useBean id="userB" class="user.userBean" />
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
String agentIdP = request.getParameter("agentFilter");
String ptFilter = request.getParameter("ptFilter");
if (fromDate == null || fromDate.isEmpty()) fromDate = today;
if (toDate   == null || toDate.isEmpty())   toDate   = today;
if (ptFilter == null || ptFilter.isEmpty()) ptFilter = "";
int agentFilterId = 0;
try { if (agentIdP != null && !agentIdP.isEmpty()) agentFilterId = Integer.parseInt(agentIdP); } catch (Exception e) {}

Vector agents   = billing.getTicketAgents();
Vector payModes = billing.getTicketPaymentModes();
// Individual ledger rows (ungrouped) to show each payment entry separately
String ptScope = ptFilter.isEmpty() ? "SELL" : ptFilter;
Vector rows = billing.getTicketPaymentsDetail(fromDate, toDate, agentFilterId, ptScope);

DecimalFormat df = new DecimalFormat("0.00");

// Pre-pass: build per-booking+party balance map and summary stats
java.util.Map<String, double[]> balMap = new java.util.LinkedHashMap<>();
java.util.Map<String, Integer>  lastRowIdx = new java.util.LinkedHashMap<>();
double totalBill = 0, totalPaid = 0, totalBal = 0;
java.util.Set<String> uniqueParties = new java.util.LinkedHashSet<>();
int sellAgentCount = 0, customerCount = 0;
for (int i = 0; i < rows.size(); i++) {
    Vector r = (Vector) rows.get(i);
    int bId = r.get(1) != null ? Integer.parseInt(r.get(1).toString()) : 0;
    String pt = r.get(4) != null ? r.get(4).toString() : "";
    String key = bId + "|" + pt;
    double bill = r.get(7) != null ? Double.parseDouble(r.get(7).toString()) : 0;
    double paid = r.get(8) != null ? Double.parseDouble(r.get(8).toString()) : 0;
    totalBill += bill; totalPaid += paid;
    double[] vals = (double[]) balMap.get(key);
    if (vals == null) { vals = new double[]{bId, 0, 0}; balMap.put(key, vals); }
    vals[1] += bill; vals[2] += paid;
    lastRowIdx.put(key, i);
    if (!uniqueParties.contains(key)) {
        uniqueParties.add(key);
        if ("SELL_AGENT".equals(pt)) sellAgentCount++;
        else if ("CUSTOMER".equals(pt)) customerCount++;
    }
}
totalBal = totalBill - totalPaid;

// Print shop name
Vector compVec = new Vector();
try { compVec = userB.getCompanyDetails(); } catch (Exception ec) {}
String printShopName = compVec.size() > 1 && compVec.get(1) != null ? String.valueOf(compVec.get(1)) : "Moulana Air Travels";
String printAddress  = compVec.size() > 2 && compVec.get(2) != null ? String.valueOf(compVec.get(2)) : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Collection Report</title>
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
.fg{display:flex;flex-direction:column;gap:3px;min-width:0;}
.fg-lbl{font-size:10px;font-weight:700;color:rgba(255,255,255,.7);text-transform:uppercase;letter-spacing:.5px;white-space:nowrap;}
.fg-inp,.fg-sel{height:33px;border:1.5px solid rgba(255,255,255,.25);border-radius:var(--r-sm);padding:0 9px;background:rgba(255,255,255,.12);color:#fff;font-size:13px;outline:none;}
.fg-inp::placeholder{color:rgba(255,255,255,.4);}
.fg-inp:focus,.fg-sel:focus{border-color:var(--gold);background:rgba(255,255,255,.18);}
.fg-sel option{background:#1a2744;color:#fff;}
.bb{display:inline-flex;align-items:center;gap:6px;height:33px;padding:0 15px;border-radius:var(--r-sm);font-size:12px;font-weight:700;cursor:pointer;border:1.5px solid transparent;transition:all .15s;white-space:nowrap;}
.bb-gold{background:var(--gold);color:#fff;border-color:var(--gold);}
.bb-gold:hover{background:var(--gold-d);}
.bb-outline-white{background:transparent;color:#fff;border-color:rgba(255,255,255,.5);}
.bb-outline-white:hover{background:rgba(255,255,255,.12);}

/* Print header */
.print-header{display:none;}

/* Summary chips */
.sum-row{display:flex;gap:10px;flex-wrap:wrap;margin-bottom:12px;}
.sum-chip{background:var(--card);border-radius:var(--r-sm);border:1px solid var(--border-l);padding:10px 16px;display:flex;flex-direction:column;gap:3px;min-width:120px;box-shadow:var(--shadow-sm);}
.sum-chip-lbl{font-size:10px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.5px;}
.sum-chip-val{font-size:18px;font-weight:800;}

/* Table */
.tbl-wrap{background:var(--card);border-radius:var(--r);border:1px solid var(--border-l);box-shadow:var(--shadow-sm);overflow:hidden;}
.rpt-table{width:100%;border-collapse:collapse;font-size:12.5px;}
.rpt-table thead tr{background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);}
.rpt-table thead th{padding:10px 10px;color:#fff;font-weight:700;text-transform:uppercase;font-size:10.5px;letter-spacing:.4px;white-space:nowrap;text-align:left;}
.rpt-table tbody tr{border-bottom:1px solid var(--border-l);transition:background .1s;}
.rpt-table tbody tr:hover{background:#f7f8fc;}
.rpt-table tbody tr.row-click{cursor:pointer;}
.rpt-table tbody td{padding:9px 10px;vertical-align:middle;}
.rpt-table tbody tr:last-child{border-bottom:none;}
.rpt-table tfoot tr{background:#f1f5f9;border-top:2px solid var(--border);}
.rpt-table tfoot td{padding:9px 10px;font-weight:800;font-size:12.5px;}

/* Badges */
.badge{display:inline-block;padding:2px 7px;border-radius:3px;font-size:10px;font-weight:700;letter-spacing:.3px;}
.badge-sell{background:#e8f5e9;color:#1b5e20;border:1px solid #c8e6c9;}
.badge-cust{background:#e3f2fd;color:#0d47a1;border:1px solid #bbdefb;}
.bal-cell{font-weight:700;}
.bal-cell.zero{color:var(--green);}
.bal-cell.due{color:var(--red);}
.btn-collect{display:inline-flex;align-items:center;gap:4px;padding:4px 10px;border-radius:var(--r-sm);font-size:11px;font-weight:700;cursor:pointer;background:#dc2626;color:#fff;border:none;transition:background .15s;}
.btn-collect:hover{background:#b91c1c;}
.empty-state{text-align:center;padding:50px 20px;color:var(--muted);}
.empty-state i{font-size:48px;color:#d1d9e6;margin-bottom:12px;display:block;}

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
.mfg textarea{border:1.5px solid var(--border);border-radius:var(--r-sm);padding:8px 10px;font-size:13px;outline:none;width:100%;min-height:76px;resize:vertical;font-family:inherit;}
.mfg textarea:focus{border-color:var(--violet);}
.modal-foot{padding:12px 16px;display:flex;gap:8px;justify-content:flex-end;border-top:1px solid var(--border-l);}
.info-row{background:#fafafa;border-radius:var(--r-sm);padding:8px 12px;font-size:12px;color:var(--text);}
.info-row span{font-weight:700;}
.detail-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px;}
.detail-box{background:#f8fafc;border:1px solid var(--border-l);border-radius:var(--r-sm);padding:8px 10px;}
.detail-label{font-size:10px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;}
.detail-val{font-size:12px;font-weight:600;color:var(--text);margin-top:2px;word-break:break-word;}
.note-box{background:#fffaf0;border:1px solid #f4e2bf;border-radius:var(--r-sm);padding:10px;font-size:12px;white-space:pre-wrap;min-height:46px;}

@media print {
    .tw-nav,.rpt-hdr{display:none!important;}
    .tw{height:auto!important;overflow:visible!important;}
    .tw-body{overflow:visible!important;height:auto!important;padding:0!important;}
    .print-header{display:flex!important;}
    .tbl-wrap{box-shadow:none!important;overflow:visible!important;}
    .rpt-table{font-size:10px!important;}
    .rpt-table thead th{padding:5px 6px!important;font-size:9px!important;}
    .rpt-table td{padding:5px 6px!important;}
    .badge{padding:1px 4px!important;font-size:9px!important;}
    .btn-collect,.bb-outline-white{display:none!important;}
    * { -webkit-print-color-adjust: exact !important; print-color-adjust: exact !important; }
}
</style>
</head>
<body>
<div class="tw">

  <!-- PRINT-ONLY HEADER -->
  <div class="print-header" style="align-items:center;gap:14px;padding:10px 16px;background:linear-gradient(135deg,#1a2744 0%,#243159 100%);border-bottom:3px solid #c9922a;margin-bottom:8px;">
    <div style="flex:1;">
      <div style="color:#c9922a;font-size:18px;font-weight:900;letter-spacing:1px;text-transform:uppercase;"><%=printShopName%></div>
      <%if (!printAddress.isEmpty()){%><div style="color:rgba(255,255,255,.75);font-size:12px;margin-top:2px;"><%=printAddress%></div><%}%>
    </div>
    <div style="text-align:right;color:rgba(255,255,255,.7);font-size:11px;">
      <div style="font-weight:700;color:#fff;">Collection Report</div>
      <div><%=fromDate%> &nbsp;to&nbsp; <%=toDate%></div>
    </div>
  </div>

  <div class="tw-nav"><%@ include file="/assets/navbar/navbar.jsp" %></div>

  <!-- HEADER -->
  <div class="rpt-hdr">
    <div class="rpt-title">
      <i class="fa-solid fa-money-bill-wave"></i>
      <span>COLLECTION REPORT</span>
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
        <div class="fg-lbl">Party Type</div>
        <select name="ptFilter" class="fg-sel" style="width:145px;">
          <option value=""   <%=("".equals(ptFilter)          ?"selected":"")%>>All (Agent + Customer)</option>
          <option value="SELL_AGENT" <%=("SELL_AGENT".equals(ptFilter)?"selected":"")%>>Sell to Agent</option>
          <option value="CUSTOMER"   <%=("CUSTOMER".equals(ptFilter)  ?"selected":"")%>>Sell to Customer</option>
        </select>
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
    <%if (rows.size() > 0) {%>
    <button class="bb bb-outline-white" onclick="window.print()">
      <i class="fa-solid fa-print"></i> Print
    </button>
    <%}%>
  </div>

  <!-- BODY -->
  <div class="tw-body">
    <!-- Summary -->
    <div class="sum-row">
      <div class="sum-chip">
        <div class="sum-chip-lbl">Total Billed</div>
        <div class="sum-chip-val" style="color:var(--navy);">&#8377;<%=df.format(totalBill)%></div>
      </div>
      <div class="sum-chip">
        <div class="sum-chip-lbl">Total Collected</div>
        <div class="sum-chip-val" style="color:var(--green);">&#8377;<%=df.format(totalPaid)%></div>
      </div>
      <div class="sum-chip">
        <div class="sum-chip-lbl">Balance Due</div>
        <div class="sum-chip-val" style="color:var(--red);">&#8377;<%=df.format(totalBal)%></div>
      </div>
      <div class="sum-chip">
        <div class="sum-chip-lbl">Sell Agent</div>
        <div class="sum-chip-val" style="color:#1b5e20;"><%=sellAgentCount%></div>
      </div>
      <div class="sum-chip">
        <div class="sum-chip-lbl">Customers</div>
        <div class="sum-chip-val" style="color:#0d47a1;"><%=customerCount%></div>
      </div>
    </div>

    <%if (rows.isEmpty()) {%>
    <div class="empty-state">
      <i class="fa-solid fa-money-bill-wave"></i>
      <h3 style="font-size:15px;font-weight:700;margin-bottom:6px;">No collection records found</h3>
      <p style="font-size:12px;">Select a date range and click Search</p>
    </div>
    <%} else {%>
    <div class="tbl-wrap">
      <table class="rpt-table">
        <thead>
          <tr>
            <th>#</th>
            <th>Date</th>
            <th>Ticket / PNR</th>
            <th>Route</th>
            <th>Party</th>
            <th>Mode</th>
            <th>Txn No</th>
            <th>Billed</th>
            <th>Paid</th>
          </tr>
        </thead>
        <tbody>
        <%
        int sno = 1;
        for (int i = 0; i < rows.size(); i++) {
            Vector r = (Vector) rows.get(i);
            // Row: [0]ledger_id [1]booking_id [2]ticket_no [3]pnr [4]party_type [5]party_display
            //      [6]txn_type  [7]bill_amount [8]amount_paid [9]payment_mode [10]transaction_no
            //      [11]txn_date [12]ow_from [13]ow_to [14]agent_id [15]party_name [16]booking_date
            int    bookingId  = r.get(1) != null ? Integer.parseInt(r.get(1).toString()) : 0;
            String tktNo      = r.get(2) != null ? r.get(2).toString() : "-";
            String pnr        = r.get(3) != null ? r.get(3).toString() : "-";
            String partyType  = r.get(4) != null ? r.get(4).toString() : "";
            String partyDisp  = r.get(5) != null ? r.get(5).toString() : "-";
            String txnType    = r.get(6) != null ? r.get(6).toString() : "DR";
            double bill       = r.get(7) != null ? Double.parseDouble(r.get(7).toString()) : 0;
            double paid       = r.get(8) != null ? Double.parseDouble(r.get(8).toString()) : 0;
            String payMode    = r.get(9)  != null ? r.get(9).toString()  : "";
            String txnNo      = r.get(10) != null ? r.get(10).toString() : "";
            String fdate      = r.get(11) != null ? r.get(11).toString() : "";
            String owFrom     = r.get(12) != null ? r.get(12).toString() : "";
            String owTo       = r.get(13) != null ? r.get(13).toString() : "";
            String agentIdRaw = r.get(14) != null ? r.get(14).toString() : "0";
            String pName      = r.get(15) != null ? r.get(15).toString() : "";
            String remarks    = r.size() > 17 && r.get(17) != null ? r.get(17).toString() : "";

            String key = bookingId + "|" + partyType;
            double[] vals = (double[]) balMap.get(key);
            double bal = vals != null ? vals[1] - vals[2] : 0;
            boolean isLastForKey = i == ((Integer) lastRowIdx.get(key)).intValue();

            String ptBadge = "SELL_AGENT".equals(partyType) ? "badge-sell" : "badge-cust";
            String ptLabel = "SELL_AGENT".equals(partyType) ? "Sell Agent" : "Customer";
            String balCls  = bal <= 0.005 ? "zero" : "due";
            String safeName = partyDisp.replace("'", "\\'");
            String partyDispAttr = partyDisp.replace("&", "&amp;").replace("\"", "&quot;");
            String routeText = (owFrom.isEmpty() && owTo.isEmpty()) ? "-" : (owFrom + " -> " + owTo);
            String routeAttr = routeText.replace("&", "&amp;").replace("\"", "&quot;");
            String payModeAttr = (payMode == null ? "" : payMode).replace("&", "&amp;").replace("\"", "&quot;");
            String txnNoAttr = (txnNo == null ? "" : txnNo).replace("&", "&amp;").replace("\"", "&quot;");
            String remarksAttr = (remarks == null ? "" : remarks).replace("&", "&amp;").replace("\"", "&quot;");
        %>
          <tr class="row-click"
              data-ledger-id="<%=r.get(0)%>"
              data-date="<%=fdate%>"
              data-ticket-no="<%=tktNo%>"
              data-pnr="<%=pnr%>"
              data-party-type="<%=ptLabel%>"
              data-party-name="<%=partyDispAttr%>"
              data-route="<%=routeAttr%>"
              data-mode="<%=payModeAttr%>"
              data-txn-no="<%=txnNoAttr%>"
              data-txn-type="<%=txnType%>"
              data-bill="<%=df.format(bill)%>"
              data-paid="<%=df.format(paid)%>"
              data-remarks="<%=remarksAttr%>"
              onclick="openRowDetailsFromRow(this)">
            <td style="color:var(--muted);"><%=sno++%></td>
            <td style="white-space:nowrap;color:var(--muted);font-size:11px;"><%=fdate%></td>
            <td>
              <div style="font-weight:700;color:var(--gold);"><%=tktNo%></div>
              <div style="font-size:11px;color:var(--muted);"><%=pnr%></div>
            </td>
            <td style="white-space:nowrap;font-weight:600;">
              <%=owFrom.isEmpty() && owTo.isEmpty() ? "<span style='color:var(--muted);'>-</span>" : owFrom + " \u2192 " + owTo%>
            </td>
            <td>
              <span class="badge <%=ptBadge%>"><%=ptLabel%></span>
              <div style="font-size:12px;margin-top:3px;font-weight:600;"><%=partyDisp%></div>
            </td>
            <td style="font-size:11px;color:var(--text);"><%=payMode.isEmpty() ? "-" : payMode%></td>
            <td style="font-size:11px;color:var(--violet);font-weight:600;"><%=txnNo.isEmpty() ? "<span style='color:var(--muted);'>\u2014</span>" : txnNo%></td>
            <td style="font-weight:600;"><%="DR".equals(txnType) ? "&#8377;" + df.format(bill) : "<span style='color:var(--green);'>&#8377;" + df.format(paid) + "</span>"%></td>
            <td style="color:var(--green);font-weight:600;">&#8377;<%=df.format(paid)%></td>
          </tr>
        <%}%>
        </tbody>
        <tfoot>
          <tr>
            <td colspan="6" style="color:var(--muted);">TOTALS</td>
            <td>&#8377;<%=df.format(totalBill)%></td>
            <td style="color:var(--green);">&#8377;<%=df.format(totalPaid)%></td>
            <td style="color:var(--red);">Bal: &#8377;<%=df.format(totalBal)%></td>
          </tr>
        </tfoot>
      </table>
    </div>
    <%}%>
    <div style="height:20px;"></div>
  </div>
</div>

<!-- CANCELLED BOOKINGS – PENDING SETTLEMENT (SELL SIDE) -->
<%
Vector cancelRowsSell = billing.getTicketCancelledPending("SELL", agentFilterId);
if (!cancelRowsSell.isEmpty()) {
%>
<div style="padding:0 16px 24px;">
  <div style="background:#fff;border-radius:8px;box-shadow:0 2px 12px rgba(0,0,0,.10);overflow:hidden;">
    <div style="background:#7c1d1d;color:#fff;padding:12px 18px;font-weight:700;font-size:14px;display:flex;align-items:center;gap:8px;">
      <i class="fa-solid fa-triangle-exclamation"></i> Cancelled Bookings – Pending Settlement (Sell Side)
    </div>
    <div style="overflow-x:auto;">
      <table style="width:100%;border-collapse:collapse;font-size:13px;">
        <thead>
          <tr style="background:#fef2f2;color:#7c1d1d;font-weight:700;text-transform:uppercase;font-size:11px;">
            <th style="padding:10px 12px;border-bottom:2px solid #fca5a5;text-align:left;">#</th>
            <th style="padding:10px 12px;border-bottom:2px solid #fca5a5;text-align:left;">Booking Date</th>
            <th style="padding:10px 12px;border-bottom:2px solid #fca5a5;text-align:left;">Ticket / PNR</th>
            <th style="padding:10px 12px;border-bottom:2px solid #fca5a5;text-align:left;">Route</th>
            <th style="padding:10px 12px;border-bottom:2px solid #fca5a5;text-align:left;">Party</th>
            <th style="padding:10px 12px;border-bottom:2px solid #fca5a5;text-align:right;">Pending Balance</th>
            <th style="padding:10px 12px;border-bottom:2px solid #fca5a5;text-align:center;">Action</th>
          </tr>
        </thead>
        <tbody>
          <%
          int csnos = 1;
          for (int ci = 0; ci < cancelRowsSell.size(); ci++) {
              Vector cr = (Vector) cancelRowsSell.get(ci);
              int    cBid     = cr.get(0) != null ? Integer.parseInt(cr.get(0).toString()) : 0;
              String cTktNo   = cr.get(1) != null ? cr.get(1).toString() : "-";
              String cPnr     = cr.get(2) != null ? cr.get(2).toString() : "-";
              String cOwFrom  = cr.get(3) != null ? cr.get(3).toString() : "";
              String cOwTo    = cr.get(4) != null ? cr.get(4).toString() : "";
              String cBdate   = cr.get(5) != null ? cr.get(5).toString() : "";
              String cPtype   = cr.get(6) != null ? cr.get(6).toString() : "CUSTOMER";
              String cPdisp   = cr.get(7) != null ? cr.get(7).toString() : "-";
              int    cAgId    = cr.get(8) != null ? Integer.parseInt(cr.get(8).toString()) : 0;
              String cPname   = cr.get(9) != null ? cr.get(9).toString() : "";
              double cPendBal = cr.get(10) != null ? Double.parseDouble(cr.get(10).toString()) : 0;
              // SELL: positive = we owe them refund; negative = they owe us
              boolean weOweRefund = cPendBal > 0;
              double  absbal      = Math.abs(cPendBal);
              String  cSafeName   = cPdisp.replace("'", "\\'");
              // txnType: CR when we give refund; DR when we collect from them
              String  cTxnType = weOweRefund ? "CR" : "DR";
              String  ptBadge  = "SELL_AGENT".equals(cPtype) ? "badge-sell" : "badge-cust";
              String  ptLabel  = "SELL_AGENT".equals(cPtype) ? "Sell Agent" : "Customer";
          %>
          <tr style="border-bottom:1px solid #fee2e2;">
            <td style="padding:9px 12px;color:#7c1d1d;"><%=csnos++%></td>
            <td style="padding:9px 12px;font-size:11px;color:#6b7280;"><%=cBdate%></td>
            <td style="padding:9px 12px;">
              <div style="font-weight:700;color:#c9922a;"><%=cTktNo%></div>
              <div style="font-size:11px;color:#6b7280;"><%=cPnr%></div>
            </td>
            <td style="padding:9px 12px;font-weight:600;white-space:nowrap;">
              <%=cOwFrom.isEmpty() && cOwTo.isEmpty() ? "<span style='color:#9ca3af;'>-</span>" : cOwFrom + " &rarr; " + cOwTo%>
            </td>
            <td style="padding:9px 12px;">
              <span class="badge <%=ptBadge%>"><%=ptLabel%></span>
              <div style="font-size:12px;margin-top:3px;font-weight:600;"><%=cPdisp%></div>
            </td>
            <td style="padding:9px 12px;text-align:right;font-weight:700;">
              <% if (weOweRefund) { %>
                <span style="color:#dc2626;">&#8377;<%=df.format(absbal)%></span>
                <div style="font-size:10px;color:#7c1d1d;">We owe refund</div>
              <% } else { %>
                <span style="color:#059669;">&#8377;<%=df.format(absbal)%></span>
                <div style="font-size:10px;color:#065f46;">They owe us</div>
              <% } %>
            </td>
            <td style="padding:9px 12px;text-align:center;">
              <% if (weOweRefund) { %>
                <button onclick="openCollect('<%=cBid%>','<%=cPtype%>','<%=cAgId%>','<%=cSafeName%>','<%=cTxnType%>',<%=absbal%>)"
                  style="background:#7c1d1d;color:#fff;border:none;border-radius:5px;padding:5px 12px;cursor:pointer;font-size:12px;font-weight:600;">
                  <i class="fa-solid fa-rotate-left"></i> Give Refund
                </button>
              <% } else { %>
                <button onclick="openCollect('<%=cBid%>','<%=cPtype%>','<%=cAgId%>','<%=cSafeName%>','<%=cTxnType%>',<%=absbal%>)"
                  style="background:#065f46;color:#fff;border:none;border-radius:5px;padding:5px 12px;cursor:pointer;font-size:12px;font-weight:600;">
                  <i class="fa-solid fa-hand-holding-dollar"></i> Collect Balance
                </button>
              <% } %>
            </td>
          </tr>
          <%}%>
        </tbody>
      </table>
    </div>
  </div>
</div>
<%}%>
<div class="modal-overlay" id="collectModal">
  <div class="modal-box">
    <div class="modal-head">
      <div class="modal-head-title"><i class="fa-solid fa-coins"></i> Collect Balance</div>
      <button class="modal-close" onclick="closeCollect()">&times;</button>
    </div>
    <div class="modal-body">
      <div class="info-row" id="collectInfo"></div>
      <div class="mfg">
        <label>Collection Date</label>
        <input type="date" id="collectDate" value="<%=today%>">
      </div>
      <div class="mfg">
        <label>Amount to Collect</label>
        <input type="number" step="0.01" id="collectAmount" placeholder="0.00">
      </div>
      <div class="mfg">
        <label>Payment Mode</label>
        <select id="collectMode" onchange="handleCollectModeChange()">
          <option value="">— Select Mode —</option>
          <%for (int i = 0; i < payModes.size(); i++) { Vector pm = (Vector) payModes.get(i);%>
          <option value="<%=pm.get(0)%>" data-cash="<%=pm.get(1).toString().toLowerCase().contains("cash") ? "1" : "0"%>"><%=pm.get(1)%></option>
          <%}%>
        </select>
      </div>
      <div class="mfg" id="collectTxnRow" style="display:none;">
        <label>Transaction No <span style="color:#dc2626;">*</span></label>
        <input type="text" id="collectTxnNo" placeholder="Txn / Ref No for online payment">
      </div>
      <div class="mfg">
        <label>Notes <span style="color:#dc2626;">*</span></label>
        <textarea id="collectNotes" placeholder="Enter collection notes"></textarea>
      </div>
    </div>
    <div class="modal-foot">
      <button class="bb" style="background:#f1f5f9;color:var(--text);border-color:var(--border);" onclick="closeCollect()">Cancel</button>
      <button class="bb bb-gold" onclick="saveCollect()"><i class="fa-solid fa-floppy-disk"></i> Save</button>
    </div>
  </div>
</div>

<div class="modal-overlay" id="detailModal">
  <div class="modal-box" style="width:620px;max-width:96vw;">
    <div class="modal-head">
      <div class="modal-head-title"><i class="fa-solid fa-receipt"></i> Collection Entry Details</div>
      <button class="modal-close" onclick="closeDetailModal()">&times;</button>
    </div>
    <div class="modal-body">
      <div class="detail-grid">
        <div class="detail-box"><div class="detail-label">Date</div><div class="detail-val" id="dDate">-</div></div>
        <div class="detail-box"><div class="detail-label">Ledger ID</div><div class="detail-val" id="dLedgerId">-</div></div>
        <div class="detail-box"><div class="detail-label">Ticket / PNR</div><div class="detail-val" id="dTicket">-</div></div>
        <div class="detail-box"><div class="detail-label">Route</div><div class="detail-val" id="dRoute">-</div></div>
        <div class="detail-box"><div class="detail-label">Party</div><div class="detail-val" id="dParty">-</div></div>
        <div class="detail-box"><div class="detail-label">Party Type</div><div class="detail-val" id="dPartyType">-</div></div>
        <div class="detail-box"><div class="detail-label">Transaction Type</div><div class="detail-val" id="dTxnType">-</div></div>
        <div class="detail-box"><div class="detail-label">Payment Mode</div><div class="detail-val" id="dMode">-</div></div>
        <div class="detail-box"><div class="detail-label">Transaction No</div><div class="detail-val" id="dTxnNo">-</div></div>
        <div class="detail-box"><div class="detail-label">Bill Amount</div><div class="detail-val" id="dBill">-</div></div>
        <div class="detail-box"><div class="detail-label">Paid Amount</div><div class="detail-val" id="dPaid">-</div></div>
      </div>
      <div class="mfg" style="margin-top:4px;">
        <label>Notes</label>
        <div class="note-box" id="dRemarks">-</div>
      </div>
    </div>
    <div class="modal-foot">
      <button class="bb" style="background:#f1f5f9;color:var(--text);border-color:var(--border);" onclick="closeDetailModal()">Close</button>
    </div>
  </div>
</div>

<script>
const ctx = '<%=ctx%>';
let _cBookingId='', _cPartyType='', _cAgentId='', _cPartyName='', _cTxnType='', _cMaxBal=0;

function openRowDetailsFromRow(tr) {
    if (!tr) return;
    const g = (k) => tr.getAttribute(k) || '';
    document.getElementById('dDate').textContent = g('data-date') || '-';
    document.getElementById('dLedgerId').textContent = g('data-ledger-id') || '-';
    document.getElementById('dTicket').textContent = (g('data-ticket-no') || '-') + ' / ' + (g('data-pnr') || '-');
    document.getElementById('dRoute').textContent = g('data-route') || '-';
    document.getElementById('dParty').textContent = g('data-party-name') || '-';
    document.getElementById('dPartyType').textContent = g('data-party-type') || '-';
    document.getElementById('dTxnType').textContent = g('data-txn-type') || '-';
    document.getElementById('dMode').textContent = g('data-mode') || '-';
    document.getElementById('dTxnNo').textContent = g('data-txn-no') || '-';
    document.getElementById('dBill').innerHTML = '&#8377;' + (g('data-bill') || '0.00');
    document.getElementById('dPaid').innerHTML = '&#8377;' + (g('data-paid') || '0.00');
    const notes = g('data-remarks').trim();
    document.getElementById('dRemarks').textContent = notes ? notes : 'No notes';
    document.getElementById('detailModal').classList.add('active');
}

function closeDetailModal() {
    document.getElementById('detailModal').classList.remove('active');
}

function openCollect(bookingId, partyType, agentId, partyName, txnType, maxBal) {
    _cBookingId = bookingId; _cPartyType = partyType; _cAgentId = agentId;
    _cPartyName = partyName; _cTxnType = txnType; _cMaxBal = maxBal;
    document.getElementById('collectInfo').innerHTML =
        'Party: <span>' + partyName + '</span> &nbsp;|&nbsp; Balance Due: <span style="color:#dc2626;">&#8377;' + maxBal.toFixed(2) + '</span>';
    document.getElementById('collectAmount').value = maxBal.toFixed(2);
    document.getElementById('collectMode').value = '';
    document.getElementById('collectTxnRow').style.display = 'none';
    document.getElementById('collectTxnNo').value = '';
    document.getElementById('collectNotes').value = '';
    document.getElementById('collectModal').classList.add('active');
}
function closeCollect() {
    document.getElementById('collectModal').classList.remove('active');
}
function handleCollectModeChange() {
    const sel = document.getElementById('collectMode');
    const opt = sel.options[sel.selectedIndex];
    const isOnline = sel.value && opt.getAttribute('data-cash') === '0';
    document.getElementById('collectTxnRow').style.display = isOnline ? '' : 'none';
    if (!isOnline) document.getElementById('collectTxnNo').value = '';
}
function saveCollect() {
    const amt  = parseFloat(document.getElementById('collectAmount').value);
    const mode = document.getElementById('collectMode').value;
    const date = document.getElementById('collectDate').value;
    const txnNo = document.getElementById('collectTxnNo').value.trim();
  const notes = document.getElementById('collectNotes').value.trim();
    if (!amt || amt <= 0) { alert('Enter a valid amount'); return; }
    if (!mode) { alert('Select a payment mode'); return; }
    if (!date) { alert('Select a collection date'); return; }
  if (!notes) { alert('Enter notes'); return; }
    const opt = document.getElementById('collectMode').options[document.getElementById('collectMode').selectedIndex];
    if (opt.getAttribute('data-cash') === '0' && !txnNo) { alert('Enter Transaction No for online payment'); return; }
    const params = new URLSearchParams();
    params.set('bookingId', _cBookingId); params.set('partyType', _cPartyType);
    params.set('agentId', _cAgentId); params.set('partyName', _cPartyName);
    params.set('txnType', _cTxnType); params.set('amount', amt);
    params.set('payModeId', mode); params.set('collectionDate', date);
    params.set('txnNo', txnNo);
    params.set('notes', notes);
    fetch(ctx + '/ticketbooking/collectBalance.jsp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params.toString()
    })
    .then(r => r.text())
    .then(d => {
        if (d.trim() === 'SUCCESS') { closeCollect(); location.reload(); }
        else alert('Error: ' + d);
    })
    .catch(err => alert('Error: ' + err.message));
}
document.getElementById('collectModal').addEventListener('click', function(e) {
    if (e.target === this) closeCollect();
});
document.getElementById('detailModal').addEventListener('click', function(e) {
  if (e.target === this) closeDetailModal();
});
</script>
</body>
</html>
