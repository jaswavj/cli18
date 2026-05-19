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

String dateType  = request.getParameter("dateType");
String fromDate  = request.getParameter("fromDate");
String toDate    = request.getParameter("toDate");
String pmFilter  = request.getParameter("pmFilter");
if (dateType == null || dateType.isEmpty()) dateType = "booking";
int pmFilterId = 0;
try { if (pmFilter != null && !pmFilter.isEmpty()) pmFilterId = Integer.parseInt(pmFilter); } catch (Exception ep) {}

String today = new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
if (fromDate == null || fromDate.isEmpty()) fromDate = today;
if (toDate   == null || toDate.isEmpty())   toDate   = today;

Vector payModes = billing.getTicketPaymentModes();

Vector reportData = new Vector();
boolean searched = false;
if (request.getParameter("fromDate") != null) {
    searched = true;
    reportData = billing.getTicketReport(dateType, fromDate, toDate, pmFilterId);
}
int total = reportData.size();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Ticket Report</title>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<%@ include file="/assets/common/head.jsp" %>
<style>
:root{
    --navy:#1a2744;--navy2:#243159;--violet:#5c4d8a;--gold:#c9922a;
    --bg:#eef1f7;--card:#fff;--border:#d1d9e6;--border-l:#e8edf5;
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
.fg-inp,.fg-sel{height:33px;border:1.5px solid rgba(255,255,255,.25);border-radius:var(--r-sm);padding:0 9px;background:rgba(255,255,255,.12);color:#fff;font-size:13px;outline:none;transition:border-color .15s;}
.fg-sel option{background:var(--navy);color:#fff;}
.fg-inp::placeholder{color:rgba(255,255,255,.4);}
.fg-inp:focus,.fg-sel:focus{border-color:var(--gold);background:rgba(255,255,255,.18);}
.bb{display:inline-flex;align-items:center;gap:6px;height:33px;padding:0 15px;border-radius:var(--r-sm);font-size:12px;font-weight:700;cursor:pointer;border:1.5px solid transparent;transition:all .15s;white-space:nowrap;text-decoration:none;}
.bb-gold{background:var(--gold);color:#fff;border-color:var(--gold);}
.bb-gold:hover{background:#a87520;}
.bb-outline-white{background:transparent;color:#fff;border-color:rgba(255,255,255,.4);}
.bb-outline-white:hover{background:rgba(255,255,255,.1);}

/* Summary bar */
.summary-bar{
    background:var(--card);border:1px solid var(--border-l);border-radius:var(--r);
    box-shadow:var(--shadow);padding:10px 16px;margin-bottom:12px;
    display:flex;align-items:center;gap:12px;flex-wrap:wrap;
}
.sum-chip{
    display:flex;align-items:center;gap:7px;padding:6px 14px;
    border-radius:6px;font-size:12px;font-weight:700;
}
.sum-chip i{font-size:13px;}
.sum-blue{background:#e8f0ff;color:var(--violet);}
.sum-green{background:#e8f5e9;color:#2e7d32;}

/* Table */
.tbl-wrap{overflow-x:auto;border-radius:var(--r);box-shadow:var(--shadow);}
.rpt-table{width:100%;border-collapse:collapse;background:var(--card);font-size:12px;}
.rpt-table thead tr{background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);}
.rpt-table thead th{
    color:#fff;padding:9px 10px;font-size:10px;font-weight:800;
    text-transform:uppercase;letter-spacing:.5px;white-space:nowrap;
    border-right:1px solid rgba(255,255,255,.1);
}
.rpt-table thead th:first-child{border-radius:var(--r) 0 0 0;}
.rpt-table thead th:last-child{border-right:none;border-radius:0 var(--r) 0 0;}
.rpt-table tbody tr{border-bottom:1px solid var(--border-l);transition:background .1s;}
.rpt-table tbody tr:hover{background:#f5f3fb;}
.rpt-table tbody tr:last-child{border-bottom:none;}
.rpt-table td{padding:8px 10px;color:var(--text);vertical-align:top;white-space:nowrap;}
.rpt-table td.wrap{white-space:normal;min-width:100px;}

/* Badges */
.badge{display:inline-flex;align-items:center;gap:4px;padding:2px 8px;border-radius:3px;font-size:10px;font-weight:700;white-space:nowrap;}
.badge-violet{background:#f0edf8;color:var(--violet);}
.badge-green{background:#e8f5e9;color:#2e7d32;}
.badge-orange{background:#fff3e0;color:#bf6000;}
.badge-blue{background:#e3f2fd;color:#0d47a1;}
.badge-ret{background:#e8f5e9;color:#2e7d32;border:1px solid #c8e6c9;}
.pnr-link{color:var(--violet);font-weight:800;text-decoration:none;letter-spacing:.5px;}
.pnr-link:hover{text-decoration:underline;color:var(--violet-d);}
.pax-mini{display:flex;flex-direction:column;gap:2px;}
.pax-mini span{font-size:10px;color:var(--muted);}

/* Empty state */
.empty-state{text-align:center;padding:50px 20px;color:var(--muted);}
.empty-state i{font-size:48px;color:#d1d9e6;margin-bottom:12px;display:block;}
.empty-state h3{font-size:15px;font-weight:700;margin-bottom:6px;}

/* Expand row (details) */
.detail-row{display:none;background:#f8f6ff !important;}
.detail-row td{padding:0 !important;}
.detail-inner{padding:12px 16px;display:grid;grid-template-columns:repeat(auto-fill,minmax(180px,1fr));gap:8px;border-top:2px solid #e0daf5;}
.di{display:flex;flex-direction:column;gap:2px;}
.di-lbl{font-size:9px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;color:var(--muted);}
.di-val{font-size:12px;font-weight:600;color:var(--text);background:var(--inp-bg);border:1px solid var(--border-l);border-radius:3px;padding:4px 7px;}
.di-val.empty{color:var(--muted);font-weight:400;font-style:italic;}
.expand-btn{cursor:pointer;color:var(--violet);background:none;border:none;font-size:12px;padding:2px 6px;border-radius:3px;transition:background .1s;}
.expand-btn:hover{background:#f0edf8;}

@media print{
    .tw-nav,.tb-header,.summary-bar .bb-outline-white{display:none!important;}
    .tw-body{overflow:visible!important;height:auto!important;}
    .tw{height:auto!important;overflow:visible!important;}
}
</style>
</head>
<body>
<div class="tw">
  <div class="tw-nav"><%@ include file="/assets/navbar/navbar.jsp" %></div>

  <!-- HEADER / FILTER -->
  <div class="tb-header">
    <div class="tb-header-title">
      <i class="fa-solid fa-chart-bar"></i>
      <span>TICKET REPORT</span>
    </div>
    <div class="tb-divider"></div>
    <form method="get" action="" style="display:flex;align-items:flex-end;gap:8px;flex-wrap:wrap;">
      <div class="fg">
        <div class="fg-lbl">Filter By</div>
        <select name="dateType" class="fg-sel" style="width:130px;">
          <option value="booking"  <%="booking".equals(dateType)?"selected":""%>>Booking Date</option>
          <option value="travel"   <%="travel".equals(dateType) ?"selected":""%>>Travel Date</option>
        </select>
      </div>
      <div class="fg">
        <div class="fg-lbl">From</div>
        <input name="fromDate" type="date" class="fg-inp" value="<%=fromDate%>" style="width:135px;">
      </div>
      <div class="fg">
        <div class="fg-lbl">To</div>
        <input name="toDate" type="date" class="fg-inp" value="<%=toDate%>" style="width:135px;">
      </div>
      <div class="fg">
        <div class="fg-lbl">Payment Mode</div>
        <select name="pmFilter" class="fg-sel" style="width:140px;">
          <option value="0" <%=(pmFilterId==0)?"selected":""%>>All Modes</option>
          <%for (int pm=0;pm<payModes.size();pm++) {
              Vector pmRow=(Vector)payModes.get(pm);
              int pmId=Integer.parseInt(String.valueOf(pmRow.get(0)));
              String pmName=String.valueOf(pmRow.get(1));%>
          <option value="<%=pmId%>" <%=(pmFilterId==pmId)?"selected":""%>><%=pmName%></option>
          <%}%>
        </select>
      </div>
      <button type="submit" class="bb bb-gold">
        <i class="fa-solid fa-filter"></i> Filter
      </button>
    </form>
    <div class="hdr-spacer"></div>
    <%if (searched && total > 0){%>
    <button class="bb bb-outline-white" onclick="window.print()">
      <i class="fa-solid fa-print"></i> Print
    </button>
    <%}%>
  </div>

  <!-- BODY -->
  <div class="tw-body">

    <%if (searched) {%>
    <!-- Summary bar -->
    <div class="summary-bar">
      <div class="sum-chip sum-blue">
        <i class="fa-solid fa-ticket"></i>
        <span>Total Bookings: <strong><%=total%></strong></span>
      </div>
      <%
        double totBuy=0, totSell=0, totCust=0;
        for (int i=0;i<reportData.size();i++) {
            Vector r=(Vector)reportData.get(i);
            try { if(r.get(18)!=null) totBuy  += Double.parseDouble(String.valueOf(r.get(18))); } catch(Exception e2){}
            try { if(r.get(21)!=null) totSell += Double.parseDouble(String.valueOf(r.get(21))); } catch(Exception e2){}
            try { if(r.get(24)!=null) totCust += Double.parseDouble(String.valueOf(r.get(24))); } catch(Exception e2){}
        }
      %>
      <div class="sum-chip sum-orange" style="background:#fff3e0;color:#bf6000;">
        <i class="fa-solid fa-arrow-down-to-bracket"></i>
        <span>Total Buy: <strong>₹ <%=String.format("%.2f", totBuy)%></strong></span>
      </div>
      <div class="sum-chip sum-green">
        <i class="fa-solid fa-arrow-up-from-bracket"></i>
        <span>Total Sell (Agent): <strong>₹ <%=String.format("%.2f", totSell)%></strong></span>
      </div>
      <div class="sum-chip" style="background:#e3f2fd;color:#0d47a1;">
        <i class="fa-solid fa-user"></i>
        <span>Total Customer: <strong>₹ <%=String.format("%.2f", totCust)%></strong></span>
      </div>
    </div>
    <%}%>

    <%if (!searched) {%>
    <div class="empty-state">
      <i class="fa-solid fa-chart-bar"></i>
      <h3>Select date range and click Filter</h3>
      <p style="font-size:12px;">Filter by booking date or one-way travel date</p>
    </div>

    <%} else if (total == 0) {%>
    <div class="empty-state">
      <i class="fa-solid fa-folder-open"></i>
      <h3>No bookings found</h3>
      <p style="font-size:12px;">Try adjusting the date range or filter type</p>
    </div>

    <%} else {%>
    <div class="tbl-wrap">
      <table class="rpt-table">
        <thead>
          <tr>
            <th>#</th>
            <th>PNR</th>
            <th>Booking Date</th>
            <th>Travel Date</th>
            <th>Route</th>
            <th>Flight</th>
            <th>Seats</th>
            <th>Phone</th>
            <th>Buy Agent</th>
            <th>Buy Amt</th>
            <th>Buy Mode</th>
            <th>Sell Agent</th>
            <th>Sell Amt</th>
            <th>Sell Mode</th>
            <th>Customer</th>
            <th>Cust Amt</th>
            <th>Cust Mode</th>
            <th>Details</th>
          </tr>
        </thead>
        <tbody>
        <%
        for (int i = 0; i < reportData.size(); i++) {
            Vector r = (Vector) reportData.get(i);
            String rId        = r.get(0)  != null ? String.valueOf(r.get(0))  : "";
            String rPnr       = r.get(1)  != null ? String.valueOf(r.get(1))  : "-";
            String rBkDate    = r.get(2)  != null ? String.valueOf(r.get(2))  : "-";
            String rOwDate    = r.get(3)  != null ? String.valueOf(r.get(3))  : "-";
            String rOwTime    = r.get(4)  != null ? String.valueOf(r.get(4))  : "";
            String rOwFrom    = r.get(5)  != null ? String.valueOf(r.get(5))  : "-";
            String rOwTo      = r.get(6)  != null ? String.valueOf(r.get(6))  : "-";
            String rOwFlight  = r.get(7)  != null ? String.valueOf(r.get(7))  : "";
            String rOwAir     = r.get(8)  != null ? String.valueOf(r.get(8))  : "";
            String rRetDate   = r.get(9)  != null ? String.valueOf(r.get(9))  : "";
            String rRetTime   = r.get(10) != null ? String.valueOf(r.get(10)) : "";
            String rRetFrom   = r.get(11) != null ? String.valueOf(r.get(11)) : "";
            String rRetTo     = r.get(12) != null ? String.valueOf(r.get(12)) : "";
            String rRetFl     = r.get(13) != null ? String.valueOf(r.get(13)) : "";
            String rRetAir    = r.get(14) != null ? String.valueOf(r.get(14)) : "";
            String rSeats     = r.get(15) != null ? String.valueOf(r.get(15)) : "-";
            String rPhone     = r.get(16) != null ? String.valueOf(r.get(16)) : "-";
            String rBuyAg     = r.get(17) != null ? String.valueOf(r.get(17)) : "";
            String rBuyAmt    = r.get(18) != null ? String.valueOf(r.get(18)) : "";
            String rBuyMode   = r.get(19) != null ? String.valueOf(r.get(19)) : "";
            String rSellAg    = r.get(20) != null ? String.valueOf(r.get(20)) : "";
            String rSellAmt   = r.get(21) != null ? String.valueOf(r.get(21)) : "";
            String rSellMode  = r.get(22) != null ? String.valueOf(r.get(22)) : "";
            String rCustNm    = r.get(23) != null ? String.valueOf(r.get(23)) : "";
            String rCustAmt   = r.get(24) != null ? String.valueOf(r.get(24)) : "";
            String rCustMode  = r.get(25) != null ? String.valueOf(r.get(25)) : "";
            boolean rHasRet   = rRetDate != null && !rRetDate.trim().isEmpty();
            String detailId   = "det_" + rId;
        %>
        <tr>
          <td style="font-weight:700;color:var(--muted);"><%=i+1%></td>
          <td>
            <a class="pnr-link" href="<%=ctx%>/ticketbooking/pnrEnquiry.jsp?pnr=<%=rPnr%>" target="_blank"><%=rPnr%></a>
          </td>
          <td><span class="badge badge-violet"><%=rBkDate%></span></td>
          <td>
            <div style="display:flex;flex-direction:column;gap:3px;">
              <span class="badge badge-blue"><i class="fa-solid fa-plane-departure"></i> <%=rOwDate%></span>
              <%if (rHasRet){%><span class="badge badge-ret"><i class="fa-solid fa-plane-arrival"></i> <%=rRetDate%></span><%}%>
            </div>
          </td>
          <td>
            <div style="font-size:12px;font-weight:700;white-space:nowrap;"><%=rOwFrom%> → <%=rOwTo%></div>
            <%if (rHasRet && !rRetFrom.isEmpty()){%>
            <div style="font-size:11px;color:var(--muted);margin-top:2px;">↩ <%=rRetFrom%> → <%=rRetTo%></div>
            <%}%>
          </td>
          <td>
            <%if (!rOwFlight.isEmpty()){%><div style="font-size:11px;"><%=rOwFlight%></div><%}%>
            <%if (!rOwAir.isEmpty()){%><div style="font-size:10px;color:var(--muted);"><%=rOwAir%></div><%}%>
          </td>
          <td style="text-align:center;font-weight:700;"><%=rSeats%></td>
          <td style="color:var(--muted);"><%=rPhone%></td>
          <td><%=rBuyAg.isEmpty() ? "<span style='color:var(--muted);'>-</span>" : "<span class='badge badge-orange'>" + rBuyAg + "</span>"%></td>
          <td style="font-weight:700;color:#bf6000;"><%=rBuyAmt.isEmpty() ? "-" : "₹ " + rBuyAmt%></td>
          <td style="color:var(--muted);font-size:11px;"><%=rBuyMode.isEmpty() ? "-" : rBuyMode%></td>
          <td><%=rSellAg.isEmpty() ? "<span style='color:var(--muted);'>-</span>" : "<span class='badge badge-green'>" + rSellAg + "</span>"%></td>
          <td style="font-weight:700;color:var(--green);"><%=rSellAmt.isEmpty() ? "-" : "₹ " + rSellAmt%></td>
          <td style="color:var(--muted);font-size:11px;"><%=rSellMode.isEmpty() ? "-" : rSellMode%></td>
          <td><%=rCustNm.isEmpty() ? "<span style='color:var(--muted);'>-</span>" : rCustNm%></td>
          <td style="font-weight:700;color:#0d47a1;"><%=rCustAmt.isEmpty() ? "-" : "₹ " + rCustAmt%></td>
          <td style="color:var(--muted);font-size:11px;"><%=rCustMode.isEmpty() ? "-" : rCustMode%></td>
          <td style="white-space:nowrap;">
            <a href="<%=ctx%>/ticketbooking/ticketPrint.jsp?id=<%=rId%>" target="_blank"
               class="bb bb-gold" style="height:26px;padding:0 8px;font-size:11px;text-decoration:none;display:inline-flex;align-items:center;gap:4px;margin-right:4px;">
              <i class="fa-solid fa-print"></i> Receipt
            </a>
            <button class="expand-btn" onclick="toggleDetail('<%=detailId%>', this)" title="View full details">
              <i class="fa-solid fa-chevron-down"></i>
            </button>
          </td>
        </tr>
        <!-- Detail expandable row -->
        <tr class="detail-row" id="<%=detailId%>">
          <td colspan="18">
            <div class="detail-inner">
              <div class="di"><div class="di-lbl">One Way Time</div><div class="di-val <%=rOwTime.isEmpty()?"empty":""%>"><%=rOwTime.isEmpty()?"-":rOwTime%></div></div>
              <%if (rHasRet){%>
              <div class="di"><div class="di-lbl">Return Date</div><div class="di-val"><%=rRetDate%></div></div>
              <div class="di"><div class="di-lbl">Return Time</div><div class="di-val <%=rRetTime.isEmpty()?"empty":""%>"><%=rRetTime.isEmpty()?"-":rRetTime%></div></div>
              <div class="di"><div class="di-lbl">Return From</div><div class="di-val <%=rRetFrom.isEmpty()?"empty":""%>"><%=rRetFrom.isEmpty()?"-":rRetFrom%></div></div>
              <div class="di"><div class="di-lbl">Return To</div><div class="di-val <%=rRetTo.isEmpty()?"empty":""%>"><%=rRetTo.isEmpty()?"-":rRetTo%></div></div>
              <div class="di"><div class="di-lbl">Ret. Flight</div><div class="di-val <%=rRetFl.isEmpty()?"empty":""%>"><%=rRetFl.isEmpty()?"-":rRetFl%></div></div>
              <div class="di"><div class="di-lbl">Ret. Airlines</div><div class="di-val <%=rRetAir.isEmpty()?"empty":""%>"><%=rRetAir.isEmpty()?"-":rRetAir%></div></div>
              <%}%>
              <div class="di" style="grid-column:span 2;">
                <div class="di-lbl">Full Detail</div>
                <a href="<%=ctx%>/ticketbooking/pnrEnquiry.jsp?pnr=<%=rPnr%>" target="_blank" class="bb bb-gold" style="margin-top:2px;text-decoration:none;height:28px;padding:0 12px;font-size:11px;">
                  <i class="fa-solid fa-arrow-up-right-from-square"></i> Open PNR Enquiry
                </a>
              </div>
            </div>
          </td>
        </tr>
        <%}%>
        </tbody>
      </table>
    </div>
    <%}%>

    <div style="height:20px;"></div>
  </div><!-- /tw-body -->
</div><!-- /tw -->

<script>
function toggleDetail(id, btn) {
    const row = document.getElementById(id);
    const open = row.style.display === 'table-row';
    row.style.display = open ? 'none' : 'table-row';
    btn.innerHTML = open
        ? '<i class="fa-solid fa-chevron-down"></i>'
        : '<i class="fa-solid fa-chevron-up"></i>';
    btn.style.background = open ? '' : '#f0edf8';
}
</script>
</body>
</html>
