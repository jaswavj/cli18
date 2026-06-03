<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8"%>
<%
response.setHeader("Cache-Control","no-store");
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) { out.print("{\"error\":\"SESSION\"}"); return; }

String bookingIdStr = request.getParameter("bookingId");
String agentIdStr   = request.getParameter("agentId");
String amountStr    = request.getParameter("amount");

if (bookingIdStr == null || amountStr == null) { out.print("{\"duplicate\":false}"); return; }

int bookingId = 0;
int agentId   = 0;
double amount = 0;
try { bookingId = Integer.parseInt(bookingIdStr); } catch (Exception e) { out.print("{\"duplicate\":false}"); return; }
try { agentId  = Integer.parseInt(agentIdStr);    } catch (Exception e) { agentId = 0; }
try { amount   = Double.parseDouble(amountStr);   } catch (Exception e) { out.print("{\"duplicate\":false}"); return; }

java.sql.Connection con = null;
java.sql.PreparedStatement pt = null;
java.sql.ResultSet rs = null;
try {
    con = util.DBConnectionManager.getConnectionFromPool();
    // Check if same booking_id + agent_id + amount was already collected TODAY
    // bill_amount=0 identifies collection entries (vs original booking entries)
    String sql =
        "SELECT l.id, l.created_at, " +
        "       COALESCE(u.fullName, u.user_name, 'Unknown') AS entered_by " +
        "FROM ticket_ledger l " +
        "LEFT JOIN users u ON u.id = l.created_by " +
        "WHERE l.booking_id = ? " +
        "  AND (l.agent_id = ? OR (? = 0 AND l.agent_id IS NULL)) " +
        "  AND ABS(l.amount - ?) < 0.005 " +
        "  AND DATE(l.created_at) = CURDATE() " +
        "  AND l.bill_amount = 0 " +
        "LIMIT 1";
    pt = con.prepareStatement(sql);
    pt.setInt(1, bookingId);
    pt.setInt(2, agentId);
    pt.setInt(3, agentId);
    pt.setDouble(4, amount);
    rs = pt.executeQuery();
    if (rs.next()) {
        String enteredBy = rs.getString("entered_by");
        java.sql.Timestamp createdAt = rs.getTimestamp("created_at");
        String dtStr = "";
        if (createdAt != null) {
            java.text.SimpleDateFormat fmt = new java.text.SimpleDateFormat("dd/MM/yyyy hh:mm a");
            dtStr = fmt.format(createdAt);
        }
        if (enteredBy == null) enteredBy = "Unknown";
        // Safe JSON escaping
        enteredBy = enteredBy.replace("\\", "\\\\").replace("\"", "\\\"");
        dtStr     = dtStr.replace("\\", "\\\\").replace("\"", "\\\"");
        out.print("{\"duplicate\":true,\"enteredBy\":\"" + enteredBy + "\",\"dateTime\":\"" + dtStr + "\"}");
    } else {
        out.print("{\"duplicate\":false}");
    }
} catch (Exception e) {
    out.print("{\"duplicate\":false}");
} finally {
    if (rs  != null) try { rs.close();  } catch (Exception ex) { ; }
    if (pt  != null) try { pt.close();  } catch (Exception ex) { ; }
    if (con != null) try { con.close(); } catch (Exception ex) { ; }
}
%>
