<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,java.text.SimpleDateFormat,java.text.DecimalFormat"%>
<%!
private void applyLedgerRunningRow(String partyType, String chargeType, String txnType,
        double bill, double paid, double[] state) {
    if ("BALANCE_COLLECT".equals(chargeType)) {
        double amt = paid;
        double c = Math.min(amt, state[0]); state[0] -= c; amt -= c;
        c = Math.min(amt, state[1]); state[1] -= c; amt -= c;
        if (amt > 0.005) state[1] += amt;
    } else if ("BALANCE_PAY".equals(chargeType)) {
        double amt = paid;
        double p = Math.min(amt, state[1]); state[1] -= p; amt -= p;
        if (amt > 0.005) state[0] += amt;
    } else if ("ADVANCE_COLLECT".equals(chargeType)) {
        state[1] -= Math.min(paid, state[1]);
    } else if ("ADVANCE_PAID".equals(chargeType)) {
        state[0] += paid;
    } else if ("ADVANCE_CREDIT".equals(chargeType)) {
        state[1] += paid;
    } else if (bill > 0.005) {
        double unpaid = Math.max(0, bill - paid);
        if ("DR".equals(txnType) || "SELL_AGENT".equals(partyType)) state[0] += unpaid;
        else if ("CR".equals(txnType) || "BUY_AGENT".equals(partyType)) state[1] += unpaid;
    }
}
private String runningBalanceClass(double runDue, double runAdvance) {
    if (runDue > 0.005) return "due";
    if (runAdvance > 0.005) return "credit";
    return "zero";
}
private double runningBalanceAmount(double runDue, double runAdvance) {
    if (runDue > 0.005) return runDue;
    if (runAdvance > 0.005) return runAdvance;
    return 0;
}
%>
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
String ticketWiseP = request.getParameter("ticketWise");
if (fromDate == null || fromDate.isEmpty()) fromDate = today;
if (toDate   == null || toDate.isEmpty())   toDate   = today;
boolean showTicketWise = "1".equals(ticketWiseP);
int agentId = 0;
try { if (agentIdP != null && !agentIdP.isEmpty()) agentId = Integer.parseInt(agentIdP); } catch (Exception e) {}

Vector agents = billing.getTicketAgents();

// Company name (use direct instantiation to avoid duplicate bean with navbar.jsp)
String companyName = "MOULANA AIR TRAVELS";
String companyAddress = "";
try {
    user.userBean uBean = new user.userBean();
    Vector companyInfo = uBean.getCompanyDetails();
    if (companyInfo != null && companyInfo.size() > 1 && companyInfo.get(1) != null)
        companyName = companyInfo.get(1).toString();
    if (companyInfo != null && companyInfo.size() > 2 && companyInfo.get(2) != null)
        companyAddress = companyInfo.get(2).toString();
} catch (Exception e) { /* use default */ }

// Data (only load when agent is selected)
Vector ledgerRows = new Vector();
String selectedAgentName = "";
double totalAdvance = 0, totalAgentDue = 0;
Vector payRows = new Vector();
DecimalFormat df = new DecimalFormat("0.00");
double totalBill = 0, totalPaid = 0, lastBal = 0;
String lastBalCls = "zero";
double[] runState = new double[]{0, 0};

if (agentId > 0) {
    ledgerRows = billing.getTicketLedgerReport(fromDate, toDate, agentId);
    Vector agentAcctTotals = billing.getAgentAccountTotals(agentId);
    totalAdvance = agentAcctTotals.size() > 0 ? Double.parseDouble(agentAcctTotals.get(0).toString()) : 0;
    totalAgentDue = agentAcctTotals.size() > 1 ? Double.parseDouble(agentAcctTotals.get(1).toString()) : 0;
    for (int i = 0; i < agents.size(); i++) {
        Vector a = (Vector) agents.get(i);
        if (Integer.parseInt(a.get(0).toString()) == agentId) {
            selectedAgentName = a.get(1).toString();
            break;
        }
    }
    // Ticket-wise view data
    Vector payRowsBuy  = billing.getTicketPaymentsDetail(fromDate, toDate, agentId, "BUY");
    Vector payRowsSell = billing.getTicketPaymentsDetail(fromDate, toDate, agentId, "SELL");
    for (int i = 0; i < payRowsBuy.size(); i++)  payRows.add(payRowsBuy.get(i));
    for (int i = 0; i < payRowsSell.size(); i++) payRows.add(payRowsSell.get(i));

    // Keep ticket-wise list in first-entry order (oldest entry first).
    java.util.Collections.sort(payRows, new java.util.Comparator() {
        public int compare(Object o1, Object o2) {
            Vector a = (Vector) o1;
            Vector b = (Vector) o2;
            String d1 = a.get(11) != null ? a.get(11).toString() : "";
            String d2 = b.get(11) != null ? b.get(11).toString() : "";
            int c = d1.compareTo(d2);
            if (c != 0) return c;

            int id1 = 0, id2 = 0;
            try { id1 = a.get(0) != null ? Integer.parseInt(a.get(0).toString()) : 0; } catch (Exception e) { id1 = 0; }
            try { id2 = b.get(0) != null ? Integer.parseInt(b.get(0).toString()) : 0; } catch (Exception e) { id2 = 0; }
            return id1 - id2;
        }
    });

}

// Format date for display e.g. 07/05/2026
java.text.SimpleDateFormat dpFmt = new java.text.SimpleDateFormat("dd/MM/yyyy");
java.text.SimpleDateFormat iFmt  = new java.text.SimpleDateFormat("yyyy-MM-dd");
String fromDisp = fromDate, toDisp = toDate;
try { fromDisp = dpFmt.format(iFmt.parse(fromDate)); } catch (Exception e) {}
try { toDisp   = dpFmt.format(iFmt.parse(toDate));   } catch (Exception e) {}

// Ticket-wise payment summary map
// key -> bookingId|side (BUY/SELL), value -> map of totals and payment timeline
java.util.LinkedHashMap ticketPayMap = new java.util.LinkedHashMap();
java.util.HashMap bookingPaxMap = new java.util.HashMap();
for (int i = 0; i < payRows.size(); i++) {
    Vector pr = (Vector) payRows.get(i);
    int bookingId = 0;
    try { bookingId = pr.get(1) != null ? Integer.parseInt(pr.get(1).toString()) : 0; } catch (Exception e) { bookingId = 0; }
    if (bookingId <= 0) continue;

    String partyType = pr.get(4) != null ? pr.get(4).toString() : "";
    String side = "BUY_AGENT".equals(partyType) ? "BUY" : "SELL";
    String mapKey = String.valueOf(bookingId) + "|" + side;

    java.util.Map info = (java.util.Map) ticketPayMap.get(mapKey);
    if (info == null) {
        String passengerName = "-";
        String bookingKey = String.valueOf(bookingId);
        if (bookingPaxMap.containsKey(bookingKey)) {
            passengerName = bookingPaxMap.get(bookingKey) != null ? bookingPaxMap.get(bookingKey).toString() : "-";
        } else {
            try {
                Vector paxRows = billing.getPNRPassengers(bookingId);
                if (paxRows != null && paxRows.size() > 0) {
                    StringBuilder paxNamesBuilder = new StringBuilder();
                    for (int px = 0; px < paxRows.size(); px++) {
                        Vector paxRow = (Vector) paxRows.get(px);
                        String pName = (paxRow != null && paxRow.size() > 1 && paxRow.get(1) != null) ? paxRow.get(1).toString().trim() : "";
                        if (pName.isEmpty()) continue;
                        if (paxNamesBuilder.length() > 0) paxNamesBuilder.append(", ");
                        paxNamesBuilder.append(pName);
                    }
                    if (paxNamesBuilder.length() > 0) passengerName = paxNamesBuilder.toString();
                }
            } catch (Exception e) {
                passengerName = "-";
            }
            bookingPaxMap.put(bookingKey, passengerName);
        }

        info = new java.util.HashMap();
        info.put("bookingId", String.valueOf(bookingId));
        info.put("side", side);
        info.put("ticketNo", pr.get(2) != null ? pr.get(2).toString() : "-");
        info.put("pnr", pr.get(3) != null ? pr.get(3).toString() : "-");
        info.put("passengerName", passengerName);
        String rFrom = pr.get(12) != null ? pr.get(12).toString() : "";
        String rTo   = pr.get(13) != null ? pr.get(13).toString() : "";
        info.put("route", (!rFrom.isEmpty() && !rTo.isEmpty()) ? (rFrom + "/" + rTo) : "-");
        info.put("bill", new Double(0));
        info.put("paid", new Double(0));
        info.put("cashPaid", new Double(0));
        info.put("bankPaid", new Double(0));
        info.put("lastPayDate", "");
        info.put("entries", new java.util.ArrayList());
        ticketPayMap.put(mapKey, info);
    }

    double billAmt = 0, payAmt = 0;
    try { billAmt = pr.get(7) != null ? Double.parseDouble(pr.get(7).toString()) : 0; } catch (Exception e) { billAmt = 0; }
    try { payAmt  = pr.get(8) != null ? Double.parseDouble(pr.get(8).toString()) : 0; } catch (Exception e) { payAmt = 0; }
    String mode = pr.get(9) != null ? pr.get(9).toString() : "";
    String payDate = pr.get(11) != null ? pr.get(11).toString() : "";

    double oldBill = ((Double) info.get("bill")).doubleValue();
    double oldPaid = ((Double) info.get("paid")).doubleValue();
    double oldCash = ((Double) info.get("cashPaid")).doubleValue();
    double oldBank = ((Double) info.get("bankPaid")).doubleValue();

    info.put("bill", new Double(oldBill + billAmt));
    info.put("paid", new Double(oldPaid + payAmt));

    if (payAmt > 0.0001) {
        String modeLc = mode.toLowerCase();
        if (modeLc.contains("cash")) info.put("cashPaid", new Double(oldCash + payAmt));
        else                          info.put("bankPaid", new Double(oldBank + payAmt));

        if (!payDate.isEmpty()) {
            String prevDate = info.get("lastPayDate") != null ? info.get("lastPayDate").toString() : "";
            if (prevDate.isEmpty() || payDate.compareTo(prevDate) > 0) info.put("lastPayDate", payDate);
        }

        java.util.List entries = (java.util.List) info.get("entries");
        entries.add((payDate.isEmpty() ? "-" : payDate) + " | " + (mode.isEmpty() ? "-" : mode) + " | " + String.format("%.2f", payAmt));
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
    --shadow:0 2px 12px rgba(0,0,0,.10);--shadow-sm:0 1px 4px rgba(0,0,0,.06);
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
.chk-wrap{display:flex;align-items:center;gap:8px;height:34px;padding:0 10px;border:1px solid var(--border);border-radius:var(--r-sm);background:var(--inp-bg);}
.chk-wrap input[type="checkbox"]{width:15px;height:15px;accent-color:var(--violet);}
.chk-wrap label{margin:0;font-size:12px;font-weight:600;color:var(--text);cursor:pointer;user-select:none;}

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
.sum-row{display:flex;gap:10px;flex-wrap:wrap;padding:12px 16px;border-bottom:1px solid var(--border);}
.sum-chip{background:var(--card);border-radius:var(--r-sm);border:1px solid var(--border-l);padding:10px 16px;display:flex;flex-direction:column;gap:8px;min-width:180px;flex:1;max-width:320px;box-shadow:var(--shadow-sm);}
.sum-chip-top{display:flex;align-items:flex-start;justify-content:space-between;gap:10px;}
.sum-chip-body{display:flex;flex-direction:column;gap:3px;}
.sum-chip-lbl{font-size:10px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.5px;}
.sum-chip-val{font-size:18px;font-weight:800;}
.sum-chip.chip-advance .sum-chip-val{color:var(--green);}
.sum-chip.chip-agent-due .sum-chip-val{color:var(--red);}

/* Ledger table (new format) */
.rpt-table{width:100%;min-width:900px;border-collapse:collapse;font-size:12.5px;}
.tbl-wrap{overflow-x:auto;}
.rpt-table thead tr{background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);}
.rpt-table thead th{padding:10px;color:#fff;font-weight:700;text-transform:uppercase;font-size:10.5px;letter-spacing:.4px;white-space:nowrap;text-align:left;}
.rpt-table tbody tr{border-bottom:1px solid var(--border-l);}
.rpt-table tbody tr.ledger-row{cursor:pointer;}
.rpt-table tbody tr.ledger-row:hover{background:#eef2ff;}
.rpt-table tbody td{padding:9px 10px;vertical-align:middle;}
.rpt-table tfoot tr{background:#f1f5f9;border-top:2px solid var(--border);}
.rpt-table tfoot td{padding:9px 10px;font-weight:800;font-size:12.5px;}
.badge{display:inline-block;padding:2px 7px;border-radius:3px;font-size:10px;font-weight:700;}
.badge-buy{background:#fff3e0;color:#bf6000;border:1px solid #ffe0b2;}
.badge-sell{background:#e8f5e9;color:#1b5e20;border:1px solid #c8e6c9;}
.badge-cust{background:#e3f2fd;color:#0d47a1;border:1px solid #bbdefb;}
.badge-dr{background:#e8f5e9;color:#1b5e20;}
.badge-cr{background:#fff3e0;color:#bf6000;}
.bal-cell{font-weight:700;}
.bal-cell.zero{color:var(--green);}
.bal-cell.due{color:var(--red);}
.bal-cell.credit{color:var(--green);}
.pax-list{font-size:10px;line-height:1.5;}
.detail-grid{display:grid;grid-template-columns:1fr 1fr;gap:10px 16px;}
.detail-item{display:flex;flex-direction:column;gap:2px;}
.detail-item.full{grid-column:1/-1;}
.detail-lbl{font-size:10px;font-weight:700;color:var(--muted);text-transform:uppercase;}
.detail-val{font-size:13px;font-weight:600;word-break:break-word;}
.modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:2000;align-items:center;justify-content:center;}
.modal-overlay.active{display:flex;}
.modal-box{background:#fff;border-radius:var(--r);width:360px;max-width:95vw;box-shadow:0 8px 32px rgba(0,0,0,.25);overflow:hidden;}
.modal-box.detail-box{width:480px;max-width:96vw;}
.modal-head{background:linear-gradient(135deg,var(--navy),var(--navy2));padding:12px 16px;display:flex;align-items:center;justify-content:space-between;}
.modal-head-title{color:#fff;font-weight:800;font-size:13px;display:flex;align-items:center;gap:8px;}
.modal-head-title i{color:var(--gold);}
.modal-close{background:none;border:none;color:rgba(255,255,255,.7);font-size:18px;cursor:pointer;}
.modal-body{padding:16px;display:flex;flex-direction:column;gap:12px;}
.modal-foot{padding:12px 16px;display:flex;gap:8px;justify-content:flex-end;border-top:1px solid var(--border-l);}
.mfg{display:flex;flex-direction:column;gap:4px;}
.mfg label{font-size:10.5px;font-weight:700;color:var(--muted);text-transform:uppercase;}
.mfg input,.mfg select{height:34px;border:1.5px solid var(--border);border-radius:var(--r-sm);padding:0 10px;font-size:13px;width:100%;}
.mfg textarea{border:1.5px solid var(--border);border-radius:var(--r-sm);padding:8px 10px;font-size:13px;width:100%;resize:vertical;min-height:72px;font-family:inherit;}
.info-row{background:#fafafa;border-radius:var(--r-sm);padding:8px 12px;font-size:12px;}
.info-row span{font-weight:700;}
.bb{display:inline-flex;align-items:center;gap:6px;height:33px;padding:0 15px;border-radius:var(--r-sm);font-size:12px;font-weight:700;cursor:pointer;border:1.5px solid transparent;}
.bb-gold{background:var(--gold);color:#fff;border-color:var(--gold);}

/* Ticket-wise payment summary */
.ticket-pay-wrap{margin-top:12px;border-top:1px solid var(--border);padding:12px 12px 0;}
.ticket-pay-title{font-size:13px;font-weight:700;color:var(--navy);margin-bottom:8px;display:flex;align-items:center;gap:6px;}
.ticket-pay-note{font-size:11px;color:var(--muted);margin-bottom:8px;}
.tp-table{width:100%;border-collapse:collapse;}
.tp-table th{background:#eef2ff;color:#1e293b;padding:7px 8px;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.3px;border-bottom:1px solid #dbe5f2;white-space:nowrap;}
.tp-table td{padding:7px 8px;font-size:11px;border-bottom:1px solid #edf2f7;vertical-align:top;}
.tp-table th.num,.tp-table td.num{text-align:right;}
.tp-col-passenger{font-size:10px;color:var(--muted);line-height:1.35;}
.tp-mode-lines{font-size:10px;line-height:1.45;color:var(--muted);}
.tp-bal-pos{color:var(--red);font-weight:700;}
.tp-bal-zero{color:var(--green);font-weight:700;}
.tp-fbal-pos{color:var(--red);font-weight:700;}
.tp-fbal-neg{color:var(--green);font-weight:700;}
.tp-fbal-zero{color:var(--muted);font-weight:700;}

/* Empty */
.empty-state{padding:60px 20px;text-align:center;color:var(--muted);}
.empty-state i{font-size:40px;opacity:.3;margin-bottom:10px;}

/* Print styles */
@media print {
    .tw-nav,.filter-card,.btn-print,.no-print{display:none!important;}
    html,body{height:auto;background:#fff;font-size:11px;width:100%;}
    .tw,.tw-body{height:auto!important;overflow:visible!important;width:100%!important;}
    .tw-body{padding:4px 6px!important;}
    .print-header{display:flex!important;-webkit-print-color-adjust:exact;print-color-adjust:exact;}
    .stmt-wrap{box-shadow:none;border-radius:0;overflow:visible!important;width:100%!important;}
    .tbl-wrap{overflow:visible!important;width:100%!important;}
    .sum-row{display:flex!important;flex-wrap:wrap;gap:8px;padding:8px 0 10px!important;border-bottom:1px solid var(--border);}
    .sum-chip{box-shadow:none;padding:8px 12px!important;min-width:140px;flex:1;}
    .sum-chip-val{font-size:14pt!important;}
    .rpt-table{min-width:unset!important;width:100%!important;font-size:8pt!important;table-layout:fixed;}
    .rpt-table thead tr{background:#1a2744!important;-webkit-print-color-adjust:exact;print-color-adjust:exact;}
    .rpt-table thead th{color:#fff!important;padding:4px 3px!important;font-size:7pt!important;white-space:normal!important;word-break:break-word;line-height:1.25;}
    .rpt-table tbody td,.rpt-table tfoot td{padding:3px 4px!important;font-size:8pt!important;white-space:normal!important;word-break:break-word;overflow:visible!important;vertical-align:top!important;line-height:1.3;}
    .rpt-table tbody tr:hover{background:transparent!important;}
    .rpt-table tfoot tr{background:#f1f5f9!important;-webkit-print-color-adjust:exact;print-color-adjust:exact;}
    .badge{font-size:7pt!important;padding:1px 4px!important;}
    .pax-list{font-size:7.5pt!important;}
    .bal-cell{-webkit-print-color-adjust:exact;print-color-adjust:exact;}

    /* Ticket-wise print */
    .ticket-pay-wrap{padding:0!important;margin-top:8px!important;border-top:none!important;overflow:visible!important;}
    .ticket-pay-note{font-size:9pt!important;margin-bottom:6px!important;}
    .tp-table{width:100%!important;table-layout:fixed;font-size:8pt!important;}
    .tp-table th,.tp-table td{padding:3px 4px!important;white-space:normal!important;word-break:break-word;}
    .tp-col-pnr,.tp-col-route,.tp-col-cash,.tp-col-bank,.tp-col-last,.tp-col-entries{display:none!important;}

    *{-webkit-print-color-adjust:exact!important;print-color-adjust:exact!important;}
    @page{size:A4 landscape;margin:6mm 8mm;}
}
</style>
</head>
<body>
<div class="tw">

<!-- PRINT-ONLY HEADER -->
<div class="print-header" style="display:none;align-items:center;gap:14px;padding:10px 16px;background:linear-gradient(135deg,#1a2744 0%,#243159 100%);border-bottom:3px solid #c9922a;margin-bottom:8px;">
    <div style="flex:1;">
        <div style="color:#c9922a;font-size:18px;font-weight:900;letter-spacing:1px;text-transform:uppercase;"><%=companyName%></div>
        <%if (!companyAddress.isEmpty()){%><div style="color:rgba(255,255,255,.75);font-size:12px;margin-top:2px;"><%=companyAddress%></div><%}%>
    </div>
    <div style="text-align:right;color:rgba(255,255,255,.7);font-size:11px;">
        <div style="font-weight:700;color:#fff;">Agent Statement</div>
        <div style="color:#c9922a;font-weight:700;font-size:13px;margin-top:2px;"><%=selectedAgentName%></div>
        <div><%=fromDisp%> &nbsp;to&nbsp; <%=toDisp%></div>
    </div>
</div>

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
    <div>
        <label>&nbsp;</label>
        <div class="chk-wrap">
            <input type="checkbox" id="ticketWise" name="ticketWise" value="1" <%=showTicketWise?"checked":""%>>
            <label for="ticketWise">Show Ticket-wise List</label>
        </div>
    </div>
    <button type="submit" class="btn-search"><i class="fa-solid fa-magnifying-glass" style="margin-right:5px;"></i>View Statement</button>
    <% if (agentId > 0 && !ledgerRows.isEmpty()) { %>
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
    

    <% if (!showTicketWise) { %>

    <!-- Summary cards -->
    <div class="sum-row">
      <div class="sum-chip chip-advance">
        <div class="sum-chip-lbl">Agent Advance (We Have to Pay)</div>
        <div class="sum-chip-val">&#8377;<%=df.format(totalAdvance)%></div>
      </div>
      <div class="sum-chip chip-agent-due">
        <div class="sum-chip-lbl">Balance (Agent Has to Pay)</div>
        <div class="sum-chip-val">&#8377;<%=df.format(totalAgentDue)%></div>
      </div>
    </div>

    <% if (ledgerRows.isEmpty()) { %>
    <div class="empty-state">
        <i class="fa-solid fa-inbox"></i>
        <div style="font-size:14px;font-weight:600;margin-bottom:6px;">No Transactions Found</div>
        <div style="font-size:12px;">No ledger entries for <%=selectedAgentName%> in this period.</div>
    </div>
    <% } else { %>

    <div class="tbl-wrap">
    <table class="rpt-table">
        <thead>
          <tr>
            <th>#</th>
            <th>Date</th>
            <th>Ticket / PNR</th>
            <th>Passengers</th>
            <th>Party</th>
            <th>Type</th>
            <th>DR/CR</th>
            <th>Bill Amt</th>
            <th>Paid Amt</th>
            <th>Mode</th>
            <th>Txn No</th>
            <th>Balance</th>
          </tr>
        </thead>
        <tbody>
        <%
          int sno = 1;
          totalBill = 0; totalPaid = 0; lastBal = 0; lastBalCls = "zero";
          runState[0] = 0; runState[1] = 0;
          for (int i = 0; i < ledgerRows.size(); i++) {
            Vector r = (Vector) ledgerRows.get(i);
            int bookingId   = r.get(0) != null ? Integer.parseInt(r.get(0).toString()) : 0;
            String tktNo      = r.get(1) != null ? r.get(1).toString() : "-";
            String pnr        = r.get(2) != null ? r.get(2).toString() : "-";
            String partyType  = r.get(3) != null ? r.get(3).toString() : "";
            String partyDisp  = r.get(4) != null ? r.get(4).toString() : "-";
            double bill  = r.get(5) != null ? Math.abs(Double.parseDouble(r.get(5).toString())) : 0;
            double paid  = r.get(6) != null ? Math.abs(Double.parseDouble(r.get(6).toString())) : 0;
            String fdate = r.get(8) != null ? r.get(8).toString() : "";
            String txnTime = r.size() > 17 && r.get(17) != null ? r.get(17).toString().trim() : "";
            String payModeName   = r.get(11) != null ? r.get(11).toString() : "";
            String lastTxnNo     = r.get(12) != null ? r.get(12).toString() : "";
            String pName         = r.get(13) != null ? r.get(13).toString() : "";
            String txnType       = r.get(14) != null ? r.get(14).toString() : "";
            String remarks       = r.size() > 15 && r.get(15) != null ? r.get(15).toString() : "";
            String chargeType    = r.size() > 16 && r.get(16) != null ? r.get(16).toString() : "";
            String ledgerId      = r.size() > 18 && r.get(18) != null ? r.get(18).toString() : "";
            String remarksAttr   = remarks.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace("'","&#39;");
            String pNameAttr     = pName.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace("'","&#39;");
            String partyDispAttr = partyDisp.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace("'","&#39;");

            String ptBadge = "badge-cust", ptLabel = partyType;
            if ("BUY_AGENT".equals(partyType))       { ptBadge = "badge-buy";  ptLabel = "Buy Agent"; }
            else if ("SELL_AGENT".equals(partyType)) { ptBadge = "badge-sell"; ptLabel = "Sell Agent"; }
            else if ("AGENT_ACCOUNT".equals(partyType)) { ptBadge = "badge-sell"; ptLabel = "Agent Account"; }
            else if ("CUSTOMER".equals(partyType))   { ptBadge = "badge-cust"; ptLabel = "Customer"; }

            String typeLabel = chargeType;
            if ("BALANCE_PAY".equals(chargeType)) typeLabel = "Pay Balance";
            else if ("ADVANCE_PAID".equals(chargeType)) typeLabel = "Advance Paid";
            else if ("BALANCE_COLLECT".equals(chargeType)) typeLabel = "Balance Collect";
            else if ("ADVANCE_COLLECT".equals(chargeType)) typeLabel = "Advance Collect";
            else if ("ADVANCE_CREDIT".equals(chargeType)) typeLabel = "Advance Credit";
            else if ("ORIGINAL".equals(chargeType) || chargeType.isEmpty()) typeLabel = "Ticket";
            else if (chargeType.length() > 0) typeLabel = chargeType.replace('_', ' ');

            String txnBadge = "DR".equals(txnType) ? "badge-dr" : "badge-cr";
            if (bill > 0.005) totalBill += bill;
            totalPaid += paid;
            applyLedgerRunningRow(partyType, chargeType, txnType, bill, paid, runState);
            double bal = runningBalanceAmount(runState[0], runState[1]);
            String balCls = runningBalanceClass(runState[0], runState[1]);
            lastBal = bal; lastBalCls = balCls;
            String ptLabelAttr = ptLabel.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace("'","&#39;");
            String typeLabelAttr = typeLabel.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace("'","&#39;");
            String tktNoAttr = tktNo.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace("'","&#39;");
            String pnrAttr = pnr.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace("'","&#39;");
            String modeAttr = payModeName.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace("'","&#39;");
            String txnNoAttr = lastTxnNo.replace("&","&amp;").replace("\"","&quot;").replace("<","&lt;").replace("'","&#39;");
        %>
          <tr class="ledger-row"
              onclick="openLedgerDetail(this)"
              data-ledger-id="<%=ledgerId%>"
              data-booking-id="<%=bookingId%>"
              data-date="<%=fdate%>"
              data-time="<%=txnTime%>"
              data-ticket="<%=tktNoAttr%>"
              data-pnr="<%=pnrAttr%>"
              data-passengers="<%=pNameAttr%>"
              data-party="<%=partyDispAttr%>"
              data-party-type="<%=partyType%>"
              data-party-label="<%=ptLabelAttr%>"
              data-type="<%=typeLabelAttr%>"
              data-txn-type="<%=txnType%>"
              data-bill="<%=df.format(bill)%>"
              data-paid="<%=df.format(paid)%>"
              data-mode="<%=modeAttr%>"
              data-txn-no="<%=txnNoAttr%>"
              data-remarks="<%=remarksAttr%>"
              data-run-bal="<%=df.format(bal)%>"
              data-run-bal-cls="<%=balCls%>">
            <td style="color:var(--muted);"><%=sno++%></td>
            <td style="white-space:nowrap;">
              <div><%=fdate%></div>
              <% if (!txnTime.isEmpty()) { %><div style="font-size:10px;color:var(--muted);margin-top:2px;"><%=txnTime%></div><% } %>
            </td>
            <td>
              <div style="font-weight:700;color:var(--gold);"><%=tktNo%></div>
              <div style="font-size:11px;color:var(--muted);"><%=pnr%></div>
            </td>
            <td>
              <div class="pax-list">
              <% String[] paxArr = pName.isEmpty() ? new String[0] : pName.split(",");
                 for (int pi = 0; pi < paxArr.length; pi++) {
                   String pax = paxArr[pi].trim();
                   if (!pax.isEmpty()) { %>
              <div><i class="fa-solid fa-user" style="font-size:9px;color:var(--muted);margin-right:3px;"></i><%=pax%></div>
              <% }} if (paxArr.length == 0) { %><span style="color:var(--muted);">—</span><% } %>
              </div>
            </td>
            <td>
              <span class="badge <%=ptBadge%>"><%=ptLabel%></span>
              <div style="font-size:12px;margin-top:3px;font-weight:600;"><%=partyDisp%></div>
            </td>
            <td><%=typeLabel%></td>
            <td><span class="badge <%=txnBadge%>"><%=txnType%></span></td>
            <td style="font-weight:600;">&#8377;<%=df.format(bill)%></td>
            <td style="color:var(--green);font-weight:600;">&#8377;<%=df.format(paid)%></td>
            <td style="font-size:11px;"><%=payModeName.isEmpty() ? "-" : payModeName%></td>
            <td style="font-size:11px;color:var(--violet);font-weight:600;"><%=lastTxnNo.isEmpty() ? "—" : lastTxnNo%></td>
            <td class="bal-cell <%=balCls%>">&#8377;<%=df.format(Math.abs(bal))%></td>
          </tr>
        <% } %>
        </tbody>
        <tfoot>
          <tr>
            <td colspan="7" style="color:var(--muted);">TOTALS</td>
            <td>&#8377;<%=df.format(totalBill)%></td>
            <td style="color:var(--green);">&#8377;<%=df.format(totalPaid)%></td>
            <td></td><td></td>
            <td class="bal-cell <%=lastBalCls%>">&#8377;<%=df.format(Math.abs(lastBal))%></td>
          </tr>
        </tfoot>
    </table>
    </div>
    <% } %>
    <% } // end !showTicketWise %>

        <% if (showTicketWise && ticketPayMap.size() > 0) { %>
        <div class="ticket-pay-wrap">
            <div class="ticket-pay-title"><i class="fa-solid fa-money-check-dollar" style="color:var(--gold);"></i>Ticket-wise Payment & Balance</div>
            <div class="ticket-pay-note">Shows each ticket bill, paid amount, balance, running final balance, and payment date history for selected period.</div>
            <div style="overflow-x:auto;">
                <table class="tp-table">
                    <thead>
                        <tr>
                            <th class="tp-col-pnr" style="width:90px;">PNR</th>
                            <th class="tp-col-passenger" style="width:150px;">Passenger Name</th>
                            <th class="num tp-col-bill" style="width:90px;">Bill</th>
                            <th class="num tp-col-paid" style="width:90px;">Paid</th>
                            <th class="num tp-col-balance" style="width:90px;">Balance</th>
                            <th class="num tp-col-final" style="width:110px;">Final Balance</th>
                            <th class="tp-col-last" style="width:105px;">Last Paid On</th>
                            <th class="tp-col-entries">Payment Entries (Date | Mode | Amount)</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% double runningFinalBal = 0;
                       java.util.Iterator tIt = ticketPayMap.entrySet().iterator();
                       while (tIt.hasNext()) {
                           java.util.Map.Entry en = (java.util.Map.Entry) tIt.next();
                           java.util.Map info = (java.util.Map) en.getValue();
                           String side = info.get("side") != null ? info.get("side").toString() : "SELL";
                           String pnr = info.get("pnr") != null ? info.get("pnr").toString() : "-";
                           String passengerName = info.get("passengerName") != null ? info.get("passengerName").toString() : "-";
                           double billV = ((Double) info.get("bill")).doubleValue();
                           double paidV = ((Double) info.get("paid")).doubleValue();
                           double diffV = billV - paidV;
                           double balV = diffV > 0 ? diffV : 0;
                              if ("BUY".equals(side)) runningFinalBal -= balV;
                              else                    runningFinalBal += balV;

                              String fBalCls = Math.abs(runningFinalBal) < 0.005 ? "tp-fbal-zero" : (runningFinalBal > 0 ? "tp-fbal-pos" : "tp-fbal-neg");
                           String lastPay = info.get("lastPayDate") != null ? info.get("lastPayDate").toString() : "";
                           java.util.List entries = (java.util.List) info.get("entries");
                           String balCls = Math.abs(balV) < 0.005 ? "tp-bal-zero" : "tp-bal-pos";
                    %>
                        <tr>
                            <td class="tp-col-pnr"><%=pnr%></td>
                            <td class="tp-col-passenger"><%=passengerName%></td>
                            <td class="num tp-col-bill"><%=String.format("%.2f", billV)%></td>
                            <td class="num tp-col-paid" style="color:var(--green);font-weight:700;"><%=String.format("%.2f", paidV)%></td>
                            <td class="num tp-col-balance <%=balCls%>"><%=String.format("%.2f", balV)%></td>
                            <td class="num tp-col-final <%=fBalCls%>"><%=String.format("%.2f", Math.abs(runningFinalBal))%></td>
                            <td class="tp-col-last" style="white-space:nowrap;"><%=lastPay.isEmpty() ? "-" : lastPay%></td>
                            <td class="tp-col-entries">
                                <% if (entries == null || entries.size() == 0) { %>
                                    <span class="tp-mode-lines">-</span>
                                <% } else { %>
                                    <div class="tp-mode-lines">
                                    <% for (int ei = 0; ei < entries.size(); ei++) { %>
                                        <div><%=entries.get(ei)%></div>
                                    <% } %>
                                    </div>
                                <% } %>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>
        </div>
        <% } %>

        <% if (showTicketWise && ticketPayMap.size() == 0) { %>
        <div class="ticket-pay-wrap">
            <div class="ticket-pay-title"><i class="fa-solid fa-money-check-dollar" style="color:var(--gold);"></i>Ticket-wise Payment & Balance</div>
            <div class="ticket-pay-note">No ticket-wise payment entries found for the selected filters.</div>
        </div>
        <% } %>
</div>
<% } // end agentId > 0 %>

</div><!-- tw-body -->
</div><!-- tw -->

<!-- Ledger detail modal -->
<div class="modal-overlay" id="ledgerDetailModal">
  <div class="modal-box detail-box">
    <div class="modal-head">
      <div class="modal-head-title"><i class="fa-solid fa-receipt"></i> Ledger Details</div>
      <button class="modal-close" onclick="closeLedgerDetail()">&times;</button>
    </div>
    <div class="modal-body" id="ledgerDetailBody"></div>
    <div class="modal-foot">
      <button class="bb bb-gold" onclick="closeLedgerDetail()">Close</button>
    </div>
  </div>
</div>

<script>
function openLedgerDetail(row) {
  if (!row || !row.dataset) return;
  const d = row.dataset;
  const balCls = d.runBalCls || 'zero';
  const balColor = balCls === 'due' ? 'var(--red)' : 'var(--green)';
  const dateTime = d.date + (d.time ? ' &nbsp;' + d.time : '');

  document.getElementById('ledgerDetailBody').innerHTML =
    '<div class="detail-grid">' +
      detailItem('Ledger ID', d.ledgerId || '—') +
      detailItem('Date &amp; Time', dateTime) +
      detailItem('Ticket No', d.ticket || '—') +
      detailItem('PNR', d.pnr || '—') +
      detailItem('Booking ID', d.bookingId && d.bookingId !== '0' ? d.bookingId : '—') +
      detailItem('Party Type', d.partyLabel || d.partyType || '—') +
      detailItem('Agent / Party', d.party || '—') +
      detailItem('Entry Type', d.type || '—') +
      detailItem('DR / CR', d.txnType || '—') +
      detailItem('Bill Amount', '&#8377;' + (d.bill || '0.00'), 'amt') +
      detailItem('Paid Amount', '&#8377;' + (d.paid || '0.00'), 'amt-green') +
      detailItem('Payment Mode', d.mode || '—') +
      detailItem('Transaction No', d.txnNo || '—') +
      detailItem('Running Balance', '&#8377;' + (d.runBal || '0.00'), null, balColor) +
      detailItem('Passengers', d.passengers || '—', 'full') +
      detailItem('Remarks', d.remarks || '—', 'full') +
    '</div>';

  document.getElementById('ledgerDetailModal').classList.add('active');
}

function detailItem(label, value, cls, color) {
  let valCls = 'detail-val';
  if (cls === 'amt-green') valCls += ' amt-green';
  const style = color ? ' style="color:' + color + ';"' : (cls === 'amt-green' ? ' style="color:var(--green);"' : '');
  const colCls = cls === 'full' ? ' detail-item full' : ' detail-item';
  return '<div class="' + colCls.trim() + '"><div class="detail-lbl">' + label + '</div><div class="' + valCls + '"' + style + '>' + (value || '—') + '</div></div>';
}

function closeLedgerDetail() {
  document.getElementById('ledgerDetailModal').classList.remove('active');
}

document.getElementById('ledgerDetailModal').addEventListener('click', function(e) {
  if (e.target === this) closeLedgerDetail();
});

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
