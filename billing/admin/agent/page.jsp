<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}
String contextPathAgent = request.getContextPath();
Vector agentList = prod.getAllAgents();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Agent Management</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <%@ include file="/assets/common/head.jsp" %>
    <style>
        body { background: #f5f7fa; }
        .table td, .table th { vertical-align: middle; }
        .badge-active { background: #28a745; color: white; padding: 4px 8px; border-radius: 4px; font-size: 0.85rem; }
        .badge-blocked { background: #dc3545; color: white; padding: 4px 8px; border-radius: 4px; font-size: 0.85rem; }
    </style>
</head>
<body>
    <%@ include file="/assets/navbar/navbar.jsp" %>

    <div class="container mt-4">
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3>Agent Management</h3>
            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addAgentModal">
                <i class="fa-solid fa-plus"></i> Add Agent
            </button>
        </div>

        <div class="card">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover table-bordered">
                        <thead class="table-light">
                            <tr>
                                <th>#</th>
                                <th>Name</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                            if (agentList != null && agentList.size() > 0) {
                                for (int i = 0; i < agentList.size(); i++) {
                                    Vector row = (Vector) agentList.elementAt(i);
                                    int id = Integer.parseInt(row.get(0).toString());
                                    String name = row.get(1).toString();
                                    int isActive = Integer.parseInt(row.get(2).toString());
                            %>
                            <tr>
                                <td><%=i+1%></td>
                                <td><%=name%></td>
                                <td>
                                    <span class="badge <%=isActive == 1 ? "badge-active" : "badge-blocked"%>">
                                        <%=isActive == 1 ? "Active" : "Blocked"%>
                                    </span>
                                </td>
                                <td>
                                    <button class="btn btn-sm btn-warning btn-edit-agent"
                                        data-id="<%=id%>"
                                        data-name="<%=name.replace("\"", "&quot;")%>">
                                        <i class="fa-solid fa-edit"></i> Edit
                                    </button>
                                    <%if (isActive == 1) {%>
                                    <button class="btn btn-sm btn-danger btn-toggle-agent" data-id="<%=id%>" data-status="0">
                                        <i class="fa-solid fa-ban"></i> Block
                                    </button>
                                    <%} else {%>
                                    <button class="btn btn-sm btn-success btn-toggle-agent" data-id="<%=id%>" data-status="1">
                                        <i class="fa-solid fa-check"></i> Unblock
                                    </button>
                                    <%}%>
                                </td>
                            </tr>
                            <%
                                }
                            } else {
                            %>
                            <tr><td colspan="4" class="text-center">No agents found</td></tr>
                            <%}%>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Add Agent Modal -->
    <div class="modal fade" id="addAgentModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Add Agent</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="addAgentForm">
                        <input type="hidden" name="action" value="add">
                        <div class="mb-3">
                            <label class="form-label">Name <span class="text-danger">*</span></label>
                            <input type="text" name="name" class="form-control" required>
                        </div>
                        <button type="submit" class="btn btn-primary">Add Agent</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Edit Agent Modal -->
    <div class="modal fade" id="editAgentModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Edit Agent</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="editAgentForm">
                        <input type="hidden" name="action" value="edit">
                        <input type="hidden" name="id" id="editAgentId">
                        <div class="mb-3">
                            <label class="form-label">Name <span class="text-danger">*</span></label>
                            <input type="text" name="name" id="editAgentName" class="form-control" required>
                        </div>
                        <button type="submit" class="btn btn-primary">Update Agent</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        const saveUrl = '<%=contextPathAgent%>/admin/agent/save.jsp';

        document.getElementById('addAgentForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const params = new URLSearchParams(new FormData(this)).toString();
            fetch(saveUrl, { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: params })
                .then(r => r.text()).then(data => {
                    if (data.trim() === 'SUCCESS') { location.reload(); }
                    else { alert('Error: ' + data); }
                });
        });

        document.addEventListener('click', function(e) {
            if (e.target.closest('.btn-edit-agent')) {
                const btn = e.target.closest('.btn-edit-agent');
                document.getElementById('editAgentId').value = btn.getAttribute('data-id');
                document.getElementById('editAgentName').value = btn.getAttribute('data-name');
                new bootstrap.Modal(document.getElementById('editAgentModal')).show();
            }
            if (e.target.closest('.btn-toggle-agent')) {
                const btn = e.target.closest('.btn-toggle-agent');
                const status = btn.getAttribute('data-status');
                const label = status === '1' ? 'unblock' : 'block';
                if (!confirm('Are you sure you want to ' + label + ' this agent?')) return;
                const params = 'action=toggle&id=' + btn.getAttribute('data-id') + '&status=' + status;
                fetch(saveUrl, { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: params })
                    .then(r => r.text()).then(data => {
                        if (data.trim() === 'SUCCESS') { location.reload(); }
                        else { alert('Error: ' + data); }
                    });
            }
        });

        document.getElementById('editAgentForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const params = new URLSearchParams(new FormData(this)).toString();
            fetch(saveUrl, { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: params })
                .then(r => r.text()).then(data => {
                    if (data.trim() === 'SUCCESS') { location.reload(); }
                    else { alert('Error: ' + data); }
                });
        });
    </script>
</body>
</html>
