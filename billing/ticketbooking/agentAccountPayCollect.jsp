<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<%
try {
    request.setCharacterEncoding("UTF-8");
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) { out.print("ERROR:SESSION"); return; }

    String agentIdStr     = request.getParameter("agentId");
    String action         = request.getParameter("action");
    String amountStr      = request.getParameter("amount");
    String payModeIdStr   = request.getParameter("payModeId");
    String txnDate        = request.getParameter("txnDate");
    String txnNo          = request.getParameter("txnNo");
    String notes          = request.getParameter("notes");

    if (agentIdStr == null || agentIdStr.trim().isEmpty()) {
        out.print("ERROR:Select an agent"); return;
    }
    if (amountStr == null || amountStr.trim().isEmpty()) {
        out.print("ERROR:Enter amount"); return;
    }

    int agentId = Integer.parseInt(agentIdStr);
    double amount = Double.parseDouble(amountStr);
    Integer payModeId = (payModeIdStr != null && !payModeIdStr.trim().isEmpty() && !"0".equals(payModeIdStr))
        ? Integer.parseInt(payModeIdStr) : null;

    String result = billing.saveAgentAccountPayCollect(
        agentId, action, amount, payModeId, txnDate, txnNo, notes, userId);
    out.print(result);
} catch (Exception e) {
    out.print("ERROR:" + e.getMessage());
}
%>
