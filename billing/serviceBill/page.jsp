<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }
String ctx = request.getContextPath();
String today = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
Vector payModes = billing.getTicketPaymentModes();
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Service Bill</title>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<%@ include file="/assets/common/head.jsp" %>
<script src="<%=ctx%>/dist/js/sweetalert2.all.min.js"></script>
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
.pg-hdr-right{margin-left:auto;display:flex;gap:8px;}
.form-card{background:var(--card);border-radius:var(--r);border:1px solid var(--border-l);box-shadow:var(--shadow-sm);max-width:900px;margin:0 auto;}
.form-card-head{background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);border-radius:var(--r) var(--r) 0 0;padding:10px 16px;display:flex;align-items:center;justify-content:space-between;}
.form-card-head-title{color:#fff;font-size:13px;font-weight:800;display:flex;align-items:center;gap:8px;}
.form-card-head-title i{color:var(--gold);}
.bill-no-badge{background:rgba(201,146,42,.2);border:1px solid var(--gold);color:var(--gold);border-radius:4px;padding:3px 10px;font-size:12px;font-weight:800;letter-spacing:.5px;}
.form-card-body{padding:18px 20px;}
.section-title{font-size:11px;font-weight:800;color:var(--muted);text-transform:uppercase;letter-spacing:.5px;margin-bottom:10px;padding-bottom:6px;border-bottom:1px solid var(--border-l);}
.form-row{display:flex;gap:14px;margin-bottom:14px;}
.form-row .fg{flex:1;min-width:0;}
.fg{display:flex;flex-direction:column;gap:4px;}
.fg label{font-size:11px;font-weight:700;color:var(--muted);text-transform:uppercase;letter-spacing:.4px;}
.fg input,.fg select,.fg textarea{border:1.5px solid var(--border);border-radius:var(--r-sm);padding:0 10px;background:var(--inp-bg);color:var(--text);font-size:13px;outline:none;transition:border-color .15s;}
.fg input,.fg select{height:36px;}
.fg textarea{padding:8px 10px;resize:vertical;min-height:70px;}
.fg input:focus,.fg select:focus,.fg textarea:focus{border-color:var(--violet);background:#fff;}
.fg input[readonly]{background:#f1f5f9;cursor:default;}
.fg select option{background:#fff;color:var(--text);}
.optional-tag{font-size:10px;color:var(--muted);font-weight:400;text-transform:none;margin-left:4px;}

/* Items table */
.items-wrap{overflow-x:auto;margin-bottom:10px;}
.items-table{width:100%;border-collapse:collapse;font-size:12px;}
.items-table thead tr{background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);}
.items-table thead th{color:#fff;padding:7px 10px;font-size:10px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;}
.items-table tbody tr{border-bottom:1px solid var(--border-l);}
.items-table td{padding:5px 6px;}
.items-table input{width:100%;height:32px;border:1.5px solid var(--border);border-radius:var(--r-sm);padding:0 8px;background:var(--inp-bg);font-size:12px;outline:none;}
.items-table input:focus{border-color:var(--violet);background:#fff;}
.btn-remove{background:#fee2e2;color:var(--red);border:none;border-radius:4px;width:28px;height:28px;cursor:pointer;font-size:13px;display:flex;align-items:center;justify-content:center;}
.btn-remove:hover{background:#fecaca;}

/* Summary */
.summary-box{background:#f8fafc;border:1px solid var(--border-l);border-radius:var(--r-sm);padding:12px 14px;margin-bottom:14px;}
.sum-row{display:flex;justify-content:space-between;align-items:center;padding:4px 0;}
.sum-row:not(:last-child){border-bottom:1px solid var(--border-l);}
.sum-lbl{font-size:12px;color:var(--muted);font-weight:600;}
.sum-val{font-size:13px;font-weight:800;color:var(--text);}
.sum-val.total{color:var(--navy);font-size:15px;}
.sum-val.balance{color:var(--red);}
.sum-val.paid{color:var(--green);}

/* Buttons */
.bb{display:inline-flex;align-items:center;gap:6px;height:36px;padding:0 16px;border-radius:var(--r-sm);font-size:12px;font-weight:700;cursor:pointer;border:1.5px solid transparent;transition:all .15s;white-space:nowrap;text-decoration:none;}
.bb-navy{background:var(--navy);color:#fff;border-color:var(--navy);}
.bb-navy:hover{background:var(--navy2);}
.bb-ghost{background:var(--inp-bg);color:var(--text);border-color:var(--border);}
.bb-ghost:hover{background:var(--border-l);}
.bb-violet{background:var(--violet);color:#fff;border-color:var(--violet);}
.bb-violet:hover{background:var(--violet-d);}
.bb-add{background:#e8f5e9;color:#2e7d32;border:1.5px solid #c8e6c9;height:32px;padding:0 12px;font-size:11px;}
.bb-add:hover{background:#c8e6c9;}
.form-foot{display:flex;gap:10px;justify-content:flex-end;padding-top:12px;border-top:1px solid var(--border-l);}
</style>
</head>
<body>
<div class="tw">
  <div class="tw-nav"><%@ include file="/assets/navbar/navbar.jsp" %></div>
  <div class="pg-hdr">
    <div class="pg-hdr-title"><i class="fa-solid fa-file-invoice"></i><span>Service Bill</span></div>
    <div class="pg-hdr-right">
      <a href="<%=ctx%>/serviceBill/report.jsp" class="bb bb-ghost" style="height:30px;font-size:11px;">
        <i class="fa-solid fa-chart-bar"></i> Report
      </a>
    </div>
  </div>

  <div class="tw-body">
    <div class="form-card">
      <div class="form-card-head">
        <div class="form-card-head-title"><i class="fa-solid fa-plus-circle"></i>&nbsp;New Service Bill</div>
        <span class="bill-no-badge" id="billNoDisplay">Loading...</span>
      </div>
      <div class="form-card-body">
        <form id="billForm" onsubmit="submitBill(event)">
          <input type="hidden" name="billNo" id="billNoInput">

          <!-- Customer Info -->
          <div class="section-title"><i class="fa-solid fa-user"></i>&nbsp;Customer Info</div>
          <div class="form-row">
            <div class="fg">
              <label>Customer Name <span class="optional-tag">(optional)</span></label>
              <input type="text" name="customerName" placeholder="Enter customer name">
            </div>
            <div class="fg">
              <label>Phone <span class="optional-tag">(optional)</span></label>
              <input type="text" name="phone" placeholder="Enter phone number">
            </div>
            <div class="fg" style="max-width:160px;">
              <label>Bill Date</label>
              <input type="date" name="billDate" value="<%=today%>" required>
            </div>
          </div>

          <!-- Service Items -->
          <div class="section-title" style="margin-top:8px;"><i class="fa-solid fa-list-check"></i>&nbsp;Services</div>
          <div class="items-wrap">
            <table class="items-table">
              <thead><tr>
                <th style="width:60%;">Service / Description</th>
                <th style="width:25%;text-align:right;">Cost (&#8377;)</th>
                <th style="width:15%;text-align:center;"></th>
              </tr></thead>
              <tbody id="itemsBody">
                <tr>
                  <td><input type="text" name="svcName" placeholder="Service name" required oninput="calcTotals()"></td>
                  <td><input type="number" step="0.01" name="svcCost" placeholder="0.00" oninput="calcTotals()" style="text-align:right;"></td>
                  <td style="text-align:center;"><button type="button" class="btn-remove" onclick="removeRow(this)" title="Remove"><i class="fa-solid fa-xmark"></i></button></td>
                </tr>
              </tbody>
            </table>
          </div>
          <button type="button" class="bb bb-add" onclick="addRow()"><i class="fa-solid fa-plus"></i>&nbsp;Add Row</button>

          <!-- Summary -->
          <div class="summary-box" style="margin-top:14px;">
            <div class="sum-row"><span class="sum-lbl">Subtotal</span><span class="sum-val" id="dispSubtotal">&#8377;0.00</span></div>
            <div class="sum-row">
              <span class="sum-lbl">Discount (&#8377;)</span>
              <input type="number" step="0.01" name="discount" id="discountInp" value="0" min="0" style="width:110px;height:28px;border:1.5px solid var(--border);border-radius:4px;padding:0 8px;font-size:12px;text-align:right;background:var(--inp-bg);outline:none;" oninput="calcTotals()">
            </div>
            <div class="sum-row"><span class="sum-lbl">Total Payable</span><span class="sum-val total" id="dispTotal">&#8377;0.00</span></div>
          </div>

          <!-- Payment -->
          <div class="section-title"><i class="fa-solid fa-money-bill-wave"></i>&nbsp;Payment</div>
          <div class="form-row">
            <div class="fg">
              <label>Payment Mode</label>
              <select name="payModeId" id="payModeId" onchange="updatePayModeName()">
                <option value="">— Select Mode —</option>
                <%for (int i = 0; i < payModes.size(); i++) { Vector pm = (Vector) payModes.get(i);%>
                <option value="<%=pm.get(0)%>" data-name="<%=pm.get(1)%>"><%=pm.get(1)%></option>
                <%}%>
              </select>
              <input type="hidden" name="payModeName" id="payModeName">
            </div>
            <div class="fg">
              <label>Paid Amount (&#8377;)</label>
              <input type="number" step="0.01" name="paidAmount" id="paidAmountInp" value="0" min="0" oninput="calcBalance()">
            </div>
            <div class="fg">
              <label>Balance</label>
              <input type="text" id="dispBalance" readonly value="0.00">
              <input type="hidden" name="balance" id="balanceHidden">
            </div>
          </div>

          <!-- Description -->
          <div class="fg" style="margin-bottom:14px;">
            <label>Description <span class="optional-tag">(optional)</span></label>
            <textarea name="description" placeholder="Additional notes..."></textarea>
          </div>

          <!-- Hidden totals -->
          <input type="hidden" name="subtotal" id="subtotalHidden">
          <input type="hidden" name="totalAmount" id="totalHidden">

          <div class="form-foot">
            <button type="reset" class="bb bb-ghost" onclick="resetForm()"><i class="fa-solid fa-rotate-left"></i> Reset</button>
            <button type="submit" class="bb bb-navy"><i class="fa-solid fa-floppy-disk"></i> Save</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<script>
var nextBillNo = '';

// Fetch next bill number
fetch('<%=ctx%>/serviceBill/getNextBillNo.jsp')
  .then(function(r){ return r.text(); })
  .then(function(t){
    t = t.trim();
    nextBillNo = t;
    document.getElementById('billNoDisplay').textContent = t;
    document.getElementById('billNoInput').value = t;
  })
  .catch(function(){ document.getElementById('billNoDisplay').textContent = 'ERR'; });

function addRow() {
    var tbody = document.getElementById('itemsBody');
    var tr = document.createElement('tr');
    tr.innerHTML = '<td><input type="text" name="svcName" placeholder="Service name" oninput="calcTotals()"></td>'
        + '<td><input type="number" step="0.01" name="svcCost" placeholder="0.00" oninput="calcTotals()" style="text-align:right;"></td>'
        + '<td style="text-align:center;"><button type="button" class="btn-remove" onclick="removeRow(this)" title="Remove"><i class="fa-solid fa-xmark"></i></button></td>';
    tbody.appendChild(tr);
}

function removeRow(btn) {
    var rows = document.querySelectorAll('#itemsBody tr');
    if (rows.length <= 1) { Swal.fire({icon:'warning',title:'Cannot Remove',text:'At least one service item is required.',confirmButtonColor:'#1a2744'}); return; }
    btn.closest('tr').remove();
    calcTotals();
}

function calcTotals() {
    var costs = document.querySelectorAll('[name="svcCost"]');
    var sub = 0;
    costs.forEach(function(c){ sub += parseFloat(c.value)||0; });
    var disc = parseFloat(document.getElementById('discountInp').value)||0;
    var total = sub - disc;
    if (total < 0) total = 0;
    document.getElementById('dispSubtotal').textContent = '\u20B9' + sub.toFixed(2);
    document.getElementById('dispTotal').textContent = '\u20B9' + total.toFixed(2);
    document.getElementById('subtotalHidden').value = sub.toFixed(2);
    document.getElementById('totalHidden').value = total.toFixed(2);
    // Auto-fill paid amount with total (user can override)
    document.getElementById('paidAmountInp').value = total.toFixed(2);
    calcBalance();
}

function calcBalance() {
    var total = parseFloat(document.getElementById('totalHidden').value)||0;
    var paid  = parseFloat(document.getElementById('paidAmountInp').value)||0;
    var bal   = total - paid;
    document.getElementById('dispBalance').value = bal.toFixed(2);
    document.getElementById('balanceHidden').value = bal.toFixed(2);
}

function updatePayModeName() {
    var sel = document.getElementById('payModeId');
    var opt = sel.options[sel.selectedIndex];
    document.getElementById('payModeName').value = opt ? (opt.getAttribute('data-name')||'') : '';
}

function resetForm() {
    setTimeout(function(){
        document.getElementById('billNoInput').value = nextBillNo;
        calcTotals();
    },50);
}

function validateBill() {
    var names = document.querySelectorAll('[name="svcName"]');
    var hasItem = false;
    names.forEach(function(n){ if(n.value.trim()) hasItem = true; });
    if (!hasItem) { Swal.fire({icon:'warning',title:'Missing Item',text:'Add at least one service item.',confirmButtonColor:'#1a2744'}); return false; }
    var total = parseFloat(document.getElementById('totalHidden').value)||0;
    if (total <= 0) { Swal.fire({icon:'warning',title:'Invalid Total',text:'Total payable must be greater than 0.',confirmButtonColor:'#1a2744'}); return false; }
    return true;
}

function submitBill(e) {
    e.preventDefault();
    if (!validateBill()) return;

    var form = document.getElementById('billForm');
    var data = new URLSearchParams(new FormData(form));
    var submitBtn = form.querySelector('[type="submit"]');
    submitBtn.disabled = true;
    submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Saving...';

    fetch('<%=ctx%>/serviceBill/save.jsp', { method:'POST', body: data })
      .then(function(r){ return r.json(); })
      .then(function(res) {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fa-solid fa-floppy-disk"></i> Save';
        if (res.status === 'ok') {
          // Refresh bill number for next entry
          fetch('<%=ctx%>/serviceBill/getNextBillNo.jsp')
            .then(function(r){ return r.text(); })
            .then(function(t){
              t = t.trim(); nextBillNo = t;
              document.getElementById('billNoDisplay').textContent = t;
              document.getElementById('billNoInput').value = t;
            });
          Swal.fire({
            icon: 'success',
            title: 'Bill Saved!',
            html: '<div style="font-size:13px;color:#64748b;margin-bottom:10px;">Service bill has been recorded.</div>'
                + '<div style="display:inline-block;background:rgba(92,77,138,.12);border:1.5px solid #5c4d8a;color:#5c4d8a;border-radius:5px;padding:5px 18px;font-size:15px;font-weight:900;letter-spacing:.5px;"># ' + res.billNo + '</div>',
            showConfirmButton: true,
            confirmButtonText: '<i class="fa fa-print"></i>&nbsp; Print',
            showDenyButton: true,
            denyButtonText: '<i class="fa fa-plus"></i>&nbsp; New Bill',
            showCancelButton: true,
            cancelButtonText: '<i class="fa fa-chart-bar"></i>&nbsp; Report',
            confirmButtonColor: '#1a2744',
            denyButtonColor: '#5c4d8a',
            cancelButtonColor: '#64748b',
            allowOutsideClick: false
          }).then(function(result) {
            if (result.isConfirmed) {
              var pw = window.open('<%=ctx%>/serviceBill/print.jsp?id=' + res.id, 'printWin',
                'width=700,height=900,menubar=no,toolbar=no,location=no,status=no,scrollbars=yes');
              if (pw) pw.focus();
              form.reset(); calcTotals();
            } else if (result.isDenied) {
              form.reset(); calcTotals();
            } else {
              window.location.href = '<%=ctx%>/serviceBill/report.jsp';
            }
          });
        } else {
          Swal.fire({icon:'error',title:'Save Failed',text: res.msg || 'An error occurred.',confirmButtonColor:'#1a2744'});
        }
      })
      .catch(function() {
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fa-solid fa-floppy-disk"></i> Save';
        Swal.fire({icon:'error',title:'Network Error',text:'Could not reach the server.',confirmButtonColor:'#1a2744'});
      });
}

// Init
calcTotals();
</script>
</body>
</html>
