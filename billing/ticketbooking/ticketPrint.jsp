<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<jsp:useBean id="user"    class="user.userBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}

int bookingId = 0;
try { bookingId = Integer.parseInt(request.getParameter("id")); } catch (Exception e2) {}
if (bookingId <= 0) { out.print("Invalid booking ID"); return; }

Vector bookingResult = billing.getTicketById(bookingId);
if (bookingResult.isEmpty()) { out.print("Booking not found"); return; }

Vector row       = (Vector) bookingResult.get(0);
Vector passengers = billing.getPNRPassengers(bookingId);

// Company
Vector compVec = new Vector();
try { compVec = user.getCompanyDetails(); } catch (Exception e2) {}
String shopName = compVec.size() > 1 && compVec.get(1) != null ? String.valueOf(compVec.get(1)) : "Moulana Travels";
String address  = compVec.size() > 2 && compVec.get(2) != null ? String.valueOf(compVec.get(2)) : "";
String gstin    = compVec.size() > 3 && compVec.get(3) != null ? String.valueOf(compVec.get(3)) : "";

// Booking fields
String pnrVal      = row.get(1)  != null ? String.valueOf(row.get(1))  : "-";
String bookDate    = row.get(2)  != null ? String.valueOf(row.get(2))  : "-";
String owDate      = row.get(3)  != null ? String.valueOf(row.get(3))  : "-";
String owTime      = row.get(4)  != null ? String.valueOf(row.get(4))  : "";
String owFrom      = row.get(5)  != null ? String.valueOf(row.get(5))  : "-";
String owTo        = row.get(6)  != null ? String.valueOf(row.get(6))  : "-";
String owFlight    = row.get(7)  != null ? String.valueOf(row.get(7))  : "-";
String owAirlines  = row.get(8)  != null ? String.valueOf(row.get(8))  : "-";
String retDate     = row.get(9)  != null ? String.valueOf(row.get(9))  : "";
String retTime     = row.get(10) != null ? String.valueOf(row.get(10)) : "";
String retFrom     = row.get(11) != null ? String.valueOf(row.get(11)) : "";
String retTo       = row.get(12) != null ? String.valueOf(row.get(12)) : "";
String retFlight   = row.get(13) != null ? String.valueOf(row.get(13)) : "";
String retAirlines = row.get(14) != null ? String.valueOf(row.get(14)) : "";
String seats       = row.get(15) != null ? String.valueOf(row.get(15)) : "-";
String phone       = row.get(16) != null ? String.valueOf(row.get(16)) : "-";
String buyAgent    = row.get(17) != null ? String.valueOf(row.get(17)) : "";
String buyAmt      = row.get(18) != null ? String.valueOf(row.get(18)) : "";
String buyMode     = row.get(19) != null ? String.valueOf(row.get(19)) : "";
String sellAgent   = row.get(20) != null ? String.valueOf(row.get(20)) : "";
String sellAmt     = row.get(21) != null ? String.valueOf(row.get(21)) : "";
String sellMode    = row.get(22) != null ? String.valueOf(row.get(22)) : "";
String custName    = row.get(23) != null ? String.valueOf(row.get(23)) : "";
String custAmt     = row.get(24) != null ? String.valueOf(row.get(24)) : "";
String custMode    = row.get(25) != null ? String.valueOf(row.get(25)) : "";
String ticketNo    = row.get(27) != null ? String.valueOf(row.get(27)) : "";
double sellPaid    = row.size() > 28 && row.get(28) != null ? ((Number)row.get(28)).doubleValue() : 0.0;
double custPaid    = row.size() > 29 && row.get(29) != null ? ((Number)row.get(29)).doubleValue() : 0.0;

// Payment summary calculations
double totalSell   = sellAmt.isEmpty() ? 0.0 : Double.parseDouble(sellAmt.replaceAll("[^\\d.]",""));
double totalCust   = custAmt.isEmpty() ? 0.0 : Double.parseDouble(custAmt.replaceAll("[^\\d.]",""));
double sellBal     = totalSell - sellPaid;
double custBal     = totalCust - custPaid;
double grandTotal  = totalSell + totalCust;
double grandPaid   = sellPaid + custPaid;
double grandBal    = grandTotal - grandPaid;
java.text.DecimalFormat pf = new java.text.DecimalFormat("#,##0.00");
boolean hasPaySummary = grandTotal > 0;
boolean hasRet     = retDate != null && !retDate.trim().isEmpty();
String ctx = request.getContextPath();

// Load ledger history for per-party payment mode + txn_no detail
java.util.Vector ledHist = new java.util.Vector();
try { ledHist = billing.getTicketLedgerByBookingId(bookingId); } catch (Exception elh2) {}
String sellLedMode = ""; String sellLedTxnNo = "";
String custLedMode = ""; String custLedTxnNo = "";
double grandCashPaid = 0, grandOnlinePaid = 0;
String lastOnlineTxnNo = "";
for (int li = 0; li < ledHist.size(); li++) {
    java.util.Vector lh = (java.util.Vector) ledHist.get(li);
    String lPT  = lh.get(1) != null ? lh.get(1).toString() : "";
    String lMod = lh.get(6) != null ? lh.get(6).toString() : "";
    String lTxn = lh.get(7) != null ? lh.get(7).toString() : "";
    double lAmt = lh.get(5) != null ? Double.parseDouble(lh.get(5).toString()) : 0;
    boolean lisCash = lMod.toLowerCase().contains("cash");
    if ("SELL_AGENT".equals(lPT)) {
        if (!lMod.isEmpty()) { sellLedMode = lMod; sellLedTxnNo = lTxn; }
    } else if ("CUSTOMER".equals(lPT)) {
        if (!lMod.isEmpty()) { custLedMode = lMod; custLedTxnNo = lTxn; }
    }
    if (lAmt > 0) {
        if (lisCash) grandCashPaid += lAmt;
        else { grandOnlinePaid += lAmt; if (!lTxn.isEmpty()) lastOnlineTxnNo = lTxn; }
    }
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title><%=ticketNo.isEmpty()?"Ticket":ticketNo%> – <%=pnrVal%></title>
<style>
/* ── PAGE SIZE : A5 (148mm × 210mm) ── */
@page {
    size: A5 portrait;
    margin: 8mm 8mm 8mm 8mm;
}
* { box-sizing: border-box; margin: 0; padding: 0; }
body {
    font-family: 'Segoe UI', Arial, sans-serif;
    font-size: 9.5pt;
    color: #0f172a;
    background: #fff;
    width: 148mm;
    margin: 0 auto;
}

/* ── NO-PRINT CONTROLS ── */
.no-print {
    display: flex; gap: 8px; justify-content: center;
    padding: 10px; background: #f1f5f9;
    border-bottom: 1px solid #d1d9e6;
}
.no-print button {
    padding: 7px 18px; border: none; border-radius: 5px;
    font-size: 12px; font-weight: 700; cursor: pointer;
}
.btn-print  { background: #1a2744; color: #fff; }
.btn-close  { background: #e2e8f0; color: #475569; }
@media print { .no-print { display: none !important; } }

/* ── TICKET WRAPPER ── */
.ticket {
    width: 148mm;
    min-height: 210mm;
    display: flex;
    flex-direction: column;
    border: 1.5pt solid #1a2744;
    overflow: hidden;
}

/* ── HEADER ── */
.tk-header {
    background: linear-gradient(135deg, #1a2744 0%, #243159 100%);
    padding: 7mm 6mm 5mm;
    display: flex;
    align-items: center;
    gap: 5mm;
}
.tk-logo { width: 14mm; height: 14mm; object-fit: contain; flex-shrink: 0; }
.tk-company { flex: 1; }
.tk-company-name { color: #c9922a; font-size: 14pt; font-weight: 900; line-height: 1.1; letter-spacing: .3pt; }
.tk-company-sub  { color: rgba(255,255,255,.75); font-size: 8pt; margin-top: 1mm; line-height: 1.4; }
.tk-pnr-box {
    text-align: right;
    border: 1.5pt solid #c9922a;
    border-radius: 4pt;
    padding: 2mm 4mm;
    background: rgba(201,146,42,.12);
}
.tk-pnr-lbl { color: rgba(255,255,255,.6); font-size: 6.5pt; font-weight: 700; text-transform: uppercase; letter-spacing: .6pt; }
.tk-pnr-val { color: #c9922a; font-size: 13pt; font-weight: 900; letter-spacing: 1.5pt; white-space: nowrap; }

/* ── DASHED SEPARATOR ── */
.tk-sep {
    border: none; border-top: 1.5pt dashed #94a3b8;
    margin: 0;
}

/* ── INFO ROW ── */
.tk-info-bar {
    background: #f1f5f9;
    display: flex;
    padding: 2.5mm 5mm;
    gap: 0;
    border-bottom: 1pt solid #e2e8f0;
    flex-wrap: wrap;
}
.tk-info-item { flex: 1; min-width: 30mm; }
.tk-info-lbl { font-size: 6.5pt; color: #64748b; font-weight: 700; text-transform: uppercase; letter-spacing: .4pt; }
.tk-info-val { font-size: 9pt; font-weight: 700; color: #1a2744; margin-top: .5mm; }

/* ── SECTION HEAD ── */
.sec-head {
    display: flex; align-items: center; gap: 2mm;
    padding: 2mm 5mm 1.5mm;
    background: #f8fafc;
    border-bottom: 1pt solid #e2e8f0;
    border-top: 1pt solid #e2e8f0;
}
.sec-head-icon { font-size: 9pt; color: #5c4d8a; }
.sec-head-title { font-size: 8pt; font-weight: 800; text-transform: uppercase; letter-spacing: .6pt; color: #1a2744; }
.sec-head-badge {
    margin-left: auto;
    font-size: 7pt; font-weight: 700; background: #1a2744; color: #fff;
    border-radius: 3pt; padding: 1pt 5pt; white-space: nowrap;
}
.sec-head-badge.ret { background: #059669; }

/* ── FLIGHT TABLE ── */
.flt-table { width: 100%; border-collapse: collapse; }
.flt-table td { padding: 2mm 5mm; vertical-align: top; }
.flt-table .flt-route td { padding: 3mm 5mm 2mm; }
.flt-from, .flt-to { font-size: 16pt; font-weight: 900; color: #1a2744; letter-spacing: .5pt; }
.flt-arrow { font-size: 12pt; color: #5c4d8a; padding: 0 3mm; vertical-align: middle; }
.flt-city  { font-size: 7.5pt; color: #64748b; font-weight: 600; margin-top: 1pt; }
.flt-detail-row td { border-top: 1pt solid #e8edf5; }
.flt-lbl { font-size: 6.5pt; color: #64748b; font-weight: 700; text-transform: uppercase; letter-spacing: .4pt; }
.flt-val { font-size: 9pt; font-weight: 700; color: #0f172a; margin-top: .5mm; }

/* ── PASSENGER TABLE ── */
.pax-table { width: 100%; border-collapse: collapse; }
.pax-table thead tr { background: #1a2744; }
.pax-table thead th {
    color: #fff; font-size: 7pt; font-weight: 700;
    text-transform: uppercase; letter-spacing: .4pt;
    padding: 2mm 3mm; text-align: left;
}
.pax-table tbody tr { border-bottom: 1pt solid #e8edf5; }
.pax-table tbody tr:nth-child(even) { background: #f8fafc; }
.pax-table td { padding: 2.5mm 3mm; font-size: 9pt; vertical-align: middle; }
.pax-no { text-align: center; font-weight: 800; color: #5c4d8a; width: 10mm; }
.pax-sign { width: 35mm; }
.pax-sign-inner { border-bottom: 1pt solid #94a3b8; height: 7mm; }

/* ── SIDE-BY-SIDE PAX + TXN ── */
.pax-txn-grid { display: flex; border-top: 1pt solid #e2e8f0; }
.pax-col { flex: 3; border-right: 1pt solid #e2e8f0; min-width: 0; }
.txn-col { flex: 2; min-width: 0; }
.pax-col .sec-head,
.txn-col .sec-head { border-top: none; }

/* ── TRANSACTION TABLE ── */
.txn-table { width: 100%; border-collapse: collapse; }
.txn-table td { padding: 1.5mm 3mm; font-size: 8pt; border-bottom: 1pt solid #f1f5f9; }
.txn-type-cell { width: 22mm; }
.txn-badge {
    display: inline-block; padding: 1pt 5pt; border-radius: 3pt;
    font-size: 6.5pt; font-weight: 800; text-transform: uppercase; letter-spacing: .3pt;
}
.txn-badge.buy  { background: #fff3e0; color: #bf6000; border: 1pt solid #ffcc80; }
.txn-badge.sell { background: #e8f5e9; color: #2e7d32; border: 1pt solid #a5d6a7; }
.txn-badge.cust { background: #e3f2fd; color: #0d47a1; border: 1pt solid #90caf9; }
.txn-agent { font-weight: 700; color: #1a2744; font-size: 8pt; }
.txn-balance  { font-size: 7.5pt; color: #64748b; }
.txn-amt   { text-align: right; font-weight: 800; color: #059669; font-size: 9pt; white-space: nowrap; }

/* ── COMPACT FLIGHT SECTION FOR RETURN TICKETS ── */
.has-ret .flt-from, .has-ret .flt-to { font-size: 13pt; }
.has-ret .flt-table .flt-route td { padding: 2mm 4mm 1.5mm; }
.has-ret .flt-table td { padding: 1.5mm 4mm; }
.has-ret .sec-head { padding: 1.5mm 5mm 1mm; }

/* ── FOOTER ── */
.tk-footer {
    margin-top: auto;
    background: linear-gradient(135deg, #1a2744 0%, #243159 100%);
    padding: 3mm 5mm;
    display: flex;
    justify-content: space-between;
    align-items: center;
}
.tk-footer-left  { color: rgba(255,255,255,.65); font-size: 7pt; }
.tk-footer-right { color: rgba(255,255,255,.65); font-size: 7pt; text-align: right; }
.tk-footer-mid   { color: #c9922a; font-size: 8pt; font-weight: 800; letter-spacing: .3pt; text-align: center; }
.jasxbill-promo {
    text-align: right;
    padding: 1mm 3mm 1.5mm;
    font-size: 5.5pt;
    color: #94a3b8;
    letter-spacing: .2pt;
}
.jasxbill-promo a { color: #94a3b8; text-decoration: none; }
@media print { .jasxbill-promo a { color: #94a3b8; } }

/* ── SIGN SECTION ── */
.sign-section {
    display: flex; gap: 5mm; padding: 3mm 5mm 4mm;
    border-top: 1.5pt dashed #94a3b8;
}
.sign-box { flex: 1; text-align: center; }
.sign-box-line { border-bottom: 1pt solid #94a3b8; height: 8mm; margin: 0 2mm; }
.sign-box-lbl { font-size: 7pt; color: #64748b; font-weight: 600; text-transform: uppercase; letter-spacing: .4pt; margin-top: 1.5mm; }

/* ── PAYMENT SUMMARY BOX ── */
.pay-summary {
    border-top: 1pt solid #1a2744;
    overflow: hidden;
}
.pay-summary-head {
    background: #1a2744;
    color: #fff;
    font-size: 7pt;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: .6pt;
    padding: 1.5mm 3mm;
    display: flex;
    align-items: center;
    gap: 2mm;
}
.pay-summary-head .gold { color: #c9922a; }
.pay-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 1.5mm 3mm;
    border-bottom: 1pt solid #e8edf5;
    font-size: 8pt;
}
.pay-row:last-child { border-bottom: none; }
.pay-row-lbl { color: #475569; font-weight: 600; }
.pay-row-amt { font-weight: 800; }
.pay-total   { background: #f8fafc; }
.pay-total .pay-row-lbl { color: #1a2744; font-weight: 700; }
.pay-total .pay-row-amt { color: #1a2744; font-size: 9pt; }
.pay-paid .pay-row-amt  { color: #059669; }
.pay-bal-ok  { background: #f0fdf4; }
.pay-bal-due { background: #fff7ed; }
.pay-bal-ok  .pay-row-lbl { color: #059669; font-weight: 700; }
.pay-bal-due .pay-row-lbl { color: #d97706; font-weight: 700; }
.pay-bal-ok  .pay-row-amt { color: #059669; font-size: 9pt; }
.pay-bal-due .pay-row-amt { color: #d97706; font-size: 9pt; }

/* ── PAYMENT MODE SUB-ROWS ── */
.txn-mode { font-size: 7pt; margin-top: 1.5pt; }
.txn-mode-cash   { color: #2e7d32; }
.txn-mode-online { color: #0d47a1; }
.pay-mode-row {
    padding: 0.8mm 3mm 1mm 6mm; font-size: 7.5pt;
    border-bottom: 1pt solid #e8edf5;
    display: flex; justify-content: space-between;
}
.pay-mode-cash  .pay-row-lbl { color: #2e7d32; font-size: 7.5pt; }
.pay-mode-cash  .pay-row-amt { color: #2e7d32; font-size: 7.5pt; }
.pay-mode-online .pay-row-lbl { color: #0d47a1; font-size: 7.5pt; }
.pay-mode-online .pay-row-amt { color: #0d47a1; font-size: 7.5pt; }
.pay-mode-txn { padding: 0.3mm 3mm 1mm 8mm; font-size: 6.5pt; color: #5c4d8a; font-style: italic; border-bottom: 1pt solid #e8edf5; }

.pt-1 { padding-top: 1mm; }
</style>
</head>
<body>

<!-- No-print controls -->
<div class="no-print">
  <button class="btn-print" onclick="doPrint()">&#9113; Print Ticket</button>
  <button class="btn-close" onclick="window.close()">&#10005; Close</button>
</div>

<div class="ticket <%=hasRet?"has-ret":""%>">

  <!-- ═══ HEADER ═══ -->
  <div class="tk-header">
    <img src="<%=ctx%>/ticketbooking/logo.png" class="tk-logo" alt="logo">
    <div class="tk-company">
      <div class="tk-company-name"><%=shopName%></div>
      <div class="tk-company-sub">
        <%if (!address.trim().isEmpty()){%><%=address%><%}%>
        <%if (!gstin.trim().isEmpty()){%>&nbsp;|&nbsp;GSTIN: <%=gstin%><%}%>
      </div>
    </div>
    <div class="tk-pnr-box">
      <%if (!ticketNo.isEmpty()) {%>
      <div class="tk-pnr-lbl">Ticket No</div>
      <div class="tk-pnr-val"><%=ticketNo%></div>
      <div style="border-top:1pt solid rgba(201,146,42,.3);margin:1.5mm 0;"></div>
      <%}%>
      <div class="tk-pnr-lbl">PNR</div>
      <div style="color:#e8d5a3;font-size:10.5pt;font-weight:800;letter-spacing:1.2pt;white-space:nowrap;"><%=pnrVal%></div>
    </div>
  </div>

  <!-- ═══ BOOKING INFO BAR ═══ -->
  <div class="tk-info-bar">
    <div class="tk-info-item">
      <div class="tk-info-lbl">Booking ID</div>
      <div class="tk-info-val">#<%=bookingId%></div>
    </div>
    <div class="tk-info-item">
      <div class="tk-info-lbl">Booking Date</div>
      <div class="tk-info-val"><%=bookDate%></div>
    </div>
    <div class="tk-info-item">
      <div class="tk-info-lbl">Passengers</div>
      <div class="tk-info-val"><%=seats%></div>
    </div>
    <div class="tk-info-item">
      <div class="tk-info-lbl">Phone</div>
      <div class="tk-info-val"><%=phone.equals("-")?"—":phone%></div>
    </div>
  </div>

  <!-- ═══ ONE WAY ═══ -->
  <div class="sec-head">
    <span class="sec-head-icon">&#9992;</span>
    <span class="sec-head-title">One Way</span>
    <span class="sec-head-badge"><%=owDate%><%=!owTime.isEmpty()?" &nbsp;"+owTime:""%></span>
  </div>
  <table class="flt-table">
    <tr class="flt-route">
      <td style="text-align:left;">
        <div class="flt-from"><%=owFrom%></div>
        <div class="flt-city">Origin</div>
      </td>
      <td style="text-align:center;vertical-align:middle;">
        <span class="flt-arrow">&#10230;</span>
      </td>
      <td style="text-align:right;">
        <div class="flt-to"><%=owTo%></div>
        <div class="flt-city">Destination</div>
      </td>
    </tr>
    <tr class="flt-detail-row">
      <td><div class="flt-lbl">Flight No</div><div class="flt-val"><%=owFlight.equals("-")?"—":owFlight%></div></td>
      <td style="text-align:center;"><div class="flt-lbl">Airlines</div><div class="flt-val"><%=owAirlines.equals("-")?"—":owAirlines%></div></td>
      <td style="text-align:right;"><div class="flt-lbl">Travel Date</div><div class="flt-val"><%=owDate%><%=!owTime.isEmpty()?" "+owTime:""%></div></td>
    </tr>
  </table>

  <%if (hasRet) {%>
  <!-- ═══ RETURN ═══ -->
  <div class="sec-head">
    <span class="sec-head-icon">&#11150;</span>
    <span class="sec-head-title">Return Journey</span>
    <span class="sec-head-badge ret"><%=retDate%><%=!retTime.isEmpty()?" &nbsp;"+retTime:""%></span>
  </div>
  <table class="flt-table">
    <tr class="flt-route">
      <td style="text-align:left;">
        <div class="flt-from"><%=retFrom.isEmpty()?"-":retFrom%></div>
        <div class="flt-city">Origin</div>
      </td>
      <td style="text-align:center;vertical-align:middle;">
        <span class="flt-arrow">&#10230;</span>
      </td>
      <td style="text-align:right;">
        <div class="flt-to"><%=retTo.isEmpty()?"-":retTo%></div>
        <div class="flt-city">Destination</div>
      </td>
    </tr>
    <tr class="flt-detail-row">
      <td><div class="flt-lbl">Flight No</div><div class="flt-val"><%=retFlight.isEmpty()?"—":retFlight%></div></td>
      <td style="text-align:center;"><div class="flt-lbl">Airlines</div><div class="flt-val"><%=retAirlines.isEmpty()?"—":retAirlines%></div></td>
      <td style="text-align:right;"><div class="flt-lbl">Return Date</div><div class="flt-val"><%=retDate%><%=!retTime.isEmpty()?" "+retTime:""%></div></td>
    </tr>
  </table>
  <%}%>

  <!-- ═══ PASSENGERS + TRANSACTION (side-by-side) ═══ -->
  <div class="pax-txn-grid">
    <!-- Left: Passengers -->
    <div class="pax-col">
      <div class="sec-head">
        <span class="sec-head-icon">&#128101;</span>
        <span class="sec-head-title">Passengers</span>
      </div>
      <table class="pax-table">
        <thead>
          <tr>
            <th style="width:10mm;text-align:center;">#</th>
            <th>Name</th>
          </tr>
        </thead>
        <tbody>
          <%if (passengers.isEmpty()) {
              for (int pi = 1; pi <= Integer.parseInt(seats.equals("-")?"1":seats); pi++) {%>
          <tr>
            <td class="pax-no"><%=pi%></td>
            <td>&nbsp;</td>
          </tr>
          <%}} else { for (int pi = 0; pi < passengers.size(); pi++) {
              Vector prow = (Vector) passengers.get(pi);
              String pNo   = prow.get(0) != null ? String.valueOf(prow.get(0)) : String.valueOf(pi+1);
              String pName = prow.get(1) != null ? String.valueOf(prow.get(1)) : "";%>
          <tr>
            <td class="pax-no"><%=pNo%></td>
            <td><%=pName.isEmpty()?"&nbsp;":pName%></td>
          </tr>
          <%}}%>
        </tbody>
      </table>
    </div><!-- /pax-col -->

    <!-- Right: Payment Summary -->
    <%if (hasPaySummary) {%>
    <div class="txn-col">
      <div class="pay-summary">
        <div class="pay-summary-head"><span class="gold">&#9670;</span> Payment</div>
        <div class="pay-row pay-total">
          <span class="pay-row-lbl">Total</span>
          <span class="pay-row-amt">&#8377;&nbsp;<%=pf.format(grandTotal)%></span>
        </div>
        <div class="pay-row pay-paid">
          <span class="pay-row-lbl">Paid<%if(grandOnlinePaid>0.005&&grandCashPaid>0.005){%> <span style="font-size:7pt;font-weight:600;color:#64748b;">(Cash+Online)</span><%}else if(grandOnlinePaid>0.005){%> <span style="font-size:7pt;font-weight:600;color:#64748b;">(Online)</span><%}else if(grandCashPaid>0.005){%> <span style="font-size:7pt;font-weight:600;color:#64748b;">(Cash)</span><%}%></span>
          <span class="pay-row-amt">&#8377;&nbsp;<%=pf.format(grandPaid)%></span>
        </div>
        <div class="pay-row <%=grandBal <= 0.005 ? "pay-bal-ok" : "pay-bal-due"%>">
          <span class="pay-row-lbl"><%=grandBal <= 0.005 ? "&#10003; Settled" : "Balance"%></span>
          <span class="pay-row-amt">&#8377;&nbsp;<%=pf.format(Math.abs(grandBal))%></span>
        </div>
      </div>
    </div><!-- /txn-col -->
    <%}%>
  </div><!-- /pax-txn-grid -->

  <!-- ═══ FOOTER ═══ -->
  <div class="tk-footer">
    <div class="tk-footer-left">Booking #<%=bookingId%>&nbsp;|&nbsp;<%=bookDate%></div>
    <div class="tk-footer-mid">Thank you for choosing <%=shopName%></div>
    <div class="tk-footer-right">PNR: <%=pnrVal%></div>
  </div>
  <div class="jasxbill-promo">Powered by JASXBILL &mdash; Smart Billing Software &bull; 8667214152</div>

</div><!-- /ticket -->

<script>
window.addEventListener('load', function() {
    setTimeout(function() {
        window.addEventListener('afterprint', function() {
            if (window.opener) { window.opener.focus(); }
            window.close();
        }, { once: true });
        window.print();
    }, 400);
});
</script>
</body>
</html>
