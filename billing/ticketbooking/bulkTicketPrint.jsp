<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<jsp:useBean id="userB"   class="user.userBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }

String dateType = request.getParameter("dateType");
String fromDate = request.getParameter("fromDate");
String toDate   = request.getParameter("toDate");
String pmFilter = request.getParameter("pmFilter");
if (dateType == null || dateType.isEmpty()) dateType = "booking";
int pmFilterId = 0;
try { if (pmFilter != null && !pmFilter.isEmpty()) pmFilterId = Integer.parseInt(pmFilter); } catch (Exception e) {}

String today = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
if (fromDate == null || fromDate.isEmpty()) fromDate = today;
if (toDate   == null || toDate.isEmpty())   toDate   = today;

// Company details – fetched once
Vector compVec = new Vector();
try { compVec = userB.getCompanyDetails(); } catch (Exception e) {}
String shopName = compVec.size() > 1 && compVec.get(1) != null ? String.valueOf(compVec.get(1)) : "Moulana Travels";
String address  = compVec.size() > 2 && compVec.get(2) != null ? String.valueOf(compVec.get(2)) : "";
String gstin    = compVec.size() > 3 && compVec.get(3) != null ? String.valueOf(compVec.get(3)) : "";

Vector reportData = billing.getTicketReport(dateType, fromDate, toDate, pmFilterId);
String ctx = request.getContextPath();
java.text.DecimalFormat pf = new java.text.DecimalFormat("#,##0.00");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Bulk Tickets – <%=fromDate%> to <%=toDate%></title>
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
    background: #e8ecf3;
}

/* ── NO-PRINT TOOLBAR ── */
.no-print {
    display: flex; gap: 8px; justify-content: center;
    padding: 10px; background: #1a2744;
    position: sticky; top: 0; z-index: 100;
}
.no-print button {
    padding: 7px 18px; border: none; border-radius: 5px;
    font-size: 12px; font-weight: 700; cursor: pointer;
}
.btn-print { background: #c9922a; color: #fff; }
.btn-close  { background: #e2e8f0; color: #475569; }
.no-print .info { color: rgba(255,255,255,.7); font-size: 12px; align-self: center; margin-left: 10px; }
@media print {
    .no-print { display: none !important; }
    body { background: #fff; }
}

/* ── TICKET WRAPPER ── */
.ticket {
    width: 148mm;
    min-height: 210mm;
    display: flex;
    flex-direction: column;
    border: 1.5pt solid #1a2744;
    overflow: hidden;
    margin: 12px auto;
    background: #fff;
    page-break-after: always;
}
.ticket:last-of-type { page-break-after: avoid; }
@media print { .ticket { margin: 0 auto; } }

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

/* ── INFO ROW ── */
.tk-info-bar {
    background: #f1f5f9;
    display: flex;
    padding: 2.5mm 5mm;
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
.sec-head-icon  { font-size: 9pt; color: #5c4d8a; }
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

/* ── SIDE-BY-SIDE PAX + PAYMENT ── */
.pax-txn-grid { display: flex; border-top: 1pt solid #e2e8f0; }
.pax-col { flex: 3; border-right: 1pt solid #e2e8f0; min-width: 0; }
.txn-col { flex: 2; min-width: 0; }
.pax-col .sec-head,
.txn-col .sec-head { border-top: none; }

/* ── PAYMENT SUMMARY BOX ── */
.pay-summary { border-top: 1pt solid #1a2744; overflow: hidden; }
.pay-summary-head {
    background: #1a2744; color: #fff;
    font-size: 7pt; font-weight: 800; text-transform: uppercase; letter-spacing: .6pt;
    padding: 1.5mm 3mm; display: flex; align-items: center; gap: 2mm;
}
.pay-summary-head .gold { color: #c9922a; }
.pay-row {
    display: flex; justify-content: space-between; align-items: center;
    padding: 1.5mm 3mm; border-bottom: 1pt solid #e8edf5; font-size: 8pt;
}
.pay-row:last-child { border-bottom: none; }
.pay-row-lbl { color: #475569; font-weight: 600; }
.pay-row-amt { font-weight: 800; }
.pay-total { background: #f8fafc; }
.pay-total .pay-row-lbl { color: #1a2744; font-weight: 700; }
.pay-total .pay-row-amt { color: #1a2744; font-size: 9pt; }
.pay-paid .pay-row-amt  { color: #059669; }
.pay-bal-ok  { background: #f0fdf4; }
.pay-bal-due { background: #fff7ed; }
.pay-bal-ok  .pay-row-lbl { color: #059669; font-weight: 700; }
.pay-bal-due .pay-row-lbl { color: #d97706; font-weight: 700; }
.pay-bal-ok  .pay-row-amt { color: #059669; font-size: 9pt; }
.pay-bal-due .pay-row-amt { color: #d97706; font-size: 9pt; }
.pay-mode-row {
    padding: 0.8mm 3mm 1mm 6mm; font-size: 7.5pt;
    border-bottom: 1pt solid #e8edf5;
    display: flex; justify-content: space-between;
}
.pay-mode-cash   .pay-row-lbl, .pay-mode-cash   .pay-row-amt { color: #2e7d32; font-size: 7.5pt; }
.pay-mode-online .pay-row-lbl, .pay-mode-online .pay-row-amt { color: #0d47a1; font-size: 7.5pt; }
.pay-mode-txn { padding: 0.3mm 3mm 1mm 8mm; font-size: 6.5pt; color: #5c4d8a; font-style: italic; border-bottom: 1pt solid #e8edf5; }

/* ── COMPACT FOR RETURN TICKETS ── */
.has-ret .flt-from, .has-ret .flt-to { font-size: 13pt; }
.has-ret .flt-table .flt-route td { padding: 2mm 4mm 1.5mm; }
.has-ret .flt-table td { padding: 1.5mm 4mm; }
.has-ret .sec-head { padding: 1.5mm 5mm 1mm; }

/* ── FOOTER ── */
.tk-footer {
    margin-top: auto;
    background: linear-gradient(135deg, #1a2744 0%, #243159 100%);
    padding: 3mm 5mm;
    display: flex; justify-content: space-between; align-items: center;
}
.tk-footer-left  { color: rgba(255,255,255,.65); font-size: 7pt; }
.tk-footer-right { color: rgba(255,255,255,.65); font-size: 7pt; text-align: right; }
.tk-footer-mid   { color: #c9922a; font-size: 8pt; font-weight: 800; letter-spacing: .3pt; text-align: center; }
.jasxbill-promo {
    text-align: right; padding: 1mm 3mm 1.5mm;
    font-size: 5.5pt; color: #94a3b8; letter-spacing: .2pt;
}
</style>
</head>
<body>

<!-- Toolbar – hidden on print -->
<div class="no-print">
  <button class="btn-print" onclick="window.print()">&#9113; Print / Save as PDF</button>
  <button class="btn-close"  onclick="window.close()">&#10005; Close</button>
  <span class="info"><%=reportData.size()%> ticket(s) &nbsp;|&nbsp; <%=fromDate%> to <%=toDate%></span>
</div>

<%
if (reportData.isEmpty()) {
%>
<div style="text-align:center;padding:60px 20px;color:#64748b;font-family:'Segoe UI',sans-serif;">
  <div style="font-size:48px;margin-bottom:12px;">&#128230;</div>
  <div style="font-size:16px;font-weight:700;">No tickets found for selected filter</div>
</div>
<%
} else {
  for (int ri = 0; ri < reportData.size(); ri++) {
    Vector rr = (Vector) reportData.get(ri);
    int bookingId = 0;
    try { bookingId = Integer.parseInt(String.valueOf(rr.get(0))); } catch (Exception e) { continue; }

    Vector bookingResult = billing.getTicketById(bookingId);
    if (bookingResult.isEmpty()) continue;
    Vector row       = (Vector) bookingResult.get(0);
    Vector passengers = billing.getPNRPassengers(bookingId);

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
    String sellAmt     = row.get(21) != null ? String.valueOf(row.get(21)) : "";
    String custAmt     = row.get(24) != null ? String.valueOf(row.get(24)) : "";
    String ticketNo    = row.get(27) != null ? String.valueOf(row.get(27)) : "";

    double totalSell  = sellAmt.isEmpty() ? 0.0 : Double.parseDouble(sellAmt.replaceAll("[^\\d.]",""));
    double totalCust  = custAmt.isEmpty() ? 0.0 : Double.parseDouble(custAmt.replaceAll("[^\\d.]",""));
    double grandTotal = totalSell + totalCust;
    boolean hasRet    = retDate != null && !retDate.trim().isEmpty();
    boolean hasPaySummary = grandTotal > 0;

    // Ledger – payment breakdown
    Vector ledHist = new Vector();
    try { ledHist = billing.getTicketLedgerByBookingId(bookingId); } catch (Exception e) {}
    double grandCashPaid = 0, grandOnlinePaid = 0;
    String lastOnlineTxnNo = "";
    for (int li = 0; li < ledHist.size(); li++) {
        Vector lh  = (Vector) ledHist.get(li);
        String lPT = lh.get(1) != null ? lh.get(1).toString() : "";
        String lMod = lh.get(6) != null ? lh.get(6).toString() : "";
        String lTxn = lh.get(7) != null ? lh.get(7).toString() : "";
        double lAmt = lh.get(5) != null ? Double.parseDouble(lh.get(5).toString()) : 0;
        if (lAmt > 0 && !"BUY_AGENT".equals(lPT)) {
            if (lMod.toLowerCase().contains("cash")) grandCashPaid += lAmt;
            else { grandOnlinePaid += lAmt; if (!lTxn.isEmpty()) lastOnlineTxnNo = lTxn; }
        }
    }
    double grandPaid = grandCashPaid + grandOnlinePaid;
    double grandBal  = grandTotal - grandPaid;
%>

<div class="ticket <%=hasRet?"has-ret":""%>">

  <!-- ═══ HEADER ═══ -->
  <div class="tk-header">
    <img src="<%=ctx%>/ticketbooking/logo.png" class="tk-logo" alt="logo" onerror="this.style.display='none'">
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

  <!-- ═══ TICKET-RECEIPT LABEL ═══ -->
  <div style="background:#1a2744;text-align:center;padding:2mm 0;border-top:1pt solid #c9922a;border-bottom:1pt solid #c9922a;">
    <span style="color:#c9922a;font-size:10pt;font-weight:900;letter-spacing:2pt;text-transform:uppercase;">Ticket-Receipt</span>
  </div>

  <!-- ═══ BOOKING INFO BAR ═══ -->
  <div class="tk-info-bar">
    <div class="tk-info-item"><div class="tk-info-lbl">Booking ID</div><div class="tk-info-val">#<%=bookingId%></div></div>
    <div class="tk-info-item"><div class="tk-info-lbl">Booking Date</div><div class="tk-info-val"><%=bookDate%></div></div>
    <div class="tk-info-item"><div class="tk-info-lbl">Passengers</div><div class="tk-info-val"><%=seats%></div></div>
    <div class="tk-info-item"><div class="tk-info-lbl">Phone</div><div class="tk-info-val"><%=phone.equals("-")?"—":phone%></div></div>
  </div>

  <!-- ═══ ONE WAY ═══ -->
  <div class="sec-head">
    <span class="sec-head-icon">&#9992;</span>
    <span class="sec-head-title">One Way</span>
    <span class="sec-head-badge"><%=owDate%><%=!owTime.isEmpty()?" &nbsp;"+owTime:""%></span>
  </div>
  <table class="flt-table">
    <tr class="flt-route">
      <td style="text-align:left;"><div class="flt-from"><%=owFrom%></div><div class="flt-city">Origin</div></td>
      <td style="text-align:center;vertical-align:middle;"><span class="flt-arrow">&#10230;</span></td>
      <td style="text-align:right;"><div class="flt-to"><%=owTo%></div><div class="flt-city">Destination</div></td>
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
      <td style="text-align:left;"><div class="flt-from"><%=retFrom.isEmpty()?"-":retFrom%></div><div class="flt-city">Origin</div></td>
      <td style="text-align:center;vertical-align:middle;"><span class="flt-arrow">&#10230;</span></td>
      <td style="text-align:right;"><div class="flt-to"><%=retTo.isEmpty()?"-":retTo%></div><div class="flt-city">Destination</div></td>
    </tr>
    <tr class="flt-detail-row">
      <td><div class="flt-lbl">Flight No</div><div class="flt-val"><%=retFlight.isEmpty()?"—":retFlight%></div></td>
      <td style="text-align:center;"><div class="flt-lbl">Airlines</div><div class="flt-val"><%=retAirlines.isEmpty()?"—":retAirlines%></div></td>
      <td style="text-align:right;"><div class="flt-lbl">Return Date</div><div class="flt-val"><%=retDate%><%=!retTime.isEmpty()?" "+retTime:""%></div></td>
    </tr>
  </table>
  <%}%>

  <!-- ═══ PASSENGERS + PAYMENT (side-by-side) ═══ -->
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
          <tr><td class="pax-no"><%=pi%></td><td>&nbsp;</td></tr>
          <%} } else {
              for (int pi = 0; pi < passengers.size(); pi++) {
                  Vector prow = (Vector) passengers.get(pi);
                  String pNo   = prow.get(0) != null ? String.valueOf(prow.get(0)) : String.valueOf(pi+1);
                  String pName = prow.get(1) != null ? String.valueOf(prow.get(1)) : "";
          %>
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
        <%if (grandCashPaid > 0.005 && grandOnlinePaid > 0.005) {%>
        <div class="pay-row pay-paid">
          <span class="pay-row-lbl">Paid <span style="font-size:7pt;font-weight:600;color:#64748b;">(Cash+Online)</span></span>
          <span class="pay-row-amt">&#8377;&nbsp;<%=pf.format(grandPaid)%></span>
        </div>
        <div class="pay-mode-row pay-mode-cash">
          <span class="pay-row-lbl">&#8213; Cash</span>
          <span class="pay-row-amt">&#8377;&nbsp;<%=pf.format(grandCashPaid)%></span>
        </div>
        <div class="pay-mode-row pay-mode-online">
          <span class="pay-row-lbl">&#8213; Online</span>
          <span class="pay-row-amt">&#8377;&nbsp;<%=pf.format(grandOnlinePaid)%></span>
        </div>
        <%} else {%>
        <div class="pay-row pay-paid">
          <span class="pay-row-lbl">Paid<%if(grandOnlinePaid>0.005){%> <span style="font-size:7pt;font-weight:600;color:#64748b;">(Online)</span><%}else if(grandCashPaid>0.005){%> <span style="font-size:7pt;font-weight:600;color:#64748b;">(Cash)</span><%}%></span>
          <span class="pay-row-amt">&#8377;&nbsp;<%=pf.format(grandPaid)%></span>
        </div>
        <%}%>
        <div class="pay-row <%=grandBal <= 0.005 ? "pay-bal-ok" : "pay-bal-due"%>">
          <span class="pay-row-lbl">Balance</span>
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

<% } // end for loop
} // end else
%>

<script>
window.addEventListener('afterprint', function() { window.close(); });
window.addEventListener('load', function() {
    setTimeout(function() { window.print(); }, 600);
});
</script>
</body>
</html>
