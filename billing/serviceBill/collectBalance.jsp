<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<%
response.setContentType("application/json;charset=UTF-8");
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) { out.print("{\"status\":\"error\",\"msg\":\"Session expired\"}"); return; }

String billIdStr      = request.getParameter("billId");
String amtStr         = request.getParameter("amount");
String payModeIdStr   = request.getParameter("payModeId");
String payModeName    = request.getParameter("payModeName");
String collectionDate = request.getParameter("collectionDate");
String remarks        = request.getParameter("remarks");

int billId = 0;
double amount = 0;
Integer payModeId = null;

try { if (billIdStr != null) billId = Integer.parseInt(billIdStr); } catch (Exception e) { billId = 0; }
try { if (amtStr != null) amount = Double.parseDouble(amtStr); } catch (Exception e) { amount = 0; }
try {
    if (payModeIdStr != null && !payModeIdStr.trim().isEmpty() && !"0".equals(payModeIdStr)) {
        payModeId = Integer.valueOf(Integer.parseInt(payModeIdStr));
    }
} catch (Exception e) { payModeId = null; }

if (payModeName == null) payModeName = "";
if (collectionDate == null) collectionDate = "";
if (remarks == null) remarks = "";

String result = billing.collectServiceBillBalance(billId, amount, payModeId, payModeName, remarks, collectionDate, userId.intValue());
if ("OK".equals(result)) {
    out.print("{\"status\":\"ok\"}");
} else {
    out.print("{\"status\":\"error\",\"msg\":\"" + result.replace("\"", "") + "\"}");
}
%>
