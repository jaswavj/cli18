<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
try {
    request.setCharacterEncoding("UTF-8");
    String action = request.getParameter("action");

    if (action == null || action.trim().isEmpty()) {
        out.print("ERROR: No action specified");
        return;
    }

    if ("add".equals(action)) {
        String name = request.getParameter("name");
        if (name == null || name.trim().isEmpty()) {
            out.print("ERROR: Name is required");
            return;
        }
        boolean ok = prod.addAgent(name.trim());
        out.print(ok ? "SUCCESS" : "ERROR: Failed to add agent");

    } else if ("edit".equals(action)) {
        String idStr = request.getParameter("id");
        String name = request.getParameter("name");
        if (idStr == null || name == null || name.trim().isEmpty()) {
            out.print("ERROR: ID and Name are required");
            return;
        }
        boolean ok = prod.updateAgent(Integer.parseInt(idStr), name.trim());
        out.print(ok ? "SUCCESS" : "ERROR: Failed to update agent");

    } else if ("toggle".equals(action)) {
        String idStr = request.getParameter("id");
        String statusStr = request.getParameter("status");
        if (idStr == null || statusStr == null) {
            out.print("ERROR: ID and status are required");
            return;
        }
        boolean ok = prod.toggleAgent(Integer.parseInt(idStr), Integer.parseInt(statusStr));
        out.print(ok ? "SUCCESS" : "ERROR: Failed to update agent status");

    } else {
        out.print("ERROR: Invalid action");
    }
} catch (Exception e) {
    e.printStackTrace();
    out.print("ERROR: " + e.getMessage());
}
%>
