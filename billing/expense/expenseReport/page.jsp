<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,java.text.SimpleDateFormat,java.text.DecimalFormat"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
String ctx = request.getContextPath();
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
String today = sdf.format(new java.util.Date());
String fromDate = request.getParameter("fromDate");
String toDate   = request.getParameter("toDate");
String expTypeFilter = request.getParameter("expenseType");
if (fromDate == null || fromDate.isEmpty()) fromDate = today;
if (toDate   == null || toDate.isEmpty())   toDate   = today;
if (expTypeFilter == null || expTypeFilter.isEmpty()) expTypeFilter = "0";
int expTypeId = 0;
try { expTypeId = Integer.parseInt(expTypeFilter); } catch (Exception e) {}
DecimalFormat df = new DecimalFormat("#,##0.00");
Vector expenseData = null;
double totalAmount = 0.0;
String selectedTypeName = "All Types";
try {
    expenseData = prod.getExpenseReport(fromDate, toDate, expTypeId);
    if (expTypeId != 0) {
        Vector expTypes = prod.getExpenseTypeList();
        for (int i = 0; i < expTypes.size(); i++) {
            Vector et = (Vector) expTypes.get(i);
            if (Integer.parseInt(et.elementAt(1).toString()) == expTypeId) { selectedTypeName = et.elementAt(0).toString(); break; }
        }
    }
    if (expenseData != null) {
        for (int i = 0; i < expenseData.size(); i++) {
            Vector row = (Vector) expenseData.get(i);
            if (row.size() > 4) totalAmount += Double.parseDouble(row.get(4).toString());
        }
    }
} catch (Exception e) { System.err.println("Expense report error: " + e.getMessage()); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Expense Report</title>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<%@ include file="/assets/common/head.jsp" %>
<style>
:root{
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
.rpt-hdr{flex-shrink:0;background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);padding:10px 16px;display:flex;align-items:center;gap:10px;flex-wrap:wrap;box-shadow:0 2px 8px rgba(0,0,0,.25);}
.rpt-title{display:flex;align-items:center;gap:9px;color:#fff;font-size:15px;font-weight:800;letter-spacing:.4px;flex-shrink:0;}
.rpt-title i{color:var(--gold);font-size:17px;}
.hdr-divider{width:1px;height:28px;background:rgba(255,255,255,.2);flex-shrink:0;}
.hdr-spacer{flex:1;}
.fg{display:flex;flex-direction:column;gap:3px;min-width:0;}
.fg-lbl{font-size:10px;font-weight:700;color:rgba(255,255,255,.7);text-transform:uppercase;letter-spacing:.5px;white-space:nowrap;}
.fg-inp,.fg-sel{height:33px;border:1.5px solid rgba(255,255,255,.25);border-radius:var(--r-sm);padding:0 9px;background:rgba(255,255,255,.12);color:#fff;font-size:13px;outline:none;}
.fg-inp:focus,.fg-sel:focus{border-color:var(--gold);background:rgba(255,255,255,.18);}
.fg-sel option{background:#1a2744;color:#fff;}
.bb{display:inline-flex;align-items:center;gap:6px;height:33px;padding:0 15px;border-radius:var(--r-sm);font-size:12px;font-weight:700;cursor:pointer;border:1.5px solid transparent;transition:all .15s;white-space:nowrap;}
.bb-gold{background:var(--gold);color:#fff;border-color:var(--gold);}
.bb-gold:hover{background:var(--gold-d);}
.bb-outline-white{background:transparent;color:#fff;border-color:rgba(255,255,255,.4);}
.bb-outline-white:hover{background:rgba(255,255,255,.1);}
.sum-row{display:flex;gap:10px;flex-wrap:wrap;margin-bottom:12px;}
.sum-chip{background:var(--card);border-radius:var(--r-sm);border:1px solid var(--border-l);padding:10px 16px;display:flex;flex-direction:column;gap:3px;min-width:130px;box-shadow:var(--shadow-sm);}
.sum-chip-lbl{font-size:10px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;}
.sum-chip-val{font-size:15px;font-weight:800;color:var(--navy);}
.tbl-wrap{overflow-x:auto;border-radius:var(--r);box-shadow:var(--shadow);}
.rpt-table{width:100%;border-collapse:collapse;background:var(--card);font-size:12px;}
.rpt-table thead tr{background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);}
.rpt-table thead th{color:#fff;padding:9px 10px;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;white-space:nowrap;border-right:1px solid rgba(255,255,255,.1);}
.rpt-table thead th:last-child{border-right:none;}
.rpt-table tbody tr{border-bottom:1px solid var(--border-l);transition:background .1s;}
.rpt-table tbody tr:hover{background:#f5f3fb;}
.rpt-table td{padding:8px 10px;vertical-align:middle;}
.rpt-table tfoot tr{background:#f8fafc;border-top:2px solid var(--navy);}
.rpt-table tfoot td{padding:8px 10px;font-weight:800;}
.badge-type{display:inline-block;padding:2px 9px;border-radius:3px;font-size:10px;font-weight:800;background:#e8f0fe;color:#1a56db;border:1px solid #c3d5fd;}
.empty-state{text-align:center;padding:50px 20px;color:var(--muted);}
.empty-state i{font-size:48px;color:#d1d9e6;margin-bottom:12px;display:block;}
@media print{.rpt-hdr .bb,.rpt-hdr form{display:none!important;}.tw{overflow:visible;height:auto;}.tw-body{overflow:visible;}}
</style>
</head>
<body>
<div class="tw">
  <div class="tw-nav"><%@ include file="/assets/navbar/navbar.jsp" %></div>

  <div class="rpt-hdr">
    <div class="rpt-title"><i class="fa-solid fa-chart-bar"></i><span>EXPENSE REPORT</span></div>
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
        <div class="fg-lbl">Expense Type</div>
        <select name="expenseType" class="fg-sel" style="width:160px;">
          <option value="0" <%=expTypeId==0?"selected":""%>>All Types</option>
          <%
          try {
            Vector expTypes = prod.getExpenseTypeList();
            for (int i = 0; i < expTypes.size(); i++) {
              Vector et = (Vector) expTypes.get(i);
              String tName = et.elementAt(0).toString();
              String tId   = et.elementAt(1).toString();
          %>
          <option value="<%=tId%>" <%=expTypeId==Integer.parseInt(tId)?"selected":""%>><%=tName%></option>
          <% } } catch (Exception e) {} %>
        </select>
      </div>
      <button type="submit" class="bb bb-gold"><i class="fa-solid fa-magnifying-glass"></i> Search</button>
    </form>
    <div class="hdr-spacer"></div>
    <%if (expenseData != null && expenseData.size() > 0) {%>
    <button class="bb bb-outline-white" onclick="window.print()"><i class="fa-solid fa-print"></i> Print</button>
    <%}%>
  </div>

  <div class="tw-body">
    <div class="sum-row">
      <div class="sum-chip">
        <div class="sum-chip-lbl">Total Entries</div>
        <div class="sum-chip-val" style="color:var(--violet);"><%=expenseData!=null?expenseData.size():0%></div>
      </div>
      <div class="sum-chip">
        <div class="sum-chip-lbl">Total Amount</div>
        <div class="sum-chip-val" style="color:var(--red);">&#8377;<%=df.format(totalAmount)%></div>
      </div>
      <div class="sum-chip">
        <div class="sum-chip-lbl">Expense Type</div>
        <div class="sum-chip-val" style="font-size:12px;"><%=selectedTypeName%></div>
      </div>
    </div>

    <%if (expenseData == null || expenseData.isEmpty()) {%>
    <div class="empty-state">
      <i class="fa-solid fa-chart-bar"></i>
      <h3 style="font-size:15px;font-weight:700;margin-bottom:6px;">No expense records found</h3>
      <p style="font-size:12px;">Select a date range and click Search</p>
    </div>
    <%} else {%>
    <div class="tbl-wrap">
      <table class="rpt-table">
        <thead>
          <tr>
            <th>#</th>
            <th>Date &amp; Time</th>
            <th>Expense Type</th>
            <th>Content</th>
            <th>Description</th>
            <th style="text-align:right;">Amount</th>
            <th>Entry By</th>
          </tr>
        </thead>
        <tbody>
        <%
        for (int i = 0; i < expenseData.size(); i++) {
          Vector row = (Vector) expenseData.get(i);
          String expDateTime   = row.get(0) != null ? row.get(0).toString() : "";
          String expTypeName   = row.get(1) != null ? row.get(1).toString() : "";
          String content       = row.get(2) != null ? row.get(2).toString() : "";
          String description   = row.get(3) != null ? row.get(3).toString() : "";
          double amount        = row.get(4) != null ? Double.parseDouble(row.get(4).toString()) : 0;
          String username      = row.get(5) != null ? row.get(5).toString() : "";
          String fmtDate = expDateTime;
          try { fmtDate = new SimpleDateFormat("dd MMM yyyy HH:mm").format(new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").parse(expDateTime)); } catch (Exception ep) {}
        %>
        <tr>
          <td style="color:var(--muted);"><%=i+1%></td>
          <td style="white-space:nowrap;color:var(--muted);font-size:11px;"><%=fmtDate%></td>
          <td><span class="badge-type"><%=expTypeName%></span></td>
          <td style="font-weight:600;"><%=content%></td>
          <td style="color:var(--muted);font-size:11px;"><%=description.isEmpty()?"<span style='color:var(--border);'>—</span>":description%></td>
          <td style="text-align:right;font-weight:800;color:var(--red);">&#8377;<%=df.format(amount)%></td>
          <td style="font-size:11px;color:var(--muted);"><i class="fa-solid fa-user" style="font-size:9px;"></i> <%=username%></td>
        </tr>
        <%}%>
        </tbody>
        <tfoot>
          <tr>
            <td colspan="5" style="color:var(--muted);text-align:right;">Grand Total</td>
            <td style="text-align:right;color:var(--red);font-size:13px;">&#8377;<%=df.format(totalAmount)%></td>
            <td></td>
          </tr>
        </tfoot>
      </table>
    </div>
    <%}%>
    <div style="height:20px;"></div>
  </div>
</div>
</body>
</html>
