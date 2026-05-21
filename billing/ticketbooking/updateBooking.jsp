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

    // ── bookingId ────────────────────────────────────────────────────────────
    String bookingIdStr = request.getParameter("bookingId");
    if (bookingIdStr == null || bookingIdStr.trim().isEmpty()) {
        out.print("ERROR:bookingId required"); return;
    }
    int bookingId = Integer.parseInt(bookingIdStr.trim());

    // ── Helper closure ───────────────────────────────────────────────────────
    // (inline param helpers – mirrors save.jsp pattern)
    String pnr         = request.getParameter("pnr") != null ? request.getParameter("pnr").trim() : "";
    String bookingDate = request.getParameter("bookingDate") != null ? request.getParameter("bookingDate").trim() : "";

    String owDate      = request.getParameter("owDate")      != null ? request.getParameter("owDate").trim()      : "";
    String owTime      = request.getParameter("owTime")      != null ? request.getParameter("owTime").trim()      : "";
    String owFromName  = request.getParameter("owFromName")  != null ? request.getParameter("owFromName").trim()  : "";
    String owToName    = request.getParameter("owToName")    != null ? request.getParameter("owToName").trim()    : "";
    String owFlightNo  = request.getParameter("owFlightNo")  != null ? request.getParameter("owFlightNo").trim()  : "";
    String owAirlines  = request.getParameter("owAirlines")  != null ? request.getParameter("owAirlines").trim()  : "";

    boolean hasReturn  = "1".equals(request.getParameter("hasReturn"));
    String retDate     = hasReturn && request.getParameter("retDate")    != null ? request.getParameter("retDate").trim()    : "";
    String retTime     = hasReturn && request.getParameter("retTime")    != null ? request.getParameter("retTime").trim()    : "";
    String retFromName = hasReturn && request.getParameter("retFromName")!= null ? request.getParameter("retFromName").trim(): "";
    String retToName   = hasReturn && request.getParameter("retToName")  != null ? request.getParameter("retToName").trim()  : "";
    String retFlightNo = hasReturn && request.getParameter("retFlightNo")!= null ? request.getParameter("retFlightNo").trim(): "";
    String retAirlines = hasReturn && request.getParameter("retAirlines")!= null ? request.getParameter("retAirlines").trim(): "";

    int noOfSeats = 1;
    try { noOfSeats = Integer.parseInt(request.getParameter("noOfSeats")); } catch(Exception e){}

    String phone = request.getParameter("phone") != null ? request.getParameter("phone").trim() : "";

    // ── City IDs ─────────────────────────────────────────────────────────────
    int owFromId = owFromName.isEmpty() ? 0 : billing.getOrInsertTicketCity(owFromName);
    int owToId   = owToName.isEmpty()   ? 0 : billing.getOrInsertTicketCity(owToName);
    Integer retFromId = null, retToId = null;
    if (hasReturn) {
        if (!retFromName.isEmpty()) retFromId = billing.getOrInsertTicketCity(retFromName);
        if (!retToName.isEmpty())   retToId   = billing.getOrInsertTicketCity(retToName);
    }

    // ── Buy / Sell / Customer amounts ────────────────────────────────────────
    String buyAgentIdStr  = request.getParameter("buyAgentId");
    String buyAmountStr   = request.getParameter("buyAmount");
    String buyModeIdStr   = request.getParameter("buyModeId");
    Integer buyAgentId    = (buyAgentIdStr !=null&&!buyAgentIdStr.trim().isEmpty())  ? Integer.parseInt(buyAgentIdStr.trim())  : null;
    Double  buyAmount     = (buyAmountStr  !=null&&!buyAmountStr.trim().isEmpty())   ? Double.parseDouble(buyAmountStr.trim()) : null;
    Integer buyModeId     = (buyModeIdStr  !=null&&!buyModeIdStr.trim().isEmpty())   ? Integer.parseInt(buyModeIdStr.trim())   : null;

    String sellAgentIdStr = request.getParameter("sellAgentId");
    String sellAmountStr  = request.getParameter("sellAmount");
    String sellModeIdStr  = request.getParameter("sellModeId");
    Integer sellAgentId   = (sellAgentIdStr!=null&&!sellAgentIdStr.trim().isEmpty()) ? Integer.parseInt(sellAgentIdStr.trim()) : null;
    Double  sellAmount    = (sellAmountStr !=null&&!sellAmountStr.trim().isEmpty())  ? Double.parseDouble(sellAmountStr.trim()): null;
    Integer sellModeId    = (sellModeIdStr !=null&&!sellModeIdStr.trim().isEmpty())  ? Integer.parseInt(sellModeIdStr.trim())  : null;

    String customerName   = request.getParameter("customerName") != null ? request.getParameter("customerName").trim() : "";
    String custAmountStr  = request.getParameter("custAmount");
    String custModeIdStr  = request.getParameter("custModeId");
    Double  custAmount    = (custAmountStr !=null&&!custAmountStr.trim().isEmpty())  ? Double.parseDouble(custAmountStr.trim()): null;
    Integer custModeId    = (custModeIdStr !=null&&!custModeIdStr.trim().isEmpty())  ? Integer.parseInt(custModeIdStr.trim())  : null;

    // ── Passengers ───────────────────────────────────────────────────────────
    List<String> paxList = new ArrayList<String>();
    for (int i = 1; i <= noOfSeats; i++) {
        String pn = request.getParameter("passenger_" + i);
        paxList.add(pn != null ? pn.trim() : "");
    }
    String[] passengerNames = paxList.toArray(new String[0]);

    String remarks = request.getParameter("remarks") != null ? request.getParameter("remarks").trim() : "";

    // ── Call update method ───────────────────────────────────────────────────
    billing.updateTicketBooking(
        bookingId, pnr, bookingDate,
        owDate, owTime, owFromId, owToId, owFlightNo, owAirlines,
        retDate, retTime, retFromId, retToId, retFlightNo, retAirlines,
        noOfSeats, phone,
        buyAgentId, buyAmount, buyModeId,
        sellAgentId, sellAmount, sellModeId,
        customerName, custAmount, custModeId,
        passengerNames, userId, remarks
    );

    out.print("SUCCESS");

} catch (Exception e) {
    out.print("ERROR:" + e.getMessage());
}
%>
