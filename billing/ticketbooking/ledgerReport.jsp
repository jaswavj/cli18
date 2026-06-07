<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,java.text.SimpleDateFormat,java.text.DecimalFormat"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<jsp:useBean id="userb" class="user.userBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}
String ctx = request.getContextPath();
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
String today    = sdf.format(new java.util.Date());
String fromDate = request.getParameter("fromDate");
String toDate   = request.getParameter("toDate");
String agentIdP  = request.getParameter("agentFilter");
String txnFilter = request.getParameter("txnFilter");
if (fromDate  == null || fromDate.isEmpty())  fromDate  = today;
if (toDate    == null || toDate.isEmpty())    toDate    = today;
if (txnFilter == null || txnFilter.isEmpty()) txnFilter = "";
int agentFilterId = 0;
try { if (agentIdP != null && !agentIdP.isEmpty()) agentFilterId = Integer.parseInt(agentIdP); } catch (Exception e) {}

Vector agents   = billing.getTicketAgents();
Vector payModes = billing.getTicketPaymentModes();
Vector allRows  = billing.getTicketLedgerReport(fromDate, toDate, agentFilterId);
Vector companyDet = userb.getCompanyDetails();
String companyName = (companyDet.size() > 1 && companyDet.get(1) != null) ? companyDet.get(1).toString() : "";
String companyAddr = (companyDet.size() > 2 && companyDet.get(2) != null) ? companyDet.get(2).toString() : "";
java.text.SimpleDateFormat dpFmt = new java.text.SimpleDateFormat("dd/MM/yyyy");
java.text.SimpleDateFormat iFmt  = new java.text.SimpleDateFormat("yyyy-MM-dd");
String fromDisp = fromDate, toDisp = toDate;
try { fromDisp = dpFmt.format(iFmt.parse(fromDate)); } catch (Exception e) {}
try { toDisp   = dpFmt.format(iFmt.parse(toDate));   } catch (Exception e) {}
Vector rows = new Vector();
for (int _fi = 0; _fi < allRows.size(); _fi++) {
    Vector _fr = (Vector) allRows.get(_fi);
    double _fb = _fr.get(7) != null ? Double.parseDouble(_fr.get(7).toString()) : 0;
    if (Math.abs(_fb) <= 0.005) continue; // skip settled
    String _ft = (_fb >= 0) ? "CR" : "DR";
    if (txnFilter.isEmpty() || txnFilter.equals(_ft)) rows.add(_fr);
}

DecimalFormat df = new DecimalFormat("0.00");

// Totals
double totalBill = 0, totalPaid = 0, totalBal = 0;
for (int i = 0; i < rows.size(); i++) {
    Vector r = (Vector) rows.get(i);
    double bill = r.get(5) != null ? Math.abs(Double.parseDouble(r.get(5).toString())) : 0;
    double paid = r.get(6) != null ? Math.abs(Double.parseDouble(r.get(6).toString())) : 0;
    double bal  = r.get(7) != null ? Math.abs(Double.parseDouble(r.get(7).toString())) : 0;
    totalBill += bill; totalPaid += paid; totalBal += bal;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Ticket Ledger</title>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<%@ include file="/assets/common/head.jsp" %>
<style>
:root {
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

/* Header */
.rpt-hdr{flex-shrink:0;background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);padding:10px 16px;display:flex;align-items:center;gap:10px;flex-wrap:wrap;box-shadow:0 2px 8px rgba(0,0,0,.25);}
.rpt-title{display:flex;align-items:center;gap:9px;color:#fff;font-size:15px;font-weight:800;letter-spacing:.4px;flex-shrink:0;}
.rpt-title i{color:var(--gold);font-size:17px;}
.hdr-divider{width:1px;height:28px;background:rgba(255,255,255,.2);flex-shrink:0;}
.hdr-spacer{flex:1;}

/* Field / Button (reuse) */
.fg{display:flex;flex-direction:column;gap:3px;min-width:0;}
.fg-lbl{font-size:10px;font-weight:700;color:rgba(255,255,255,.7);text-transform:uppercase;letter-spacing:.5px;white-space:nowrap;}
.fg-inp,.fg-sel{height:33px;border:1.5px solid rgba(255,255,255,.25);border-radius:var(--r-sm);padding:0 9px;background:rgba(255,255,255,.12);color:#fff;font-size:13px;outline:none;}
.fg-inp::placeholder{color:rgba(255,255,255,.4);}
.fg-inp:focus,.fg-sel:focus{border-color:var(--gold);background:rgba(255,255,255,.18);}
.fg-sel option{background:#1a2744;color:#fff;}
.bb{display:inline-flex;align-items:center;gap:6px;height:33px;padding:0 15px;border-radius:var(--r-sm);font-size:12px;font-weight:700;cursor:pointer;border:1.5px solid transparent;transition:all .15s;white-space:nowrap;}
.bb-gold{background:var(--gold);color:#fff;border-color:var(--gold);}
.bb-gold:hover{background:var(--gold-d);}

/* Summary chips */
.sum-row{display:flex;gap:10px;flex-wrap:wrap;margin-bottom:12px;}
.sum-chip{background:var(--card);border-radius:var(--r-sm);border:1px solid var(--border-l);padding:10px 16px;display:flex;flex-direction:column;gap:3px;min-width:120px;box-shadow:var(--shadow-sm);}
.sum-chip-lbl{font-size:10px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.5px;}
.sum-chip-val{font-size:18px;font-weight:800;}
.sum-chip.chip-bill .sum-chip-val{color:var(--navy);}
.sum-chip.chip-paid .sum-chip-val{color:var(--green);}
.sum-chip.chip-bal  .sum-chip-val{color:var(--red);}

/* Table */
.tbl-wrap{background:var(--card);border-radius:var(--r);border:1px solid var(--border-l);box-shadow:var(--shadow-sm);overflow-x:auto;}
.rpt-table{width:100%;min-width:900px;border-collapse:collapse;font-size:12.5px;}
.rpt-table thead tr{background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);}
.rpt-table thead th{padding:10px 10px;color:#fff;font-weight:700;text-transform:uppercase;font-size:10.5px;letter-spacing:.4px;white-space:nowrap;text-align:left;}
.rpt-table tbody tr{border-bottom:1px solid var(--border-l);transition:background .1s;}
.rpt-table tbody tr:hover{background:#f7f8fc;}
.rpt-table tbody td{padding:9px 10px;vertical-align:middle;}
.rpt-table tbody tr:last-child{border-bottom:none;}
.rpt-table tfoot tr{background:#f1f5f9;border-top:2px solid var(--border);}
.rpt-table tfoot td{padding:9px 10px;font-weight:800;font-size:12.5px;}

/* Badges */
.badge{display:inline-block;padding:2px 7px;border-radius:3px;font-size:10px;font-weight:700;letter-spacing:.3px;}
.badge-buy{background:#fff3e0;color:#bf6000;border:1px solid #ffe0b2;}
.badge-sell{background:#e8f5e9;color:#1b5e20;border:1px solid #c8e6c9;}
.badge-cust{background:#e3f2fd;color:#0d47a1;border:1px solid #bbdefb;}
.badge-dr{background:#e8f5e9;color:#1b5e20;}
.badge-cr{background:#fff3e0;color:#bf6000;}
.bal-cell{font-weight:700;}
.bal-cell.zero{color:var(--green);}
.bal-cell.due{color:var(--red);}
.btn-collect{display:inline-flex;align-items:center;gap:4px;padding:4px 10px;border-radius:var(--r-sm);font-size:11px;font-weight:700;cursor:pointer;background:#dc2626;color:#fff;border:none;transition:background .15s;}
.btn-collect:hover{background:#b91c1c;}
.bb-print{background:rgba(255,255,255,.15);color:#fff;border-color:rgba(255,255,255,.35);}
.bb-print:hover{background:rgba(255,255,255,.25);}
.pax-list{font-size:10px;line-height:1.5;color:var(--text);}
.pax-list .pax-item{white-space:normal;word-break:break-word;}
.rpt-table .col-pax{width:200px;max-width:200px;min-width:120px;}
.rpt-table .col-tkt{white-space:nowrap;min-width:90px;}
.rpt-table .col-date{white-space:nowrap;min-width:90px;}
.rpt-table .col-party{min-width:110px;}
.rpt-table .col-amt{white-space:nowrap;min-width:80px;}
.rpt-table .col-bal{white-space:nowrap;min-width:80px;}
.print-header{display:none;}
@media print{
  .tw-nav,.rpt-hdr,.sum-row,.no-print{display:none!important;}
  .tw,.tw-body{height:auto!important;overflow:visible!important;}
  .tbl-wrap{box-shadow:none;border:none;overflow:visible!important;}
  .rpt-table{min-width:unset!important;font-size:10px;}
  .rpt-table thead tr{background:#1a2744!important;-webkit-print-color-adjust:exact;print-color-adjust:exact;}
  .rpt-table thead th{color:#fff!important;padding:5px 6px!important;}
  body{background:#fff;font-size:11px;}
  .tw-body{padding:4px 6px!important;overflow:visible!important;}
  .rpt-table tbody td{padding:4px 6px!important;}
  .print-header{display:flex!important;}
  *{-webkit-print-color-adjust:exact!important;print-color-adjust:exact!important;}
  @page{size:A4 landscape;margin:8mm 8mm;}
}

/* Modal */
.modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:2000;align-items:center;justify-content:center;}
.modal-overlay.active{display:flex;}
.modal-box{background:#fff;border-radius:var(--r);width:360px;max-width:95vw;box-shadow:0 8px 32px rgba(0,0,0,.25);overflow:hidden;}
.modal-head{background:linear-gradient(135deg,var(--navy),var(--navy2));padding:12px 16px;display:flex;align-items:center;justify-content:space-between;}
.modal-head-title{color:#fff;font-weight:800;font-size:13px;display:flex;align-items:center;gap:8px;}
.modal-head-title i{color:var(--gold);}
.modal-close{background:none;border:none;color:rgba(255,255,255,.7);font-size:18px;cursor:pointer;line-height:1;}
.modal-close:hover{color:#fff;}
.modal-body{padding:16px;display:flex;flex-direction:column;gap:12px;}
.mfg{display:flex;flex-direction:column;gap:4px;}
.mfg label{font-size:10.5px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;}
.mfg input,.mfg select{height:34px;border:1.5px solid var(--border);border-radius:var(--r-sm);padding:0 10px;font-size:13px;outline:none;width:100%;}
.mfg input:focus,.mfg select:focus{border-color:var(--violet);}
.modal-foot{padding:12px 16px;display:flex;gap:8px;justify-content:flex-end;border-top:1px solid var(--border-l);}
.info-row{background:#fafafa;border-radius:var(--r-sm);padding:8px 12px;font-size:12px;color:var(--text);}
.info-row span{font-weight:700;}
</style>
</head>
<body>
<div class="tw">
  <div class="tw-nav"><%@ include file="/assets/navbar/navbar.jsp" %></div>

  <!-- HEADER -->
  <div class="rpt-hdr">
    <div class="rpt-title">
      <i class="fa-solid fa-book-open"></i>
      <span>TICKET LEDGER</span>
    </div>
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
        <div class="fg-lbl">Type</div>
        <select name="txnFilter" class="fg-sel" style="width:110px;">
          <option value=""   <%=("".equals(txnFilter)  ?"selected":"")%>>CR &amp; DR</option>
          <option value="CR" <%=("CR".equals(txnFilter)?"selected":"")%>>CR Only</option>
          <option value="DR" <%=("DR".equals(txnFilter)?"selected":"")%>>DR Only</option>
        </select>
      </div>
      <div class="fg">
        <div class="fg-lbl">Agent</div>
        <select name="agentFilter" class="fg-sel" style="width:140px;">
          <option value="0">All Agents</option>
          <%for (int i = 0; i < agents.size(); i++) { Vector a = (Vector) agents.get(i);%>
          <option value="<%=a.get(0)%>" <%=(agentFilterId == Integer.parseInt(a.get(0).toString()) ? "selected" : "")%>><%=a.get(1)%></option>
          <%}%>
        </select>
      </div>
      <button type="submit" class="bb bb-gold">
        <i class="fa-solid fa-magnifying-glass"></i> Search
      </button>
    </form>

    <div class="hdr-spacer"></div>
    <button class="bb bb-print no-print" onclick="window.print()">
      <i class="fa-solid fa-print"></i> Print
    </button>
  </div>

  <!-- PRINT HEADER (visible only when printing) -->
  <div class="print-header" style="display:none;align-items:center;gap:14px;padding:10px 16px;background:linear-gradient(135deg,#1a2744 0%,#243159 100%);border-bottom:3px solid #c9922a;margin-bottom:8px;">
    <div style="flex:1;">
      <div style="color:#c9922a;font-size:18px;font-weight:900;letter-spacing:1px;text-transform:uppercase;"><%=companyName%></div>
      <%if (!companyAddr.isEmpty()){%><div style="color:rgba(255,255,255,.75);font-size:12px;margin-top:2px;"><%=companyAddr%></div><%}%>
    </div>
    <div style="text-align:right;color:rgba(255,255,255,.7);font-size:11px;">
      <div style="font-weight:700;color:#fff;font-size:13px;">Ticket Ledger Report</div>
      <div style="margin-top:3px;"><%=fromDisp%> &nbsp;to&nbsp; <%=toDisp%></div>
    </div>
  </div>

  <!-- BODY -->
  <div class="tw-body">

    <!-- Summary -->
    <div class="sum-row">
      <div class="sum-chip chip-bill">
        <div class="sum-chip-lbl">Total Bill</div>
        <div class="sum-chip-val">&#8377;<%=df.format(totalBill)%></div>
      </div>
      <div class="sum-chip chip-paid">
        <div class="sum-chip-lbl">Total Paid</div>
        <div class="sum-chip-val">&#8377;<%=df.format(totalPaid)%></div>
      </div>
      <div class="sum-chip chip-bal">
        <div class="sum-chip-lbl">Total Balance</div>
        <div class="sum-chip-val">&#8377;<%=df.format(totalBal)%></div>
      </div>
      <div class="sum-chip" style="background:var(--card);">
        <div class="sum-chip-lbl">Records</div>
        <div class="sum-chip-val" style="color:var(--violet);"><%=rows.size()%></div>
      </div>
    </div>

    <!-- Table -->
    <div class="tbl-wrap">
      <table class="rpt-table">
        <thead>
          <tr>
            <th>#</th>
            <th class="col-date">Date</th>
            <th class="col-tkt">Ticket / PNR</th>
            <th class="col-pax">Passengers</th>
            <th class="col-party">Party</th>
            <th>Type</th>
            <th>DR/CR</th>
            <th class="col-amt">Bill Amt</th>
            <th class="col-amt">Paid Amt</th>
            <th>Mode</th>
            <th>Txn No</th>
            <th class="col-bal">Balance</th>
            <th class="no-print">Action</th>
          </tr>
        </thead>
        <tbody>
        <%
        if (rows.isEmpty()) {
        %>
          <tr><td colspan="13" style="text-align:center;padding:30px;color:var(--muted);">
            <i class="fa-solid fa-inbox" style="font-size:24px;display:block;margin-bottom:8px;"></i>
            No ledger entries found for this period.
          </td></tr>
        <%
        } else {
          int sno = 1;
          for (int i = 0; i < rows.size(); i++) {
            Vector r = (Vector) rows.get(i);
            int    bookingId  = Integer.parseInt(r.get(0).toString());
            String tktNo      = r.get(1) != null ? r.get(1).toString() : "-";
            String pnr        = r.get(2) != null ? r.get(2).toString() : "-";
            String partyType  = r.get(3) != null ? r.get(3).toString() : "";
            String partyDisp  = r.get(4) != null ? r.get(4).toString() : "-";
            double netBal     = r.get(7) != null ? Double.parseDouble(r.get(7).toString()) : 0;
            String txnType    = (netBal >= 0) ? "CR" : "DR";
            double bill  = r.get(5) != null ? Math.abs(Double.parseDouble(r.get(5).toString())) : 0;
            double paid  = r.get(6) != null ? Math.abs(Double.parseDouble(r.get(6).toString())) : 0;
            double bal   = Math.abs(netBal);
            String fdate = r.get(8) != null ? r.get(8).toString() : "";
            String agentIdRaw    = r.get(9)  != null ? r.get(9).toString()  : "0";
            String payModeName   = r.get(11) != null ? r.get(11).toString() : "";
            String lastTxnNo     = r.get(12) != null ? r.get(12).toString() : "";
            String pName         = r.get(13) != null ? r.get(13).toString() : "";

            String ptBadge = "badge-cust";
            String ptLabel = partyType;
            if ("BUY_AGENT".equals(partyType))  { ptBadge = "badge-buy";  ptLabel = "Buy Agent"; }
            else if ("SELL_AGENT".equals(partyType)) { ptBadge = "badge-sell"; ptLabel = "Sell Agent"; }
            else if ("CUSTOMER".equals(partyType))   { ptBadge = "badge-cust"; ptLabel = "Customer"; }

            String txnBadge = "DR".equals(txnType) ? "badge-dr" : "badge-cr";
            String balCls   = bal <= 0.005 ? "zero" : "due";
        %>
          <tr>
            <td style="color:var(--muted);"><%=sno++%></td>
            <td style="white-space:nowrap;"><%=fdate%></td>
            <td>
              <div style="font-weight:700;color:var(--gold);"><%=tktNo%></div>
              <div style="font-size:11px;color:var(--muted);"><%=pnr%></div>
            </td>
            <td>
              <div class="pax-list">
              <%
                String[] paxArr = pName.isEmpty() ? new String[0] : pName.split(",");
                for (int pi = 0; pi < paxArr.length; pi++) {
                  String pax = paxArr[pi].trim();
                  if (!pax.isEmpty()) {
              %><div class="pax-item"><i class="fa-solid fa-user" style="font-size:9px;color:var(--muted);margin-right:3px;"></i><%=pax%></div><%
                  }
                }
                if (paxArr.length == 0) { %><span style="color:var(--muted);">—</span><% }
              %>
              </div>
            </td>
            <td>
              <span class="badge <%=ptBadge%>"><%=ptLabel%></span>
              <div style="font-size:12px;margin-top:3px;font-weight:600;"><%=partyDisp%></div>
            </td>
            <td>-</td>
            <td><span class="badge <%=txnBadge%>"><%=txnType%></span></td>
            <td style="font-weight:600;">&#8377;<%=df.format(bill)%></td>
            <td style="color:var(--green);font-weight:600;">&#8377;<%=df.format(paid)%></td>
            <td style="font-size:11px;color:var(--text);"><%=payModeName.isEmpty() ? "-" : payModeName%></td>
            <td style="font-size:11px;color:var(--violet);font-weight:600;">
              <%=lastTxnNo.isEmpty() ? "<span style='color:var(--muted);'>—</span>" : lastTxnNo%>
            </td>
            <td class="bal-cell <%=balCls%>">&#8377;<%=df.format(Math.abs(bal))%></td>
            <td class="no-print">
              <%if (bal > 0.005) {%>
              <button class="btn-collect"
                onclick="openCollect(<%=bookingId%>,'<%=partyType%>','<%=agentIdRaw%>','<%=partyDisp.replace("'","\\'")%>','<%=txnType%>',<%=df.format(bal)%>)">
                <%if ("CR".equals(txnType)) {%><i class="fa-solid fa-money-bill-wave"></i> Pay<%} else {%><i class="fa-solid fa-coins"></i> Collect<%}%>
              </button>
              <%} else {%>
              <span style="color:var(--green);font-size:11px;font-weight:700;"><i class="fa-solid fa-check"></i> Settled</span>
              <%}%>
            </td>
          </tr>
        <%
          }
        }
        %>
        </tbody>
        <tfoot>
          <tr>
            <td colspan="7" style="color:var(--muted);">TOTALS</td>
            <td>&#8377;<%=df.format(totalBill)%></td>
            <td style="color:var(--green);">&#8377;<%=df.format(totalPaid)%></td>
            <td></td><td></td>
            <td style="color:var(--red);">&#8377;<%=df.format(totalBal)%></td>
            <td></td>
          </tr>
        </tfoot>
      </table>
    </div>

    <div style="height:20px;"></div>
  </div><!-- /tw-body -->
</div><!-- /tw -->

<!-- ── COLLECT BALANCE MODAL ── -->
<div class="modal-overlay" id="collectModal">
  <div class="modal-box">
    <div class="modal-head">
      <div class="modal-head-title"><i class="fa-solid fa-coins"></i> Collect Balance</div>
      <button class="modal-close" onclick="closeCollect()">&times;</button>
    </div>
    <div class="modal-body">
      <div class="info-row" id="collectInfo"></div>
      <div class="mfg">
        <label>Collection Date</label>
        <input type="date" id="collectDate" value="<%=today%>">
      </div>
      <div class="mfg">
        <label>Amount to Collect</label>
        <input type="number" step="0.01" id="collectAmount" placeholder="0.00">
      </div>
      <div class="mfg">
        <label>Payment Mode</label>
        <select id="collectMode" onchange="handleCollectModeChange()">
          <option value="">— Select Mode —</option>
          <%for (int i = 0; i < payModes.size(); i++) { Vector pm = (Vector) payModes.get(i);%>
          <option value="<%=pm.get(0)%>" data-cash="<%=pm.get(1).toString().toLowerCase().contains("cash") ? "1" : "0"%>"><%=pm.get(1)%></option>
          <%}%>
        </select>
      </div>
      <div class="mfg" id="collectTxnRow" style="display:none;">
        <label>Transaction No <span style="color:#dc2626;">*</span></label>
        <input type="text" id="collectTxnNo" placeholder="Txn / Ref No for online payment">
      </div>
    </div>
    <div class="modal-foot">
      <button class="bb" style="background:#f1f5f9;color:var(--text);border-color:var(--border);" onclick="closeCollect()">Cancel</button>
      <button class="bb bb-gold" onclick="saveCollect()"><i class="fa-solid fa-money-bill-wave"></i> Pay</button>
    </div>
  </div>
</div>

<script>
const ctx = '<%=ctx%>';
let _cBookingId='', _cPartyType='', _cAgentId='', _cPartyName='', _cTxnType='', _cMaxBal=0;

function openCollect(bookingId, partyType, agentId, partyName, txnType, maxBal) {
    _cBookingId = bookingId;
    _cPartyType = partyType;
    _cAgentId   = agentId;
    _cPartyName = partyName;
    _cTxnType   = txnType;
    _cMaxBal    = maxBal;

    // Duplicate check: same booking + agent + amount already collected today?
    fetch(ctx + '/ticketbooking/checkDuplicateLedger.jsp?bookingId=' + bookingId
            + '&agentId=' + agentId + '&amount=' + maxBal.toFixed(2))
    .then(r => r.json())
    .then(d => {
        if (d.duplicate) {
            alert('⚠️ Duplicate Entry Detected!\n\nThis amount has already been collected today for this booking.\n\nEntered by : ' + d.enteredBy + '\nDate & Time: ' + d.dateTime + '\n\nClick OK to reload the page.');
            location.reload();
            return;
        }
        _showCollectModal(partyName, maxBal);
    })
    .catch(() => {
        // On network error, proceed to modal
        _showCollectModal(partyName, maxBal);
    });
}

function _showCollectModal(partyName, maxBal) {
    document.getElementById('collectInfo').innerHTML =
        'Party: <span>' + partyName + '</span> &nbsp;|&nbsp; Balance Due: <span style="color:#dc2626;">&#8377;' + maxBal.toFixed(2) + '</span>';
    document.getElementById('collectAmount').value = maxBal.toFixed(2);
    document.getElementById('collectMode').value = '';
    document.getElementById('collectTxnRow').style.display = 'none';
    document.getElementById('collectTxnNo').value = '';
    document.getElementById('collectModal').classList.add('active');
}
function closeCollect() {
    document.getElementById('collectModal').classList.remove('active');
}
function handleCollectModeChange() {
    const sel = document.getElementById('collectMode');
    const opt = sel.options[sel.selectedIndex];
    const isOnline = sel.value && opt.getAttribute('data-cash') === '0';
    document.getElementById('collectTxnRow').style.display = isOnline ? '' : 'none';
    if (!isOnline) document.getElementById('collectTxnNo').value = '';
}
function saveCollect() {
    const amt  = parseFloat(document.getElementById('collectAmount').value);
    const mode = document.getElementById('collectMode').value;
    const date = document.getElementById('collectDate').value;
    const txnNo = document.getElementById('collectTxnNo').value.trim();
    if (!amt || amt <= 0) { alert('Enter a valid amount'); return; }
    if (!mode) { alert('Select a payment mode'); return; }
    if (!date) { alert('Select a collection date'); return; }
    const opt = document.getElementById('collectMode').options[document.getElementById('collectMode').selectedIndex];
    if (opt.getAttribute('data-cash') === '0' && !txnNo) { alert('Enter Transaction No for online payment'); return; }

    const params = new URLSearchParams();
    params.set('bookingId',      _cBookingId);
    params.set('partyType',      _cPartyType);
    params.set('agentId',        _cAgentId);
    params.set('partyName',      _cPartyName);
    params.set('txnType',        _cTxnType);
    params.set('amount',         amt);
    params.set('payModeId',      mode);
    params.set('collectionDate', date);
    params.set('txnNo',          txnNo);

    fetch(ctx + '/ticketbooking/collectBalance.jsp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params.toString()
    })
    .then(r => r.text())
    .then(d => {
        if (d.trim() === 'SUCCESS') {
            closeCollect();
            location.reload();
        } else {
            alert('Error: ' + d);
        }
    })
    .catch(err => alert('Error: ' + err.message));
}

// Close modal on overlay click
document.getElementById('collectModal').addEventListener('click', function(e) {
    if (e.target === this) closeCollect();
});

// Auto-collapse sidebar on page load (desktop only)
document.addEventListener('DOMContentLoaded', function() {
    if (window.innerWidth > 768) {
        var sb = document.getElementById('sidebar');
        if (sb) sb.classList.add('hidden');
        document.body.classList.add('sidebar-hidden');
    }
});
</script>
</body>
</html>
