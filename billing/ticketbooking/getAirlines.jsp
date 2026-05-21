<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<%
request.setCharacterEncoding("UTF-8");
String term = request.getParameter("term");
if (term == null) term = "";
Vector results = billing.searchTicketAirline(term);
StringBuilder json = new StringBuilder("[");
for (int i = 0; i < results.size(); i++) {
    Vector row = (Vector) results.elementAt(i);
    if (i > 0) json.append(",");
    String name = row.get(1).toString().replace("\\","\\\\").replace("\"","\\\"");
    json.append("{\"id\":").append(row.get(0))
        .append(",\"label\":\"").append(name)
        .append("\",\"value\":\"").append(name).append("\"}");
}
json.append("]");
out.print(json.toString());
%>
