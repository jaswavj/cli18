<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
String ctx = request.getContextPath();
java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
java.text.SimpleDateFormat ddf = new java.text.SimpleDateFormat("dd-MM-yyyy");

java.util.Calendar cal = java.util.Calendar.getInstance();
cal.set(java.util.Calendar.DAY_OF_MONTH, 1);
String defFrom = sdf.format(cal.getTime());
String defTo   = sdf.format(new java.util.Date());

String fromDate = request.getParameter("fromDate");
String toDate   = request.getParameter("toDate");
if (fromDate == null || fromDate.isEmpty()) fromDate = defFrom;
if (toDate   == null || toDate.isEmpty())   toDate   = defTo;

String fromDisp = "", toDisp = "";
try { fromDisp = ddf.format(sdf.parse(fromDate)); } catch(Exception e) { fromDisp = fromDate; }
try { toDisp   = ddf.format(sdf.parse(toDate));   } catch(Exception e) { toDisp   = toDate;   }

// Load via bean
Vector rows = billing.getServiceBillReport(fromDate, toDate);
int totalCount = rows.size();
double grandTotal = 0, grandPaid = 0, grandBalance = 0;
for (int i = 0; i < rows.size(); i++) {
    Vector r = (Vector) rows.get(i);
    try { grandTotal   += Double.parseDouble(r.get(5).toString()); } catch(Exception e) {}
    try { grandPaid    += Double.parseDouble(r.get(6).toString()); } catch(Exception e) {}
    try { grandBalance += Double.parseDouble(r.get(7).toString()); } catch(Exception e) {}
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Service Bill Report</title>
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
.tw-body{flex:1;min-height:0;overflow-y:auto;padding:14px;}
.tw-body::-webkit-scrollbar{width:5px;}
.tw-body::-webkit-scrollbar-thumb{background:var(--violet);border-radius:3px;}
.rpt-hdr{flex-shrink:0;background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);padding:8px 16px;display:flex;align-items:center;gap:10px;box-shadow:0 2px 8px rgba(0,0,0,.25);}
.rpt-hdr-title{display:flex;align-items:center;gap:9px;color:#fff;font-size:14px;font-weight:800;letter-spacing:.4px;}
.rpt-hdr-title i{color:var(--gold);}
.rpt-hdr-right{margin-left:auto;display:flex;gap:8px;align-items:center;}
.filter-bar{background:var(--card);border-bottom:1px solid var(--border-l);padding:10px 16px;display:flex;gap:12px;flex-wrap:wrap;align-items:flex-end;}
.fg{display:flex;flex-direction:column;gap:3px;}
.fg label{font-size:10px;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;}
.fg input,.fg select{height:32px;border:1.5px solid var(--border);border-radius:var(--r-sm);padding:0 10px;background:var(--inp-bg);color:var(--text);font-size:12px;outline:none;}
.fg input:focus,.fg select:focus{border-color:var(--violet);background:#fff;}
.bb{display:inline-flex;align-items:center;gap:5px;height:32px;padding:0 14px;border-radius:var(--r-sm);font-size:11px;font-weight:700;cursor:pointer;border:1.5px solid transparent;white-space:nowrap;text-decoration:none;}
.bb-violet{background:var(--violet);color:#fff;border-color:var(--violet);}
.bb-violet:hover{background:var(--violet-d);}
.bb-ghost{background:var(--inp-bg);color:var(--text);border-color:var(--border);}
.bb-ghost:hover{background:var(--border-l);}
.bb-navy{background:var(--navy);color:#fff;}
.bb-navy:hover{background:var(--navy2);}
/* Chips */
.chips{display:flex;gap:10px;flex-wrap:wrap;padding:10px 0 2px 0;}
.chip{background:var(--card);border:1px solid var(--border-l);border-radius:6px;padding:7px 14px;display:flex;flex-direction:column;gap:2px;min-width:120px;box-shadow:var(--shadow);}
.chip-lbl{font-size:10px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;}
.chip-val{font-size:17px;font-weight:900;color:var(--navy);}
.chip-val.green{color:var(--green);}
.chip-val.red{color:var(--red);}
.chip-val.gold{color:var(--gold);}
/* Table */
.rpt-table-wrap{background:var(--card);border-radius:var(--r);border:1px solid var(--border-l);overflow:hidden;box-shadow:var(--shadow);margin-top:10px;}
.rpt-table{width:100%;border-collapse:collapse;font-size:12px;}
.rpt-table thead tr{background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);}
.rpt-table thead th{color:#fff;padding:8px 10px;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;white-space:nowrap;}
.rpt-table tbody tr{border-bottom:1px solid var(--border-l);transition:background .12s;}
.rpt-table tbody tr:hover{background:#f0f4ff;}
.rpt-table tbody td{padding:8px 10px;vertical-align:middle;}
.rpt-table tfoot tr{background:var(--navy2);}
.rpt-table tfoot td{padding:8px 10px;color:#fff;font-weight:900;font-size:11px;}
.sn-badge{display:inline-block;background:var(--border-l);color:var(--muted);border-radius:4px;padding:1px 7px;font-size:10px;font-weight:700;}
.bill-badge{font-weight:800;color:var(--violet);}
.bal-zero{color:var(--green);font-weight:700;}
.bal-pos{color:var(--red);font-weight:700;}
.no-data{text-align:center;padding:30px;color:var(--muted);}
@media print{
    .tw-nav,.rpt-hdr .rpt-hdr-right,.filter-bar{display:none!important;}
    .tw,.tw-body{overflow:visible;height:auto;}
    body{background:#fff;}
}
</style>
</head>
<body>
<div class="tw">
  <div class="tw-nav"><%@ include file="/assets/navbar/navbar.jsp" %></div>

  <div class="rpt-hdr">
    <div class="rpt-hdr-title"><i class="fa-solid fa-file-invoice-dollar"></i><span>Service Bill Report</span></div>
    <div class="rpt-hdr-right">
      <a href="<%=ctx%>/serviceBill/page.jsp" class="bb bb-ghost" style="height:28px;font-size:11px;">
        <i class="fa-solid fa-plus"></i> New Bill
      </a>
      <button class="bb bb-ghost" style="height:28px;font-size:11px;" onclick="window.print()">
        <i class="fa-solid fa-print"></i> Print
      </button>
    </div>
  </div>

  <!-- Filter Bar -->
  <form method="get" action="">
  <div class="filter-bar">
    <div class="fg">
      <label>From Date</label>
      <input type="date" name="fromDate" value="<%=fromDate%>">
    </div>
    <div class="fg">
      <label>To Date</label>
      <input type="date" name="toDate" value="<%=toDate%>">
    </div>
    <button type="submit" class="bb bb-violet"><i class="fa-solid fa-magnifying-glass"></i> Search</button>
  </div>
  </form>

  <div class="tw-body">

    <!-- Summary Chips -->
    <div class="chips">
      <div class="chip"><div class="chip-lbl">Total Bills</div><div class="chip-val gold"><%=totalCount%></div></div>
      <div class="chip"><div class="chip-lbl">Total Amount</div><div class="chip-val">&#8377;<%=String.format("%.2f",grandTotal)%></div></div>
      <div class="chip"><div class="chip-lbl">Total Paid</div><div class="chip-val green">&#8377;<%=String.format("%.2f",grandPaid)%></div></div>
      <div class="chip"><div class="chip-lbl">Total Balance</div><div class="chip-val red">&#8377;<%=String.format("%.2f",grandBalance)%></div></div>
      <div class="chip" style="flex:1;background:transparent;border-color:transparent;box-shadow:none;justify-content:flex-end;flex-direction:row;align-items:center;">
        <span style="font-size:11px;color:var(--muted);font-weight:700;">Period: <strong style="color:var(--text);"><%=fromDisp%></strong> to <strong style="color:var(--text);"><%=toDisp%></strong></span>
      </div>
    </div>

    <!-- Table -->
    <div class="rpt-table-wrap">
      <table class="rpt-table">
        <thead><tr>
          <th>#</th>
          <th>Bill No</th>
          <th>Date</th>
          <th>Customer</th>
          <th>Phone</th>
          <th style="text-align:right;">Total (&#8377;)</th>
          <th style="text-align:right;">Paid (&#8377;)</th>
          <th style="text-align:right;">Balance (&#8377;)</th>
          <th>Pay Mode</th>
          <th style="text-align:center;">Action</th>
        </tr></thead>
        <tbody>
        <%if(rows.isEmpty()){%>
        <tr><td colspan="10" class="no-data"><i class="fa-solid fa-inbox"></i>&nbsp; No records found for the selected period.</td></tr>
        <%} else {%>
        <%int sn=0; for(int ri=0;ri<rows.size();ri++){ sn++;
            Vector row=(Vector)rows.get(ri);
            int rid        = row.get(0) != null ? Integer.parseInt(row.get(0).toString()) : 0;
            String rbillNo = row.get(1) != null ? row.get(1).toString() : "";
            String rdate   = row.get(2) != null ? row.get(2).toString() : "";
            String rcust   = row.get(3) != null ? row.get(3).toString() : "";
            String rphone  = row.get(4) != null ? row.get(4).toString() : "";
            double rtot    = row.get(5) != null ? Double.parseDouble(row.get(5).toString()) : 0;
            double rpaid   = row.get(6) != null ? Double.parseDouble(row.get(6).toString()) : 0;
            double rbal    = row.get(7) != null ? Double.parseDouble(row.get(7).toString()) : 0;
            String rpmode  = row.get(8) != null ? row.get(8).toString() : "";
        %>
        <tr>
          <td><span class="sn-badge"><%=sn%></span></td>
          <td><span class="bill-badge">#<%=rbillNo%></span></td>
          <td style="white-space:nowrap;"><%=rdate%></td>
          <td><%=rcust%></td>
          <td><%=rphone%></td>
          <td style="text-align:right;font-weight:700;"><%=String.format("%.2f",rtot)%></td>
          <td style="text-align:right;color:var(--green);font-weight:700;"><%=String.format("%.2f",rpaid)%></td>
          <td style="text-align:right;" class="<%=rbal>0?"bal-pos":"bal-zero"%>"><%=String.format("%.2f",rbal)%></td>
          <td><%=rpmode%></td>
          <td style="text-align:center;">
            <a href="<%=ctx%>/serviceBill/print.jsp?id=<%=rid%>" target="_blank" class="bb bb-navy" style="height:26px;padding:0 10px;font-size:10px;" title="View/Print">
              <i class="fa-solid fa-print"></i>
            </a>
          </td>
        </tr>
        <%}}%>
        </tbody>
        <%if(!rows.isEmpty()){%>
        <tfoot><tr>
          <td colspan="5" style="text-align:right;font-size:10px;letter-spacing:.4px;">TOTAL</td>
          <td style="text-align:right;"><%=String.format("%.2f",grandTotal)%></td>
          <td style="text-align:right;color:#a7f3d0;"><%=String.format("%.2f",grandPaid)%></td>
          <td style="text-align:right;color:#fca5a5;"><%=String.format("%.2f",grandBalance)%></td>
          <td colspan="2"></td>
        </tr></tfoot>
        <%}%>
      </table>
    </div>
  </div>
</div>
</body>
</html>
