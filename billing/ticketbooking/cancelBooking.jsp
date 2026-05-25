<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<jsp:useBean id="billing" class="billing.billingBean" />
<jsp:useBean id="user"    class="user.userBean" />
<%
response.setContentType("text/plain;charset=UTF-8");
try {
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) { out.print("ERROR:SESSION"); return; }

    // ── Permission check (module 6 = Edit Booking) ──────────────────────────
    Vector perms = user.getUserPermission(userId);
    boolean hasPerm = false;
    for (int i = 0; i < perms.size(); i++) {
        Vector p = (Vector) perms.get(i);
        if (p != null && !p.isEmpty() && "6".equals(p.get(0).toString())) {
            hasPerm = true; break;
        }
    }
    if (!hasPerm) { out.print("ERROR:Permission denied"); return; }

    String bookingIdStr = request.getParameter("bookingId");
    String reason       = request.getParameter("reason") != null ? request.getParameter("reason").trim() : "";

    if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
        out.print("ERROR:bookingId required"); return;
    }
    int bookingId = Integer.parseInt(bookingIdStr.trim());

    // ── Cancel charge params (refund auto-calculated; entries inserted as pending) ──
    String ccBuyStr  = request.getParameter("cancelChargeBuy");
    String ccSellStr = request.getParameter("cancelChargeSell");
    Double  cancelChargeBuy   = (ccBuyStr  != null && !ccBuyStr.trim().isEmpty())  ? Double.parseDouble(ccBuyStr.trim())  : null;
    Double  cancelChargeSell  = (ccSellStr != null && !ccSellStr.trim().isEmpty()) ? Double.parseDouble(ccSellStr.trim()) : null;

    billing.cancelTicketBooking(bookingId, userId, reason,
        cancelChargeBuy, null,
        cancelChargeSell, null);
    out.print("SUCCESS");

} catch (Exception e) {
    out.print("ERROR:" + e.getMessage());
}
%>
