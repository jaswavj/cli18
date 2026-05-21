<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,java.text.SimpleDateFormat"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<jsp:useBean id="userB"   class="user.userBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
String ctx = request.getContextPath();

String today = new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
String fromDate = request.getParameter("fromDate");
String toDate   = request.getParameter("toDate");
if (fromDate == null || fromDate.isEmpty()) fromDate = today;
if (toDate   == null || toDate.isEmpty())   toDate   = today;

boolean searched = request.getParameter("fromDate") != null;
Vector logs = new Vector();
if (searched) { try { logs = billing.getBookingLogs(fromDate, toDate); } catch(Exception e){} }
int totalEdit=0, totalCancel=0;
for(int i=0;i<logs.size();i++){
    Vector r=(Vector)logs.get(i);
    String at=r.get(4)!=null?r.get(4).toString():"";
    if("EDIT".equals(at)) totalEdit++;
    else if("CANCEL".equals(at)) totalCancel++;
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Edit / Cancel Log</title>
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
.fg-inp::placeholder{color:rgba(255,255,255,.4);}
.fg-inp:focus,.fg-sel:focus{border-color:var(--gold);background:rgba(255,255,255,.18);}
.bb{display:inline-flex;align-items:center;gap:6px;height:33px;padding:0 15px;border-radius:var(--r-sm);font-size:12px;font-weight:700;cursor:pointer;border:1.5px solid transparent;transition:all .15s;white-space:nowrap;text-decoration:none;}
.bb-gold{background:var(--gold);color:#fff;border-color:var(--gold);}
.bb-gold:hover{background:#a87520;}
.bb-outline-white{background:transparent;color:#fff;border-color:rgba(255,255,255,.4);}
.bb-outline-white:hover{background:rgba(255,255,255,.1);}
.sum-bar{background:var(--card);border:1px solid var(--border-l);border-radius:var(--r);box-shadow:var(--shadow);padding:10px 16px;margin-bottom:12px;display:flex;align-items:center;gap:12px;flex-wrap:wrap;}
.sum-chip{display:flex;align-items:center;gap:7px;padding:6px 14px;border-radius:6px;font-size:12px;font-weight:700;}
.sum-chip i{font-size:13px;}
.chip-violet{background:#f0edf8;color:var(--violet);}
.chip-green{background:#e8f5e9;color:#2e7d32;}
.chip-red{background:#fce8e8;color:#b71c1c;}
.tbl-wrap{overflow-x:auto;border-radius:var(--r);box-shadow:var(--shadow);}
.rpt-table{width:100%;border-collapse:collapse;background:var(--card);font-size:12px;}
.rpt-table thead tr{background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);}
.rpt-table thead th{color:#fff;padding:9px 10px;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;white-space:nowrap;border-right:1px solid rgba(255,255,255,.1);}
.rpt-table thead th:first-child{border-radius:var(--r) 0 0 0;}
.rpt-table thead th:last-child{border-right:none;border-radius:0 var(--r) 0 0;}
.rpt-table tbody tr{border-bottom:1px solid var(--border-l);transition:background .1s;}
.rpt-table tbody tr:hover{background:#f5f3fb;}
.rpt-table tbody tr:last-child{border-bottom:none;}
.rpt-table td{padding:8px 10px;color:var(--text);vertical-align:middle;white-space:nowrap;}
.rpt-table td.wrap{white-space:normal;max-width:220px;word-break:break-word;}
.badge{display:inline-flex;align-items:center;gap:4px;padding:2px 9px;border-radius:3px;font-size:10px;font-weight:800;letter-spacing:.3px;}
.badge-edit{background:#e8f5e9;color:#2e7d32;border:1px solid #c8e6c9;}
.badge-cancel{background:#fce8e8;color:#b71c1c;border:1px solid #ffcdd2;}
.empty-state{text-align:center;padding:50px 20px;color:var(--muted);}
.empty-state i{font-size:48px;color:#d1d9e6;margin-bottom:12px;display:block;}
.empty-state h3{font-size:15px;font-weight:700;margin-bottom:6px;}
.sno{font-size:11px;color:var(--muted);font-weight:600;}
.change-list{display:flex;flex-wrap:wrap;gap:4px;min-width:180px;max-width:360px;}
.change-pill{display:inline-flex;align-items:center;gap:3px;background:#f0edf8;border:1px solid #d4cce8;border-radius:4px;padding:2px 7px;font-size:10px;color:#3d2f6e;white-space:nowrap;}
.change-pill .arrow{color:#8b7bb5;font-style:normal;margin:0 2px;}
.change-pill .label{font-weight:700;color:#5c4d8a;margin-right:3px;}
.change-pill .old{text-decoration:line-through;color:var(--red);opacity:.8;}
.change-pill .nw{color:var(--green);font-weight:700;}
</style>
</head>
<body>
<div class="tw">
  <div class="tw-nav"><%@ include file="/assets/navbar/navbar.jsp" %></div>

  <div class="tb-header">
    <div class="tb-header-title">
      <i class="fa-solid fa-clock-rotate-left"></i>
      <span>Edit / Cancel Log</span>
    </div>
    <div class="tb-divider"></div>
    <form method="get" style="display:contents;">
      <div class="fg">
        <div class="fg-lbl">From Date</div>
        <input type="date" name="fromDate" class="fg-inp" value="<%=fromDate%>" style="width:140px;">
      </div>
      <div class="fg">
        <div class="fg-lbl">To Date</div>
        <input type="date" name="toDate" class="fg-inp" value="<%=toDate%>" style="width:140px;">
      </div>
      <button type="submit" class="bb bb-gold" style="align-self:flex-end;">
        <i class="fa-solid fa-magnifying-glass"></i> Search
      </button>
    </form>
    <div class="hdr-spacer"></div>
    <a href="<%=ctx%>/ticketbooking/page.jsp" class="bb bb-outline-white">
      <i class="fa-solid fa-arrow-left"></i> Back
    </a>
  </div>

  <div class="tw-body">
    <%if(searched){%>
    <div class="sum-bar">
      <div class="sum-chip chip-violet"><i class="fa-solid fa-list"></i> Total: <%=logs.size()%></div>
      <div class="sum-chip chip-green"><i class="fa-solid fa-pen-to-square"></i> Edits: <%=totalEdit%></div>
      <div class="sum-chip chip-red"><i class="fa-solid fa-ban"></i> Cancels: <%=totalCancel%></div>
    </div>

    <div class="tbl-wrap">
      <table class="rpt-table">
        <thead>
          <tr>
            <th>#</th>
            <th>Date</th>
            <th>Time</th>
            <th>Ticket No</th>
            <th>PNR</th>
            <th>Action</th>
            <th>Changed By</th>
            <th>Remarks</th>
            <th>Changes</th>
          </tr>
        </thead>
        <tbody>
          <%if(logs.isEmpty()){%>
          <tr><td colspan="9">
            <div class="empty-state">
              <i class="fa-solid fa-clock-rotate-left"></i>
              <h3>No logs found</h3>
              <p>No edit or cancel actions were recorded for the selected date range.</p>
            </div>
          </td></tr>
          <%}else{%>
          <%for(int i=0;i<logs.size();i++){
            Vector r=(Vector)logs.get(i);
            String ticketNo= r.get(2)!=null?r.get(2).toString():"—";
            String pnrVal  = r.get(3)!=null?r.get(3).toString():"—";
            String action  = r.get(4)!=null?r.get(4).toString():"";
            String uname   = r.get(5)!=null?r.get(5).toString():"—";
            String chDate  = r.get(6)!=null?r.get(6).toString():"";
            String chTime  = r.get(7)!=null?r.get(7).toString():"";
            String remarks = r.get(8)!=null?r.get(8).toString():"";
            String description = r.size()>9 && r.get(9)!=null ? r.get(9).toString() : "";
            boolean isCancel = "CANCEL".equals(action);
          %>
          <tr>
            <td class="sno"><%=i+1%></td>
            <td><%=chDate%></td>
            <td style="color:var(--muted);"><%=chTime%></td>
            <td style="font-weight:700;letter-spacing:.5px;"><%=ticketNo%></td>
            <td style="color:var(--violet);font-weight:700;letter-spacing:.5px;"><%=pnrVal%></td>
            <td>
              <%if(isCancel){%>
                <span class="badge badge-cancel"><i class="fa-solid fa-ban"></i> CANCEL</span>
              <%}else{%>
                <span class="badge badge-edit"><i class="fa-solid fa-pen-to-square"></i> EDIT</span>
              <%}%>
            </td>
            <td><%=uname%></td>
            <td class="wrap"><%=remarks.isEmpty()?"<span style='color:var(--muted);font-style:italic;'>—</span>":remarks%></td>
            <td>
              <%if(!description.isEmpty()){
                String[] lines = description.split("\n");
                out.print("<div class='change-list'>");
                for(String line : lines){
                  line = line.trim(); if(line.isEmpty()) continue;
                  int arrowIdx = line.indexOf(" → ");
                  if(arrowIdx>0){
                    int colonIdx = line.indexOf(": ");
                    String lbl = colonIdx>0 ? line.substring(0,colonIdx) : "";
                    String rest = colonIdx>0 ? line.substring(colonIdx+2) : line;
                    int ai = rest.indexOf(" → ");
                    String oldV = ai>0 ? rest.substring(0,ai) : rest;
                    String newV = ai>0 ? rest.substring(ai+3) : "";
                    String eLbl = lbl.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;");
                    String eOld = (oldV.isEmpty()?"—":oldV).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;");
                    String eNew = (newV.isEmpty()?"—":newV).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;");
                    out.print("<span class='change-pill'><span class='label'>"+eLbl+":</span><span class='old'>"+eOld+"</span><i class='arrow fa-solid fa-arrow-right' style='font-size:8px;'></i><span class='nw'>"+eNew+"</span></span>");
                  } else {
                    out.print("<span class='change-pill'>"+line.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")+"</span>");
                  }
                }
                out.print("</div>");
              }else{%>
                <span style="color:var(--muted);font-style:italic;">—</span>
              <%}%>
            </td>
          </tr>
          <%}%>
          <%}%>
        </tbody>
      </table>
    </div>
    <%}else{%>
    <div class="empty-state">
      <i class="fa-solid fa-clock-rotate-left"></i>
      <h3>Select a date range</h3>
      <p>Choose From Date and To Date, then click Search to view the edit/cancel audit log.</p>
    </div>
    <%}%>
  </div>
</div>
</body>
</html>
