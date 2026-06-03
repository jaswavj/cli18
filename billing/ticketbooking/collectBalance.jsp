<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<%
try {
    request.setCharacterEncoding("UTF-8");
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) { out.print("ERROR:SESSION"); return; }

    String bookingIdStr    = request.getParameter("bookingId");
    String partyType       = request.getParameter("partyType");
    String agentIdStr      = request.getParameter("agentId");
    String partyName       = request.getParameter("partyName");
    String txnType         = request.getParameter("txnType");
    String amountStr       = request.getParameter("amount");
    String payModeIdStr    = request.getParameter("payModeId");
    String collectionDate  = request.getParameter("collectionDate");
    String transactionNo   = request.getParameter("txnNo");

    if (bookingIdStr == null || amountStr == null || amountStr.trim().isEmpty()) {
        out.print("ERROR:Missing required fields"); return;
    }

    int bookingId = Integer.parseInt(bookingIdStr);
    double amount = Double.parseDouble(amountStr);
    Integer agentId    = (agentIdStr   != null && !agentIdStr.trim().isEmpty()   && !"0".equals(agentIdStr))   ? Integer.parseInt(agentIdStr)   : null;
    Integer payModeId  = (payModeIdStr != null && !payModeIdStr.trim().isEmpty() && !"0".equals(payModeIdStr)) ? Integer.parseInt(payModeIdStr) : null;
    if (collectionDate == null || collectionDate.trim().isEmpty()) {
        collectionDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
    }
    if (txnType == null || txnType.isEmpty()) txnType = "DR";

    String result = billing.collectTicketBalance(bookingId, partyType, agentId, partyName, txnType, amount, payModeId, collectionDate, transactionNo, userId);
    out.print(result);
} catch (Exception e) {
    out.print("ERROR:" + e.getMessage());
}
%>
