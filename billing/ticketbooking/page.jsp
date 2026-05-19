<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,java.text.SimpleDateFormat"%>
<jsp:useBean id="billing" class="billing.billingBean" />
<%
Integer userId = (Integer) session.getAttribute("userId");
if (userId == null) {
    response.sendRedirect(request.getContextPath() + "/index.jsp");
    return;
}
String ctx = request.getContextPath();
Vector agents       = billing.getTicketAgents();
Vector payModes     = billing.getTicketPaymentModes();
String lastTicketNo = billing.getLastTicketNo();
String today = new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Ticket Booking</title>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
<%@ include file="/assets/common/head.jsp" %>
<style>
:root {
    --navy:        #1a2744;
    --navy2:       #243159;
    --violet:      #5c4d8a;
    --violet-d:    #4a3d78;
    --gold:        #c9922a;
    --gold-d:      #a87520;
    --bg:          #eef1f7;
    --card:        #ffffff;
    --border:      #d1d9e6;
    --border-l:    #e8edf5;
    --text:        #0f172a;
    --muted:       #64748b;
    --inp-bg:      #f8fafc;
    --green:       #059669;
    --red:         #dc2626;
    --r:           8px;
    --r-sm:        5px;
    --shadow:      0 2px 12px rgba(0,0,0,.10);
    --shadow-sm:   0 1px 4px rgba(0,0,0,.07);
}

*,*::before,*::after { box-sizing:border-box; margin:0; padding:0; }
html,body { height:100%; font-family:'Segoe UI',system-ui,sans-serif; font-size:13px; background:var(--bg); color:var(--text); }

/* ── WRAPPER ── */
.tw { display:flex; flex-direction:column; height:100vh; height:100dvh; overflow:hidden; }
.tw-nav { flex-shrink:0; }
.tw-body { flex:1; min-height:0; overflow-y:auto; padding:12px 14px 20px; }
.tw-body::-webkit-scrollbar { width:5px; }
.tw-body::-webkit-scrollbar-track { background:#f1f5f9; }
.tw-body::-webkit-scrollbar-thumb { background:var(--violet); border-radius:3px; }

/* ── HEADER BAR ── */
.tb-header {
    flex-shrink:0;
    background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);
    padding:10px 16px;
    display:flex; align-items:center; gap:10px; flex-wrap:wrap;
    box-shadow:0 2px 8px rgba(0,0,0,.25);
}
.tb-header-title {
    display:flex; align-items:center; gap:9px; color:#fff;
    font-size:15px; font-weight:800; letter-spacing:.4px; flex-shrink:0;
}
.tb-header-title i { color:var(--gold); font-size:17px; }
.tb-divider { width:1px; height:28px; background:rgba(255,255,255,.2); flex-shrink:0; }
.tb-id-badge {
    background:rgba(255,255,255,.12); border:1px solid rgba(255,255,255,.2);
    color:#fff; border-radius:var(--r-sm); padding:5px 12px;
    font-size:12px; font-weight:700; letter-spacing:.5px; white-space:nowrap;
    min-width:100px; text-align:center;
}
.hdr-spacer { flex:1; }

/* ── FIELD GROUP ── */
.fg { display:flex; flex-direction:column; gap:3px; min-width:0; position:relative; }
.fg-lbl {
    font-size:10px; font-weight:700; color:rgba(255,255,255,.7);
    text-transform:uppercase; letter-spacing:.5px; white-space:nowrap;
}
.fg-lbl-dark { color:var(--muted); }
.fg-inp,.fg-sel {
    height:33px; border:1.5px solid var(--border); border-radius:var(--r-sm);
    padding:0 9px; background:var(--inp-bg); color:var(--text); font-size:13px;
    outline:none; transition:border-color .15s,box-shadow .15s; width:100%;
}
.fg-sel { cursor:pointer; }
.fg-inp:focus,.fg-sel:focus {
    border-color:var(--violet);
    box-shadow:0 0 0 3px rgba(92,77,138,.18); background:#fff;
}
.fg-inp.hdr-inp {
    background:rgba(255,255,255,.12); border-color:rgba(255,255,255,.25);
    color:#fff; height:33px;
}
.fg-inp.hdr-inp::placeholder { color:rgba(255,255,255,.4); }
.fg-inp.hdr-inp:focus { border-color:var(--gold); box-shadow:0 0 0 3px rgba(201,146,42,.2); background:rgba(255,255,255,.18); }

/* ── BUTTONS ── */
.bb {
    display:inline-flex; align-items:center; gap:6px; height:33px; padding:0 15px;
    border-radius:var(--r-sm); font-size:12px; font-weight:700; cursor:pointer;
    border:1.5px solid transparent; transition:all .15s; white-space:nowrap; letter-spacing:.2px;
}
.bb-gold { background:var(--gold); color:#fff; border-color:var(--gold); }
.bb-gold:hover { background:var(--gold-d); border-color:var(--gold-d); }
.bb-outline-white { background:transparent; color:#fff; border-color:rgba(255,255,255,.4); }
.bb-outline-white:hover { background:rgba(255,255,255,.1); }
.bb-green { background:var(--green); color:#fff; border-color:var(--green); }
.bb-green:hover { background:#047857; }
.bb-red { background:var(--red); color:#fff; border-color:var(--red); }

/* ── SECTION CARDS ── */
.sec-card {
    background:var(--card); border-radius:var(--r); border:1px solid var(--border-l);
    box-shadow:var(--shadow-sm); margin-bottom:12px; overflow:hidden;
}
.sec-head {
    display:flex; align-items:center; gap:9px;
    background:linear-gradient(135deg,var(--navy) 0%,var(--navy2) 100%);
    padding:9px 14px; color:#fff;
}
.sec-head i { color:var(--gold); font-size:14px; }
.sec-head-title { font-size:12px; font-weight:800; text-transform:uppercase; letter-spacing:.6px; }
.sec-head-badge {
    margin-left:auto; background:rgba(255,255,255,.15); border:1px solid rgba(255,255,255,.25);
    color:#fff; border-radius:3px; padding:2px 8px; font-size:10px; font-weight:700; letter-spacing:.4px;
}
.sec-body { padding:14px; }

/* ── FLIGHT STRIP ── */
.flight-strip {
    display:flex; gap:8px; align-items:flex-end; flex-wrap:wrap;
    background:#f7f8fc; border:1px solid var(--border-l); border-radius:var(--r-sm); padding:10px 12px;
}
.flight-strip.return-strip { background:#f3f7f3; border-color:#c8e6c9; }

.route-sep {
    display:flex; flex-direction:column; align-items:center; justify-content:flex-end;
    color:var(--violet); font-size:18px; padding-bottom:6px; flex-shrink:0; min-width:24px;
}

/* City autocomplete */
.city-wrap { position:relative; }
.city-dropdown {
    position:absolute; top:100%; left:0; right:0; z-index:1000;
    background:#fff; border:1.5px solid var(--border); border-top:none;
    border-radius:0 0 var(--r-sm) var(--r-sm); max-height:180px; overflow-y:auto;
    box-shadow:0 4px 12px rgba(0,0,0,.12); display:none;
}
.city-dropdown li {
    list-style:none; padding:7px 11px; cursor:pointer;
    font-size:12.5px; color:var(--text); transition:background .1s;
    border-bottom:1px solid var(--border-l);
    display:flex; align-items:center; gap:6px;
}
.city-dropdown li:hover,.city-dropdown li.active { background:#f0edf8; color:var(--violet); }
.city-dropdown li i { color:var(--violet); font-size:11px; }
.city-dropdown .add-option { color:var(--green); font-weight:700; }
.city-dropdown .add-option i { color:var(--green); }
.city-new-badge {
    font-size:9px; background:#e8f5e9; color:var(--green);
    border:1px solid #c8e6c9; border-radius:3px; padding:1px 5px; font-weight:700;
}

/* ── PASSENGER GRID ── */
.pax-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(200px,1fr)); gap:8px; margin-top:10px; }
.pax-item { display:flex; flex-direction:column; gap:3px; }
.pax-lbl {
    font-size:10px; font-weight:700; color:var(--muted);
    text-transform:uppercase; letter-spacing:.4px;
    display:flex; align-items:center; gap:5px;
}
.pax-num { background:var(--navy); color:#fff; border-radius:3px; padding:1px 6px; font-size:9px; }

/* ── TRANSACTION CARD ── */
.txn-grid { display:grid; grid-template-columns:1fr 1fr; gap:12px; }
.txn-block {
    border:2px solid var(--border-l); border-radius:var(--r-sm); overflow:hidden;
}
.txn-block-head {
    display:flex; align-items:center; gap:7px; padding:8px 12px;
    font-size:11px; font-weight:800; text-transform:uppercase; letter-spacing:.5px;
}
.txn-block-head.buy-head { background:#fff3e0; color:#bf6000; border-bottom:1px solid #ffe0b2; }
.txn-block-head.buy-head i { color:#e65100; }
.txn-block-head.sell-head { background:#e8f5e9; color:#1b5e20; border-bottom:1px solid #c8e6c9; }
.txn-block-head.sell-head i { color:#2e7d32; }
.txn-block-head .toggle-sw { margin-left:auto; }
.txn-block-body { padding:10px 12px; background:#fafafa; }
.txn-block-body.disabled { opacity:.4; pointer-events:none; }
.txn-row { display:flex; gap:8px; flex-wrap:wrap; align-items:flex-end; }

/* Toggle switch */
.sw { position:relative; display:inline-flex; align-items:center; cursor:pointer; gap:7px; }
.sw input { display:none; }
.sw-track {
    width:36px; height:20px; background:#ccc; border-radius:10px;
    transition:background .2s; flex-shrink:0; position:relative;
}
.sw-track::after {
    content:''; position:absolute; top:2px; left:2px;
    width:16px; height:16px; background:#fff; border-radius:50%;
    transition:transform .2s; box-shadow:0 1px 3px rgba(0,0,0,.2);
}
.sw input:checked ~ .sw-track { background:var(--green); }
.sw input:checked ~ .sw-track::after { transform:translateX(16px); }
.sw-lbl { font-size:11px; font-weight:700; color:var(--muted); }

/* Sell type radio buttons */
.sell-type-row { display:flex; gap:6px; margin-bottom:10px; flex-wrap:wrap; }
.sell-chip {
    display:flex; align-items:center; gap:5px; padding:5px 10px;
    border:1.5px solid var(--border); border-radius:20px; cursor:pointer;
    font-size:11px; font-weight:700; color:var(--muted); transition:all .15s;
}
.sell-chip:hover { border-color:var(--violet); color:var(--violet); }
.sell-chip input { display:none; }
.sell-chip.selected { background:var(--violet); color:#fff; border-color:var(--violet); }

/* ── RESPONSIVE ── */
@media(max-width:768px) {
    .tb-header { padding:8px 10px; gap:7px; }
    .txn-grid { grid-template-columns:1fr; }
    .flight-strip { gap:6px; }
}
@media(max-width:480px) {
    .flight-strip { display:grid; grid-template-columns:1fr 1fr; }
    .route-sep { display:none; }
    .pax-grid { grid-template-columns:1fr 1fr; }
}

/* ── BALANCE BADGE ── */
.bal-display {
    display:flex; flex-direction:column; gap:2px; min-width:90px;
}
.bal-display .fg-lbl-dark { margin-bottom:1px; }
.bal-amt {
    height:33px; border:1.5px solid var(--border-l); border-radius:var(--r-sm);
    padding:0 9px; background:#f1f5f9; color:var(--text); font-size:13px;
    font-weight:700; display:flex; align-items:center; white-space:nowrap;
}
.bal-amt.bal-zero { color:var(--green); }
.bal-amt.bal-due  { color:var(--red);   background:#fff5f5; border-color:#fecaca; }

/* Autocomplete override */
.ui-autocomplete {
    font-size:12.5px; border:1.5px solid var(--border);
    border-radius:0 0 var(--r-sm) var(--r-sm);
    box-shadow:0 4px 12px rgba(0,0,0,.12);
}
.ui-menu-item-wrapper { padding:7px 11px !important; }
.ui-state-active,.ui-widget-content .ui-state-active {
    background:#f0edf8 !important; color:var(--violet) !important;
    border:none !important;
}
</style>
</head>
<body>

<div class="tw">
  <div class="tw-nav"><%@ include file="/assets/navbar/navbar.jsp" %></div>

  <!-- ══ HEADER BAR ══ -->
  <div class="tb-header">
    <div class="tb-header-title">
      <i class="fa-solid fa-plane-departure"></i>
      <span>TICKET BOOKING</span>
    </div>
    <%if (!lastTicketNo.isEmpty()) {%>
    <div class="tb-id-badge" title="Last saved ticket number">
      <i class="fa-solid fa-ticket" style="color:var(--gold);margin-right:5px;"></i>Last: <%=lastTicketNo%>
    </div>
    <%}%>
    <div class="tb-divider"></div>

    <div class="fg">
      <div class="fg-lbl">PNR Number</div>
      <input id="pnr" type="text" class="fg-inp hdr-inp" placeholder="Enter PNR" style="width:140px;" autocomplete="off">
    </div>

    <div class="fg">
      <div class="fg-lbl">Booking Date</div>
      <input id="bookingDate" type="date" class="fg-inp hdr-inp" value="<%=today%>" style="width:140px;">
    </div>

    <div class="hdr-spacer"></div>

    <button class="bb bb-outline-white" onclick="resetForm()">
      <i class="fa-solid fa-rotate-left"></i> Clear
    </button>
    <button class="bb bb-gold" id="saveBtn" onclick="submitBooking()">
      <i class="fa-solid fa-floppy-disk"></i> Save Booking
    </button>
    <button class="bb" id="printBtn" style="display:none;background:#059669;color:#fff;border-color:#059669;">
      <i class="fa-solid fa-print"></i> Print Ticket
    </button>
  </div>

  <!-- ══ BODY ══ -->
  <div class="tw-body">

    <!-- ── JOURNEY DETAILS ── -->
    <div class="sec-card">
      <div class="sec-head">
        <i class="fa-solid fa-route"></i>
        <span class="sec-head-title">Journey Details</span>
      </div>
      <div class="sec-body">

        <!-- ONE WAY -->
        <div style="display:flex;align-items:center;gap:8px;margin-bottom:8px;">
          <i class="fa-solid fa-plane-departure" style="color:var(--violet);font-size:13px;"></i>
          <span style="font-size:11px;font-weight:800;text-transform:uppercase;letter-spacing:.5px;color:var(--navy);">One Way</span>
        </div>
        <div class="flight-strip">
          <div class="fg" style="width:120px;">
            <div class="fg-lbl fg-lbl-dark">Travel Date</div>
            <input id="owDate" type="date" class="fg-inp">
          </div>
          <div class="fg" style="width:105px;">
            <div class="fg-lbl fg-lbl-dark">Time</div>
            <input id="owTime" type="time" class="fg-inp">
          </div>

          <div class="fg city-wrap" style="flex:1;min-width:130px;">
            <div class="fg-lbl fg-lbl-dark">From <span id="owFromNew" class="city-new-badge" style="display:none;">NEW</span></div>
            <input id="owFrom" type="text" class="fg-inp city-inp" data-hidden="owFromId" placeholder="City / Airport" autocomplete="off">
            <input type="hidden" id="owFromId">
          </div>

          <div class="route-sep"><i class="fa-solid fa-arrow-right"></i></div>

          <div class="fg city-wrap" style="flex:1;min-width:130px;">
            <div class="fg-lbl fg-lbl-dark">To <span id="owToNew" class="city-new-badge" style="display:none;">NEW</span></div>
            <input id="owTo" type="text" class="fg-inp city-inp" data-hidden="owToId" placeholder="City / Airport" autocomplete="off">
            <input type="hidden" id="owToId">
          </div>

          <div class="fg" style="width:120px;">
            <div class="fg-lbl fg-lbl-dark">Flight No</div>
            <input id="owFlightNo" type="text" class="fg-inp" placeholder="e.g. AI-202">
          </div>
          <div class="fg" style="flex:1;min-width:130px;">
            <div class="fg-lbl fg-lbl-dark">Airlines</div>
            <input id="owAirlines" type="text" class="fg-inp" placeholder="e.g. Air India">
          </div>
        </div>

        <!-- RETURN TOGGLE -->
        <div style="margin-top:12px;margin-bottom:8px;display:flex;align-items:center;gap:10px;">
          <label class="sw" id="retToggleWrap">
            <input type="checkbox" id="retToggle" onchange="toggleReturn(this.checked)">
            <span class="sw-track"></span>
            <span class="sw-lbl" style="font-size:12px;font-weight:800;color:var(--navy);">
              <i class="fa-solid fa-plane-arrival" style="color:var(--green);margin-right:4px;"></i>Include Return Journey
            </span>
          </label>
        </div>

        <!-- RETURN SECTION (hidden by default) -->
        <div id="returnSection" style="display:none;">
          <div class="flight-strip return-strip">
            <div class="fg" style="width:120px;">
              <div class="fg-lbl fg-lbl-dark">Return Date</div>
              <input id="retDate" type="date" class="fg-inp">
            </div>
            <div class="fg" style="width:105px;">
              <div class="fg-lbl fg-lbl-dark">Time</div>
              <input id="retTime" type="time" class="fg-inp">
            </div>
            <div class="fg city-wrap" style="flex:1;min-width:130px;">
              <div class="fg-lbl fg-lbl-dark">From <span id="retFromNew" class="city-new-badge" style="display:none;">NEW</span></div>
              <input id="retFrom" type="text" class="fg-inp city-inp" data-hidden="retFromId" placeholder="City / Airport" autocomplete="off">
              <input type="hidden" id="retFromId">
            </div>
            <div class="route-sep"><i class="fa-solid fa-arrow-right"></i></div>
            <div class="fg city-wrap" style="flex:1;min-width:130px;">
              <div class="fg-lbl fg-lbl-dark">To <span id="retToNew" class="city-new-badge" style="display:none;">NEW</span></div>
              <input id="retTo" type="text" class="fg-inp city-inp" data-hidden="retToId" placeholder="City / Airport" autocomplete="off">
              <input type="hidden" id="retToId">
            </div>
            <div class="fg" style="width:120px;">
              <div class="fg-lbl fg-lbl-dark">Flight No</div>
              <input id="retFlightNo" type="text" class="fg-inp" placeholder="e.g. AI-203">
            </div>
            <div class="fg" style="flex:1;min-width:130px;">
              <div class="fg-lbl fg-lbl-dark">Airlines</div>
              <input id="retAirlines" type="text" class="fg-inp" placeholder="e.g. Air India">
            </div>
          </div>
        </div>

      </div>
    </div>

    <!-- ── PASSENGER DETAILS ── -->
    <div class="sec-card">
      <div class="sec-head">
        <i class="fa-solid fa-users"></i>
        <span class="sec-head-title">Passenger Details</span>
        <div class="sec-head-badge" id="paxCountBadge">1 Passenger</div>
      </div>
      <div class="sec-body">
        <div style="display:flex;align-items:flex-end;gap:12px;flex-wrap:wrap;margin-bottom:4px;">
          <div class="fg" style="width:160px;">
            <div class="fg-lbl fg-lbl-dark">No. of Seats</div>
            <div style="display:flex;align-items:center;gap:0;">
              <button type="button" class="bb" style="background:#f1f5f9;color:var(--navy);border:1.5px solid var(--border);border-radius:var(--r-sm) 0 0 var(--r-sm);height:33px;padding:0 10px;font-size:16px;line-height:1;" onclick="changeSeatCount(-1)">−</button>
              <input id="noOfSeats" type="number" class="fg-inp" value="1" min="1" max="20" readonly
                     style="width:60px;text-align:center;border-radius:0;border-left:none;border-right:none;" onchange="renderPassengers()">
              <button type="button" class="bb" style="background:#f1f5f9;color:var(--navy);border:1.5px solid var(--border);border-radius:0 var(--r-sm) var(--r-sm) 0;height:33px;padding:0 10px;font-size:16px;line-height:1;" onclick="changeSeatCount(1)">+</button>
            </div>
          </div>
          <div class="fg" style="width:200px;">
            <div class="fg-lbl fg-lbl-dark">Common Phone No.</div>
            <input id="phone" type="tel" class="fg-inp" placeholder="Mobile number">
          </div>
        </div>
        <div class="pax-grid" id="paxGrid"></div>
      </div>
    </div>

    <!-- ── TRANSACTION DETAILS ── -->
    <div class="sec-card">
      <div class="sec-head">
        <i class="fa-solid fa-money-bill-transfer"></i>
        <span class="sec-head-title">Transaction Details</span>
      </div>
      <div class="sec-body">
        <div class="txn-grid">

          <!-- BUY BLOCK -->
          <div class="txn-block">
            <div class="txn-block-head buy-head">
              <i class="fa-solid fa-arrow-down-to-bracket"></i>
              Buy from Agent
              <label class="sw toggle-sw" title="Enable if buying from an agent">
                <input type="checkbox" id="buyToggle" onchange="toggleBuyBlock(this.checked)">
                <span class="sw-track"></span>
              </label>
            </div>
            <div class="txn-block-body disabled" id="buyBody">
              <div class="txn-row">
                <div class="fg" style="flex:1;min-width:130px;">
                  <div class="fg-lbl fg-lbl-dark">Agent</div>
                  <select id="buyAgent" class="fg-sel">
                    <option value="">— Select Agent —</option>
                    <%
                    for (int i = 0; i < agents.size(); i++) {
                        Vector a = (Vector) agents.elementAt(i);
                    %>
                    <option value="<%=a.get(0)%>"><%=a.get(1)%></option>
                    <%}%>
                  </select>
                </div>
                <div class="fg" style="width:100px;">
                  <div class="fg-lbl fg-lbl-dark">Bill Amount</div>
                  <input id="buyAmount" type="number" step="0.01" class="fg-inp" placeholder="0.00" oninput="syncPaid('buy');calcBal('buy')">
                </div>
                <div class="fg" style="width:100px;">
                  <div class="fg-lbl fg-lbl-dark">Paid Amount</div>
                  <input id="buyPaidAmount" type="number" step="0.01" class="fg-inp" placeholder="0.00" oninput="calcBal('buy')">
                </div>
                <div class="bal-display">
                  <div class="fg-lbl fg-lbl-dark">Balance</div>
                  <div class="bal-amt bal-zero" id="buyBalDisp">₹0.00</div>
                </div>
                <div class="fg" style="flex:1;min-width:120px;">
                  <div class="fg-lbl fg-lbl-dark">Payment Mode</div>
                  <select id="buyMode" class="fg-sel">
                    <option value="">— Mode —</option>
                    <%for (int i = 0; i < payModes.size(); i++) { Vector pm = (Vector)payModes.elementAt(i);%>
                    <option value="<%=pm.get(0)%>"><%=pm.get(1)%></option>
                    <%}%>
                  </select>
                </div>
              </div>
            </div>
          </div>

          <!-- SELL BLOCK -->
          <div class="txn-block">
            <div class="txn-block-head sell-head">
              <i class="fa-solid fa-arrow-up-from-bracket"></i>
              Sell To
              <label class="sw toggle-sw" title="Enable selling section">
                <input type="checkbox" id="sellToggle" checked onchange="toggleSellBlock(this.checked)">
                <span class="sw-track"></span>
              </label>
            </div>
            <div class="txn-block-body" id="sellBody">
              <div class="sell-type-row">
                <label class="sell-chip selected" id="chipCustomer">
                  <input type="radio" name="sellType" value="customer" checked onchange="setSellType('customer')">
                  <i class="fa-solid fa-user"></i> Customer
                </label>
                <label class="sell-chip" id="chipAgent">
                  <input type="radio" name="sellType" value="agent" onchange="setSellType('agent')">
                  <i class="fa-solid fa-building"></i> Agent
                </label>
              </div>

              <!-- Sell to Customer -->
              <div id="sellCustSection">
                <div class="txn-row">
                  <div class="fg" style="flex:1;min-width:140px;">
                    <div class="fg-lbl fg-lbl-dark">Customer Name</div>
                    <input id="custName" type="text" class="fg-inp" placeholder="Passenger / Customer name">
                  </div>
                  <div class="fg" style="width:100px;">
                    <div class="fg-lbl fg-lbl-dark">Bill Amount</div>
                    <input id="custAmount" type="number" step="0.01" class="fg-inp" placeholder="0.00" oninput="syncPaid('cust');calcBal('cust')">
                  </div>
                  <div class="fg" style="width:100px;">
                    <div class="fg-lbl fg-lbl-dark">Paid Amount</div>
                    <input id="custPaidAmount" type="number" step="0.01" class="fg-inp" placeholder="0.00" oninput="calcBal('cust')">
                  </div>
                  <div class="bal-display">
                    <div class="fg-lbl fg-lbl-dark">Balance</div>
                    <div class="bal-amt bal-zero" id="custBalDisp">₹0.00</div>
                  </div>
                  <div class="fg" style="flex:1;min-width:120px;">
                    <div class="fg-lbl fg-lbl-dark">Payment Mode</div>
                    <select id="custMode" class="fg-sel">
                      <option value="">— Mode —</option>
                      <%for (int i = 0; i < payModes.size(); i++) { Vector pm = (Vector)payModes.elementAt(i);%>
                      <option value="<%=pm.get(0)%>"><%=pm.get(1)%></option>
                      <%}%>
                    </select>
                  </div>
                </div>
              </div>

              <!-- Sell to Agent -->
              <div id="sellAgentSection" style="display:none;">
                <div class="txn-row">
                  <div class="fg" style="flex:1;min-width:130px;">
                    <div class="fg-lbl fg-lbl-dark">Agent</div>
                    <select id="sellAgent" class="fg-sel">
                      <option value="">— Select Agent —</option>
                      <%for (int i = 0; i < agents.size(); i++) { Vector a = (Vector)agents.elementAt(i);%>
                      <option value="<%=a.get(0)%>"><%=a.get(1)%></option>
                      <%}%>
                    </select>
                  </div>
                  <div class="fg" style="width:100px;">
                    <div class="fg-lbl fg-lbl-dark">Bill Amount</div>
                    <input id="sellAmount" type="number" step="0.01" class="fg-inp" placeholder="0.00" oninput="syncPaid('sell');calcBal('sell')">
                  </div>
                  <div class="fg" style="width:100px;">
                    <div class="fg-lbl fg-lbl-dark">Paid Amount</div>
                    <input id="sellPaidAmount" type="number" step="0.01" class="fg-inp" placeholder="0.00" oninput="calcBal('sell')">
                  </div>
                  <div class="bal-display">
                    <div class="fg-lbl fg-lbl-dark">Balance</div>
                    <div class="bal-amt bal-zero" id="sellBalDisp">₹0.00</div>
                  </div>
                  <div class="fg" style="flex:1;min-width:120px;">
                    <div class="fg-lbl fg-lbl-dark">Payment Mode</div>
                    <select id="sellMode" class="fg-sel">
                      <option value="">— Mode —</option>
                      <%for (int i = 0; i < payModes.size(); i++) { Vector pm = (Vector)payModes.elementAt(i);%>
                      <option value="<%=pm.get(0)%>"><%=pm.get(1)%></option>
                      <%}%>
                    </select>
                  </div>
                </div>
              </div>

            </div>
          </div>

        </div><!-- /txn-grid -->
      </div>
    </div>

    <!-- bottom space -->
    <div style="height:20px;"></div>
  </div><!-- /tw-body -->
</div><!-- /tw -->

<script>
const ctx = '<%=ctx%>';
let cityCache = {};   // text → {id, isNew}

// ══════════════════════════════════════════
//  City Autocomplete (jQuery UI)
// ══════════════════════════════════════════
function initCityAC(inp) {
    const hiddenId = inp.getAttribute('data-hidden');
    const newBadgeId = inp.id.replace('ow','ow').replace('ret','ret') + 'New';
    const $inp = $(inp);

    $inp.autocomplete({
        minLength: 1,
        delay: 200,
        source: function(req, resp) {
            $.getJSON(ctx + '/ticketbooking/getCities.jsp', { term: req.term }, function(data) {
                // Append "Add new" option if no exact match
                const lower = req.term.trim().toLowerCase();
                const exact = data.find(d => d.label.toLowerCase() === lower);
                if (!exact && req.term.trim().length > 0) {
                    data.push({ id: 0, label: '+ Add "' + req.term.trim() + '"', value: req.term.trim(), isNew: true });
                }
                resp(data);
            });
        },
        select: function(e, ui) {
            document.getElementById(hiddenId).value = ui.item.id;
            inp.value = ui.item.value;
            const badge = document.getElementById(inp.id + 'New');
            if (badge) badge.style.display = ui.item.isNew ? 'inline' : 'none';
            return false;
        },
        focus: function(e, ui) { inp.value = ui.item.isNew ? ui.item.value : ui.item.label; return false; }
    }).autocomplete('instance')._renderItem = function(ul, item) {
        return $('<li>').append(
            $('<div>').addClass('ui-menu-item-wrapper').html(
                item.isNew
                    ? '<i class="fa-solid fa-plus" style="color:var(--green);margin-right:6px;"></i><strong style="color:var(--green);">' + item.label + '</strong>'
                    : '<i class="fa-solid fa-location-dot" style="color:var(--violet);margin-right:6px;"></i>' + item.label
            )
        ).appendTo(ul);
    };

    // On blur — if hidden id is empty, resolve city via server
    $inp.on('blur', function() {
        const val = this.value.trim();
        if (!val) { document.getElementById(hiddenId).value = ''; return; }
        if (!document.getElementById(hiddenId).value) {
            // city text is new — mark for server-side getOrInsert
            document.getElementById(hiddenId).value = '0';
            const badge = document.getElementById(inp.id + 'New');
            if (badge) badge.style.display = 'inline';
        }
    });
}

$(function() {
    document.querySelectorAll('.city-inp').forEach(initCityAC);
});

// ══════════════════════════════════════════
//  Balance Calculation
// ══════════════════════════════════════════
// When bill amount changes, sync paid amount to match (full payment default)
function syncPaid(pfx) {
    const bill = parseFloat(document.getElementById(pfx + 'Amount')?.value) || 0;
    const paidEl = document.getElementById(pfx + 'PaidAmount');
    if (paidEl && !paidEl._touched) paidEl.value = bill > 0 ? bill.toFixed(2) : '';
}
// Mark paid field as manually touched so syncPaid won't override it
document.addEventListener('DOMContentLoaded', function() {
    ['buy','sell','cust'].forEach(function(pfx) {
        const el = document.getElementById(pfx + 'PaidAmount');
        if (el) el.addEventListener('input', function() { this._touched = true; });
    });
});

function calcBal(pfx) {
    const bill  = parseFloat(document.getElementById(pfx + 'Amount')?.value) || 0;
    const paid  = parseFloat(document.getElementById(pfx + 'PaidAmount')?.value) || 0;
    const bal   = bill - paid;
    const disp  = document.getElementById(pfx + 'BalDisp');
    if (!disp) return;
    disp.textContent = '₹' + Math.abs(bal).toFixed(2);
    disp.className = 'bal-amt ' + (bal <= 0 ? 'bal-zero' : 'bal-due');
}

// ══════════════════════════════════════════
//  Return section toggle
// ══════════════════════════════════════════
function toggleReturn(show) {
    document.getElementById('returnSection').style.display = show ? '' : 'none';
}

// ══════════════════════════════════════════
//  Passenger seats
// ══════════════════════════════════════════
function changeSeatCount(delta) {
    const el = document.getElementById('noOfSeats');
    let v = parseInt(el.value) + delta;
    if (v < 1) v = 1;
    if (v > 20) v = 20;
    el.value = v;
    renderPassengers();
}

function renderPassengers() {
    const n = parseInt(document.getElementById('noOfSeats').value) || 1;
    document.getElementById('paxCountBadge').textContent = n + (n === 1 ? ' Passenger' : ' Passengers');
    const grid = document.getElementById('paxGrid');
    // Preserve existing values
    const existing = {};
    grid.querySelectorAll('input[id^="pax_"]').forEach(el => {
        existing[el.id] = el.value;
    });
    grid.innerHTML = '';
    for (let i = 1; i <= n; i++) {
        const key = 'pax_' + i;
        const div = document.createElement('div');
        div.className = 'pax-item';
        div.innerHTML = `
            <div class="pax-lbl"><span class="pax-num">${i}</span>Passenger Name</div>
            <input id="${key}" type="text" class="fg-inp" placeholder="Full name" value="${existing[key] || ''}">
        `;
        grid.appendChild(div);
    }
}

// ══════════════════════════════════════════
//  Transaction toggles
// ══════════════════════════════════════════
function toggleBuyBlock(on) {
    document.getElementById('buyBody').classList.toggle('disabled', !on);
}
function toggleSellBlock(on) {
    document.getElementById('sellBody').classList.toggle('disabled', !on);
}
function setSellType(type) {
    const isCust = type === 'customer';
    document.getElementById('sellCustSection').style.display  = isCust ? '' : 'none';
    document.getElementById('sellAgentSection').style.display = isCust ? 'none' : '';
    document.getElementById('chipCustomer').classList.toggle('selected', isCust);
    document.getElementById('chipAgent').classList.toggle('selected', !isCust);
}

// ══════════════════════════════════════════
//  Reset
// ══════════════════════════════════════════
function resetForm() {
    if (!confirm('Clear all fields?')) return;
    const sb = document.getElementById('saveBtn');
    sb.disabled = false;
    sb.innerHTML = '<i class="fa-solid fa-floppy-disk"></i> Save Booking';
    sb.style.background = '';
    sb.style.borderColor = '';
    const pb = document.getElementById('printBtn');
    pb.style.display = 'none';
    pb.onclick = null;
    document.getElementById('pnr').value = '';
    ['owDate','owTime','owFrom','owFromId','owTo','owToId','owFlightNo','owAirlines',
     'retDate','retTime','retFrom','retFromId','retTo','retToId','retFlightNo','retAirlines'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.value = '';
    });
    ['owFromNew','owToNew','retFromNew','retToNew'].forEach(id => {
        const el = document.getElementById(id);
        if (el) el.style.display = 'none';
    });
    document.getElementById('retToggle').checked = false;
    toggleReturn(false);
    document.getElementById('noOfSeats').value = 1;
    document.getElementById('phone').value = '';
    renderPassengers();
    document.getElementById('buyToggle').checked = false;
    toggleBuyBlock(false);
    document.getElementById('buyAgent').value = '';
    document.getElementById('buyAmount').value = '';
    document.getElementById('buyPaidAmount').value = '';
    document.getElementById('buyPaidAmount')._touched = false;
    document.getElementById('buyBalDisp').textContent = '₹0.00';
    document.getElementById('buyBalDisp').className = 'bal-amt bal-zero';
    document.getElementById('buyMode').value = '';
    document.getElementById('sellToggle').checked = true;
    toggleSellBlock(true);
    setSellType('customer');
    document.getElementById('custName').value = '';
    document.getElementById('custAmount').value = '';
    document.getElementById('custPaidAmount').value = '';
    document.getElementById('custPaidAmount')._touched = false;
    document.getElementById('custBalDisp').textContent = '₹0.00';
    document.getElementById('custBalDisp').className = 'bal-amt bal-zero';
    document.getElementById('custMode').value = '';
    document.getElementById('sellAgent').value = '';
    document.getElementById('sellAmount').value = '';
    document.getElementById('sellPaidAmount').value = '';
    document.getElementById('sellPaidAmount')._touched = false;
    document.getElementById('sellBalDisp').textContent = '₹0.00';
    document.getElementById('sellBalDisp').className = 'bal-amt bal-zero';
    document.getElementById('sellMode').value = '';
}

// ══════════════════════════════════════════
//  Save Booking
// ══════════════════════════════════════════
function submitBooking() {
    const bookingDate = document.getElementById('bookingDate').value;
    const owFrom      = document.getElementById('owFrom').value.trim();
    const owTo        = document.getElementById('owTo').value.trim();

    if (!bookingDate) { Swal.fire('Error','Booking date is required','error'); return; }
    if (!owFrom)      { Swal.fire('Error','One Way: From city is required','error'); return; }
    if (!owTo)        { Swal.fire('Error','One Way: To city is required','error'); return; }
    if (owFrom.toLowerCase() === owTo.toLowerCase()) {
        Swal.fire('Error','From and To cities cannot be the same','error'); return;
    }

    const hasReturn = document.getElementById('retToggle').checked;
    const noOfSeats = parseInt(document.getElementById('noOfSeats').value) || 1;
    const buyOn     = document.getElementById('buyToggle').checked;
    const sellOn    = document.getElementById('sellToggle').checked;
    const sellType  = document.querySelector('input[name="sellType"]:checked')?.value || 'customer';

    // Payment mode validation
    if (buyOn && !document.getElementById('buyMode').value) {
        Swal.fire('Error','Please select a Payment Mode for Buy from Agent','error');
        document.getElementById('buyMode').focus(); return;
    }
    if (sellOn) {
        if (sellType === 'customer' && !document.getElementById('custMode').value) {
            Swal.fire('Error','Please select a Payment Mode for Customer','error');
            document.getElementById('custMode').focus(); return;
        }
        if (sellType === 'agent' && !document.getElementById('sellMode').value) {
            Swal.fire('Error','Please select a Payment Mode for Sell to Agent','error');
            document.getElementById('sellMode').focus(); return;
        }
    }

    const params = new URLSearchParams();
    params.set('pnr',         document.getElementById('pnr').value.trim());
    params.set('bookingDate', bookingDate);
    params.set('owDate',      document.getElementById('owDate').value);
    params.set('owTime',      document.getElementById('owTime').value);
    params.set('owFromName',  owFrom);
    params.set('owToName',    owTo);
    params.set('owFlightNo',  document.getElementById('owFlightNo').value.trim());
    params.set('owAirlines',  document.getElementById('owAirlines').value.trim());
    params.set('hasReturn',   hasReturn ? '1' : '0');

    if (hasReturn) {
        params.set('retDate',     document.getElementById('retDate').value);
        params.set('retTime',     document.getElementById('retTime').value);
        params.set('retFromName', document.getElementById('retFrom').value.trim());
        params.set('retToName',   document.getElementById('retTo').value.trim());
        params.set('retFlightNo', document.getElementById('retFlightNo').value.trim());
        params.set('retAirlines', document.getElementById('retAirlines').value.trim());
    }

    params.set('noOfSeats', noOfSeats);
    params.set('phone',     document.getElementById('phone').value.trim());

    // Passengers
    for (let i = 1; i <= noOfSeats; i++) {
        params.set('passenger_' + i, document.getElementById('pax_' + i)?.value.trim() || '');
    }

    // Buy from agent
    if (buyOn) {
        params.set('buyAgentId',    document.getElementById('buyAgent').value);
        params.set('buyAmount',     document.getElementById('buyAmount').value);
        params.set('buyModeId',     document.getElementById('buyMode').value);
        params.set('buyPaidAmount', document.getElementById('buyPaidAmount').value || document.getElementById('buyAmount').value);
    }

    // Sell
    if (sellOn) {
        if (sellType === 'customer') {
            params.set('customerName',   document.getElementById('custName').value.trim());
            params.set('custAmount',     document.getElementById('custAmount').value);
            params.set('custModeId',     document.getElementById('custMode').value);
            params.set('custPaidAmount', document.getElementById('custPaidAmount').value || document.getElementById('custAmount').value);
        } else {
            params.set('sellAgentId',    document.getElementById('sellAgent').value);
            params.set('sellAmount',     document.getElementById('sellAmount').value);
            params.set('sellModeId',     document.getElementById('sellMode').value);
            params.set('sellPaidAmount', document.getElementById('sellPaidAmount').value || document.getElementById('sellAmount').value);
        }
    }

    const btn = document.getElementById('saveBtn');
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Saving...';

    fetch(ctx + '/ticketbooking/save.jsp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: params.toString()
    })
    .then(r => r.text())
    .then(data => {
        const d = data.trim();
        if (d.startsWith('SUCCESS:')) {
            const bookingId = d.split(':')[1];
            btn.innerHTML = '<i class="fa-solid fa-check"></i> Saved #' + bookingId;
            btn.style.background = 'var(--green, #059669)';
            btn.style.borderColor = 'var(--green, #059669)';
            const pb = document.getElementById('printBtn');
            pb.style.display = 'inline-flex';
            pb.onclick = function() { window.open(ctx + '/ticketbooking/ticketPrint.jsp?id=' + bookingId, '_blank'); };
            Swal.fire({
                icon: 'success', title: 'Booking Saved!',
                html: 'Booking ID: <strong>#' + bookingId + '</strong><br><small>Click <b>Print Ticket</b> to print &nbsp;|&nbsp; <b>Clear</b> for new booking</small>',
                confirmButtonText: 'OK', timer: 6000, timerProgressBar: true
            });
        } else {
            const msg = d.startsWith('ERROR:') ? d.substring(6) : d;
            Swal.fire('Error', msg, 'error');
            btn.disabled = false;
            btn.innerHTML = '<i class="fa-solid fa-floppy-disk"></i> Save Booking';
            btn.style.background = '';
            btn.style.borderColor = '';
        }
    })
    .catch(err => {
        Swal.fire('Error', err.message, 'error');
        btn.disabled = false;
        btn.innerHTML = '<i class="fa-solid fa-floppy-disk"></i> Save Booking';
        btn.style.background = '';
        btn.style.borderColor = '';
    });
}

// ══════════════════════════════════════════
//  Init
// ══════════════════════════════════════════
document.addEventListener('DOMContentLoaded', function() {
    renderPassengers();
    toggleBuyBlock(false);
    toggleSellBlock(true);
    setSellType('customer');
});
</script>
</body>
</html>
