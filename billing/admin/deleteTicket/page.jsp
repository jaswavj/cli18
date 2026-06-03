<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,java.text.SimpleDateFormat"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
String ctx = request.getContextPath();

String dateType = request.getParameter("dateType");
String fromDate = request.getParameter("fromDate");
String toDate   = request.getParameter("toDate");
if (dateType == null || dateType.isEmpty()) dateType = "booking";
String today = new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
if (fromDate == null || fromDate.isEmpty()) fromDate = today;
if (toDate   == null || toDate.isEmpty())   toDate   = today;

// Flash message from delete action
String flashMsg = (String) session.getAttribute("flashMsg");
if (flashMsg != null) session.removeAttribute("flashMsg");

boolean searched = request.getParameter("fromDate") != null;
Vector rows = new Vector();
if (searched) {
    rows = billing.getTicketReport(dateType, fromDate, toDate, 0);
}
int total = rows.size();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Delete Ticket</title>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<%@ include file="/assets/common/head.jsp" %>
<style>
:root{--navy:#1a2744;--navy2:#243159;--gold:#c9922a;--violet:#5c4d8a;--bg:#eef1f7;--card:#fff;--border:#d1d9e6;--border-l:#e8edf5;--text:#0f172a;--muted:#64748b;--green:#059669;--red:#dc2626;--r:8px;--r-sm:5px;--shadow:0 2px 12px rgba(0,0,0,.10);}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
html,body{height:100%;font-family:'Segoe UI',system-ui,sans-serif;font-size:13px;background:var(--bg);color:var(--text);}
.tw{display:flex;flex-direction:column;height:100vh;height:100dvh;overflow:hidden;}
.tw-nav{flex-shrink:0;}
.tw-body{flex:1;min-height:0;overflow-y:auto;padding:14px;}
.tw-body::-webkit-scrollbar{width:5px;}
.tw-body::-webkit-scrollbar-thumb{background:var(--violet);border-radius:3px;}
.tb-header{background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);padding:10px 16px;display:flex;align-items:center;gap:10px;flex-wrap:wrap;box-shadow:0 2px 8px rgba(0,0,0,.25);flex-shrink:0;}
.tb-header-title{display:flex;align-items:center;gap:9px;color:#fff;font-size:15px;font-weight:800;letter-spacing:.4px;}
.tb-header-title i{color:var(--gold);font-size:17px;}
.tb-divider{width:1px;height:28px;background:rgba(255,255,255,.2);}
.hdr-spacer{flex:1;}
.fg{display:flex;flex-direction:column;gap:3px;min-width:0;}
.fg-lbl{font-size:10px;font-weight:700;color:rgba(255,255,255,.7);text-transform:uppercase;letter-spacing:.5px;}
.fg-inp,.fg-sel{height:33px;border:1.5px solid rgba(255,255,255,.25);border-radius:var(--r-sm);padding:0 9px;background:rgba(255,255,255,.12);color:#fff;font-size:13px;outline:none;transition:border-color .15s;}
.fg-inp::placeholder{color:rgba(255,255,255,.4);}
.fg-inp:focus,.fg-sel:focus{border-color:var(--gold);background:rgba(255,255,255,.18);}
.fg-sel option{background:var(--navy);}
.bb{display:inline-flex;align-items:center;gap:6px;height:33px;padding:0 15px;border-radius:var(--r-sm);font-size:12px;font-weight:700;cursor:pointer;border:1.5px solid transparent;transition:all .15s;white-space:nowrap;text-decoration:none;}
.bb-gold{background:var(--gold);color:#fff;border-color:var(--gold);}
.bb-gold:hover{background:#a87520;}
.bb-red{background:var(--red);color:#fff;border-color:var(--red);}
.bb-red:hover{background:#b91c1c;}
.sum-bar{background:var(--card);border:1px solid var(--border-l);border-radius:var(--r);box-shadow:var(--shadow);padding:10px 16px;margin-bottom:12px;display:flex;align-items:center;gap:12px;flex-wrap:wrap;}
.sum-chip{display:flex;align-items:center;gap:7px;padding:6px 14px;border-radius:6px;font-size:12px;font-weight:700;}
.chip-violet{background:#f0edf8;color:var(--violet);}
.chip-red{background:#fce8e8;color:#b71c1c;}
.tbl-wrap{overflow-x:auto;border-radius:var(--r);box-shadow:var(--shadow);}
.rpt-table{width:100%;border-collapse:collapse;background:var(--card);font-size:12px;}
.rpt-table thead tr{background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);}
.rpt-table thead th{color:#fff;padding:9px 10px;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;white-space:nowrap;border-right:1px solid rgba(255,255,255,.1);}
.rpt-table thead th:first-child{border-radius:var(--r) 0 0 0;}
.rpt-table thead th:last-child{border-right:none;border-radius:0 var(--r) 0 0;}
.rpt-table tbody tr{border-bottom:1px solid var(--border-l);transition:background .1s;}
.rpt-table tbody tr:hover{background:#fef2f2;}
.rpt-table tbody tr:last-child{border-bottom:none;}
.rpt-table td{padding:8px 10px;vertical-align:middle;white-space:nowrap;}
.sno{font-size:11px;color:var(--muted);font-weight:600;}
.empty-state{text-align:center;padding:50px 20px;color:var(--muted);}
.empty-state i{font-size:48px;color:#d1d9e6;margin-bottom:12px;display:block;}
.empty-state h3{font-size:15px;font-weight:700;margin-bottom:6px;}
.del-btn{display:inline-flex;align-items:center;gap:5px;padding:4px 12px;border:none;border-radius:4px;background:#dc2626;color:#fff;font-size:11px;font-weight:700;cursor:pointer;transition:background .15s;}
.del-btn:hover{background:#b91c1c;}
.warn-banner{background:#fff7ed;border:1px solid #fed7aa;border-radius:var(--r);padding:10px 16px;margin-bottom:12px;display:flex;align-items:center;gap:9px;color:#c2410c;font-size:12px;font-weight:600;}
.warn-banner i{font-size:15px;}
</style>
</head>
<body>
<div class="tw">
  <div class="tw-nav"><%@ include file="/assets/navbar/navbar.jsp" %></div>

  <!-- HEADER -->
  <div class="tb-header">
    <div class="tb-header-title">
      <i class="fa-solid fa-trash-can"></i>
      <span>Delete Ticket</span>
    </div>
    <div class="tb-divider"></div>
    <form method="get" action="" style="display:flex;align-items:flex-end;gap:8px;flex-wrap:wrap;">
      <div class="fg">
        <label class="fg-lbl">Date Type</label>
        <select name="dateType" class="fg-sel">
          <option value="booking" <%="booking".equals(dateType)?"selected":""%>>Booking Date</option>
          <option value="travel"  <%="travel".equals(dateType)?"selected":""%>>Travel Date</option>
        </select>
      </div>
      <div class="fg">
        <label class="fg-lbl">From</label>
        <input type="date" name="fromDate" class="fg-inp" value="<%=fromDate%>">
      </div>
      <div class="fg">
        <label class="fg-lbl">To</label>
        <input type="date" name="toDate" class="fg-inp" value="<%=toDate%>">
      </div>
      <button type="submit" class="bb bb-gold"><i class="fa-solid fa-magnifying-glass"></i> Search</button>
    </form>
    <div class="hdr-spacer"></div>
    <a href="<%=ctx%>/admin/deleteTicket/report.jsp" class="bb" style="background:rgba(255,255,255,.15);color:#fff;border-color:rgba(255,255,255,.3);">
      <i class="fa-solid fa-clock-rotate-left"></i> Delete Log
    </a>
  </div>

  <!-- BODY -->
  <div class="tw-body">
    <%if (!searched) {%>
    <div class="empty-state">
      <i class="fa-solid fa-trash-can"></i>
      <h3>Select a date range to search tickets</h3>
      <p style="font-size:12px;">Choose booking or travel date and press Search</p>
    </div>
    <%} else {%>

    <div class="warn-banner">
      <i class="fa-solid fa-triangle-exclamation"></i>
      Deleting a ticket is permanent. The booking, all ledger entries and passengers will be removed. A log entry will be saved.
    </div>

    <div class="sum-bar">
      <div class="sum-chip chip-violet">
        <i class="fa-solid fa-ticket"></i> <%=total%> ticket<%=total!=1?"s":""%> found
      </div>
      <%if (total > 0) {%>
      <div class="sum-chip chip-red">
        <i class="fa-solid fa-trash-can"></i> Click Delete to remove a ticket permanently
      </div>
      <%}%>
    </div>

    <%if (total == 0) {%>
    <div class="empty-state">
      <i class="fa-solid fa-plane-slash"></i>
      <h3>No tickets found for selected date range</h3>
    </div>
    <%} else {%>
    <div class="tbl-wrap">
      <table class="rpt-table">
        <thead>
          <tr>
            <th>Action</th>
            <th>PNR / Ticket No</th>
            <th>Booking Date</th>
            <th>Route</th>
            <th>Travel Date</th>
            <th>Passengers</th>
            <th>Buy Agent</th>
            <th>Sell Agent</th>
            <th>Customer</th>
          </tr>
        </thead>
        <tbody>
        <%
        for (int i = 0; i < rows.size(); i++) {
            Vector r = (Vector) rows.get(i);
            String bId      = r.get(0) != null ? r.get(0).toString() : "";
            String pnr      = r.get(1) != null ? r.get(1).toString() : "-";
            String bDate    = r.get(2) != null ? r.get(2).toString() : "-";
            String owDate   = r.get(3) != null ? r.get(3).toString() : "-";
            String owFrom   = r.get(5) != null ? r.get(5).toString() : "";
            String owTo     = r.get(6) != null ? r.get(6).toString() : "";
            String seats    = r.get(15)!= null ? r.get(15).toString() : "-";
            String buyAgent = r.get(17)!= null ? r.get(17).toString() : "-";
            String sellAmt  = r.get(21)!= null ? r.get(21).toString() : "";
            String sellAg   = r.get(20)!= null ? r.get(20).toString() : "";
            String custName = r.get(23)!= null ? r.get(23).toString() : "-";
            String tktNo    = r.get(27)!= null ? r.get(27).toString() : "";
            String displayPnr = (!tktNo.isEmpty() ? tktNo + " / " : "") + pnr;
        %>
        <tr>
          <td>
            <button class="del-btn" onclick="confirmDelete(<%=bId%>,'<%=pnr.replace("'","")%>')">
              <i class="fa-solid fa-trash-can"></i> Delete #<%=bId%>
            </button>
          </td>
          <td><%=displayPnr%></td>
          <td><%=bDate%></td>
          <td><%=owFrom%> &#8594; <%=owTo%></td>
          <td><%=owDate%></td>
          <td style="text-align:center;"><%=seats%></td>
          <td><%=buyAgent.equals("-")||buyAgent.isEmpty()?"—":buyAgent%></td>
          <td><%=sellAg.isEmpty()||sellAg.equals("-")?"—":sellAg%></td>
          <td><%=custName.equals("-")||custName.isEmpty()?"—":custName%></td>
        </tr>
        <%}%>
        </tbody>
      </table>
    </div>
    <%}%>
    <%}%>
  </div>
</div>

<!-- Hidden delete form -->
<form id="deleteForm" action="<%=ctx%>/admin/deleteTicket/deleteAction.jsp" method="post" style="display:none;">
  <input type="hidden" name="bookingId" id="delBookingId">
  <input type="hidden" name="fromDate"  value="<%=fromDate%>">
  <input type="hidden" name="toDate"    value="<%=toDate%>">
  <input type="hidden" name="dateType"  value="<%=dateType%>">
</form>

<script>
function confirmDelete(bookingId, pnr) {
  Swal.fire({
    icon: 'warning',
    title: 'Delete Ticket?',
    html: '<b>Booking #' + bookingId + '</b> (PNR: ' + pnr + ')<br><span style="color:#dc2626;font-size:13px;">This will permanently delete the booking, all ledger entries and passenger records.</span>',
    showCancelButton: true,
    confirmButtonColor: '#dc2626',
    cancelButtonColor: '#64748b',
    confirmButtonText: 'Yes, Delete',
    cancelButtonText: 'Cancel'
  }).then(function(result) {
    if (result.isConfirmed) {
      document.getElementById('delBookingId').value = bookingId;
      document.getElementById('deleteForm').submit();
    }
  });
}
<%if (flashMsg != null && !flashMsg.isEmpty()) {
    String[] fp = flashMsg.split("\\|", 2);
    String fType = fp.length > 0 ? fp[0] : "info";
    String fText = fp.length > 1 ? fp[1].replace("'", "\\'") : "";
    String fIcon = "success".equals(fType) ? "success" : "error";
%>
window.addEventListener('DOMContentLoaded', function() {
  Swal.fire({ icon: '<%=fIcon%>', title: '<%="success".equals(fType)?"Deleted!":"Error"%>', text: '<%=fText%>', timer: 3000, showConfirmButton: false });
});
<%}%>
</script>
</body>
</html>
