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

@media(max-width:600px){.detail-grid{grid-template-columns:1fr 1fr;}.txn-strips{grid-template-columns:1fr;}}
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
              <div class="txn-row2"><span class="txn-key">Amount</span><span class="txn-value amount">₹ <%=buyAmt.isEmpty()?"-":buyAmt%></span></div>
              <div class="txn-row2"><span class="txn-key">Mode</span><span class="txn-value"><%=buyMode.isEmpty()?"-":buyMode%></span></div>
            </div>
          </div>
          <%}%>
          <%if (!sellAgent.isEmpty()) {%>
          <div class="txn-strip">
            <div class="txn-strip-head sell-h"><i class="fa-solid fa-arrow-up-from-bracket"></i> Sell to Agent</div>
            <div class="txn-strip-body">
              <div class="txn-row2"><span class="txn-key">Agent</span><span class="txn-value"><%=sellAgent%></span></div>
              <div class="txn-row2"><span class="txn-key">Amount</span><span class="txn-value amount">₹ <%=sellAmt.isEmpty()?"-":sellAmt%></span></div>
              <div class="txn-row2"><span class="txn-key">Mode</span><span class="txn-value"><%=sellMode.isEmpty()?"-":sellMode%></span></div>
            </div>
          </div>
          <%}%>
          <%if (!custName.isEmpty() || !custAmt.isEmpty()) {%>
          <div class="txn-strip">
            <div class="txn-strip-head cust-h"><i class="fa-solid fa-user"></i> Customer</div>
            <div class="txn-strip-body">
              <div class="txn-row2"><span class="txn-key">Name</span><span class="txn-value"><%=custName.isEmpty()?"-":custName%></span></div>
              <div class="txn-row2"><span class="txn-key">Amount</span><span class="txn-value amount">₹ <%=custAmt.isEmpty()?"-":custAmt%></span></div>
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
        <%if (ledgerHistory.isEmpty()) {%>
        <p style="color:var(--muted);font-size:12px;font-style:italic;">No payment entries found</p>
        <%} else {%>
        <div style="overflow-x:auto;">
        <table style="width:100%;border-collapse:collapse;font-size:12px;">
          <thead>
            <tr style="background:linear-gradient(135deg,#1a2744,#243159);">
              <th style="padding:7px 10px;color:#fff;font-weight:700;text-align:left;font-size:10.5px;text-transform:uppercase;letter-spacing:.4px;">#</th>
              <th style="padding:7px 10px;color:#fff;font-weight:700;text-align:left;font-size:10.5px;text-transform:uppercase;letter-spacing:.4px;">Date</th>
              <th style="padding:7px 10px;color:#fff;font-weight:700;text-align:left;font-size:10.5px;text-transform:uppercase;letter-spacing:.4px;">Party</th>
              <th style="padding:7px 10px;color:#fff;font-weight:700;text-align:left;font-size:10.5px;text-transform:uppercase;letter-spacing:.4px;">Type</th>
              <th style="padding:7px 10px;color:#fff;font-weight:700;text-align:left;font-size:10.5px;text-transform:uppercase;letter-spacing:.4px;">Mode</th>
              <th style="padding:7px 10px;color:#fff;font-weight:700;text-align:left;font-size:10.5px;text-transform:uppercase;letter-spacing:.4px;">Txn No</th>
              <th style="padding:7px 10px;color:#fff;font-weight:700;text-align:right;font-size:10.5px;text-transform:uppercase;letter-spacing:.4px;">Amount</th>
              <th style="padding:7px 10px;color:#fff;font-weight:700;text-align:left;font-size:10.5px;text-transform:uppercase;letter-spacing:.4px;">Remarks</th>
            </tr>
          </thead>
          <tbody>
          <%
          DecimalFormat dfLh = new DecimalFormat("0.00");
          for (int li = 0; li < ledgerHistory.size(); li++) {
              Vector lh = (Vector) ledgerHistory.get(li);
              // [0]id [1]party_type [2]party_display [3]txn_type [4]bill_amount [5]amount [6]payment_mode [7]txn_no [8]txn_date [9]remarks
              String lPartyType = lh.get(1) != null ? lh.get(1).toString() : "";
              String lPartyDisp = lh.get(2) != null ? lh.get(2).toString() : "-";
              String lTxnType   = lh.get(3) != null ? lh.get(3).toString() : "DR";
              double lAmt       = lh.get(5) != null ? Double.parseDouble(lh.get(5).toString()) : 0;
              String lMode      = lh.get(6) != null ? lh.get(6).toString() : "";
              String lTxnNo     = lh.get(7) != null ? lh.get(7).toString() : "";
              String lDate      = lh.get(8) != null ? lh.get(8).toString() : "-";
              String lRemarks   = lh.get(9) != null ? lh.get(9).toString() : "";
              String lPtBadgeClr = "BUY_AGENT".equals(lPartyType) ? "#bf6000" : "SELL_AGENT".equals(lPartyType) ? "#1b5e20" : "#0d47a1";
              String lPtLabel = "BUY_AGENT".equals(lPartyType) ? "Buy Agent" : "SELL_AGENT".equals(lPartyType) ? "Sell Agent" : "Customer";
              String lAmtClr = "CR".equals(lTxnType) ? "#059669" : "#dc2626";
          %>
          <tr style="border-bottom:1px solid #e8edf5;<%=li % 2 == 1 ? "background:#f7f8fc;" : ""%>">
            <td style="padding:7px 10px;color:#94a3b8;"><%=li+1%></td>
            <td style="padding:7px 10px;color:#64748b;white-space:nowrap;"><%=lDate%></td>
            <td style="padding:7px 10px;">
              <span style="display:inline-block;padding:1px 6px;border-radius:3px;font-size:10px;font-weight:700;color:<%=lPtBadgeClr%>;background:<%="BUY_AGENT".equals(lPartyType) ? "#fff3e0" : "SELL_AGENT".equals(lPartyType) ? "#e8f5e9" : "#e3f2fd"%>;"><%=lPtLabel%></span>
              <div style="font-size:11px;margin-top:2px;font-weight:600;"><%=lPartyDisp%></div>
            </td>
            <td style="padding:7px 10px;">
              <span style="font-size:10px;font-weight:700;color:<%="DR".equals(lTxnType) ? "#dc2626" : "#059669"%>;"><%=lTxnType%></span>
            </td>
            <td style="padding:7px 10px;font-size:11px;"><%=lMode.isEmpty() ? "-" : lMode%></td>
            <td style="padding:7px 10px;font-size:11px;font-weight:600;color:#5c4d8a;"><%=lTxnNo.isEmpty() ? "<span style='color:#94a3b8;'>\u2014</span>" : lTxnNo%></td>
            <td style="padding:7px 10px;text-align:right;font-weight:700;color:<%=lAmtClr%>;">&#8377;<%=dfLh.format(lAmt)%></td>
            <td style="padding:7px 10px;font-size:11px;color:#475569;"><%=lRemarks.isEmpty() ? "<span style='color:#94a3b8;'>\u2014</span>" : lRemarks%></td>
          </tr>
          <%}%>
          </tbody>
        </table>
        </div>
        <%}%>

    </div><!-- /result-body -->
  </div><!-- /result-card -->

    <%}%>

    <div style="height:20px;"></div>
  </div><!-- /tw-body -->
</div><!-- /tw -->
</body>
</html>
