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
SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
String today    = sdf.format(new java.util.Date());
String fromDate = request.getParameter("fromDate");
String toDate   = request.getParameter("toDate");
String agentIdP = request.getParameter("agentId");
if (fromDate == null || fromDate.isEmpty()) fromDate = today;
if (toDate   == null || toDate.isEmpty())   toDate   = today;
int agentId = 0;
try { if (agentIdP != null && !agentIdP.isEmpty()) agentId = Integer.parseInt(agentIdP); } catch (Exception e) {}

Vector agents = billing.getTicketAgents();

// Company name (use direct instantiation to avoid duplicate bean with navbar.jsp)
String companyName = "MOULANA AIR TRAVELS";
try {
    user.userBean uBean = new user.userBean();
    Vector companyInfo = uBean.getCompanyDetails();
    if (companyInfo != null && companyInfo.size() > 1 && companyInfo.get(1) != null)
        companyName = companyInfo.get(1).toString();
} catch (Exception e) { /* use default */ }

// Data (only load when agent is selected)
Vector rows = new Vector();
String selectedAgentName = "";
if (agentId > 0) {
    rows = billing.getAgentStatement(fromDate, toDate, agentId);
    // Get agent name from OPEN row
    if (rows.size() > 0) {
        Vector firstRow = (Vector) rows.get(0);
        selectedAgentName = firstRow.get(11) != null ? firstRow.get(11).toString() : "";
    }
    if (selectedAgentName.isEmpty()) {
        for (int i = 0; i < agents.size(); i++) {
            Vector a = (Vector) agents.get(i);
            if (a.get(0).toString().equals(String.valueOf(agentId))) {
                selectedAgentName = a.get(1).toString(); break;
            }
        }
    }
}

// Format date for display e.g. 07/05/2026
java.text.SimpleDateFormat dpFmt = new java.text.SimpleDateFormat("dd/MM/yyyy");
java.text.SimpleDateFormat iFmt  = new java.text.SimpleDateFormat("yyyy-MM-dd");
String fromDisp = fromDate, toDisp = toDate;
try { fromDisp = dpFmt.format(iFmt.parse(fromDate)); } catch (Exception e) {}
try { toDisp   = dpFmt.format(iFmt.parse(toDate));   } catch (Exception e) {}

// Totals from TOTAL row
String totalDrStr = "0.00", totalCrStr = "0.00", closingBal = "0.00", closingDir = "NIL";
if (rows.size() > 0) {
    Vector lastRow = (Vector) rows.get(rows.size() - 1);
    if ("TOTAL".equals(lastRow.get(0))) {
        totalDrStr  = lastRow.get(3).toString();
        totalCrStr  = lastRow.get(4).toString();
        closingBal  = lastRow.get(5).toString();
        closingDir  = lastRow.get(6).toString();
    }
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Agent Statement</title>
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
.tw-body{flex:1;min-height:0;overflow-y:auto;padding:12px 14px 20px;}
.tw-body::-webkit-scrollbar{width:5px;}
.tw-body::-webkit-scrollbar-thumb{background:var(--violet);border-radius:3px;}

/* Filter bar */
.filter-card{background:var(--card);border-radius:var(--r);padding:14px 16px;box-shadow:var(--shadow);display:flex;flex-wrap:wrap;gap:10px;align-items:flex-end;margin-bottom:14px;}
.filter-card label{display:block;font-size:11px;font-weight:600;color:var(--muted);margin-bottom:4px;}
.filter-card input,.filter-card select{height:34px;border:1px solid var(--border);border-radius:var(--r-sm);padding:0 10px;font-size:12px;background:var(--inp-bg);color:var(--text);outline:none;min-width:160px;}
.filter-card input:focus,.filter-card select:focus{border-color:var(--violet);}
.btn-search{height:34px;padding:0 20px;border:none;border-radius:var(--r-sm);background:var(--violet);color:#fff;font-size:12px;font-weight:600;cursor:pointer;}
.btn-search:hover{background:var(--violet-d);}
.btn-print{height:34px;padding:0 16px;border:none;border-radius:var(--r-sm);background:var(--navy);color:#fff;font-size:12px;font-weight:600;cursor:pointer;display:flex;align-items:center;gap:6px;}
.btn-print:hover{background:var(--navy2);}

/* Statement container */
.stmt-wrap{background:var(--card);border-radius:var(--r);box-shadow:var(--shadow);overflow:hidden;}

/* Statement header */
.stmt-header{background:var(--navy);color:#fff;padding:14px 20px;display:flex;justify-content:space-between;align-items:center;flex-wrap:wrap;gap:8px;}
.stmt-header .co-name{font-size:16px;font-weight:700;letter-spacing:.5px;}
.stmt-header .ac-name{font-size:12px;opacity:.85;margin-top:2px;}
.stmt-header .period{font-size:12px;text-align:right;line-height:1.7;}

/* Table */
.stmt-table{width:100%;border-collapse:collapse;}
.stmt-table thead th{background:var(--navy2);color:#fff;padding:8px 10px;font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.4px;white-space:nowrap;}
.stmt-table th.num,.stmt-table td.num{text-align:right;}
.stmt-table td{padding:6px 10px;font-size:12px;border-bottom:1px solid var(--border-l);vertical-align:top;}
.stmt-table tr:hover td{background:#f5f7ff;}
.stmt-table tr.row-open td{background:#fffbf0;font-style:italic;}
.stmt-table tr.row-total td{background:var(--navy);color:#fff;font-weight:700;font-size:12px;}
.stmt-table tr.row-total:hover td{background:var(--navy);}
.stmt-table tr.row-pax td{background:#fafcff;border-bottom:1px dotted #e0e6f0;}
.stmt-table tr.row-pax:hover td{background:#f0f4ff;}

.particulars-main{font-weight:600;color:var(--text);}
.particulars-sub{font-size:11px;color:var(--muted);margin-top:2px;}
.particulars-route{font-size:11px;color:var(--violet);font-weight:600;margin-top:1px;}
.pax-label{font-size:11px;color:var(--muted);font-style:italic;}
.bal-dr{color:var(--red);font-weight:600;}
.bal-cr{color:var(--green);font-weight:600;}
.bal-nil{color:var(--muted);}
.dr-amt{color:#b45309;font-weight:600;}
.cr-amt{color:var(--green);font-weight:600;}
.badge-party{font-size:9px;padding:1px 5px;border-radius:3px;font-weight:700;margin-left:4px;}
.badge-buy{background:#fff3e0;color:#e65100;}
.badge-sell{background:#e8f5e9;color:#2e7d32;}
.badge-cust{background:#e3f2fd;color:#1565c0;}

/* Summary chips */
.summary-row{display:flex;gap:10px;flex-wrap:wrap;padding:12px 16px;border-bottom:1px solid var(--border);}
.s-chip{flex:1;min-width:120px;background:var(--bg);border-radius:var(--r-sm);padding:8px 12px;text-align:center;}
.s-chip .s-lbl{font-size:10px;font-weight:700;color:var(--muted);text-transform:uppercase;}
.s-chip .s-val{font-size:16px;font-weight:700;margin-top:2px;}
.s-chip.chip-dr .s-val{color:var(--red);}
.s-chip.chip-cr .s-val{color:var(--green);}
.s-chip.chip-bal .s-val{color:var(--violet);}

/* Empty */
.empty-state{padding:60px 20px;text-align:center;color:var(--muted);}
.empty-state i{font-size:40px;opacity:.3;margin-bottom:10px;}

/* Print styles */
@media print {
    .tw-nav,.filter-card,.btn-print,.no-print{display:none!important;}
    html,body{height:auto;background:#fff;font-size:11pt;}
    .tw,.tw-body{height:auto;overflow:visible;}
    .stmt-wrap{box-shadow:none;border-radius:0;}
    .stmt-header{background:#1a2744!important;-webkit-print-color-adjust:exact;print-color-adjust:exact;}
    .stmt-table thead th{background:#243159!important;-webkit-print-color-adjust:exact;print-color-adjust:exact;}
    .stmt-table tr.row-total td{background:#1a2744!important;color:#fff!important;-webkit-print-color-adjust:exact;print-color-adjust:exact;}
    .stmt-table td{padding:4px 8px;font-size:10pt;}
    .stmt-table tr:hover td{background:transparent;}
    @page{size:A4 landscape;margin:10mm 8mm;}
}
</style>
</head>
<body>
<div class="tw">
<div class="tw-nav"><%@ include file="/assets/navbar/navbar.jsp" %></div>
<div class="tw-body">

<!-- Filter -->
<form method="GET" action="" class="filter-card no-print">
    <div>
        <label>From Date</label>
        <input type="date" name="fromDate" value="<%=fromDate%>">
    </div>
    <div>
        <label>To Date</label>
        <input type="date" name="toDate" value="<%=toDate%>">
    </div>
    <div>
        <label>Agent <span style="color:var(--red)">*</span></label>
        <select name="agentId" required style="min-width:200px;">
            <option value="">-- Select Agent --</option>
            <% for (int i = 0; i < agents.size(); i++) {
                Vector ag = (Vector) agents.get(i);
                String aId   = ag.get(0) != null ? ag.get(0).toString() : "";
                String aName = ag.get(1) != null ? ag.get(1).toString() : "";
                boolean sel  = aId.equals(String.valueOf(agentId));
            %>
            <option value="<%=aId%>" <%=sel?"selected":""%>><%=aName%></option>
            <% } %>
        </select>
    </div>
    <button type="submit" class="btn-search"><i class="fa-solid fa-magnifying-glass" style="margin-right:5px;"></i>View Statement</button>
    <% if (agentId > 0 && rows.size() > 1) { %>
    <button type="button" class="btn-print" onclick="window.print()"><i class="fa-solid fa-print"></i>Print</button>
    <% } %>
</form>

<% if (agentId == 0) { %>
<!-- No agent selected -->
<div class="stmt-wrap">
    <div class="empty-state">
        <i class="fa-solid fa-book-open"></i>
        <div style="font-size:15px;font-weight:600;margin-bottom:6px;">Select an Agent</div>
        <div style="font-size:12px;">Choose an agent and date range to view the account statement.</div>
    </div>
</div>
<% } else { %>

<!-- Statement -->
<div class="stmt-wrap" id="stmtArea">

    <!-- Header -->
    <div class="stmt-header">
        <div>
            <div class="co-name"><%=companyName.toUpperCase()%></div>
            <div class="ac-name">A/c Name: <%=selectedAgentName.toUpperCase()%></div>
        </div>
        <div class="period">
            Period From : <%=fromDisp%> To <%=toDisp%>
        </div>
    </div>

    <% // Count TXN rows only (excluding OPEN and TOTAL)
       int txnCount = 0;
       for (int i = 0; i < rows.size(); i++) {
           Vector r = (Vector) rows.get(i);
           if ("TXN".equals(r.get(0))) txnCount++;
       }
    %>

    <% if (txnCount == 0) { %>
    <div class="empty-state">
        <i class="fa-solid fa-inbox"></i>
        <div style="font-size:14px;font-weight:600;margin-bottom:6px;">No Transactions Found</div>
        <div style="font-size:12px;">No ledger entries for <%=selectedAgentName%> in this period.</div>
    </div>
    <% } else { %>

    <!-- Summary chips -->
    <div class="summary-row no-print">
        <div class="s-chip chip-dr">
            <div class="s-lbl">Total DR (Charged)</div>
            <div class="s-val"><%=totalDrStr%></div>
        </div>
        <div class="s-chip chip-cr">
            <div class="s-lbl">Total CR (Received)</div>
            <div class="s-val"><%=totalCrStr%></div>
        </div>
        <div class="s-chip chip-bal">
            <div class="s-lbl">Closing Balance</div>
            <div class="s-val <%="DR".equals(closingDir)?"bal-dr":"CR".equals(closingDir)?"bal-cr":"bal-nil"%>">
                <%=closingBal%> <span style="font-size:11px;"><%="NIL".equals(closingDir)?"":closingDir%></span>
            </div>
        </div>
        <div class="s-chip">
            <div class="s-lbl">Transactions</div>
            <div class="s-val" style="color:var(--navy);"><%=txnCount%></div>
        </div>
    </div>

    <!-- Table -->
    <div style="overflow-x:auto;">
    <table class="stmt-table">
        <thead>
            <tr>
                <th style="width:88px;">Date</th>
                <th style="width:90px;">Vou.Number</th>
                <th>Particulars</th>
                <th class="num" style="width:110px;">Dr.Amount</th>
                <th class="num" style="width:110px;">Cr.Amount</th>
                <th class="num" style="width:130px;">Balance</th>
            </tr>
        </thead>
        <tbody>
        <%
        for (int i = 0; i < rows.size(); i++) {
            Vector r = (Vector) rows.get(i);
            String rowType   = r.get(0) != null ? r.get(0).toString() : "";
            String txnDate   = r.get(1) != null ? r.get(1).toString() : "";
            String vouNo     = r.get(2) != null ? r.get(2).toString() : "";
            String drAmt     = r.get(3) != null ? r.get(3).toString() : "";
            String crAmt     = r.get(4) != null ? r.get(4).toString() : "";
            String balance   = r.get(5) != null ? r.get(5).toString() : "";
            String balDir    = r.get(6) != null ? r.get(6).toString() : "";
            String partMain  = r.get(7) != null ? r.get(7).toString() : "";
            String route     = r.get(8) != null ? r.get(8).toString() : "";
            String flightInf = r.get(9) != null ? r.get(9).toString() : "";
            String extraPax  = r.get(10) != null ? r.get(10).toString() : "";
            String pType     = r.get(12) != null ? r.get(12).toString() : "";

            String balCls = "DR".equals(balDir) ? "bal-dr" : "CR".equals(balDir) ? "bal-cr" : "bal-nil";
            String balDisplay = "NIL".equals(balDir) ? "0.00" : balance + " " + balDir;

            if ("OPEN".equals(rowType)) {
        %>
        <tr class="row-open">
            <td style="color:var(--muted);font-size:11px;">b/f</td>
            <td style="color:var(--muted);font-size:11px;">Opening Balance</td>
            <td></td>
            <td class="num dr-amt"><%=drAmt.isEmpty()?"":drAmt%></td>
            <td class="num cr-amt"><%=crAmt.isEmpty()?"":crAmt%></td>
            <td class="num <%=balCls%>"><%=balDisplay%></td>
        </tr>
        <%
            } else if ("TOTAL".equals(rowType)) {
        %>
        <tr class="row-total">
            <td colspan="3" style="text-align:right;letter-spacing:.5px;">TOTAL</td>
            <td class="num"><%=drAmt%></td>
            <td class="num"><%=crAmt%></td>
            <td class="num <%=balCls%>" style="color:#fff;"><%=balDisplay%></td>
        </tr>
        <%
            } else {
                // Determine party badge
                String badgeCls = "", badgeLbl = "";
                if ("BUY_AGENT".equals(pType))   { badgeCls="badge-buy";  badgeLbl="Buy";  }
                else if ("SELL_AGENT".equals(pType)) { badgeCls="badge-sell"; badgeLbl="Sell"; }
                else if ("CUSTOMER".equals(pType))   { badgeCls="badge-cust"; badgeLbl="Cust"; }
        %>
        <tr>
            <td style="white-space:nowrap;color:var(--muted);"><%=txnDate%></td>
            <td style="white-space:nowrap;font-size:11px;">
                <%=vouNo%>
                <% if (!badgeLbl.isEmpty()) { %><span class="badge-party <%=badgeCls%>"><%=badgeLbl%></span><% } %>
            </td>
            <td>
                <div class="particulars-main"><%=partMain%></div>
                <% if (!flightInf.isEmpty()) { %><div class="particulars-sub"><%=flightInf%></div><% } %>
                <% if (!route.isEmpty()) { %><div class="particulars-route"><%=route%></div><% } %>
            </td>
            <td class="num dr-amt"><%=drAmt.isEmpty()?"":drAmt%></td>
            <td class="num cr-amt"><%=crAmt.isEmpty()?"":crAmt%></td>
            <td class="num <%=balCls%>"><%=balDisplay%></td>
        </tr>
        <%
                // Extra passengers as sub-rows
                if (!extraPax.isEmpty()) {
                    String[] paxList = extraPax.split("\\|\\|");
                    for (int p = 0; p < paxList.length; p++) {
                        String paxName = paxList[p].trim();
                        if (paxName.isEmpty()) continue;
        %>
        <tr class="row-pax">
            <td></td>
            <td class="pax-label">pax-<%=(p+2)%></td>
            <td><div class="particulars-main" style="font-size:11px;"><%=paxName%></div></td>
            <td></td><td></td><td></td>
        </tr>
        <%
                    }
                }
            } // end TXN row
        } // end for
        %>
        </tbody>
    </table>
    </div>
    <% } // end txnCount > 0 %>
</div>
<% } // end agentId > 0 %>

</div><!-- tw-body -->
</div><!-- tw -->
</body>
</html>
