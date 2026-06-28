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
    String notes           = request.getParameter("notes");

    if (notes == null || notes.trim().isEmpty()) {
        out.print("ERROR:Notes is required"); return;
    }

    String[] bookingIds = request.getParameterValues("bookingIds[]");
    if (bookingIds == null) bookingIds = request.getParameterValues("bookingIds");

    Integer agentId    = (agentIdStr   != null && !agentIdStr.trim().isEmpty()   && !"0".equals(agentIdStr))   ? Integer.parseInt(agentIdStr)   : null;
    Integer payModeId  = (payModeIdStr != null && !payModeIdStr.trim().isEmpty() && !"0".equals(payModeIdStr)) ? Integer.parseInt(payModeIdStr) : null;
    if (collectionDate == null || collectionDate.trim().isEmpty()) {
        collectionDate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
    }
    if (txnType == null || txnType.isEmpty()) txnType = "DR";

    String result;
    if (bookingIds != null && bookingIds.length > 0) {
        String[] partyTypes = request.getParameterValues("partyTypes[]");
        if (partyTypes == null) partyTypes = request.getParameterValues("partyTypes");

        String[] agentIds = request.getParameterValues("agentIds[]");
        if (agentIds == null) agentIds = request.getParameterValues("agentIds");

        String[] partyNames = request.getParameterValues("partyNames[]");
        if (partyNames == null) partyNames = request.getParameterValues("partyNames");

        String[] txnTypes = request.getParameterValues("txnTypes[]");
        if (txnTypes == null) txnTypes = request.getParameterValues("txnTypes");

        String[] amounts = request.getParameterValues("amounts[]");
        if (amounts == null) amounts = request.getParameterValues("amounts");

        int n = bookingIds.length;
        if (partyTypes == null || partyNames == null || txnTypes == null || amounts == null ||
            partyTypes.length != n || partyNames.length != n || txnTypes.length != n || amounts.length != n) {
            out.print("ERROR:Invalid multi-ticket payload"); return;
        }

        int[] bookingIdArr = new int[n];
        Integer[] agentIdArr = new Integer[n];
        double[] amountArr = new double[n];

        for (int i = 0; i < n; i++) {
            bookingIdArr[i] = Integer.parseInt(bookingIds[i]);
            amountArr[i] = Double.parseDouble(amounts[i]);
            Integer rowAgent = null;
            if (agentIds != null && agentIds.length == n) {
                String rowAgentStr = agentIds[i];
                if (rowAgentStr != null && !rowAgentStr.trim().isEmpty() && !"0".equals(rowAgentStr.trim())) {
                    rowAgent = Integer.parseInt(rowAgentStr.trim());
                }
            }
            if (rowAgent == null) rowAgent = agentId;
            agentIdArr[i] = rowAgent;
        }

        result = billing.collectTicketBalanceBulk(bookingIdArr, partyTypes, agentIdArr, partyNames, txnTypes,
                amountArr, payModeId, collectionDate, transactionNo, notes, userId);
    } else {
        if (bookingIdStr == null || amountStr == null || amountStr.trim().isEmpty()) {
            out.print("ERROR:Missing required fields"); return;
        }
        int bookingId = Integer.parseInt(bookingIdStr);
        double amount = Double.parseDouble(amountStr);
        result = billing.collectTicketBalance(bookingId, partyType, agentId, partyName, txnType,
                amount, payModeId, collectionDate, transactionNo, notes, userId);
    }

    out.print(result);
} catch (Exception e) {
    out.print("ERROR:" + e.getMessage());
}
%>
