<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<%
response.setContentType("application/json;charset=UTF-8");
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) { out.print("{\"status\":\"error\",\"msg\":\"Session expired\"}"); return; }
String ctx = request.getContextPath();

String billNo       = request.getParameter("billNo");
String billDate     = request.getParameter("billDate");
String customerName = request.getParameter("customerName");
String phone        = request.getParameter("phone");
String subtotalStr  = request.getParameter("subtotal");
String discountStr  = request.getParameter("discount");
String totalStr     = request.getParameter("totalAmount");
String payModeId    = request.getParameter("payModeId");
String payModeName  = request.getParameter("payModeName");
String paidStr      = request.getParameter("paidAmount");
String balStr       = request.getParameter("balance");
String description  = request.getParameter("description");
String[] svcNames   = request.getParameterValues("svcName");
String[] svcCosts   = request.getParameterValues("svcCost");

if (billDate   == null || billDate.isEmpty())   billDate   = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
if (customerName == null) customerName = "";
if (phone        == null) phone = "";
if (payModeId    == null) payModeId = "";
if (payModeName  == null) payModeName = "";
if (description  == null) description = "";

double subtotal = 0, discount = 0, total = 0, paid = 0, balance = 0;
try { subtotal = Double.parseDouble(subtotalStr); } catch(Exception e) {}
try { discount = Double.parseDouble(discountStr); } catch(Exception e) {}
try { total    = Double.parseDouble(totalStr);    } catch(Exception e) {}
try { paid     = Double.parseDouble(paidStr);     } catch(Exception e) {}
try { balance  = Double.parseDouble(balStr);      } catch(Exception e) {}

int pmId = 0;
try { pmId = Integer.parseInt(payModeId); } catch(Exception e) {}

// Generate bill_no on server if not supplied
if (billNo == null || billNo.trim().isEmpty()) {
    billNo = billing.getNextServiceBillNo();
}

int newId = billing.saveServiceBill(billNo, billDate, customerName, phone,
    subtotal, discount, total, paid, balance,
    pmId > 0 ? pmId : null, payModeName, description, userId, svcNames, svcCosts);

if (newId < 0) {
    out.print("{\"status\":\"error\",\"msg\":\"Failed to save bill\"}");
} else {
    out.print("{\"status\":\"ok\",\"id\":\"" + newId + "\",\"billNo\":\"" + billNo.replace("\"","") + "\"}");
}
%>
