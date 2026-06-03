<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) { response.sendRedirect(request.getContextPath() + "/index.jsp"); return; }

String bookingIdStr = request.getParameter("bookingId");
String fromDate     = request.getParameter("fromDate");
String toDate       = request.getParameter("toDate");
String dateType     = request.getParameter("dateType");

int bookingId = 0;
try { bookingId = Integer.parseInt(bookingIdStr); } catch (Exception e) {}

if (bookingId <= 0) {
    response.sendRedirect(request.getContextPath() + "/admin/deleteTicket/page.jsp");
    return;
}

String redirectUrl = request.getContextPath() + "/admin/deleteTicket/page.jsp"
    + "?fromDate=" + (fromDate != null ? fromDate : "")
    + "&toDate=" + (toDate != null ? toDate : "")
    + "&dateType=" + (dateType != null ? dateType : "booking");

try {
    billing.deleteTicketWithLog(bookingId, userId);
    session.setAttribute("flashMsg", "success|Ticket #" + bookingId + " deleted successfully.");
} catch (Exception e) {
    e.printStackTrace();
    session.setAttribute("flashMsg", "error|Delete failed: " + e.getMessage());
}

response.sendRedirect(redirectUrl);
%>
