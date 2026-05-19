<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<%
try {
    request.setCharacterEncoding("UTF-8");
    Integer userId = (Integer) session.getAttribute("userId");
    if (userId == null) { out.print("ERROR:SESSION"); return; }

    String pnr          = request.getParameter("pnr");
    String bookingDate  = request.getParameter("bookingDate");

    // Oneway
    String owDate       = request.getParameter("owDate");
    String owTime       = request.getParameter("owTime");
    String owFromName   = request.getParameter("owFromName");
    String owToName     = request.getParameter("owToName");
    String owFlightNo   = request.getParameter("owFlightNo");
    String owAirlines   = request.getParameter("owAirlines");

    // Return
    boolean hasReturn   = "1".equals(request.getParameter("hasReturn"));
    String retDate      = request.getParameter("retDate");
    String retTime      = request.getParameter("retTime");
    String retFromName  = request.getParameter("retFromName");
    String retToName    = request.getParameter("retToName");
    String retFlightNo  = request.getParameter("retFlightNo");
    String retAirlines  = request.getParameter("retAirlines");

    // Passengers
    int noOfSeats = 1;
    try { noOfSeats = Integer.parseInt(request.getParameter("noOfSeats")); } catch (Exception e) {}
    String phone = request.getParameter("phone");

    // Agent - Buy
    String buyAgentIdStr  = request.getParameter("buyAgentId");
    String buyAmountStr   = request.getParameter("buyAmount");
    String buyModeIdStr   = request.getParameter("buyModeId");

    // Agent / Customer - Sell
    String sellAgentIdStr = request.getParameter("sellAgentId");
    String sellAmountStr  = request.getParameter("sellAmount");
    String sellModeIdStr  = request.getParameter("sellModeId");
    String customerName   = request.getParameter("customerName");
    String custAmountStr  = request.getParameter("custAmount");
    String custModeIdStr  = request.getParameter("custModeId");

    // Paid amounts (partial payment support)
    String buyPaidStr  = request.getParameter("buyPaidAmount");
    String sellPaidStr = request.getParameter("sellPaidAmount");
    String custPaidStr = request.getParameter("custPaidAmount");

    // Validation
    if (bookingDate == null || bookingDate.trim().isEmpty()) {
        out.print("ERROR:Booking date is required"); return;
    }
    if (owFromName == null || owFromName.trim().isEmpty() || owToName == null || owToName.trim().isEmpty()) {
        out.print("ERROR:From and To cities are required"); return;
    }
    if (owFromName.trim().equalsIgnoreCase(owToName.trim())) {
        out.print("ERROR:From and To cities cannot be the same"); return;
    }

    // Resolve city IDs (get or insert)
    int owFromId = billing.getOrInsertTicketCity(owFromName.trim());
    int owToId   = billing.getOrInsertTicketCity(owToName.trim());
    Integer retFromId = null, retToId = null;
    if (hasReturn) {
        if (retFromName != null && !retFromName.trim().isEmpty())
            retFromId = billing.getOrInsertTicketCity(retFromName.trim());
        if (retToName != null && !retToName.trim().isEmpty())
            retToId = billing.getOrInsertTicketCity(retToName.trim());
    }

    // Parse agents & amounts
    Integer buyAgentId  = (buyAgentIdStr  != null && !buyAgentIdStr.isEmpty())  ? Integer.parseInt(buyAgentIdStr)  : null;
    Double  buyAmount   = (buyAmountStr   != null && !buyAmountStr.isEmpty())   ? Double.parseDouble(buyAmountStr)   : null;
    Integer buyModeId   = (buyModeIdStr   != null && !buyModeIdStr.isEmpty())   ? Integer.parseInt(buyModeIdStr)   : null;
    Integer sellAgentId = (sellAgentIdStr != null && !sellAgentIdStr.isEmpty()) ? Integer.parseInt(sellAgentIdStr) : null;
    Double  sellAmount  = (sellAmountStr  != null && !sellAmountStr.isEmpty())  ? Double.parseDouble(sellAmountStr)  : null;
    Integer sellModeId  = (sellModeIdStr  != null && !sellModeIdStr.isEmpty())  ? Integer.parseInt(sellModeIdStr)  : null;
    Double  custAmount  = (custAmountStr  != null && !custAmountStr.isEmpty())  ? Double.parseDouble(custAmountStr)  : null;
    Integer custModeId  = (custModeIdStr  != null && !custModeIdStr.isEmpty())  ? Integer.parseInt(custModeIdStr)  : null;

    Double buyPaidAmount  = (buyPaidStr  != null && !buyPaidStr.isEmpty())  ? Double.parseDouble(buyPaidStr)  : null;
    Double sellPaidAmount = (sellPaidStr != null && !sellPaidStr.isEmpty()) ? Double.parseDouble(sellPaidStr) : null;
    Double custPaidAmount = (custPaidStr != null && !custPaidStr.isEmpty()) ? Double.parseDouble(custPaidStr) : null;

    // Passenger names array
    String[] passengerNames = new String[noOfSeats];
    for (int i = 0; i < noOfSeats; i++) {
        passengerNames[i] = request.getParameter("passenger_" + (i + 1));
        if (passengerNames[i] == null) passengerNames[i] = "";
    }

    int bookingId = billing.saveTicketBooking(
        pnr, bookingDate,
        owDate, owTime, owFromId, owToId, owFlightNo, owAirlines,
        hasReturn ? retDate : null, hasReturn ? retTime : null, retFromId, retToId,
        hasReturn ? retFlightNo : null, hasReturn ? retAirlines : null,
        noOfSeats, phone,
        buyAgentId, buyAmount, buyModeId,
        sellAgentId, sellAmount, sellModeId,
        customerName, custAmount, custModeId,
        passengerNames, userId,
        buyPaidAmount, sellPaidAmount, custPaidAmount
    );

    out.print("SUCCESS:" + bookingId);

} catch (Exception e) {
    e.printStackTrace();
    out.print("ERROR:" + e.getMessage());
}
%>
