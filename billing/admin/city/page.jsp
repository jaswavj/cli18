<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page language="java" import="java.util.*"%>
<jsp:useBean id="prod" class="product.productBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}
String contextPathCity = request.getContextPath();
Vector cityList = prod.getAllCities();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>City Management</title>
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
            <h3>City Management</h3>
            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addCityModal">
                <i class="fa-solid fa-plus"></i> Add City
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
                            if (cityList != null && cityList.size() > 0) {
                                for (int i = 0; i < cityList.size(); i++) {
                                    Vector row = (Vector) cityList.elementAt(i);
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
                                    <button class="btn btn-sm btn-warning btn-edit-city"
                                        data-id="<%=id%>"
                                        data-name="<%=name.replace("\"", "&quot;")%>">
                                        <i class="fa-solid fa-edit"></i> Edit
                                    </button>
                                    <%if (isActive == 1) {%>
                                    <button class="btn btn-sm btn-danger btn-toggle-city" data-id="<%=id%>" data-status="0">
                                        <i class="fa-solid fa-ban"></i> Block
                                    </button>
                                    <%} else {%>
                                    <button class="btn btn-sm btn-success btn-toggle-city" data-id="<%=id%>" data-status="1">
                                        <i class="fa-solid fa-check"></i> Unblock
                                    </button>
                                    <%}%>
                                </td>
                            </tr>
                            <%
                                }
                            } else {
                            %>
                            <tr><td colspan="4" class="text-center">No cities found</td></tr>
                            <%}%>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- Add City Modal -->
    <div class="modal fade" id="addCityModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Add City</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="addCityForm">
                        <input type="hidden" name="action" value="add">
                        <div class="mb-3">
                            <label class="form-label">Name <span class="text-danger">*</span></label>
                            <input type="text" name="name" class="form-control" required>
                        </div>
                        <button type="submit" class="btn btn-primary">Add City</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Edit City Modal -->
    <div class="modal fade" id="editCityModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Edit City</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="editCityForm">
                        <input type="hidden" name="action" value="edit">
                        <input type="hidden" name="id" id="editCityId">
                        <div class="mb-3">
                            <label class="form-label">Name <span class="text-danger">*</span></label>
                            <input type="text" name="name" id="editCityName" class="form-control" required>
                        </div>
                        <button type="submit" class="btn btn-primary">Update City</button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script>
        const saveUrl = '<%=contextPathCity%>/admin/city/save.jsp';

        document.getElementById('addCityForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const params = new URLSearchParams(new FormData(this)).toString();
            fetch(saveUrl, { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: params })
                .then(r => r.text()).then(data => {
                    if (data.trim() === 'SUCCESS') { location.reload(); }
                    else { alert('Error: ' + data); }
                });
        });

        document.addEventListener('click', function(e) {
            if (e.target.closest('.btn-edit-city')) {
                const btn = e.target.closest('.btn-edit-city');
                document.getElementById('editCityId').value = btn.getAttribute('data-id');
                document.getElementById('editCityName').value = btn.getAttribute('data-name');
                new bootstrap.Modal(document.getElementById('editCityModal')).show();
            }
            if (e.target.closest('.btn-toggle-city')) {
                const btn = e.target.closest('.btn-toggle-city');
                const status = btn.getAttribute('data-status');
                const label = status === '1' ? 'unblock' : 'block';
                if (!confirm('Are you sure you want to ' + label + ' this city?')) return;
                const params = 'action=toggle&id=' + btn.getAttribute('data-id') + '&status=' + status;
                fetch(saveUrl, { method: 'POST', headers: { 'Content-Type': 'application/x-www-form-urlencoded' }, body: params })
                    .then(r => r.text()).then(data => {
                        if (data.trim() === 'SUCCESS') { location.reload(); }
                        else { alert('Error: ' + data); }
                    });
            }
        });

        document.getElementById('editCityForm').addEventListener('submit', function(e) {
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
