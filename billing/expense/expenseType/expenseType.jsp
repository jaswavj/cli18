<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Expense Type</title>
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
.tw-body{flex:1;min-height:0;overflow-y:auto;padding:14px;}
.tw-body::-webkit-scrollbar{width:5px;}
.tw-body::-webkit-scrollbar-thumb{background:var(--violet);border-radius:3px;}
.pg-hdr{flex-shrink:0;background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);padding:10px 16px;display:flex;align-items:center;gap:10px;box-shadow:0 2px 8px rgba(0,0,0,.25);}
.pg-hdr-title{display:flex;align-items:center;gap:9px;color:#fff;font-size:15px;font-weight:800;letter-spacing:.4px;}
.pg-hdr-title i{color:var(--gold);font-size:17px;}
.layout{display:flex;gap:14px;align-items:flex-start;}
.layout-left{width:360px;flex-shrink:0;}
.layout-right{flex:1;min-width:0;}
.card{background:var(--card);border-radius:var(--r);border:1px solid var(--border-l);box-shadow:var(--shadow-sm);}
.card-head{background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);border-radius:var(--r) var(--r) 0 0;padding:10px 14px;display:flex;align-items:center;gap:8px;}
.card-head-title{color:#fff;font-size:13px;font-weight:800;letter-spacing:.3px;}
.card-head-title i{color:var(--gold);}
.card-body{padding:14px;}
.fg{display:flex;flex-direction:column;gap:4px;margin-bottom:12px;}
.fg label{font-size:11px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;}
.fg input{height:36px;border:1.5px solid var(--border);border-radius:var(--r-sm);padding:0 10px;background:var(--inp-bg);color:var(--text);font-size:13px;outline:none;transition:border-color .15s;}
.fg input:focus{border-color:var(--violet);background:#fff;}
.bb{display:inline-flex;align-items:center;justify-content:center;gap:6px;height:36px;padding:0 16px;border-radius:var(--r-sm);font-size:12px;font-weight:700;cursor:pointer;border:1.5px solid transparent;transition:all .15s;white-space:nowrap;width:100%;}
.bb-navy{background:var(--navy);color:#fff;border-color:var(--navy);}
.bb-navy:hover{background:var(--navy2);}
.bb-violet{background:var(--violet);color:#fff;border-color:var(--violet);width:auto;}
.bb-violet:hover{background:var(--violet-d);}
.bb-ghost{background:var(--inp-bg);color:var(--text);border-color:var(--border);width:auto;}
.bb-ghost:hover{background:var(--border-l);}
.rpt-table{width:100%;border-collapse:collapse;font-size:12px;}
.rpt-table thead tr{background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);}
.rpt-table thead th{color:#fff;padding:8px 10px;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;white-space:nowrap;}
.rpt-table tbody tr{border-bottom:1px solid var(--border-l);transition:background .1s;}
.rpt-table tbody tr:hover{background:#f5f3fb;}
.rpt-table td{padding:8px 10px;vertical-align:middle;}
.modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:2000;align-items:center;justify-content:center;}
.modal-overlay.active{display:flex;}
.modal-box{background:#fff;border-radius:var(--r);width:360px;max-width:95vw;box-shadow:0 8px 32px rgba(0,0,0,.25);overflow:hidden;}
.modal-head{background:linear-gradient(135deg,var(--navy),var(--navy2));padding:12px 16px;display:flex;align-items:center;justify-content:space-between;}
.modal-head-title{color:#fff;font-weight:800;font-size:13px;display:flex;align-items:center;gap:8px;}
.modal-head-title i{color:var(--gold);}
.modal-close{background:none;border:none;color:rgba(255,255,255,.7);font-size:20px;cursor:pointer;line-height:1;}
.modal-close:hover{color:#fff;}
.modal-body{padding:16px;display:flex;flex-direction:column;gap:12px;}
.modal-foot{padding:12px 16px;display:flex;gap:8px;justify-content:flex-end;border-top:1px solid var(--border-l);}
.mfg{display:flex;flex-direction:column;gap:4px;}
.mfg label{font-size:11px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;}
.mfg input{height:36px;border:1.5px solid var(--border);border-radius:var(--r-sm);padding:0 10px;background:var(--inp-bg);color:var(--text);font-size:13px;outline:none;transition:border-color .15s;}
.mfg input:focus{border-color:var(--violet);background:#fff;}
.mfg input:disabled{opacity:.6;cursor:not-allowed;}
</style>
</head>
<body>
<div class="tw">
  <div class="tw-nav"><%@ include file="/assets/navbar/navbar.jsp" %></div>
  <div class="pg-hdr">
    <div class="pg-hdr-title"><i class="fa-solid fa-tags"></i><span>Expense Type</span></div>
  </div>
  <div class="tw-body">
    <div class="layout">
      <div class="layout-left">
        <div class="card">
          <div class="card-head"><div class="card-head-title"><i class="fa-solid fa-plus-circle"></i>&nbsp;Add Expense Type</div></div>
          <div class="card-body">
            <form action="<%=ctx%>/expense/expenseType/saveExpenseType.jsp" method="post">
              <div class="fg">
                <label>Expense Type Name</label>
                <input type="text" name="expenseTypeName" placeholder="Enter type name" required>
              </div>
              <button type="submit" class="bb bb-navy"><i class="fa-solid fa-floppy-disk"></i>&nbsp;Save</button>
            </form>
          </div>
        </div>
      </div>
      <div class="layout-right">
        <div class="card">
          <div class="card-head"><div class="card-head-title"><i class="fa-solid fa-list"></i>&nbsp;Expense Type List</div></div>
          <div style="overflow-x:auto;">
            <table class="rpt-table">
              <thead><tr><th style="width:40px;">#</th><th>Name</th><th style="width:80px;text-align:center;">Action</th></tr></thead>
              <tbody>
                <%
                try {
                  Vector vec = prod.getExpenseTypeList();
                  if (vec != null && vec.size() > 0) {
                    for (int i = 0; i < vec.size(); i++) {
                      Vector row = (Vector) vec.get(i);
                      if (row == null || row.elementAt(0)==null || row.elementAt(1)==null) continue;
                      String typeName = row.elementAt(0).toString();
                      int typeId = Integer.parseInt(row.elementAt(1).toString());
                %>
                <tr>
                  <td style="color:var(--muted);"><%=i+1%></td>
                  <td style="font-weight:600;"><%=typeName%></td>
                  <td style="text-align:center;">
                    <button class="bb bb-violet" style="height:28px;padding:0 10px;font-size:11px;"
                      onclick="openEdit('<%=typeName.replace("'","\\'")%>',<%=typeId%>)">
                      <i class="fa-solid fa-pen"></i>&nbsp;Edit
                    </button>
                  </td>
                </tr>
                <% }
                  } else { %>
                <tr><td colspan="3" style="text-align:center;padding:30px;color:var(--muted);"><i class="fa-solid fa-inbox" style="font-size:24px;display:block;margin-bottom:8px;"></i>No expense types found.</td></tr>
                <% }
                } catch(Exception e) { %>
                <tr><td colspan="3" style="color:var(--red);text-align:center;">Error: <%=e.getMessage()%></td></tr>
                <% } %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
<div class="modal-overlay" id="editModal" onclick="if(event.target===this)closeEdit()">
  <div class="modal-box">
    <div class="modal-head">
      <div class="modal-head-title"><i class="fa-solid fa-pen"></i> Edit Expense Type</div>
      <button class="modal-close" onclick="closeEdit()">&times;</button>
    </div>
    <form action="<%=ctx%>/expense/expenseType/editExpenseType.jsp" method="post">
      <input type="hidden" name="expenseTypeId" id="editId">
      <div class="modal-body">
        <div class="mfg"><label>Current Name</label><input type="text" id="currentName" disabled></div>
        <div class="mfg"><label>New Name</label><input type="text" name="newExpenseType" id="editName" required></div>
      </div>
      <div class="modal-foot">
        <button type="button" class="bb bb-ghost" onclick="closeEdit()">Cancel</button>
        <button type="submit" class="bb bb-violet"><i class="fa-solid fa-floppy-disk"></i>&nbsp;Update</button>
      </div>
    </form>
  </div>
</div>
<script>
function openEdit(name,id){
  document.getElementById('currentName').value=name;
  document.getElementById('editName').value=name;
  document.getElementById('editId').value=id;
  document.getElementById('editModal').classList.add('active');
}
function closeEdit(){document.getElementById('editModal').classList.remove('active');}
document.addEventListener('keydown',function(e){if(e.key==='Escape')closeEdit();});
</script>
</body>
</html>
