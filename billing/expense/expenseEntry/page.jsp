<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
String ctx = request.getContextPath();
String today = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
String nowTime = new java.text.SimpleDateFormat("HH:mm").format(new java.util.Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Expense Entry</title>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<%@ include file="/assets/common/head.jsp" %>
<style>
:root{
    --navy:#1a2744;--navy2:#243159;--violet:#5c4d8a;--violet-d:#4a3d78;
    --gold:#c9922a;--bg:#eef1f7;--card:#ffffff;--border:#d1d9e6;--border-l:#e8edf5;
    --text:#0f172a;--muted:#64748b;--inp-bg:#f8fafc;--green:#059669;--red:#dc2626;
    --r:8px;--r-sm:5px;--shadow:0 2px 12px rgba(0,0,0,.10);--shadow-sm:0 1px 4px rgba(0,0,0,.07);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
html,body{height:100%;font-family:'Segoe UI',system-ui,sans-serif;font-size:13px;background:var(--bg);color:var(--text);}
.tw{display:flex;flex-direction:column;height:100vh;height:100dvh;overflow:hidden;}
.tw-nav{flex-shrink:0;}
.tw-body{flex:1;min-height:0;overflow-y:auto;padding:14px;}
.tw-body::-webkit-scrollbar{width:5px;}
.tw-body::-webkit-scrollbar-thumb{background:var(--violet);border-radius:3px;}
.pg-hdr{flex-shrink:0;background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);padding:10px 16px;display:flex;align-items:center;gap:10px;box-shadow:0 2px 8px rgba(0,0,0,.25);}
.pg-hdr-title{display:flex;align-items:center;gap:9px;color:#fff;font-size:15px;font-weight:800;letter-spacing:.4px;}
.pg-hdr-title i{color:var(--gold);font-size:17px;}
.form-card{background:var(--card);border-radius:var(--r);border:1px solid var(--border-l);box-shadow:var(--shadow-sm);max-width:820px;margin:0 auto;}
.form-card-head{background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);border-radius:var(--r) var(--r) 0 0;padding:10px 16px;}
.form-card-head-title{color:#fff;font-size:13px;font-weight:800;display:flex;align-items:center;gap:8px;}
.form-card-head-title i{color:var(--gold);}
.form-card-body{padding:18px 20px;}
.form-row{display:flex;gap:14px;margin-bottom:14px;}
.form-row .fg{flex:1;min-width:0;}
.fg{display:flex;flex-direction:column;gap:4px;}
.fg label{font-size:11px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;}
.fg input,.fg select,.fg textarea{border:1.5px solid var(--border);border-radius:var(--r-sm);padding:0 10px;background:var(--inp-bg);color:var(--text);font-size:13px;outline:none;transition:border-color .15s;}
.fg input,.fg select{height:36px;}
.fg textarea{padding:8px 10px;resize:vertical;min-height:80px;}
.fg input:focus,.fg select:focus,.fg textarea:focus{border-color:var(--violet);background:#fff;}
.fg select option{background:#fff;color:var(--text);}
.form-foot{display:flex;gap:10px;justify-content:flex-end;padding-top:6px;border-top:1px solid var(--border-l);margin-top:4px;}
.bb{display:inline-flex;align-items:center;gap:6px;height:36px;padding:0 18px;border-radius:var(--r-sm);font-size:12px;font-weight:700;cursor:pointer;border:1.5px solid transparent;transition:all .15s;white-space:nowrap;}
.bb-navy{background:var(--navy);color:#fff;border-color:var(--navy);}
.bb-navy:hover{background:var(--navy2);}
.bb-ghost{background:var(--inp-bg);color:var(--text);border-color:var(--border);}
.bb-ghost:hover{background:var(--border-l);}
</style>
</head>
<body>
<div class="tw">
  <div class="tw-nav"><%@ include file="/assets/navbar/navbar.jsp" %></div>
  <div class="pg-hdr">
    <div class="pg-hdr-title"><i class="fa-solid fa-pen-to-square"></i><span>Expense Entry</span></div>
  </div>
  <div class="tw-body">
    <div class="form-card">
      <div class="form-card-head">
        <div class="form-card-head-title"><i class="fa-solid fa-receipt"></i>Add Expense Entry</div>
      </div>
      <div class="form-card-body">
        <form action="<%=ctx%>/expense/expenseEntry/saveExpenseEntry.jsp" method="post" onsubmit="return validateForm()">
          <div class="form-row">
            <div class="fg">
              <label>Expense Type</label>
              <select name="expenseType" id="expenseType" required>
                <option value="">— Select Type —</option>
                <%
                try {
                  Vector expTypes = prod.getExpenseTypeList();
                  for (int i = 0; i < expTypes.size(); i++) {
                    Vector et = (Vector) expTypes.get(i);
                    String tName = et.elementAt(0).toString();
                    String tId   = et.elementAt(1).toString();
                %>
                <option value="<%=tId%>"><%=tName%></option>
                <% } } catch (Exception e) { %><option value="">Error loading</option><% } %>
              </select>
            </div>
            <div class="fg">
              <label>Amount</label>
              <input type="number" step="0.01" name="amount" id="amount" placeholder="0.00" required>
            </div>
          </div>
          <div class="fg" style="margin-bottom:14px;">
            <label>Content</label>
            <input type="text" name="content" id="content" placeholder="Enter content" required>
          </div>
          <div class="fg" style="margin-bottom:14px;">
            <label>Description <span style="color:var(--muted);font-weight:400;text-transform:none;">(optional)</span></label>
            <textarea name="description" id="description" placeholder="Any additional notes..."></textarea>
          </div>
          <div class="form-row">
            <div class="fg">
              <label>Date</label>
              <input type="date" name="expenseDate" id="expenseDate" value="<%=today%>" required>
            </div>
            <div class="fg">
              <label>Time</label>
              <input type="time" name="expenseTime" id="expenseTime" value="<%=nowTime%>" required>
            </div>
          </div>
          <div class="form-foot">
            <button type="reset" class="bb bb-ghost"><i class="fa-solid fa-rotate-left"></i> Reset</button>
            <button type="submit" class="bb bb-navy"><i class="fa-solid fa-floppy-disk"></i> Save Expense</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>
<script>
function validateForm(){
  var et=document.getElementById('expenseType').value;
  var amt=document.getElementById('amount').value;
  var con=document.getElementById('content').value.trim();
  var dt=document.getElementById('expenseDate').value;
  var tm=document.getElementById('expenseTime').value;
  if(!et){alert('Select an expense type');return false;}
  if(!amt||parseFloat(amt)<=0){alert('Enter a valid amount');return false;}
  if(!con){alert('Enter content');return false;}
  if(!dt){alert('Select a date');return false;}
  if(!tm){alert('Select a time');return false;}
  return true;
}
</script>
</body>
</html>
