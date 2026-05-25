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

String searchPNR = request.getParameter("pnr");
Vector bookingResult = new Vector();
Vector passengers    = new Vector();
boolean searched = false;
String errorMsg  = null;

if (searchPNR != null && !searchPNR.trim().isEmpty()) {
    searched = true;
    bookingResult = billing.getPNRDetails(searchPNR.trim());
    if (!bookingResult.isEmpty()) {
        Vector row = (Vector) bookingResult.get(0);
        int bId = 0;
        try { bId = Integer.parseInt(String.valueOf(row.get(0))); } catch (Exception e2) {}
        if (bId > 0) passengers = billing.getPNRPassengers(bId);
    } else {
        errorMsg = "No booking found for PNR: " + searchPNR.trim();
    }
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>PNR Enquiry</title>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<%@ include file="/assets/common/head.jsp" %>
<style>
:root {
    --navy:#1a2744;--navy2:#243159;--violet:#5c4d8a;--violet-d:#4a3d78;
    --gold:#c9922a;--bg:#eef1f7;--card:#fff;--border:#d1d9e6;--border-l:#e8edf5;
    --text:#0f172a;--muted:#64748b;--inp-bg:#f8fafc;--green:#059669;--red:#dc2626;
    --r:8px;--r-sm:5px;--shadow:0 2px 12px rgba(0,0,0,.10);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
html,body{height:100%;font-family:'Segoe UI',system-ui,sans-serif;font-size:13px;background:var(--bg);color:var(--text);}
.tw{display:flex;flex-direction:column;height:100vh;height:100dvh;overflow:hidden;}
.tw-nav{flex-shrink:0;}
.tw-body{flex:1;min-height:0;overflow-y:auto;padding:14px;}
.tw-body::-webkit-scrollbar{width:5px;}
.tw-body::-webkit-scrollbar-thumb{background:var(--violet);border-radius:3px;}

/* Header */
.tb-header{
    background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);
    padding:10px 16px;display:flex;align-items:center;gap:10px;flex-wrap:wrap;
    box-shadow:0 2px 8px rgba(0,0,0,.25);flex-shrink:0;
}
.tb-header-title{display:flex;align-items:center;gap:9px;color:#fff;font-size:15px;font-weight:800;letter-spacing:.4px;}
.tb-header-title i{color:var(--gold);font-size:17px;}
.tb-divider{width:1px;height:28px;background:rgba(255,255,255,.2);}
.hdr-spacer{flex:1;}
.fg{display:flex;flex-direction:column;gap:3px;min-width:0;}
.fg-lbl{font-size:10px;font-weight:700;color:rgba(255,255,255,.7);text-transform:uppercase;letter-spacing:.5px;}
.fg-inp{height:33px;border:1.5px solid rgba(255,255,255,.25);border-radius:var(--r-sm);padding:0 9px;background:rgba(255,255,255,.12);color:#fff;font-size:13px;outline:none;transition:border-color .15s;}
.fg-inp::placeholder{color:rgba(255,255,255,.4);}
.fg-inp:focus{border-color:var(--gold);background:rgba(255,255,255,.18);}
.bb{display:inline-flex;align-items:center;gap:6px;height:33px;padding:0 15px;border-radius:var(--r-sm);font-size:12px;font-weight:700;cursor:pointer;border:1.5px solid transparent;transition:all .15s;white-space:nowrap;}
.bb-gold{background:var(--gold);color:#fff;border-color:var(--gold);}
.bb-gold:hover{background:#a87520;}

/* Result card */
.result-card{background:var(--card);border-radius:var(--r);border:1px solid var(--border-l);box-shadow:var(--shadow);margin-bottom:14px;overflow:hidden;}
.result-head{background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);padding:10px 16px;display:flex;align-items:center;gap:10px;}
.result-head i{color:var(--gold);}
.result-head-title{color:#fff;font-size:13px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;}
.pnr-chip{margin-left:auto;background:var(--gold);color:#fff;border-radius:4px;padding:3px 12px;font-size:13px;font-weight:900;letter-spacing:1px;}
.result-body{padding:16px;}

/* Detail grid */
.detail-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:10px;}
.detail-item{display:flex;flex-direction:column;gap:3px;}
.detail-lbl{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--muted);}
.detail-val{font-size:13px;font-weight:600;color:var(--text);background:var(--inp-bg);border:1px solid var(--border-l);border-radius:var(--r-sm);padding:5px 9px;min-height:30px;}
.detail-val.empty{color:var(--muted);font-style:italic;font-weight:400;}

/* Section divider */
.sec-div{display:flex;align-items:center;gap:8px;margin:14px 0 10px;}
.sec-div-line{flex:1;height:1px;background:var(--border-l);}
.sec-div-title{font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.6px;color:var(--muted);white-space:nowrap;}
.sec-div i{color:var(--violet);font-size:12px;}

/* Journey card */
.journey-block{border:1.5px solid var(--border-l);border-radius:var(--r-sm);overflow:hidden;margin-bottom:10px;}
.journey-head{display:flex;align-items:center;gap:8px;padding:7px 12px;font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;}
.journey-head.ow-head{background:#e8f0ff;color:var(--violet);}
.journey-head.ret-head{background:#e8f5e9;color:#2e7d32;}
.journey-head i{font-size:13px;}
.journey-body{padding:10px 12px;background:#fafafa;}

/* Passengers */
.pax-chips{display:flex;flex-wrap:wrap;gap:6px;margin-top:8px;}
.pax-chip{display:flex;align-items:center;gap:6px;background:#f0edf8;border:1.5px solid #d8d0f0;border-radius:20px;padding:4px 12px;font-size:12px;font-weight:600;color:var(--violet);}
.pax-chip .pax-no{background:var(--violet);color:#fff;border-radius:50%;width:18px;height:18px;display:inline-flex;align-items:center;justify-content:center;font-size:9px;font-weight:800;flex-shrink:0;}

/* Transaction strips */
.txn-strips{display:grid;grid-template-columns:repeat(auto-fill,minmax(220px,1fr));gap:10px;margin-top:10px;}
.txn-strip{border:1.5px solid var(--border-l);border-radius:var(--r-sm);overflow:hidden;}
.txn-strip-head{display:flex;align-items:center;gap:6px;padding:7px 10px;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;}
.txn-strip-head.buy-h{background:#fff3e0;color:#bf6000;}
.txn-strip-head.sell-h{background:#e8f5e9;color:#1b5e20;}
.txn-strip-head.cust-h{background:#e3f2fd;color:#0d47a1;}
.txn-strip-head i{font-size:12px;}
.txn-strip-body{padding:9px 10px;background:#fafafa;display:flex;flex-direction:column;gap:4px;}
.txn-row2{display:flex;justify-content:space-between;align-items:center;gap:6px;}
.txn-key{font-size:10px;color:var(--muted);font-weight:600;}
.txn-value{font-size:12px;font-weight:700;color:var(--text);}
.txn-value.amount{color:var(--green);font-size:14px;}

/* Empty / Error */
.empty-state{text-align:center;padding:40px 20px;color:var(--muted);}
.empty-state i{font-size:48px;color:#d1d9e6;margin-bottom:12px;display:block;}
.empty-state h3{font-size:15px;font-weight:700;margin-bottom:6px;}
.error-state{background:#fef2f2;border:1.5px solid #fecaca;border-radius:var(--r-sm);padding:12px 16px;color:var(--red);display:flex;align-items:center;gap:8px;margin-bottom:14px;font-weight:600;}

@media(max-width:600px){.detail-grid{grid-template-columns:1fr 1fr;}.txn-strips{grid-template-columns:1fr;}.ph-two-col{grid-template-columns:1fr !important;}}

/* Payment history table (agentStatement style) */
.ph-table{width:100%;border-collapse:collapse;}
.ph-table thead th{background:var(--navy2);color:#fff;padding:8px 10px;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;white-space:nowrap;}
.ph-table th.num,.ph-table td.num{text-align:right;}
.ph-table td{padding:6px 10px;font-size:12px;border-bottom:1px solid var(--border-l);vertical-align:middle;}
.ph-table tr:hover td{background:#f5f7ff;}
.ph-table tr.row-total td{background:var(--navy);color:#fff;font-weight:700;font-size:12px;}
.ph-table tr.row-total:hover td{background:var(--navy);}
.bal-dr{color:var(--red);font-weight:600;}
.bal-cr{color:var(--green);font-weight:600;}
.bal-nil{color:var(--muted);}
.dr-amt{color:#b45309;font-weight:600;}
.cr-amt{color:var(--green);font-weight:600;}
.badge-ph{font-size:9px;padding:1px 5px;border-radius:3px;font-weight:700;}
.badge-ph-buy{background:#fff3e0;color:#e65100;}
.badge-ph-sell{background:#e8f5e9;color:#2e7d32;}
.badge-ph-cust{background:#e3f2fd;color:#1565c0;}
</style>
</head>
<body>
<div class="tw">
  <div class="tw-nav"><%@ include file="/assets/navbar/navbar.jsp" %></div>

  <!-- HEADER -->
  <div class="tb-header">
    <div class="tb-header-title">
      <i class="fa-solid fa-magnifying-glass"></i>
      <span>PNR ENQUIRY</span>
    </div>
    <div class="tb-divider"></div>
    <form method="get" action="" style="display:flex;align-items:flex-end;gap:8px;flex-wrap:wrap;">
      <div class="fg">
        <div class="fg-lbl">PNR Number</div>
        <input name="pnr" type="text" class="fg-inp" placeholder="Enter PNR to search"
               value="<%=searchPNR != null ? searchPNR.trim() : ""%>" style="width:200px;" autocomplete="off">
      </div>
      <button type="submit" class="bb bb-gold">
        <i class="fa-solid fa-magnifying-glass"></i> Search
      </button>
    </form>
    <div class="hdr-spacer"></div>
  </div>

  <!-- BODY -->
  <div class="tw-body">

    <%if (!searched) {%>
    <div class="empty-state">
      <i class="fa-solid fa-ticket"></i>
      <h3>Enter a PNR number to search</h3>
      <p style="font-size:12px;">Search any ticket booking by its PNR reference number</p>
    </div>
    <%} else if (errorMsg != null) {%>
    <div class="error-state">
      <i class="fa-solid fa-circle-xmark" style="font-size:16px;"></i>
      <%=errorMsg%>
    </div>
    <%} else {
        Vector row = (Vector) bookingResult.get(0);
        // Helper
        String v0  = row.get(0)  != null ? String.valueOf(row.get(0))  : "";
        String pnrVal     = row.get(1)  != null ? String.valueOf(row.get(1))  : "-";
        String bookDate   = row.get(2)  != null ? String.valueOf(row.get(2))  : "-";
        String owDate     = row.get(3)  != null ? String.valueOf(row.get(3))  : "-";
        String owTime     = row.get(4)  != null ? String.valueOf(row.get(4))  : "-";
        String owFrom     = row.get(5)  != null ? String.valueOf(row.get(5))  : "-";
        String owTo       = row.get(6)  != null ? String.valueOf(row.get(6))  : "-";
        String owFlight   = row.get(7)  != null ? String.valueOf(row.get(7))  : "-";
        String owAirlines = row.get(8)  != null ? String.valueOf(row.get(8))  : "-";
        String retDate    = row.get(9)  != null ? String.valueOf(row.get(9))  : "";
        String retTime    = row.get(10) != null ? String.valueOf(row.get(10)) : "";
        String retFrom    = row.get(11) != null ? String.valueOf(row.get(11)) : "";
        String retTo      = row.get(12) != null ? String.valueOf(row.get(12)) : "";
        String retFlight  = row.get(13) != null ? String.valueOf(row.get(13)) : "";
        String retAirlines= row.get(14) != null ? String.valueOf(row.get(14)) : "";
        String seats      = row.get(15) != null ? String.valueOf(row.get(15)) : "-";
        String phone      = row.get(16) != null ? String.valueOf(row.get(16)) : "-";
        String buyAgent   = row.get(17) != null ? String.valueOf(row.get(17)) : "";
        String buyAmt     = row.get(18) != null ? String.valueOf(row.get(18)) : "";
        String buyMode    = row.get(19) != null ? String.valueOf(row.get(19)) : "";
        String sellAgent  = row.get(20) != null ? String.valueOf(row.get(20)) : "";
        String sellAmt    = row.get(21) != null ? String.valueOf(row.get(21)) : "";
        String sellMode   = row.get(22) != null ? String.valueOf(row.get(22)) : "";
        String custName   = row.get(23) != null ? String.valueOf(row.get(23)) : "";
        String custAmt    = row.get(24) != null ? String.valueOf(row.get(24)) : "";
        String custMode   = row.get(25) != null ? String.valueOf(row.get(25)) : "";
        String createdAt  = row.get(26) != null ? String.valueOf(row.get(26)) : "-";
        boolean isCancelled = row.size() > 27 && "1".equals(String.valueOf(row.get(27)));
        boolean hasRet    = retDate != null && !retDate.trim().isEmpty();
        // Load payment history
        int bookingIdInt = 0;
        try { bookingIdInt = Integer.parseInt(v0); } catch (Exception ex2) {}
        java.util.Vector ledgerHistory = new java.util.Vector();
        try { if (bookingIdInt > 0) ledgerHistory = billing.getTicketLedgerByBookingId(bookingIdInt); } catch (Exception elh) {}
    %>

    <!-- ── BOOKING OVERVIEW ── -->
    <div class="result-card">
      <div class="result-head">
        <i class="fa-solid fa-ticket fa-lg"></i>
        <span class="result-head-title">Booking Details</span>
        <div class="pnr-chip"><%=pnrVal%></div>
        <% if (isCancelled) { %><span style="background:#dc2626;color:#fff;padding:3px 10px;border-radius:20px;font-size:11px;font-weight:700;letter-spacing:.5px;margin-left:8px;"><i class="fa-solid fa-ban" style="margin-right:4px;"></i>CANCELLED</span><% } %>
      </div>
      <div class="result-body">
        <div class="detail-grid">
          <div class="detail-item">
            <div class="detail-lbl"><i class="fa-solid fa-hashtag" style="margin-right:3px;"></i>Booking ID</div>
            <div class="detail-val">#<%=v0%></div>
          </div>
          <div class="detail-item">
            <div class="detail-lbl"><i class="fa-solid fa-calendar-check" style="margin-right:3px;"></i>Booking Date</div>
            <div class="detail-val"><%=bookDate%></div>
          </div>
          <div class="detail-item">
            <div class="detail-lbl"><i class="fa-solid fa-users" style="margin-right:3px;"></i>No. of Seats</div>
            <div class="detail-val"><%=seats%></div>
          </div>
          <div class="detail-item">
            <div class="detail-lbl"><i class="fa-solid fa-phone" style="margin-right:3px;"></i>Phone</div>
            <div class="detail-val <%=phone.equals("-") ? "empty" : ""%>"><%=phone%></div>
          </div>
          <div class="detail-item">
            <div class="detail-lbl"><i class="fa-solid fa-clock" style="margin-right:3px;"></i>Created At</div>
            <div class="detail-val"><%=createdAt%></div>
          </div>
        </div>

        <!-- JOURNEY -->
        <div class="sec-div">
          <div class="sec-div-line"></div>
          <i class="fa-solid fa-route"></i>
          <div class="sec-div-title">Journey</div>
          <div class="sec-div-line"></div>
        </div>

        <!-- One Way -->
        <div class="journey-block">
          <div class="journey-head ow-head">
            <i class="fa-solid fa-plane-departure"></i> One Way
          </div>
          <div class="journey-body">
            <div class="detail-grid">
              <div class="detail-item"><div class="detail-lbl">Date</div><div class="detail-val"><%=owDate%></div></div>
              <div class="detail-item"><div class="detail-lbl">Time</div><div class="detail-val"><%=owTime%></div></div>
              <div class="detail-item"><div class="detail-lbl">From</div><div class="detail-val"><%=owFrom%></div></div>
              <div class="detail-item"><div class="detail-lbl">To</div><div class="detail-val"><%=owTo%></div></div>
              <div class="detail-item"><div class="detail-lbl">Flight No</div><div class="detail-val <%=owFlight.equals("-")?"empty":""%>"><%=owFlight%></div></div>
              <div class="detail-item"><div class="detail-lbl">Airlines</div><div class="detail-val <%=owAirlines.equals("-")?"empty":""%>"><%=owAirlines%></div></div>
            </div>
          </div>
        </div>

        <%if (hasRet) {%>
        <!-- Return -->
        <div class="journey-block">
          <div class="journey-head ret-head">
            <i class="fa-solid fa-plane-arrival"></i> Return Journey
          </div>
          <div class="journey-body">
            <div class="detail-grid">
              <div class="detail-item"><div class="detail-lbl">Date</div><div class="detail-val"><%=retDate%></div></div>
              <div class="detail-item"><div class="detail-lbl">Time</div><div class="detail-val"><%=retTime%></div></div>
              <div class="detail-item"><div class="detail-lbl">From</div><div class="detail-val"><%=retFrom%></div></div>
              <div class="detail-item"><div class="detail-lbl">To</div><div class="detail-val"><%=retTo%></div></div>
              <div class="detail-item"><div class="detail-lbl">Flight No</div><div class="detail-val <%=retFlight.isEmpty()?"empty":""%>"><%=retFlight.isEmpty()?"-":retFlight%></div></div>
              <div class="detail-item"><div class="detail-lbl">Airlines</div><div class="detail-val <%=retAirlines.isEmpty()?"empty":""%>"><%=retAirlines.isEmpty()?"-":retAirlines%></div></div>
            </div>
          </div>
        </div>
        <%}%>

        <!-- PASSENGERS -->
        <div class="sec-div">
          <div class="sec-div-line"></div>
          <i class="fa-solid fa-users"></i>
          <div class="sec-div-title">Passengers</div>
          <div class="sec-div-line"></div>
        </div>
        <div class="pax-chips">
          <%if (passengers.isEmpty()) {%>
          <span style="color:var(--muted);font-size:12px;font-style:italic;">No passenger data</span>
          <%} else { for (int pi = 0; pi < passengers.size(); pi++) {
              Vector prow = (Vector) passengers.get(pi);
              String pNo   = prow.get(0) != null ? String.valueOf(prow.get(0)) : String.valueOf(pi+1);
              String pName = prow.get(1) != null ? String.valueOf(prow.get(1)) : "-";
          %>
          <div class="pax-chip">
            <span class="pax-no"><%=pNo%></span>
            <%=pName%>
          </div>
          <%}}%>
        </div>

        <!-- TRANSACTION -->
        <div class="sec-div">
          <div class="sec-div-line"></div>
          <i class="fa-solid fa-money-bill-transfer"></i>
          <div class="sec-div-title">Transaction</div>
          <div class="sec-div-line"></div>
        </div>
        <div class="txn-strips">
          <%if (!buyAgent.isEmpty()) {%>
          <div class="txn-strip">
            <div class="txn-strip-head buy-h"><i class="fa-solid fa-arrow-down-to-bracket"></i> Buy from Agent</div>
            <div class="txn-strip-body">
              <div class="txn-row2"><span class="txn-key">Agent</span><span class="txn-value"><%=buyAgent%></span></div>
              <div class="txn-row2"><span class="txn-key">Bill Amount</span><span class="txn-value amount">₹ <%=buyAmt.isEmpty()?"-":buyAmt%></span></div>
              <div class="txn-row2"><span class="txn-key">Mode</span><span class="txn-value"><%=buyMode.isEmpty()?"-":buyMode%></span></div>
            </div>
          </div>
          <%}%>
          <%if (!sellAgent.isEmpty()) {%>
          <div class="txn-strip">
            <div class="txn-strip-head sell-h"><i class="fa-solid fa-arrow-up-from-bracket"></i> Sell to Agent</div>
            <div class="txn-strip-body">
              <div class="txn-row2"><span class="txn-key">Agent</span><span class="txn-value"><%=sellAgent%></span></div>
              <div class="txn-row2"><span class="txn-key">Bill Amount</span><span class="txn-value amount">₹ <%=sellAmt.isEmpty()?"-":sellAmt%></span></div>
              <div class="txn-row2"><span class="txn-key">Mode</span><span class="txn-value"><%=sellMode.isEmpty()?"-":sellMode%></span></div>
            </div>
          </div>
          <%}%>
          <%if (!custName.isEmpty() || !custAmt.isEmpty()) {%>
          <div class="txn-strip">
            <div class="txn-strip-head cust-h"><i class="fa-solid fa-user"></i> Customer</div>
            <div class="txn-strip-body">
              <div class="txn-row2"><span class="txn-key">Name</span><span class="txn-value"><%=custName.isEmpty()?"-":custName%></span></div>
              <div class="txn-row2"><span class="txn-key">Bill Amount</span><span class="txn-value amount">₹ <%=custAmt.isEmpty()?"-":custAmt%></span></div>
              <div class="txn-row2"><span class="txn-key">Mode</span><span class="txn-value"><%=custMode.isEmpty()?"-":custMode%></span></div>
            </div>
          </div>
          <%}%>
          <%if (buyAgent.isEmpty() && sellAgent.isEmpty() && custName.isEmpty() && custAmt.isEmpty()) {%>
          <p style="color:var(--muted);font-size:12px;font-style:italic;">No transaction data recorded</p>
          <%}%>
        </div>

        <!-- PAYMENT HISTORY -->
        <div class="sec-div">
          <div class="sec-div-line"></div>
          <i class="fa-solid fa-clock-rotate-left"></i>
          <div class="sec-div-title">Payment History</div>
          <div class="sec-div-line"></div>
        </div>
        <%
        DecimalFormat dfLh = new DecimalFormat("0.00");
        java.util.Vector buyLedger  = new java.util.Vector();
        java.util.Vector sellLedger = new java.util.Vector();
        for (int li = 0; li < ledgerHistory.size(); li++) {
            Vector lhRow = (Vector) ledgerHistory.get(li);
            String lhParty = lhRow.get(1) != null ? lhRow.get(1).toString() : "";
            if ("BUY_AGENT".equals(lhParty)) buyLedger.add(lhRow);
            else sellLedger.add(lhRow);
        }
        if (ledgerHistory.isEmpty()) {
        %>
        <p style="color:var(--muted);font-size:12px;font-style:italic;">No payment entries found</p>
        <%} else {%>
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:14px;" class="ph-two-col">

          <!-- BUY side -->
          <div>
            <div style="display:flex;align-items:center;gap:6px;padding:7px 10px;background:#fff3e0;border-radius:6px 6px 0 0;border:1px solid #ffe0b2;border-bottom:none;">
              <i class="fa-solid fa-arrow-down-to-bracket" style="color:#bf6000;font-size:12px;"></i>
              <span style="font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.4px;color:#bf6000;">Buy from Agent</span>
            </div>
            <%if (buyLedger.isEmpty()) {%>
            <div style="padding:14px 10px;font-size:12px;color:var(--muted);font-style:italic;background:#fafafa;border:1px solid #ffe0b2;border-radius:0 0 6px 6px;">No entries</div>
            <%} else {
                double bRunBal = 0, bTotalDr = 0, bTotalCr = 0;
            %>
            <div style="overflow-x:auto;border:1px solid #ffe0b2;border-radius:0 0 6px 6px;">
            <table class="ph-table">
              <thead>
                <tr>
                  <th style="background:#fff8f0;color:#bf6000;width:90px;">Date</th>
                  <th style="background:#fff8f0;color:#bf6000;">Mode</th>
                  <th class="num" style="background:#fff8f0;color:#dc2626;width:90px;">Dr.Amt</th>
                  <th class="num" style="background:#fff8f0;color:#059669;width:90px;">Cr.Amt</th>
                  <th class="num" style="background:#fff8f0;color:#bf6000;width:100px;">Balance</th>
                </tr>
              </thead>
              <tbody>
              <%for (int bi = 0; bi < buyLedger.size(); bi++) {
                  Vector bRow = (Vector) buyLedger.get(bi);
                  String bTxnType  = bRow.get(3) != null ? bRow.get(3).toString() : "DR";
                  double bBillAmt  = bRow.get(4) != null ? Double.parseDouble(bRow.get(4).toString()) : 0;
                  double bPaidAmt  = bRow.get(5) != null ? Double.parseDouble(bRow.get(5).toString()) : 0;
                  String bMode     = bRow.get(6) != null ? bRow.get(6).toString() : "";
                  String bDate     = bRow.get(8) != null ? bRow.get(8).toString() : "-";
                  String bRemarks  = bRow.get(9) != null ? bRow.get(9).toString() : "";
                  String bPartyDisp = bRow.get(2) != null ? bRow.get(2).toString() : "-";
                  boolean bIsCollection = (bBillAmt <= 0.005);
                  double bAmt; String bDisplayDir;
                  if (bIsCollection) { bAmt = bPaidAmt; bDisplayDir = "DR".equals(bTxnType) ? "CR" : "DR"; }
                  else { bAmt = Math.max(bBillAmt - bPaidAmt, 0); bDisplayDir = bTxnType; }
                  boolean bIsDR = "DR".equals(bDisplayDir);
                  if (bIsDR) { bRunBal += bAmt; bTotalDr += bAmt; } else { bRunBal -= bAmt; bTotalCr += bAmt; }
                  String bBal, bBalCls;
                  if      (bRunBal >  0.001) { bBal = dfLh.format(bRunBal)  + " DR"; bBalCls = "bal-dr"; }
                  else if (bRunBal < -0.001) { bBal = dfLh.format(-bRunBal) + " CR"; bBalCls = "bal-cr"; }
                  else                       { bBal = "0.00";                          bBalCls = "bal-nil"; }
              %>
              <tr style="cursor:pointer;" onclick="showPHModal('<%=bDate%>','<%=bPartyDisp.replace("'","&#39;")%>','<%=bMode.replace("'","&#39;")%>','<%=bDisplayDir%>','<%=dfLh.format(bAmt)%>','<%=bRemarks.replace("'","&#39;").replace("\"","&quot;")%>')">
                <td style="white-space:nowrap;color:var(--muted);"><%=bDate%></td>
                <td style="font-size:11px;color:var(--muted);"><%=bMode.isEmpty()?"-":bMode%></td>
                <td class="num dr-amt"><%=bIsDR ? dfLh.format(bAmt) : ""%></td>
                <td class="num cr-amt"><%=!bIsDR ? dfLh.format(bAmt) : ""%></td>
                <td class="num <%=bBalCls%>"><%=bBal%></td>
              </tr>
              <%}%>
              <tr class="row-total">
                <td colspan="2" style="text-align:right;letter-spacing:.4px;">TOTAL</td>
                <td class="num"><%=dfLh.format(bTotalDr)%></td>
                <td class="num"><%=dfLh.format(bTotalCr)%></td>
                <td class="num <%=bRunBal>0.001?"bal-dr":bRunBal<-0.001?"bal-cr":"bal-nil"%>">
                  <%=bRunBal>0.001?dfLh.format(bRunBal)+" DR":bRunBal<-0.001?dfLh.format(-bRunBal)+" CR":"0.00"%>
                </td>
              </tr>
              </tbody>
            </table>
            </div>
            <%}%>
          </div>

          <!-- SELL side -->
          <div>
            <div style="display:flex;align-items:center;gap:6px;padding:7px 10px;background:#e8f5e9;border-radius:6px 6px 0 0;border:1px solid #c8e6c9;border-bottom:none;">
              <i class="fa-solid fa-arrow-up-from-bracket" style="color:#1b5e20;font-size:12px;"></i>
              <span style="font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.4px;color:#1b5e20;">Sell To</span>
            </div>
            <%if (sellLedger.isEmpty()) {%>
            <div style="padding:14px 10px;font-size:12px;color:var(--muted);font-style:italic;background:#fafafa;border:1px solid #c8e6c9;border-radius:0 0 6px 6px;">No entries</div>
            <%} else {
                double sRunBal = 0, sTotalDr = 0, sTotalCr = 0;
            %>
            <div style="overflow-x:auto;border:1px solid #c8e6c9;border-radius:0 0 6px 6px;">
            <table class="ph-table">
              <thead>
                <tr>
                  <th style="background:#f1f8f2;color:#1b5e20;width:90px;">Date</th>
                  <th style="background:#f1f8f2;color:#1b5e20;">Mode</th>
                  <th class="num" style="background:#f1f8f2;color:#dc2626;width:90px;">Dr.Amt</th>
                  <th class="num" style="background:#f1f8f2;color:#059669;width:90px;">Cr.Amt</th>
                  <th class="num" style="background:#f1f8f2;color:#1b5e20;width:100px;">Balance</th>
                </tr>
              </thead>
              <tbody>
              <%for (int si = 0; si < sellLedger.size(); si++) {
                  Vector sRow = (Vector) sellLedger.get(si);
                  String sPartyType = sRow.get(1) != null ? sRow.get(1).toString() : "";
                  String sPartyDisp = sRow.get(2) != null ? sRow.get(2).toString() : "-";
                  String sTxnType   = sRow.get(3) != null ? sRow.get(3).toString() : "DR";
                  double sBillAmt   = sRow.get(4) != null ? Double.parseDouble(sRow.get(4).toString()) : 0;
                  double sPaidAmt   = sRow.get(5) != null ? Double.parseDouble(sRow.get(5).toString()) : 0;
                  String sMode      = sRow.get(6) != null ? sRow.get(6).toString() : "";
                  String sDate      = sRow.get(8) != null ? sRow.get(8).toString() : "-";
                  String sRemarks   = sRow.get(9) != null ? sRow.get(9).toString() : "";
                  boolean sIsCollection = (sBillAmt <= 0.005);
                  double sAmt; String sDisplayDir;
                  if (sIsCollection) { sAmt = sPaidAmt; sDisplayDir = "DR".equals(sTxnType) ? "CR" : "DR"; }
                  else { sAmt = Math.max(sBillAmt - sPaidAmt, 0); sDisplayDir = sTxnType; }
                  boolean sIsDR = "DR".equals(sDisplayDir);
                  if (sIsDR) { sRunBal += sAmt; sTotalDr += sAmt; } else { sRunBal -= sAmt; sTotalCr += sAmt; }
                  String sBal, sBalCls;
                  if      (sRunBal >  0.001) { sBal = dfLh.format(sRunBal)  + " DR"; sBalCls = "bal-dr"; }
                  else if (sRunBal < -0.001) { sBal = dfLh.format(-sRunBal) + " CR"; sBalCls = "bal-cr"; }
                  else                       { sBal = "0.00";                          sBalCls = "bal-nil"; }
                  String sBadgeLbl = "SELL_AGENT".equals(sPartyType) ? "Sell" : "Cust";
                  String sBadgeCls = "SELL_AGENT".equals(sPartyType) ? "badge-ph badge-ph-sell" : "badge-ph badge-ph-cust";
              %>
              <tr style="cursor:pointer;" onclick="showPHModal('<%=sDate%>','<%=sPartyDisp.replace("'","&#39;")%>','<%=sMode.replace("'","&#39;")%>','<%=sDisplayDir%>','<%=dfLh.format(sAmt)%>','<%=sRemarks.replace("'","&#39;").replace("\"","&quot;")%>')">
                <td style="white-space:nowrap;color:var(--muted);"><%=sDate%></td>
                <td style="font-size:11px;"><span class="<%=sBadgeCls%>"><%=sBadgeLbl%></span> <span style="color:var(--muted);"><%=sMode.isEmpty()?"-":sMode%></span></td>
                <td class="num dr-amt"><%=sIsDR ? dfLh.format(sAmt) : ""%></td>
                <td class="num cr-amt"><%=!sIsDR ? dfLh.format(sAmt) : ""%></td>
                <td class="num <%=sBalCls%>"><%=sBal%></td>
              </tr>
              <%}%>
              <tr class="row-total">
                <td colspan="2" style="text-align:right;letter-spacing:.4px;">TOTAL</td>
                <td class="num"><%=dfLh.format(sTotalDr)%></td>
                <td class="num"><%=dfLh.format(sTotalCr)%></td>
                <td class="num <%=sRunBal>0.001?"bal-dr":sRunBal<-0.001?"bal-cr":"bal-nil"%>">
                  <%=sRunBal>0.001?dfLh.format(sRunBal)+" DR":sRunBal<-0.001?dfLh.format(-sRunBal)+" CR":"0.00"%>
                </td>
              </tr>
              </tbody>
            </table>
            </div>
            <%}%>
          </div>

        </div><!-- /two-col -->
        <%}%>

    </div><!-- /result-body -->
  </div><!-- /result-card -->

    <%}%>

    <div style="height:20px;"></div>
  </div><!-- /tw-body -->
</div><!-- /tw -->
<script>
function showPHModal(date, party, mode, type, amt, remark) {
    var isDR = type === 'DR';
    var amtClr = isDR ? '#dc2626' : '#059669';
    var html =
        '<table style="width:100%;border-collapse:collapse;font-size:13px;text-align:left;">' +
        '<tr><td style="padding:5px 8px;color:#64748b;width:40%">Date</td><td style="padding:5px 8px;font-weight:600;">' + date + '</td></tr>' +
        '<tr><td style="padding:5px 8px;color:#64748b;">Party</td><td style="padding:5px 8px;font-weight:600;">' + (party || '-') + '</td></tr>' +
        '<tr><td style="padding:5px 8px;color:#64748b;">Type</td><td style="padding:5px 8px;"><span style="font-weight:700;color:' + amtClr + ';">' + type + '</span></td></tr>' +
        '<tr><td style="padding:5px 8px;color:#64748b;">Mode</td><td style="padding:5px 8px;">' + (mode || '-') + '</td></tr>' +
        '<tr><td style="padding:5px 8px;color:#64748b;">Amount</td><td style="padding:5px 8px;font-weight:700;color:' + amtClr + ';">&#8377; ' + amt + '</td></tr>' +
        '<tr><td style="padding:8px 8px 4px;color:#64748b;vertical-align:top;">Remarks</td><td style="padding:8px 8px 4px;">' +
        (remark ? '<span style="font-weight:600;color:#0f172a;">' + remark + '</span>' : '<span style="color:#94a3b8;font-style:italic;">No remarks</span>') +
        '</td></tr></table>';
    Swal.fire({
        title: 'Transaction Detail',
        html: html,
        confirmButtonText: 'Close',
        confirmButtonColor: '#1a2744',
        width: 380
    });
}
</script>
</body>
</html>
