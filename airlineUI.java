import java.util.*;
import java.io.*;
import java.sql.*;
import java.text.ParseException;

public class airlineUI{
	
	static final String USER = "jat134";	//Your username
	static final String PASS = "hihi2222";	//your password
	static final String url = "jdbc:oracle:thin:@class3.cs.pitt.edu:1521:dbclass";	//if connecting to class3
	//static final String url = "jdbc:oracle:thin:@unixs.cs.pitt.edu:1521:dbclass";	//if connecting to unixs
																					//one must be commented out for code to function
	private static Connection conn = null;
	private static Statement stmt = null;
	
	public static void main(String args[]){
		try{
			DriverManager.registerDriver (new oracle.jdbc.driver.OracleDriver());
			System.out.println("Connecting to database...");
			conn = DriverManager.getConnection(url,USER,PASS);
			System.out.println("Creating database...");
			stmt = conn.createStatement();
			//String sql = "CREATE DATABASE pittToursDB";
			//stmt.executeUpdate(sql);
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
		Scanner scan = new Scanner(System.in);
		while(true){
			System.out.println("\n-----Administrator Menu-----");
			System.out.println("1. Erase the database");
			System.out.println("2. Load airline information");
			System.out.println("3. Load schedule information");
			System.out.println("4. Load pricing information");
			System.out.println("5. Load plane information");
			System.out.println("6. Generate passenger manifest for a specific flight on a given day");
			System.out.println("7. Quit");
			int userInput = scan.nextInt();
			
			if(userInput == 1){
				System.out.println("Are you sure you want to delete the entire database? Please type Y for yes or N for no");
				Scanner scan1 = new Scanner(System.in);
				String s = scan1.nextLine();
				if (s.equals("Y")) {
					deleteDatabase();
				}
				else {
					System.out.println("You have changed your mind about deleting the database. Goodbye.");
					System.exit(0);
				}
				scan1.close();
			}
			
			else if(userInput == 2){
				try {
					loadAirlineInformation();
				} catch (IOException e) {
					e.printStackTrace();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
			else if(userInput == 3){
				try {
					loadScheduleInformation();
				} catch (IOException e) {
					e.printStackTrace();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
			else if(userInput == 4){
				Scanner scan1 = new Scanner(System.in);
				System.out.println("Would you like to load pricing information or change the price of an existing flight? To load price please enter L or if you want to change please enter C");
				if (scan1.next().equals("C")) {
					//change pricing information
					try {
						changePricingInformation();
					} catch (SQLException e) {
						e.printStackTrace();
					}
				}
				else if (scan1.next().equals("L")) {
					//load information
					try {
						loadPricingInformation();
					} catch (IOException e) {
						e.printStackTrace();
					} catch (SQLException e) {
						e.printStackTrace();
					}
				}
				else {
					System.out.println("You have input the wrong entry. Sorry, goodbye.");
					System.exit(0);
				}
				scan1.close();
			}
			else if(userInput == 5){
				try {
					loadPlaneInformation();
				} catch (IOException e) {
					e.printStackTrace();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
			else if(userInput == 6){
				try {
					generateManifesto();
				} catch (SQLException e) {
					e.printStackTrace();
				}
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
			scan.close();

		}
	}
	
	public static int deleteDatabase () {
		System.out.println("Deleting Database...");
		try {
			Statement stmt = conn.createStatement();
			String airlineDelete = "TRUNCATE Airline";
			stmt.executeUpdate(airlineDelete);
			
			String flightDelete = "TRUNCATE Flight";
			stmt.executeUpdate(flightDelete);
			
			String planeDelete = "TRUNCATE Plane";
			stmt.executeUpdate(planeDelete);
			
			String priceDelete = "TRUNCATE Price";
			stmt.executeUpdate(priceDelete);
			
			String customerDelete = "TRUNCATE Customer";
			stmt.executeUpdate(customerDelete);
			
			String reservationDelete = "TRUNCATE Reservation";
			stmt.executeUpdate(reservationDelete);
			
			String reservationDetailsDelete = "TRUNCATE Reservation_detail";
			stmt.executeUpdate(reservationDetailsDelete);
			
			String dateDelete = "TRUNCATE Date";
			stmt.executeUpdate(dateDelete);
			
			System.out.println("Database is now empty");
			
		} catch (SQLException e) {
			System.out.println("An error occured while deleting database. Goodbye.");
			System.exit(0);
		}
		return 0;
	}
	
	public static void loadAirlineInformation() throws IOException, SQLException {
		Scanner scan = new Scanner (System.in);
		System.out.println("Please enter a file name to load airline information");
		String fileName = scan.next();
		BufferedReader br = new BufferedReader(new FileReader(fileName));
		String line;
		System.out.println("Inserting airline info...");
		while ((line = br.readLine()) != null) {
			String var[] = line.split(",");
			String airlineID = var[0];
			String airlineName = var[1];
			String airlineAbbreviation = var[2];
			String yearFounded = var[3];
			
			Statement stmt = conn.createStatement();
			String insertAirline = "INSERT INTO Airline (airline_id, airline_name, airline_abbreviation, year_founded) VALUES ('"+airlineID+"','" +airlineName+"','"+airlineAbbreviation+"','"+yearFounded+"')";
			stmt.executeUpdate(insertAirline);
		}
		br.close();
		scan.close();
	}
	
	public static void loadScheduleInformation() throws IOException, SQLException {
		Scanner scan = new Scanner (System.in);
		System.out.println("Please enter a file name to load flight information");
		String fileName = scan.next();
		BufferedReader br = new BufferedReader(new FileReader(fileName));
		String line;
		System.out.println("Inserting flight info...");
		while ((line = br.readLine()) != null) {
			String var[] = line.split(",");
			String flightNumber = var[0];
			String planeType = var[1];
			String departureCity = var[2];
			String arrivalCity = var[3];
			String departureTime = var[4];
			String arrivalTime = var[5];
			String weeklySchedule = var[6];
			
			Statement stmt = conn.createStatement();
			String insertFlight = "INSERT INTO Flight (flight_number, plane_type, departure_city, arrival_city, departure_time, arrival_time, weekly_schedule) VALUES ('"+flightNumber+"','" +planeType+"','"+departureCity+"','"+arrivalCity+"','"+departureTime+"','"+arrivalTime+"','"+weeklySchedule+"')";
			stmt.executeUpdate(insertFlight);
		}
		br.close();
		scan.close();
	}
	
	public static int changePricingInformation() throws SQLException {
		Scanner input = new Scanner (System.in);
		String departureCity;
		String arrivalCity;
		String airlineID;
		int highCost;
		int lowCost;
		
		System.out.println("Please enter departure city as airport code. E.g. Pittsburgh will be PIT");
		if (input.next().length() > 3) {
			System.out.println("Sorry you input too many letters for the airport code. Goodbye.");
			return 0;
		}
		else {
			departureCity = input.next();
		}
		
		System.out.println("Please enter arrival city as airport code. E.g. Pittsburgh will be PIT");
		if (input.next().length() > 3) {
			System.out.println("Sorry you input too many letters for the airport code. Goodbye.");
			return 0;
		}
		else {
			arrivalCity = input.next();
		}
		
		System.out.println("Please enter airline ID number. The number should not be more than three numbers");
		if (input.next().length() > 3) {
			System.out.println("Sorry you input too many numbers for the airline ID. Goodbye.");
			return 0;
		}
		else {
			airlineID = input.next();
		}
		
		System.out.println("Please enter the high cost for this flight. Input should be a max of 3 digits and rounded to the closest ones place. E.g. $230.10 will be 230");
		if (input.next().length() > 3) {
			System.out.println("Sorry you inputt too many numbers for the High Cost. Goodbye.");
			return 0;
		}
		else {
			highCost = input.nextInt();
		}
		
		System.out.println("Please enter the low cost for this flight. Input should be a max of 3 digits and rounded to the closest ones place. E.g. $230.10 will be 230");
		if (input.next().length() > 3) {
			System.out.println("Sorry you input too many numbers for the airline ID. Goodbye.");
			return 0;
		}
		else {
			lowCost = input.nextInt();
		}
		
		Statement stmt = conn.createStatement();
		String updatePrice = "UPDATE PRICE SET high_cost =" + highCost + ",low_cost=" + lowCost + "WHERE departure_city ='" + departureCity + "' and arrival_city='" + arrivalCity + "' and airline_id='"+airlineID+ "'";
		stmt.executeUpdate(updatePrice);
		input.close();
		return 0;
	}
	
	public static void loadPricingInformation() throws IOException, SQLException {
		Scanner scan = new Scanner (System.in);
		System.out.println("Please enter a file name to load pricing information");
		String fileName = scan.next();
		BufferedReader br = new BufferedReader(new FileReader(fileName));
		String line;
		System.out.println("Inserting pricing info...");
		while ((line = br.readLine()) != null) {
			String var[] = line.split(",");
			String departureCity = var[0];
			String arrivalCity = var[1];
			String airlineID = var[2];
			String highPrice = var[3];
			String lowPrice = var[4];
			
			Statement stmt = conn.createStatement();
			String insertPrice = "INSERT INTO Price (departure_city, arrival_city, airline_id, high_price, low_price) VALUES ('"+departureCity+"','" +arrivalCity+"','"+airlineID+"','"+highPrice+"','"+lowPrice+"')";
			stmt.executeUpdate(insertPrice);
		}
		br.close();
		scan.close();
	}
	
	public static int loadPlaneInformation() throws IOException, SQLException {
		Scanner scan = new Scanner (System.in);
		System.out.println("Please enter a file name to load plane information");
		String fileName = scan.next();
		BufferedReader br = new BufferedReader(new FileReader(fileName));
		String line;
		System.out.println("Inserting plane info...");
		while ((line = br.readLine()) != null) {
			String var[] = line.split(",");
			String planeType = var[0];
			String manufacture = var[1];
			String planeCapacity = var[2];
			String lastService = var[3];
			String year = var[4];
			String ownerID = var[5];
			
			if (planeType.length() > 4) {
				System.out.println("Plane type input is incorrect.");
				return 0;
			}
			if (ownerID.length() > 3) {
				System.out.println("Owner id input is incorrect");
				return 0;
			}
			Statement stmt = conn.createStatement();
			String insertPlane = "INSERT INTO Plane (plane_type, manufacture, plane_capacity, last_service, year, owner_id) VALUES ('"+planeType+"','" +manufacture+"','"+planeCapacity+"','"+lastService+"','"+year+"','"+ownerID+"')";
			stmt.executeUpdate(insertPlane);
		}
		br.close();
		scan.close();
		return 0;
	}
	
	public static int generateManifesto() throws SQLException {
		Scanner scan = new Scanner (System.in);
		System.out.println("Please input the flight number. The flight number should not be more than 3 numbers: ");
		String flightNumber = scan.next();
		
		System.out.println("Please input the date. The format of the date should be MM/DD/YYYY: ");
		String date = scan.next();
		
		if (flightNumber.length() > 3) {
			System.out.println("Flight number input is incorrect.");
			return 0;
		}
		Statement stmt = conn.createStatement();
		String manifesto = "Select salutation, first_name, last_name FROM Customer AS c INNER JOIN Reservation as r ON c.cid = r.cid INNER JOIN Reservation_detail as d ON r.reservation_number = d.reservation_number WHERE Reservation_detail.flight_number = " + flightNumber + " and" + "Reservation_detail.flight_date = " + date + "";
		ResultSet rs = stmt.executeQuery(manifesto);
		scan.close();
		return 0;
	}

//-------------------------------------------------------------	
//------------------------ USER INTERFACE ---------------------
//-------------------------------------------------------------
	
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
		boolean correct = true;
		boolean verify = true;
		String salutation = "", 
				fname = "", 
				lname = "", 
				street = "", 
				city= "", 
				state = "", 
				pn = "", 
				email = "", 
				ccn= "", 
				cced= "", 
				cced2 = "";
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
					sql = "SELECT first_name, last_name FROM customer WHERE first_name = '"+fname+"' AND last_name = '" +lname +"'";
					ResultSet rs = stmt.executeQuery(sql);
					if(rs.next() == true){
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
			sql = "SELECT MAX(cid) as maxid FROM customer";
			ResultSet rs = stmt.executeQuery(sql);
			
			int cid = -1;
			int ffm = 0;
			if(rs.next()){
				cid  = rs.getInt("maxid");
				cid++;
				System.out.println(""+cid);
			}
			else{
				System.out.println("error adding customer");
			}
			if(cid != -1){
				sql = "insert into customer values('"+cid+"', '"+salutation+"', '"+fname+"', '"+lname+"', '"+ccn+"', "+cced2+", '"+street+"', '"+
									city + "', '"+state+"', '"+pn+"', '"+email+"', '"+ffm+"')";
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
			sql = "SELECT * FROM customer WHERE first_name = '"+fname+"' AND last_name = '" +lname +"'";
			ResultSet rs = stmt.executeQuery(sql);
			
			if(rs.next()){
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
		String sql = "";
		String ca = "";
		String cb = "";
		System.out.println("---Find flight price menu---");
		try{
			System.out.println("Please enter the following");
			System.out.println("Departure city (abbv.): ");
			ca = scanner.nextLine();
			System.out.println("Arrival city (abbv.): ");
			cb = scanner.nextLine();
			
			sql = "SELECT high_price, low_price FROM price WHERE departure_city = '" + ca + "' AND arrival_city = '" + cb +"'";
			ResultSet rs = stmt.executeQuery(sql);
			int AtoBhp = 0, AtoBlp = 0;
			if(rs.next()){
				AtoBhp  = rs.getInt("high_price");
				AtoBlp  = rs.getInt("low_price");
				System.out.println("Flight from "+ca+" to" + cb+ ":");
				System.out.println("High price: " +AtoBhp);
				System.out.println("Low price: " +AtoBlp);
			}
			else{
				System.out.println("Flight from "+ca+" to" + cb+ " not available");
			}
			sql = "SELECT high_price, low_price FROM price WHERE departure_city = '" + cb + "' AND arrival_city = '" + ca +"'";
			ResultSet rs1 = stmt.executeQuery(sql);
			int BtoAhp = 0, BtoAlp = 0;
			if(rs1.next()){
				BtoAhp  = rs.getInt("high_price");
				BtoAlp  = rs.getInt("low_price");
				System.out.println("Flight from "+cb+" to" + ca+ ":");
				System.out.println("High price: " +BtoAhp);
				System.out.println("Low price: " +BtoAlp);
			}
			else{
				System.out.println("Flight from "+cb+" to" + ca+ " not available");
			}
			if(rs.next() && rs1.next()){
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
		Scanner scanner = new Scanner(System.in);
		String sql = "";
		String ca = "";
		String cb = "";
		System.out.println("---Find all route menu---");
		try{
			System.out.println("Please enter the following");
			System.out.println("Departure city (abbv.): ");
			ca = scanner.nextLine();
			System.out.println("Arrival city (abbv.): ");
			cb = scanner.nextLine();
			sql = "SELECT * FROM flight WHERE departure_city = '" + ca + "' AND arrival_city = '" + cb +"'";
			ResultSet rs = stmt.executeQuery(sql);
			System.out.println("Direct routes: \n");
			while(rs.next()){
				String fn  = rs.getString("flight_number");
				String dc  = rs.getString("departure_city");
				String dt  = rs.getString("departure_time");
				String ac  = rs.getString("arrival_city");
				String at  = rs.getString("arrival_time");
				System.out.println("Flight no: "+fn);
				System.out.println("Departs " + dc + " at " + dt);
				System.out.println("Arrives at " + ac + " at " + at + "\n");
			}
			
			System.out.println("Non-direct routes:\n");
			
			
			
		}catch(SQLException se){
				se.printStackTrace();
		}catch(Exception e){
			e.printStackTrace();
		}
	}
}