
package billing;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import java.text.*;
import billing.ProductItem;
import com.sun.rowset.*; 	
import javax.sql.rowset.*;
import java.util.Date;
import java.util.Map;
import java.util.Set;
import java.util.Vector;

public class billingBean {

    public billingBean() {
    }
    
    public Connection check() throws SQLException
   		{
		return util.DBConnectionManager.getConnectionFromPool();
		}
//////////////////////////----------------------------
public Vector getProductUsingCode(String code) throws Exception
	{
	return getProductUsingCode(code, 3); // Default to Retailer (3)
	}

public Vector getProductUsingCode(String code, int priceCategory) throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con						= util.DBConnectionManager.getConnectionFromPool();
		Vector vec = new Vector();
		
		pt = con.prepareStatement("SELECT  "
								+"	    a.id,a.`name`, "
								+"	    b.`mrp` AS selected_mrp, "
								+"	ROUND(CASE  "
								+"	            WHEN b.`disc_type` = 1 THEN b.`discount` "
								+"	            WHEN b.`disc_type` = 2 THEN (b.`mrp` * b.`discount`) / 100 "
								+"	            ELSE 0 "
								+"	        END, 2 "
								+"	    ) AS discount_amount,b.id,a.unit_id,IFNULL(u.name,'') AS unit_name, IFNULL(b.commission,0) AS commission, IFNULL(u.convertion_unit,'') AS convertion_unit "
								+"	FROM `prod_product` a "
								+"	JOIN `prod_batch` b ON b.`product_id` = a.`id` "
								+"	LEFT JOIN `prod_units` u ON u.id = a.unit_id "
								+"	WHERE a.`code` = ?;");
		pt.setString(1, code);

		rs = pt.executeQuery();
		if(rs.next())
			{
			vec.addElement(rs.getString(1));
			vec.addElement(rs.getString(2));
			vec.addElement(rs.getString(3));
			vec.addElement(rs.getString(4));
			vec.addElement(rs.getString(5));
			vec.addElement(rs.getString(6)); // unit_id
			vec.addElement(rs.getString(7)); // unit_name
			vec.addElement(rs.getString(8)); // commission
			vec.addElement(rs.getString(9)); // convertion_unit

			rs.close();
			}
		return vec;
		}
	finally
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
}
public Vector getProductUsingName(String productName) throws Exception
	{
	return getProductUsingName(productName, 3); // Default to Retailer (3)
	}

public Vector getProductUsingName(String productName, int priceCategory) throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con						= util.DBConnectionManager.getConnectionFromPool();
		Vector vec = new Vector();
		
		pt = con.prepareStatement("SELECT  "
								+"	    a.id,a.`code`, "
								+"	    b.`mrp` AS selected_mrp, "
								+"	ROUND(CASE  "
								+"	            WHEN b.`disc_type` = 1 THEN b.`discount` "
								+"	            WHEN b.`disc_type` = 2 THEN (b.`mrp` * b.`discount`) / 100 "
								+"	            ELSE 0 "
								+"	        END, 2 "
								+"	    ) AS discount_amount,b.id,a.unit_id,IFNULL(u.name,'') AS unit_name, IFNULL(b.commission,0) AS commission, IFNULL(u.convertion_unit,'') AS convertion_unit "
								+"	FROM `prod_product` a "
								+"	JOIN `prod_batch` b ON b.`product_id` = a.`id` "
								+"	LEFT JOIN `prod_units` u ON u.id = a.unit_id "
								+"	WHERE a.name = ?;");
		pt.setString(1, productName);

		rs = pt.executeQuery();
		if(rs.next())
			{
			vec.addElement(rs.getString(1));
			vec.addElement(rs.getString(2));
			vec.addElement(rs.getString(3));
			vec.addElement(rs.getString(4));
			vec.addElement(rs.getString(5));
			vec.addElement(rs.getString(6)); // unit_id
			vec.addElement(rs.getString(7)); // unit_name
			vec.addElement(rs.getString(8)); // commission
			vec.addElement(rs.getString(9)); // convertion_unit

			rs.close();
			}
		return vec;
		}
	finally
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
}
//////////////////////////----------------------------
public Vector getSalesReport(String from,String to,int catId)throws Exception
{
		Connection con 			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;
	try
	  {
	   con						= util.DBConnectionManager.getConnectionFromPool();
		Vector vec = new Vector();
	
	
			pt = con.prepareStatement("SELECT a.bill_display,c.`qty`,c.`price`,c.`disc`,c.`total`,a.date,a.time,b.user_name,a.id,d.`name`,e.`name`,f.`name`,a.paid,a.balance,a.currentBalance,a.cusName  "
									+"	FROM `prod_bill` a "
									+"	JOIN `users` b ON b.id=a.`uid`  "
									+"	join `prod_bill_details` c on c.bill_id=a.id "
									+"	join `prod_product` d on d.id=c.`prod_id` "
									+"	join `prod_category` e on e.id=d.category_id "
									+"	join `prod_brands` f on f.id=d.brand_id "
									+"	WHERE a.is_cancelled=0 AND a.date BETWEEN ? AND ? and e.id=?;");	
	
		pt.setString(1,from);
		pt.setString(2,to);	
		pt.setInt(3,catId);	
		rs = pt.executeQuery();
	while(rs.next())
		{	
		Vector vec1		= new Vector();
		vec1.addElement(rs.getString(1)); 	// 0 bill_display
		vec1.addElement(rs.getString(2));	//1 qty
		vec1.addElement(rs.getString(3));	//2 price
		vec1.addElement(rs.getString(4));	//3 disc
		vec1.addElement(rs.getString(5));	//4 total
		vec1.addElement(rs.getString(6));	//5 date
		vec1.addElement(rs.getString(7));	//6 time
		vec1.addElement(rs.getString(8));	//7 user
		vec1.addElement(rs.getString(9));	//8 billid
		vec1.addElement(rs.getString(10));	//9 iteam
		vec1.addElement(rs.getString(11));	//10 categ
		vec1.addElement(rs.getString(12));	//11 brand
		vec1.addElement(rs.getString(13));	//12 paid
		vec1.addElement(rs.getString(14));	//13 balance
		vec1.addElement(rs.getString(15));	//14 curBalance
		vec1.addElement(rs.getString(16));	//15 cusName
		vec.addElement(vec1);
		}
	return vec;
	 }
 	finally 
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
}
///////////////////////////
public Vector getsalesCashBankReport(String from,String to,int modeId,int typeId,int uid)throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();

        if(modeId == 0 && uid==0){
            pt = con.prepareStatement(
                "SELECT a.bill_display,a.total,a.`prodDisc`+a.`extraDisc` AS discount,a.payable,a.paid,a.date,a.time,b.user_name, " +
                "a.id,CASE WHEN a.paymentMode = 3 THEN CONCAT('CASH & ', MAX(d.type)) ELSE MAX(d.type) END AS TYPE,SUM(c.cash) as cash,SUM(c.bank) as bank,a.balance,a.currentBalance,a.cusName,a.cusPhn  " +
                "FROM `prod_bill` a " +
                "JOIN `users` b ON b.id=a.`uid` " +
                "JOIN `prod_bill_payment` c ON c.bill_id=a.id " +
                "JOIN `prod_bill_payment_type` d ON d.id=c.paymentType " +
                "WHERE a.is_cancelled=0 AND a.date BETWEEN ? AND ?  GROUP BY a.id,a.bill_display,a.total,a.payable,a.paid,a.date,a.time,b.user_name,a.balance,a.currentBalance,a.cusName,a.paymentMode"
            );
            pt.setString(1, from);
            pt.setString(2, to);
            
        }
        else if(modeId == 0 && uid!=0){
            pt = con.prepareStatement(
                "SELECT a.bill_display,a.total,a.`prodDisc`+a.`extraDisc` AS discount,a.payable,a.paid,a.date,a.time,b.user_name, " +
                "a.id,CASE WHEN a.paymentMode = 3 THEN CONCAT('CASH & ', MAX(d.type)) ELSE MAX(d.type) END AS TYPE,SUM(c.cash) as cash,SUM(c.bank) as bank,a.balance,a.currentBalance,a.cusName,a.cusPhn " +
                "FROM `prod_bill` a " +
                "JOIN `users` b ON b.id=a.`uid` " +
                "JOIN `prod_bill_payment` c ON c.bill_id=a.id " +
                "JOIN `prod_bill_payment_type` d ON d.id=c.paymentType " +
                "WHERE a.is_cancelled=0 AND a.date BETWEEN ? AND ? AND a.uid=? GROUP BY a.id,a.bill_display,a.total,a.payable,a.paid,a.date,a.time,b.user_name,a.balance,a.currentBalance,a.cusName,a.paymentMode"
            );
            pt.setString(1, from);
            pt.setString(2, to);
            pt.setInt(3, uid);
        }
        else if(modeId == 1 && uid==0){
            pt = con.prepareStatement(
                "SELECT a.bill_display,a.total,a.`prodDisc`+a.`extraDisc` AS discount,a.payable,a.paid,a.date,a.time,b.user_name, " +
                "a.id,CASE WHEN a.paymentMode = 3 THEN CONCAT('CASH & ', MAX(d.type)) ELSE MAX(d.type) END AS TYPE,SUM(c.cash) as cash,SUM(c.bank) as bank,a.balance,a.currentBalance,a.cusName,a.cusPhn " +
                "FROM `prod_bill` a " +
                "JOIN `users` b ON b.id=a.`uid` " +
                "JOIN `prod_bill_payment` c ON c.bill_id=a.id " +
                "JOIN `prod_bill_payment_type` d ON d.id=c.paymentType " +
                "WHERE a.is_cancelled=0 AND a.date BETWEEN ? AND ? AND a.paymentMode IN(1,3)  GROUP BY a.id,a.bill_display,a.total,a.payable,a.paid,a.date,a.time,b.user_name,a.balance,a.currentBalance,a.cusName,a.paymentMode"
            );
            pt.setString(1, from);
            pt.setString(2, to);
            
        }else if(modeId == 1 && uid!=0){
            pt = con.prepareStatement(
                "SELECT a.bill_display,a.total,a.`prodDisc`+a.`extraDisc` AS discount,a.payable,a.paid,a.date,a.time,b.user_name, " +
                "a.id,CASE WHEN a.paymentMode = 3 THEN CONCAT('CASH & ', MAX(d.type)) ELSE MAX(d.type) END AS TYPE,SUM(c.cash) as cash,SUM(c.bank) as bank,a.balance,a.currentBalance,a.cusName,a.cusPhn " +
                "FROM `prod_bill` a " +
                "JOIN `users` b ON b.id=a.`uid` " +
                "JOIN `prod_bill_payment` c ON c.bill_id=a.id " +
                "JOIN `prod_bill_payment_type` d ON d.id=c.paymentType " +
                "WHERE a.is_cancelled=0 AND a.date BETWEEN ? AND ? AND a.paymentMode IN(1,3) AND a.uid=? GROUP BY a.id,a.bill_display,a.total,a.payable,a.paid,a.date,a.time,b.user_name,a.balance,a.currentBalance,a.cusName,a.paymentMode"
            );
            pt.setString(1, from);
            pt.setString(2, to);
            pt.setInt(3, uid);
        } else if(modeId == 2 && typeId==0 && uid==0) {
            pt = con.prepareStatement(
                "SELECT a.bill_display,a.total,a.`prodDisc`+a.`extraDisc` AS discount,a.payable,a.paid,a.date,a.time,b.user_name, " +
                "a.id,CASE WHEN a.paymentMode = 3 THEN CONCAT('CASH & ', MAX(d.type)) ELSE MAX(d.type) END AS TYPE ,SUM(c.cash) as cash,SUM(c.bank) as bank,a.balance,a.currentBalance,a.cusName,a.cusPhn " +
                "FROM `prod_bill` a " +
                "JOIN `users` b ON b.id=a.`uid` " +
                "JOIN `prod_bill_payment` c ON c.bill_id=a.id " +
                "JOIN `prod_bill_payment_type` d ON d.id=c.paymentType " +
                "WHERE a.is_cancelled=0 AND a.date BETWEEN ? AND ? AND a.paymentMode IN(2,3) GROUP BY a.id,a.bill_display,a.total,a.payable,a.paid,a.date,a.time,b.user_name,a.balance,a.currentBalance,a.cusName,a.paymentMode"
            );
            pt.setString(1, from);
            pt.setString(2, to);
            
            
           
        }
        else if(modeId == 2 && typeId==0 && uid!=0) {
            pt = con.prepareStatement(
                "SELECT a.bill_display,a.total,a.`prodDisc`+a.`extraDisc` AS discount,a.payable,a.paid,a.date,a.time,b.user_name, " +
                "a.id,CASE WHEN a.paymentMode = 3 THEN CONCAT('CASH & ', MAX(d.type)) ELSE MAX(d.type) END AS TYPE ,SUM(c.cash) as cash,SUM(c.bank) as bank,a.balance,a.currentBalance,a.cusName,a.cusPhn " +
                "FROM `prod_bill` a " +
                "JOIN `users` b ON b.id=a.`uid` " +
                "JOIN `prod_bill_payment` c ON c.bill_id=a.id " +
                "JOIN `prod_bill_payment_type` d ON d.id=c.paymentType " +
                "WHERE a.is_cancelled=0 AND a.date BETWEEN ? AND ? AND a.paymentMode IN(2,3) AND a.uid=? GROUP BY a.id,a.bill_display,a.total,a.payable,a.paid,a.date,a.time,b.user_name,a.balance,a.currentBalance,a.cusName,a.paymentMode"
            );
            pt.setString(1, from);
            pt.setString(2, to);
            pt.setInt(3, uid);
            
           
        }
        else if(modeId == 2 && typeId!=0 && uid==0) {
            pt = con.prepareStatement(
                "SELECT a.bill_display,a.total,a.`prodDisc`+a.`extraDisc` AS discount,a.payable,a.paid,a.date,a.time,b.user_name, " +
                "a.id,CASE WHEN a.paymentMode = 3 THEN CONCAT('CASH & ', MAX(d.type)) ELSE MAX(d.type) END AS TYPE ,SUM(c.cash) as cash,SUM(c.bank) as bank,a.balance,a.currentBalance,a.cusName,a.cusPhn " +
                "FROM `prod_bill` a " +
                "JOIN `users` b ON b.id=a.`uid` " +
                "JOIN `prod_bill_payment` c ON c.bill_id=a.id " +
                "JOIN `prod_bill_payment_type` d ON d.id=c.paymentType " +
                "WHERE a.is_cancelled=0 AND a.date BETWEEN ? AND ? AND a.paymentMode IN(2,3) AND c.paymentType=?  GROUP BY a.id,a.bill_display,a.total,a.payable,a.paid,a.date,a.time,b.user_name,a.balance,a.currentBalance,a.cusName,a.paymentMode"
            );
            pt.setString(1, from);
            pt.setString(2, to);
            pt.setInt(3, typeId);
            
           
        }
        else if(modeId == 2 && typeId!=0 && uid!=0) {
            pt = con.prepareStatement(
                "SELECT a.bill_display,a.total,a.`prodDisc`+a.`extraDisc` AS discount,a.payable,a.paid,a.date,a.time,b.user_name, " +
                "a.id,CASE WHEN a.paymentMode = 3 THEN CONCAT('CASH & ', MAX(d.type)) ELSE MAX(d.type) END AS TYPE ,SUM(c.cash) as cash,SUM(c.bank) as bank,a.balance,a.currentBalance,a.cusName,a.cusPhn " +
                "FROM `prod_bill` a " +
                "JOIN `users` b ON b.id=a.`uid` " +
                "JOIN `prod_bill_payment` c ON c.bill_id=a.id " +
                "JOIN `prod_bill_payment_type` d ON d.id=c.paymentType " +
                "WHERE a.is_cancelled=0 AND a.date BETWEEN ? AND ? AND a.paymentMode IN(2,3) AND c.paymentType=? AND a.uid=? GROUP BY a.id,a.bill_display,a.total,a.payable,a.paid,a.date,a.time,b.user_name,a.balance,a.currentBalance,a.cusName,a.paymentMode"
            );
            pt.setString(1, from);
            pt.setString(2, to);
            pt.setInt(3, typeId);
            pt.setInt(4, uid);
           
        }

        rs = pt.executeQuery();
        while(rs.next()) {
            Vector vec1 = new Vector();
            vec1.addElement(rs.getString(1)); // bill_display
            vec1.addElement(rs.getString(2)); // total
            vec1.addElement(rs.getString(3)); // discount
            vec1.addElement(rs.getString(4)); // payable
            vec1.addElement(rs.getString(5)); // paid
            vec1.addElement(rs.getString(6)); // date
            vec1.addElement(rs.getString(7)); // time
            vec1.addElement(rs.getString(8)); // user_name
            vec1.addElement(rs.getString(9)); // id
            vec1.addElement(rs.getString(10)); // type
            vec1.addElement(rs.getString(11)); // cash
            vec1.addElement(rs.getString(12)); // bank
            vec1.addElement(rs.getString(13)); // Balance
            vec1.addElement(rs.getString(14)); // curBalance
            vec1.addElement(rs.getString(15)); // cus Name
            vec1.addElement(rs.getString(16)); // Cus Number
            vec.addElement(vec1);
        }
        return vec;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pt != null) try { pt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}


//////////////////////////
public Vector getSalesReportChart()throws Exception
{
		Connection con 			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;
	try
	  {
	   con						= util.DBConnectionManager.getConnectionFromPool();
		Vector vec = new Vector();
	
	
			pt = con.prepareStatement("SELECT "
									+"	    DATE_FORMAT(`date`, '%d-%m-%Y') AS bill_date, "
									+"	    SUM(payable) AS total_payable "
									+"	FROM prod_bill "
									+"	WHERE DATE >= CURDATE() - INTERVAL 5 DAY "
									+"	GROUP BY DATE(DATE) "
									+"	ORDER BY bill_date DESC;");	
	

		rs = pt.executeQuery();
	while(rs.next())
		{	
		Vector vec1		= new Vector();
		vec1.addElement(rs.getString(1));
		vec1.addElement(rs.getString(2));

		vec.addElement(vec1);
		}
	return vec;
	 }
 	finally 
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
}
////////////////////////
public int saveBill(String customerName, double finalDiscount, double payableAmount, double grandTotal,int uid,double priceTotal,double discountTotal) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    int billId = 0;

    try {

        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(true); // IMPORTANT

        java.util.Calendar cal = java.util.Calendar.getInstance();
		int year = cal.get(java.util.Calendar.YEAR) % 100;  // Last 2 digits of the year


        String getLastIdSQL = "SELECT MAX(id) AS maxId FROM prod_bill WHERE YEAR(DATE) = YEAR(CURDATE())";
        ps = con.prepareStatement(getLastIdSQL);
        rs = ps.executeQuery();

        int nextId = 1; // Default if no record
        if (rs.next() && rs.getInt("maxId") != 0) {
            nextId = rs.getInt("maxId") + 1;
        }


        String billNo = year + "-" + nextId;

        // Close previous resources to reuse statement
        rs.close();
        ps.close();


        String sql = "INSERT INTO prod_bill (bill_display, total, extraDisc, payable, paid, uid, DATE, TIME, cusName,prodDisc) " +
                     "VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW(), ?,?)";
        ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
        ps.setString(1, billNo);
        ps.setDouble(2, priceTotal);
        ps.setDouble(3, finalDiscount);
        ps.setDouble(4, payableAmount);
        ps.setDouble(5, payableAmount);
        ps.setInt(6, uid);
        ps.setString(7, customerName);
        ps.setDouble(8, discountTotal);

        ps.executeUpdate();
        rs = ps.getGeneratedKeys();
        if (rs.next()) {
            billId = rs.getInt(1);
        }

    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (con != null) con.close();
    }

    return billId;
}
/////////////////////////





public String saveBillItems(List<ProductItem> items,
                         String customerName, double finalDiscount,
                         double payableAmount, double grandTotal,
                         int uid, double priceTotal, double discountTotal,String customerPhn
                         	,double totalPaid,double cashPaid,double bankPaid,int mode,int type,double balance,int customerId) throws Exception {
    return saveBillItems(items, customerName, finalDiscount, payableAmount, grandTotal, uid, priceTotal, discountTotal, customerPhn, totalPaid, cashPaid, bankPaid, mode, type, balance, customerId, 3, 0, 1); // Default to Retailer, no attender, tax bill ON
}

public String saveBillItems(List<ProductItem> items,
                         String customerName, double finalDiscount,
                         double payableAmount, double grandTotal,
                         int uid, double priceTotal, double discountTotal,String customerPhn
                         	,double totalPaid,double cashPaid,double bankPaid,int mode,int type,double balance,int customerId,int priceCategory) throws Exception {
    return saveBillItems(items, customerName, finalDiscount, payableAmount, grandTotal, uid, priceTotal, discountTotal, customerPhn, totalPaid, cashPaid, bankPaid, mode, type, balance, customerId, priceCategory, 0, 1); // No attender, tax bill ON
}

public String saveBillItems(List<ProductItem> items,
                         String customerName, double finalDiscount,
                         double payableAmount, double grandTotal,
                         int uid, double priceTotal, double discountTotal,String customerPhn
                         	,double totalPaid,double cashPaid,double bankPaid,int mode,int type,double balance,int customerId,int priceCategory,int attenderId) throws Exception {
    return saveBillItems(items, customerName, finalDiscount, payableAmount, grandTotal, uid, priceTotal, discountTotal, customerPhn, totalPaid, cashPaid, bankPaid, mode, type, balance, customerId, priceCategory, attenderId, 1); // Tax bill ON
}

public String saveBillItems(List<ProductItem> items,
                         String customerName, double finalDiscount,
                         double payableAmount, double grandTotal,
                         int uid, double priceTotal, double discountTotal,String customerPhn
                         	,double totalPaid,double cashPaid,double bankPaid,int mode,int type,double balance,int customerId,int priceCategory,int attenderId,int isTaxBill) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    int billId = 0;
    String billNo = null;
    

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false); // Start transaction

        // Generate bill number based on tax bill type
        // Tax bills (is_tax_bill=1): 26-52, 26-53, etc. (with year prefix)
        // Non-tax bills (is_tax_bill=0): 1, 2, 3, etc. (without year, separate counter)
        String getLastIdSQL = "SELECT COUNT(id) AS billCount FROM prod_bill " +
                              "WHERE YEAR(DATE) = YEAR(CURDATE()) AND is_tax_bill = ?";
        ps = con.prepareStatement(getLastIdSQL);
        ps.setInt(1, isTaxBill);
        rs = ps.executeQuery();

        int nextId = 1;
        if (rs.next()) {
            nextId = rs.getInt("billCount") + 1;
        }

        // Format bill number based on type
        if (isTaxBill == 1) {
            // Tax bill with year prefix
            java.util.Calendar cal = java.util.Calendar.getInstance();
            int year = cal.get(java.util.Calendar.YEAR) % 100;
            billNo = year + "-" + nextId;
        } else {
            // Non-tax bill without year
            billNo = String.valueOf(nextId);
        }
        
        rs.close();
        ps.close();

        
        String sql = "INSERT INTO prod_bill (bill_display, total, extraDisc, payable, paid, uid, DATE, TIME, cusName, prodDisc, cusPhn, paymentMode, paymentType, balance, is_balance,currentBalance,customerId,price_category,attender_id,is_tax_bill) " +
             "VALUES (?, ?, ?, ?, ?, ?, NOW(), NOW(), ?, ?, ?, ?, ?, ?, ?,?,?,?,?,?)";

ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);

ps.setString(1, billNo);
ps.setDouble(2, priceTotal);
ps.setDouble(3, finalDiscount);
ps.setDouble(4, payableAmount);
ps.setDouble(5, totalPaid);
ps.setInt(6, uid);
ps.setString(7, customerName);
ps.setDouble(8, discountTotal);
ps.setString(9, customerPhn);
ps.setInt(10, mode);
ps.setInt(11, type);
ps.setDouble(12, balance);

ps.setInt(13, balance > 0 ? 1 : 0);
ps.setDouble(14, balance);
if (customerId > 0) {
    ps.setInt(15, customerId);
} else {
    ps.setNull(15, java.sql.Types.INTEGER);
}
ps.setInt(16, priceCategory);
if (attenderId > 0) {
    ps.setInt(17, attenderId);
} else {
    ps.setNull(17, java.sql.Types.INTEGER);
}
ps.setInt(18, isTaxBill);

ps.executeUpdate();


        rs = ps.getGeneratedKeys();
        if (rs.next()) {
            billId = rs.getInt(1);
        }
        rs.close();
        ps.close();

        // Insert multiple products into prod_bill_details
        String sqlDetail = "INSERT INTO prod_bill_details (bill_id, prod_id, qty, price, disc, total, gst, cost, commission) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        ps = con.prepareStatement(sqlDetail);

        for (ProductItem item : items) {
            ps.setInt(1, billId);
            ps.setInt(2, item.productId);
            ps.setBigDecimal(3, item.qty);
            ps.setDouble(4, item.price);
            ps.setDouble(5, item.discount);
            ps.setDouble(6, item.total);
            ps.setInt(7, item.gst);
            ps.setDouble(8, item.cost);
            ps.setDouble(9, item.commission);
            ps.addBatch();
        }

        ps.executeBatch(); // Efficient batch insert
        ps.close();
        
        String sqlPayment = "INSERT INTO prod_bill_payment (bill_id, cash, bank, paymentType) VALUES (?, ?, ?, ?)";
        ps = con.prepareStatement(sqlPayment);
        ps.setInt(1, billId);
        ps.setDouble(2, cashPaid);
        ps.setDouble(3, bankPaid);
        ps.setInt(4, type); // UPI, Card, etc.
        ps.executeUpdate();
        ps.close();

        con.commit(); // Commit all inserts

    } catch (Exception e) {
        if (con != null) con.rollback(); // Rollback if error
        throw e;
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (con != null) con.close();
    }

    return billNo; // return for reference
    
}



/*public void saveBillItem(int billId, int productId, int qty, double price, double discount, double total) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(true);

        String sql = "INSERT INTO `prod_bill_details` (bill_id, prod_id, qty, price, disc, total) VALUES (?, ?, ?, ?, ?, ?)";
        ps = con.prepareStatement(sql);
        ps.setInt(1, billId);
        ps.setInt(2, productId);
        ps.setInt(3, qty);
        ps.setDouble(4, price);
        ps.setDouble(5, discount);
        ps.setDouble(6, total);

        ps.executeUpdate();
    } finally {
        if (ps != null) ps.close();
        if (con != null) con.close();
    }
}
*/
////////////////////////

/*public void updateStock(int productId, int qty,int uid,int batchId) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false); // transaction

        pt = con.prepareStatement("UPDATE prod_batch SET stock = stock - ? WHERE product_id = ?");
        pt.setInt(1, qty);
        pt.setInt(2, productId);
        pt.executeUpdate();
        pt.close();

        int lastStockNow = 0;
        pt = con.prepareStatement(
            "SELECT stock_now FROM prod_lifecycle WHERE product_id = ? ORDER BY id DESC LIMIT 1"
        );
        pt.setInt(1, productId);
        rs = pt.executeQuery();
        if (rs.next()) {
            lastStockNow = rs.getInt("stock_now");
        }
        rs.close();
        pt.close();

        int newStockNow = lastStockNow - qty; // increasing lifecycle stock
        pt = con.prepareStatement(
            "INSERT INTO prod_lifecycle (batch_id, stock_out, stock_now, notes,DATE,TIME,product_id,uid) VALUES (?, ?, ?,'WHILE BILLING', NOW(), NOW(),?,?)");
        pt.setInt(1, batchId);
        pt.setInt(2, qty);
        pt.setInt(3, newStockNow);          
        pt.setInt(4, productId);  
        pt.setInt(5, uid); 
        pt.executeUpdate();

        con.commit();
    } catch (Exception e) {
        if (con != null) con.rollback();
        throw e;
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignored) {}
        if (pt != null) try { pt.close(); } catch (Exception ignored) {}
        if (con != null) try { con.close(); } catch (Exception ignored) {}
    }
}*/
public void updateStock(int productId, BigDecimal qty, int uid, int batchId,int billId) throws Exception {
    updateStock(productId, qty, uid, batchId, billId, false);
}

public void updateStock(int productId, BigDecimal qty, int uid, int batchId, int billId, boolean userHasStockPermission) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false); // Begin transaction

        // STEP 1: Get current stock from prod_batch
        BigDecimal currentStock = BigDecimal.ZERO;
        pt = con.prepareStatement("SELECT stock FROM prod_batch WHERE product_id = ? AND id = ?");
        pt.setInt(1, productId);
        pt.setInt(2, batchId);
        rs = pt.executeQuery();
        if (rs.next()) {
            currentStock = rs.getBigDecimal("stock");
        }
        rs.close();
        pt.close();

        // STEP 2: Get last stock_now from prod_lifecycle
        BigDecimal lastStockNow = BigDecimal.ZERO;
        pt = con.prepareStatement(
            "SELECT stock_now FROM prod_lifecycle WHERE product_id = ? ORDER BY id DESC LIMIT 1"
        );
        pt.setInt(1, productId);
        rs = pt.executeQuery();
        if (rs.next()) {
            lastStockNow = rs.getBigDecimal("stock_now");
        }
        rs.close();
        pt.close();

        // STEP 3: Check if enough stock is available
        if (currentStock.compareTo(qty) >= 0) {
            // Reduce stock in prod_batch
            pt = con.prepareStatement("UPDATE prod_batch SET stock = stock - ? WHERE product_id = ? AND id = ?");
            pt.setBigDecimal(1, qty);
            pt.setInt(2, productId);
            pt.setInt(3, batchId);
            pt.executeUpdate();
            pt.close();

            // Insert into prod_lifecycle
            BigDecimal newStockNow = lastStockNow.subtract(qty);
            pt = con.prepareStatement(
                "INSERT INTO prod_lifecycle (batch_id, stock_out, stock_now, notes, DATE, TIME, product_id, uid,bill_id) VALUES (?, ?, ?, 'WHILE BILLING', NOW(), NOW(), ?, ?,?)"
            );
            pt.setInt(1, batchId);
            pt.setBigDecimal(2, qty);
            pt.setBigDecimal(3, newStockNow);
            pt.setInt(4, productId);
            pt.setInt(5, uid);
            pt.setInt(6, billId);
            pt.executeUpdate();
            pt.close();

        } else {
            
            pt = con.prepareStatement(
                "INSERT INTO prod_batch_zero_stock_bill (batch_id, qty, date, time, product_id, uid) VALUES (?, ?, NOW(), NOW(), ?, ?)"
            );
            pt.setInt(1, batchId);
            pt.setBigDecimal(2, qty);
            pt.setInt(3, productId);
            pt.setInt(4, uid);
            pt.executeUpdate();
            pt.close();

            
            pt = con.prepareStatement(
                "INSERT INTO prod_lifecycle (batch_id, stock_out, stock_now, notes, DATE, TIME, product_id, uid,is_zero_stock_bill,bill_id) VALUES (?, ?, ?, ' BILL WITHOUT STOCK', NOW(), NOW(), ?, ?,1,?)"
            );
            pt.setInt(1, batchId);
            pt.setBigDecimal(2, qty);
            pt.setBigDecimal(3, lastStockNow); // not subtracted
            pt.setInt(4, productId);
            pt.setInt(5, uid);
            pt.setInt(6, billId);
            pt.executeUpdate();
            pt.close();
        }

        con.commit(); // Commit if everything is OK
    } catch (Exception e) {
        if (con != null) con.rollback(); // Rollback on error
        throw e;
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignored) {}
        if (pt != null) try { pt.close(); } catch (Exception ignored) {}
        if (con != null) try { con.close(); } catch (Exception ignored) {}
    }
}

public Vector getStockAdj(String from, String to, int productId) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT b.name,a.`stock_in`,a.`stock_out`,a.`stock_now`,a.`notes`,")
           .append("CONCAT(DATE_FORMAT(a.date, '%d-%m-%Y'),'/',a.time) AS DATETIME,")
           .append("c.user_name,a.stockAdjType,IFNULL(u.name,'') AS unit_name,IFNULL(u.convertion_unit,'') AS convertion_unit ")
           .append("FROM prod_lifecycle a ")
           .append("JOIN prod_product b ON a.`product_id`=b.`id` ")
           .append("JOIN users c ON c.id=a.uid ")
           .append("LEFT JOIN prod_units u ON u.id=b.unit_id ")
           .append("WHERE a.date BETWEEN ? AND ? ");

        if (productId != 0) {
            sql.append("AND a.product_id = ? ");
        }

        sql.append("ORDER BY a.id");

        pt = con.prepareStatement(sql.toString());
        pt.setString(1, from);
        pt.setString(2, to);

        if (productId != 0) {
            pt.setInt(3, productId);
        }

        rs = pt.executeQuery();
        while (rs.next()) {
            Vector vec1 = new Vector();
            vec1.addElement(rs.getString(1));
            vec1.addElement(rs.getString(2));
            vec1.addElement(rs.getString(3));
            vec1.addElement(rs.getString(4));
            vec1.addElement(rs.getString(5));
            vec1.addElement(rs.getString(6));
            vec1.addElement(rs.getString(7));
            vec1.addElement(rs.getString(8));
            vec1.addElement(rs.getString(9)); // unit_name
            vec1.addElement(rs.getString(10)); // convertion_unit
            vec.addElement(vec1);
        }
        return vec;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pt != null) try { pt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public Vector getBillDetails(int billId) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String sql = "SELECT bd.id, bd.bill_id, bd.prod_id, p.name AS product_name, " +
                     "bd.qty, bd.price, bd.disc, bd.total " +
                     "FROM prod_bill_details bd " +
                     "JOIN prod_product p ON bd.prod_id = p.id " +
                     "WHERE bd.bill_id = ?";
        
        ps = con.prepareStatement(sql);
        ps.setInt(1, billId);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt("id"));           // 0
            row.addElement(rs.getInt("bill_id"));      // 1
            row.addElement(rs.getInt("prod_id"));      // 2
            row.addElement(rs.getString("product_name")); // 3
            row.addElement(rs.getBigDecimal("qty"));          // 4
            row.addElement(rs.getDouble("price"));     // 5
            row.addElement(rs.getDouble("disc"));      // 6
            row.addElement(rs.getDouble("total"));     // 7
            vec.add(row);
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    return vec;
}
public Vector getExtraDisc(int billId) throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con					= util.DBConnectionManager.getConnectionFromPool();

		
		Vector vec1	= new Vector();
		pt = con.prepareStatement("SELECT a.total,a.prodDisc,a.extraDisc,a.payable,a.paid,b.`cash`,b.`bank`,a.balance,a.currentBalance,a.date,a.bill_display FROM `prod_bill` a,`prod_bill_payment` b WHERE a.id=b.bill_id AND a.id=?;");
		pt.setInt(1,billId);
		rs = pt.executeQuery();
		if (rs.next()) {
		    vec1.addElement(rs.getDouble(1));
		    vec1.addElement(rs.getDouble(2));
		    vec1.addElement(rs.getDouble(3));
		    vec1.addElement(rs.getDouble(4));
		    vec1.addElement(rs.getDouble(5));
		    vec1.addElement(rs.getDouble(6));
		    vec1.addElement(rs.getDouble(7));
		    vec1.addElement(rs.getDouble(8));
		    vec1.addElement(rs.getDouble(9));
		    vec1.addElement(rs.getString(10)); // date
		    vec1.addElement(rs.getString(11)); // bill_display
		}
		return vec1;
		}
	finally
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}

		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}

		if(con!= null)
			{
			try{con.close();}catch(Exception e){}
			con = null;
			}
		}
	}
public Vector getBillDetailsUsingNo(String bill) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String sql = "SELECT c.`name`,b.`qty`,b.`price`,b.`disc`,b.`total`,b.gst,d.name AS category_name,c.hsn,IFNULL(u.name,'') AS unit_name,IFNULL(u.convertion_unit,'') AS convertion_unit FROM `prod_bill` a "
					+"	JOIN `prod_bill_details` b ON b.`bill_id`=a.`id` "
					+"	JOIN `prod_product` c ON c.id=b.`prod_id` "
					+"	LEFT JOIN `prod_category` d ON d.id=c.category_id "
					+"	LEFT JOIN `prod_units` u ON u.id=c.unit_id "
					+"	WHERE a.`bill_display`=?;";
        
        ps = con.prepareStatement(sql);
        ps.setString(1, bill);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString(1));           	
            row.addElement(rs.getString(2));      	
            row.addElement(rs.getString(3));     	
            row.addElement(rs.getString(4)); 
            row.addElement(rs.getString(5));	
            row.addElement(rs.getString(6));
            row.addElement(rs.getString(7)); // category_name
            row.addElement(rs.getString(8)); // hsn
            row.addElement(rs.getString(9)); // unit_name
            row.addElement(rs.getString(10)); // convertion_unit
           
            vec.add(row);
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    return vec;
}
public double getExtraDisc(String bill)throws Exception
{
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;


		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  double disc  = 0;

		      pt = con.prepareStatement("SELECT extraDisc FROM `prod_bill` WHERE bill_display=?;");
		      pt.setString(1,bill);
		      rs = pt.executeQuery();
		      if(rs.next())
		      	disc  = rs.getInt(1);

		      return disc;
			}
		finally
			{
				if (rs != null)
					{
					try	 { rs.close(); } catch (SQLException e) { ; }
					rs = null;
					}
				if (pt != null)
					{
					try	 { pt.close(); } catch (SQLException e) { ; }
					pt = null;
					}
				if(con!= null)
					{
					try{con.close();}catch(Exception e){}
					con = null;
					}
			}
}
  public double getSalesByCategory(int categoryId, String fromDate, String toDate)throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con					= util.DBConnectionManager.getConnectionFromPool();
		
		double totalSales	= 0;
		
		pt = con.prepareStatement("select sum(c.qty*c.price) "
					+"		FROM `prod_bill` a   "
					+"		JOIN `prod_bill_details` c ON c.bill_id=a.id "
					+"		JOIN `prod_product` d ON d.id=c.`prod_id` "
					+"		JOIN `prod_category` e ON e.id=d.category_id "
					+"		WHERE a.is_cancelled=0 AND a.date BETWEEN ? AND ? AND e.id=?;");
		pt.setString(1, fromDate);
		pt.setString(2, toDate);
		pt.setInt(3,categoryId);
		rs = pt.executeQuery();
		if(rs.next())
			totalSales	= rs.getDouble(1);
		
		return totalSales;
		}
	finally
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
	}
	public double getSalesCashTotal( String fromDate, String toDate)throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con					= util.DBConnectionManager.getConnectionFromPool();
		
		double totalSales	= 0;
		
		pt = con.prepareStatement("SELECT SUM(b.cash) "
								+"	FROM `prod_bill` a   "
								+"	JOIN`prod_bill_payment` b ON b.bill_id=a.id "
								+"	WHERE a.is_cancelled=0 AND a.date BETWEEN ?  AND ? ");
		pt.setString(1, fromDate);
		pt.setString(2, toDate);
		
		rs = pt.executeQuery();
		if(rs.next())
			totalSales	= rs.getDouble(1);
		
		return totalSales;
		}
	finally
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
	}
	public double getSalesBankTotal( String fromDate, String toDate)throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con					= util.DBConnectionManager.getConnectionFromPool();
		
		double totalSales	= 0;
		
		pt = con.prepareStatement("SELECT SUM(b.bank) "
								+"	FROM `prod_bill` a   "
								+"	JOIN`prod_bill_payment` b ON b.bill_id=a.id "
								+"	WHERE a.is_cancelled=0 AND a.date BETWEEN ?  AND ?");
		pt.setString(1, fromDate);
		pt.setString(2, toDate);
		
		rs = pt.executeQuery();
		if(rs.next())
			totalSales	= rs.getDouble(1);
		
		return totalSales;
		}
	finally
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
	}
	public double getSalesBalanceTotal( String fromDate, String toDate)throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con					= util.DBConnectionManager.getConnectionFromPool();
		
		double totalSales	= 0;
		
		pt = con.prepareStatement("SELECT SUM(a.balance) "
								+"	FROM `prod_bill` a   "
								+"	JOIN`prod_bill_payment` b ON b.bill_id=a.id "
								+"	WHERE a.is_cancelled=0 AND a.date BETWEEN ?  AND ?");
		pt.setString(1, fromDate);
		pt.setString(2, toDate);
		
		rs = pt.executeQuery();
		if(rs.next())
			totalSales	= rs.getDouble(1);
		
		return totalSales;
		}
	finally
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
	}
public Vector getBillsForPrint()throws Exception
{
		Connection con 			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;
	try
	  {
	   con						= util.DBConnectionManager.getConnectionFromPool();
		Vector vec = new Vector();
	
	
			pt = con.prepareStatement("SELECT id,bill_display,total,paid,DATE,TIME,cusName  FROM `prod_bill` WHERE is_cancelled=0 ORDER BY id DESC LIMIT 50;");	
	

		rs = pt.executeQuery();
	while(rs.next())
		{	
		Vector vec1		= new Vector();
		vec1.addElement(rs.getString(1));
		vec1.addElement(rs.getString(2));
		vec1.addElement(rs.getString(3));
		vec1.addElement(rs.getString(4));
		vec1.addElement(rs.getString(5));
		vec1.addElement(rs.getString(6));
		vec1.addElement(rs.getString(7));

		vec.addElement(vec1);
		}
	return vec;
	 }
 	finally 
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
}
public Vector getDueBills()throws Exception
{
		Connection con 			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;
	try
	  {
	   con						= util.DBConnectionManager.getConnectionFromPool();
		Vector vec = new Vector();
	
	
			pt = con.prepareStatement("SELECT a.cusName,a.cusPhn,a.payable,a.paid,a.balance,a.date,a.time,b.user_name,a.bill_display,a.id,a.currentBalance FROM `prod_bill` a,users b WHERE a.`uid`=b.id AND a.currentBalance>0 AND a.is_cancelled=0;");	
	

		rs = pt.executeQuery();
	while(rs.next())
		{	
		Vector vec1		= new Vector();
		vec1.addElement(rs.getString(1));
		vec1.addElement(rs.getString(2));
		vec1.addElement(rs.getString(3));
		vec1.addElement(rs.getString(4));
		vec1.addElement(rs.getString(5));
		vec1.addElement(rs.getString(6));
		vec1.addElement(rs.getString(7));
		vec1.addElement(rs.getString(8));
		vec1.addElement(rs.getString(9));
		vec1.addElement(rs.getString(10));
		vec1.addElement(rs.getString(11));
		vec.addElement(vec1);
		}
	return vec;
	 }
 	finally 
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
}
public Vector getBillAmount(int id) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector row = new Vector();

    try {
        con = util.DBConnectionManager.getConnectionFromPool();

        String sql =
            "SELECT a.payable, a.paid, a.currentBalance " +
            "FROM prod_bill a WHERE id = ?";

        ps = con.prepareStatement(sql);
        ps.setInt(1, id);
        rs = ps.executeQuery();

        if (rs.next()) {            // only one record expected
            row.addElement(rs.getString(1));
            row.addElement(rs.getString(2));
            row.addElement(rs.getString(3));
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignore) {}
        if (ps != null) try { ps.close(); } catch (Exception ignore) {}
        if (con != null) try { con.close(); } catch (Exception ignore) {}
    }

    return row;
}
public void saveDuePayment(int billId,
                           double payNow,
                           int mode,
                           int bankOption,
                           int uid) throws Exception {
    Connection con = null;
    PreparedStatement insertPS = null;
    PreparedStatement updatePS = null;
    PreparedStatement selectPS = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);  // transaction

        String selectSql = "SELECT paid, currentBalance FROM prod_bill WHERE id = ?";
        selectPS = con.prepareStatement(selectSql);
        selectPS.setInt(1, billId);
        rs = selectPS.executeQuery();

        double currentPaid = 0;
        double currentBalances = 0;
        if (rs.next()) {
            currentPaid = rs.getDouble("paid");
            currentBalances = rs.getDouble("currentBalance");
        } else {
            throw new Exception("Bill not found: " + billId);
        }

        double newPaid = currentPaid + payNow;
        double newBalance = currentBalances - payNow;
        if (newBalance < 0) newBalance = 0;

        String insertSql = "INSERT INTO prod_bill_due_collection "
                + "(bill_id, balance, paid, finalBalance, mode, bankOption, uid, collectDate, collectTime, date, time) "
                + "VALUES (?,?,?,?,?,?,?,CURRENT_DATE(),CURRENT_TIME(),CURRENT_DATE(),CURRENT_TIME())";
        insertPS = con.prepareStatement(insertSql);
        insertPS.setInt(1, billId);
        insertPS.setDouble(2, currentBalances);
        insertPS.setDouble(3, payNow);
        insertPS.setDouble(4, newBalance);
        insertPS.setInt(5, mode);
        insertPS.setInt(6, bankOption);
        insertPS.setInt(7,  uid ); 
        insertPS.executeUpdate();

        String updateSql = "UPDATE prod_bill SET  currentBalance = ? WHERE id = ?";
        updatePS = con.prepareStatement(updateSql);
        //updatePS.setDouble(1, newPaid);
        updatePS.setDouble(1, newBalance);
        updatePS.setInt(2, billId);
        updatePS.executeUpdate();

        con.commit();
    } catch (Exception e) {
        if (con != null) try { con.rollback(); } catch (Exception ignore) {}
        throw e;
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignore) {}
        if (selectPS != null) try { selectPS.close(); } catch (Exception ignore) {}
        if (insertPS != null) try { insertPS.close(); } catch (Exception ignore) {}
        if (updatePS != null) try { updatePS.close(); } catch (Exception ignore) {}
        if (con != null) try { con.close(); } catch (Exception ignore) {}
    }
}
public double getBillCurrentBalance(int billId) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String sql = "SELECT currentBalance FROM prod_bill WHERE id = ?";
        ps = con.prepareStatement(sql);
        ps.setInt(1, billId);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            return rs.getDouble("currentBalance");
        }
        return 0.0;
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignore) {}
        if (ps != null) try { ps.close(); } catch (Exception ignore) {}
        if (con != null) try { con.close(); } catch (Exception ignore) {}
    }
}

public Vector getDuePaidList(int id) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String sql = "SELECT b.`cusName`,a.`balance`,a.`paid`,a.`finalBalance`,CASE WHEN a.mode=1 THEN 'Cash' ELSE 'Bank' END AS MODE, "
					+"	CASE WHEN a.bankOption=0 THEN '-' WHEN a.bankOption=1 THEN 'UPI' WHEN a.bankOption=2 THEN 'DEBIT CARD' WHEN a.bankOption=3 THEN 'CREDIT CARD' "
					+"	WHEN a.bankOption=4 THEN 'NEFT' WHEN a.bankOption=5 THEN 'WALLET' END AS bank,a.date,a.time,c.user_name   "
					+"	FROM `prod_bill_due_collection` a,`prod_bill` b,`users` c WHERE a.`bill_id`=b.id AND a.`uid`=c.`id` AND a.`bill_id`=?;";
        
        ps = con.prepareStatement(sql);
        ps.setInt(1, id);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString(1));           	
            row.addElement(rs.getString(2));      	
            row.addElement(rs.getString(3));     	
            row.addElement(rs.getString(4)); 
            row.addElement(rs.getString(5));
            row.addElement(rs.getString(6)); 
            row.addElement(rs.getString(7));
            row.addElement(rs.getString(8)); 
            row.addElement(rs.getString(9));	
           
            vec.add(row);
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    return vec;
}
public Vector getDuePaidList(String from, String to, int uid) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();

    try {
        con = util.DBConnectionManager.getConnectionFromPool();

        // Base query
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT b.cusName, a.balance, ");
        sql.append("CASE WHEN a.mode = 1 THEN a.paid ELSE '0' END AS cashPaid, ");
        sql.append("CASE WHEN a.mode = 2 THEN a.paid ELSE '0' END AS bankPaid, ");
        sql.append("CASE WHEN a.mode = 1 THEN 'Cash' ELSE 'Bank' END AS mode, ");
        sql.append("CASE ");
        sql.append(" WHEN a.bankOption = 0 THEN '-' ");
        sql.append(" WHEN a.bankOption = 1 THEN 'UPI' ");
        sql.append(" WHEN a.bankOption = 2 THEN 'DEBIT CARD' ");
        sql.append(" WHEN a.bankOption = 3 THEN 'CREDIT CARD' ");
        sql.append(" WHEN a.bankOption = 4 THEN 'NEFT' ");
        sql.append(" WHEN a.bankOption = 5 THEN 'WALLET' ");
        sql.append("END AS bank, ");
        sql.append("a.date, a.time, c.user_name, b.bill_display, b.id ");
        sql.append("FROM prod_bill_due_collection a ");
        sql.append("JOIN prod_bill b ON a.bill_id = b.id ");
        sql.append("JOIN users c ON a.uid = c.id ");
        sql.append("WHERE a.date BETWEEN ? AND ? b.is_cancelled=0");

        if (uid != 0) {
            sql.append("AND a.uid = ? ");
        }

        ps = con.prepareStatement(sql.toString());
        ps.setString(1, from);
        ps.setString(2, to);

        if (uid != 0) {
            ps.setInt(3, uid);
        }

        rs = ps.executeQuery();

        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString(1));   // cusName
            row.addElement(rs.getString(2));   // balance
            row.addElement(rs.getString(3));   // cashPaid
            row.addElement(rs.getString(4));   // bankPaid
            row.addElement(rs.getString(5));   // mode
            row.addElement(rs.getString(6));   // bank
            row.addElement(rs.getString(7));   // date
            row.addElement(rs.getString(8));   // time
            row.addElement(rs.getString(9));   // user_name
            row.addElement(rs.getString(10));  // bill_display
            row.addElement(rs.getString(11));  // id

            vec.add(row);
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignore) {}
        if (ps != null) try { ps.close(); } catch (Exception ignore) {}
        if (con != null) try { con.close(); } catch (Exception ignore) {}
    }

    return vec;
}
public double getDueCashTotal( String fromDate, String toDate)throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con					= util.DBConnectionManager.getConnectionFromPool();
		
		double totalSales	= 0;
		
		pt = con.prepareStatement("SELECT SUM(CASE WHEN a.mode=1 THEN a.paid END) AS cashPaid FROM `prod_bill_due_collection` a WHERE a.date BETWEEN ? AND ?;");
		pt.setString(1, fromDate);
		pt.setString(2, toDate);
		
		rs = pt.executeQuery();
		if(rs.next())
			totalSales	= rs.getDouble(1);
		
		return totalSales;
		}
	finally
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
	}
public double getDueBankTotal( String fromDate, String toDate)throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con					= util.DBConnectionManager.getConnectionFromPool();
		
		double totalSales	= 0;
		
		pt = con.prepareStatement("SELECT SUM(CASE WHEN a.mode=2 THEN a.paid END) AS bankPaid FROM `prod_bill_due_collection` a WHERE a.date BETWEEN ? AND ?;");
		pt.setString(1, fromDate);
		pt.setString(2, toDate);
		
		rs = pt.executeQuery();
		if(rs.next())
			totalSales	= rs.getDouble(1);
		
		return totalSales;
		}
	finally
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
	}
public void cancelBill(int billId, String cancelReason, int uid) throws Exception {
    Connection con = null;
    PreparedStatement psUpdate = null;
    PreparedStatement psInsert = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);   // start transaction

        String updateSql = "UPDATE prod_bill SET is_cancelled = 1 WHERE id = ?";
        psUpdate = con.prepareStatement(updateSql);
        psUpdate.setInt(1, billId);
        int rows = psUpdate.executeUpdate();
        System.out.println("Rows affected in prod_bill: " + rows);

        String insertSql =
            "INSERT INTO prod_bill_cancel (bill_id, reason, date, time, uid) " +
            "VALUES (?, ?, CURDATE(), CURTIME(), ?)";
        psInsert = con.prepareStatement(insertSql);
        psInsert.setInt(1, billId);
        psInsert.setString(2, cancelReason);
        psInsert.setInt(3, uid);
        psInsert.executeUpdate();

        con.commit();               // commit both operations
        System.out.println("Bill cancelled and reason saved.");
    } catch (Exception e) {
        if (con != null) {
            try {
                con.rollback();
                System.out.println("Transaction rolled back due to error.");
            } catch (Exception ex) {
                ex.printStackTrace();
            }
        }
        throw e;                    // rethrow to caller
    } finally {
        if (psInsert != null) try { psInsert.close(); } catch (Exception e) {}
        if (psUpdate != null) try { psUpdate.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public void updateStockAfterCancel(int prodId, BigDecimal qty, int uid) throws Exception {
    Connection con = null;
    PreparedStatement psUpdate = null;
    PreparedStatement psInsert = null;
    PreparedStatement psGetBatch = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);

        String getBatchSql = "SELECT id, stock FROM prod_batch WHERE product_id = ? LIMIT 1";
        psGetBatch = con.prepareStatement(getBatchSql);
        psGetBatch.setInt(1, prodId);
        rs = psGetBatch.executeQuery();

        if (!rs.next()) {
            throw new Exception("No batch found for product id: " + prodId);
        }

        int batchId = rs.getInt("id");
        BigDecimal currentStock = rs.getBigDecimal("stock");
        BigDecimal newStock = currentStock.add(qty);

        String updateSql = "UPDATE prod_batch SET stock = ? WHERE id = ?";
        psUpdate = con.prepareStatement(updateSql);
        psUpdate.setBigDecimal(1, newStock);
        psUpdate.setInt(2, batchId);
        psUpdate.executeUpdate();

        String insertSql = "INSERT INTO prod_lifecycle " +
                "(batch_id, product_id, stock_in, stock_out, stock_now, notes, date, time, uid, stock_type, stockAdjType) " +
                "VALUES (?, ?, ?, 0, ?, ?, CURDATE(), CURTIME(), ?, 1, 1)";
        psInsert = con.prepareStatement(insertSql);
        psInsert.setInt(1, batchId);
        psInsert.setInt(2, prodId);
        psInsert.setBigDecimal(3, qty);          // stock_in
        psInsert.setBigDecimal(4, newStock);     // stock_now
        psInsert.setString(5, "Cancel bill - returned to stock");
        psInsert.setInt(6, uid);
        psInsert.executeUpdate();

        con.commit();
        System.out.println("Stock updated for product " + prodId + ", qty restored: " + qty);
    } catch (Exception e) {
        if (con != null) {
            try { con.rollback(); } catch (Exception ex) { ex.printStackTrace(); }
        }
        throw e;
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (psInsert != null) try { psInsert.close(); } catch (Exception e) {}
        if (psUpdate != null) try { psUpdate.close(); } catch (Exception e) {}
        if (psGetBatch != null) try { psGetBatch.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}
 public int getBillId(String no)throws Exception
{
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;


		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  int billId  = 0;

		      pt = con.prepareStatement("SELECT id FROM prod_bill WHERE bill_display = ?");
		      pt.setString(1,no);
		      rs = pt.executeQuery();
		      if(rs.next())
		      	billId  = rs.getInt(1);

		      return billId;
			}
		finally
			{
				if (rs != null)
					{
					try	 { rs.close(); } catch (SQLException e) { ; }
					rs = null;
					}
				if (pt != null)
					{
					try	 { pt.close(); } catch (SQLException e) { ; }
					pt = null;
					}
				if(con!= null)
					{
					try{con.close();}catch(Exception e){}
					con = null;
					}
			}
}
public int getStatus(int billId,int prodId)throws Exception
{
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;


		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  int status  = 0;

		      pt = con.prepareStatement("SELECT CASE WHEN is_zero_stock_bill=1 THEN 1 ELSE 0 END AS STATUS FROM `prod_lifecycle` WHERE bill_id=? AND product_id=? AND is_zero_stock_bill=1;");
		      pt.setInt(1,billId);
		      pt.setInt(2,prodId);
		      rs = pt.executeQuery();
		      if(rs.next())
		      	status  = rs.getInt(1);

		      return status;
			}
		finally
			{
				if (rs != null)
					{
					try	 { rs.close(); } catch (SQLException e) { ; }
					rs = null;
					}
				if (pt != null)
					{
					try	 { pt.close(); } catch (SQLException e) { ; }
					pt = null;
					}
				if(con!= null)
					{
					try{con.close();}catch(Exception e){}
					con = null;
					}
			}
}
 public int getProductGST(int id)throws Exception
{
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;


		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  int status  = 0;

		      pt = con.prepareStatement("SELECT gst FROM `prod_product` WHERE id=?");
		      pt.setInt(1,id);
		      
		      rs = pt.executeQuery();
		      if(rs.next())
		      	status  = rs.getInt(1);

		      return status;
			}
		finally
			{
				if (rs != null)
					{
					try	 { rs.close(); } catch (SQLException e) { ; }
					rs = null;
					}
				if (pt != null)
					{
					try	 { pt.close(); } catch (SQLException e) { ; }
					pt = null;
					}
				if(con!= null)
					{
					try{con.close();}catch(Exception e){}
					con = null;
					}
			}
}

public double getProductCost(int productId, int batchId) throws Exception {
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;

		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  double cost  = 0.0;

		      pt = con.prepareStatement("SELECT cost FROM prod_batch WHERE product_id = ? AND id = ?");
		      pt.setInt(1, productId);
		      pt.setInt(2, batchId);
		      
		      rs = pt.executeQuery();
		      if(rs.next())
		      	cost  = rs.getDouble(1);

		      return cost;
			}
		finally
			{
				if (rs != null)
					{
					try	 { rs.close(); } catch (SQLException e) { ; }
					rs = null;
					}
				if (pt != null)
					{
					try	 { pt.close(); } catch (SQLException e) { ; }
					pt = null;
					}
				if(con!= null)
					{
					try{con.close();}catch(Exception e){}
					con = null;
					}
			}
}

public Vector getSalesGSTReport(String from, String to) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String sql = "SELECT b.bill_display AS invoice_no,b.cusName AS customer_name,b.date AS invoice_date,p.name AS item_description,(bd.price * bd.qty) / (1 + p.gst / 100) AS taxable_amount, "
				+"	p.gst AS gst_rate,(bd.price * bd.qty) - ((bd.price * bd.qty) / (1 + p.gst / 100)) AS gst_amount, bd.price * bd.qty AS sale_amount, "
				+"	(bd.price * bd.qty) + ((bd.price * bd.qty) * p.gst / 100) AS total "
				+"	FROM prod_bill b JOIN prod_bill_details bd ON b.id = bd.bill_id JOIN  prod_product p ON bd.prod_id = p.id "
				+"	WHERE b.date BETWEEN ? AND ? AND b.is_cancelled = 0  ORDER BY b.date DESC, b.bill_display;";
        
        ps = con.prepareStatement(sql);
        ps.setString(1, from);
        ps.setString(2, to);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString(1));           	
            row.addElement(rs.getString(2));      	
            row.addElement(rs.getString(3));     	
            row.addElement(rs.getString(4)); 
            row.addElement(rs.getString(5));
            row.addElement(rs.getString(6)); 
            row.addElement(rs.getString(7));
            row.addElement(rs.getString(8)); 
            row.addElement(rs.getString(9));	
           
            vec.add(row);
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    return vec;
}

// Invoice-wise GST Report for GSTR-1 Compliance
public Vector getSalesGSTReportInvoiceWise(String from, String to) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        // Invoice-wise aggregation with GST breakdown
        String sql = "SELECT " +
                    "b.bill_display AS invoice_no, " +
                    "b.cusName AS customer_name, " +
                    "b.date AS invoice_date, " +
                    "CASE WHEN c.gstin = '' OR c.gstin IS NULL THEN 'NA' ELSE c.gstin END AS customer_gstin, " +
                    "SUM((bd.price * bd.qty) / (1 + p.gst / 100)) AS taxable_amount, " +
                    "SUM((bd.price * bd.qty) - ((bd.price * bd.qty) / (1 + p.gst / 100))) AS total_gst, " +
                    "SUM(bd.price * bd.qty) AS invoice_value, " +
                    "b.total AS final_amount " +
                    "FROM prod_bill b " +
                    "JOIN prod_bill_details bd ON b.id = bd.bill_id " +
                    "JOIN prod_product p ON bd.prod_id = p.id " +
                    "LEFT JOIN customers c ON b.customerId = c.id " +
                    "WHERE b.date BETWEEN ? AND ? AND b.is_cancelled = 0 " +
                    "GROUP BY b.id, b.bill_display, b.cusName, b.date, b.total, c.gstin " +
                    "ORDER BY b.date DESC, b.bill_display";
        
        ps = con.prepareStatement(sql);
        ps.setString(1, from);
        ps.setString(2, to);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString("invoice_no"));           // 0
            row.addElement(rs.getString("customer_name"));        // 1
            row.addElement(rs.getString("invoice_date"));         // 2
            row.addElement(rs.getString("customer_gstin"));       // 3
            
            double taxableAmount = rs.getDouble("taxable_amount");
            double totalGst = rs.getDouble("total_gst");
            double invoiceValue = rs.getDouble("invoice_value");
            double finalAmount = rs.getDouble("final_amount");
            
            // Calculate CGST and SGST (50% each of total GST)
            double cgst = totalGst / 2;
            double sgst = totalGst / 2;
            
            row.addElement(String.format("%.2f", taxableAmount)); // 4
            row.addElement(String.format("%.2f", cgst));          // 5
            row.addElement(String.format("%.2f", sgst));          // 6
            row.addElement(String.format("%.2f", totalGst));      // 7
            row.addElement(String.format("%.2f", finalAmount));   // 8
            
            vec.add(row);
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    return vec;
}

public Vector getProfitAnalysisReport(String from, String to) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String sql = "SELECT a.bill_display, p.name, bd.qty, bd.cost, (bd.cost * bd.qty) AS total_cost, bd.total, a.date " +
                     "FROM prod_bill a " +
                     "JOIN prod_bill_details bd ON a.id = bd.bill_id " +
                     "JOIN prod_product p ON bd.prod_id = p.id " +
                     "WHERE a.date BETWEEN ? AND ? AND a.is_cancelled = 0 " +
                     "ORDER BY a.date DESC, a.bill_display";
        
        ps = con.prepareStatement(sql);
        ps.setString(1, from);
        ps.setString(2, to);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString("bill_display"));
            row.addElement(rs.getString("name"));
            row.addElement(rs.getBigDecimal("qty"));
            row.addElement(rs.getDouble("cost"));
            row.addElement(rs.getDouble("total_cost"));
            row.addElement(rs.getDouble("total"));
            row.addElement(rs.getString("date"));
            vec.add(row);
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    return vec;
}

public double getThisMonthProfit() throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    double profit = 0.0;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String sql = "SELECT SUM(bd.total - (bd.cost * bd.qty)) AS profit " +
                     "FROM prod_bill a " +
                     "JOIN prod_bill_details bd ON a.id = bd.bill_id " +
                     "WHERE MONTH(a.date) = MONTH(CURDATE()) " +
                     "AND YEAR(a.date) = YEAR(CURDATE()) " +
                     "AND a.is_cancelled = 0";
        
        ps = con.prepareStatement(sql);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            profit = rs.getDouble("profit");
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    return profit;
}

public double getLastMonthProfit() throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    double profit = 0.0;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String sql = "SELECT SUM(bd.total - (bd.cost * bd.qty)) AS profit " +
                     "FROM prod_bill a " +
                     "JOIN prod_bill_details bd ON a.id = bd.bill_id " +
                     "WHERE MONTH(a.date) = MONTH(DATE_SUB(CURDATE(), INTERVAL 1 MONTH)) " +
                     "AND YEAR(a.date) = YEAR(DATE_SUB(CURDATE(), INTERVAL 1 MONTH)) " +
                     "AND a.is_cancelled = 0";
        
        ps = con.prepareStatement(sql);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            profit = rs.getDouble("profit");
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    return profit;
}

public Vector getCancelBill(String from, String to) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String sql = "SELECT b.`bill_display`,b.`payable`,b.`paid`,a.`reason`,a.`date`,a.`time`,c.user_name,b.id FROM `prod_bill_cancel` a,`prod_bill` b,users c WHERE a.`bill_id`=b.`id` AND a.`uid`=c.id AND a.`date` BETWEEN ? AND ? ;";
        
        ps = con.prepareStatement(sql);
        ps.setString(1, from);
        ps.setString(2, to);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString(1));           	
            row.addElement(rs.getString(2));      	
            row.addElement(rs.getString(3));     	
            row.addElement(rs.getString(4)); 
            row.addElement(rs.getString(5));
            row.addElement(rs.getString(6)); 
            row.addElement(rs.getString(7)); 
            row.addElement(rs.getString(8)); 
	
           
            vec.add(row);
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    return vec;
}
public Vector getSalesReportByBrand(String from,String to,int brand)throws Exception
{
		Connection con 			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;
	try
	  {
	   con						= util.DBConnectionManager.getConnectionFromPool();
		Vector vec = new Vector();
	
	
			pt = con.prepareStatement("SELECT a.bill_display,c.`qty`,c.`price`,c.`disc`,c.`total`,a.date,a.time,b.user_name,a.id,d.`name`,e.`name`,f.`name`,a.paid,a.balance,a.currentBalance,a.cusName  "
									+"	FROM `prod_bill` a "
									+"	JOIN `users` b ON b.id=a.`uid`  "
									+"	join `prod_bill_details` c on c.bill_id=a.id "
									+"	join `prod_product` d on d.id=c.`prod_id` "
									+"	join `prod_category` e on e.id=d.category_id "
									+"	join `prod_brands` f on f.id=d.brand_id "
									+"	WHERE a.is_cancelled=0 AND a.date BETWEEN ? AND ? and f.id=?;");	
	
		pt.setString(1,from);
		pt.setString(2,to);	
		pt.setInt(3,brand);	
		rs = pt.executeQuery();
	while(rs.next())
		{	
		Vector vec1		= new Vector();
		vec1.addElement(rs.getString(1)); 	// 0 bill_display
		vec1.addElement(rs.getString(2));	//1 qty
		vec1.addElement(rs.getString(3));	//2 price
		vec1.addElement(rs.getString(4));	//3 disc
		vec1.addElement(rs.getString(5));	//4 total
		vec1.addElement(rs.getString(6));	//5 date
		vec1.addElement(rs.getString(7));	//6 time
		vec1.addElement(rs.getString(8));	//7 user
		vec1.addElement(rs.getString(9));	//8 billid
		vec1.addElement(rs.getString(10));	//9 iteam
		vec1.addElement(rs.getString(11));	//10 categ
		vec1.addElement(rs.getString(12));	//11 brand
		vec1.addElement(rs.getString(13));	//12 paid
		vec1.addElement(rs.getString(14));	//13 balance
		vec1.addElement(rs.getString(15));	//14 curBalance
		vec1.addElement(rs.getString(16));	//15 cusName
		vec.addElement(vec1);
		}
	return vec;
	 }
 	finally 
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
}
public Vector getDueSupplierBills(int supId) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();

        String sql = "SELECT a.id,a.`invno`,a.`invdate`,a.`total`,a.`paid`,a.`balance`,"
                   + "CONCAT(a.`ent_date`,'/',a.`ent_time`),b.user_name,c.name,a.prno "
                   + "FROM `prod_purchase` a "
                   + "JOIN users b ON a.`ent_uid`=b.id "
                   + "JOIN `prod_supplier` c ON a.`deal_id`=c.id "
                   + "WHERE a.`is_cancelled`=0 AND a.`balance`>0 AND a.invno!='' ";

        if (supId > 0) {
            sql += " AND a.deal_id=?";
            pt = con.prepareStatement(sql);
            pt.setInt(1, supId);
        } else {
            pt = con.prepareStatement(sql);
        }

        rs = pt.executeQuery();
        while (rs.next()) {
            Vector vec1 = new Vector();
            vec1.addElement(rs.getString(1));
            vec1.addElement(rs.getString(2));
            vec1.addElement(rs.getString(3));
            vec1.addElement(rs.getString(4));
            vec1.addElement(rs.getString(5));
            vec1.addElement(rs.getString(6));
            vec1.addElement(rs.getString(7));
            vec1.addElement(rs.getString(8));
            vec1.addElement(rs.getString(9));
            vec1.addElement(rs.getString(10));
            vec.addElement(vec1);
        }
        return vec;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pt != null) try { pt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}
public Vector getSupplierBillAmount(int id) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector row = new Vector();

    try {
        con = util.DBConnectionManager.getConnectionFromPool();

        String sql =
            "SELECT a.total, a.paid, a.balance FROM `prod_purchase` a WHERE id = ?";

        ps = con.prepareStatement(sql);
        ps.setInt(1, id);
        rs = ps.executeQuery();

        if (rs.next()) {            // only one record expected
            row.addElement(rs.getString(1));
            row.addElement(rs.getString(2));
            row.addElement(rs.getString(3));
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignore) {}
        if (ps != null) try { ps.close(); } catch (Exception ignore) {}
        if (con != null) try { con.close(); } catch (Exception ignore) {}
    }

    return row;
}
public Vector getSupplierPaymentId(int id) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector row = new Vector();

    try {
        con = util.DBConnectionManager.getConnectionFromPool();

        String sql =
            "SELECT id FROM `prod_purchase_supplier_payment` WHERE prid=?;";

        ps = con.prepareStatement(sql);
        ps.setInt(1, id);
        rs = ps.executeQuery();

        if (rs.next()) {            // only one record expected
            row.addElement(rs.getString(1));
            
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignore) {}
        if (ps != null) try { ps.close(); } catch (Exception ignore) {}
        if (con != null) try { con.close(); } catch (Exception ignore) {}
    }

    return row;
}

public int getSupplierIdFromBill(int billId) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    int supplierId = 0;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();

        String sql =
            "SELECT deal_id FROM `prod_purchase_supplier_payment` WHERE prid = ?";

        ps = con.prepareStatement(sql);
        ps.setInt(1, billId);
        rs = ps.executeQuery();

        if (rs.next()) {
            supplierId = rs.getInt(1);
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignore) {}
        if (ps != null) try { ps.close(); } catch (Exception ignore) {}
        if (con != null) try { con.close(); } catch (Exception ignore) {}
    }

    return supplierId;
}

public void saveSupplierDuePayment(int billId, double payNow, int mode, int bankOption,
                                   int uid, int supId, double balance,int supPayID) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false); // start transaction

        // 1. Update prod_purchase
        pt = con.prepareStatement(
            "UPDATE prod_purchase " +
            "SET paid = paid + ?, balance = balance - ? " +
            "WHERE id = ?"
        );
        pt.setDouble(1, payNow);
        pt.setDouble(2, payNow);
        pt.setInt(3, billId);
        pt.executeUpdate();
        pt.close();

        // 2. Update prod_purchase_supplier_payment
        pt = con.prepareStatement(
            "UPDATE prod_purchase_supplier_payment " +
            "SET paid = paid + ?, balance = balance - ? " +
            "WHERE id = ?"
        );
        pt.setDouble(1, payNow);
        pt.setDouble(2, payNow);
        pt.setInt(3, supPayID);
        pt.executeUpdate();
        pt.close();

        // 3. Insert into prod_purchase_supplier_payment_details
        pt = con.prepareStatement(
            "INSERT INTO prod_purchase_supplier_payment_details " +
            "(supPayId, payable, paid, balance, pay_type, pay_mode, uid, notes, date, time) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, now(), now())"
        );

        pt.setInt(1, supPayID);            // supPayId
        pt.setDouble(2, balance);        // original balance passed
        pt.setDouble(3, payNow);         // this payment
        pt.setDouble(4, balance - payNow); // new balance
        pt.setInt(5, mode);              // payment type
        pt.setInt(6, bankOption);        // bank option (0-6, where 6 is Cheque)
        pt.setInt(7, uid);               // user id
        pt.setString(8, "pending payment"); // notes
        pt.executeUpdate();

        con.commit(); // commit all 3 steps
    } catch (Exception e) {
        if (con != null) {
            try { con.rollback(); } catch (SQLException ex) { }
        }
        throw e;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pt != null) try { pt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}
public Vector getDueSupplierPaidList(int id) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();

        String sql = "SELECT c.`invno`,d.`name`,a.`payable`,a.`paid`,a.`balance`,CASE WHEN a.pay_type=1 THEN 'CASH' ELSE 'BANK' END,b.user_name,a.date,a.time FROM `prod_purchase_supplier_payment_details` a,users b,`prod_purchase` c,`prod_supplier` d " 
				+" WHERE a.`uid`=b.id AND c.id=a.`supPayId` AND d.id=c.`deal_id` AND a.`supPayId`=?;";

        
            pt = con.prepareStatement(sql);
            pt.setInt(1, id);
       

        rs = pt.executeQuery();
        while (rs.next()) {
            Vector vec1 = new Vector();
            vec1.addElement(rs.getString(1));
            vec1.addElement(rs.getString(2));
            vec1.addElement(rs.getString(3));
            vec1.addElement(rs.getString(4));
            vec1.addElement(rs.getString(5));
            vec1.addElement(rs.getString(6));
            vec1.addElement(rs.getString(7));
            vec1.addElement(rs.getString(8));
            vec1.addElement(rs.getString(9));
            vec.addElement(vec1);
        }
        return vec;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pt != null) try { pt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}
public double getPaidTotal(String bill)throws Exception
{
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;


		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  double disc  = 0;

		      pt = con.prepareStatement("SELECT paid FROM `prod_bill` WHERE bill_display=?;");
		      pt.setString(1,bill);
		      rs = pt.executeQuery();
		      if(rs.next())
		      	disc  = rs.getDouble(1);

		      return disc;
			}
		finally
			{
				if (rs != null)
					{
					try	 { rs.close(); } catch (SQLException e) { ; }
					rs = null;
					}
				if (pt != null)
					{
					try	 { pt.close(); } catch (SQLException e) { ; }
					pt = null;
					}
				if(con!= null)
					{
					try{con.close();}catch(Exception e){}
					con = null;
					}
			}
}
public double getbalanceTotal(String bill)throws Exception
{
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;


		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  double disc  = 0;

		      pt = con.prepareStatement("SELECT balance FROM `prod_bill` WHERE bill_display=?;");
		      pt.setString(1,bill);
		      rs = pt.executeQuery();
		      if(rs.next())
		      	disc  = rs.getDouble(1);

		      return disc;
			}
		finally
			{
				if (rs != null)
					{
					try	 { rs.close(); } catch (SQLException e) { ; }
					rs = null;
					}
				if (pt != null)
					{
					try	 { pt.close(); } catch (SQLException e) { ; }
					pt = null;
					}
				if(con!= null)
					{
					try{con.close();}catch(Exception e){}
					con = null;
					}
			}
}
public String getBillDate(String bill)throws Exception
	{
			Connection con 			= null;
	PreparedStatement pt	= null;
	ResultSet rs			= null;
	try{
	
	con						= util.DBConnectionManager.getConnectionFromPool();
	pt = con.prepareStatement("SELECT CONCAT(DATE_FORMAT(date, '%d-%m-%Y'), ' ', TIME_FORMAT(time, '%H:%i:%s')) AS bill_datetime FROM `prod_bill` WHERE bill_display=?;");
	pt.setString(1,bill);
	rs=pt.executeQuery();
	if(rs.next())
		{
		return rs.getString(1);
		}
	return null;
	}
finally
	{
	if (pt != null)
		{
		try	 { pt.close(); } catch (SQLException e) { ; }
		pt = null;
		}
		
	if (rs != null)
		{
		try	 { rs.close(); } catch (SQLException e) { ; }
		rs = null;
		}
		    		
	if(con!= null)			
		{
		try{con.close();}catch(Exception e){}
		con = null;	
		}
	}
	}
public Vector getDueCollection(String from, String to) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String sql = "select b.`bill_display`,b.`cusName`,a.`balance`,a.`paid`,a.`finalBalance` "
				+"	,case when a.mode=1 then 'CASH' else 'BANK'end as mode,c.user_name,DATE_FORMAT(a.collectDate, '%d-%m-%Y') AS bill_date,a.collectTime from `prod_bill_due_collection` a,`prod_bill` b,users c where b.id=a.`bill_id` "
				+"	and c.id=a.uid and a.collectDate between ? and ?;";
        
        ps = con.prepareStatement(sql);
        ps.setString(1, from);
        ps.setString(2, to);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString(1));           	
            row.addElement(rs.getString(2));      	
            row.addElement(rs.getString(3));     	
            row.addElement(rs.getString(4)); 
            row.addElement(rs.getString(5));
            row.addElement(rs.getString(6)); 
            row.addElement(rs.getString(7)); 
            row.addElement(rs.getString(8)); 
            row.addElement(rs.getString(9)); 
	
           
            vec.add(row);
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    return vec;
}
public double getSalesDiscountTotal( String fromDate, String toDate)throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con					= util.DBConnectionManager.getConnectionFromPool();
		
		double totalSales	= 0;
		
		pt = con.prepareStatement("SELECT SUM(a.extraDisc+a.prodDisc) "
								+"	FROM `prod_bill` a   "
								+"	JOIN`prod_bill_payment` b ON b.bill_id=a.id "
								+"	WHERE a.is_cancelled=0 AND a.date BETWEEN ?  AND ?");
		pt.setString(1, fromDate);
		pt.setString(2, toDate);
		
		rs = pt.executeQuery();
		if(rs.next())
			totalSales	= rs.getDouble(1);
		
		return totalSales;
		}
	finally
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
	}
	public Vector getSalesReportByItem(String from,String to,int item)throws Exception
{
		Connection con 			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;
	try
	  {
	   con						= util.DBConnectionManager.getConnectionFromPool();
		Vector vec = new Vector();
	
	
			pt = con.prepareStatement("SELECT a.bill_display,c.`qty`,c.`price`,c.`disc`,c.`total`,a.date,a.time,b.user_name,a.id,d.`name`,e.`name`,f.`name`,a.paid,a.balance,a.currentBalance,a.cusName  "
									+"	FROM `prod_bill` a "
									+"	JOIN `users` b ON b.id=a.`uid`  "
									+"	join `prod_bill_details` c on c.bill_id=a.id "
									+"	join `prod_product` d on d.id=c.`prod_id` "
									+"	join `prod_category` e on e.id=d.category_id "
									+"	join `prod_brands` f on f.id=d.brand_id "
									+"	WHERE a.is_cancelled=0 AND a.date BETWEEN ? AND ? and d.id=?;");	
	
		pt.setString(1,from);
		pt.setString(2,to);	
		pt.setInt(3,item);	
		rs = pt.executeQuery();
	while(rs.next())
		{	
		Vector vec1		= new Vector();
		vec1.addElement(rs.getString(1)); 	// 0 bill_display
		vec1.addElement(rs.getString(2));	//1 qty
		vec1.addElement(rs.getString(3));	//2 price
		vec1.addElement(rs.getString(4));	//3 disc
		vec1.addElement(rs.getString(5));	//4 total
		vec1.addElement(rs.getString(6));	//5 date
		vec1.addElement(rs.getString(7));	//6 time
		vec1.addElement(rs.getString(8));	//7 user
		vec1.addElement(rs.getString(9));	//8 billid
		vec1.addElement(rs.getString(10));	//9 iteam
		vec1.addElement(rs.getString(11));	//10 categ
		vec1.addElement(rs.getString(12));	//11 brand
		vec1.addElement(rs.getString(13));	//12 paid
		vec1.addElement(rs.getString(14));	//13 balance
		vec1.addElement(rs.getString(15));	//14 curBalance
		vec1.addElement(rs.getString(16));	//15 cusName
		vec.addElement(vec1);
		}
	return vec;
	 }
 	finally 
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
}
public Vector getCommissionReport(String from, String to, int customerId) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();
        pt = con.prepareStatement(
            "SELECT a.bill_display, DATE(a.date) AS bill_date, " +
            "p.name AS product_name, " +
            "d.qty, d.price, d.disc, d.total, " +
            "IFNULL(d.commission, 0) AS commission_per_unit, " +
            "IFNULL(d.commission, 0) * d.qty AS commission_amount " +
            "FROM prod_bill a " +
            "JOIN prod_bill_details d ON d.bill_id = a.id " +
            "JOIN prod_product p ON p.id = d.prod_id " +
            "WHERE a.is_cancelled = 0 " +
            "AND a.customerId = ? " +
            "AND DATE(a.date) BETWEEN ? AND ? " +
            "ORDER BY a.date, a.id, d.id"
        );
        pt.setInt(1, customerId);
        pt.setString(2, from);
        pt.setString(3, to);
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString(1));   // 0 bill_display
            row.addElement(rs.getString(2));   // 1 bill_date
            row.addElement(rs.getString(3));   // 2 product_name
            row.addElement(rs.getDouble(4));   // 3 qty
            row.addElement(rs.getDouble(5));   // 4 price
            row.addElement(rs.getDouble(6));   // 5 disc
            row.addElement(rs.getDouble(7));   // 6 total
            row.addElement(rs.getDouble(8));   // 7 commission_per_unit
            row.addElement(rs.getDouble(9));   // 8 commission_amount
            vec.addElement(row);
        }
        return vec;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { }
        if (pt != null) try { pt.close(); } catch (SQLException e) { }
        if (con != null) try { con.close(); } catch (Exception e) { }
    }
}
public Vector getSalesReportByCustomer(String from, String to, int customerId) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();
        
        pt = con.prepareStatement(
            "SELECT a.id, a.bill_display, a.total, " +
            "(a.prodDisc + a.extraDisc) AS totalDiscount, " +
            "a.payable, a.paid, a.balance, a.currentBalance, " +
            "a.date, a.time, b.user_name " +
            "FROM prod_bill a " +
            "JOIN users b ON b.id = a.uid " +
            "WHERE a.is_cancelled = 0 " +
            "AND a.date BETWEEN ? AND ? " +
            "AND a.customerId = ? " +
            "ORDER BY a.date DESC, a.time DESC"
        );
        
        pt.setString(1, from);
        pt.setString(2, to);
        pt.setInt(3, customerId);
        rs = pt.executeQuery();
        
        while (rs.next()) {
            Vector vec1 = new Vector();
            vec1.addElement(rs.getInt(1));      // 0 bill id
            vec1.addElement(rs.getString(2));   // 1 bill_display
            vec1.addElement(rs.getDouble(3));   // 2 total
            vec1.addElement(rs.getDouble(4));   // 3 discount
            vec1.addElement(rs.getDouble(5));   // 4 payable
            vec1.addElement(rs.getDouble(6));   // 5 paid
            vec1.addElement(rs.getDouble(7));   // 6 balance
            vec1.addElement(rs.getDouble(8));   // 7 currentBalance
            vec1.addElement(rs.getString(9));   // 8 date
            vec1.addElement(rs.getString(10));  // 9 time
            vec1.addElement(rs.getString(11));  // 10 user_name
            vec.addElement(vec1);
        }
        return vec;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { }
        if (pt != null) try { pt.close(); } catch (SQLException e) { }
        if (con != null) try { con.close(); } catch (Exception e) { }
    }
}
public String getNumPaid(double amount) {
        long rupees = (long) amount;
        int paise = (int) Math.round((amount - rupees) * 100);

        String words = convertNumberToWords(rupees) + " Rupees";
        if (paise > 0) {
            words += " and " + convertNumberToWords(paise) + " Paise";
        }
        words += " Only";

        return words;
    }

    // Helper method for integer numbers
    private String convertNumberToWords(long n) {
        String[] units = { "", "One", "Two", "Three", "Four", "Five",
                "Six", "Seven", "Eight", "Nine", "Ten",
                "Eleven", "Twelve", "Thirteen", "Fourteen",
                "Fifteen", "Sixteen", "Seventeen", "Eighteen", "Nineteen" };

        String[] tens = { "", "", "Twenty", "Thirty", "Forty", "Fifty",
                "Sixty", "Seventy", "Eighty", "Ninety" };

        if (n < 20) return units[(int)n];
        if (n < 100) return tens[(int)n / 10] + ((n % 10 != 0) ? " " + units[(int)(n % 10)] : "");
        if (n < 1000) return units[(int)(n / 100)] + " Hundred" + ((n % 100 != 0) ? " " + convertNumberToWords(n % 100) : "");
        if (n < 100000) return convertNumberToWords(n / 1000) + " Thousand" + ((n % 1000 != 0) ? " " + convertNumberToWords(n % 1000) : "");
        if (n < 10000000) return convertNumberToWords(n / 100000) + " Lakh" + ((n % 100000 != 0) ? " " + convertNumberToWords(n % 100000) : "");
        return convertNumberToWords(n / 10000000) + " Crore" + ((n % 10000000 != 0) ? " " + convertNumberToWords(n % 10000000) : "");
    }
 public String getCusName(String bill)throws Exception
	{
			Connection con 			= null;
	PreparedStatement pt	= null;
	ResultSet rs			= null;
	try{
	
	con						= util.DBConnectionManager.getConnectionFromPool();
	pt = con.prepareStatement("SELECT cusName FROM `prod_bill` WHERE bill_display=?;");
	pt.setString(1,bill);
	rs=pt.executeQuery();
	if(rs.next())
		{
		return rs.getString(1);
		}
	return null;
	}
finally
	{
	if (pt != null)
		{
		try	 { pt.close(); } catch (SQLException e) { ; }
		pt = null;
		}
		
	if (rs != null)
		{
		try	 { rs.close(); } catch (SQLException e) { ; }
		rs = null;
		}
		    		
	if(con!= null)			
		{
		try{con.close();}catch(Exception e){}
		con = null;	
		}
	}
	}
public Vector getCustomerDetailsByBillNo(String bill) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        pt = con.prepareStatement(
            "SELECT c.name, c.phone_number, c.address, c.gstin " +
            "FROM prod_bill b " +
            "LEFT JOIN customers c ON b.customerId = c.id " +
            "WHERE b.bill_display = ?"
        );
        pt.setString(1, bill);
        rs = pt.executeQuery();
        
        Vector customerDetails = new Vector();
        if (rs.next()) {
            customerDetails.add(rs.getString(1) != null ? rs.getString(1) : "-"); // name
            customerDetails.add(rs.getString(2) != null ? rs.getString(2) : "-"); // phone
            customerDetails.add(rs.getString(3) != null ? rs.getString(3) : "-"); // address
            customerDetails.add(rs.getString(4) != null ? rs.getString(4) : "-"); // gstin
        }
        
        return customerDetails;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { }
        if (pt != null) try { pt.close(); } catch (SQLException e) { }
        if (con != null) try { con.close(); } catch (Exception e) { }
    }
}
public double getThisMonthPhSale()throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con					= util.DBConnectionManager.getConnectionFromPool();
		
		double totalSales	= 0;
		
		pt = con.prepareStatement("SELECT IFNULL(SUM(a.`payable`), 0) AS this_month_total "
								+"	FROM prod_bill a "
								+"	WHERE a.`is_cancelled` = 0 "
								+"	  AND MONTH(a.`date`) = MONTH(CURRENT_DATE()) "
								+"	  AND YEAR(a.`date`) = YEAR(CURRENT_DATE());");

		
		rs = pt.executeQuery();
		if(rs.next())
			totalSales	= rs.getDouble(1);
		
		return totalSales;
		}
	finally
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
	}
	public double getLastMonthPhSale()throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con					= util.DBConnectionManager.getConnectionFromPool();
		
		double totalSales	= 0;
		
		pt = con.prepareStatement("SELECT IFNULL(SUM(a.`payable`), 0) AS this_month_total "
								+"	FROM prod_bill a  "
							
								+"	WHERE a.`is_cancelled` = 0 "
								 +" AND MONTH(a.`date`) = MONTH(CURRENT_DATE() - INTERVAL 1 MONTH)"
  								+"  AND YEAR(a.`date`) = YEAR(CURRENT_DATE() - INTERVAL 1 MONTH);");

		
		rs = pt.executeQuery();
		if(rs.next())
			totalSales	= rs.getDouble(1);
		
		return totalSales;
		}
	finally
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
	}
public double getThisMonthPhPurchase()throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con					= util.DBConnectionManager.getConnectionFromPool();
		
		double totalSales	= 0;
		
		pt = con.prepareStatement("SELECT IFNULL(SUM(a.`total`), 0) AS this_month_total  "
								+"	FROM `prod_purchase` a "
								+"	WHERE MONTH(a.`ent_date`) = MONTH(CURRENT_DATE())  "
								+"	  AND YEAR(a.`ent_date`) = YEAR(CURRENT_DATE());");

		
		rs = pt.executeQuery();
		if(rs.next())
			totalSales	= rs.getDouble(1);
		
		return totalSales;
		}
	finally
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
	}
	public double getLastMonthPhPurchase()throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con					= util.DBConnectionManager.getConnectionFromPool();
		
		double totalSales	= 0;
		
		pt = con.prepareStatement("SELECT IFNULL(SUM(a.`total`), 0) AS this_month_total "
								+"	FROM `prod_purchase` a "
								+"	WHERE  MONTH(a.`ent_date`) = MONTH(CURRENT_DATE() - INTERVAL 1 MONTH) "
								+"	AND YEAR(a.`ent_date`) = YEAR(CURRENT_DATE() - INTERVAL 1 MONTH);");

		
		rs = pt.executeQuery();
		if(rs.next())
			totalSales	= rs.getDouble(1);
		
		return totalSales;
		}
	finally
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
	}

	
public Vector getSalesReportCharts()throws Exception
{
		Connection con 			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;
	try
	  {
	   con						= util.DBConnectionManager.getConnectionFromPool();
		Vector vec = new Vector();
	
	
			pt = con.prepareStatement("SELECT  "
								+"	  DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL nums.n DAY), '%d-%m-%Y') AS bill_date, "
								+"	  IFNULL(SUM(pb.payable), 0) AS total_payable "
								+"	FROM ( "
								+"	  SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 "
								+"	  UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 "
								+"	  UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 "
								+"	  UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 "
								+"	) AS nums "
								+"	LEFT JOIN prod_bill pb "
								+"	  ON DATE(pb.`date`) = DATE_SUB(CURDATE(), INTERVAL nums.n DAY) "
								+"	  AND pb.is_cancelled = 0 "
								+"	GROUP BY nums.n "
								+"	ORDER BY nums.n ASC;  -- n=0 (today) first, n=15 oldest last");	
	

		rs = pt.executeQuery();
	while(rs.next())
		{	
		Vector vec1		= new Vector();
		vec1.addElement(rs.getString(1));
		vec1.addElement(rs.getString(2));

		vec.addElement(vec1);
		}
	return vec;
	 }
 	finally 
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
}

public Vector getPurchaseReportCharts()throws Exception
{
		Connection con 			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;
	try
	  {
	   con						= util.DBConnectionManager.getConnectionFromPool();
		Vector vec = new Vector();
	
	
			pt = con.prepareStatement("SELECT  "
								+"	  DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL nums.n DAY), '%d-%m-%Y') AS bill_date, "
								+"	  IFNULL(SUM(pp.total), 0) AS total_purchase "
								+"	FROM ( "
								+"	  SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 "
								+"	  UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 "
								+"	  UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 "
								+"	  UNION ALL SELECT 12 UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 "
								+"	) AS nums "
								+"	LEFT JOIN prod_purchase pp "
								+"	  ON DATE(pp.`ent_date`) = DATE_SUB(CURDATE(), INTERVAL nums.n DAY) "
								+"	  AND pp.is_cancelled = 0 "
								+"	GROUP BY nums.n "
								+"	ORDER BY nums.n ASC;  -- n=0 (today) first, n=15 oldest last");	
	
	
		rs = pt.executeQuery();
	while(rs.next())
		{	
		Vector vec1		= new Vector();
		vec1.addElement(rs.getString(1));
		vec1.addElement(rs.getString(2));

		vec.addElement(vec1);
		}
	return vec;
	 }
 	finally 
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
}

public double getTotalSalesByDateRange(String from, String to) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    double totalSales = 0.0;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement("SELECT SUM(payable) FROM prod_bill WHERE is_cancelled = 0 AND date BETWEEN ? AND ?");
        pt.setString(1, from);
        pt.setString(2, to);
        rs = pt.executeQuery();
        if (rs.next()) {
            totalSales = rs.getDouble(1);
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    return totalSales;
}

public double getTotalPurchasesByDateRange(String from, String to) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    double totalPurchases = 0.0;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement("SELECT SUM(total) FROM prod_purchase WHERE is_cancelled = 0 AND ent_date BETWEEN ? AND ?");
        pt.setString(1, from);
        pt.setString(2, to);
        rs = pt.executeQuery();
        if (rs.next()) {
            totalPurchases = rs.getDouble(1);
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    return totalPurchases;
}

public double getTodaySales() throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    double todaySales = 0.0;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement("SELECT IFNULL(SUM(payable), 0) FROM prod_bill WHERE is_cancelled = 0 AND DATE(date) = CURDATE()");
        rs = pt.executeQuery();
        if (rs.next()) {
            todaySales = rs.getDouble(1);
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    return todaySales;
}

public int getTodayBillCount() throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    int billCount = 0;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement("SELECT COUNT(*) FROM prod_bill WHERE is_cancelled = 0 AND DATE(date) = CURDATE()");
        rs = pt.executeQuery();
        if (rs.next()) {
            billCount = rs.getInt(1);
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    return billCount;
}

public Vector getProductWiseProfitLoss(String from, String to) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    Vector result = new Vector();
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        System.out.println("getProductWiseProfitLoss called with dates: " + from + " to " + to);
        
        // Query to get product-wise sales with costs
        String sql = "SELECT " +
            "p.name AS product_name, " +
            "SUM(bd.qty) AS total_qty_sold, " +
            "SUM(bd.total) AS total_sales_amount, " +
            "AVG(bd.price) AS avg_sale_price, " +
            "COALESCE( " +
            "    (SELECT pd.rate FROM prod_purchase_details pd " +
            "     JOIN prod_purchase pp ON pp.id = pd.prid " +
            "     WHERE pd.prods_id = p.id AND pp.is_cancelled = 0 " +
            "     ORDER BY pp.ent_date DESC LIMIT 1), " +
            "    (SELECT pb.cost FROM prod_batch pb " +
            "     WHERE pb.product_id = p.id ORDER BY pb.id DESC LIMIT 1) " +
            ") AS cost_price " +
            "FROM prod_bill_details bd " +
            "JOIN prod_bill b ON b.id = bd.bill_id " +
            "JOIN prod_product p ON p.id = bd.prod_id " +
            "WHERE b.is_cancelled = 0 AND b.date BETWEEN ? AND ? " +
            "GROUP BY p.id, p.name " +
            "ORDER BY total_sales_amount DESC";
            
        pt = con.prepareStatement(sql);
        pt.setString(1, from);
        pt.setString(2, to);
        rs = pt.executeQuery();
        System.out.println("Query executed, processing results...");
        
        while (rs.next()) {
            Vector row = new Vector();
            String productName = rs.getString("product_name");
            double qtySold = rs.getDouble("total_qty_sold");
            double totalSales = rs.getDouble("total_sales_amount");
            double avgSalePrice = rs.getDouble("avg_sale_price");
            double costPrice = rs.getDouble("cost_price");
            
            // Calculate profit/loss
            double totalCost = qtySold * costPrice;
            double profitLoss = totalSales - totalCost;
            double profitMargin = totalSales > 0 ? (profitLoss / totalSales) * 100 : 0;
            
            row.addElement(productName);        // 0 - Product Name
            row.addElement(String.valueOf(qtySold));     // 1 - Quantity Sold
            row.addElement(String.format("%.2f", avgSalePrice)); // 2 - Avg Sale Price
            row.addElement(String.format("%.2f", costPrice));    // 3 - Cost Price
            row.addElement(String.format("%.2f", totalSales));   // 4 - Total Sales
            row.addElement(String.format("%.2f", totalCost));    // 5 - Total Cost
            row.addElement(String.format("%.2f", profitLoss));   // 6 - Profit/Loss
            row.addElement(String.format("%.2f", profitMargin)); // 7 - Profit Margin %
            
            result.addElement(row);
        }
        
        System.out.println("Total products processed: " + result.size());
        
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    return result;
}

// Get bills by date range for bill date change
public Vector getBillsByDateRange(String fromDate, String toDate, int userId) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String sql = "SELECT id, bill_no, pat_name, date, time, total, paid, balance " +
                     "FROM prod_bill " +
                     "WHERE date BETWEEN ? AND ? AND is_cancelled = 0";
        
        // Add user filter if not "All User" (userId = 0)
        if (userId != 0) {
            sql += " AND ent_uid = ?";
        }
        
        sql += " ORDER BY date DESC, time DESC";
        
        System.out.println("SQL Query: " + sql);
        System.out.println("From Date: " + fromDate + ", To Date: " + toDate + ", User ID: " + userId);
        
        pt = con.prepareStatement(sql);
        pt.setString(1, fromDate);
        pt.setString(2, toDate);
        
        if (userId != 0) {
            pt.setInt(3, userId);
        }
        
        rs = pt.executeQuery();
        
        int count = 0;
        while (rs.next()) {
            count++;
            Vector row = new Vector();
            row.addElement(rs.getString(1));  // id
            row.addElement(rs.getString(2));  // bill_no
            row.addElement(rs.getString(3));  // pat_name
            row.addElement(rs.getString(4));  // date
            row.addElement(rs.getString(5));  // time
            row.addElement(rs.getString(6));  // total
            row.addElement(rs.getString(7));  // paid
            row.addElement(rs.getString(8));  // balance
            vec.addElement(row);
        }
        System.out.println("Total rows retrieved: " + count);
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    System.out.println("Returning vector with size: " + vec.size());
    return vec;
}

// Update bill date
public boolean updateBillDate(int billId, String newDate, int userId) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        // First, get the old date
        String oldDate = null;
        pt = con.prepareStatement("SELECT date FROM prod_bill WHERE id = ?");
        pt.setInt(1, billId);
        rs = pt.executeQuery();
        if (rs.next()) {
            oldDate = rs.getString(1);
        }
        rs.close();
        pt.close();
        
        // Insert into audit table
        if (oldDate != null) {
            pt = con.prepareStatement("INSERT INTO prod_bill_datechange (billId, oldDate, changeDate, date, time, uid) VALUES (?, ?, ?, CURDATE(), CURTIME(), ?)");
            pt.setInt(1, billId);
            pt.setString(2, oldDate);
            pt.setString(3, newDate);
            pt.setInt(4, userId);
            pt.executeUpdate();
            pt.close();
        }
        
        // Update the bill date
        pt = con.prepareStatement("UPDATE prod_bill SET date = ? WHERE id = ?");
        pt.setString(1, newDate);
        pt.setInt(2, billId);
        
        int rowsUpdated = pt.executeUpdate();
        con.commit();
        
        return rowsUpdated > 0;
    } catch (Exception e) {
        if (con != null) try { con.rollback(); } catch (Exception ex) {}
        throw e;
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

// Get bill date change report
public Vector getBillDateChangeReport(String fromDate, String toDate) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String sql = "SELECT a.billId, b.bill_display, a.oldDate, a.changeDate, a.date, a.time, c.user_name " +
                     "FROM prod_bill_datechange a " +
                     "JOIN prod_bill b ON a.billId = b.id " +
                     "JOIN users c ON a.uid = c.id " +
                     "WHERE a.date BETWEEN ? AND ? " +
                     "ORDER BY a.date DESC, a.time DESC";
        
        pt = con.prepareStatement(sql);
        pt.setString(1, fromDate);
        pt.setString(2, toDate);
        rs = pt.executeQuery();
        
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt(1));      // billId
            row.addElement(rs.getString(2));   // bill_display
            row.addElement(rs.getString(3));   // oldDate
            row.addElement(rs.getString(4));   // changeDate
            row.addElement(rs.getString(5));   // date
            row.addElement(rs.getString(6));   // time
            row.addElement(rs.getString(7));   // user_name
            vec.addElement(row);
        }
        return vec;
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}
public String getCusNumber(String bill)throws Exception
	{
			Connection con 			= null;
	PreparedStatement pt	= null;
	ResultSet rs			= null;
	try{
	
	con						= util.DBConnectionManager.getConnectionFromPool();
	pt = con.prepareStatement("SELECT cusPhn FROM `prod_bill` WHERE bill_display=?;");
	pt.setString(1,bill);
	rs=pt.executeQuery();
	if(rs.next())
		{
		return rs.getString(1);
		}
	return null;
	}
finally
	{
	if (pt != null)
		{
		try	 { pt.close(); } catch (SQLException e) { ; }
		pt = null;
		}
		
	if (rs != null)
		{
		try	 { rs.close(); } catch (SQLException e) { ; }
		rs = null;
		}
		    		
	if(con!= null)			
		{
		try{con.close();}catch(Exception e){}
		con = null;	
		}
	}
	}

//////////////////////////---------------------------
// Get active batch ID for a product (used for component stock reduction)
public int getProductBatchId(int productId) throws Exception {
	Connection con = null;
	PreparedStatement pt = null;
	ResultSet rs = null;
	try {
		con = util.DBConnectionManager.getConnectionFromPool();
		
		pt = con.prepareStatement("SELECT id FROM prod_batch WHERE product_id = ? AND stock > 0 ORDER BY id LIMIT 1");
		pt.setInt(1, productId);
		rs = pt.executeQuery();
		
		if (rs.next()) {
			return rs.getInt("id");
		}
		
		return 0;
	} finally {
		if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
		if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
		if (con != null) try { con.close(); } catch (SQLException e) { ; }
	}
}

//////////////////////////---------------------------
// Update stock with custom notes (overloaded method for component tracking)
public void updateStock(int productId, BigDecimal qty, int uid, int batchId, int billId, String notes) throws Exception {
    updateStock(productId, qty, uid, batchId, billId, notes, false);
}

public void updateStock(int productId, BigDecimal qty, int uid, int batchId, int billId, String notes, boolean userHasStockPermission) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);

        // Get current stock from prod_batch
        BigDecimal currentStock = BigDecimal.ZERO;
        pt = con.prepareStatement("SELECT stock FROM prod_batch WHERE product_id = ? AND id = ?");
        pt.setInt(1, productId);
        pt.setInt(2, batchId);
        rs = pt.executeQuery();
        if (rs.next()) {
            currentStock = rs.getBigDecimal("stock");
        }
        rs.close();
        pt.close();

        // Get last stock_now from prod_lifecycle
        BigDecimal lastStockNow = BigDecimal.ZERO;
        pt = con.prepareStatement(
            "SELECT stock_now FROM prod_lifecycle WHERE product_id = ? ORDER BY id DESC LIMIT 1"
        );
        pt.setInt(1, productId);
        rs = pt.executeQuery();
        if (rs.next()) {
            lastStockNow = rs.getBigDecimal("stock_now");
        }
        rs.close();
        pt.close();

        if (currentStock.compareTo(qty) >= 0) {
            // Reduce stock in prod_batch
            pt = con.prepareStatement("UPDATE prod_batch SET stock = stock - ? WHERE product_id = ? AND id = ?");
            pt.setBigDecimal(1, qty);
            pt.setInt(2, productId);
            pt.setInt(3, batchId);
            pt.executeUpdate();
            pt.close();

            // Insert into prod_lifecycle with custom notes
            BigDecimal newStockNow = lastStockNow.subtract(qty);
            pt = con.prepareStatement(
                "INSERT INTO prod_lifecycle (batch_id, stock_out, stock_now, notes, DATE, TIME, product_id, uid, bill_id) VALUES (?, ?, ?, ?, NOW(), NOW(), ?, ?, ?)"
            );
            pt.setInt(1, batchId);
            pt.setBigDecimal(2, qty);
            pt.setBigDecimal(3, newStockNow);
            pt.setString(4, notes);
            pt.setInt(5, productId);
            pt.setInt(6, uid);
            pt.setInt(7, billId);
            pt.executeUpdate();
            pt.close();

            con.commit();
        } else {
            // Apply "bill without stock" logic for components too
            pt = con.prepareStatement(
                "INSERT INTO prod_batch_zero_stock_bill (batch_id, qty, date, time, product_id, uid) VALUES (?, ?, NOW(), NOW(), ?, ?)"
            );
            pt.setInt(1, batchId);
            pt.setBigDecimal(2, qty);
            pt.setInt(3, productId);
            pt.setInt(4, uid);
            pt.executeUpdate();
            pt.close();

            pt = con.prepareStatement(
                "INSERT INTO prod_lifecycle (batch_id, stock_out, stock_now, notes, DATE, TIME, product_id, uid, is_zero_stock_bill, bill_id) VALUES (?, ?, ?, ?, NOW(), NOW(), ?, ?, 1, ?)"
            );
            pt.setInt(1, batchId);
            pt.setBigDecimal(2, qty);
            pt.setBigDecimal(3, lastStockNow); // not subtracted
            pt.setString(4, notes + " - BILL WITHOUT STOCK");
            pt.setInt(5, productId);
            pt.setInt(6, uid);
            pt.setInt(7, billId);
            pt.executeUpdate();
            pt.close();

            con.commit();
        }
    } catch (Exception e) {
        if (con != null) {
            try {
                con.rollback();
            } catch (SQLException ex) {
                ;
            }
        }
        throw e;
    } finally {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                ;
            }
            rs = null;
        }

        if (pt != null) {
            try {
                pt.close();
            } catch (SQLException e) {
                ;
            }
            pt = null;
        }

        if (con != null) {
            try {
                con.close();
            } catch (Exception e) {
            }
            con = null;
        }
    }
}
public String getProductHistory(int productId, int customerId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            
            String sql = "SELECT pb.bill_display, pb.date, pb.time, pbd.qty, pbd.price, pbd.disc, pbd.total, pb.cusName " +
                         "FROM prod_bill pb " +
                         "JOIN prod_bill_details pbd ON pb.id = pbd.bill_id " +
                         "WHERE pbd.prod_id = ? " +
                         "AND (pb.is_cancelled IS NULL OR pb.is_cancelled = 0) ";
            
            if (customerId > 0) {
                sql += "AND pb.customerId = ? ";
            }
            
            sql += "ORDER BY pb.date DESC, pb.time DESC LIMIT 6";
            
            ps = con.prepareStatement(sql);
            ps.setInt(1, productId);
            
            if (customerId > 0) {
                ps.setInt(2, customerId);
            }
            
            rs = ps.executeQuery();
            
            StringBuilder json = new StringBuilder("[");
            boolean first = true;
            
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;
                
                json.append("{");
                json.append("\"billNo\":\"").append(rs.getString("bill_display")).append("\",");
                json.append("\"date\":\"").append(rs.getString("date")).append("\",");
                json.append("\"time\":\"").append(rs.getString("time")).append("\",");
                json.append("\"qty\":").append(rs.getBigDecimal("qty")).append(",");
                json.append("\"price\":").append(rs.getDouble("price")).append(",");
                json.append("\"discount\":").append(rs.getDouble("disc")).append(",");
                json.append("\"total\":").append(rs.getDouble("total")).append(",");
                String cusName = rs.getString("cusName");
                json.append("\"customerName\":\"").append(cusName != null ? cusName : "-").append("\"");
                json.append("}");
            }
            
            json.append("]");
            return json.toString();
            
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { ; }
                rs = null;
            }
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { ; }
                ps = null;
            }
            if (con != null) {
                try { con.close(); } catch (SQLException e) { ; }
                con = null;
            }
        }
    }

    public String checkOverdueDues(int customerId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            
            // Check for bills with outstanding balance older than 10 days
            String sql = "SELECT bill_display, date, currentBalance " +
                         "FROM prod_bill " +
                         "WHERE customerId = ? " +
                         "AND currentBalance > 0 " +
                         "AND DATEDIFF(CURDATE(), date) > 10 " +
                         "AND (is_cancelled IS NULL OR is_cancelled = 0) " +
                         "ORDER BY date ASC";
            
            ps = con.prepareStatement(sql);
            ps.setInt(1, customerId);
            
            rs = ps.executeQuery();
            
            StringBuilder overdueDetails = new StringBuilder();
            double totalOverdue = 0;
            int count = 0;
            
            while (rs.next()) {
                if (count > 0) overdueDetails.append(", ");
                overdueDetails.append(rs.getString("bill_display"))
                             .append(" (")
                             .append(rs.getString("date"))
                             .append(" - ₹")
                             .append(String.format("%.2f", rs.getDouble("currentBalance")))
                             .append(")");
                totalOverdue += rs.getDouble("currentBalance");
                count++;
            }
            
            StringBuilder json = new StringBuilder("{");
            if (count > 0) {
                String message = "Customer has " + count + " overdue bill(s) with pending amount of ₹" + 
                               String.format("%.2f", totalOverdue) + ".<br><br>" +
                               "Bills: " + overdueDetails.toString() + 
                               "<br><br>Please clear pending dues before creating new bills.";
                json.append("\"hasOverdue\":true,\"message\":\"")
                    .append(message.replace("\"", "\\\""))
                    .append("\"}");
            } else {
                json.append("\"hasOverdue\":false,\"message\":\"\"}");
            }
            
            return json.toString();
            
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { ; }
                rs = null;
            }
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { ; }
                ps = null;
            }
            if (con != null) {
                try { con.close(); } catch (SQLException e) { ; }
                con = null;
            }
        }
    }

    public String checkDueCheques() throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            
            // Check if there are bills created today
            String checkTodayBills = "SELECT COUNT(*) as count FROM prod_bill WHERE DATE(DATE) = CURDATE()";
            ps = con.prepareStatement(checkTodayBills);
            rs = ps.executeQuery();
            
            boolean hasBillsToday = false;
            if (rs.next()) {
                hasBillsToday = rs.getInt("count") > 0;
            }
            rs.close();
            ps.close();
            
            // If bills exist today, no need to check due cheques
            if (hasBillsToday) {
                return "{\"hasBillsToday\":true,\"hasDueCheques\":false}";
            }
            
            // Get credit_days from credit_days table
            int creditDaysValue = 0;
            String getCreditDaysSql = "SELECT credit_days FROM credit_days LIMIT 1";
            ps = con.prepareStatement(getCreditDaysSql);
            rs = ps.executeQuery();
            if (rs.next()) {
                creditDaysValue = rs.getInt("credit_days");
            }
            rs.close();
            ps.close();
            
            // Check for due cheques from both tables
            // Customer cheques
            String customerChequesSql = "SELECT COUNT(*) AS COUNT FROM prod_cheque_allocation WHERE STATUS = 'ALLOCATED' "
										+"	AND (DATE_ADD(allocated_date, INTERVAL ?-1 DAY) = CURDATE() OR DATE_ADD(allocated_date, INTERVAL ? DAY) = CURDATE());";
            ps = con.prepareStatement(customerChequesSql);
            ps.setInt(1, creditDaysValue);
            ps.setInt(2, creditDaysValue);
            rs = ps.executeQuery();
            
            int customerDueCount = 0;
            if (rs.next()) {
                customerDueCount = rs.getInt("count");
            }
            rs.close();
            ps.close();
            
            // Supplier cheques
            String supplierChequesSql = "SELECT COUNT(*) AS COUNT FROM prod_supplier_cheque_allocation WHERE STATUS = 'ALLOCATED' "
									+"	AND (DATE_ADD(allocated_date, INTERVAL ?-1 DAY) = CURDATE() OR DATE_ADD(allocated_date, INTERVAL ? DAY) = CURDATE());";
            ps = con.prepareStatement(supplierChequesSql);
            ps.setInt(1, creditDaysValue);
            ps.setInt(2, creditDaysValue);
            rs = ps.executeQuery();
            
            int supplierDueCount = 0;
            if (rs.next()) {
                supplierDueCount = rs.getInt("count");
            }
            
            boolean hasDueCheques = (customerDueCount + supplierDueCount) > 0;
            
            return "{\"hasBillsToday\":false,\"hasDueCheques\":" + hasDueCheques + "}";
            
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { ; }
                rs = null;
            }
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { ; }
                ps = null;
            }
            if (con != null) {
                try { con.close(); } catch (SQLException e) { ; }
                con = null;
            }
        }
    }

    public String getDueChequesList() throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            
            // Get credit_days from credit_days table
            int creditDaysValue = 0;
            String getCreditDaysSql = "SELECT credit_days FROM credit_days LIMIT 1";
            ps = con.prepareStatement(getCreditDaysSql);
            rs = ps.executeQuery();
            if (rs.next()) {
                creditDaysValue = rs.getInt("credit_days");
            }
            rs.close();
            ps.close();
            
            StringBuilder json = new StringBuilder("[");
            boolean first = true;
            
            // Get customer cheques due today
            String customerChequesSql = "SELECT pca.cheque_id, pcs.cheque_number, pca.allocated_date, " +
                                       "? as credit_days, pca.allocated_amount, pc.name " +
                                       "FROM prod_cheque_allocation pca " +
                                       "JOIN prod_cheque_stock pcs ON pca.cheque_id = pcs.id " +
                                       "JOIN customers pc ON pcs.customer_id = pc.id " +
                                       "WHERE pca.status = 'ALLOCATED' " +
                                       "AND (DATE_ADD(pca.allocated_date, INTERVAL ?-1 DAY) = CURDATE() OR DATE_ADD(pca.allocated_date, INTERVAL ? DAY) = CURDATE()) " +
                                       "ORDER BY pca.allocated_date ASC";
            
            ps = con.prepareStatement(customerChequesSql);
            ps.setInt(1, creditDaysValue);
            ps.setInt(2, creditDaysValue);
            ps.setInt(3, creditDaysValue);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;
                
                json.append("{")
                    .append("\"type\":\"customer\",")
                    .append("\"chequeId\":").append(rs.getInt("cheque_id")).append(",")
                    .append("\"chequeNumber\":\"").append(rs.getString("cheque_number")).append("\",")
                    .append("\"name\":\"").append(rs.getString("name")).append("\",")
                    .append("\"allocatedDate\":\"").append(rs.getString("allocated_date")).append("\",")
                    .append("\"creditDays\":").append(rs.getInt("credit_days")).append(",")
                    .append("\"amount\":").append(rs.getDouble("allocated_amount"))
                    .append("}");
            }
            rs.close();
            ps.close();
            
            // Get supplier cheques due today
            String supplierChequesSql = "SELECT psca.cheque_id, pscs.cheque_number, psca.allocated_date, " +
                                       "? as credit_days, psca.allocated_amount, ps.name " +
                                       "FROM prod_supplier_cheque_allocation psca " +
                                       "JOIN prod_supplier_cheque_stock pscs ON psca.cheque_id = pscs.id " +
                                       "JOIN prod_supplier ps ON pscs.supplier_id = ps.id " +
                                       "WHERE psca.status = 'ALLOCATED' " +
                                       "AND (DATE_ADD(psca.allocated_date, INTERVAL ?-1 DAY) = CURDATE() OR DATE_ADD(psca.allocated_date, INTERVAL ? DAY) = CURDATE()) " +
                                       "ORDER BY psca.allocated_date ASC";
            
            ps = con.prepareStatement(supplierChequesSql);
            ps.setInt(1, creditDaysValue);
            ps.setInt(2, creditDaysValue);
            ps.setInt(3, creditDaysValue);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;
                
                json.append("{")
                    .append("\"type\":\"supplier\",")
                    .append("\"chequeId\":").append(rs.getInt("cheque_id")).append(",")
                    .append("\"chequeNumber\":\"").append(rs.getString("cheque_number")).append("\",")
                    .append("\"name\":\"").append(rs.getString("name")).append("\",")
                    .append("\"allocatedDate\":\"").append(rs.getString("allocated_date")).append("\",")
                    .append("\"creditDays\":").append(rs.getInt("credit_days")).append(",")
                    .append("\"amount\":").append(rs.getDouble("allocated_amount"))
                    .append("}");
            }
            
            json.append("]");
            return json.toString();
            
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { ; }
                rs = null;
            }
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { ; }
                ps = null;
            }
            if (con != null) {
                try { con.close(); } catch (SQLException e) { ; }
                con = null;
            }
        }
    }
    
    // Get top customers by sales for current month
    public Vector getTopCustomers() throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector result = new Vector();
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            String sql = "SELECT c.name, SUM(pb.payable) as total_sales, COUNT(pb.id) as bill_count " +
                         "FROM prod_bill pb " +
                         "JOIN customers c ON pb.customerId = c.id " +
                         "WHERE pb.is_cancelled = 0 AND MONTH(pb.date) = MONTH(CURDATE()) AND YEAR(pb.date) = YEAR(CURDATE()) " +
                         "GROUP BY c.id, c.name " +
                         "ORDER BY total_sales DESC LIMIT 5";
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Vector row = new Vector();
                row.add(rs.getString("name"));
                row.add(rs.getDouble("total_sales"));
                row.add(rs.getInt("bill_count"));
                result.add(row);
            }
            
            return result;
            
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { ; }
                rs = null;
            }
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { ; }
                ps = null;
            }
            if (con != null) {
                try { con.close(); } catch (SQLException e) { ; }
                con = null;
            }
        }
    }
    
    // Get top suppliers by purchase for current month
    public Vector getTopSuppliers() throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector result = new Vector();
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            String sql = "SELECT ps.name, SUM(pp.net) as total_purchase, COUNT(pp.id) as purchase_count " +
                         "FROM prod_purchase pp " +
                         "JOIN prod_supplier ps ON pp.deal_id = ps.id " +
                         "WHERE pp.is_cancelled = 0 AND MONTH(pp.invdate) = MONTH(CURDATE()) AND YEAR(pp.invdate) = YEAR(CURDATE()) AND pp.is_po=0 " +
                         "GROUP BY ps.id, ps.name " +
                         "ORDER BY total_purchase DESC LIMIT 5";
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Vector row = new Vector();
                row.add(rs.getString("name"));
                row.add(rs.getDouble("total_purchase"));
                row.add(rs.getInt("purchase_count"));
                result.add(row);
            }
            
            return result;
            
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { ; }
                rs = null;
            }
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { ; }
                ps = null;
            }
            if (con != null) {
                try { con.close(); } catch (SQLException e) { ; }
                con = null;
            }
        }
    }
    
    // Get top customers with outstanding balances
    public Vector getOutstandingCustomers() throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector result = new Vector();
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            String sql = "SELECT c.name, SUM(pb.balance) AS outstanding ,SUM(pb.currentBalance) AS currentOutstanding "
						+"	FROM prod_bill pb  "
						+"	JOIN customers c ON pb.customerId = c.id  "
						+"	WHERE pb.is_cancelled = 0  AND pb.currentBalance>0 "
						+"	GROUP BY c.id, c.name "
						+"	ORDER BY currentOutstanding DESC LIMIT 5";
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Vector row = new Vector();
                row.add(rs.getString("name"));
                row.add(rs.getDouble("outstanding"));
                row.add(rs.getDouble("currentOutstanding"));
                result.add(row);
            }
            
            return result;
            
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { ; }
                rs = null;
            }
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { ; }
                ps = null;
            }
            if (con != null) {
                try { con.close(); } catch (SQLException e) { ; }
                con = null;
            }
        }
    }
    
    // Get top suppliers with outstanding balances
    public Vector getOutstandingSuppliers() throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector result = new Vector();
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            String sql = "SELECT ps.name, SUM(psp.balance) AS outstanding "
						+"	FROM prod_purchase_supplier_payment psp "
						+"	JOIN prod_purchase pur ON pur.id = psp.prid "
						+"	JOIN prod_supplier ps ON psp.deal_id = ps.id "
						+"	WHERE pur.is_cancelled = 0 AND (psp.balance) > 0 "
						+"	GROUP BY ps.id, ps.name "
						+"	ORDER BY outstanding DESC LIMIT 5;";
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            
            while (rs.next()) {
                Vector row = new Vector();
                row.add(rs.getString("name"));
                row.add(rs.getDouble("outstanding"));
                result.add(row);
            }
            
            return result;
            
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { ; }
                rs = null;
            }
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { ; }
                ps = null;
            }
            if (con != null) {
                try { con.close(); } catch (SQLException e) { ; }
                con = null;
            }
        }
    }
    
    // Get available cheques for a customer
    public String getAvailableChequesForCustomer(int customerId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        StringBuilder json = new StringBuilder("[");
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            
            String sql = "SELECT pcs.id, pcs.cheque_number, pcs.entry_date, pcs.bank_name, pcs.status " +
                         "FROM prod_cheque_stock pcs " +
                         "WHERE pcs.customer_id = ? AND pcs.status = 'AVAILABLE' " +
                         "ORDER BY pcs.entry_date ASC";
            
            ps = con.prepareStatement(sql);
            ps.setInt(1, customerId);
            rs = ps.executeQuery();
            
            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;
                
                json.append("{")
                    .append("\"id\":").append(rs.getInt("id")).append(",")
                    .append("\"chequeNumber\":\"").append(rs.getString("cheque_number")).append("\",")
                    .append("\"chequeDate\":\"").append(rs.getString("entry_date")).append("\",")
                    
                    .append("\"bankName\":\"").append(rs.getString("bank_name") != null ? rs.getString("bank_name") : "").append("\",")
                    .append("\"status\":\"").append(rs.getString("status")).append("\"")
                    .append("}");
            }
            
            json.append("]");
            return json.toString();
            
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { ; }
                rs = null;
            }
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { ; }
                ps = null;
            }
            if (con != null) {
                try { con.close(); } catch (SQLException e) { ; }
                con = null;
            }
        }
    }
    
    // Check if user has special permission
    public boolean checkUserSpecialPermission(int userId, int contentId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            
            String sql = "SELECT COUNT(*) as count FROM user_special_permission " +
                         "WHERE user_id = ? AND content_id = ?";
            
            ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, contentId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
            
            return false;
            
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { ; }
                rs = null;
            }
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { ; }
                ps = null;
            }
            if (con != null) {
                try { con.close(); } catch (SQLException e) { ; }
                con = null;
            }
        }
    }
    
    // Get total available stock for a product from prod_batch table
    public double getProductStock(int productId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            
            String sql = "SELECT SUM(stock) as total_stock FROM prod_batch WHERE product_id = ?";
            
            ps = con.prepareStatement(sql);
            ps.setInt(1, productId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getDouble("total_stock");
            }
            
            return 0;
            
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { ; }
                rs = null;
            }
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { ; }
                ps = null;
            }
            if (con != null) {
                try { con.close(); } catch (SQLException e) { ; }
                con = null;
            }
        }
    }
    
    // Update LR details for a bill
    public void updateLRDetails(String billNo, String lrNo, String lrDate, String lrName) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            
            String sql = "UPDATE prod_bill SET lr_no = ?, lr_date = ?, lr_name = ? WHERE bill_display = ?";
            
            System.out.println("Executing SQL: " + sql);
            System.out.println("Parameters: lrNo=" + lrNo + ", lrDate=" + lrDate + ", lrName=" + lrName + ", billNo=" + billNo);
            
            ps = con.prepareStatement(sql);
            ps.setString(1, lrNo);
            
            if (lrDate != null && !lrDate.trim().isEmpty()) {
                ps.setString(2, lrDate);
            } else {
                ps.setNull(2, java.sql.Types.DATE);
            }
            
            ps.setString(3, lrName);
            ps.setString(4, billNo);
            
            int rowsAffected = ps.executeUpdate();
            System.out.println("Rows affected: " + rowsAffected);
            
            if (rowsAffected == 0) {
                throw new Exception("No bill found with bill number: " + billNo);
            }
            
            // Commit the transaction
            con.commit();
            System.out.println("Transaction committed successfully");
            
        } catch (Exception e) {
            // Rollback on error
            if (con != null) {
                try { con.rollback(); } catch (SQLException ex) { ; }
            }
            throw e;
        } finally {
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { ; }
                ps = null;
            }
            if (con != null) {
                try { con.close(); } catch (SQLException e) { ; }
                con = null;
            }
        }
    }
    
    // Get LR details for a bill
    public Vector getLRDetails(String billNo) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector lrDetails = new Vector();
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            String sql = "SELECT lr_no, lr_date, lr_name FROM prod_bill WHERE bill_display = ?";
            ps = con.prepareStatement(sql);
            ps.setString(1, billNo);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                lrDetails.add(rs.getString("lr_no"));
                lrDetails.add(rs.getString("lr_date"));
                lrDetails.add(rs.getString("lr_name"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { ; }
                rs = null;
            }
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { ; }
                ps = null;
            }
            if (con != null) {
                try { con.close(); } catch (SQLException e) { ; }
                con = null;
            }
        }
        
        return lrDetails;
    }
    
//////////////////////////////////////////////////////
// QUOTATION METHODS
public String saveQuotation(List<ProductItem> items, String customerName, String customerPhn,
                            int customerId, double finalDiscount, double payableAmount, 
                            double grandTotal, int uid, double priceTotal, double discountTotal) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    int quotId = 0;
    String quotNo = null;
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);
        
        // Generate quotation number
        java.util.Calendar cal = java.util.Calendar.getInstance();
        int year = cal.get(java.util.Calendar.YEAR) % 100;
        
        String getLastIdSQL = "SELECT MAX(id) AS maxId FROM prod_quotation WHERE YEAR(date) = YEAR(CURDATE())";
        ps = con.prepareStatement(getLastIdSQL);
        rs = ps.executeQuery();
        
        int nextId = 1;
        if (rs.next() && rs.getInt("maxId") != 0) {
            nextId = rs.getInt("maxId") + 1;
        }
        
        quotNo = "Q" + year + "-" + nextId;
        rs.close();
        ps.close();
        
        // Insert quotation header
        String sql = "INSERT INTO prod_quotation (bill_display, total, prodDisc, extraDisc, payable, " +
                     "cusName, cusPhn, customerId, date, time, uid, is_billed, is_cancelled) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW(), ?, 0, 0)";
        
        ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
        ps.setString(1, quotNo);
        ps.setDouble(2, priceTotal);
        ps.setDouble(3, discountTotal);
        ps.setDouble(4, finalDiscount);
        ps.setDouble(5, payableAmount);
        ps.setString(6, customerName);
        ps.setString(7, customerPhn);
        if (customerId > 0) {
            ps.setInt(8, customerId);
        } else {
            ps.setNull(8, java.sql.Types.INTEGER);
        }
        ps.setInt(9, uid);
        ps.executeUpdate();
        
        rs = ps.getGeneratedKeys();
        if (rs.next()) {
            quotId = rs.getInt(1);
        }
        rs.close();
        ps.close();
        
        // Insert quotation details
        String sqlDetail = "INSERT INTO prod_quotation_details (quot_id, prod_id, qty, price, disc, total, gst, is_cancelled) " +
                          "VALUES (?, ?, ?, ?, ?, ?, ?, 0)";
        ps = con.prepareStatement(sqlDetail);
        
        for (ProductItem item : items) {
            ps.setInt(1, quotId);
            ps.setInt(2, item.productId);
            ps.setBigDecimal(3, item.qty);
            ps.setDouble(4, item.price);
            ps.setDouble(5, item.discount);
            ps.setDouble(6, item.total);
            ps.setInt(7, item.gst);
            ps.addBatch();
        }
        
        ps.executeBatch();
        ps.close();
        
        con.commit();
        
    } catch (Exception e) {
        if (con != null) con.rollback();
        throw e;
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (con != null) con.close();
    }
    
    return quotNo + "|" + quotId;
}

public Vector getQuotationList() throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector quotList = new Vector();
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String sql = "SELECT id, bill_display, cusName, cusPhn, payable, date, time " +
                     "FROM prod_quotation " +
                     "WHERE is_cancelled = 0 AND is_billed = 0 " +
                     "ORDER BY date DESC, time DESC";
        
        ps = con.prepareStatement(sql);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            Vector row = new Vector();
            row.add(rs.getInt("id"));
            row.add(rs.getString("bill_display"));
            row.add(rs.getString("cusName"));
            row.add(rs.getString("cusPhn"));
            row.add(rs.getDouble("payable"));
            row.add(rs.getDate("date"));
            row.add(rs.getTime("time"));
            quotList.add(row);
        }
        
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (con != null) con.close();
    }
    
    return quotList;
}

public Map<String, Object> getSalesStatistics(String fromDate, String toDate, String categoryId, String brandId, String productId) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        // Build dynamic WHERE clause
        StringBuilder whereClause = new StringBuilder();
        whereClause.append("WHERE pb.is_cancelled = 0 AND pb.date BETWEEN ? AND ? ");
        
        List<Object> params = new ArrayList<Object>();
        params.add(fromDate);
        params.add(toDate);
        
        if (categoryId != null && !categoryId.trim().isEmpty()) {
            whereClause.append("AND pp.category_id = ? ");
            params.add(Integer.parseInt(categoryId));
        }
        
        if (brandId != null && !brandId.trim().isEmpty()) {
            whereClause.append("AND pp.brand_id = ? ");
            params.add(Integer.parseInt(brandId));
        }
        
        if (productId != null && !productId.trim().isEmpty()) {
            whereClause.append("AND pp.id = ? ");
            params.add(Integer.parseInt(productId));
        }
        
        // Get summary statistics
        String summarySQL = "SELECT " +
            "COUNT(DISTINCT pb.id) as totalBills, " +
            "SUM(pbd.total) as totalSales, " +
            "SUM(pbd.qty) as totalQty " +
            "FROM prod_bill pb " +
            "INNER JOIN prod_bill_details pbd ON pb.id = pbd.bill_id " +
            "INNER JOIN prod_product pp ON pbd.prod_id = pp.id " +
            whereClause.toString();
        
        ps = con.prepareStatement(summarySQL);
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
        
        rs = ps.executeQuery();
        
        int totalBills = 0;
        double totalSales = 0;
        double totalQty = 0;
        double avgBill = 0;
        
        if (rs.next()) {
            totalBills = rs.getInt("totalBills");
            totalSales = rs.getDouble("totalSales");
            totalQty = rs.getDouble("totalQty");
            if (totalBills > 0) {
                avgBill = totalSales / totalBills;
            }
        }
        rs.close();
        ps.close();
        
        // Get detailed records
        String detailSQL = "SELECT " +
            "pb.bill_display as billNo, " +
            "DATE_FORMAT(pb.date, '%d-%m-%Y') as date, " +
            "pp.name as productName, " +
            "pc.name as categoryName, " +
            "pbr.name as brandName, " +
            "pbd.qty, " +
            "pbd.price, " +
            "pbd.disc, " +
            "pbd.total " +
            "FROM prod_bill pb " +
            "INNER JOIN prod_bill_details pbd ON pb.id = pbd.bill_id " +
            "INNER JOIN prod_product pp ON pbd.prod_id = pp.id " +
            "INNER JOIN prod_category pc ON pp.category_id = pc.id " +
            "INNER JOIN prod_brands pbr ON pp.brand_id = pbr.id " +
            whereClause.toString() +
            "ORDER BY pb.date DESC, pb.id DESC " +
            "LIMIT 500";
        
        ps = con.prepareStatement(detailSQL);
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
        
        rs = ps.executeQuery();
        
        Vector details = new Vector();
        while (rs.next()) {
            Map<String, Object> row = new HashMap<String, Object>();
            row.put("billNo", rs.getString("billNo"));
            row.put("date", rs.getString("date"));
            row.put("productName", rs.getString("productName"));
            row.put("categoryName", rs.getString("categoryName"));
            row.put("brandName", rs.getString("brandName"));
            row.put("qty", rs.getDouble("qty"));
            row.put("price", rs.getDouble("price"));
            row.put("disc", rs.getDouble("disc"));
            row.put("total", rs.getDouble("total"));
            details.add(row);
        }
        
        // Build response
        Map<String, Object> response = new HashMap<String, Object>();
        response.put("totalBills", totalBills);
        response.put("totalSales", String.format("%.2f", totalSales));
        response.put("totalQty", String.format("%.2f", totalQty));
        response.put("avgBill", String.format("%.2f", avgBill));
        response.put("details", details);
        
        return response;
        
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (con != null) con.close();
    }
}

public Vector getQuotationHeader(int quotId) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector header = new Vector();
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String sql = "SELECT bill_display, total, prodDisc, extraDisc, payable, " +
                     "cusName, cusPhn, customerId, date, time " +
                     "FROM prod_quotation WHERE id = ?";
        
        ps = con.prepareStatement(sql);
        ps.setInt(1, quotId);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            header.add(rs.getString("bill_display"));
            header.add(rs.getDouble("total"));
            header.add(rs.getDouble("prodDisc"));
            header.add(rs.getDouble("extraDisc"));
            header.add(rs.getDouble("payable"));
            header.add(rs.getString("cusName"));
            header.add(rs.getString("cusPhn"));
            header.add(rs.getInt("customerId"));
            header.add(rs.getDate("date"));
            header.add(rs.getTime("time"));
        }
        
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (con != null) con.close();
    }
    
    return header;
}

public Vector getQuotationDetails(int quotId) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector details = new Vector();
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String sql = "SELECT d.id, d.prod_id, p.name AS prod_name, p.code, " +
                     "d.qty, d.price, d.disc, d.total, d.gst " +
                     "FROM prod_quotation_details d " +
                     "JOIN prod_product p ON p.id = d.prod_id " +
                     "WHERE d.quot_id = ? AND d.is_cancelled = 0";
        
        ps = con.prepareStatement(sql);
        ps.setInt(1, quotId);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            Vector row = new Vector();
            row.add(rs.getInt("id"));
            row.add(rs.getInt("prod_id"));
            row.add(rs.getString("prod_name"));
            row.add(rs.getString("code"));
            row.add(rs.getBigDecimal("qty"));
            row.add(rs.getDouble("price"));
            row.add(rs.getDouble("disc"));
            row.add(rs.getDouble("total"));
            row.add(rs.getInt("gst"));
            details.add(row);
        }
        
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (con != null) con.close();
    }
    
    return details;
}

public void cancelQuotation(int quotId) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);
        
        String sql = "UPDATE prod_quotation SET is_cancelled = 1 WHERE id = ?";
        ps = con.prepareStatement(sql);
        ps.setInt(1, quotId);
        ps.executeUpdate();
        
        con.commit();
        
    } catch (Exception e) {
        if (con != null) con.rollback();
        throw e;
    } finally {
        if (ps != null) ps.close();
        if (con != null) con.close();
    }
}

public void markQuotationAsBilled(int quotId) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);
        
        String sql = "UPDATE prod_quotation SET is_billed = 1 WHERE id = ?";
        ps = con.prepareStatement(sql);
        ps.setInt(1, quotId);
        ps.executeUpdate();
        
        con.commit();
        
    } catch (Exception e) {
        if (con != null) con.rollback();
        throw e;
    } finally {
        if (ps != null) ps.close();
        if (con != null) con.close();
    }
}

//////////////////////////////////////////////////////
// ATTENDER SALES REPORT
//////////////////////////////////////////////////////

/**
 * Get attender-wise sales report
 * @param from Start date
 * @param to End date
 * @param attenderId 0 for all attenders, specific ID for individual attender
 * @return Vector of sales data
 */
public Vector getAttenderWiseSalesReport(String from, String to, int attenderId) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();
        
        String sql = "SELECT " +
                     "a.bill_display, " +
                     "a.total, " +
                     "a.prodDisc + a.extraDisc AS discount, " +
                     "a.payable, " +
                     "a.paid, " +
                     "a.date, " +
                     "a.time, " +
                     "a.cusName, " +
                     "a.currentBalance, " +
                     "IFNULL(att.name, 'No Attender') AS attender_name " +
                     "FROM prod_bill a " +
                     "LEFT JOIN attender att ON att.id = a.attender_id " +
                     "WHERE a.is_cancelled = 0 AND a.date BETWEEN ? AND ? ";
        
        if (attenderId > 0) {
            sql += "AND a.attender_id = ? ";
        }
        
        sql += "ORDER BY a.date DESC, a.time DESC";
        
        pt = con.prepareStatement(sql);
        pt.setString(1, from);
        pt.setString(2, to);
        
        if (attenderId > 0) {
            pt.setInt(3, attenderId);
        }
        
        rs = pt.executeQuery();
        
        while (rs.next()) {
            Vector vec1 = new Vector();
            vec1.addElement(rs.getString("bill_display"));    // 0
            vec1.addElement(rs.getDouble("total"));           // 1
            vec1.addElement(rs.getDouble("discount"));        // 2
            vec1.addElement(rs.getDouble("payable"));         // 3
            vec1.addElement(rs.getDouble("paid"));            // 4
            vec1.addElement(rs.getString("date"));            // 5
            vec1.addElement(rs.getString("time"));            // 6
            vec1.addElement(rs.getString("cusName"));         // 7
            vec1.addElement(rs.getDouble("currentBalance")); // 8
            vec1.addElement(rs.getString("attender_name"));   // 9
            vec.addElement(vec1);
        }
        
        return vec;
    } finally {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) { ; }
            rs = null;
        }
        if (pt != null) {
            try { pt.close(); } catch (SQLException e) { ; }
            pt = null;
        }
        if (con != null) {
            try { con.close(); } catch (Exception e) {}
            con = null;
        }
    }
}

//////////////////////////////////////////////////////

/**
 * Fetch payment details of a bill by its display number.
 * Returns a Vector with the following elements (all Strings/doubles):
 *   0 - bill id (int)
 *   1 - bill_display (String)
 *   2 - date (String)
 *   3 - cusName (String)
 *   4 - payable (double)
 *   5 - paymentMode (int)
 *   6 - paymentType (int)
 *   7 - cash (double)
 *   8 - bank (double)
 * Returns empty Vector if not found or cancelled.
 */
public Vector getBillPaymentInfo(String billNo) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String sql =
            "SELECT a.id, a.bill_display, a.date, IFNULL(a.cusName,'') AS cusName, " +
            "       a.payable, a.paymentMode, a.paymentType, " +
            "       IFNULL(b.cash, 0) AS cash, IFNULL(b.bank, 0) AS bank " +
            "FROM prod_bill a " +
            "LEFT JOIN prod_bill_payment b ON b.bill_id = a.id " +
            "WHERE a.bill_display = ? AND a.is_cancelled = 0 " +
            "LIMIT 1";
        ps = con.prepareStatement(sql);
        ps.setString(1, billNo);
        rs = ps.executeQuery();
        if (rs.next()) {
            vec.addElement(rs.getInt("id"));             // 0
            vec.addElement(rs.getString("bill_display")); // 1
            vec.addElement(rs.getString("date"));         // 2
            vec.addElement(rs.getString("cusName"));      // 3
            vec.addElement(rs.getDouble("payable"));      // 4
            vec.addElement(rs.getInt("paymentMode"));     // 5
            vec.addElement(rs.getInt("paymentType"));     // 6
            vec.addElement(rs.getDouble("cash"));         // 7
            vec.addElement(rs.getDouble("bank"));         // 8
        }
        return vec;
    } finally {
        if (rs  != null) try { rs.close();  } catch (SQLException e) { ; }
        if (ps  != null) try { ps.close();  } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e)   { ; }
    }
}

/**
 * Update the payment type / amounts for a bill.
 * - Updates prod_bill_payment (cash, bank, paymentType)
 * - Updates prod_bill (paymentMode, paymentType, paid)
 * - Inserts audit row into prod_bill_payment_type_change
 *
 * @param billId   internal bill id
 * @param cash     new cash amount
 * @param bank     new bank amount
 * @param bankMode payment type id (1=UPI, 2=Debit, 3=Credit, 4=Net Banking, 5=Wallet)
 * @param uid      logged-in user id
 * @throws Exception on any DB error (caller should handle rollback messaging)
 */
public void updateBillPaymentType(int billId, double cash, double bank, int bankMode, int uid) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);

        // Fetch old values for audit
        ps = con.prepareStatement(
            "SELECT IFNULL(b.cash,0), IFNULL(b.bank,0) " +
            "FROM prod_bill a " +
            "LEFT JOIN prod_bill_payment b ON b.bill_id = a.id " +
            "WHERE a.id = ? AND a.is_cancelled = 0 LIMIT 1");
        ps.setInt(1, billId);
        rs = ps.executeQuery();
        if (!rs.next()) {
            throw new Exception("Bill not found or has been cancelled.");
        }
        double oldCash = rs.getDouble(1);
        double oldBank = rs.getDouble(2);
        rs.close(); ps.close();

        // Determine payment mode: 1=Cash, 2=Bank, 3=Mixed
        int paymentMode;
        if (cash > 0 && bank > 0) {
            paymentMode = 3;
        } else if (bank > 0) {
            paymentMode = 2;
        } else {
            paymentMode = 1;
        }
        int paymentType = (bank > 0) ? bankMode : 0;

        // Update prod_bill_payment
        ps = con.prepareStatement(
            "UPDATE prod_bill_payment " +
            "SET cash = ?, bank = ?, paymentType = ? " +
            "WHERE bill_id = ?");
        ps.setDouble(1, cash);
        ps.setDouble(2, bank);
        ps.setInt(3,    paymentType);
        ps.setInt(4,    billId);
        ps.executeUpdate();
        ps.close();

        // Update prod_bill
        ps = con.prepareStatement(
            "UPDATE prod_bill " +
            "SET paymentMode = ?, paymentType = ?, paid = ? " +
            "WHERE id = ?");
        ps.setInt(1,    paymentMode);
        ps.setInt(2,    paymentType);
        ps.setDouble(3, cash + bank);
        ps.setInt(4,    billId);
        ps.executeUpdate();
        ps.close();

        // Audit insert
        ps = con.prepareStatement(
            "INSERT INTO prod_bill_payment_type_change " +
            "(bill_id, old_cash_amount, cash_amount, old_bank_amount, bank_amount, bank_mode, uid, date_time) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, NOW())");
        ps.setInt(1,    billId);
        ps.setDouble(2, oldCash);
        ps.setDouble(3, cash);
        ps.setDouble(4, oldBank);
        ps.setDouble(5, bank);
        if (bank > 0) {
            ps.setInt(6, bankMode);
        } else {
            ps.setNull(6, java.sql.Types.INTEGER);
        }
        ps.setInt(7, uid);
        ps.executeUpdate();
        ps.close();

        con.commit();
    } catch (Exception e) {
        if (con != null) try { con.rollback(); } catch (Exception ignored) { ; }
        throw e;
    } finally {
        if (rs  != null) try { rs.close();  } catch (SQLException e) { ; }
        if (ps  != null) try { ps.close();  } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e)   { ; }
    }
}

/**
 * Fetch payment type change audit report for a date range.
 * Returns a Vector of row Vectors, each containing:
 *   0  - id (int)
 *   1  - bill_id (int)
 *   2  - bill_display (String)
 *   3  - old_cash_amount (double)
 *   4  - cash_amount (double)
 *   5  - old_bank_amount (double)
 *   6  - bank_amount (double)
 *   7  - bank_mode_name (String)  -- type label from prod_bill_payment_type, or "Cash" if null
 *   8  - user_name (String)
 *   9  - date_time (String)
 */
public Vector getPaymentTypeChangeReport(String fromDate, String toDate) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String sql =
            "SELECT c.id, c.bill_id, b.bill_display, " +
            "       c.old_cash_amount, c.cash_amount, " +
            "       c.old_bank_amount, c.bank_amount, " +
            "       IFNULL(pt.type, 'Cash') AS bank_mode_name, " +
            "       IFNULL(u.user_name, '') AS user_name, " +
            "       c.date_time " +
            "FROM prod_bill_payment_type_change c " +
            "JOIN prod_bill b ON b.id = c.bill_id " +
            "LEFT JOIN prod_bill_payment_type pt ON pt.id = c.bank_mode " +
            "LEFT JOIN users u ON u.id = c.uid " +
            "WHERE DATE(c.date_time) BETWEEN ? AND ? " +
            "ORDER BY c.date_time DESC";
        ps = con.prepareStatement(sql);
        ps.setString(1, fromDate);
        ps.setString(2, toDate);
        rs = ps.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt("id"));                 // 0
            row.addElement(rs.getInt("bill_id"));            // 1
            row.addElement(rs.getString("bill_display"));    // 2
            row.addElement(rs.getDouble("old_cash_amount")); // 3
            row.addElement(rs.getDouble("cash_amount"));     // 4
            row.addElement(rs.getDouble("old_bank_amount")); // 5
            row.addElement(rs.getDouble("bank_amount"));     // 6
            row.addElement(rs.getString("bank_mode_name"));  // 7
            row.addElement(rs.getString("user_name"));       // 8
            row.addElement(rs.getString("date_time"));       // 9
            vec.add(row);
        }
        return vec;
    } finally {
        if (rs  != null) try { rs.close();  } catch (SQLException e) { ; }
        if (ps  != null) try { ps.close();  } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e)   { ; }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
//  EXCHANGE FEATURE
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Returns bill header info for the exchange page.
 * Result vector: [bill_id, customer_id, total, payable, paid, cusName, billDate]
 */
public Vector getBillHeaderForExchange(String billNo) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String sql = "SELECT id, customerId, total, payable, paid, cusName, date "
                   + "FROM prod_bill WHERE bill_display = ? AND is_cancelled = 0";
        ps = con.prepareStatement(sql);
        ps.setString(1, billNo);
        rs = ps.executeQuery();
        Vector row = new Vector();
        if (rs.next()) {
            row.add(rs.getObject(1)); // bill_id
            row.add(rs.getObject(2)); // customer_id (may be null)
            row.add(rs.getString(3)); // total
            row.add(rs.getString(4)); // payable
            row.add(rs.getString(5)); // paid
            row.add(rs.getString(6) != null ? rs.getString(6) : "-"); // cusName
            row.add(rs.getString(7) != null ? rs.getString(7) : "-"); // date
        }
        return row;
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
}

/**
 * Returns bill item rows for the exchange page.
 * Each row: [detailId, prodId, productName, qty, price, disc, total, isExchanged]
 */
public Vector getBillItemsForExchange(String billNo) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String sql = "SELECT bd.id, bd.prod_id, p.name, bd.qty, bd.price, bd.disc, bd.total, "
                   + "IFNULL(bd.is_exchanged, 0) AS is_exchanged "
                   + "FROM prod_bill b "
                   + "JOIN prod_bill_details bd ON bd.bill_id = b.id "
                   + "JOIN prod_product p ON p.id = bd.prod_id "
                   + "WHERE b.bill_display = ? AND b.is_cancelled = 0 AND bd.is_cancelled = 0";
        ps = con.prepareStatement(sql);
        ps.setString(1, billNo);
        rs = ps.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.add(rs.getString(1)); // detailId
            row.add(rs.getString(2)); // prodId
            row.add(rs.getString(3)); // productName
            row.add(rs.getString(4)); // qty
            row.add(rs.getString(5)); // price
            row.add(rs.getString(6)); // disc
            row.add(rs.getString(7)); // total
            row.add(rs.getString(8)); // isExchanged
            vec.add(row);
        }
        return vec;
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
}

/**
 * Search active products with their MRP for exchange autocomplete.
 * Each row: [prod_id, name, mrp]
 */
public Vector searchProductsForExchange(String term) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String sql = "SELECT p.id, p.name, IFNULL(b.mrp, 0) AS mrp, COALESCE(p.code,'') AS code "
                   + "FROM prod_product p "
                   + "LEFT JOIN prod_batch b ON b.product_id = p.id "
                   + "WHERE p.is_active = 1 AND (p.name LIKE ? OR p.code LIKE ?) "
                   + "GROUP BY p.id, p.name, b.mrp, p.code "
                   + "ORDER BY p.name LIMIT 20";
        ps = con.prepareStatement(sql);
        ps.setString(1, "%" + term + "%");
        ps.setString(2, "%" + term + "%");
        rs = ps.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.add(rs.getString(1)); // prod_id
            row.add(rs.getString(2)); // name
            row.add(rs.getString(3)); // mrp
            row.add(rs.getString(4)); // code
            vec.add(row);
        }
        return vec;
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
}

/**
 * Saves a product exchange on an existing bill.
 *
 * Logic:
 *  - Fetches old prod_bill_details row (must not be cancelled or already exchanged).
 *  - Calculates diff = (newPrice * oldQty) - oldTotal
 *  - If diff < 0 → difference credited as exchange_point to the customer
 *  - Always updates prod_bill total / payable by diff
 *  - Updates prod_bill_details (new prod_id, price, total, is_exchanged=1)
 *  - Inserts into pro_bill_exchange and customers_exchange_point (when customer exists)
 *
 * @return human-readable result message
 */
public String saveExchange(String billNo, int detailId, int newProdId, double newPrice, int uid) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);

        // ── 1. Fetch old detail row ───────────────────────────────────────────
        ps = con.prepareStatement(
            "SELECT bd.id, bd.bill_id, bd.prod_id, bd.qty, bd.price, bd.total, "
          + "IFNULL(bd.is_exchanged, 0) "
          + "FROM prod_bill_details bd "
          + "WHERE bd.id = ? AND bd.is_cancelled = 0");
        ps.setInt(1, detailId);
        rs = ps.executeQuery();
        if (!rs.next()) {
            throw new Exception("Bill detail not found or already cancelled.");
        }
        int    fetchedBillId    = rs.getInt(2);
        int    oldProdId        = rs.getInt(3);
        BigDecimal qty          = rs.getBigDecimal(4);
        double oldItemTotal     = rs.getDouble(6);
        int    alreadyExchanged = rs.getInt(7);
        rs.close(); ps.close();

        if (alreadyExchanged == 1) {
            throw new Exception("This item has already been exchanged.");
        }

        // ── 2. Fetch bill header ──────────────────────────────────────────────
        ps = con.prepareStatement(
            "SELECT id, customerId, total, payable, paid FROM prod_bill "
          + "WHERE bill_display = ? AND is_cancelled = 0");
        ps.setString(1, billNo);
        rs = ps.executeQuery();
        if (!rs.next()) {
            throw new Exception("Bill not found: " + billNo);
        }
        int     billId       = rs.getInt(1);
        int     customerId   = rs.getInt(2);
        boolean hasCustomer  = !rs.wasNull() && customerId > 0;
        double  billTotal    = rs.getDouble(3);
        double  billPayable  = rs.getDouble(4);
        rs.close(); ps.close();

        if (billId != fetchedBillId) {
            throw new Exception("Bill / detail mismatch.");
        }

        // ── 3. Calculate new totals ───────────────────────────────────────────
        double newItemTotal  = new java.math.BigDecimal(newPrice).multiply(qty)
                                   .setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();
        double diff          = new java.math.BigDecimal(newItemTotal - oldItemTotal)
                                   .setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();
        double newBillTotal  = new java.math.BigDecimal(billTotal  + diff)
                                   .setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();
        double newBillPayable= new java.math.BigDecimal(billPayable + diff)
                                   .setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();

        // ── 4. Fetch batch_id for old product ─────────────────────────────────
        int oldBatchId = 0;
        ps = con.prepareStatement(
            "SELECT id FROM prod_batch WHERE product_id = ? ORDER BY id DESC LIMIT 1");
        ps.setInt(1, oldProdId);
        rs = ps.executeQuery();
        if (rs.next()) oldBatchId = rs.getInt(1);
        rs.close(); ps.close();

        // ── 5. Fetch batch_id for new product ─────────────────────────────────
        int newBatchId = 0;
        ps = con.prepareStatement(
            "SELECT id FROM prod_batch WHERE product_id = ? ORDER BY id DESC LIMIT 1");
        ps.setInt(1, newProdId);
        rs = ps.executeQuery();
        if (rs.next()) newBatchId = rs.getInt(1);
        rs.close(); ps.close();

        // ── 6. Restore stock for OLD product (it's being returned) ────────────
        if (oldBatchId > 0) {
            // Add back qty to prod_batch
            ps = con.prepareStatement(
                "UPDATE prod_batch SET stock = stock + ? WHERE id = ?");
            ps.setBigDecimal(1, qty);
            ps.setInt(2, oldBatchId);
            ps.executeUpdate();
            ps.close();

            // Get latest stock_now for old product lifecycle
            BigDecimal oldProdLastStock = BigDecimal.ZERO;
            ps = con.prepareStatement(
                "SELECT stock_now FROM prod_lifecycle WHERE product_id = ? ORDER BY id DESC LIMIT 1");
            ps.setInt(1, oldProdId);
            rs = ps.executeQuery();
            if (rs.next()) oldProdLastStock = rs.getBigDecimal(1);
            rs.close(); ps.close();

            BigDecimal oldProdStockNow = oldProdLastStock.add(qty);

            // Insert lifecycle: stock_in (product returned)
            ps = con.prepareStatement(
                "INSERT INTO prod_lifecycle "
              + "(bill_id, batch_id, product_id, stock_in, stock_out, stock_now, "
              + " notes, date, time, uid, stock_type, stockAdjType) "
              + "VALUES (?, ?, ?, ?, 0, ?, 'PRODUCT EXCHANGE - RETURNED', NOW(), NOW(), ?, 1, 1)");
            ps.setInt(1, billId);
            ps.setInt(2, oldBatchId);
            ps.setInt(3, oldProdId);
            ps.setBigDecimal(4, qty);
            ps.setBigDecimal(5, oldProdStockNow);
            ps.setInt(6, uid);
            ps.executeUpdate();
            ps.close();
        }

        // ── 7. Reduce stock for NEW product (it's being given out) ────────────
        if (newBatchId > 0) {
            // Get current stock of new product's batch
            BigDecimal newProdCurrentStock = BigDecimal.ZERO;
            ps = con.prepareStatement(
                "SELECT stock FROM prod_batch WHERE id = ?");
            ps.setInt(1, newBatchId);
            rs = ps.executeQuery();
            if (rs.next()) newProdCurrentStock = rs.getBigDecimal(1);
            rs.close(); ps.close();

            // Get latest stock_now for new product lifecycle
            BigDecimal newProdLastStock = BigDecimal.ZERO;
            ps = con.prepareStatement(
                "SELECT stock_now FROM prod_lifecycle WHERE product_id = ? ORDER BY id DESC LIMIT 1");
            ps.setInt(1, newProdId);
            rs = ps.executeQuery();
            if (rs.next()) newProdLastStock = rs.getBigDecimal(1);
            rs.close(); ps.close();

            if (newProdCurrentStock.compareTo(qty) >= 0) {
                // Enough stock — deduct normally
                ps = con.prepareStatement(
                    "UPDATE prod_batch SET stock = stock - ? WHERE id = ?");
                ps.setBigDecimal(1, qty);
                ps.setInt(2, newBatchId);
                ps.executeUpdate();
                ps.close();

                BigDecimal newProdStockNow = newProdLastStock.subtract(qty);
                ps = con.prepareStatement(
                    "INSERT INTO prod_lifecycle "
                  + "(bill_id, batch_id, product_id, stock_in, stock_out, stock_now, "
                  + " notes, date, time, uid, stock_type, stockAdjType) "
                  + "VALUES (?, ?, ?, 0, ?, ?, 'PRODUCT EXCHANGE - GIVEN', NOW(), NOW(), ?, 1, 2)");
                ps.setInt(1, billId);
                ps.setInt(2, newBatchId);
                ps.setInt(3, newProdId);
                ps.setBigDecimal(4, qty);
                ps.setBigDecimal(5, newProdStockNow);
                ps.setInt(6, uid);
                ps.executeUpdate();
                ps.close();
            } else {
                // Zero-stock bill record
                ps = con.prepareStatement(
                    "INSERT INTO prod_batch_zero_stock_bill "
                  + "(batch_id, product_id, qty, date, time, uid) "
                  + "VALUES (?, ?, ?, NOW(), NOW(), ?)");
                ps.setInt(1, newBatchId);
                ps.setInt(2, newProdId);
                ps.setBigDecimal(3, qty);
                ps.setInt(4, uid);
                ps.executeUpdate();
                ps.close();

                ps = con.prepareStatement(
                    "INSERT INTO prod_lifecycle "
                  + "(bill_id, batch_id, product_id, stock_in, stock_out, stock_now, "
                  + " notes, date, time, uid, stock_type, is_zero_stock_bill, stockAdjType) "
                  + "VALUES (?, ?, ?, 0, ?, ?, 'PRODUCT EXCHANGE - GIVEN WITHOUT STOCK', NOW(), NOW(), ?, 1, 1, 2)");
                ps.setInt(1, billId);
                ps.setInt(2, newBatchId);
                ps.setInt(3, newProdId);
                ps.setBigDecimal(4, qty);
                ps.setBigDecimal(5, newProdLastStock); // stock not changed
                ps.setInt(6, uid);
                ps.executeUpdate();
                ps.close();
            }
        }

        // ── 8. Update prod_bill_details ───────────────────────────────────────
        ps = con.prepareStatement(
            "UPDATE prod_bill_details SET prod_id = ?, price = ?, disc = 0, total = ?, is_exchanged = 1 "
          + "WHERE id = ?");
        ps.setInt(1, newProdId);
        ps.setDouble(2, newPrice);
        ps.setDouble(3, newItemTotal);
        ps.setInt(4, detailId);
        ps.executeUpdate();
        ps.close();

        // ── 9. Update prod_bill amounts ───────────────────────────────────────
        ps = con.prepareStatement(
            "UPDATE prod_bill SET total = ?, payable = ? WHERE id = ?");
        ps.setDouble(1, newBillTotal);
        ps.setDouble(2, newBillPayable);
        ps.setInt(3, billId);
        ps.executeUpdate();
        ps.close();

        // ── 10. Insert into pro_bill_exchange ─────────────────────────────────
        ps = con.prepareStatement(
            "INSERT INTO pro_bill_exchange (bill_id, customer_id, old_prod_id, new_prod_id, uid, date_time) "
          + "VALUES (?, ?, ?, ?, ?, NOW())");
        ps.setInt(1, billId);
        if (hasCustomer) { ps.setInt(2, customerId); } else { ps.setNull(2, java.sql.Types.INTEGER); }
        ps.setInt(3, oldProdId);
        ps.setInt(4, newProdId);
        ps.setInt(5, uid);
        ps.executeUpdate();
        ps.close();

        // ── 11. Exchange point logic (only when new total is lower) ───────────
        String resultMsg;
        if (diff < 0 && hasCustomer) {
            double exchangePointAmount = Math.abs(diff);

            ps = con.prepareStatement("SELECT IFNULL(exchange_point, 0) FROM customers WHERE id = ?");
            ps.setInt(1, customerId);
            rs = ps.executeQuery();
            double oldPoint = rs.next() ? rs.getDouble(1) : 0;
            rs.close(); ps.close();

            double totalPoint = new java.math.BigDecimal(oldPoint + exchangePointAmount)
                                    .setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();

            ps = con.prepareStatement("UPDATE customers SET exchange_point = ? WHERE id = ?");
            ps.setDouble(1, totalPoint);
            ps.setInt(2, customerId);
            ps.executeUpdate();
            ps.close();

            ps = con.prepareStatement(
                "INSERT INTO customers_exchange_point "
              + "(customer_id, bill_id, old_point, exchange_point, total_point, uid, date_time, notes) "
              + "VALUES (?, ?, ?, ?, ?, ?, NOW(), ?)");
            ps.setInt(1, customerId);
            ps.setInt(2, billId);
            ps.setDouble(3, oldPoint);
            ps.setDouble(4, exchangePointAmount);
            ps.setDouble(5, totalPoint);
            ps.setInt(6, uid);
            ps.setString(7, "Points earned on product exchange (Bill: " + billNo + ")");
            ps.executeUpdate();
            ps.close();

            resultMsg = "Exchange completed. Customer earned ₹" + String.format("%.2f", exchangePointAmount)
                      + " exchange points. Total points: ₹" + String.format("%.2f", totalPoint);

        } else if (diff > 0) {
            resultMsg = "Exchange completed. Bill amount increased by ₹" + String.format("%.2f", diff);
        } else {
            resultMsg = "Exchange completed. Same amount — no change to bill or points.";
        }

        con.commit();
        return resultMsg;

    } catch (Exception e) {
        if (con != null) { try { con.rollback(); } catch (Exception ex) { ; } }
        throw e;
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
}

/**
 * Processes a product return on an existing bill.
 *
 * Logic:
 *  - Fetches prod_bill_details row (must be active, not cancelled/exchanged/returned).
 *  - Restores stock for the returned product (prod_batch.stock += qty).
 *  - Inserts prod_lifecycle row (stock_in, stockAdjType=1).
 *  - Reduces bill total and payable by item total.
 *  - Marks prod_bill_details.is_exchanged = 2 (returned).
 *  - Inserts into pro_bill_exchange (old_prod_id = new_prod_id = same product to denote return).
 *  - Credits item total as exchange_point to the customer (if linked).
 *  - Inserts into customers_exchange_point ledger.
 *
 * @return human-readable result message
 */
public String saveReturn(String billNo, int detailId, double returnQty, int uid) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);

        // ── 1. Fetch detail row ───────────────────────────────────────────────
        ps = con.prepareStatement(
            "SELECT bd.id, bd.bill_id, bd.prod_id, bd.qty, bd.total, "
          + "IFNULL(bd.is_exchanged, 0) "
          + "FROM prod_bill_details bd "
          + "WHERE bd.id = ? AND bd.is_cancelled = 0");
        ps.setInt(1, detailId);
        rs = ps.executeQuery();
        if (!rs.next()) {
            throw new Exception("Bill detail not found or already cancelled.");
        }
        int        fetchedBillId  = rs.getInt(2);
        int        prodId         = rs.getInt(3);
        BigDecimal totalQty       = rs.getBigDecimal(4);
        double     itemTotal      = rs.getDouble(5);
        int        currentStatus  = rs.getInt(6);
        rs.close(); ps.close();

        if (currentStatus == 1) throw new Exception("This item has already been exchanged.");
        if (currentStatus == 2) throw new Exception("This item has already been returned.");

        BigDecimal retQty = new BigDecimal(returnQty).setScale(3, java.math.RoundingMode.HALF_UP);
        if (retQty.compareTo(BigDecimal.ZERO) <= 0)
            throw new Exception("Return quantity must be greater than zero.");
        if (retQty.compareTo(totalQty) > 0)
            throw new Exception("Return quantity (" + retQty + ") exceeds bill quantity (" + totalQty + ").");

        // Proportional amount to return
        double retAmount = new java.math.BigDecimal(itemTotal)
            .multiply(retQty)
            .divide(totalQty, 3, java.math.RoundingMode.HALF_UP)
            .doubleValue();

        boolean isFullReturn = retQty.compareTo(totalQty) == 0;

        // ── 2. Fetch bill header ──────────────────────────────────────────────
        ps = con.prepareStatement(
            "SELECT id, customerId, total, payable FROM prod_bill "
          + "WHERE bill_display = ? AND is_cancelled = 0");
        ps.setString(1, billNo);
        rs = ps.executeQuery();
        if (!rs.next()) throw new Exception("Bill not found: " + billNo);
        int     billId      = rs.getInt(1);
        int     customerId  = rs.getInt(2);
        boolean hasCustomer = !rs.wasNull() && customerId > 0;
        double  billTotal   = rs.getDouble(3);
        double  billPayable = rs.getDouble(4);
        rs.close(); ps.close();

        if (billId != fetchedBillId) throw new Exception("Bill / detail mismatch.");

        // ── 3. Fetch batch_id ─────────────────────────────────────────────────
        int batchId = 0;
        ps = con.prepareStatement(
            "SELECT id FROM prod_batch WHERE product_id = ? ORDER BY id DESC LIMIT 1");
        ps.setInt(1, prodId);
        rs = ps.executeQuery();
        if (rs.next()) batchId = rs.getInt(1);
        rs.close(); ps.close();

        // ── 4. Restore stock ──────────────────────────────────────────────────
        if (batchId > 0) {
            ps = con.prepareStatement(
                "UPDATE prod_batch SET stock = stock + ? WHERE id = ?");
            ps.setBigDecimal(1, retQty);
            ps.setInt(2, batchId);
            ps.executeUpdate(); ps.close();

            BigDecimal lastStockNow = BigDecimal.ZERO;
            ps = con.prepareStatement(
                "SELECT stock_now FROM prod_lifecycle WHERE product_id = ? ORDER BY id DESC LIMIT 1");
            ps.setInt(1, prodId);
            rs = ps.executeQuery();
            if (rs.next()) lastStockNow = rs.getBigDecimal(1);
            rs.close(); ps.close();

            ps = con.prepareStatement(
                "INSERT INTO prod_lifecycle "
              + "(bill_id, batch_id, product_id, stock_in, stock_out, stock_now, "
              + " notes, date, time, uid, stock_type, stockAdjType) "
              + "VALUES (?, ?, ?, ?, 0, ?, 'PRODUCT RETURN', NOW(), NOW(), ?, 1, 1)");
            ps.setInt(1, billId);
            ps.setInt(2, batchId);
            ps.setInt(3, prodId);
            ps.setBigDecimal(4, retQty);
            ps.setBigDecimal(5, lastStockNow.add(retQty));
            ps.setInt(6, uid);
            ps.executeUpdate(); ps.close();
        }

        // ── 5. Update bill total & payable ────────────────────────────────────
        double newBillTotal   = new java.math.BigDecimal(billTotal   - retAmount)
                                    .setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();
        double newBillPayable = new java.math.BigDecimal(billPayable - retAmount)
                                    .setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();
        ps = con.prepareStatement(
            "UPDATE prod_bill SET total = ?, payable = ? WHERE id = ?");
        ps.setDouble(1, newBillTotal   < 0 ? 0 : newBillTotal);
        ps.setDouble(2, newBillPayable < 0 ? 0 : newBillPayable);
        ps.setInt(3, billId);
        ps.executeUpdate(); ps.close();

        // ── 6. Update or mark detail row ─────────────────────────────────────
        if (isFullReturn) {
            ps = con.prepareStatement(
                "UPDATE prod_bill_details SET is_exchanged = 2 WHERE id = ?");
            ps.setInt(1, detailId);
        } else {
            BigDecimal newQty = totalQty.subtract(retQty).setScale(3, java.math.RoundingMode.HALF_UP);
            double newItemTotal = new java.math.BigDecimal(itemTotal - retAmount)
                                      .setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();
            ps = con.prepareStatement(
                "UPDATE prod_bill_details SET qty = ?, total = ? WHERE id = ?");
            ps.setBigDecimal(1, newQty);
            ps.setDouble(2, newItemTotal < 0 ? 0 : newItemTotal);
            ps.setInt(3, detailId);
        }
        ps.executeUpdate(); ps.close();

        // ── 7. Insert into pro_bill_exchange ──────────────────────────────────
        ps = con.prepareStatement(
            "INSERT INTO pro_bill_exchange (bill_id, customer_id, old_prod_id, new_prod_id, uid, date_time) "
          + "VALUES (?, ?, ?, ?, ?, NOW())");
        ps.setInt(1, billId);
        if (hasCustomer) { ps.setInt(2, customerId); } else { ps.setNull(2, java.sql.Types.INTEGER); }
        ps.setInt(3, prodId);
        ps.setInt(4, prodId);
        ps.setInt(5, uid);
        ps.executeUpdate(); ps.close();

        // ── 8. Credit exchange points ─────────────────────────────────────────
        String resultMsg;
        if (hasCustomer) {
            ps = con.prepareStatement(
                "SELECT IFNULL(exchange_point, 0) FROM customers WHERE id = ?");
            ps.setInt(1, customerId);
            rs = ps.executeQuery();
            double oldPoint = rs.next() ? rs.getDouble(1) : 0;
            rs.close(); ps.close();

            double totalPoint = new java.math.BigDecimal(oldPoint + retAmount)
                                    .setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();
            ps = con.prepareStatement(
                "UPDATE customers SET exchange_point = ? WHERE id = ?");
            ps.setDouble(1, totalPoint);
            ps.setInt(2, customerId);
            ps.executeUpdate(); ps.close();

            ps = con.prepareStatement(
                "INSERT INTO customers_exchange_point "
              + "(customer_id, bill_id, old_point, exchange_point, total_point, uid, date_time, notes) "
              + "VALUES (?, ?, ?, ?, ?, ?, NOW(), ?)");
            ps.setInt(1, customerId);
            ps.setInt(2, billId);
            ps.setDouble(3, oldPoint);
            ps.setDouble(4, retAmount);
            ps.setDouble(5, totalPoint);
            ps.setInt(6, uid);
            ps.setString(7, "Points earned on product return (Bill: " + billNo + ", Qty: " + returnQty + ")");
            ps.executeUpdate(); ps.close();

            resultMsg = "Return completed for qty " + returnQty + ". Bill reduced by \u20b9"
                      + String.format("%.2f", retAmount)
                      + ". Customer earned \u20b9" + String.format("%.2f", retAmount)
                      + " exchange points. Total points: \u20b9" + String.format("%.2f", totalPoint);
        } else {
            resultMsg = "Return completed for qty " + returnQty + ". Bill reduced by \u20b9"
                      + String.format("%.2f", retAmount)
                      + ". No customer linked \u2014 exchange points not credited.";
        }

        con.commit();
        return resultMsg;

    } catch (Exception e) {
        if (con != null) { try { con.rollback(); } catch (Exception ex) { ; } }
        throw e;
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
}

public String saveReturn(String billNo, int detailId, int uid) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);

        // ── 1. Fetch detail row ───────────────────────────────────────────────
        ps = con.prepareStatement(
            "SELECT bd.id, bd.bill_id, bd.prod_id, bd.qty, bd.total, "
          + "IFNULL(bd.is_exchanged, 0) "
          + "FROM prod_bill_details bd "
          + "WHERE bd.id = ? AND bd.is_cancelled = 0");
        ps.setInt(1, detailId);
        rs = ps.executeQuery();
        if (!rs.next()) {
            throw new Exception("Bill detail not found or already cancelled.");
        }
        int        fetchedBillId    = rs.getInt(2);
        int        prodId           = rs.getInt(3);
        BigDecimal qty              = rs.getBigDecimal(4);
        double     itemTotal        = rs.getDouble(5);
        int        currentStatus    = rs.getInt(6);
        rs.close(); ps.close();

        if (currentStatus == 1) throw new Exception("This item has already been exchanged.");
        if (currentStatus == 2) throw new Exception("This item has already been returned.");

        // ── 2. Fetch bill header ──────────────────────────────────────────────
        ps = con.prepareStatement(
            "SELECT id, customerId, total, payable FROM prod_bill "
          + "WHERE bill_display = ? AND is_cancelled = 0");
        ps.setString(1, billNo);
        rs = ps.executeQuery();
        if (!rs.next()) {
            throw new Exception("Bill not found: " + billNo);
        }
        int     billId       = rs.getInt(1);
        int     customerId   = rs.getInt(2);
        boolean hasCustomer  = !rs.wasNull() && customerId > 0;
        double  billTotal    = rs.getDouble(3);
        double  billPayable  = rs.getDouble(4);
        rs.close(); ps.close();

        if (billId != fetchedBillId) {
            throw new Exception("Bill / detail mismatch.");
        }

        // ── 3. Fetch batch_id for the returned product ────────────────────────
        int batchId = 0;
        ps = con.prepareStatement(
            "SELECT id FROM prod_batch WHERE product_id = ? ORDER BY id DESC LIMIT 1");
        ps.setInt(1, prodId);
        rs = ps.executeQuery();
        if (rs.next()) batchId = rs.getInt(1);
        rs.close(); ps.close();

        // ── 4. Restore stock ──────────────────────────────────────────────────
        if (batchId > 0) {
            ps = con.prepareStatement(
                "UPDATE prod_batch SET stock = stock + ? WHERE id = ?");
            ps.setBigDecimal(1, qty);
            ps.setInt(2, batchId);
            ps.executeUpdate();
            ps.close();

            BigDecimal lastStockNow = BigDecimal.ZERO;
            ps = con.prepareStatement(
                "SELECT stock_now FROM prod_lifecycle WHERE product_id = ? ORDER BY id DESC LIMIT 1");
            ps.setInt(1, prodId);
            rs = ps.executeQuery();
            if (rs.next()) lastStockNow = rs.getBigDecimal(1);
            rs.close(); ps.close();

            BigDecimal stockNow = lastStockNow.add(qty);
            ps = con.prepareStatement(
                "INSERT INTO prod_lifecycle "
              + "(bill_id, batch_id, product_id, stock_in, stock_out, stock_now, "
              + " notes, date, time, uid, stock_type, stockAdjType) "
              + "VALUES (?, ?, ?, ?, 0, ?, 'PRODUCT RETURN', NOW(), NOW(), ?, 1, 1)");
            ps.setInt(1, billId);
            ps.setInt(2, batchId);
            ps.setInt(3, prodId);
            ps.setBigDecimal(4, qty);
            ps.setBigDecimal(5, stockNow);
            ps.setInt(6, uid);
            ps.executeUpdate();
            ps.close();
        }

        // ── 5. Reduce bill total & payable ────────────────────────────────────
        double newBillTotal   = new java.math.BigDecimal(billTotal  - itemTotal)
                                    .setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();
        double newBillPayable = new java.math.BigDecimal(billPayable - itemTotal)
                                    .setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();

        ps = con.prepareStatement(
            "UPDATE prod_bill SET total = ?, payable = ? WHERE id = ?");
        ps.setDouble(1, newBillTotal < 0 ? 0 : newBillTotal);
        ps.setDouble(2, newBillPayable < 0 ? 0 : newBillPayable);
        ps.setInt(3, billId);
        ps.executeUpdate();
        ps.close();

        // ── 6. Mark detail as returned (is_exchanged = 2) ────────────────────
        ps = con.prepareStatement(
            "UPDATE prod_bill_details SET is_exchanged = 2 WHERE id = ?");
        ps.setInt(1, detailId);
        ps.executeUpdate();
        ps.close();

        // ── 7. Insert into pro_bill_exchange ──────────────────────────────────
        ps = con.prepareStatement(
            "INSERT INTO pro_bill_exchange (bill_id, customer_id, old_prod_id, new_prod_id, uid, date_time) "
          + "VALUES (?, ?, ?, ?, ?, NOW())");
        ps.setInt(1, billId);
        if (hasCustomer) { ps.setInt(2, customerId); } else { ps.setNull(2, java.sql.Types.INTEGER); }
        ps.setInt(3, prodId);
        ps.setInt(4, prodId); // same product — denotes a return, not a swap
        ps.setInt(5, uid);
        ps.executeUpdate();
        ps.close();

        // ── 8. Credit exchange points to customer ─────────────────────────────
        String resultMsg;
        if (hasCustomer) {
            ps = con.prepareStatement(
                "SELECT IFNULL(exchange_point, 0) FROM customers WHERE id = ?");
            ps.setInt(1, customerId);
            rs = ps.executeQuery();
            double oldPoint = rs.next() ? rs.getDouble(1) : 0;
            rs.close(); ps.close();

            double totalPoint = new java.math.BigDecimal(oldPoint + itemTotal)
                                    .setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();

            ps = con.prepareStatement(
                "UPDATE customers SET exchange_point = ? WHERE id = ?");
            ps.setDouble(1, totalPoint);
            ps.setInt(2, customerId);
            ps.executeUpdate();
            ps.close();

            ps = con.prepareStatement(
                "INSERT INTO customers_exchange_point "
              + "(customer_id, bill_id, old_point, exchange_point, total_point, uid, date_time, notes) "
              + "VALUES (?, ?, ?, ?, ?, ?, NOW(), ?)");
            ps.setInt(1, customerId);
            ps.setInt(2, billId);
            ps.setDouble(3, oldPoint);
            ps.setDouble(4, itemTotal);
            ps.setDouble(5, totalPoint);
            ps.setInt(6, uid);
            ps.setString(7, "Points earned on product return (Bill: " + billNo + ")");
            ps.executeUpdate();
            ps.close();

            resultMsg = "Return completed. Bill reduced by \u20b9" + String.format("%.2f", itemTotal)
                      + ". Customer earned \u20b9" + String.format("%.2f", itemTotal)
                      + " exchange points. Total points: \u20b9" + String.format("%.2f", totalPoint);
        } else {
            resultMsg = "Return completed. Bill reduced by \u20b9" + String.format("%.2f", itemTotal)
                      + ". No customer linked — exchange points not credited.";
        }

        con.commit();
        return resultMsg;

    } catch (Exception e) {
        if (con != null) { try { con.rollback(); } catch (Exception ex) { ; } }
        throw e;
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
}

/**
 * Fetches exchange/return report rows for the given date range.
 * typeFilter: 0 = all, 1 = exchange only, 2 = return only.
 *
 * Each result row:
 *  0 = id (int)
 *  1 = date_time (String)
 *  2 = bill_no (String)
 *  3 = customer_name (String)
 *  4 = old_prod_name (String)
 *  5 = new_prod_name (String)
 *  6 = type: 1=exchange / 2=return (int)
 *  7 = points_earned (double)
 *  8 = staff_name (String)
 */
public Vector getExchangeReturnReport(String fromDate, String toDate, int typeFilter) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector result = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();

        String typeClause = "";
        if (typeFilter == 1) {
            typeClause = " AND pbe.old_prod_id <> pbe.new_prod_id ";
        } else if (typeFilter == 2) {
            typeClause = " AND pbe.old_prod_id = pbe.new_prod_id ";
        }

        String sql =
            "SELECT pbe.id, "
          + "       DATE_FORMAT(pbe.date_time,'%d-%m-%Y %H:%i') AS dt, "
          + "       pb.bill_display AS bill_no, "
          + "       IFNULL(c.name, 'Walk-in') AS customer_name, "
          + "       op.name AS old_prod_name, "
          + "       np.name AS new_prod_name, "
          + "       CASE WHEN pbe.old_prod_id = pbe.new_prod_id THEN 2 ELSE 1 END AS type, "
          + "       IFNULL((SELECT cep.exchange_point "
          + "                FROM customers_exchange_point cep "
          + "               WHERE cep.bill_id = pbe.bill_id "
          + "                 AND cep.customer_id = pbe.customer_id "
          + "               ORDER BY cep.id DESC LIMIT 1), 0) AS points_earned, "
          + "       IFNULL(u.user_name, '-') AS staff_name "
          + "FROM pro_bill_exchange pbe "
          + "JOIN prod_bill pb ON pb.id = pbe.bill_id "
          + "LEFT JOIN customers c ON c.id = pbe.customer_id "
          + "JOIN prod_product op ON op.id = pbe.old_prod_id "
          + "JOIN prod_product np ON np.id = pbe.new_prod_id "
          + "LEFT JOIN users u ON u.id = pbe.uid "
          + "WHERE DATE(pbe.date_time) BETWEEN ? AND ? "
          + typeClause
          + "ORDER BY pbe.date_time DESC";

        ps = con.prepareStatement(sql);
        ps.setString(1, fromDate);
        ps.setString(2, toDate);
        rs = ps.executeQuery();

        while (rs.next()) {
            Vector row = new Vector();
            row.add(rs.getInt("id"));                // 0
            row.add(rs.getString("dt"));             // 1
            row.add(rs.getString("bill_no"));        // 2
            row.add(rs.getString("customer_name"));  // 3
            row.add(rs.getString("old_prod_name"));  // 4
            row.add(rs.getString("new_prod_name"));  // 5
            row.add(rs.getInt("type"));              // 6  1=exchange, 2=return
            row.add(rs.getDouble("points_earned"));  // 7
            row.add(rs.getString("staff_name"));     // 8
            result.add(row);
        }
        return result;
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
}

/**
 * Deducts used exchange points from customer after a bill is saved.
 * - Reduces customers.exchange_point by pointsUsed (floor to 0).
 * - Inserts a negative ledger entry in customers_exchange_point.
 */
public void useExchangePoint(int customerId, int billId, double pointsUsed, int uid) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);

        // Fetch current points
        ps = con.prepareStatement(
            "SELECT IFNULL(exchange_point, 0) FROM customers WHERE id = ?");
        ps.setInt(1, customerId);
        rs = ps.executeQuery();
        double oldPoint = rs.next() ? rs.getDouble(1) : 0;
        rs.close(); ps.close();

        double actualDeduct = Math.min(pointsUsed, oldPoint);
        double newPoint = new java.math.BigDecimal(oldPoint - actualDeduct)
                              .setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();
        if (newPoint < 0) newPoint = 0;

        // Update customers table
        ps = con.prepareStatement(
            "UPDATE customers SET exchange_point = ? WHERE id = ?");
        ps.setDouble(1, newPoint);
        ps.setInt(2, customerId);
        ps.executeUpdate();
        ps.close();

        // Insert ledger row (negative exchange_point = deduction)
        ps = con.prepareStatement(
            "INSERT INTO customers_exchange_point "
          + "(customer_id, bill_id, old_point, exchange_point, total_point, uid, date_time, notes) "
          + "VALUES (?, ?, ?, ?, ?, ?, NOW(), ?)");
        ps.setInt(1, customerId);
        ps.setInt(2, billId);
        ps.setDouble(3, oldPoint);
        ps.setDouble(4, -actualDeduct);   // negative = used/deducted
        ps.setDouble(5, newPoint);
        ps.setInt(6, uid);
        ps.setString(7, "Points used as bill discount (Bill ID: " + billId + ", Used: " + String.format("%.2f", actualDeduct) + ")");
        ps.executeUpdate();
        ps.close();

        con.commit();
    } catch (Exception e) {
        if (con != null) { try { con.rollback(); } catch (Exception ex) { ; } }
        throw e;
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Ticket Booking Methods
// ─────────────────────────────────────────────────────────────────────────────

public Vector searchTicketCity(String term) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();
        pt = con.prepareStatement(
            "SELECT id, name FROM ticket_city WHERE name LIKE ? AND is_active = 1 ORDER BY name LIMIT 10");
        pt.setString(1, "%" + term + "%");
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt("id"));
            row.addElement(rs.getString("name"));
            vec.addElement(row);
        }
        return vec;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

/** Returns existing city id if found (case-insensitive), otherwise inserts and returns new id. */
public int getOrInsertTicketCity(String name) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement("SELECT id FROM ticket_city WHERE LOWER(name) = LOWER(?) LIMIT 1");
        pt.setString(1, name.trim());
        rs = pt.executeQuery();
        if (rs.next()) {
            return rs.getInt("id");
        }
        rs.close(); pt.close();
        con.setAutoCommit(false);
        pt = con.prepareStatement(
            "INSERT INTO ticket_city (name, is_active) VALUES (?, 1)",
            Statement.RETURN_GENERATED_KEYS);
        pt.setString(1, name.trim());
        pt.executeUpdate();
        rs = pt.getGeneratedKeys();
        int newId = rs.next() ? rs.getInt(1) : -1;
        con.commit();
        return newId;
    } catch (Exception e) {
        if (con != null) try { con.rollback(); } catch (SQLException ex) { ; }
        throw e;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

// ── ticket_flightno lookup ──────────────────────────────────────────────────
public Vector searchTicketFlightNo(String term) throws Exception {
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();
        pt = con.prepareStatement(
            "SELECT id, value FROM ticket_flightno WHERE value LIKE ? ORDER BY value LIMIT 10");
        pt.setString(1, "%" + term + "%");
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt("id"));
            row.addElement(rs.getString("value"));
            vec.addElement(row);
        }
        return vec;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public void getOrInsertTicketFlightNo(String name) throws Exception {
    if (name == null || name.trim().isEmpty()) return;
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement("SELECT id FROM ticket_flightno WHERE LOWER(value) = LOWER(?) LIMIT 1");
        pt.setString(1, name.trim());
        rs = pt.executeQuery();
        if (rs.next()) return;
        rs.close(); pt.close();
        pt = con.prepareStatement("INSERT IGNORE INTO ticket_flightno (value) VALUES (?)");
        pt.setString(1, name.trim());
        pt.executeUpdate();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

// ── ticket_airline lookup ───────────────────────────────────────────────────
public Vector searchTicketAirline(String term) throws Exception {
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();
        pt = con.prepareStatement(
            "SELECT id, value FROM ticket_airline WHERE value LIKE ? ORDER BY value LIMIT 10");
        pt.setString(1, "%" + term + "%");
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt("id"));
            row.addElement(rs.getString("value"));
            vec.addElement(row);
        }
        return vec;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public void getOrInsertTicketAirline(String name) throws Exception {
    if (name == null || name.trim().isEmpty()) return;
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement("SELECT id FROM ticket_airline WHERE LOWER(value) = LOWER(?) LIMIT 1");
        pt.setString(1, name.trim());
        rs = pt.executeQuery();
        if (rs.next()) return;
        rs.close(); pt.close();
        pt = con.prepareStatement("INSERT IGNORE INTO ticket_airline (value) VALUES (?)");
        pt.setString(1, name.trim());
        pt.executeUpdate();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public Vector getTicketAgents() throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();
        pt = con.prepareStatement(
            "SELECT id, name FROM ticket_agent WHERE is_active = 1 ORDER BY name");
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt("id"));
            row.addElement(rs.getString("name"));
            vec.addElement(row);
        }
        return vec;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public Vector getTicketPaymentModes() throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();
        pt = con.prepareStatement(
            "SELECT id, modes FROM ticket_payment_mode WHERE is_active = 1 ORDER BY id");
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt("id"));
            row.addElement(rs.getString("modes"));
            vec.addElement(row);
        }
        return vec;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

/**
 * Saves a full ticket booking: header + passengers + ledger entries in one transaction.
 * Ledger logic:
 *   - Buy from agent  → CR entry (we owe the agent)
 *   - Sell to agent   → DR entry (agent owes us)
 * Returns the new booking id.
 */
public String getTicketNo(int id) {
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement("SELECT ticket_no FROM ticket_booking WHERE id=? LIMIT 1");
        pt.setInt(1, id);
        rs = pt.executeQuery();
        if (rs.next() && rs.getString(1) != null) return rs.getString(1);
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        try { if (rs!=null) rs.close(); } catch (Exception e) {}
        try { if (pt!=null) pt.close(); } catch (Exception e) {}
        try { if (con!=null) con.close(); } catch (Exception e) {}
    }
    return String.format("TKT-%03d", id);
}

public int saveTicketBooking(
        String pnr, String bookingDate,
        String onewayDate, String onewayTime, int onewayFromId, int onewayToId,
        String onewayFlightNo, String onewayAirlines,
        String returnDate, String returnTime,
        Integer returnFromId, Integer returnToId,
        String returnFlightNo, String returnAirlines,
        int noOfSeats, String phone,
        Integer buyAgentId, Double buyAmount, Integer buyPaymentModeId,
        Integer sellAgentId, Double sellAmount, Integer sellPaymentModeId,
        String customerName, Double customerAmount, Integer customerPaymentModeId,
        String[] passengerNames, int createdBy,
        Double buyPaidAmount, Double sellPaidAmount, Double custPaidAmount,
        String buyTxnNo, String sellTxnNo, String custTxnNo) throws Exception {

    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);

        // ── 1. Generate ticket number ──────────────────────────────────────
        String ticketNo = "TKT-001";
        try {
            PreparedStatement ptTn = con.prepareStatement(
                "SELECT ticket_no FROM ticket_booking ORDER BY id DESC LIMIT 1");
            ResultSet rsTn = ptTn.executeQuery();
            if (rsTn.next() && rsTn.getString(1) != null) {
                String lastTkt = rsTn.getString(1);
                int tNum = Integer.parseInt(lastTkt.substring(4));
                ticketNo = String.format("TKT-%03d", tNum + 1);
            }
            rsTn.close(); ptTn.close();
        } catch (Exception etk) { /* keep TKT-001 */ }

        // ── 2. Booking header ──────────────────────────────────────────────
        String sql = "INSERT INTO ticket_booking " +
            "(pnr, booking_date, " +
            " oneway_travel_date, oneway_travel_time, oneway_from_id, oneway_to_id, oneway_flight_no, oneway_airlines, " +
            " return_travel_date, return_travel_time, return_from_id, return_to_id, return_flight_no, return_airlines, " +
            " no_of_seats, phone, " +
            " buy_agent_id, buy_amount, buy_payment_mode_id, " +
            " sell_agent_id, sell_amount, sell_payment_mode_id, " +
            " customer_name, customer_amount, customer_payment_mode_id, created_by, ticket_no," +
            " buy_paid_amount, sell_paid_amount, cust_paid_amount) " +
            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        pt = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
        pt.setString(1, pnr);
        pt.setString(2, bookingDate);
        pt.setString(3, (onewayDate != null && !onewayDate.isEmpty()) ? onewayDate : null);
        pt.setString(4, (onewayTime != null && !onewayTime.isEmpty()) ? onewayTime : null);
        pt.setInt(5, onewayFromId);
        pt.setInt(6, onewayToId);
        pt.setString(7, (onewayFlightNo != null && !onewayFlightNo.isEmpty()) ? onewayFlightNo : null);
        pt.setString(8, (onewayAirlines != null && !onewayAirlines.isEmpty()) ? onewayAirlines : null);
        pt.setString(9, (returnDate != null && !returnDate.isEmpty()) ? returnDate : null);
        pt.setString(10, (returnTime != null && !returnTime.isEmpty()) ? returnTime : null);
        if (returnFromId != null) pt.setInt(11, returnFromId); else pt.setNull(11, Types.INTEGER);
        if (returnToId   != null) pt.setInt(12, returnToId);   else pt.setNull(12, Types.INTEGER);
        pt.setString(13, (returnFlightNo != null && !returnFlightNo.isEmpty()) ? returnFlightNo : null);
        pt.setString(14, (returnAirlines != null && !returnAirlines.isEmpty()) ? returnAirlines : null);
        pt.setInt(15, noOfSeats);
        pt.setString(16, (phone != null && !phone.isEmpty()) ? phone : null);
        if (buyAgentId != null) pt.setInt(17, buyAgentId); else pt.setNull(17, Types.INTEGER);
        if (buyAmount  != null) pt.setDouble(18, buyAmount);  else pt.setNull(18, Types.DOUBLE);
        if (buyPaymentModeId != null) pt.setInt(19, buyPaymentModeId); else pt.setNull(19, Types.INTEGER);
        if (sellAgentId != null) pt.setInt(20, sellAgentId); else pt.setNull(20, Types.INTEGER);
        if (sellAmount  != null) pt.setDouble(21, sellAmount);  else pt.setNull(21, Types.DOUBLE);
        if (sellPaymentModeId != null) pt.setInt(22, sellPaymentModeId); else pt.setNull(22, Types.INTEGER);
        pt.setString(23, (customerName != null && !customerName.isEmpty()) ? customerName : null);
        if (customerAmount  != null) pt.setDouble(24, customerAmount);  else pt.setNull(24, Types.DOUBLE);
        if (customerPaymentModeId != null) pt.setInt(25, customerPaymentModeId); else pt.setNull(25, Types.INTEGER);
        pt.setInt(26, createdBy);
        pt.setString(27, ticketNo);
        if (buyPaidAmount  != null) pt.setDouble(28, buyPaidAmount);  else pt.setNull(28, Types.DOUBLE);
        if (sellPaidAmount != null) pt.setDouble(29, sellPaidAmount); else pt.setNull(29, Types.DOUBLE);
        if (custPaidAmount != null) pt.setDouble(30, custPaidAmount); else pt.setNull(30, Types.DOUBLE);
        pt.executeUpdate();
        rs = pt.getGeneratedKeys();
        int bookingId = rs.next() ? rs.getInt(1) : -1;
        rs.close(); pt.close();

        // ── 3. Passengers ──────────────────────────────────────────────────
        if (passengerNames != null && passengerNames.length > 0) {
            pt = con.prepareStatement(
                "INSERT INTO ticket_passenger (booking_id, seat_no, passenger_name) VALUES (?,?,?)");
            for (int i = 0; i < passengerNames.length; i++) {
                String pName = (passengerNames[i] != null) ? passengerNames[i].trim() : "";
                pt.setInt(1, bookingId);
                pt.setInt(2, i + 1);
                pt.setString(3, pName);
                pt.addBatch();
            }
            pt.executeBatch();
            pt.close();
        }

        // ── 4. Ledger entries ──────────────────────────────────────────────
        String ledSql =
            "INSERT INTO ticket_ledger " +
            "(booking_id, party_type, agent_id, party_name, transaction_type, bill_amount, amount, payment_mode_id, transaction_no, remarks, transaction_date) " +
            "VALUES (?,?,?,?,?,?,?,?,?,?,?)";

        // Buy from agent → CR (we owe agent)
        if (buyAgentId != null && buyAmount != null && buyAmount > 0) {
            pt = con.prepareStatement(ledSql);
            pt.setInt(1, bookingId);
            pt.setString(2, "BUY_AGENT");
            pt.setInt(3, buyAgentId);
            pt.setNull(4, Types.VARCHAR);
            pt.setString(5, "CR");
            pt.setDouble(6, buyAmount);
            double bPaid = (buyPaidAmount != null) ? buyPaidAmount : 0.0;
            pt.setDouble(7, bPaid);
            if (buyPaymentModeId != null) pt.setInt(8, buyPaymentModeId); else pt.setNull(8, Types.INTEGER);
            String btnStr = (buyTxnNo != null && !buyTxnNo.trim().isEmpty()) ? buyTxnNo.trim() : null;
            if (btnStr != null) pt.setString(9, btnStr); else pt.setNull(9, Types.VARCHAR);
            pt.setString(10, "Buy ticket | PNR: " + (pnr != null ? pnr : "-"));
            pt.setString(11, bookingDate);
            pt.executeUpdate();
            pt.close();
        }

        // Sell to agent → DR (agent owes us)
        if (sellAgentId != null && sellAmount != null && sellAmount > 0) {
            pt = con.prepareStatement(ledSql);
            pt.setInt(1, bookingId);
            pt.setString(2, "SELL_AGENT");
            pt.setInt(3, sellAgentId);
            pt.setNull(4, Types.VARCHAR);
            pt.setString(5, "DR");
            pt.setDouble(6, sellAmount);
            double sPaid = (sellPaidAmount != null) ? sellPaidAmount : 0.0;
            pt.setDouble(7, sPaid);
            if (sellPaymentModeId != null) pt.setInt(8, sellPaymentModeId); else pt.setNull(8, Types.INTEGER);
            String stnStr = (sellTxnNo != null && !sellTxnNo.trim().isEmpty()) ? sellTxnNo.trim() : null;
            if (stnStr != null) pt.setString(9, stnStr); else pt.setNull(9, Types.VARCHAR);
            pt.setString(10, "Sell ticket | PNR: " + (pnr != null ? pnr : "-"));
            pt.setString(11, bookingDate);
            pt.executeUpdate();
            pt.close();
        }

        // Customer → DR (customer owes us)
        if (customerAmount != null && customerAmount > 0) {
            pt = con.prepareStatement(ledSql);
            pt.setInt(1, bookingId);
            pt.setString(2, "CUSTOMER");
            pt.setNull(3, Types.INTEGER);
            pt.setString(4, (customerName != null && !customerName.isEmpty()) ? customerName : "-");
            pt.setString(5, "DR");
            pt.setDouble(6, customerAmount);
            double cPaid = (custPaidAmount != null) ? custPaidAmount : 0.0;
            pt.setDouble(7, cPaid);
            if (customerPaymentModeId != null) pt.setInt(8, customerPaymentModeId); else pt.setNull(8, Types.INTEGER);
            String ctnStr = (custTxnNo != null && !custTxnNo.trim().isEmpty()) ? custTxnNo.trim() : null;
            if (ctnStr != null) pt.setString(9, ctnStr); else pt.setNull(9, Types.VARCHAR);
            pt.setString(10, "Customer payment | PNR: " + (pnr != null ? pnr : "-"));
            pt.setString(11, bookingDate);
            pt.executeUpdate();
            pt.close();
        }

        // ── 5. Autocomplete lookups (same connection / same commit) ────────
        if (onewayFlightNo != null && !onewayFlightNo.trim().isEmpty()) {
            pt = con.prepareStatement("INSERT IGNORE INTO ticket_flightno (value) VALUES (?)");
            pt.setString(1, onewayFlightNo.trim()); pt.executeUpdate(); pt.close();
        }
        if (onewayAirlines != null && !onewayAirlines.trim().isEmpty()) {
            pt = con.prepareStatement("INSERT IGNORE INTO ticket_airline (value) VALUES (?)");
            pt.setString(1, onewayAirlines.trim()); pt.executeUpdate(); pt.close();
        }
        if (returnFlightNo != null && !returnFlightNo.trim().isEmpty()) {
            pt = con.prepareStatement("INSERT IGNORE INTO ticket_flightno (value) VALUES (?)");
            pt.setString(1, returnFlightNo.trim()); pt.executeUpdate(); pt.close();
        }
        if (returnAirlines != null && !returnAirlines.trim().isEmpty()) {
            pt = con.prepareStatement("INSERT IGNORE INTO ticket_airline (value) VALUES (?)");
            pt.setString(1, returnAirlines.trim()); pt.executeUpdate(); pt.close();
        }

        con.commit();
        return bookingId;

    } catch (Exception e) {
        if (con != null) try { con.rollback(); } catch (SQLException ex) { ; }
        throw e;
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.setAutoCommit(true); } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// PNR ENQUIRY  –  returns full booking row (single result or empty Vector)
// Row layout:
//   [0]  booking id       [1]  pnr               [2]  booking_date
//   [3]  ow_travel_date   [4]  ow_travel_time     [5]  ow_from (city name)
//   [6]  ow_to (name)     [7]  ow_flight_no       [8]  ow_airlines
//   [9]  ret_travel_date  [10] ret_travel_time    [11] ret_from (name)
//   [12] ret_to (name)    [13] ret_flight_no      [14] ret_airlines
//   [15] no_of_seats      [16] phone
//   [17] buy_agent_name   [18] buy_amount         [19] buy_mode
//   [20] sell_agent_name  [21] sell_amount        [22] sell_mode
//   [23] customer_name    [24] customer_amount    [25] customer_mode
//   [26] created_at
// ─────────────────────────────────────────────────────────────────────────────
public Vector getPNRDetails(String pnr) {
    Vector result = new Vector();
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String sql =
            "SELECT b.id, b.pnr, b.booking_date," +
            " b.oneway_travel_date, b.oneway_travel_time," +
            " cf.name AS ow_from, ct.name AS ow_to," +
            " b.oneway_flight_no, b.oneway_airlines," +
            " b.return_travel_date, b.return_travel_time," +
            " rf.name AS ret_from, rt2.name AS ret_to," +
            " b.return_flight_no, b.return_airlines," +
            " b.no_of_seats, b.phone," +
            " ba.name AS buy_agent, b.buy_amount, bm.modes AS buy_mode," +
            " sa.name AS sell_agent, b.sell_amount, sm.modes AS sell_mode," +
            " b.customer_name, b.customer_amount, cm.modes AS cust_mode," +
            " b.created_at, COALESCE(b.is_cancelled,0) AS is_cancelled" +
            " FROM ticket_booking b" +
            " LEFT JOIN ticket_city cf  ON cf.id  = b.oneway_from_id" +
            " LEFT JOIN ticket_city ct  ON ct.id  = b.oneway_to_id" +
            " LEFT JOIN ticket_city rf  ON rf.id  = b.return_from_id" +
            " LEFT JOIN ticket_city rt2 ON rt2.id = b.return_to_id" +
            " LEFT JOIN ticket_agent ba ON ba.id  = b.buy_agent_id" +
            " LEFT JOIN ticket_agent sa ON sa.id  = b.sell_agent_id" +
            " LEFT JOIN ticket_payment_mode bm ON bm.id = b.buy_payment_mode_id" +
            " LEFT JOIN ticket_payment_mode sm ON sm.id = b.sell_payment_mode_id" +
            " LEFT JOIN ticket_payment_mode cm ON cm.id = b.customer_payment_mode_id" +
            " WHERE b.pnr = ?" +
            " ORDER BY b.id DESC LIMIT 1";
        pt = con.prepareStatement(sql);
        pt.setString(1, pnr.trim());
        rs = pt.executeQuery();
        if (rs.next()) {
            Vector row = new Vector();
            for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++)
                row.add(rs.getObject(i));
            result.add(row);
        }
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        try { if (rs!=null) rs.close(); } catch (Exception e) {}
        try { if (pt!=null) pt.close(); } catch (Exception e) {}
        try { if (con!=null) con.close(); } catch (Exception e) {}
    }
    return result;
}

// ─────────────────────────────────────────────────────────────────────────────
// PNR ENQUIRY – passengers for a booking id
// Row: [0] seat_no  [1] passenger_name
// ─────────────────────────────────────────────────────────────────────────────
public Vector getPNRPassengers(int bookingId) {
    Vector result = new Vector();
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement(
            "SELECT seat_no, passenger_name FROM ticket_passenger WHERE booking_id=? ORDER BY seat_no");
        pt.setInt(1, bookingId);
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.add(rs.getObject(1));
            row.add(rs.getObject(2));
            result.add(row);
        }
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        try { if (rs!=null) rs.close(); } catch (Exception e) {}
        try { if (pt!=null) pt.close(); } catch (Exception e) {}
        try { if (con!=null) con.close(); } catch (Exception e) {}
    }
    return result;
}

// ─────────────────────────────────────────────────────────────────────────────
// GET LAST TICKET NO  –  most recently saved ticket number (for display)
// ─────────────────────────────────────────────────────────────────────────────
public String getLastTicketNo() {
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement(
            "SELECT ticket_no FROM ticket_booking ORDER BY id DESC LIMIT 1");
        rs = pt.executeQuery();
        if (rs.next() && rs.getString(1) != null) return rs.getString(1);
        return "";
    } catch (Exception e) { return ""; }
    finally {
        try { if (rs!=null) rs.close(); } catch (Exception e) {}
        try { if (pt!=null) pt.close(); } catch (Exception e) {}
        try { if (con!=null) con.close(); } catch (Exception e) {}
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET TICKET BY ID FULL  –  all raw IDs for edit-form population
// Row: [0]id [1]pnr [2]bookingDate
//      [3]owDate [4]owTime [5]owFromId [6]owFromName [7]owToId [8]owToName
//      [9]owFlightNo [10]owAirlines
//      [11]retDate [12]retTime [13]retFromId [14]retFromName [15]retToId [16]retToName
//      [17]retFlightNo [18]retAirlines
//      [19]seats [20]phone
//      [21]buyAgentId [22]buyAgentName [23]buyAmount [24]buyModeId [25]buyModeName [26]buyPaid
//      [27]sellAgentId [28]sellAgentName [29]sellAmount [30]sellModeId [31]sellModeName [32]sellPaid
//      [33]custName [34]custAmount [35]custModeId [36]custModeName [37]custPaid
//      [38]ticketNo [39]createdAt [40]isCancelled
// ─────────────────────────────────────────────────────────────────────────────
public Vector getTicketByIdFull(int id) throws Exception {
    Vector result = new Vector();
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String sql =
            "SELECT b.id, b.pnr, b.booking_date," +
            " b.oneway_travel_date, b.oneway_travel_time," +
            " b.oneway_from_id, cf.name AS ow_from," +
            " b.oneway_to_id, ct.name AS ow_to," +
            " b.oneway_flight_no, b.oneway_airlines," +
            " b.return_travel_date, b.return_travel_time," +
            " b.return_from_id, rf.name AS ret_from," +
            " b.return_to_id, rt2.name AS ret_to," +
            " b.return_flight_no, b.return_airlines," +
            " b.no_of_seats, b.phone," +
            " b.buy_agent_id, ba.name AS buy_agent_name," +
            " b.buy_amount, b.buy_payment_mode_id, bm.modes AS buy_mode_name," +
            " COALESCE(b.buy_paid_amount,0) AS buy_paid," +
            " b.sell_agent_id, sa.name AS sell_agent_name," +
            " b.sell_amount, b.sell_payment_mode_id, sm.modes AS sell_mode_name," +
            " COALESCE(b.sell_paid_amount,0) AS sell_paid," +
            " b.customer_name, b.customer_amount, b.customer_payment_mode_id, cm.modes AS cust_mode_name," +
            " COALESCE(b.cust_paid_amount,0) AS cust_paid," +
            " b.ticket_no, b.created_at, COALESCE(b.is_cancelled,0) AS is_cancelled," +
            " (SELECT tl.transaction_no FROM ticket_ledger tl WHERE tl.booking_id=b.id AND tl.party_type='BUY_AGENT'  LIMIT 1) AS buy_txn_no," +
            " (SELECT tl.transaction_no FROM ticket_ledger tl WHERE tl.booking_id=b.id AND tl.party_type='SELL_AGENT' LIMIT 1) AS sell_txn_no," +
            " (SELECT tl.transaction_no FROM ticket_ledger tl WHERE tl.booking_id=b.id AND tl.party_type='CUSTOMER'   LIMIT 1) AS cust_txn_no" +
            " FROM ticket_booking b" +
            " LEFT JOIN ticket_city cf  ON cf.id  = b.oneway_from_id" +
            " LEFT JOIN ticket_city ct  ON ct.id  = b.oneway_to_id" +
            " LEFT JOIN ticket_city rf  ON rf.id  = b.return_from_id" +
            " LEFT JOIN ticket_city rt2 ON rt2.id = b.return_to_id" +
            " LEFT JOIN ticket_agent ba ON ba.id  = b.buy_agent_id" +
            " LEFT JOIN ticket_agent sa ON sa.id  = b.sell_agent_id" +
            " LEFT JOIN ticket_payment_mode bm ON bm.id = b.buy_payment_mode_id" +
            " LEFT JOIN ticket_payment_mode sm ON sm.id = b.sell_payment_mode_id" +
            " LEFT JOIN ticket_payment_mode cm ON cm.id = b.customer_payment_mode_id" +
            " WHERE b.id = ? LIMIT 1";
        pt = con.prepareStatement(sql);
        pt.setInt(1, id);
        rs = pt.executeQuery();
        if (rs.next()) {
            Vector row = new Vector();
            for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++) row.add(rs.getObject(i));
            result.add(row);
        }
    } finally {
        try { if (rs!=null) rs.close(); } catch (Exception e) {}
        try { if (pt!=null) pt.close(); } catch (Exception e) {}
        try { if (con!=null) con.close(); } catch (Exception e) {}
    }
    return result;
}

// ─────────────────────────────────────────────────────────────────────────────
// UPDATE TICKET BOOKING  –  header fields + passengers, audit-logged
// ─────────────────────────────────────────────────────────────────────────────
public void updateTicketBooking(
        int bookingId,
        String pnr, String bookingDate,
        String onewayDate, String onewayTime, int onewayFromId, int onewayToId,
        String onewayFlightNo, String onewayAirlines,
        String returnDate, String returnTime,
        Integer returnFromId, Integer returnToId,
        String returnFlightNo, String returnAirlines,
        int noOfSeats, String phone,
        Integer buyAgentId, Double buyAmount, Integer buyModeId,
        Integer sellAgentId, Double sellAmount, Integer sellModeId,
        String customerName, Double customerAmount, Integer custModeId,
        String[] passengerNames, int updatedBy, String remarks,
        Double buyDCAmt, Double buyDCPaid, Integer buyDCModeId, String buyDCTxnNo,
        Double sellDCAmt, Double sellDCPaid, Integer sellDCModeId, String sellDCTxnNo) throws Exception {

    Connection con = null; PreparedStatement pt = null;
    String today = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
    String now   = new java.text.SimpleDateFormat("HH:mm:ss").format(new java.util.Date());
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);

        // 0. Build change description (before → after)
        StringBuilder _cd = new StringBuilder();
        PreparedStatement ptO = con.prepareStatement(
            "SELECT b.pnr, DATE_FORMAT(b.booking_date,'%Y-%m-%d')," +
            " DATE_FORMAT(b.oneway_travel_date,'%Y-%m-%d'), COALESCE(b.oneway_travel_time,'')," +
            " COALESCE(cf.name,''), COALESCE(ct.name,'')," +
            " COALESCE(b.oneway_flight_no,''), COALESCE(b.oneway_airlines,'')," +
            " DATE_FORMAT(b.return_travel_date,'%Y-%m-%d'), COALESCE(b.return_travel_time,'')," +
            " COALESCE(rf.name,''), COALESCE(rt2.name,'')," +
            " COALESCE(b.return_flight_no,''), COALESCE(b.return_airlines,'')," +
            " b.no_of_seats, COALESCE(b.phone,'')," +
            " COALESCE(ba.name,''), COALESCE(b.buy_amount,0), COALESCE(bm.modes,'')," +
            " COALESCE(sa.name,''), COALESCE(b.sell_amount,0), COALESCE(sm.modes,'')," +
            " COALESCE(b.customer_name,''), COALESCE(b.customer_amount,0), COALESCE(cm.modes,'')" +
            " FROM ticket_booking b" +
            " LEFT JOIN ticket_city cf  ON cf.id=b.oneway_from_id" +
            " LEFT JOIN ticket_city ct  ON ct.id=b.oneway_to_id" +
            " LEFT JOIN ticket_city rf  ON rf.id=b.return_from_id" +
            " LEFT JOIN ticket_city rt2 ON rt2.id=b.return_to_id" +
            " LEFT JOIN ticket_agent ba ON ba.id=b.buy_agent_id" +
            " LEFT JOIN ticket_agent sa ON sa.id=b.sell_agent_id" +
            " LEFT JOIN ticket_payment_mode bm ON bm.id=b.buy_payment_mode_id" +
            " LEFT JOIN ticket_payment_mode sm ON sm.id=b.sell_payment_mode_id" +
            " LEFT JOIN ticket_payment_mode cm ON cm.id=b.customer_payment_mode_id" +
            " WHERE b.id=? LIMIT 1");
        ptO.setInt(1, bookingId);
        ResultSet rsO = ptO.executeQuery();
        if (rsO.next()) {
            PreparedStatement ptN = con.prepareStatement(
                "SELECT (SELECT name  FROM ticket_city         WHERE id=?) owf," +
                "       (SELECT name  FROM ticket_city         WHERE id=?) owt," +
                "       (SELECT name  FROM ticket_city         WHERE id=?) rtf," +
                "       (SELECT name  FROM ticket_city         WHERE id=?) rtt," +
                "       (SELECT name  FROM ticket_agent        WHERE id=?) ba," +
                "       (SELECT modes FROM ticket_payment_mode WHERE id=?) bm," +
                "       (SELECT name  FROM ticket_agent        WHERE id=?) sa," +
                "       (SELECT modes FROM ticket_payment_mode WHERE id=?) sm," +
                "       (SELECT modes FROM ticket_payment_mode WHERE id=?) cm");
            ptN.setInt(1, onewayFromId); ptN.setInt(2, onewayToId);
            if (returnFromId!=null) ptN.setInt(3,returnFromId); else ptN.setNull(3,Types.INTEGER);
            if (returnToId!=null)   ptN.setInt(4,returnToId);   else ptN.setNull(4,Types.INTEGER);
            if (buyAgentId!=null)   ptN.setInt(5,buyAgentId);   else ptN.setNull(5,Types.INTEGER);
            if (buyModeId!=null)    ptN.setInt(6,buyModeId);    else ptN.setNull(6,Types.INTEGER);
            if (sellAgentId!=null)  ptN.setInt(7,sellAgentId);  else ptN.setNull(7,Types.INTEGER);
            if (sellModeId!=null)   ptN.setInt(8,sellModeId);   else ptN.setNull(8,Types.INTEGER);
            if (custModeId!=null)   ptN.setInt(9,custModeId);   else ptN.setNull(9,Types.INTEGER);
            ResultSet rsN = ptN.executeQuery();
            String nOwf="",nOwt="",nRtf="",nRtt="",nBa="",nBm="",nSa="",nSm="",nCm="";
            if (rsN.next()) {
                nOwf=rsN.getString(1)!=null?rsN.getString(1):""; nOwt=rsN.getString(2)!=null?rsN.getString(2):"";
                nRtf=rsN.getString(3)!=null?rsN.getString(3):""; nRtt=rsN.getString(4)!=null?rsN.getString(4):"";
                nBa=rsN.getString(5)!=null?rsN.getString(5):"";  nBm=rsN.getString(6)!=null?rsN.getString(6):"";
                nSa=rsN.getString(7)!=null?rsN.getString(7):"";  nSm=rsN.getString(8)!=null?rsN.getString(8):"";
                nCm=rsN.getString(9)!=null?rsN.getString(9):"";
            }
            rsN.close(); ptN.close();
            // Old values
            String oPnr=rsO.getString(1)!=null?rsO.getString(1):"";
            String oBDate=rsO.getString(2)!=null?rsO.getString(2):"";
            String oOwDate=rsO.getString(3)!=null?rsO.getString(3):"";
            String oOwTime=rsO.getString(4)!=null?rsO.getString(4):"";
            String oOwf=rsO.getString(5)!=null?rsO.getString(5):"";
            String oOwt=rsO.getString(6)!=null?rsO.getString(6):"";
            String oOwFlt=rsO.getString(7)!=null?rsO.getString(7):"";
            String oOwAir=rsO.getString(8)!=null?rsO.getString(8):"";
            String oRetDate=rsO.getString(9)!=null?rsO.getString(9):"";
            String oRetTime=rsO.getString(10)!=null?rsO.getString(10):"";
            String oRtf=rsO.getString(11)!=null?rsO.getString(11):"";
            String oRtt=rsO.getString(12)!=null?rsO.getString(12):"";
            String oRetFlt=rsO.getString(13)!=null?rsO.getString(13):"";
            String oRetAir=rsO.getString(14)!=null?rsO.getString(14):"";
            int oSeats=rsO.getInt(15);
            String oPhone=rsO.getString(16)!=null?rsO.getString(16):"";
            String oBa=rsO.getString(17)!=null?rsO.getString(17):"";
            double oBuyAmt=rsO.getDouble(18);
            String oBm=rsO.getString(19)!=null?rsO.getString(19):"";
            String oSa=rsO.getString(20)!=null?rsO.getString(20):"";
            double oSellAmt=rsO.getDouble(21);
            String oSm=rsO.getString(22)!=null?rsO.getString(22):"";
            String oCustN=rsO.getString(23)!=null?rsO.getString(23):"";
            double oCustAmt=rsO.getDouble(24);
            String oCm=rsO.getString(25)!=null?rsO.getString(25):"";
            // New values
            String nPnr=pnr!=null?pnr.trim():""; String nBDate=bookingDate!=null?bookingDate:"";
            String nOwDate=onewayDate!=null?onewayDate:""; String nOwTime=onewayTime!=null?onewayTime:"";
            String nOwFlt=onewayFlightNo!=null?onewayFlightNo.trim():""; String nOwAir=onewayAirlines!=null?onewayAirlines.trim():"";
            String nRetDate=returnDate!=null?returnDate:""; String nRetTime=returnTime!=null?returnTime:"";
            String nRetFlt=returnFlightNo!=null?returnFlightNo.trim():""; String nRetAir=returnAirlines!=null?returnAirlines.trim():"";
            String nPhone=phone!=null?phone.trim():""; String nCustN=customerName!=null?customerName.trim():"";
            double nBuyAmt=buyAmount!=null?buyAmount:0; double nSellAmt=sellAmount!=null?sellAmount:0; double nCustAmt=customerAmount!=null?customerAmount:0;
            // Compare & append
            if(!oPnr.equals(nPnr))             _cd.append("PNR: ").append(oPnr).append(" → ").append(nPnr).append("\n");
            if(!oBDate.equals(nBDate))          _cd.append("Booking Date: ").append(oBDate).append(" → ").append(nBDate).append("\n");
            if(!oOwDate.equals(nOwDate))        _cd.append("Travel Date: ").append(oOwDate).append(" → ").append(nOwDate).append("\n");
            if(!oOwTime.equals(nOwTime))        _cd.append("Travel Time: ").append(oOwTime).append(" → ").append(nOwTime).append("\n");
            if(!oOwf.equals(nOwf))              _cd.append("From: ").append(oOwf).append(" → ").append(nOwf).append("\n");
            if(!oOwt.equals(nOwt))              _cd.append("To: ").append(oOwt).append(" → ").append(nOwt).append("\n");
            if(!oOwFlt.equals(nOwFlt))          _cd.append("Flight No: ").append(oOwFlt).append(" → ").append(nOwFlt).append("\n");
            if(!oOwAir.equals(nOwAir))          _cd.append("Airlines: ").append(oOwAir).append(" → ").append(nOwAir).append("\n");
            if(!oRetDate.equals(nRetDate))      _cd.append("Return Date: ").append(oRetDate).append(" → ").append(nRetDate).append("\n");
            if(!oRetTime.equals(nRetTime))      _cd.append("Return Time: ").append(oRetTime).append(" → ").append(nRetTime).append("\n");
            if(!oRtf.equals(nRtf))              _cd.append("Ret From: ").append(oRtf).append(" → ").append(nRtf).append("\n");
            if(!oRtt.equals(nRtt))              _cd.append("Ret To: ").append(oRtt).append(" → ").append(nRtt).append("\n");
            if(!oRetFlt.equals(nRetFlt))        _cd.append("Ret Flight: ").append(oRetFlt).append(" → ").append(nRetFlt).append("\n");
            if(!oRetAir.equals(nRetAir))        _cd.append("Ret Airlines: ").append(oRetAir).append(" → ").append(nRetAir).append("\n");
            if(oSeats!=noOfSeats)               _cd.append("Seats: ").append(oSeats).append(" → ").append(noOfSeats).append("\n");
            if(!oPhone.equals(nPhone))          _cd.append("Phone: ").append(oPhone).append(" → ").append(nPhone).append("\n");
            if(!oBa.equals(nBa))                _cd.append("Buy Agent: ").append(oBa).append(" → ").append(nBa).append("\n");
            if(Math.abs(oBuyAmt-nBuyAmt)>0.005) _cd.append("Buy Amt: ").append(String.format("%.2f",oBuyAmt)).append(" → ").append(String.format("%.2f",nBuyAmt)).append("\n");
            if(!oBm.equals(nBm))                _cd.append("Buy Mode: ").append(oBm).append(" → ").append(nBm).append("\n");
            if(!oSa.equals(nSa))                _cd.append("Sell Agent: ").append(oSa).append(" → ").append(nSa).append("\n");
            if(Math.abs(oSellAmt-nSellAmt)>0.005) _cd.append("Sell Amt: ").append(String.format("%.2f",oSellAmt)).append(" → ").append(String.format("%.2f",nSellAmt)).append("\n");
            if(!oSm.equals(nSm))                _cd.append("Sell Mode: ").append(oSm).append(" → ").append(nSm).append("\n");
            if(!oCustN.equals(nCustN))          _cd.append("Customer: ").append(oCustN).append(" → ").append(nCustN).append("\n");
            if(Math.abs(oCustAmt-nCustAmt)>0.005) _cd.append("Cust Amt: ").append(String.format("%.2f",oCustAmt)).append(" → ").append(String.format("%.2f",nCustAmt)).append("\n");
            if(!oCm.equals(nCm))                _cd.append("Cust Mode: ").append(oCm).append(" → ").append(nCm).append("\n");
        }
        rsO.close(); ptO.close();
        String _descStr = _cd.toString().trim();

        // 1. Update booking header
        pt = con.prepareStatement(
            "UPDATE ticket_booking SET" +
            " pnr=?, booking_date=?," +
            " oneway_travel_date=?, oneway_travel_time=?, oneway_from_id=?, oneway_to_id=?," +
            " oneway_flight_no=?, oneway_airlines=?," +
            " return_travel_date=?, return_travel_time=?, return_from_id=?, return_to_id=?," +
            " return_flight_no=?, return_airlines=?," +
            " no_of_seats=?, phone=?," +
            " buy_agent_id=?, buy_amount=?, buy_payment_mode_id=?," +
            " sell_agent_id=?, sell_amount=?, sell_payment_mode_id=?," +
            " customer_name=?, customer_amount=?, customer_payment_mode_id=?" +
            " WHERE id=?");
        pt.setString(1, pnr);
        pt.setString(2, bookingDate);
        pt.setString(3, (onewayDate!=null&&!onewayDate.isEmpty()) ? onewayDate : null);
        pt.setString(4, (onewayTime!=null&&!onewayTime.isEmpty()) ? onewayTime : null);
        pt.setInt(5, onewayFromId);
        pt.setInt(6, onewayToId);
        pt.setString(7, (onewayFlightNo!=null&&!onewayFlightNo.isEmpty()) ? onewayFlightNo : null);
        pt.setString(8, (onewayAirlines!=null&&!onewayAirlines.isEmpty()) ? onewayAirlines : null);
        pt.setString(9, (returnDate!=null&&!returnDate.isEmpty()) ? returnDate : null);
        pt.setString(10, (returnTime!=null&&!returnTime.isEmpty()) ? returnTime : null);
        if (returnFromId!=null) pt.setInt(11, returnFromId); else pt.setNull(11, Types.INTEGER);
        if (returnToId!=null)   pt.setInt(12, returnToId);   else pt.setNull(12, Types.INTEGER);
        pt.setString(13, (returnFlightNo!=null&&!returnFlightNo.isEmpty()) ? returnFlightNo : null);
        pt.setString(14, (returnAirlines!=null&&!returnAirlines.isEmpty()) ? returnAirlines : null);
        pt.setInt(15, noOfSeats);
        pt.setString(16, (phone!=null&&!phone.isEmpty()) ? phone : null);
        if (buyAgentId!=null) pt.setInt(17, buyAgentId); else pt.setNull(17, Types.INTEGER);
        if (buyAmount!=null)  pt.setDouble(18, buyAmount); else pt.setNull(18, Types.DOUBLE);
        if (buyModeId!=null)  pt.setInt(19, buyModeId);   else pt.setNull(19, Types.INTEGER);
        if (sellAgentId!=null) pt.setInt(20, sellAgentId); else pt.setNull(20, Types.INTEGER);
        if (sellAmount!=null)  pt.setDouble(21, sellAmount); else pt.setNull(21, Types.DOUBLE);
        if (sellModeId!=null)  pt.setInt(22, sellModeId);   else pt.setNull(22, Types.INTEGER);
        pt.setString(23, (customerName!=null&&!customerName.isEmpty()) ? customerName : null);
        if (customerAmount!=null) pt.setDouble(24, customerAmount); else pt.setNull(24, Types.DOUBLE);
        if (custModeId!=null) pt.setInt(25, custModeId); else pt.setNull(25, Types.INTEGER);
        pt.setInt(26, bookingId);
        pt.executeUpdate(); pt.close();

        // 1b. Update ledger bill_amount and payment_mode for each party
        if (buyAgentId != null && buyAmount != null) {
            pt = con.prepareStatement(
                "UPDATE ticket_ledger SET bill_amount=?, payment_mode_id=?" +
                " WHERE booking_id=? AND party_type='BUY_AGENT'" +
                " AND COALESCE(bill_amount,0) > 0 AND COALESCE(charge_type,'ORIGINAL') = 'ORIGINAL'");
            pt.setDouble(1, buyAmount);
            if (buyModeId != null) pt.setInt(2, buyModeId); else pt.setNull(2, Types.INTEGER);
            pt.setInt(3, bookingId);
            pt.executeUpdate(); pt.close();
        }
        if (sellAgentId != null && sellAmount != null) {
            pt = con.prepareStatement(
                "UPDATE ticket_ledger SET bill_amount=?, payment_mode_id=?" +
                " WHERE booking_id=? AND party_type='SELL_AGENT'" +
                " AND COALESCE(bill_amount,0) > 0 AND COALESCE(charge_type,'ORIGINAL') = 'ORIGINAL'");
            pt.setDouble(1, sellAmount);
            if (sellModeId != null) pt.setInt(2, sellModeId); else pt.setNull(2, Types.INTEGER);
            pt.setInt(3, bookingId);
            pt.executeUpdate(); pt.close();
        }
        if (customerAmount != null) {
            pt = con.prepareStatement(
                "UPDATE ticket_ledger SET bill_amount=?, payment_mode_id=?" +
                " WHERE booking_id=? AND party_type='CUSTOMER'" +
                " AND COALESCE(bill_amount,0) > 0 AND COALESCE(charge_type,'ORIGINAL') = 'ORIGINAL'");
            pt.setDouble(1, customerAmount);
            if (custModeId != null) pt.setInt(2, custModeId); else pt.setNull(2, Types.INTEGER);
            pt.setInt(3, bookingId);
            pt.executeUpdate(); pt.close();
        }

        // 1c. Date Change Charge – Buy side
        if (buyDCAmt != null && buyDCAmt > 0) {
            double buyDCPaidVal = (buyDCPaid != null) ? buyDCPaid : 0.0;
            pt = con.prepareStatement(
                "UPDATE ticket_booking SET buy_amount=COALESCE(buy_amount,0)+?," +
                " buy_paid_amount=COALESCE(buy_paid_amount,0)+?," +
                " buy_date_change_amt=COALESCE(buy_date_change_amt,0)+?," +
                " buy_date_change_paid=COALESCE(buy_date_change_paid,0)+?" +
                " WHERE id=?");
            pt.setDouble(1, buyDCAmt); pt.setDouble(2, buyDCPaidVal);
            pt.setDouble(3, buyDCAmt); pt.setDouble(4, buyDCPaidVal);
            pt.setInt(5, bookingId);
            pt.executeUpdate(); pt.close();
            // Ledger: Buy agent date change charge (CR – we owe more to agent)
            pt = con.prepareStatement(
                "INSERT INTO ticket_ledger" +
                " (booking_id,party_type,agent_id,party_name,transaction_type,bill_amount,amount,payment_mode_id,transaction_no,remarks,transaction_date,charge_type)" +
                " VALUES (?,?,?,?,?,?,?,?,?,?,?,?)");
            pt.setInt(1, bookingId);
            pt.setString(2, "BUY_AGENT");
            if (buyAgentId != null) pt.setInt(3, buyAgentId); else pt.setNull(3, Types.INTEGER);
            pt.setNull(4, Types.VARCHAR);
            pt.setString(5, "CR");
            pt.setDouble(6, buyDCAmt);
            pt.setDouble(7, buyDCPaidVal);
            if (buyDCModeId != null) pt.setInt(8, buyDCModeId); else pt.setNull(8, Types.INTEGER);
            if (buyDCTxnNo != null && !buyDCTxnNo.isEmpty()) pt.setString(9, buyDCTxnNo); else pt.setNull(9, Types.VARCHAR);
            pt.setString(10, "Date Change | PNR: " + (pnr != null ? pnr : "-"));
            pt.setString(11, today);
            pt.setString(12, "DATE_CHANGE");
            pt.executeUpdate(); pt.close();
        }

        // 1d. Date Change Charge – Sell side
        if (sellDCAmt != null && sellDCAmt > 0) {
            double sellDCPaidVal = (sellDCPaid != null) ? sellDCPaid : 0.0;
            boolean isSellAgent = (sellAgentId != null);
            if (isSellAgent) {
                pt = con.prepareStatement(
                    "UPDATE ticket_booking SET sell_amount=COALESCE(sell_amount,0)+?," +
                    " sell_paid_amount=COALESCE(sell_paid_amount,0)+?," +
                    " sell_date_change_amt=COALESCE(sell_date_change_amt,0)+?," +
                    " sell_date_change_paid=COALESCE(sell_date_change_paid,0)+?" +
                    " WHERE id=?");
            } else {
                pt = con.prepareStatement(
                    "UPDATE ticket_booking SET customer_amount=COALESCE(customer_amount,0)+?," +
                    " cust_paid_amount=COALESCE(cust_paid_amount,0)+?," +
                    " sell_date_change_amt=COALESCE(sell_date_change_amt,0)+?," +
                    " sell_date_change_paid=COALESCE(sell_date_change_paid,0)+?" +
                    " WHERE id=?");
            }
            pt.setDouble(1, sellDCAmt); pt.setDouble(2, sellDCPaidVal);
            pt.setDouble(3, sellDCAmt); pt.setDouble(4, sellDCPaidVal);
            pt.setInt(5, bookingId);
            pt.executeUpdate(); pt.close();
            // Ledger: Sell side date change charge (DR – they owe us more)
            pt = con.prepareStatement(
                "INSERT INTO ticket_ledger" +
                " (booking_id,party_type,agent_id,party_name,transaction_type,bill_amount,amount,payment_mode_id,transaction_no,remarks,transaction_date,charge_type)" +
                " VALUES (?,?,?,?,?,?,?,?,?,?,?,?)");
            pt.setInt(1, bookingId);
            pt.setString(2, isSellAgent ? "SELL_AGENT" : "CUSTOMER");
            if (isSellAgent && sellAgentId != null) pt.setInt(3, sellAgentId); else pt.setNull(3, Types.INTEGER);
            if (!isSellAgent && customerName != null && !customerName.isEmpty()) pt.setString(4, customerName); else pt.setNull(4, Types.VARCHAR);
            pt.setString(5, "DR");
            pt.setDouble(6, sellDCAmt);
            pt.setDouble(7, sellDCPaidVal);
            if (sellDCModeId != null) pt.setInt(8, sellDCModeId); else pt.setNull(8, Types.INTEGER);
            if (sellDCTxnNo != null && !sellDCTxnNo.isEmpty()) pt.setString(9, sellDCTxnNo); else pt.setNull(9, Types.VARCHAR);
            pt.setString(10, "Date Change | PNR: " + (pnr != null ? pnr : "-"));
            pt.setString(11, today);
            pt.setString(12, "DATE_CHANGE");
            pt.executeUpdate(); pt.close();
        }

        // 2. Replace passengers
        pt = con.prepareStatement("DELETE FROM ticket_passenger WHERE booking_id=?");
        pt.setInt(1, bookingId); pt.executeUpdate(); pt.close();
        if (passengerNames != null && passengerNames.length > 0) {
            pt = con.prepareStatement(
                "INSERT INTO ticket_passenger (booking_id, seat_no, passenger_name) VALUES (?,?,?)");
            for (int i = 0; i < passengerNames.length; i++) {
                String pn = (passengerNames[i]!=null) ? passengerNames[i].trim() : "";
                pt.setInt(1, bookingId); pt.setInt(2, i+1); pt.setString(3, pn);
                pt.addBatch();
            }
            pt.executeBatch(); pt.close();
        }

        // 3. Autocomplete lookups
        if (onewayFlightNo!=null&&!onewayFlightNo.trim().isEmpty()) {
            pt = con.prepareStatement("INSERT IGNORE INTO ticket_flightno (value) VALUES (?)");
            pt.setString(1, onewayFlightNo.trim()); pt.executeUpdate(); pt.close();
        }
        if (onewayAirlines!=null&&!onewayAirlines.trim().isEmpty()) {
            pt = con.prepareStatement("INSERT IGNORE INTO ticket_airline (value) VALUES (?)");
            pt.setString(1, onewayAirlines.trim()); pt.executeUpdate(); pt.close();
        }
        if (returnFlightNo!=null&&!returnFlightNo.trim().isEmpty()) {
            pt = con.prepareStatement("INSERT IGNORE INTO ticket_flightno (value) VALUES (?)");
            pt.setString(1, returnFlightNo.trim()); pt.executeUpdate(); pt.close();
        }
        if (returnAirlines!=null&&!returnAirlines.trim().isEmpty()) {
            pt = con.prepareStatement("INSERT IGNORE INTO ticket_airline (value) VALUES (?)");
            pt.setString(1, returnAirlines.trim()); pt.executeUpdate(); pt.close();
        }

        // 4. Fetch ticket_no / pnr for log
        pt = con.prepareStatement("SELECT ticket_no, pnr FROM ticket_booking WHERE id=? LIMIT 1");
        pt.setInt(1, bookingId);
        ResultSet rs2 = pt.executeQuery();
        String tktNo="", pnrVal="";
        if (rs2.next()) { tktNo=rs2.getString(1)!=null?rs2.getString(1):""; pnrVal=rs2.getString(2)!=null?rs2.getString(2):""; }
        rs2.close(); pt.close();

        // 5. Fetch user name for log
        pt = con.prepareStatement("SELECT fullName FROM users WHERE id=? LIMIT 1");
        pt.setInt(1, updatedBy);
        ResultSet rsn = pt.executeQuery();
        String uname = rsn.next() ? (rsn.getString(1)!=null?rsn.getString(1):"") : "";
        rsn.close(); pt.close();

        // 6. Insert audit log
        pt = con.prepareStatement(
            "INSERT INTO ticket_booking_log (booking_id,ticket_no,pnr,action_type,changed_by,user_name,change_date,change_time,remarks,description) VALUES (?,?,?,?,?,?,?,?,?,?)");
        pt.setInt(1, bookingId); pt.setString(2, tktNo); pt.setString(3, pnrVal);
        pt.setString(4, "EDIT"); pt.setInt(5, updatedBy); pt.setString(6, uname);
        pt.setString(7, today); pt.setString(8, now);
        pt.setString(9, remarks!=null?remarks:"");
        if (_descStr.isEmpty()) pt.setNull(10, Types.VARCHAR); else pt.setString(10, _descStr);
        pt.executeUpdate(); pt.close();

        con.commit();
    } catch (Exception e) {
        if (con!=null) try { con.rollback(); } catch (SQLException ex) {}
        throw e;
    } finally {
        if (pt!=null)  try { pt.close();  } catch (Exception e) {}
        if (con!=null) try { con.setAutoCommit(true); } catch (Exception e) {}
        if (con!=null) try { con.close(); } catch (Exception e) {}
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// CANCEL TICKET BOOKING  –  soft-cancel + audit log
// ─────────────────────────────────────────────────────────────────────────────
public void cancelTicketBooking(int bookingId, int cancelledBy, String reason,
        Double cancelChargeBuy, Integer cancelModeBuy,
        Double cancelChargeSell, Integer cancelModeSell) throws Exception {
    Connection con = null; PreparedStatement pt = null;
    String today = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
    String now   = new java.text.SimpleDateFormat("HH:mm:ss").format(new java.util.Date());
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);

        pt = con.prepareStatement("UPDATE ticket_booking SET is_cancelled=1 WHERE id=?");
        pt.setInt(1, bookingId); pt.executeUpdate(); pt.close();

        // Fetch booking details + paid amounts for refund calculation
        pt = con.prepareStatement(
            "SELECT ticket_no, pnr, buy_agent_id, sell_agent_id, customer_name," +
            " COALESCE(buy_amount,0), COALESCE(sell_amount,0), COALESCE(customer_amount,0)," +
            " COALESCE(buy_paid_amount,0), COALESCE(sell_paid_amount,0), COALESCE(cust_paid_amount,0)" +
            " FROM ticket_booking WHERE id=? LIMIT 1");
        pt.setInt(1, bookingId);
        ResultSet rs2 = pt.executeQuery();
        String tktNo="", pnrVal="";
        int origBuyAgentId = 0; boolean hasBuyAgent = false;
        int origSellAgentId = 0; boolean hasSellAgent = false;
        String origCustName = "";
        double buyBillAmt = 0, sellBillAmt = 0;
        double buyPaidAmt = 0, sellPaidAmt = 0;
        if (rs2.next()) {
            tktNo    = rs2.getString(1) != null ? rs2.getString(1) : "";
            pnrVal   = rs2.getString(2) != null ? rs2.getString(2) : "";
            if (rs2.getObject(3) != null) { origBuyAgentId  = rs2.getInt(3);  hasBuyAgent  = true; }
            if (rs2.getObject(4) != null) { origSellAgentId = rs2.getInt(4);  hasSellAgent = true; }
            origCustName = rs2.getString(5) != null ? rs2.getString(5) : "";
            buyBillAmt   = rs2.getDouble(6);
            // sell_amount when sell agent, customer_amount when direct customer
            sellBillAmt  = hasSellAgent ? rs2.getDouble(7) : rs2.getDouble(8);
            buyPaidAmt   = rs2.getDouble(9);
            sellPaidAmt  = hasSellAgent ? rs2.getDouble(10) : rs2.getDouble(11);
        }
        rs2.close(); pt.close();

        // Refund = amount already paid minus cancel charge (not full bill minus charge)
        double calcRefundBuy  = (cancelChargeBuy  != null) ? Math.max(0, buyPaidAmt  - cancelChargeBuy)  : 0;
        double calcRefundSell = (cancelChargeSell != null) ? Math.max(0, sellPaidAmt - cancelChargeSell) : 0;

        // Update cancel charge/refund columns in ticket_booking
        pt = con.prepareStatement(
            "UPDATE ticket_booking SET" +
            " cancel_charge_buy=?, refund_received_buy=?," +
            " cancel_charge_sell=?, refund_to_sell=?" +
            " WHERE id=?");
        pt.setDouble(1, cancelChargeBuy  != null ? cancelChargeBuy  : 0.0);
        pt.setDouble(2, calcRefundBuy);
        pt.setDouble(3, cancelChargeSell != null ? cancelChargeSell : 0.0);
        pt.setDouble(4, calcRefundSell);
        pt.setInt(5, bookingId);
        pt.executeUpdate(); pt.close();

        String ledSql =
            "INSERT INTO ticket_ledger" +
            " (booking_id,party_type,agent_id,party_name,transaction_type,bill_amount,amount,payment_mode_id,transaction_no,remarks,transaction_date,charge_type,cancel_charge)" +
            " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)";

        // Buy Agent cancel – record cancel charge + refund due (including 0 charge)
        if (cancelChargeBuy != null && hasBuyAgent) {
            pt = con.prepareStatement(ledSql);
            pt.setInt(1, bookingId);
            pt.setString(2, "BUY_AGENT");
            pt.setInt(3, origBuyAgentId);
            pt.setNull(4, Types.VARCHAR);
            pt.setString(5, "DR");
            pt.setDouble(6, calcRefundBuy); pt.setDouble(7, 0.0);
            pt.setNull(8, Types.INTEGER);
            pt.setNull(9, Types.VARCHAR);
            pt.setString(10, "Cancel | PNR: " + pnrVal);
            pt.setString(11, today); pt.setString(12, "CANCEL_CHARGE");
            pt.setDouble(13, cancelChargeBuy);
            pt.executeUpdate(); pt.close();
        }

        // Sell side cancel – record cancel charge + refund due (including 0 charge)
        if (cancelChargeSell != null && (hasSellAgent || sellBillAmt > 0.005 || sellPaidAmt > 0.005)) {
            String sParty = hasSellAgent ? "SELL_AGENT" : "CUSTOMER";
            pt = con.prepareStatement(ledSql);
            pt.setInt(1, bookingId);
            pt.setString(2, sParty);
            if (hasSellAgent) pt.setInt(3, origSellAgentId); else pt.setNull(3, Types.INTEGER);
            if (!hasSellAgent && !origCustName.isEmpty()) pt.setString(4, origCustName); else pt.setNull(4, Types.VARCHAR);
            pt.setString(5, "CR");
            pt.setDouble(6, calcRefundSell); pt.setDouble(7, 0.0);
            pt.setNull(8, Types.INTEGER);
            pt.setNull(9, Types.VARCHAR);
            pt.setString(10, "Cancel | PNR: " + pnrVal);
            pt.setString(11, today); pt.setString(12, "CANCEL_CHARGE");
            pt.setDouble(13, cancelChargeSell);
            pt.executeUpdate(); pt.close();
        }

        pt = con.prepareStatement("SELECT fullName FROM users WHERE id=? LIMIT 1");
        pt.setInt(1, cancelledBy);
        ResultSet rsn = pt.executeQuery();
        String uname = rsn.next() ? (rsn.getString(1)!=null?rsn.getString(1):"") : "";
        rsn.close(); pt.close();

        pt = con.prepareStatement(
            "INSERT INTO ticket_booking_log (booking_id,ticket_no,pnr,action_type,changed_by,user_name,change_date,change_time,remarks) VALUES (?,?,?,?,?,?,?,?,?)");
        pt.setInt(1, bookingId); pt.setString(2, tktNo); pt.setString(3, pnrVal);
        pt.setString(4, "CANCEL"); pt.setInt(5, cancelledBy); pt.setString(6, uname);
        pt.setString(7, today); pt.setString(8, now);
        pt.setString(9, reason!=null?reason:"");
        pt.executeUpdate(); pt.close();

        con.commit();
    } catch (Exception e) {
        if (con!=null) try { con.rollback(); } catch (SQLException ex) {}
        throw e;
    } finally {
        if (pt!=null)  try { pt.close();  } catch (Exception e) {}
        if (con!=null) try { con.setAutoCommit(true); } catch (Exception e) {}
        if (con!=null) try { con.close(); } catch (Exception e) {}
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET BOOKING LOGS  –  for edit/cancel report
// Row: [0]id [1]booking_id [2]ticket_no [3]pnr [4]action_type
//      [5]user_name [6]change_date [7]change_time [8]remarks
// ─────────────────────────────────────────────────────────────────────────────
public Vector getBookingLogs(String fromDate, String toDate) {
    Vector result = new Vector();
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement(
            "SELECT id, booking_id, ticket_no, pnr, action_type, user_name, change_date, change_time, remarks, description" +
            " FROM ticket_booking_log WHERE change_date BETWEEN ? AND ? ORDER BY id DESC");
        pt.setString(1, fromDate); pt.setString(2, toDate);
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++) row.add(rs.getObject(i));
            result.add(row);
        }
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        try { if (rs!=null) rs.close(); } catch (Exception e) {}
        try { if (pt!=null) pt.close(); } catch (Exception e) {}
        try { if (con!=null) con.close(); } catch (Exception e) {}
    }
    return result;
}

// ─────────────────────────────────────────────────────────────────────────────
// GET TICKET BY ID  –  identical columns to getPNRDetails but keyed by b.id
// ─────────────────────────────────────────────────────────────────────────────
public Vector getTicketById(int id) {
    Vector result = new Vector();
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String sql =
            "SELECT b.id, b.pnr, b.booking_date," +
            " b.oneway_travel_date, b.oneway_travel_time," +
            " cf.name AS ow_from, ct.name AS ow_to," +
            " b.oneway_flight_no, b.oneway_airlines," +
            " b.return_travel_date, b.return_travel_time," +
            " rf.name AS ret_from, rt2.name AS ret_to," +
            " b.return_flight_no, b.return_airlines," +
            " b.no_of_seats, b.phone," +
            " ba.name AS buy_agent, b.buy_amount, bm.modes AS buy_mode," +
            " sa.name AS sell_agent, b.sell_amount, sm.modes AS sell_mode," +
            " b.customer_name, b.customer_amount, cm.modes AS cust_mode," +
            " b.created_at" +
            " FROM ticket_booking b" +
            " LEFT JOIN ticket_city cf  ON cf.id  = b.oneway_from_id" +
            " LEFT JOIN ticket_city ct  ON ct.id  = b.oneway_to_id" +
            " LEFT JOIN ticket_city rf  ON rf.id  = b.return_from_id" +
            " LEFT JOIN ticket_city rt2 ON rt2.id = b.return_to_id" +
            " LEFT JOIN ticket_agent ba ON ba.id  = b.buy_agent_id" +
            " LEFT JOIN ticket_agent sa ON sa.id  = b.sell_agent_id" +
            " LEFT JOIN ticket_payment_mode bm ON bm.id = b.buy_payment_mode_id" +
            " LEFT JOIN ticket_payment_mode sm ON sm.id = b.sell_payment_mode_id" +
            " LEFT JOIN ticket_payment_mode cm ON cm.id = b.customer_payment_mode_id" +
            " WHERE b.id = ? LIMIT 1";  // ticket_no appended
        sql = sql.replace("b.created_at", "b.created_at, b.ticket_no, COALESCE(b.sell_paid_amount, 0) AS sell_paid, COALESCE(b.cust_paid_amount, 0) AS cust_paid");
        pt = con.prepareStatement(sql);
        pt.setInt(1, id);
        rs = pt.executeQuery();
        if (rs.next()) {
            Vector row = new Vector();
            for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++)
                row.add(rs.getObject(i));
            result.add(row);
        }
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        try { if (rs!=null) rs.close(); } catch (Exception e) {}
        try { if (pt!=null) pt.close(); } catch (Exception e) {}
        try { if (con!=null) con.close(); } catch (Exception e) {}
    }
    return result;
}

// ─────────────────────────────────────────────────────────────────────────────
// TICKET REPORT  –  filter by date range; optionally filter by payment mode
// paymentModeId: 0 = all; >0 = filter on buy OR sell OR customer payment mode
// ─────────────────────────────────────────────────────────────────────────────
public Vector getTicketReport(String dateType, String fromDate, String toDate, int paymentModeId) {
    Vector result = new Vector();
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String dateCol = "travel".equalsIgnoreCase(dateType) ? "b.oneway_travel_date" : "b.booking_date";
        String modeFilter = (paymentModeId > 0)
            ? " AND (b.buy_payment_mode_id = ? OR b.sell_payment_mode_id = ? OR b.customer_payment_mode_id = ?)"
            : "";
        String sql =
            "SELECT b.id, b.pnr, b.booking_date," +
            " b.oneway_travel_date, b.oneway_travel_time," +
            " cf.name AS ow_from, ct.name AS ow_to," +
            " b.oneway_flight_no, b.oneway_airlines," +
            " b.return_travel_date, b.return_travel_time," +
            " rf.name AS ret_from, rt2.name AS ret_to," +
            " b.return_flight_no, b.return_airlines," +
            " b.no_of_seats, b.phone," +
            " ba.name AS buy_agent, b.buy_amount, bm.modes AS buy_mode," +
            " sa.name AS sell_agent, b.sell_amount, sm.modes AS sell_mode," +
            " b.customer_name, b.customer_amount, cm.modes AS cust_mode," +
            " b.created_at, b.ticket_no" +
            " FROM ticket_booking b" +
            " LEFT JOIN ticket_city cf  ON cf.id  = b.oneway_from_id" +
            " LEFT JOIN ticket_city ct  ON ct.id  = b.oneway_to_id" +
            " LEFT JOIN ticket_city rf  ON rf.id  = b.return_from_id" +
            " LEFT JOIN ticket_city rt2 ON rt2.id = b.return_to_id" +
            " LEFT JOIN ticket_agent ba ON ba.id  = b.buy_agent_id" +
            " LEFT JOIN ticket_agent sa ON sa.id  = b.sell_agent_id" +
            " LEFT JOIN ticket_payment_mode bm ON bm.id = b.buy_payment_mode_id" +
            " LEFT JOIN ticket_payment_mode sm ON sm.id = b.sell_payment_mode_id" +
            " LEFT JOIN ticket_payment_mode cm ON cm.id = b.customer_payment_mode_id" +
            " WHERE " + dateCol + " BETWEEN ? AND ? AND COALESCE(b.is_cancelled,0)=0" + modeFilter +
            " ORDER BY b.booking_date ASC";
        pt = con.prepareStatement(sql);
        pt.setString(1, fromDate);
        pt.setString(2, toDate);
        if (paymentModeId > 0) {
            pt.setInt(3, paymentModeId);
            pt.setInt(4, paymentModeId);
            pt.setInt(5, paymentModeId);
        }
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++)
                row.add(rs.getObject(i));
            result.add(row);
        }
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        try { if (rs!=null) rs.close(); } catch (Exception e) {}
        try { if (pt!=null) pt.close(); } catch (Exception e) {}
        try { if (con!=null) con.close(); } catch (Exception e) {}
    }
    return result;
}

// backward-compat overload (no payment mode filter)
public Vector getTicketReport(String dateType, String fromDate, String toDate) {
    return getTicketReport(dateType, fromDate, toDate, 0);
}

// ─────────────────────────────────────────────────────────────────────────────
// TICKET LEDGER REPORT — individual ledger rows (incl. cancel entries)
// Row: [0]booking_id [1]ticket_no [2]pnr [3]party_type [4]party_display
//      [5]bill_amount [6]paid_amount [7]line_balance [8]transaction_date
//      [9]agent_id [10]party_name [11]payment_mode [12]txn_no [13]passengers
//      [14]transaction_type [15]remarks [16]charge_type [17]txn_time [18]ledger_id
//      [19]cancel_charge [20]is_cancelled
// ─────────────────────────────────────────────────────────────────────────────
public Vector getTicketLedgerReport(String fromDate, String toDate, int agentId) {
    Vector result = new Vector();
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String sql =
            "SELECT l.booking_id," +
            " CASE WHEN l.booking_id > 0 THEN COALESCE(b.ticket_no, CONCAT('TKT-', LPAD(b.id, 3, '0'))) ELSE '-' END AS ticket_no," +
            " COALESCE(b.pnr, '-') AS pnr," +
            " l.party_type," +
            " COALESCE(a.name, l.party_name, '-') AS party_display," +
            " COALESCE(l.bill_amount, 0) AS bill_amount," +
            " COALESCE(l.amount, 0) AS paid_amount," +
            " CASE WHEN COALESCE(l.bill_amount, 0) > 0 THEN COALESCE(l.bill_amount, 0) - COALESCE(l.amount, 0)" +
            "      ELSE COALESCE(l.amount, 0) END AS line_balance," +
            " l.transaction_date," +
            " l.agent_id, l.party_name," +
            " COALESCE(pm.modes, '') AS payment_mode_name," +
            " COALESCE(l.transaction_no, '') AS txn_no," +
            " COALESCE(pax.pax_names, '') AS passenger_names," +
            " l.transaction_type," +
            " COALESCE(l.remarks, '') AS remarks," +
            " COALESCE(l.charge_type, '') AS charge_type," +
            " COALESCE(DATE_FORMAT(l.created_at, '%H:%i'), '') AS txn_time," +
            " l.id AS ledger_id," +
            " COALESCE(l.cancel_charge, 0) AS cancel_charge," +
            " COALESCE(b.is_cancelled, 0) AS is_cancelled" +
            " FROM ticket_ledger l" +
            " LEFT JOIN ticket_booking b ON b.id = l.booking_id AND l.booking_id > 0" +
            " LEFT JOIN ticket_agent a ON a.id = l.agent_id" +
            " LEFT JOIN ticket_payment_mode pm ON pm.id = l.payment_mode_id" +
            " LEFT JOIN (SELECT booking_id, GROUP_CONCAT(passenger_name ORDER BY seat_no SEPARATOR ', ') AS pax_names" +
            "            FROM ticket_passenger GROUP BY booking_id) pax ON pax.booking_id = l.booking_id AND l.booking_id > 0" +
            " WHERE l.transaction_date BETWEEN ? AND ?" +
            " AND l.agent_id IS NOT NULL" +
            (agentId > 0 ? " AND l.agent_id = ?" : "") +
            " ORDER BY l.transaction_date ASC, l.created_at ASC, l.id ASC";
        pt = con.prepareStatement(sql);
        pt.setString(1, fromDate);
        pt.setString(2, toDate);
        if (agentId > 0) pt.setInt(3, agentId);
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++)
                row.add(rs.getObject(i));
            result.add(row);
        }
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return result;
}

// Pending balance for a cancelled booking on one party side
public double getBookingCancelPendingBalance(int bookingId, String partyType) {
    if (bookingId <= 0 || partyType == null) return 0;
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String sql;
        if ("BUY_AGENT".equals(partyType)) {
            sql =
                "SELECT (COALESCE(b.cancel_charge_buy,0) - COALESCE(b.buy_paid_amount,0)" +
                "  - COALESCE((SELECT SUM(l.amount) FROM ticket_ledger l" +
                "    WHERE l.booking_id=b.id AND l.party_type='BUY_AGENT'" +
                "    AND COALESCE(l.bill_amount,0)=0),0)) AS pending_balance" +
                " FROM ticket_booking b WHERE b.id=? AND b.is_cancelled=1 LIMIT 1";
        } else if ("SELL_AGENT".equals(partyType)) {
            sql =
                "SELECT (COALESCE(b.sell_paid_amount,0) - COALESCE(b.cancel_charge_sell,0) - COALESCE(b.refund_to_sell,0)" +
                "  - COALESCE((SELECT SUM(l.amount) FROM ticket_ledger l" +
                "    WHERE l.booking_id=b.id AND l.party_type='SELL_AGENT'" +
                "    AND COALESCE(l.bill_amount,0)=0),0)) AS pending_balance" +
                " FROM ticket_booking b WHERE b.id=? AND b.is_cancelled=1 LIMIT 1";
        } else if ("CUSTOMER".equals(partyType)) {
            sql =
                "SELECT (COALESCE(b.cust_paid_amount,0) - COALESCE(b.cancel_charge_sell,0) - COALESCE(b.refund_to_sell,0)" +
                "  - COALESCE((SELECT SUM(l.amount) FROM ticket_ledger l" +
                "    WHERE l.booking_id=b.id AND l.party_type='CUSTOMER'" +
                "    AND COALESCE(l.bill_amount,0)=0),0)) AS pending_balance" +
                " FROM ticket_booking b WHERE b.id=? AND b.is_cancelled=1 LIMIT 1";
        } else {
            return 0;
        }
        pt = con.prepareStatement(sql);
        pt.setInt(1, bookingId);
        rs = pt.executeQuery();
        if (rs.next()) {
            Object v = rs.getObject("pending_balance");
            return v != null ? ((Number) v).doubleValue() : 0;
        }
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return 0;
}

// Ledger totals for one booking + party (sums all ticket_ledger rows incl. balance collections)
// Returns Vector: [0]totalBill [1]totalPaid [2]balance [3]balanceDir(DR/CR/NIL)
public Vector getBookingLedgerTotals(int bookingId, String partyType) {
    Vector result = new Vector();
    result.add(0.0);
    result.add(0.0);
    result.add(0.0);
    result.add("NIL");
    if (bookingId <= 0 || partyType == null) return result;

    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();

        pt = con.prepareStatement(
            "SELECT COALESCE(b.is_cancelled,0) AS is_cancelled FROM ticket_booking b WHERE b.id=? LIMIT 1");
        pt.setInt(1, bookingId);
        rs = pt.executeQuery();
        boolean isCancelled = rs.next() && rs.getInt("is_cancelled") == 1;
        rs.close(); rs = null; pt.close(); pt = null;

        if (isCancelled) {
            double pending = getBookingCancelPendingBalance(bookingId, partyType);
            double balance = Math.abs(pending);
            String dir = "NIL";
            if (pending > 0.005) dir = "CR";
            else if (pending < -0.005) dir = "DR";
            result.set(0, 0.0);
            result.set(1, 0.0);
            result.set(2, balance);
            result.set(3, dir);
            return result;
        }

        pt = con.prepareStatement(
            "SELECT COALESCE(SUM(COALESCE(l.bill_amount,0)),0) AS total_bill," +
            " COALESCE(SUM(COALESCE(l.amount,0)),0) AS total_paid" +
            " FROM ticket_ledger l" +
            " WHERE l.booking_id=? AND l.party_type=?" +
            " AND COALESCE(l.charge_type,'') <> 'CANCEL_CHARGE'");
        pt.setInt(1, bookingId);
        pt.setString(2, partyType);
        rs = pt.executeQuery();
        double totalBill = 0, totalPaid = 0;
        if (rs.next()) {
            totalBill = rs.getDouble("total_bill");
            totalPaid = rs.getDouble("total_paid");
        }

        double net = totalBill - totalPaid;
        double balance = 0;
        String dir = "NIL";
        if (net > 0.005) {
            balance = net;
            dir = "BUY_AGENT".equals(partyType) ? "CR" : "DR";
        }

        result.set(0, totalBill);
        result.set(1, totalPaid);
        result.set(2, balance);
        result.set(3, dir);
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return result;
}

// ─────────────────────────────────────────────────────────────────────────────
// COLLECTION REPORT  — Sell to Customer + Sell to Agent ledger (with balance collections)
// Row layout: [0]booking_id [1]ticket_no [2]pnr [3]party_type [4]party_display
//             [5]txn_type   [6]total_bill [7]total_paid [8]balance
//             [9]first_date [10]agent_id [11]party_name [12]ow_from [13]ow_to [14]booking_date
// partyTypeFilter: "" = both CUSTOMER+SELL_AGENT, "CUSTOMER", or "SELL_AGENT"
// agentId: 0 = all agents
// ─────────────────────────────────────────────────────────────────────────────
public Vector getCollectionReport(String fromDate, String toDate, int agentId, String partyTypeFilter) {
    Vector result = new Vector();
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String ptFilter;
        if ("CUSTOMER".equals(partyTypeFilter))   ptFilter = " AND l.party_type = 'CUSTOMER'";
        else if ("SELL_AGENT".equals(partyTypeFilter)) ptFilter = " AND l.party_type = 'SELL_AGENT'";
        else                                          ptFilter = " AND l.party_type IN ('CUSTOMER','SELL_AGENT')";
        String agFilter = (agentId > 0) ? " AND l.agent_id = ?" : "";
        String sql =
            "SELECT l.booking_id, b.ticket_no, b.pnr, l.party_type," +
            " COALESCE(a.name, l.party_name) AS party_display," +
            " l.transaction_type," +
            " SUM(COALESCE(l.bill_amount,0)) AS total_bill," +
            " SUM(COALESCE(l.amount,0)) AS total_paid," +
            " SUM(COALESCE(l.bill_amount,0)) - SUM(COALESCE(l.amount,0)) AS balance," +
            " MIN(l.transaction_date) AS first_date, l.agent_id, l.party_name," +
            " COALESCE(cf.name,'') AS ow_from, COALESCE(ct.name,'') AS ow_to, b.booking_date" +
            " FROM ticket_ledger l" +
            " JOIN ticket_booking b ON b.id = l.booking_id" +
            " LEFT JOIN ticket_agent a ON a.id = l.agent_id" +
            " LEFT JOIN ticket_city cf ON cf.id = b.oneway_from_id" +
            " LEFT JOIN ticket_city ct ON ct.id = b.oneway_to_id" +
            " WHERE l.transaction_date BETWEEN ? AND ? AND COALESCE(b.is_cancelled,0)=0" + ptFilter + agFilter +
            " GROUP BY l.booking_id, l.party_type, l.transaction_type, l.agent_id, l.party_name," +
            " b.ticket_no, b.pnr, a.name, cf.name, ct.name, b.booking_date" +
            " ORDER BY MIN(l.transaction_date) DESC, l.booking_id DESC";
        pt = con.prepareStatement(sql);
        pt.setString(1, fromDate);
        pt.setString(2, toDate);
        if (agentId > 0) pt.setInt(3, agentId);
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++) row.add(rs.getObject(i));
            result.add(row);
        }
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return result;
}

// ─────────────────────────────────────────────────────────────────────────────
// AGENT PAID REPORT  — Buy from Agent ledger (what we paid/owe to agents)
// Row layout: same as getCollectionReport above
// ─────────────────────────────────────────────────────────────────────────────
public Vector getAgentPaidReport(String fromDate, String toDate, int agentId) {
    Vector result = new Vector();
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String agFilter = (agentId > 0) ? " AND l.agent_id = ?" : "";
        String sql =
            "SELECT l.booking_id, b.ticket_no, b.pnr, l.party_type," +
            " COALESCE(a.name, l.party_name) AS party_display," +
            " l.transaction_type," +
            " SUM(COALESCE(l.bill_amount,0)) AS total_bill," +
            " SUM(COALESCE(l.amount,0)) AS total_paid," +
            " SUM(COALESCE(l.bill_amount,0)) - SUM(COALESCE(l.amount,0)) AS balance," +
            " MIN(l.transaction_date) AS first_date, l.agent_id, l.party_name," +
            " COALESCE(cf.name,'') AS ow_from, COALESCE(ct.name,'') AS ow_to, b.booking_date" +
            " FROM ticket_ledger l" +
            " JOIN ticket_booking b ON b.id = l.booking_id" +
            " LEFT JOIN ticket_agent a ON a.id = l.agent_id" +
            " LEFT JOIN ticket_city cf ON cf.id = b.oneway_from_id" +
            " LEFT JOIN ticket_city ct ON ct.id = b.oneway_to_id" +
            " WHERE l.party_type = 'BUY_AGENT' AND l.transaction_date BETWEEN ? AND ? AND COALESCE(b.is_cancelled,0)=0" + agFilter +
            " GROUP BY l.booking_id, l.party_type, l.transaction_type, l.agent_id, l.party_name," +
            " b.ticket_no, b.pnr, a.name, cf.name, ct.name, b.booking_date" +
            " ORDER BY MIN(l.transaction_date) DESC, l.booking_id DESC";
        pt = con.prepareStatement(sql);
        pt.setString(1, fromDate);
        pt.setString(2, toDate);
        if (agentId > 0) pt.setInt(3, agentId);
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++) row.add(rs.getObject(i));
            result.add(row);
        }
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return result;
}

// ─────────────────────────────────────────────────────────────────────────────
// COLLECT BALANCE — insert a balance-collection entry into ticket_ledger
// Returns "SUCCESS" or "ERROR:message"
// ─────────────────────────────────────────────────────────────────────────────
public String collectTicketBalance(int bookingId, String partyType, Integer agentId,
        String partyName, String txnType, double collectedAmount,
        Integer paymentModeId, String collectionDate, String transactionNo, Integer createdBy) {
    return collectTicketBalance(bookingId, partyType, agentId, partyName, txnType,
        collectedAmount, paymentModeId, collectionDate, transactionNo, null, createdBy);
}

public String collectTicketBalance(int bookingId, String partyType, Integer agentId,
    String partyName, String txnType, double collectedAmount,
    Integer paymentModeId, String collectionDate, String transactionNo,
    String notes, Integer createdBy) {
    Connection con = null; PreparedStatement pt = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);
        String sql =
            "INSERT INTO ticket_ledger " +
            "(booking_id, party_type, agent_id, party_name, transaction_type, bill_amount, amount, payment_mode_id, transaction_no, remarks, transaction_date, created_by) " +
            "VALUES (?,?,?,?,?,0,?,?,?,?,?,?)";
        pt = con.prepareStatement(sql);
        pt.setInt(1, bookingId);
        pt.setString(2, partyType);
        if (agentId != null) pt.setInt(3, agentId); else pt.setNull(3, Types.INTEGER);
        // Use NULL for party_name when agent_id is set (matches original booking entry GROUP BY)
        if (agentId != null) pt.setNull(4, Types.VARCHAR);
        else pt.setString(4, (partyName != null && !partyName.isEmpty()) ? partyName : "");
        pt.setString(5, txnType);
        pt.setDouble(6, collectedAmount);
        if (paymentModeId != null) pt.setInt(7, paymentModeId); else pt.setNull(7, Types.INTEGER);
        String tnStr = (transactionNo != null && !transactionNo.trim().isEmpty()) ? transactionNo.trim() : null;
        if (tnStr != null) pt.setString(8, tnStr); else pt.setNull(8, Types.VARCHAR);
        String notesStr = (notes != null && !notes.trim().isEmpty()) ? notes.trim() : "Balance collection";
        pt.setString(9, notesStr);
        pt.setString(10, collectionDate);
        if (createdBy != null) pt.setInt(11, createdBy); else pt.setNull(11, Types.INTEGER);
        int rows = pt.executeUpdate();
        if (rows == 0) throw new Exception("No rows inserted");
        con.commit();
        return "SUCCESS";
    } catch (Exception e) {
        if (con != null) try { con.rollback(); } catch (Exception ex) { ; }
        e.printStackTrace();
        return "ERROR:" + e.getMessage();
    } finally {
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.setAutoCommit(true); con.close(); } catch (Exception e) { ; }
    }
}

// Bulk balance collection save for multiple bookings in one transaction.
public String collectTicketBalanceBulk(int[] bookingIds, String[] partyTypes, Integer[] agentIds,
        String[] partyNames, String[] txnTypes, double[] collectedAmounts,
        Integer paymentModeId, String collectionDate, String transactionNo,
        String notes, Integer createdBy) {
    Connection con = null; PreparedStatement pt = null;
    try {
        if (bookingIds == null || bookingIds.length == 0) return "ERROR:No bookings selected";
        if (partyTypes == null || partyNames == null || txnTypes == null || collectedAmounts == null)
            return "ERROR:Invalid collection payload";
        if (partyTypes.length != bookingIds.length || partyNames.length != bookingIds.length ||
                txnTypes.length != bookingIds.length || collectedAmounts.length != bookingIds.length)
            return "ERROR:Payload size mismatch";
        if (agentIds != null && agentIds.length != bookingIds.length)
            return "ERROR:Agent payload size mismatch";

        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);
        String sql =
            "INSERT INTO ticket_ledger " +
            "(booking_id, party_type, agent_id, party_name, transaction_type, bill_amount, amount, payment_mode_id, transaction_no, remarks, transaction_date, created_by) " +
            "VALUES (?,?,?,?,?,0,?,?,?,?,?,?)";
        pt = con.prepareStatement(sql);

        String notesStr = (notes != null && !notes.trim().isEmpty()) ? notes.trim() : "Balance collection";
        String tnStr = (transactionNo != null && !transactionNo.trim().isEmpty()) ? transactionNo.trim() : null;

        for (int i = 0; i < bookingIds.length; i++) {
            if (collectedAmounts[i] <= 0) continue;

            pt.setInt(1, bookingIds[i]);
            pt.setString(2, partyTypes[i]);

            Integer agentId = (agentIds != null) ? agentIds[i] : null;
            if (agentId != null && agentId.intValue() > 0) pt.setInt(3, agentId.intValue());
            else pt.setNull(3, Types.INTEGER);

            // Keep party_name NULL when agent_id exists to preserve grouping behavior.
            if (agentId != null && agentId.intValue() > 0) pt.setNull(4, Types.VARCHAR);
            else pt.setString(4, (partyNames[i] != null) ? partyNames[i] : "");

            pt.setString(5, txnTypes[i]);
            pt.setDouble(6, collectedAmounts[i]);

            if (paymentModeId != null) pt.setInt(7, paymentModeId.intValue());
            else pt.setNull(7, Types.INTEGER);

            if (tnStr != null) pt.setString(8, tnStr); else pt.setNull(8, Types.VARCHAR);
            pt.setString(9, notesStr);
            pt.setString(10, collectionDate);
            if (createdBy != null) pt.setInt(11, createdBy.intValue()); else pt.setNull(11, Types.INTEGER);
            pt.addBatch();
        }

        int[] counts = pt.executeBatch();
        int inserted = 0;
        if (counts != null) {
            for (int c : counts) {
                if (c > 0 || c == Statement.SUCCESS_NO_INFO) inserted++;
            }
        }
        if (inserted == 0) throw new Exception("No rows inserted");

        con.commit();
        return "SUCCESS";
    } catch (Exception e) {
        if (con != null) try { con.rollback(); } catch (Exception ex) { ; }
        e.printStackTrace();
        return "ERROR:" + e.getMessage();
    } finally {
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.setAutoCommit(true); con.close(); } catch (Exception e) { ; }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// TICKET PAYMENTS DETAIL — individual ledger rows (un-grouped) for collection
// and agent paid reports. Shows each payment entry separately.
// partyTypeScope: "SELL" = SELL_AGENT+CUSTOMER, "BUY" = BUY_AGENT,
//                "SELL_AGENT" or "CUSTOMER" for specific type
// Row: [0]ledger_id [1]booking_id [2]ticket_no [3]pnr [4]party_type
//      [5]party_display [6]txn_type [7]bill_amount [8]amount_paid
//      [9]payment_mode [10]transaction_no [11]txn_date
//      [12]ow_from [13]ow_to [14]agent_id [15]party_name [16]booking_date
//      [17]remarks
// ─────────────────────────────────────────────────────────────────────────────
public Vector getTicketPaymentsDetail(String fromDate, String toDate, int agentId, String partyTypeScope) {
    Vector result = new Vector();
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String ptFilter;
        if ("BUY".equals(partyTypeScope) || "BUY_AGENT".equals(partyTypeScope))
            ptFilter = " AND l.party_type = 'BUY_AGENT'";
        else if ("SELL_AGENT".equals(partyTypeScope))
            ptFilter = " AND l.party_type = 'SELL_AGENT'";
        else if ("CUSTOMER".equals(partyTypeScope))
            ptFilter = " AND l.party_type = 'CUSTOMER'";
        else
            ptFilter = " AND l.party_type IN ('SELL_AGENT','CUSTOMER')";
        String agFilter = (agentId > 0) ? " AND l.agent_id = ?" : "";
        String sql =
            "SELECT l.id, l.booking_id, COALESCE(b.ticket_no,'-'), COALESCE(b.pnr,'-')," +
            " l.party_type, COALESCE(ta.name, l.party_name, '-') AS party_display," +
            " l.transaction_type, COALESCE(l.bill_amount,0), COALESCE(l.amount,0)," +
            " COALESCE(pm.modes,'-') AS payment_mode, COALESCE(l.transaction_no,'') AS txn_no," +
            " l.transaction_date, COALESCE(cf.name,'') AS ow_from, COALESCE(ct.name,'') AS ow_to," +
            " COALESCE(l.agent_id,0), COALESCE(l.party_name,''), b.booking_date, COALESCE(l.remarks,'')" +
            " FROM ticket_ledger l" +
            " JOIN ticket_booking b ON b.id = l.booking_id" +
            " LEFT JOIN ticket_agent ta ON ta.id = l.agent_id" +
            " LEFT JOIN ticket_payment_mode pm ON pm.id = l.payment_mode_id" +
            " LEFT JOIN ticket_city cf ON cf.id = b.oneway_from_id" +
            " LEFT JOIN ticket_city ct ON ct.id = b.oneway_to_id" +
            " WHERE l.transaction_date BETWEEN ? AND ? AND COALESCE(b.is_cancelled,0)=0" + ptFilter + agFilter +
            " ORDER BY l.transaction_date DESC, l.booking_id DESC, l.id ASC";
        pt = con.prepareStatement(sql);
        pt.setString(1, fromDate);
        pt.setString(2, toDate);
        if (agentId > 0) pt.setInt(3, agentId);
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++) row.add(rs.getObject(i));
            result.add(row);
        }
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return result;
}

// ─────────────────────────────────────────────────────────────────────────────
// CANCELLED BOOKINGS PENDING SETTLEMENT
// Returns cancelled bookings that still have a pending balance to settle.
// scope = "BUY"  → buy-agent side (we owe agent or agent owes us)
// scope = "SELL" → sell-agent / customer side (we owe refund or they owe us)
// agentId = 0 means all agents.
// Row: [0]booking_id [1]ticket_no [2]pnr [3]ow_from [4]ow_to
//      [5]booking_date [6]party_type [7]party_display
//      [8]agent_id [9]party_name [10]pending_balance
//  pending_balance sign (BUY):  > 0 → we still owe agent  | < 0 → agent owes us
//  pending_balance sign (SELL): > 0 → we still owe refund | < 0 → they owe us more
// ─────────────────────────────────────────────────────────────────────────────
public Vector getTicketCancelledPending(String scope, int agentId) {
    Vector result = new Vector();
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        if ("BUY".equals(scope)) {
            String agFilter = agentId > 0 ? " AND b.buy_agent_id = ?" : "";
            String sql =
                "SELECT b.id, COALESCE(b.ticket_no,'-'), COALESCE(b.pnr,'-')," +
                " COALESCE(cf.name,'') AS ow_from, COALESCE(ct.name,'') AS ow_to," +
                " DATE_FORMAT(b.booking_date,'%d/%m/%Y') AS bdate," +
                " 'BUY_AGENT' AS party_type," +
                " COALESCE(ta.name, '-') AS party_display," +
                " COALESCE(b.buy_agent_id, 0) AS agent_id," +
                " '' AS party_name," +
                " (COALESCE(b.cancel_charge_buy,0) - COALESCE(b.buy_paid_amount,0)" +
                "  - COALESCE((SELECT SUM(l.amount) FROM ticket_ledger l" +
                "    WHERE l.booking_id=b.id AND l.party_type='BUY_AGENT'" +
                "    AND COALESCE(l.bill_amount,0)=0),0)" +
                " ) AS pending_balance" +
                " FROM ticket_booking b" +
                " LEFT JOIN ticket_agent ta ON ta.id = b.buy_agent_id" +
                " LEFT JOIN ticket_city cf ON cf.id = b.oneway_from_id" +
                " LEFT JOIN ticket_city ct ON ct.id = b.oneway_to_id" +
                " WHERE b.is_cancelled = 1 AND b.buy_agent_id IS NOT NULL" + agFilter +
                " HAVING ABS(pending_balance) > 0.005" +
                " ORDER BY b.id DESC";
            pt = con.prepareStatement(sql);
            if (agentId > 0) pt.setInt(1, agentId);
            rs = pt.executeQuery();
            while (rs.next()) {
                Vector row = new Vector();
                for (int i = 1; i <= 11; i++) row.add(rs.getObject(i));
                result.add(row);
            }
        } else { // SELL
            String agFilter = agentId > 0 ? " AND b.sell_agent_id = ?" : "";
            String sql =
                "SELECT b.id, COALESCE(b.ticket_no,'-'), COALESCE(b.pnr,'-')," +
                " COALESCE(cf.name,'') AS ow_from, COALESCE(ct.name,'') AS ow_to," +
                " DATE_FORMAT(b.booking_date,'%d/%m/%Y') AS bdate," +
                " CASE WHEN b.sell_agent_id IS NOT NULL THEN 'SELL_AGENT' ELSE 'CUSTOMER' END AS party_type," +
                " CASE WHEN b.sell_agent_id IS NOT NULL THEN COALESCE(ta.name,'-')" +
                "      ELSE COALESCE(b.customer_name,'-') END AS party_display," +
                " COALESCE(b.sell_agent_id,0) AS agent_id," +
                " COALESCE(b.customer_name,'') AS party_name," +
                " (CASE WHEN b.sell_agent_id IS NOT NULL THEN" +
                "   COALESCE(b.sell_paid_amount,0) - COALESCE(b.cancel_charge_sell,0) - COALESCE(b.refund_to_sell,0)" +
                "   - COALESCE((SELECT SUM(l.amount) FROM ticket_ledger l" +
                "     WHERE l.booking_id=b.id AND l.party_type='SELL_AGENT'" +
                "     AND COALESCE(l.bill_amount,0)=0),0)" +
                "  ELSE" +
                "   COALESCE(b.cust_paid_amount,0) - COALESCE(b.cancel_charge_sell,0) - COALESCE(b.refund_to_sell,0)" +
                "   - COALESCE((SELECT SUM(l.amount) FROM ticket_ledger l" +
                "     WHERE l.booking_id=b.id AND l.party_type='CUSTOMER'" +
                "     AND COALESCE(l.bill_amount,0)=0),0)" +
                "  END) AS pending_balance" +
                " FROM ticket_booking b" +
                " LEFT JOIN ticket_agent ta ON ta.id = b.sell_agent_id" +
                " LEFT JOIN ticket_city cf ON cf.id = b.oneway_from_id" +
                " LEFT JOIN ticket_city ct ON ct.id = b.oneway_to_id" +
                " WHERE b.is_cancelled = 1" +
                "   AND (b.sell_agent_id IS NOT NULL OR COALESCE(b.cust_paid_amount,0)>0" +
                "        OR COALESCE(b.sell_paid_amount,0)>0)" + agFilter +
                " HAVING ABS(pending_balance) > 0.005" +
                " ORDER BY b.id DESC";
            pt = con.prepareStatement(sql);
            if (agentId > 0) pt.setInt(1, agentId);
            rs = pt.executeQuery();
            while (rs.next()) {
                Vector row = new Vector();
                for (int i = 1; i <= 11; i++) row.add(rs.getObject(i));
                result.add(row);
            }
        }
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return result;
}

// ─────────────────────────────────────────────────────────────────────────────
// TICKET LEDGER BY BOOKING ID — all payment entries for a specific booking
// Used by pnrEnquiry to show full payment history.
// Row: [0]id [1]party_type [2]party_display [3]txn_type
//      [4]bill_amount [5]amount [6]payment_mode [7]txn_no
//      [8]txn_date [9]remarks
// ─────────────────────────────────────────────────────────────────────────────
public Vector getTicketLedgerByBookingId(int bookingId) {
    Vector result = new Vector();
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String sql =
            "SELECT l.id, l.party_type," +
            " COALESCE(ta.name, l.party_name, '-') AS party_display," +
            " l.transaction_type, COALESCE(l.bill_amount,0), COALESCE(l.amount,0)," +
            " COALESCE(pm.modes,'-') AS payment_mode, COALESCE(l.transaction_no,'') AS txn_no," +
            " l.transaction_date, COALESCE(l.remarks,'')" +
            " FROM ticket_ledger l" +
            " LEFT JOIN ticket_agent ta ON ta.id = l.agent_id" +
            " LEFT JOIN ticket_payment_mode pm ON pm.id = l.payment_mode_id" +
            " WHERE l.booking_id = ?" +
            " ORDER BY l.id ASC";
        pt = con.prepareStatement(sql);
        pt.setInt(1, bookingId);
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++) row.add(rs.getObject(i));
            result.add(row);
        }
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return result;
}

// ─────────────────────────────────────────────────────────────────────────────
// AGENT STATEMENT — full account ledger with opening balance + running balance
// Row layout for each Vector element (String[13]):
//   [0] row_type: "OPEN"|"TXN"|"TOTAL"
//   [1] txn_date (dd/MM/yyyy)       [2] vou_number
//   [3] dr_amount                   [4] cr_amount
//   [5] balance (abs value)         [6] balance_dir ("DR"/"CR"/"NIL")
//   [7] particulars (main line)     [8] route ("MAA/SIN")
//   [9] flight_info                 [10] extra_pax ("||" separated)
//   [11] agent_name                 [12] party_type
// ─────────────────────────────────────────────────────────────────────────────
public Vector getAgentStatement(String fromDate, String toDate, int agentId) {
    Vector result = new Vector();
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();

        String agentName = "";
        pt = con.prepareStatement("SELECT name FROM ticket_agent WHERE id=?");
        pt.setInt(1, agentId);
        rs = pt.executeQuery();
        if (rs.next()) {
            agentName = rs.getString("name");
            if (agentName == null) agentName = "";
        }
        rs.close(); rs = null; pt.close(); pt = null;

        String sql =
            "SELECT l.id, l.transaction_date," +
            " DATE_FORMAT(l.transaction_date,'%d/%m/%Y') AS txn_date," +
            " COALESCE(b.ticket_no, CONCAT('TKT-',LPAD(b.id,3,'0'))) AS ticket_no," +
            " l.transaction_type, l.amount, COALESCE(l.bill_amount,0) AS bill_amount, l.remarks," +
            " b.pnr, b.id AS booking_id," +
            " oc.name AS from_city, dc.name AS to_city," +
            " b.oneway_airlines, DATE_FORMAT(b.oneway_travel_date,'%d%b%Y') AS oneway_date," +
            " b.oneway_flight_no, l.party_type, l.party_name," +
            " pax.passengers," +
            " COALESCE(b.is_cancelled,0) AS is_cancelled," +
            " COALESCE(l.charge_type,'') AS charge_type," +
            " COALESCE(l.cancel_charge,0) AS cancel_charge" +
            " FROM ticket_ledger l" +
            " LEFT JOIN ticket_booking b ON l.booking_id = b.id AND l.booking_id > 0" +
            " LEFT JOIN ticket_city oc ON b.oneway_from_id = oc.id" +
            " LEFT JOIN ticket_city dc ON b.oneway_to_id = dc.id" +
            " LEFT JOIN (SELECT booking_id, GROUP_CONCAT(passenger_name ORDER BY id SEPARATOR '||') AS passengers" +
            "            FROM ticket_passenger GROUP BY booking_id) pax ON pax.booking_id = b.id" +
            " WHERE l.agent_id = ? AND DATE(l.transaction_date) <= ?" +
            " ORDER BY l.transaction_date ASC, l.created_at ASC, l.id ASC";
        pt = con.prepareStatement(sql);
        pt.setInt(1, agentId);
        pt.setString(2, toDate);
        rs = pt.executeQuery();

        double runBal = 0.0;
        double totalDr = 0.0, totalCr = 0.0;
        boolean openAdded = false;

        while (rs.next()) {
            String txnDateRaw = rs.getString("transaction_date");
            if (txnDateRaw == null) continue;
            boolean inPeriod = txnDateRaw.compareTo(fromDate) >= 0 && txnDateRaw.compareTo(toDate) <= 0;
            if (!inPeriod && txnDateRaw.compareTo(fromDate) >= 0) continue;

            int bookingId = rs.getInt("booking_id");
            int isCancelled = rs.getInt("is_cancelled");
            String chargeType = rs.getString("charge_type");
            if (chargeType == null) chargeType = "";
            String partyType = rs.getString("party_type");
            if (partyType == null) partyType = "";
            String txnType = rs.getString("transaction_type");
            double billAmt = rs.getDouble("bill_amount");
            double paidAmt = rs.getDouble("amount");
            double cancelCharge = rs.getDouble("cancel_charge");
            boolean isCancelRow = "CANCEL_CHARGE".equals(chargeType);

            if (isCancelled == 1 && !isCancelRow) continue;

            double displayAmt = 0;
            String displayDir = "NIL";
            if (isCancelRow) {
                double pending = getBookingCancelPendingBalance(bookingId, partyType);
                displayAmt = Math.abs(pending);
                if (pending > 0.005) displayDir = "CR";
                else if (pending < -0.005) displayDir = "DR";
            } else {
                boolean isCollection = billAmt <= 0.005;
                if (isCollection) {
                    displayAmt = paidAmt;
                    if (displayAmt <= 0.005) continue;
                    displayDir = "DR".equals(txnType) ? "CR" : "DR";
                } else {
                    displayAmt = Math.max(billAmt - paidAmt, 0);
                    if (displayAmt <= 0.005) continue;
                    displayDir = txnType;
                }
            }

            if (inPeriod && !openAdded) {
                String openDr = "", openCr = "", openDir = "NIL";
                if (runBal >= 0.005)       { openDr = String.format("%.2f", runBal);   openDir = "DR"; }
                else if (runBal <= -0.005) { openCr = String.format("%.2f", -runBal);  openDir = "CR"; }
                Vector openRow = new Vector();
                openRow.add("OPEN");
                openRow.add("");
                openRow.add("Opening Balance");
                openRow.add(openDr);
                openRow.add(openCr);
                openRow.add(String.format("%.2f", Math.abs(runBal)));
                openRow.add(openDir);
                openRow.add(""); openRow.add(""); openRow.add(""); openRow.add("");
                openRow.add(agentName);
                openRow.add("");
                openRow.add("");
                openRow.add("");
                result.add(openRow);
                openAdded = true;
            }

            if ("DR".equals(displayDir)) runBal += displayAmt;
            else if ("CR".equals(displayDir)) runBal -= displayAmt;

            if (!inPeriod) continue;

            if ("DR".equals(displayDir)) totalDr += displayAmt;
            else if ("CR".equals(displayDir)) totalCr += displayAmt;

            String passengers = rs.getString("passengers");
            String pax1 = "", extraPax = "";
            if (passengers != null && !passengers.isEmpty()) {
                String[] paxArr = passengers.split("\\|\\|");
                pax1 = paxArr[0];
                if (paxArr.length > 1) {
                    StringBuilder sb = new StringBuilder();
                    for (int i = 1; i < paxArr.length; i++) {
                        if (i > 1) sb.append("||");
                        sb.append(paxArr[i]);
                    }
                    extraPax = sb.toString();
                }
            }

            String particulars = pax1;
            if (isCancelRow) {
                if (!particulars.isEmpty()) particulars = particulars + " (Cancelled)";
                else particulars = "Cancelled Ticket";
            } else if (particulars.isEmpty()) {
                String rem = rs.getString("remarks");
                if (rem != null && !rem.isEmpty()) {
                    particulars = rem;
                } else if (billAmt <= 0.005) {
                    particulars = "DR".equals(txnType) ? "Payment Received" : "Payment Made";
                } else {
                    particulars = "DR".equals(txnType) ? "Ticket Booking" : "Ticket Purchase";
                }
            }

            String flightNo   = rs.getString("oneway_flight_no");
            String pnr        = rs.getString("pnr");
            String onewayDate = rs.getString("oneway_date");
            StringBuilder fi  = new StringBuilder();
            if (flightNo != null && !flightNo.isEmpty()) fi.append(flightNo).append(" ");
            if (pnr      != null && !pnr.isEmpty())      fi.append(pnr).append(" ");
            if (onewayDate != null && !onewayDate.isEmpty()) fi.append("Trv.dt:").append(onewayDate);
            String flightInfo = fi.toString().trim();

            String fromCity = rs.getString("from_city");
            String toCity   = rs.getString("to_city");
            String route    = (fromCity != null && toCity != null) ? fromCity + "/" + toCity : "";

            boolean isCollection = !isCancelRow && billAmt <= 0.005;
            String vouNo = isCancelRow ? rs.getString("ticket_no")
                    : (isCollection ? "REC-" + rs.getInt("id") : rs.getString("ticket_no"));

            String drAmt  = "DR".equals(displayDir) ? String.format("%.2f", displayAmt) : "";
            String crAmt  = "CR".equals(displayDir) ? String.format("%.2f", displayAmt) : "";
            String balStr = String.format("%.2f", Math.abs(runBal));
            String balDir = runBal >= 0.005 ? "DR" : (runBal <= -0.005 ? "CR" : "NIL");
            String pType  = partyType;

            String rawRemarks = rs.getString("remarks");
            if (rawRemarks == null) rawRemarks = "";
            if (isCancelRow) {
                rawRemarks = "Cancel Charge: " + String.format("%.2f", cancelCharge)
                        + " | Refund Due: " + String.format("%.2f", Math.abs(billAmt));
            }

            Vector row = new Vector();
            row.add("TXN");
            row.add(rs.getString("txn_date"));
            row.add(vouNo);
            row.add(drAmt);
            row.add(crAmt);
            row.add(balStr);
            row.add(balDir);
            row.add(particulars);
            row.add(route);
            row.add(flightInfo);
            row.add(extraPax);
            row.add(agentName);
            row.add(pType);
            row.add(rawRemarks);
            row.add(isCancelRow ? String.format("%.2f", cancelCharge)
                    : (billAmt > 0.005 ? String.format("%.2f", billAmt) : ""));
            result.add(row);
        }

        if (!openAdded) {
            String openDr = "", openCr = "", openDir = "NIL";
            if (runBal >= 0.005)       { openDr = String.format("%.2f", runBal);   openDir = "DR"; }
            else if (runBal <= -0.005) { openCr = String.format("%.2f", -runBal);  openDir = "CR"; }
            Vector openRow = new Vector();
            openRow.add("OPEN");
            openRow.add("");
            openRow.add("Opening Balance");
            openRow.add(openDr);
            openRow.add(openCr);
            openRow.add(String.format("%.2f", Math.abs(runBal)));
            openRow.add(openDir);
            openRow.add(""); openRow.add(""); openRow.add(""); openRow.add("");
            openRow.add(agentName);
            openRow.add("");
            openRow.add("");
            openRow.add("");
            result.add(openRow);
        }

        String balStr = String.format("%.2f", Math.abs(runBal));
        String balDir = runBal >= 0.005 ? "DR" : (runBal <= -0.005 ? "CR" : "NIL");
        Vector totRow = new Vector();
        totRow.add("TOTAL");
        totRow.add(""); totRow.add("Total");
        totRow.add(String.format("%.2f", totalDr));
        totRow.add(String.format("%.2f", totalCr));
        totRow.add(balStr); totRow.add(balDir);
        totRow.add(""); totRow.add(""); totRow.add(""); totRow.add("");
        totRow.add(agentName); totRow.add("");
        totRow.add("");
        totRow.add("");
        result.add(totRow);

    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return result;
}

// ─────────────────────────────────────────────────────────────────────────────
// TICKET DASHBOARD STATS
// ─────────────────────────────────────────────────────────────────────────────
// Ticket Dashboard Stats — delegates to parameterised version with current date
// ─────────────────────────────────────────────────────────────────────────────
public Map<String,Object> getTicketDashboardStats() {
    java.util.Calendar _cal = java.util.Calendar.getInstance();
    return getTicketDashboardStats(_cal.get(java.util.Calendar.YEAR), _cal.get(java.util.Calendar.MONTH) + 1);
}

// ─────────────────────────────────────────────────────────────────────────────
// Ticket Dashboard Stats for a specific year + month
// ─────────────────────────────────────────────────────────────────────────────
public Map<String,Object> getTicketDashboardStats(int year, int month) {
    Map<String,Object> stats = new java.util.LinkedHashMap<String,Object>();
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();

        // ── Today stats ──────────────────────────────────────────────────────
        pt = con.prepareStatement(
            "SELECT COUNT(*) AS cnt," +
            " SUM(COALESCE(sell_amount,0)+COALESCE(customer_amount,0)) AS sell," +
            " IFNULL(SUM(buy_amount),0) AS buy" +
            " FROM ticket_booking WHERE DATE(booking_date)=CURDATE() AND COALESCE(is_cancelled,0)=0");
        rs = pt.executeQuery();
        if (rs.next()) {
            stats.put("todayCount", rs.getInt("cnt"));
            stats.put("todaySell",  rs.getDouble("sell"));
            stats.put("todayBuy",   rs.getDouble("buy"));
            double sell = rs.getDouble("sell"), buy = rs.getDouble("buy");
            stats.put("todayProfit", sell - buy);
        } else { stats.put("todayCount",0); stats.put("todaySell",0.0); stats.put("todayBuy",0.0); stats.put("todayProfit",0.0); }
        rs.close(); pt.close();

        // ── Selected month stats ──────────────────────────────────────────────
        pt = con.prepareStatement(
            "SELECT COUNT(*) AS cnt," +
            " SUM(COALESCE(sell_amount,0)+COALESCE(customer_amount,0)) AS sell," +
            " IFNULL(SUM(buy_amount),0) AS buy" +
            " FROM ticket_booking" +
            " WHERE MONTH(booking_date)=? AND YEAR(booking_date)=? AND COALESCE(is_cancelled,0)=0");
        pt.setInt(1, month); pt.setInt(2, year);
        rs = pt.executeQuery();
        if (rs.next()) {
            stats.put("monthCount", rs.getInt("cnt"));
            stats.put("monthSell",  rs.getDouble("sell"));
            stats.put("monthBuy",   rs.getDouble("buy"));
            stats.put("monthProfit", rs.getDouble("sell") - rs.getDouble("buy"));
        } else { stats.put("monthCount",0); stats.put("monthSell",0.0); stats.put("monthBuy",0.0); stats.put("monthProfit",0.0); }
        rs.close(); pt.close();

        // ── Total outstanding (all parties) ──────────────────────────────────
        pt = con.prepareStatement(
            "SELECT IFNULL(SUM(CASE" +
            "  WHEN COALESCE(bill_amount,0)>0 AND transaction_type='DR' THEN bill_amount-amount" +
            "  WHEN COALESCE(bill_amount,0)>0 AND transaction_type='CR' THEN -(bill_amount-amount)" +
            "  WHEN COALESCE(bill_amount,0)<=0 AND transaction_type='DR' THEN -amount" +
            "  WHEN COALESCE(bill_amount,0)<=0 AND transaction_type='CR' THEN amount" +
            "  ELSE 0 END),0) AS outstanding FROM ticket_ledger l" +
            " JOIN ticket_booking b ON b.id=l.booking_id AND COALESCE(b.is_cancelled,0)=0");
        rs = pt.executeQuery();
        stats.put("totalOutstanding", rs.next() ? rs.getDouble("outstanding") : 0.0);
        rs.close(); pt.close();

        // ── Total agent outstanding ───────────────────────────────────────────
        pt = con.prepareStatement(
            "SELECT IFNULL(SUM(CASE" +
            "  WHEN COALESCE(bill_amount,0)>0 AND transaction_type='DR' THEN bill_amount-amount" +
            "  WHEN COALESCE(bill_amount,0)>0 AND transaction_type='CR' THEN -(bill_amount-amount)" +
            "  WHEN COALESCE(bill_amount,0)<=0 AND transaction_type='DR' THEN -amount" +
            "  WHEN COALESCE(bill_amount,0)<=0 AND transaction_type='CR' THEN amount" +
            "  ELSE 0 END),0) AS outstanding FROM ticket_ledger l JOIN ticket_booking b ON b.id=l.booking_id AND COALESCE(b.is_cancelled,0)=0 WHERE l.agent_id IS NOT NULL");
        rs = pt.executeQuery();
        stats.put("totalAgentOutstanding", rs.next() ? rs.getDouble("outstanding") : 0.0);
        rs.close(); pt.close();

        // ── Bookings for selected month ───────────────────────────────────────
        pt = con.prepareStatement(
            "SELECT b.id, b.ticket_no, b.pnr, b.booking_date," +
            " IFNULL(cf.name,'') AS from_city, IFNULL(ct.name,'') AS to_city," +
            " b.no_of_seats, IFNULL(b.customer_name,'') AS customer_name," +
            " IFNULL(b.sell_amount,0)+IFNULL(b.customer_amount,0) AS sell_amount," +
            " IFNULL(b.buy_amount,0) AS buy_amount" +
            " FROM ticket_booking b" +
            " LEFT JOIN ticket_city cf ON cf.id=b.oneway_from_id" +
            " LEFT JOIN ticket_city ct ON ct.id=b.oneway_to_id" +
            " WHERE MONTH(b.booking_date)=? AND YEAR(b.booking_date)=? AND COALESCE(b.is_cancelled,0)=0" +
            " ORDER BY b.booking_date DESC, b.id DESC LIMIT 100");
        pt.setInt(1, month); pt.setInt(2, year);
        rs = pt.executeQuery();
        Vector recent = new Vector();
        while (rs.next()) {
            Vector row = new Vector();
            row.add(rs.getInt("id"));
            row.add(rs.getString("ticket_no") != null ? rs.getString("ticket_no") : "");
            row.add(rs.getString("pnr") != null ? rs.getString("pnr") : "");
            row.add(rs.getString("booking_date"));
            row.add(rs.getString("from_city"));
            row.add(rs.getString("to_city"));
            row.add(rs.getInt("no_of_seats"));
            row.add(rs.getString("customer_name"));
            row.add(rs.getDouble("sell_amount"));
            row.add(rs.getDouble("buy_amount"));
            recent.add(row);
        }
        stats.put("recentBookings", recent);
        rs.close(); pt.close();

        // ── Daily chart — all days of selected month (0 for days with no bookings) ───
        // Build first/last day of the selected month in Java
        java.util.Calendar c1 = java.util.Calendar.getInstance();
        c1.set(year, month - 1, 1);
        String firstDay = String.format("%04d-%02d-01", year, month);
        String lastDay  = String.format("%04d-%02d-%02d", year, month,
                            c1.getActualMaximum(java.util.Calendar.DAY_OF_MONTH));
        pt = con.prepareStatement(
            "SELECT DATE_FORMAT(d,'%d %b') AS lbl," +
            " COALESCE(b.cnt,0) AS cnt," +
            " COALESCE(b.sell,0) AS sell" +
            " FROM (" +
            "   SELECT DATE(?) + INTERVAL (a.n + b10.n*10) DAY AS d" +
            "   FROM (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4" +
            "         UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a" +
            "   CROSS JOIN (SELECT 0 n UNION ALL SELECT 1 UNION ALL SELECT 2) b10" +
            " ) days" +
            " LEFT JOIN (" +
            "   SELECT DATE(booking_date) AS bdate, COUNT(id) AS cnt, SUM(COALESCE(sell_amount,0)+COALESCE(customer_amount,0)) AS sell" +
            "   FROM ticket_booking WHERE booking_date BETWEEN ? AND ? AND COALESCE(is_cancelled,0)=0" +
            "   GROUP BY DATE(booking_date)" +
            " ) b ON b.bdate = days.d" +
            " WHERE days.d BETWEEN ? AND ?" +
            " ORDER BY days.d ASC");
        pt.setString(1, firstDay);
        pt.setString(2, firstDay);
        pt.setString(3, lastDay);
        pt.setString(4, firstDay);
        pt.setString(5, lastDay);
        rs = pt.executeQuery();
        Vector chart = new Vector();
        while (rs.next()) {
            Vector row = new Vector();
            row.add(rs.getString("lbl"));
            row.add(rs.getInt("cnt"));
            row.add(rs.getDouble("sell"));
            chart.add(row);
        }
        stats.put("weeklyChart", chart);
        rs.close(); pt.close();

        // ── Agent outstanding: receivable (they owe us) and payable (we owe them) ───
        pt = con.prepareStatement(
            "SELECT a.name," +
            " SUM(CASE" +
            "  WHEN COALESCE(l.bill_amount,0)>0 AND l.transaction_type='DR' THEN l.bill_amount-l.amount" +
            "  WHEN COALESCE(l.bill_amount,0)>0 AND l.transaction_type='CR' THEN -(l.bill_amount-l.amount)" +
            "  WHEN COALESCE(l.bill_amount,0)<=0 AND l.transaction_type='DR' THEN -l.amount" +
            "  WHEN COALESCE(l.bill_amount,0)<=0 AND l.transaction_type='CR' THEN l.amount" +
            "  ELSE 0 END) AS outstanding" +
            " FROM ticket_ledger l" +
            " JOIN ticket_agent a ON a.id=l.agent_id" +
            " JOIN ticket_booking b ON b.id=l.booking_id AND COALESCE(b.is_cancelled,0)=0" +
            " WHERE l.agent_id IS NOT NULL" +
            " GROUP BY l.agent_id, a.name" +
            " HAVING ABS(outstanding) > 0.005" +
            " ORDER BY ABS(outstanding) DESC");
        rs = pt.executeQuery();
        Vector agentsReceivable = new Vector(); // outstanding > 0: they owe us
        Vector agentsPayable    = new Vector(); // outstanding < 0: we owe them
        while (rs.next()) {
            double outstanding = rs.getDouble("outstanding");
            Vector row = new Vector();
            row.add(rs.getString("name"));
            row.add(Math.abs(outstanding));
            if (outstanding > 0.005) {
                if (agentsReceivable.size() < 5) agentsReceivable.add(row);
            } else if (outstanding < -0.005) {
                if (agentsPayable.size() < 5) agentsPayable.add(row);
            }
        }
        stats.put("agentsReceivable", agentsReceivable);
        stats.put("agentsPayable",    agentsPayable);
        stats.put("topAgentsDue", agentsReceivable); // backward compat
        rs.close(); pt.close();

    } catch (Exception e) {
        e.printStackTrace();
        if (!stats.containsKey("todayCount")) stats.put("todayCount", 0);
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return stats;
}

// =============================================================================
// SERVICE BILL METHODS
// =============================================================================

// ---------------------------------------------------------------------------
// getNextServiceBillNo — returns next bill_no for current year, e.g. "26-1"
// ---------------------------------------------------------------------------
public String getNextServiceBillNo() {
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        String yr = new java.text.SimpleDateFormat("yy").format(new java.util.Date());
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement(
            "SELECT COALESCE(MAX(CAST(SUBSTRING_INDEX(bill_no,'-',-1) AS UNSIGNED)),0)+1 " +
            "FROM service_bill WHERE bill_no LIKE ?");
        pt.setString(1, yr + "-%");
        rs = pt.executeQuery();
        int seq = 1;
        if (rs.next()) seq = rs.getInt(1);
        return yr + "-" + seq;
    } catch (Exception e) {
        e.printStackTrace();
        return new java.text.SimpleDateFormat("yy").format(new java.util.Date()) + "-ERR";
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
}

// ---------------------------------------------------------------------------
// saveServiceBill — saves header + items in a transaction.
// Returns new inserted id (>0) on success, or -1 on failure.
// svcNames and svcCosts must be parallel arrays; null entries are skipped.
// ---------------------------------------------------------------------------
public int saveServiceBill(String billNo, String billDate, String customerName,
        String phone, double subtotal, double discount, double totalAmount,
        double paidAmount, double balance, Integer payModeId, String payModeName,
        String description, int createdBy, String[] svcNames, String[] svcCosts) {
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);

        pt = con.prepareStatement(
            "INSERT INTO service_bill " +
            "(bill_no,bill_date,customer_name,phone,subtotal,discount,total_amount," +
            "paid_amount,balance,pay_mode_id,pay_mode_name,description,created_by) " +
            "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",
            Statement.RETURN_GENERATED_KEYS);
        pt.setString(1, billNo);
        pt.setString(2, billDate);
        pt.setString(3, customerName != null ? customerName.trim() : "");
        pt.setString(4, phone != null ? phone.trim() : "");
        pt.setDouble(5, subtotal);
        pt.setDouble(6, discount);
        pt.setDouble(7, totalAmount);
        pt.setDouble(8, paidAmount);
        pt.setDouble(9, balance);
        if (payModeId != null && payModeId > 0) pt.setInt(10, payModeId);
        else pt.setNull(10, Types.INTEGER);
        pt.setString(11, payModeName != null ? payModeName.trim() : "");
        pt.setString(12, description != null ? description.trim() : "");
        pt.setInt(13, createdBy);
        pt.executeUpdate();

        rs = pt.getGeneratedKeys();
        int newId = -1;
        if (rs.next()) newId = rs.getInt(1);
        rs.close(); pt.close();

        if (newId > 0 && svcNames != null) {
            pt = con.prepareStatement(
                "INSERT INTO service_bill_items (bill_id,service_name,cost) VALUES (?,?,?)");
            for (int i = 0; i < svcNames.length; i++) {
                if (svcNames[i] == null || svcNames[i].trim().isEmpty()) continue;
                double cost = 0;
                if (svcCosts != null && i < svcCosts.length) {
                    try { cost = Double.parseDouble(svcCosts[i]); } catch (Exception ex) { ; }
                }
                pt.setInt(1, newId);
                pt.setString(2, svcNames[i].trim());
                pt.setDouble(3, cost);
                pt.addBatch();
            }
            pt.executeBatch();
        }

        con.commit();
        return newId;
    } catch (Exception e) {
        if (con != null) try { con.rollback(); } catch (Exception ex) { ; }
        e.printStackTrace();
        return -1;
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.setAutoCommit(true); con.close(); } catch (Exception e) { ; }
    }
}

// ---------------------------------------------------------------------------
// getServiceBillById — returns bill header as a Vector.
// Row: [0]bill_no [1]bill_date(dd-MM-yyyy) [2]customer_name [3]phone
//      [4]subtotal [5]discount [6]total_amount [7]paid_amount [8]balance
//      [9]pay_mode_name [10]description
// Returns empty Vector if not found.
// ---------------------------------------------------------------------------
public Vector getServiceBillById(int billId) {
    Vector vec = new Vector();
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement(
            "SELECT bill_no, DATE_FORMAT(bill_date,'%d-%m-%Y'), customer_name, phone, " +
            "subtotal, discount, total_amount, paid_amount, balance, " +
            "COALESCE(pay_mode_name,''), COALESCE(description,'') " +
            "FROM service_bill WHERE id=?");
        pt.setInt(1, billId);
        rs = pt.executeQuery();
        if (rs.next()) {
            for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++)
                vec.add(rs.getObject(i));
        }
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return vec;
}

// ---------------------------------------------------------------------------
// getServiceBillItems — returns items for a bill.
// Each row: [0]service_name [1]cost
// ---------------------------------------------------------------------------
public Vector getServiceBillItems(int billId) {
    Vector result = new Vector();
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement(
            "SELECT service_name, cost FROM service_bill_items WHERE bill_id=? ORDER BY id");
        pt.setInt(1, billId);
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.add(rs.getString(1));
            row.add(rs.getDouble(2));
            result.add(row);
        }
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return result;
}

// ---------------------------------------------------------------------------
// getServiceBillReport — returns bill list for date range.
// Each row: [0]id [1]bill_no [2]bill_date(dd-MM-yyyy) [3]customer_name
//           [4]phone [5]total_amount [6]paid_amount [7]balance [8]pay_mode_name
//           [9]collected_amount
// ---------------------------------------------------------------------------
public Vector getServiceBillReport(String fromDate, String toDate) {
    return getServiceBillReport(fromDate, toDate, 0);
}

// ---------------------------------------------------------------------------
// getServiceBillReport (with filter)
// balanceOnly = 1  -> only rows where balance > 0
// balanceOnly = 0  -> all rows
// ---------------------------------------------------------------------------
public Vector getServiceBillReport(String fromDate, String toDate, int balanceOnly) {
    Vector result = new Vector();
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String balFilter = balanceOnly == 1 ? " AND sb.balance > 0" : "";
        try {
            // Preferred query: includes collected amount from collection table.
            pt = con.prepareStatement(
                "SELECT sb.id, sb.bill_no, DATE_FORMAT(sb.bill_date,'%d-%m-%Y'), " +
                "COALESCE(sb.customer_name,''), COALESCE(sb.phone,''), " +
                "sb.total_amount, sb.paid_amount, sb.balance, COALESCE(sb.pay_mode_name,''), " +
                "COALESCE((SELECT SUM(c.amount) FROM service_bill_balance_collection c WHERE c.bill_id = sb.id),0) AS collected_amount " +
                "FROM service_bill sb " +
                "WHERE sb.bill_date BETWEEN ? AND ? " + balFilter +
                " ORDER BY sb.bill_date DESC, sb.id DESC");
            pt.setString(1, fromDate);
            pt.setString(2, toDate);
            rs = pt.executeQuery();
        } catch (Exception exTbl) {
            // Fallback: collection table not available yet. Keep report working.
            if (rs != null) try { rs.close(); } catch (Exception ex) { ; }
            if (pt != null) try { pt.close(); } catch (Exception ex) { ; }

            pt = con.prepareStatement(
                "SELECT sb.id, sb.bill_no, DATE_FORMAT(sb.bill_date,'%d-%m-%Y'), " +
                "COALESCE(sb.customer_name,''), COALESCE(sb.phone,''), " +
                "sb.total_amount, sb.paid_amount, sb.balance, COALESCE(sb.pay_mode_name,''), " +
                "0 AS collected_amount " +
                "FROM service_bill sb " +
                "WHERE sb.bill_date BETWEEN ? AND ? " + balFilter +
                " ORDER BY sb.bill_date DESC, sb.id DESC");
            pt.setString(1, fromDate);
            pt.setString(2, toDate);
            rs = pt.executeQuery();
        }

        while (rs.next()) {
            Vector row = new Vector();
            for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++) row.add(rs.getObject(i));
            result.add(row);
        }
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return result;
}

// ---------------------------------------------------------------------------
// collectServiceBillBalance — inserts collection entry and updates header
// Returns "OK" or error text.
// ---------------------------------------------------------------------------
public String collectServiceBillBalance(int billId, double collectAmount,
        Integer payModeId, String payModeName, String remarks,
        String collectionDate, int userId) {
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        if (billId <= 0) return "Invalid bill id";
        if (collectAmount <= 0.0001) return "Collection amount must be greater than 0";

        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);

        double total = 0, paid = 0, bal = 0;
        pt = con.prepareStatement(
            "SELECT total_amount, paid_amount, balance FROM service_bill WHERE id=? FOR UPDATE");
        pt.setInt(1, billId);
        rs = pt.executeQuery();
        if (!rs.next()) {
            rs.close(); pt.close();
            con.rollback();
            return "Bill not found";
        }
        total = rs.getDouble(1);
        paid = rs.getDouble(2);
        bal = rs.getDouble(3);
        rs.close(); pt.close();

        if (bal <= 0.0001) {
            con.rollback();
            return "No pending balance";
        }
        if (collectAmount - bal > 0.0001) {
            con.rollback();
            return "Collection amount cannot exceed balance";
        }

        double newPaid = paid + collectAmount;
        double newBal = total - newPaid;
        if (newBal < 0.0001) newBal = 0;

        pt = con.prepareStatement(
            "INSERT INTO service_bill_balance_collection " +
            "(bill_id, collection_date, amount, pay_mode_id, pay_mode_name, remarks, created_by) " +
            "VALUES (?,?,?,?,?,?,?)");
        pt.setInt(1, billId);
        pt.setString(2, (collectionDate != null && !collectionDate.trim().isEmpty()) ? collectionDate : new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()));
        pt.setDouble(3, collectAmount);
        if (payModeId != null && payModeId > 0) pt.setInt(4, payModeId.intValue());
        else pt.setNull(4, Types.INTEGER);
        pt.setString(5, payModeName != null ? payModeName.trim() : "");
        pt.setString(6, remarks != null ? remarks.trim() : "");
        pt.setInt(7, userId);
        pt.executeUpdate();
        pt.close();

        pt = con.prepareStatement(
            "UPDATE service_bill SET paid_amount=?, balance=?, pay_mode_id=?, pay_mode_name=? WHERE id=?");
        pt.setDouble(1, newPaid);
        pt.setDouble(2, newBal);
        if (payModeId != null && payModeId > 0) pt.setInt(3, payModeId.intValue());
        else pt.setNull(3, Types.INTEGER);
        pt.setString(4, payModeName != null ? payModeName.trim() : "");
        pt.setInt(5, billId);
        pt.executeUpdate();
        pt.close();

        con.commit();
        return "OK";
    } catch (Exception e) {
        if (con != null) try { con.rollback(); } catch (Exception ex) { ; }
        e.printStackTrace();
        return "Failed to collect balance";
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.setAutoCommit(true); con.close(); } catch (Exception e) { ; }
    }
}

// ---------------------------------------------------------------------------
// getServiceBillCollectedAmount — total collected from collection table
// ---------------------------------------------------------------------------
public double getServiceBillCollectedAmount(int billId) {
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement(
            "SELECT COALESCE(SUM(amount),0) FROM service_bill_balance_collection WHERE bill_id=?");
        pt.setInt(1, billId);
        rs = pt.executeQuery();
        if (rs.next()) return rs.getDouble(1);
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return 0;
}

// ---------------------------------------------------------------------------
// getServiceBillBalanceCollections — row: [0]date [1]amount [2]mode [3]remarks
// ---------------------------------------------------------------------------
public Vector getServiceBillBalanceCollections(int billId) {
    Vector result = new Vector();
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement(
            "SELECT DATE_FORMAT(collection_date,'%d-%m-%Y'), amount, COALESCE(pay_mode_name,''), COALESCE(remarks,'') " +
            "FROM service_bill_balance_collection WHERE bill_id=? ORDER BY collection_date ASC, id ASC");
        pt.setInt(1, billId);
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.add(rs.getString(1));
            row.add(rs.getDouble(2));
            row.add(rs.getString(3));
            row.add(rs.getString(4));
            result.add(row);
        }
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return result;
}

// ─────────────────────────────────────────────────────────────────────────────
// DELETE TICKET  –  hard-delete booking + ledger + passengers, then log
// ─────────────────────────────────────────────────────────────────────────────
public void deleteTicketWithLog(int bookingId, int deletedBy) throws Exception {
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);

        // 1. Snapshot the booking for the log
        pt = con.prepareStatement(
            "SELECT b.ticket_no, b.pnr, b.booking_date," +
            " cf.name, ct.name," +
            " b.oneway_travel_date," +
            " ba.name, b.buy_amount, sa.name, b.sell_amount," +
            " b.customer_name, b.customer_amount, b.no_of_seats" +
            " FROM ticket_booking b" +
            " LEFT JOIN ticket_city cf  ON cf.id = b.oneway_from_id" +
            " LEFT JOIN ticket_city ct  ON ct.id = b.oneway_to_id" +
            " LEFT JOIN ticket_agent ba ON ba.id = b.buy_agent_id" +
            " LEFT JOIN ticket_agent sa ON sa.id = b.sell_agent_id" +
            " WHERE b.id = ? LIMIT 1");
        pt.setInt(1, bookingId);
        rs = pt.executeQuery();
        String tktNo = "", pnrVal = "", bookDate = "", owFrom = "", owTo = "", owDate = "";
        String buyAgent = "", sellAgent = "", custName = "";
        double buyAmt = 0, sellAmt = 0, custAmt = 0;
        int seats = 0;
        if (rs.next()) {
            tktNo    = rs.getString(1)  != null ? rs.getString(1)  : "";
            pnrVal   = rs.getString(2)  != null ? rs.getString(2)  : "";
            bookDate = rs.getString(3)  != null ? rs.getString(3)  : "";
            owFrom   = rs.getString(4)  != null ? rs.getString(4)  : "";
            owTo     = rs.getString(5)  != null ? rs.getString(5)  : "";
            owDate   = rs.getString(6)  != null ? rs.getString(6)  : "";
            buyAgent = rs.getString(7)  != null ? rs.getString(7)  : "";
            buyAmt   = rs.getDouble(8);
            sellAgent= rs.getString(9)  != null ? rs.getString(9)  : "";
            sellAmt  = rs.getDouble(10);
            custName = rs.getString(11) != null ? rs.getString(11) : "";
            custAmt  = rs.getDouble(12);
            seats    = rs.getInt(13);
        }
        rs.close(); pt.close();

        // 2. Collect passenger names
        pt = con.prepareStatement(
            "SELECT passenger_name FROM ticket_passenger WHERE booking_id=? ORDER BY seat_no");
        pt.setInt(1, bookingId);
        rs = pt.executeQuery();
        StringBuilder paxNames = new StringBuilder();
        while (rs.next()) {
            if (paxNames.length() > 0) paxNames.append(", ");
            if (rs.getString(1) != null) paxNames.append(rs.getString(1));
        }
        rs.close(); pt.close();

        // 3. Fetch deleter name
        pt = con.prepareStatement("SELECT fullName FROM users WHERE id=? LIMIT 1");
        pt.setInt(1, deletedBy);
        rs = pt.executeQuery();
        String delName = rs.next() ? (rs.getString(1) != null ? rs.getString(1) : "") : "";
        rs.close(); pt.close();

        // 4. Delete child rows first (FK order)
        pt = con.prepareStatement("DELETE FROM ticket_passenger WHERE booking_id=?");
        pt.setInt(1, bookingId); pt.executeUpdate(); pt.close();

        pt = con.prepareStatement("DELETE FROM ticket_ledger WHERE booking_id=?");
        pt.setInt(1, bookingId); pt.executeUpdate(); pt.close();

        pt = con.prepareStatement("DELETE FROM ticket_booking WHERE id=?");
        pt.setInt(1, bookingId); pt.executeUpdate(); pt.close();

        // 5. Insert delete log
        pt = con.prepareStatement(
            "INSERT INTO ticket_delete_log" +
            " (booking_id,ticket_no,pnr,booking_date,oneway_from,oneway_to,oneway_travel_date," +
            "  passenger_names,buy_agent,buy_amount,sell_agent,sell_amount," +
            "  customer_name,customer_amount,no_of_seats,deleted_by,deleted_by_name,deleted_at)" +
            " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,NOW())");
        pt.setInt(1, bookingId);
        pt.setString(2, tktNo);
        pt.setString(3, pnrVal);
        pt.setString(4, bookDate.isEmpty() ? null : bookDate);
        pt.setString(5, owFrom);
        pt.setString(6, owTo);
        pt.setString(7, owDate.isEmpty() ? null : owDate);
        pt.setString(8, paxNames.toString());
        pt.setString(9, buyAgent.isEmpty() ? null : buyAgent);
        pt.setDouble(10, buyAmt);
        pt.setString(11, sellAgent.isEmpty() ? null : sellAgent);
        pt.setDouble(12, sellAmt);
        pt.setString(13, custName.isEmpty() ? null : custName);
        pt.setDouble(14, custAmt);
        pt.setInt(15, seats);
        pt.setInt(16, deletedBy);
        pt.setString(17, delName);
        pt.executeUpdate(); pt.close();

        con.commit();
    } catch (Exception e) {
        if (con != null) try { con.rollback(); } catch (Exception ex) {}
        throw e;
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) {}
        if (pt  != null) try { pt.close();  } catch (Exception e) {}
        if (con != null) try { con.setAutoCommit(true); con.close(); } catch (Exception e) {}
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// GET TICKET DELETE LOG  –  list of deleted tickets by deleted_at date range
// Row: [0]id [1]booking_id [2]ticket_no [3]pnr [4]booking_date
//      [5]oneway_from [6]oneway_to [7]oneway_travel_date
//      [8]passenger_names [9]buy_agent [10]buy_amount
//      [11]sell_agent [12]sell_amount [13]customer_name [14]customer_amount
//      [15]no_of_seats [16]deleted_by_name [17]deleted_at
// ─────────────────────────────────────────────────────────────────────────────
public Vector getTicketDeleteLog(String fromDate, String toDate) {
    Vector result = new Vector();
    Connection con = null; PreparedStatement pt = null; ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement(
            "SELECT id,booking_id,ticket_no,pnr,booking_date," +
            " oneway_from,oneway_to,oneway_travel_date," +
            " passenger_names,buy_agent,buy_amount," +
            " sell_agent,sell_amount,customer_name,customer_amount," +
            " no_of_seats,deleted_by_name,deleted_at" +
            " FROM ticket_delete_log" +
            " WHERE DATE(deleted_at) BETWEEN ? AND ?" +
            " ORDER BY id DESC");
        pt.setString(1, fromDate);
        pt.setString(2, toDate);
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            for (int i = 1; i <= rs.getMetaData().getColumnCount(); i++) row.add(rs.getObject(i));
            result.add(row);
        }
    } catch (Exception e) { e.printStackTrace(); }
    finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (pt  != null) try { pt.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return result;
}

}