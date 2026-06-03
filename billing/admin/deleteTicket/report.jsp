<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,java.text.SimpleDateFormat"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
String ctx = request.getContextPath();

String fromDate = request.getParameter("fromDate");
String toDate   = request.getParameter("toDate");
String today    = new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
if (fromDate == null || fromDate.isEmpty()) fromDate = today;
if (toDate   == null || toDate.isEmpty())   toDate   = today;

boolean searched = request.getParameter("fromDate") != null;
Vector logs = new Vector();
if (searched) {
    try { logs = billing.getTicketDeleteLog(fromDate, toDate); } catch(Exception e) {}
}
int total = logs.size();
java.text.DecimalFormat pf = new java.text.DecimalFormat("#,##0.00");
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Ticket Delete Log</title>
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
.fg-inp{height:33px;border:1.5px solid rgba(255,255,255,.25);border-radius:var(--r-sm);padding:0 9px;background:rgba(255,255,255,.12);color:#fff;font-size:13px;outline:none;transition:border-color .15s;}
.fg-inp::placeholder{color:rgba(255,255,255,.4);}
.fg-inp:focus{border-color:var(--gold);background:rgba(255,255,255,.18);}
.bb{display:inline-flex;align-items:center;gap:6px;height:33px;padding:0 15px;border-radius:var(--r-sm);font-size:12px;font-weight:700;cursor:pointer;border:1.5px solid transparent;transition:all .15s;white-space:nowrap;text-decoration:none;}
.bb-gold{background:var(--gold);color:#fff;border-color:var(--gold);}
.bb-gold:hover{background:#a87520;}
.sum-bar{background:var(--card);border:1px solid var(--border-l);border-radius:var(--r);box-shadow:var(--shadow);padding:10px 16px;margin-bottom:12px;display:flex;align-items:center;gap:12px;flex-wrap:wrap;}
.sum-chip{display:flex;align-items:center;gap:7px;padding:6px 14px;border-radius:6px;font-size:12px;font-weight:700;}
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
.rpt-table td.wrap{white-space:normal;max-width:200px;word-break:break-word;}
.sno{font-size:11px;color:var(--muted);font-weight:600;}
.empty-state{text-align:center;padding:50px 20px;color:var(--muted);}
.empty-state i{font-size:48px;color:#d1d9e6;margin-bottom:12px;display:block;}
.empty-state h3{font-size:15px;font-weight:700;margin-bottom:6px;}
.del-badge{display:inline-flex;align-items:center;gap:4px;padding:2px 9px;border-radius:3px;font-size:10px;font-weight:800;background:#fce8e8;color:#b71c1c;border:1px solid #ffcdd2;}
.amt{font-weight:700;font-size:12px;}
</style>
</head>
<body>
<div class="tw">
  <div class="tw-nav"><%@ include file="/assets/navbar/navbar.jsp" %></div>

  <!-- HEADER -->
  <div class="tb-header">
    <div class="tb-header-title">
      <i class="fa-solid fa-clock-rotate-left"></i>
      <span>Ticket Delete Log</span>
    </div>
    <div class="tb-divider"></div>
    <form method="get" action="" style="display:flex;align-items:flex-end;gap:8px;flex-wrap:wrap;">
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
    <a href="<%=ctx%>/admin/deleteTicket/page.jsp" class="bb" style="background:rgba(255,255,255,.15);color:#fff;border-color:rgba(255,255,255,.3);">
      <i class="fa-solid fa-trash-can"></i> Delete Ticket
    </a>
  </div>

  <!-- BODY -->
  <div class="tw-body">
    <%if (!searched) {%>
    <div class="empty-state">
      <i class="fa-solid fa-clock-rotate-left"></i>
      <h3>Select a date range to view the delete log</h3>
    </div>
    <%} else if (total == 0) {%>
    <div class="empty-state">
      <i class="fa-solid fa-check-circle" style="color:#d1d9e6;"></i>
      <h3>No deleted tickets found for selected dates</h3>
    </div>
    <%} else {%>

    <div class="sum-bar">
      <div class="sum-chip chip-red">
        <i class="fa-solid fa-trash-can"></i> <%=total%> deleted ticket<%=total!=1?"s":""%>
      </div>
    </div>

    <div class="tbl-wrap">
      <table class="rpt-table">
        <thead>
          <tr>
            <th>#</th>
            <th>Booking ID</th>
            <th>Ticket No / PNR</th>
            <th>Booking Date</th>
            <th>Route</th>
            <th>Travel Date</th>
            <th>Passengers</th>
            <th>Seats</th>
            <th>Buy Agent</th>
            <th>Buy Amt</th>
            <th>Sell Agent</th>
            <th>Sell Amt</th>
            <th>Customer</th>
            <th>Cust Amt</th>
            <th>Deleted By</th>
            <th>Deleted At</th>
          </tr>
        </thead>
        <tbody>
        <%
        for (int i = 0; i < logs.size(); i++) {
            Vector r = (Vector) logs.get(i);
            // [0]id [1]booking_id [2]ticket_no [3]pnr [4]booking_date
            // [5]oneway_from [6]oneway_to [7]oneway_travel_date
            // [8]passenger_names [9]buy_agent [10]buy_amount
            // [11]sell_agent [12]sell_amount [13]customer_name [14]customer_amount
            // [15]no_of_seats [16]deleted_by_name [17]deleted_at
            String logId     = r.get(0)  != null ? r.get(0).toString() : "";
            String bId       = r.get(1)  != null ? r.get(1).toString() : "-";
            String tktNo     = r.get(2)  != null ? r.get(2).toString() : "";
            String pnr       = r.get(3)  != null ? r.get(3).toString() : "-";
            String bDate     = r.get(4)  != null ? r.get(4).toString() : "-";
            String owFrom    = r.get(5)  != null ? r.get(5).toString() : "-";
            String owTo      = r.get(6)  != null ? r.get(6).toString() : "-";
            String owDate    = r.get(7)  != null ? r.get(7).toString() : "-";
            String paxNames  = r.get(8)  != null ? r.get(8).toString() : "";
            String buyAgent  = r.get(9)  != null ? r.get(9).toString() : "";
            String buyAmt    = r.get(10) != null ? r.get(10).toString() : "0";
            String sellAgent = r.get(11) != null ? r.get(11).toString() : "";
            String sellAmt   = r.get(12) != null ? r.get(12).toString() : "0";
            String custName  = r.get(13) != null ? r.get(13).toString() : "";
            String custAmt   = r.get(14) != null ? r.get(14).toString() : "0";
            String seats     = r.get(15) != null ? r.get(15).toString() : "-";
            String delBy     = r.get(16) != null ? r.get(16).toString() : "-";
            String delAt     = r.get(17) != null ? r.get(17).toString() : "-";
            String displayTkt = (!tktNo.isEmpty() ? tktNo + " / " : "") + pnr;
            try { buyAmt  = pf.format(Double.parseDouble(buyAmt));  } catch(Exception e){}
            try { sellAmt = pf.format(Double.parseDouble(sellAmt)); } catch(Exception e){}
            try { custAmt = pf.format(Double.parseDouble(custAmt)); } catch(Exception e){}
        %>
        <tr>
          <td class="sno"><%=i+1%></td>
          <td><strong>#<%=bId%></strong></td>
          <td><%=displayTkt%></td>
          <td><%=bDate%></td>
          <td><%=owFrom%> &#8594; <%=owTo%></td>
          <td><%=owDate%></td>
          <td class="wrap" style="max-width:160px;"><%=paxNames.isEmpty()?"—":paxNames%></td>
          <td style="text-align:center;"><%=seats%></td>
          <td><%=buyAgent.isEmpty()?"—":buyAgent%></td>
          <td class="amt" style="color:#2e7d32;"><%=buyAgent.isEmpty()?"—":"₹"+buyAmt%></td>
          <td><%=sellAgent.isEmpty()?"—":sellAgent%></td>
          <td class="amt" style="color:#1a237e;"><%=sellAgent.isEmpty()?"—":"₹"+sellAmt%></td>
          <td><%=custName.isEmpty()?"—":custName%></td>
          <td class="amt" style="color:#b45309;"><%=custName.isEmpty()?"—":"₹"+custAmt%></td>
          <td><span class="del-badge"><i class="fa-solid fa-user"></i> <%=delBy%></span></td>
          <td style="font-size:11px;color:var(--muted);"><%=delAt%></td>
        </tr>
        <%}%>
        </tbody>
      </table>
    </div>
    <%}%>
  </div>
</div>
</body>
</html>
