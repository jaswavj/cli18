<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<jsp:useBean id="user" class="user.userBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
String ctx = request.getContextPath();

int billId = 0;
try { billId = Integer.parseInt(request.getParameter("id")); } catch(Exception e) {}

// Company info
Vector compDet = user.getCompanyDetails();
String shopName = "", address = "", gstin = "";
if (compDet != null && compDet.size() > 3) {
    shopName = compDet.get(1) != null ? compDet.get(1).toString() : "";
    address  = compDet.get(2) != null ? compDet.get(2).toString() : "";
    gstin    = compDet.get(3) != null ? compDet.get(3).toString() : "";
}

// Load bill from bean
Vector bill = billing.getServiceBillById(billId);
String loadErr = bill.isEmpty() ? "Bill not found." : null;

String billNo = "", billDate = "", customerName = "", phone = "";
String payModeName = "", description = "";
double subtotal = 0, discount = 0, totalAmount = 0, paidAmount = 0, balance = 0;
double collectedAmount = 0;

if (!bill.isEmpty()) {
    billNo       = bill.get(0)  != null ? bill.get(0).toString()  : "";
    billDate     = bill.get(1)  != null ? bill.get(1).toString()  : "";
    customerName = bill.get(2)  != null ? bill.get(2).toString()  : "";
    phone        = bill.get(3)  != null ? bill.get(3).toString()  : "";
    try { subtotal    = Double.parseDouble(bill.get(4).toString());  } catch(Exception e) {}
    try { discount    = Double.parseDouble(bill.get(5).toString());  } catch(Exception e) {}
    try { totalAmount = Double.parseDouble(bill.get(6).toString());  } catch(Exception e) {}
    try { paidAmount  = Double.parseDouble(bill.get(7).toString());  } catch(Exception e) {}
    try { balance     = Double.parseDouble(bill.get(8).toString());  } catch(Exception e) {}
    payModeName  = bill.get(9)  != null ? bill.get(9).toString()  : "";
    description  = bill.get(10) != null ? bill.get(10).toString() : "";
}

// Load items from bean
Vector itemsVec = billing.getServiceBillItems(billId);
Vector collections = billing.getServiceBillBalanceCollections(billId);
collectedAmount = billing.getServiceBillCollectedAmount(billId);
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Service Bill - <%=billNo%></title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
body{font-family:'Segoe UI',Arial,sans-serif;background:#eef1f7;display:flex;flex-direction:column;align-items:center;min-height:100vh;padding:20px 0;}
.screen-btn-bar{display:flex;gap:10px;margin-bottom:16px;}
.s-btn{display:inline-flex;align-items:center;gap:6px;height:34px;padding:0 16px;border-radius:5px;font-size:12px;font-weight:700;cursor:pointer;border:none;}
.s-btn-navy{background:#1a2744;color:#fff;}
.s-btn-ghost{background:#fff;color:#1a2744;border:1px solid #d1d9e6;}

/* A5 Receipt */
.receipt{
    width:148mm;
    min-height:210mm;
    background:#fff;
    box-shadow:0 4px 24px rgba(0,0,0,.15);
    padding:8mm;
    display:flex;
    flex-direction:column;
    gap:0;
}
.rpt-company{text-align:center;padding-bottom:5mm;border-bottom:1.5pt solid #1a2744;}
.rpt-company-name{font-size:15pt;font-weight:900;color:#1a2744;letter-spacing:.5px;}
.rpt-company-addr{font-size:8pt;color:#64748b;margin-top:2px;}
.rpt-company-gstin{font-size:7.5pt;color:#64748b;}

.receipt-type-band{background:#1a2744;text-align:center;padding:2mm 0;margin:3mm 0;border-top:1pt solid #c9922a;border-bottom:1pt solid #c9922a;}
.receipt-type-band span{color:#c9922a;font-size:10pt;font-weight:900;letter-spacing:2pt;text-transform:uppercase;}

.rpt-info-bar{display:flex;justify-content:space-between;margin-bottom:4mm;font-size:8.5pt;}
.rpt-info-bar .lbl{color:#64748b;font-size:7.5pt;}
.rpt-info-bar .val{font-weight:800;color:#0f172a;}
.customer-box{background:#f8fafc;border:1pt solid #d1d9e6;border-radius:4pt;padding:3mm 4mm;margin-bottom:4mm;}
.customer-box .lbl{font-size:7.5pt;color:#64748b;font-weight:700;text-transform:uppercase;letter-spacing:.4pt;}
.customer-box .cust-name{font-size:11pt;font-weight:900;color:#1a2744;margin-top:1mm;}
.customer-box .cust-phone{font-size:8.5pt;color:#5c4d8a;font-weight:700;}

/* Items table */
.items-tbl{width:100%;border-collapse:collapse;font-size:8.5pt;margin-bottom:4mm;}
.items-tbl thead tr{background:#1a2744;}
.items-tbl thead th{color:#fff;padding:2mm 3mm;font-size:7.5pt;font-weight:800;text-transform:uppercase;letter-spacing:.4pt;}
.items-tbl tbody tr{border-bottom:0.5pt solid #e8edf5;}
.items-tbl tbody td{padding:2mm 3mm;color:#0f172a;vertical-align:top;}
.items-tbl tfoot td{padding:2mm 3mm;font-size:8pt;}
.items-tbl .sn{color:#64748b;font-size:7.5pt;width:6mm;}

/* Totals */
.totals-box{margin-left:auto;width:72mm;font-size:8.5pt;}
.tot-row{display:flex;justify-content:space-between;padding:1.5mm 3mm;border-bottom:0.5pt solid #e8edf5;}
.tot-row .tl{color:#64748b;}
.tot-row .tv{font-weight:700;color:#0f172a;}
.tot-row.highlight{background:#f8fafc;}
.tot-row.grand{background:#1a2744;border-bottom:none;}
.tot-row.grand .tl,.tot-row.grand .tv{color:#fff;font-weight:900;font-size:9.5pt;}
.tot-row.paid .tv{color:#059669;}
.tot-row.balance .tv{color:<%=balance>0?"#dc2626":"#059669"%>;}

.pay-mode-row{font-size:8pt;color:#64748b;text-align:right;margin-top:1.5mm;padding-right:3mm;}
.desc-box{background:#f8fafc;border:1pt solid #d1d9e6;border-radius:4pt;padding:2.5mm 3.5mm;margin-top:4mm;font-size:8pt;color:#0f172a;}
.desc-box .d-lbl{font-size:7.5pt;color:#64748b;font-weight:700;text-transform:uppercase;letter-spacing:.4pt;margin-bottom:1.5mm;}
.footer-band{text-align:center;margin-top:auto;padding-top:5mm;border-top:1pt solid #c9922a;margin-top:6mm;}
.footer-band .thank{color:#1a2744;font-size:9pt;font-weight:900;}
.footer-band .note{color:#64748b;font-size:7pt;margin-top:1mm;}
.collection-box{background:#f8fafc;border:1pt solid #d1d9e6;border-radius:4pt;padding:2.5mm 3.5mm;margin-top:4mm;font-size:8pt;color:#0f172a;}
.collection-box .c-lbl{font-size:7.5pt;color:#64748b;font-weight:700;text-transform:uppercase;letter-spacing:.4pt;margin-bottom:1.5mm;}
.collection-box table{width:100%;border-collapse:collapse;font-size:7.5pt;}
.collection-box th,.collection-box td{padding:1.5mm 1.5mm;border-bottom:.5pt solid #e8edf5;text-align:left;}
.collection-box th{font-size:7pt;color:#64748b;text-transform:uppercase;}

@media print{
    body{background:#fff;padding:0;}
    .screen-btn-bar{display:none!important;}
    .receipt{box-shadow:none;width:148mm;min-height:210mm;padding:8mm;}
    @page{size:A5 portrait;margin:0;}
}
</style>
</head>
<body>
<%if(loadErr!=null){%>
<div style="color:red;padding:20px;">Error: <%=loadErr%></div>
<%} else {%>
<div class="screen-btn-bar">
  <button class="s-btn s-btn-navy" onclick="doPrint()"><i>&#128424;</i> Print</button>
  <button class="s-btn s-btn-ghost" onclick="closeTab()">&#10005; Close</button>
</div>

<div class="receipt">
  <!-- Company Header -->
  <div class="rpt-company">
    <div class="rpt-company-name"><%=shopName%></div>
    <div class="rpt-company-addr"><%=address%></div>
    <%if(gstin!=null&&!gstin.isEmpty()){%><div class="rpt-company-gstin">GSTIN: <%=gstin%></div><%}%>
  </div>

  <div class="receipt-type-band"><span>Service Receipt</span></div>

  <!-- Info Bar -->
  <div class="rpt-info-bar">
    <div><div class="lbl">Bill No</div><div class="val"># <%=billNo%></div></div>
    <div style="text-align:right;"><div class="lbl">Date</div><div class="val"><%=billDate%></div></div>
  </div>

  <!-- Customer -->
  <%if((customerName!=null&&!customerName.isEmpty())||(phone!=null&&!phone.isEmpty())){%>
  <div class="customer-box">
    <div class="lbl">Customer</div>
    <%if(customerName!=null&&!customerName.isEmpty()){%><div class="cust-name"><%=customerName%></div><%}%>
    <%if(phone!=null&&!phone.isEmpty()){%><div class="cust-phone"><i>&#9742;</i> <%=phone%></div><%}%>
  </div>
  <%}%>

  <!-- Items -->
  <table class="items-tbl">
    <thead><tr>
      <th class="sn">#</th>
      <th style="text-align:left;">Service</th>
      <th style="text-align:right;">Amount (&#8377;)</th>
    </tr></thead>
    <tbody>
    <%for(int i=0;i<itemsVec.size();i++){Vector itm=(Vector)itemsVec.get(i);%>
      <tr>
        <td class="sn"><%=i+1%></td>
        <td><%=itm.get(0)%></td>
        <td style="text-align:right;font-weight:700;"><%=String.format("%.2f",(Double)itm.get(1))%></td>
      </tr>
    <%}%>
    </tbody>
  </table>

  <!-- Totals -->
  <div class="totals-box">
    <div class="tot-row"><span class="tl">Subtotal</span><span class="tv">&#8377;<%=String.format("%.2f",subtotal)%></span></div>
    <%if(discount>0){%><div class="tot-row"><span class="tl">Discount</span><span class="tv" style="color:#c9922a;">- &#8377;<%=String.format("%.2f",discount)%></span></div><%}%>
    <div class="tot-row grand"><span class="tl">Total Payable</span><span class="tv">&#8377;<%=String.format("%.2f",totalAmount)%></span></div>
    <div class="tot-row paid"><span class="tl">Paid</span><span class="tv">&#8377;<%=String.format("%.2f",paidAmount)%></span></div>
    <div class="tot-row paid"><span class="tl">Balance Collected</span><span class="tv">&#8377;<%=String.format("%.2f",collectedAmount)%></span></div>
    <div class="tot-row balance"><span class="tl">Balance</span><span class="tv">&#8377;<%=String.format("%.2f",balance)%></span></div>
  </div>
  <%if(payModeName!=null&&!payModeName.isEmpty()){%>
  <div class="pay-mode-row">Payment Mode: <strong><%=payModeName%></strong></div>
  <%}%>

  <%if(description!=null&&!description.trim().isEmpty()){%>
  <div class="desc-box">
    <div class="d-lbl">Note</div>
    <div><%=description%></div>
  </div>
  <%}%>

  <% if (collections != null && collections.size() > 0) { %>
  <div class="collection-box">
    <div class="c-lbl">Balance Collection History</div>
    <table>
      <thead>
        <tr><th style="width:24mm;">Date</th><th style="width:24mm;text-align:right;">Amount</th><th style="width:32mm;">Mode</th><th>Remarks</th></tr>
      </thead>
      <tbody>
        <% for (int ci = 0; ci < collections.size(); ci++) {
            Vector c = (Vector) collections.get(ci);
            String cDate = c.get(0) != null ? c.get(0).toString() : "";
            double cAmt = c.get(1) != null ? Double.parseDouble(c.get(1).toString()) : 0;
            String cMode = c.get(2) != null ? c.get(2).toString() : "";
            String cRem = c.get(3) != null ? c.get(3).toString() : "";
        %>
        <tr>
          <td><%=cDate%></td>
          <td style="text-align:right;font-weight:700;">&#8377;<%=String.format("%.2f",cAmt)%></td>
          <td><%=cMode%></td>
          <td><%=cRem%></td>
        </tr>
        <% } %>
      </tbody>
    </table>
  </div>
  <% } %>

  <div class="footer-band">
    <div class="thank">Thank you for your business!</div>
    <div class="note">This is a computer generated receipt.</div>
  </div>
</div>
<%}%>
<script>
function doPrint() {
  window.print();
  window.addEventListener('afterprint', function() { window.close(); }, { once: true });
}
function closeTab() {
  window.close();
}
// Auto-print on load
window.onload = function() { doPrint(); };
</script>
</body>
</html>
