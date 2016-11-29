import java.util.*;
import java.io.*;
import java.sql.*;

public class airlineUI{
	
	static final String USER = "jat134";	//Your username
	static final String PASS = "hihi2222";	//your password
	static final String url = "jdbc:oracle:thin:@db10.cs.pitt.edu:1521:dbclass";
	
	
	static Connection conn = null;
	static Statement stmt = null;
	
	public static void main(String args[]){
		try{
			DriverManager.registerDriver (new oracle.jdbc.driver.OracleDriver());
			System.out.println("Connecting to database...");
			conn = DriverManager.getConnection(url,USER,PASS);
			System.out.println("Creating database...");
			stmt = conn.createStatement();
			String sql = "CREATE DATABASE pittToursDB.sql";
			stmt.executeUpdate(sql);
			System.out.println("Database created successfully...");
			
		}catch(SQLException se){
			se.printStackTrace();
		}catch(Exception e){
			e.printStackTrace();
		}
		
		Scanner scanner = new Scanner(System.in);
		int choice = 0;
		while(true){
			System.out.println("\nWhich interface would you like to access?");
			System.out.println("1. Administrator Interface");
			System.out.println("2. Customer Interface");
			System.out.println("3. Exit");
			choice = scanner.nextInt();
			if(choice == 1){
				adminInterface();
			}
			else if(choice == 2){
				userInterface();
			}
			else if(choice == 3){
				try{
					if(stmt!=null)
            			stmt.close();
				}catch(SQLException se2){}
				try{
					if(conn!=null)
						conn.close();
				}catch(SQLException se){
					se.printStackTrace();
				}
				System.out.println("Exit successful.");
				System.exit(0);
			}
			else{
				System.out.println("Please enter a valid input.");
			}
		}
	}
	public static void adminInterface(){
		Scanner scanner = new Scanner(System.in);
		while(true){
			System.out.println("\n-----Administrator Menu-----");
			System.out.println("1. Erase the database");
			System.out.println("2. Load ariline information");
			System.out.println("3. Load scedule information");
			System.out.println("4. Load pricing information");
			System.out.println("5. Load plane information");
			System.out.println("6. Generate passenger manifest for a specific flight on a given day");
			System.out.println("7. Quit\n");
			int userInput = scanner.nextInt();
			if(userInput == 1){

			}
			else if(userInput == 2){

			}
			else if(userInput == 3){

			}
			else if(userInput == 4){

			}
			else if(userInput == 5){

			}
			else if(userInput == 6){
				
			}
			else if(userInput == 7){
				try{
					if(stmt!=null)
            			stmt.close();
				}catch(SQLException se2){}
				try{
					if(conn!=null)
						conn.close();
				}catch(SQLException se){
					se.printStackTrace();
				}
				System.out.println("Exit successful.");
				System.exit(0);
			}
			else{
				System.out.println("Invalid input\n");
			}
		}
	}
	public static void userInterface(){
		Scanner scanner = new Scanner(System.in);
		while(true){
			System.out.println("\n-----Customer Menu-----");
			System.out.println("1. Add customer");
			System.out.println("2. show customer info, given customer name");
			System.out.println("3. Find price for flights between two cities");
			System.out.println("4. Find all routes between two cities");
			System.out.println("5. Find all routes between two cities of a given airline");
			System.out.println("6. Find all routes with available seats between two cities on given day");
			System.out.println("7. For a given airline, find all routes with available seats between two cities on given day");
			System.out.println("8. Add reservation");
			System.out.println("9. Show reservation info, given reservation number");
			System.out.println("10. Buy ticket from existing reservation");
			System.out.println("11. Exit\n");
			int userInput = scanner.nextInt();
			if(userInput == 1){
				addCustomer();
			}
			else if(userInput == 2){
				showCustomer();
			}
			else if(userInput == 3){
				findPrice();
			}
			else if(userInput == 4){
				findRoutes();
			}
			else if(userInput == 5){

			}
			else if(userInput == 6){
				
			}
			else if(userInput == 7){
				
			}
			else if(userInput == 8){
				
			}
			else if(userInput == 9){
				
			}
			else if(userInput == 10){
				
			}
			else if(userInput == 11){
				try{
					if(stmt!=null)
            			stmt.close();
				}catch(SQLException se2){}
				try{
					if(conn!=null)
						conn.close();
				}catch(SQLException se){
					se.printStackTrace();
				}
				System.out.println("Exit successful.");
				System.exit(0);
			}
			else{
				System.out.println("Invalid input\n");
			}
		}
	}
	public static void addCustomer(){
		Scanner scanner = new Scanner(System.in);
		Boolean correct = true;
		Boolean verify = true;
		String salutation, fname, lname, street, city, state, pn, email, ccn, cced, cced2;
		String sql;
		try{
			while(correct){
				System.out.println("----Add Customer----");
				System.out.println("Please enter the following information.");
				while (verify){
					System.out.println("Salutation (mr./mrs.): ");
					salutation = scanner.nextLine();
					System.out.println("First name: ");
					fname = scanner.nextLine();
					System.out.println("Last name: ");
					lname = scanner.nextLine();
					sql = "SELECT first_name, last_name FROM customer WHERE first_name = "+fname+" AND last_name = " +lname +"";
					ResultSet rs = stmt.executeQuery(sql);
					Boolean exist = rs.next();
					if(exist != null){
						System.out.println("A customer by this name already exists.");
						System.out.println("Please eneter a new name.");
					}
					else{
						verify = false;
					}
					rs.close();
				}
				verify = true;
				
				System.out.println("Address Street: ");
				street = scanner.nextLine();
				System.out.println("Address city: ");
				city = scanner.nextLine();
				System.out.println("State(abbv): ");
				state = scanner.nextLine();
				while(verify){
					System.out.println("Phone number (10 digit number): ");
					pn = scanner.nextLine();
					if(pn.length() == 10){
						verify = false;
					}
					else{
						System.out.println("Phone number not valid.");
					}
				}
				verify = true;
				while(verify){
					System.out.println("Email address(maximum of 30 characters): ");
					email = scanner.nextLine();
					if(email.length() <= 30){
						verify = false;
					}
					else{
						System.out.println("Email address not valid.");
					}
				}
				verify = true;
				while(verify){
					System.out.println("Credit card number (16 digit number): ");
					ccn = scanner.nextLine();
					if(ccn.length() == 16){
						verify = false;
					}
					else{
						System.out.println("Credit card number not valid.");
					}
				}
				System.out.println("Credit card expirtion date (enter as mm/dd/yyyy): ");
				cced = scanner.nextLine();
				cced2 = "to_date('"+cced+"', 'mm/dd/yyyy')";
				System.out.println("Adding customer to system...");
				correct = false;
			}
			sql = "SELECT MAX(cid) FROM customer";
			ResultSet rs = stmt.executeQuery(sql);
			int cid = -1;
			int ffm = 0;
			if(rs.next()){
				cid  = rs.getInt("cid"); 
			}
			else{
				System.out.println("error addin customer");
			}
			if(cid != -1){
				sql = "insert into customer values('"+cid+"', '"+salutation+"', '"+fname+"', '"+lname+"', '"+ccn+"', "+cced2+", '"+street+"', '"+
									city + "', '"+state+"', '"+pn+"', '"+email+"', '"+ffm+"');";
				stmt.executeUpdate(sql);
				System.out.println("Success!");
				System.out.println("Your customer ID is " + cid);
			}
		}catch(SQLException se){
			se.printStackTrace();
		}catch(Exception e){
			e.printStackTrace();
		}
		return;
	}
	public static void showCustomer(){
		Scanner scanner = new Scanner(System.in);
		String fname;
		String lname;
		String sql;
		System.out.println("---Show Customer---");
		try{
			System.out.println("First name: ");
			fname = scanner.nextLine();
			System.out.println("Last name: ");
			lname = scanner.nextLine();
			sql = "SELECT first_name, last_name FROM customer WHERE first_name = "+fname+" AND last_name = " +lname +"";
			ResultSet rs = stmt.executeQuery(sql);
			Boolean exist = rs.next();
			if(exist != null){
				String s  = rs.getString("salutation");
				int cid = rs.getInt("cid");
				String pn = rs.getString("phone");
				String email = rs.getString("email");
				System.out.println(""+s+" "+fname+ " " + lname+"");
				System.out.println("Pitt rewards number: " + cid+ "");
				System.out.println("Phone number: " + pn+ "");
				System.out.println("Email: " + email+ "");
			}
			else{
				System.out.println("Customer not found");
			}
			rs.close();
		}catch(SQLException se){
			se.printStackTrace();
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	public static void findPrice(){
		Scanner scanner = new Scanner(System.in);
		String sql;
		String ca;
		String cb;
		System.out.println("---Find flight price menu---");System.out.println("Available cities:");
		try{
			System.out.println("Please enter the following");
			System.out.println("Departure city (abbv.): ");
			ca = scanner.nextLine();
			System.out.println("Arrival city (abbv.): ");
			cb = scanner.nextLine();
			
			sql = "SELECT high_price, low_price FROM price WHERE departure_city = " + ca + " AND arrival_city = " + cb +"";
			ResultSet rs = stmt.executeQuery(sql);
			Boolean AtoB = rs.next();
			int AtoBhp, AtoBlp;
			if(AtoB != null){
				AtoBhp  = rs.getInt("high_price");
				AtoBlp  = rs.getInt("low_price");
				System.out.println("Flight from "+ca+" to" + cb+ ":");
				System.out.println("High price: " +AtoBhp);
				System.out.println("Low price: " +AtoBlp);
			}
			else{
				System.out.println("Flight from "+ca+" to" + cb+ " not available");
			}
			sql = "SELECT high_price, low_price FROM price WHERE departure_city = " + cb + " AND arrival_city = " + ca +"";
			rs = stmt.executeQuery(sql);
			Boolean BtoA = rs.next();
			int BtoAhp, BtoAlp;
			if(BtoA != null){
				BtoAhp  = rs.getInt("high_price");
				BtoAlp  = rs.getInt("low_price");
				System.out.println("Flight from "+cb+" to" + ca+ ":");
				System.out.println("High price: " +BtoAhp);
				System.out.println("Low price: " +BtoAlp);
			}
			else{
				System.out.println("Flight from "+cb+" to" + ca+ " not available");
			}
			if(BtoA != null && AtoB != null){
				System.out.println("Round trip from "+ca+" to" + cb+ ":");
				int rthp = BtoAhp + AtoBhp;
				int rtlp = BtoAlp + AtoBlp;
				System.out.println("High price: " +rthp);
				System.out.println("Low price: " +rtlp);
			}
			else{
				System.out.println("Round trip not available.");
			}
			
			rs.close();
		}catch(SQLException se){
				se.printStackTrace();
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	public static void findRoutes(){
		
	}
}




