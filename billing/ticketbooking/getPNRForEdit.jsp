<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<jsp:useBean id="billing" class="billing.billingBean" />
<jsp:useBean id="user"    class="user.userBean" />
<%!
    private String j(Object o) {
        if (o == null) return "";
        return o.toString().replace("\\", "\\\\").replace("\"", "\\\"")
                           .replace("\n", "\\n").replace("\r", "\\r");
    }
%>
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
    if (!hasPerm) { out.print("NO_PERM"); return; }

    String pnr = request.getParameter("pnr");
    if (pnr == null || pnr.trim().isEmpty()) { out.print("ERROR:PNR required"); return; }

    // ── Find booking by PNR ──────────────────────────────────────────────────
    Vector pnrRows = billing.getPNRDetails(pnr.trim());
    if (pnrRows == null || pnrRows.isEmpty()) { out.print("NOT_FOUND"); return; }
    Vector pr = (Vector) pnrRows.get(0);
    int bookingId = pr.get(0) != null ? Integer.parseInt(pr.get(0).toString()) : 0;

    // ── Full booking data ────────────────────────────────────────────────────
    Vector full = billing.getTicketByIdFull(bookingId);
    if (full == null || full.isEmpty()) { out.print("NOT_FOUND"); return; }
    Vector d = (Vector) full.get(0);

    // ── Passengers ──────────────────────────────────────────────────────────
    Vector pax = billing.getPNRPassengers(bookingId);

    // ── Build JSON ───────────────────────────────────────────────────────────
    StringBuilder sb = new StringBuilder("{");
    sb.append("\"id\":\"").append(j(d.get(0))).append("\",");
    sb.append("\"pnr\":\"").append(j(d.get(1))).append("\",");
    sb.append("\"bookingDate\":\"").append(j(d.get(2))).append("\",");
    sb.append("\"owDate\":\"").append(j(d.get(3))).append("\",");
    sb.append("\"owTime\":\"").append(j(d.get(4))).append("\",");
    sb.append("\"owFromId\":\"").append(d.get(5)!=null ? d.get(5) : "").append("\",");
    sb.append("\"owFromName\":\"").append(j(d.get(6))).append("\",");
    sb.append("\"owToId\":\"").append(d.get(7)!=null ? d.get(7) : "").append("\",");
    sb.append("\"owToName\":\"").append(j(d.get(8))).append("\",");
    sb.append("\"owFlightNo\":\"").append(j(d.get(9))).append("\",");
    sb.append("\"owAirlines\":\"").append(j(d.get(10))).append("\",");
    sb.append("\"retDate\":\"").append(j(d.get(11))).append("\",");
    sb.append("\"retTime\":\"").append(j(d.get(12))).append("\",");
    sb.append("\"retFromId\":\"").append(d.get(13)!=null ? d.get(13) : "").append("\",");
    sb.append("\"retFromName\":\"").append(j(d.get(14))).append("\",");
    sb.append("\"retToId\":\"").append(d.get(15)!=null ? d.get(15) : "").append("\",");
    sb.append("\"retToName\":\"").append(j(d.get(16))).append("\",");
    sb.append("\"retFlightNo\":\"").append(j(d.get(17))).append("\",");
    sb.append("\"retAirlines\":\"").append(j(d.get(18))).append("\",");
    sb.append("\"seats\":\"").append(d.get(19)!=null ? d.get(19) : "1").append("\",");
    sb.append("\"phone\":\"").append(j(d.get(20))).append("\",");
    sb.append("\"buyAgentId\":\"").append(d.get(21)!=null ? d.get(21) : "").append("\",");
    sb.append("\"buyAmount\":\"").append(d.get(23)!=null ? d.get(23) : "").append("\",");
    sb.append("\"buyModeId\":\"").append(d.get(24)!=null ? d.get(24) : "").append("\",");
    sb.append("\"buyPaid\":\"").append(d.get(26)!=null ? d.get(26) : "0").append("\",");
    sb.append("\"sellAgentId\":\"").append(d.get(27)!=null ? d.get(27) : "").append("\",");
    sb.append("\"sellAmount\":\"").append(d.get(29)!=null ? d.get(29) : "").append("\",");
    sb.append("\"sellModeId\":\"").append(d.get(30)!=null ? d.get(30) : "").append("\",");
    sb.append("\"sellPaid\":\"").append(d.get(32)!=null ? d.get(32) : "0").append("\",");
    sb.append("\"custName\":\"").append(j(d.get(33))).append("\",");
    sb.append("\"custAmount\":\"").append(d.get(34)!=null ? d.get(34) : "").append("\",");
    sb.append("\"custModeId\":\"").append(d.get(35)!=null ? d.get(35) : "").append("\",");
    sb.append("\"custPaid\":\"").append(d.get(37)!=null ? d.get(37) : "0").append("\",");
    sb.append("\"ticketNo\":\"").append(j(d.get(38))).append("\",");
    sb.append("\"isCancelled\":\"").append(d.get(40)!=null ? d.get(40) : "0").append("\",");
    sb.append("\"buyTxnNo\":\"").append(j(d.get(41))).append("\",");
    sb.append("\"sellTxnNo\":\"").append(j(d.get(42))).append("\",");
    sb.append("\"custTxnNo\":\"").append(j(d.get(43))).append("\",");

    sb.append("\"passengers\":[");
    if (pax != null) {
        for (int i = 0; i < pax.size(); i++) {
            Vector pp = (Vector) pax.get(i);
            String pname = (pp != null && pp.size() > 1 && pp.get(1) != null)
                           ? pp.get(1).toString().replace("\"", "\\\"") : "";
            if (i > 0) sb.append(",");
            sb.append("\"").append(pname).append("\"");
        }
    }
    sb.append("]");
    sb.append("}");
    out.print(sb.toString());

} catch (Exception e) {
    out.print("ERROR:" + e.getMessage());
}
%>
