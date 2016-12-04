import java.util.*;
import java.io.*;
import java.sql.*;
import java.text.ParseException;
import java.lang.*;

public class airlineUI{
	
	static final String USER = "jat134";	//Your username
	static final String PASS = "hihi2222";	//your password
	static final String url = "jdbc:oracle:thin:@class3.cs.pitt.edu:1521:dbclass";	//if connecting to class3
	//static final String url = "jdbc:oracle:thin:@unixs.cs.pitt.edu:1521:dbclass";	//if connecting to unixs
																					//one must be commented out for code to function
	private static Connection conn = null;
	private static Statement stmt = null;
	private static Statement stmt2 = null;
	private static Statement stmt3 = null;
	
	public static void main(String args[]){
		try{
			DriverManager.registerDriver (new oracle.jdbc.driver.OracleDriver());
			System.out.println("Connecting to database...");
			conn = DriverManager.getConnection(url,USER,PASS);
			System.out.println("Creating database...");
			stmt = conn.createStatement();
			stmt2 = conn.createStatement();
			stmt3 = conn.createStatement();
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
			System.out.println("3. Stress test");
			System.out.println("4. Exit");
			choice = scanner.nextInt();
			if(choice == 1){
				adminInterface();
			}
			else if(choice == 2){
				userInterface();
			}
			else if(choice == 3){
				stressTest();
			}
			else if(choice == 4){
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
	public static void stressTest(){
		Scanner scanner = new Scanner(System.in);
		PrintStream console = System.out;
		System.out.println("--------Stress Test--------");
		System.out.println("--Stress test command can only be run once");
		System.out.println("--Prior to running, run pittToursData.sql");
		System.out.println("--You must purge the database and rerun pittToursData.sql to run a second time");
		System.out.println("--Output will be redirected to stressTestOutput.txt");
		System.out.println("--SQL errors will print to console");
		System.out.println("Input 1 to continue. Any other input will return to menu.");
		int c = scanner.nextInt();
		if(c != 1){
			return;
		}
		PrintStream o = null;
		FileOutputStream fout = null;
		File f = new File("stressTestOutput.txt");
		try{
			f.createNewFile();
		}catch(IOException e){}
		try{
			fout = new  FileOutputStream(f);
		}catch(FileNotFoundException e){}
		o = new PrintStream(fout);
		System.setOut(o);
		//Stess test admin Interface
		System.out.println("-------------------START-------------------");
		System.out.println("---------------------------------------------");
		System.out.println("---------------------------------------------");
		System.out.println("---------------ADMIN INTERFACE---------------");
		System.out.println("---------------------------------------------");
		System.out.println("---------------------------------------------");
		
		//Stress test customer Interface
		System.out.println("------------------------------------------------");
		System.out.println("------------------------------------------------");
		System.out.println("---------------CUSTOMER INTERFACE---------------");
		System.out.println("------------------------------------------------");
		System.out.println("------------------------------------------------");
		stAddCustomer();	//task 1
		stShowCustomer();	//task 2
		stFindPrice();			//task 3
		stFindRoutes();			//task 4
		stFindRoutesByAirline();	//task 5
		stFindRoutesWithSeats();	//task 6
		stFindRoutesWithSeatsByAirline();	//task 7
				//task 8
		stShowReservationInfo();	//task 9
		stBuyTicket();		//task 10
		System.out.println("-------------------END--------------------");
		System.setOut(console);
        System.out.println("Stress test finished");
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

		}
	}
	
	public static int deleteDatabase () {
		System.out.println("Deleting Database...");
		try {
			String dateDelete = "DELETE * FROM Date";
			stmt.executeUpdate(dateDelete);
			System.out.println("Date erased");
			String reservationDetailsDelete = "DELETE * FROM Reservation_detail";
			stmt.executeUpdate(reservationDetailsDelete);
			System.out.println("Reservation data detail erased");
			String reservationDelete = "DELETE * FROM Reservation";
			stmt.executeUpdate(reservationDelete);
			System.out.println("Reservation data erased");
			String customerDelete = "DELETE * FROM Customer";
			stmt.executeUpdate(customerDelete);
			System.out.println("Customer data erased");
			String priceDelete = "DELETE * FROM Price";
			stmt.executeUpdate(priceDelete);
			System.out.println("Price data erased");
			String planeDelete = "DELETE * FROM Plane";
			stmt.executeUpdate(planeDelete);
			System.out.println("Plane data erased");
			String flightDelete = "DELETE * FROM Flight";
			stmt.executeUpdate(flightDelete);
			System.out.println("Flight data erased");
			Statement stmt = conn.createStatement();
			String airlineDelete = "DELETE * FROM Airline";
			stmt.executeUpdate(airlineDelete);
			System.out.println("Airline data erased");
			System.out.println("Database is now empty");
			conn.commit();
			
		} catch (SQLException e) {
			System.out.println("An error occured while deleting database. Goodbye.");
			System.exit(0);
		}
		return 0;
	}
	
	public static void loadAirlineInformation() throws IOException, SQLException {
		Scanner scan2 = new Scanner (System.in);
		System.out.println("Please enter a file name to load airline information");
		String fileName = scan2.nextLine();
		BufferedReader br = new BufferedReader(new FileReader(fileName));
		String line;
		System.out.println("Inserting airline info...");
		while ((line = br.readLine()) != null) {
			String var[] = line.split(",");
			String airlineID = var[0];
			String airlineName = var[1];
			String airlineAbbreviation = var[2];
			String city = var[3];
			String yearFounded = var[4];
			int year = Integer.parseInt(yearFounded);

			String insertAirline = "INSERT INTO Airline (aid, name, abbreviation, year_founded) VALUES ('"+airlineID+"','" +airlineName+"','"+airlineAbbreviation+"','"+year+"')";
			stmt.executeUpdate(insertAirline);
		}
		br.close();
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
			
			String insertFlight = "INSERT INTO Flight (flight_number, plane_type, departure_city, arrival_city, departure_time, arrival_time, weekely_schedule) VALUES ('"+flightNumber+"','" +planeType+"','"+departureCity+"','"+arrivalCity+"','"+departureTime+"','"+arrivalTime+"','"+weeklySchedule+"')";
			stmt.executeUpdate(insertFlight);
		}
		br.close();
	}
	
	public static int changePricingInformation() throws SQLException {
		Scanner input = new Scanner (System.in);
		String departureCity;
		String arrivalCity;
		String airlineID;
		int highCost;
		int lowCost;
		
		System.out.println("Please enter departure city as airport code. E.g. Pittsburgh will be PIT");
		//if (input.next().length() > 3) {
		//	System.out.println("Sorry you input too many letters for the airport code. Goodbye.");
		//	return 0;
		//}
		//else {
			departureCity = input.next();
		//}
		
		System.out.println("Please enter arrival city as airport code. E.g. Pittsburgh will be PIT");
		//if (input.next().length() > 3) {
		//	System.out.println("Sorry you input too many letters for the airport code. Goodbye.");
		//	return 0;
		//}
		//else {
			arrivalCity = input.next();
		//}
		
		System.out.println("Please enter airline ID number. The number should not be more than three numbers");
		//if (input.next().length() > 3) {
		//	System.out.println("Sorry you input too many numbers for the airline ID. Goodbye.");
		//	return 0;
		//}
		//else {
			airlineID = input.next();
		//}
		
		System.out.println("Please enter the high cost for this flight. Input should be a max of 3 digits and rounded to the closest ones place. E.g. $230.10 will be 230");
		//if (input.next().length() > 3) {
		//	System.out.println("Sorry you inputt too many numbers for the High Cost. Goodbye.");
		//	return 0;
		//}
		//else {
			highCost = input.nextInt();
		//}
		
		System.out.println("Please enter the low cost for this flight. Input should be a max of 3 digits and rounded to the closest ones place. E.g. $230.10 will be 230");
		//if (input.next().length() > 3) {
		//	System.out.println("Sorry you input too many numbers for the airline ID. Goodbye.");
		//	return 0;
		//}
		//else {
			lowCost = input.nextInt();
		//}
		
		String updatePrice = "UPDATE PRICE SET high_price =" + highCost + ",low_price=" + lowCost + "WHERE departure_city ='" + departureCity + "' and arrival_city='" + arrivalCity + "' and airline_id='"+airlineID+ "'";
		stmt.executeUpdate(updatePrice);
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
			
			String insertPrice = "INSERT INTO Price (departure_city, arrival_city, airline_id, high_price, low_price) VALUES ('"+departureCity+"','" +arrivalCity+"','"+airlineID+"','"+highPrice+"','"+lowPrice+"')";
			stmt.executeUpdate(insertPrice);
		}
		br.close();
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
			String insertPlane = "INSERT INTO Plane (plane_type, manufacture, plane_capacity, last_service, year, owner_id) VALUES ('"+planeType+"','" +manufacture+"','"+planeCapacity+"','"+lastService+"','"+year+"','"+ownerID+"')";
			stmt.executeUpdate(insertPlane);
		}
		br.close();
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

		String manifesto = "Select salutation, first_name, last_name FROM Customer AS c INNER JOIN Reservation as r ON c.cid = r.cid INNER JOIN Reservation_detail as d ON r.reservation_number = d.reservation_number WHERE Reservation_detail.flight_number = " + flightNumber + " and" + "Reservation_detail.flight_date = " + date + "";
		ResultSet rs = stmt.executeQuery(manifesto);
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
						scanner.nextLine();
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
					}
					else{
						System.out.println("error adding customer");
					}
					if(cid != -1){
						addCustomer(cid, salutation, fname, lname, ccn, cced2, street, city, state, pn, email, ffm);
					}
				}catch(SQLException se){
					se.printStackTrace();
				}catch(Exception e){
					e.printStackTrace();
				}
			}
			else if(userInput == 2){
				scanner.nextLine();
				String fname;
				String lname;
				System.out.println("---Show Customer---");
				System.out.println("First name: ");
				fname = scanner.nextLine();
				System.out.println("Last name: ");
				lname = scanner.nextLine();
				showCustomer(fname, lname);
			}
			else if(userInput == 3){
				scanner.nextLine();
				System.out.println("---Find flight price menu---");
				System.out.println("Please enter the following");
				System.out.println("Departure city (abbv.): ");
				String ca = scanner.nextLine();
				System.out.println("Arrival city (abbv.): ");
				String cb = scanner.nextLine();
				findPrice(ca, cb);
			}
			else if(userInput == 4){
				scanner.nextLine();
				System.out.println("---Find all route menu---");
				System.out.println("Please enter the following");
				System.out.println("Departure city (abbv.): ");
				String ca = scanner.nextLine();
				System.out.println("Arrival city (abbv.): ");
				String cb = scanner.nextLine();
				findRoutes(ca, cb);
			}
			else if(userInput == 5){
				scanner.nextLine();
				System.out.println("---Find all route by airline menu---");
				System.out.println("Please enter the following");
				System.out.println("Airline name: ");
				String aln = scanner.nextLine();
				System.out.println("Departure city (abbv.): ");
				String ca = scanner.nextLine();
				System.out.println("Arrival city (abbv.): ");
				String cb = scanner.nextLine();
				findRoutesByAirline(ca, cb, aln);
			}
			else if(userInput == 6){
				scanner.nextLine();
				System.out.println("---Find all route with seats by date---");
				System.out.println("Please enter the following");
				System.out.println("Departure city (abbv.): ");
				String ca = scanner.nextLine();
				System.out.println("Arrival city (abbv.): ");
				String cb = scanner.nextLine();
				System.out.println("Date in format mm/dd/yyyy: ");
				String date = scanner.nextLine();
				findRoutesWithSeats(ca, cb, date);
			}
			else if(userInput == 7){
				scanner.nextLine();
				System.out.println("---Find all route with seats by date---");
				System.out.println("Please enter the following");
				System.out.println("Airline name: ");
				String aln = scanner.nextLine();
				System.out.println("Departure city (abbv.): ");
				String ca = scanner.nextLine();
				System.out.println("Arrival city (abbv.): ");
				String cb = scanner.nextLine();
				System.out.println("Date in format mm/dd/yyyy: ");
				String date = scanner.nextLine();
				findRoutesWithSeatsByAirline(ca, cb, date, aln);
			}
			else if(userInput == 8){
				
			}
			else if(userInput == 9){
				scanner.nextLine();
				System.out.println("---Show Reservation Info---");
				System.out.println("Reservation number: ");
				String r_no = scanner.nextLine();
				showReservationInfo(r_no);
			}
			else if(userInput == 10){
				scanner.nextLine();
				System.out.println("---Buy Ticket---");
				System.out.println("Reservation number: ");
				String r_no = scanner.nextLine();
				buyTicket(r_no);
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
	public static void addCustomer(int cid, String salutation, String fname, String lname, String ccn, String cced2, String street, String city, String state, String pn, String email, int ffm){
		try{
			String sql = "insert into customer values('"+cid+"', '"+salutation+"', '"+fname+"', '"+lname+"', '"+ccn+"', "+cced2+", '"+street+"', '"+
								city + "', '"+state+"', '"+pn+"', '"+email+"', '"+ffm+"')";
			stmt.executeUpdate(sql);
			System.out.println("Success!");
			System.out.println("Your customer ID is " + cid);
		}catch(SQLException se){
			se.printStackTrace();
		}catch(Exception e){
			e.printStackTrace();
		}
		return;
	}
	public static void stAddCustomer(){
		try{
			System.out.println("--------------------------------");
			System.out.println("----STRESS TEST ADD CUSTOMER----");
			System.out.println("--------------------------------");
			String sql = "SELECT MAX(cid) as maxid FROM customer";
			ResultSet rs = stmt.executeQuery(sql);			
			int cid = -1;
			if(rs.next()){
				cid  = rs.getInt("maxid");
				cid++;
			}
			sql = "Select count(cid) as cno FROM customer";
			rs = stmt.executeQuery(sql);	
			int cno = -1;
			if(rs.next()){
				cno  = rs.getInt("cno");
			}
			System.out.println("Current customer count: " + cno);
			System.out.println("Adding 10 customers...");
			addCustomer(cid++, "mr", "john", "ham", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mr", "johny", "hamma", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mr", "sam", "something", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mr", "tomas", "ahh", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mr", "trav", "some", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "ell", "boon", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "amy", "tan", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "eileen", "shaw", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "sam", "ham", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "leslie", "dean", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			rs = stmt.executeQuery(sql);
			int newCno = -1;
			if(rs.next()){
				newCno  = rs.getInt("cno");
			}
			System.out.println("Current customer count: " + newCno);
			//added 10 customers
			
			System.out.println("Adding 10 more customers...");
			addCustomer(cid++, "mr", "eli", "ham", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mr", "junior", "hamma", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mr", "juno", "something", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mr", "tommy", "ahh", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mr", "travis", "some", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "ellenor", "boon", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "amanda", "tan", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "lily", "shaw", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "samantha", "ham", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "lord", "dean", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			rs = stmt.executeQuery(sql);	
			if(rs.next()){
				cno  = rs.getInt("cno");
			}
			System.out.println("Current customer count after adding 20 total: " + cno);
			System.out.println("Adding 10 more customers...");
			addCustomer(cid++, "mr", "job", "ham", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mr", "george", "hamma", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mr", "jeb", "something", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mr", "tyler", "ahh", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mr", "jake", "some", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "tammy", "boon", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "yolanda", "tan", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "donna", "shaw", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "carly", "ham", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "olivia", "dean", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			rs = stmt.executeQuery(sql);	
			if(rs.next()){
				cno  = rs.getInt("cno");
			}
			System.out.println("Current customer count after adding 30 total: " + cno);
			System.out.println("Adding 10 more customers...");
			addCustomer(cid++, "mr", "jeff", "ham", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mr", "georgy", "hond", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mr", "stan", "something", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mr", "bill", "ahh", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mr", "billy", "some", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "tanya", "boon", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "molly", "tan", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "staci", "shaw", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "taylor", "ham", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "liv", "dean", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			rs = stmt.executeQuery(sql);	
			if(rs.next()){
				cno  = rs.getInt("cno");
			}
			System.out.println("Current customer count after adding 40 total: " + cno);
			System.out.println("Adding 10 more customers...");
			addCustomer(cid++, "mr", "jacob", "ham", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mr", "gene", "hamma", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mr", "jeffery", "something", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mr", "tye", "ahh", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mr", "samuel", "some", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "liz", "boon", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "elizabeth", "tan", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "megan", "shaw", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "jacky", "ham", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			addCustomer(cid++, "mrs", "karly", "dean", "1111222233334444","to_date('12/09/2019', 'mm/dd/yyyy')", "Forbes", "Pittsburgh","PA","1009998877","me@gmail.com",0);
			rs = stmt.executeQuery(sql);	
			if(rs.next()){
				cno  = rs.getInt("cno");
			}
			System.out.println("Current customer count after adding 50 total: " + cno);
			
		}catch(SQLException se){
			se.printStackTrace();
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	public static void showCustomer(String fname, String lname){
		String sql;
		try{
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
	public static void stShowCustomer(){
		System.out.println("---------------------------------");
		System.out.println("----STRESS TEST SHOW CUSTOMER----");
		System.out.println("---------------------------------");
		System.out.println("Should be found:");
		showCustomer("john","ham");
		showCustomer("johny","hamma");
		showCustomer("sam","something");
		showCustomer("tomas", "ahh");
		showCustomer("trav", "some");
		showCustomer("ell", "boon");
		showCustomer("amy", "tan");
		showCustomer("eileen", "shaw");
		showCustomer("sam", "ham");
		showCustomer("leslie", "dean");
		
		showCustomer("eli", "ham");
		showCustomer("junior", "hamma");
		showCustomer("juno", "something");
		showCustomer("tommy", "ahh");
		showCustomer("travis", "some");
		showCustomer("ellenor", "boon");
		showCustomer("amanda", "tan");
		showCustomer("lily", "shaw");
		showCustomer("samantha", "ham");
		showCustomer("lord", "dean");
		
		showCustomer("job", "ham");
		showCustomer("george", "hamma");
		showCustomer("jeb", "something");
		showCustomer("tyler", "ahh");
		showCustomer("jake", "some");
		showCustomer("tammy", "boon");
		showCustomer("yolanda", "tan");
		showCustomer("donna", "shaw");
		showCustomer("carly", "ham");
		showCustomer("olivia", "dean");
		
		System.out.println("Should not be found:");
		showCustomer("not","found");
		showCustomer("some","guy");
		showCustomer("some","girl");
		showCustomer("doesnot","exist");
		showCustomer("aaaaaa","notaname");
	}
	public static void findPrice(String ca, String cb){
		String sql = "";
		try{
			sql = "SELECT * FROM price WHERE departure_city = '" + ca + "' AND arrival_city = '" + cb +"'";
			ResultSet rs = stmt.executeQuery(sql);
			boolean r = false;
			int AtoBhp = 0, AtoBlp = 0;
			int al;
			while(rs.next()){
				AtoBhp  = rs.getInt("high_price");
				AtoBlp  = rs.getInt("low_price");
				System.out.println("Flight from "+ca+" to " + cb+ ":");
				System.out.println("High price: " +AtoBhp);
				System.out.println("Low price: " +AtoBlp);
				r = true;
			}
			sql = "SELECT high_price, low_price FROM price WHERE departure_city = '" + cb + "' AND arrival_city = '" + ca +"'";
			ResultSet rs1 = stmt.executeQuery(sql);
			boolean r1 = false;
			int BtoAhp = 0, BtoAlp = 0;
			if(rs1.next()){
				BtoAhp  = rs1.getInt("high_price");
				BtoAlp  = rs1.getInt("low_price");
				System.out.println("Flight from "+cb+" to " + ca+ ":");
				System.out.println("High price: " +BtoAhp);
				System.out.println("Low price: " +BtoAlp);
				r1 = true;
			}
			else{
				System.out.println("Flight from "+cb+" to " + ca+ " not available");
			}
			if(r && r1){
				System.out.println("Round trip from "+ca+" to " + cb+ ":");
				int rthp = BtoAhp + AtoBhp;
				int rtlp = BtoAlp + AtoBlp;
				System.out.println("High price: " +rthp);
				System.out.println("Low price: " +rtlp);
			}
			else{
				System.out.println("Round trip not available.");
			}
			rs1.close();
			rs.close();
		}catch(SQLException se){
				se.printStackTrace();
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	public static void stFindPrice(){
		System.out.println("------------------------------");
		System.out.println("----STRESS TEST FIND PRICE----");
		System.out.println("------------------------------");
		findPrice("PIT", "DCA");
		findPrice("PIT", "SFA");
		findPrice("PIT", "ATL");
		findPrice("JFK", "DCA");
		findPrice("SFA", "PIT");
		findPrice("PIT", "DCA");
		findPrice("JFK", "SFA");
		findPrice("ATL", "LAX");
		findPrice("DCA", "SFA");
		findPrice("SFA", "DCA");
		findPrice("LAX", "DCA");
	}
	public static void findRoutes(String ca, String cb){
		String sql = "";
		int i = 0;
		try{
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
		
			sql = "SELECT * FROM flight WHERE departure_city = '" + ca + "' AND arrival_city != '" + cb +"'";
			rs = stmt.executeQuery(sql);
			while(rs.next()){
				String aCity = rs.getString("arrival_city");
				String dTime = rs.getString("departure_time");
				String aTime = rs.getString("arrival_time");
				String flight_no = rs.getString("flight_number");
				String schedule = rs.getString("weekely_schedule");
				sql = "SELECT * FROM flight WHERE departure_city = '" + aCity + "' AND arrival_city = '" + cb +"'";
				ResultSet rs1 = stmt2.executeQuery(sql);
				while(rs1.next()){
					String flight_no2 = rs1.getString("flight_number");
					String aTime2 = rs1.getString("arrival_time");
					String dTime2 = rs1.getString("departure_time");
					String schedule2 = rs1.getString("weekely_schedule");
					int f1arrival_time = Integer.parseInt(aTime);
					int f2departure_time = Integer.parseInt(dTime2);
					if(f1arrival_time >= 100){
						if(f1arrival_time < f2departure_time - 100){}
						else{
							continue;
						}
					}
					else{
						f1arrival_time = f1arrival_time + 2400;
						if(f1arrival_time > f2departure_time - 100){}
						else{
							continue;
						}
					}
					String[] days = schedule.split("-");
					boolean sameday = false;
					int j = 0;
					if(sameday != true && j < days.length){
						if(schedule2.contains(days[j])){
							sameday = true;
						}
					}
					if(sameday == false){
						continue;
					}
					System.out.println("Flight no: "+flight_no);
					System.out.println("Departs " + ca + " at " + dTime);
					System.out.println("Arrives at " + aCity + " at " + aTime + "");
					System.out.println("Flight no: "+flight_no2);
					System.out.println("Departs " + aCity + " at " + dTime2);
					System.out.println("Arrives at " + cb + " at " + aTime2 + "\n");
				}
			}
			
			
		}catch(SQLException se){
				se.printStackTrace();
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	public static void stFindRoutes(){
		System.out.println("-------------------------------");
		System.out.println("----STRESS TEST FIND ROUTES----");
		System.out.println("-------------------------------");
		System.out.println("----PIT to DCA");
		findRoutes("PIT", "DCA");
		System.out.println("----PIT to SFA");
		findRoutes("PIT", "SFA");
		System.out.println("----PIT to ATL");
		findRoutes("PIT", "ATL");
		System.out.println("----JFK to DCA");
		findRoutes("JFK", "DCA");
		System.out.println("----SFA to PIT");
		findRoutes("SFA", "PIT");
		System.out.println("----JFK to SFA");
		findRoutes("JFK", "SFA");
		System.out.println("----ATL to LAX");
		findRoutes("ATL", "LAX");
		System.out.println("----DCA to SFA");
		findRoutes("DCA", "SFA");
		System.out.println("----SFA to DCA");
		findRoutes("SFA", "DCA");
		System.out.println("----LAX to DCA");
		findRoutes("LAX", "DCA");
	}
	public static void findRoutesByAirline(String ca, String cb, String aln){
		String sql = "";
		String aid = "";
		int i = 0;
		try{
			sql = "SELECT aid FROM airline WHERE name = '" + aln+ "'";
			ResultSet rs = stmt.executeQuery(sql);
			if(rs.next()){
				aid = rs.getString("aid");
			}
			else{
				System.out.println("Airline not found. Returning to menu");
				return;
			}
			
			sql = "SELECT * FROM flight WHERE departure_city = '" + ca + "' AND arrival_city = '" + cb +"' AND airline_id = '"+aid+"'";
			rs = stmt.executeQuery(sql);
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
		
			sql = "SELECT * FROM flight WHERE departure_city = '" + ca + "' AND arrival_city != '" + cb +"' AND airline_id = '"+aid+"'";
			rs = stmt.executeQuery(sql);
			while(rs.next()){
				String aCity = rs.getString("arrival_city");
				String dTime = rs.getString("departure_time");
				String aTime = rs.getString("arrival_time");
				String flight_no = rs.getString("flight_number");
				String schedule = rs.getString("weekely_schedule");
				sql = "SELECT * FROM flight WHERE departure_city = '" + aCity + "' AND arrival_city = '" + cb +"' AND airline_id = '"+aid+"'";
				ResultSet rs1 = stmt2.executeQuery(sql);
				while(rs1.next()){
					String flight_no2 = rs1.getString("flight_number");
					String aTime2 = rs1.getString("arrival_time");
					String dTime2 = rs1.getString("departure_time");
					String schedule2 = rs1.getString("weekely_schedule");
					
					int f1arrival_time = Integer.parseInt(aTime);
					int f2departure_time = Integer.parseInt(dTime2);
					if(f1arrival_time >= 100){
						if(f1arrival_time < f2departure_time - 100){}
						else{
							continue;
						}
					}
					else{
						f1arrival_time = f1arrival_time + 2400;
						if(f1arrival_time > f2departure_time - 100){}
						else{
							continue;
						}
					}
					String[] days = schedule.split("-");
					boolean sameday = false;
					int j = 0;
					if(sameday != true && j < days.length){
						if(schedule2.contains(days[j])){
							sameday = true;
						}
					}
					if(sameday == false){
						continue;
					}
					System.out.println("Flight no: "+flight_no);
					System.out.println("Departs " + ca + " at " + dTime);
					System.out.println("Arrives at " + aCity + " at " + aTime + "");
					System.out.println("Flight no: "+flight_no2);
					System.out.println("Departs " + aCity + " at " + dTime2);
					System.out.println("Arrives at " + cb + " at " + aTime2 + "\n");
					
				}
			}
			
			
		}catch(SQLException se){
				se.printStackTrace();
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	public static void stFindRoutesByAirline(){
		System.out.println("------------------------------------------");
		System.out.println("----STRESS TEST FIND ROUTES By Airline----");
		System.out.println("------------------------------------------");
		System.out.println("----PIT to DCA on airline United Airlines");
		findRoutesByAirline("PIT", "DCA", "United Airlines");
		System.out.println("----PIT to SFA on airline United Airlines");
		findRoutesByAirline("PIT", "SFA", "United Airlines");
		System.out.println("----PIT to SFA on airline Delta Air Lines");
		findRoutesByAirline("PIT", "SFA","Delta Air Lines");
		System.out.println("----PIT to ATL on airline Western Airlines");
		findRoutesByAirline("PIT", "ATL", "Western Airlines");
		System.out.println("----JFK to DCA on airline Delta Air Lines");
		findRoutesByAirline("JFK", "DCA", "Delta Air Lines");
		System.out.println("----JFK to DCA on airline United Airlines");
		findRoutesByAirline("JFK", "DCA", "United Airlines");
		System.out.println("----SFA to PIT on airline United Airlines");
		findRoutesByAirline("SFA", "PIT", "United Airlines");
		System.out.println("----DCA to PIT on airline United Airlines");
		findRoutesByAirline("DCA", "PIT", "United Airlines");
		System.out.println("----DCA to PIT on airline American Airlines");
		findRoutesByAirline("DCA", "PIT", "American Airlines");
		System.out.println("----DCA to PIT on airline All Nippon Airways");
		findRoutesByAirline("DCA", "PIT", "All Nippon Airways");
		System.out.println("----JFK to SFA on airline Delta Air Lines");
		findRoutesByAirline("JFK", "SFA", "Delta Air Lines");
		System.out.println("----JFK to SFA on airline Qatar Airways");
		findRoutesByAirline("JFK", "SFA", "Qatar Airways");
		System.out.println("----ATL to LAX on airline Belair Airlines");
		findRoutesByAirline("ATL", "LAX", "Belair Airlines");
		System.out.println("----DCA to SFA on airline Delta Air Lines");
		findRoutesByAirline("DCA", "SFA", "Delta Air Lines");
		System.out.println("----ATL to DCA on airline United Airlines");
		findRoutesByAirline("ATL", "DCA", "United Airlines");
	}
	public static void findRoutesWithSeats(String ca, String cb, String date){
		String sql = "";
		int i = 0;
		date = "to_date('"+date+"','mm/dd/yyyy')";
		try{
			
			sql = "SELECT * FROM flight WHERE departure_city = '" + ca + "' AND arrival_city = '" + cb +"'";
			ResultSet rs = stmt.executeQuery(sql);
			ResultSet rs1 = null;
			System.out.println("Direct routes: \n");
			while(rs.next()){
				String dc  = rs.getString("departure_city");
				String dt  = rs.getString("departure_time");
				String ac  = rs.getString("arrival_city");
				String at  = rs.getString("arrival_time");
				String fn  = rs.getString("flight_number");
				sql = "SELECT * FROM reservation_detail WHERE flight_date = " + date + " AND flight_number = '"+ fn +"'";
				rs1 = stmt2.executeQuery(sql);
				if(rs1.next()){
					sql = "Select plane_type FROM flight WHERE flight_number = '" + fn +"'";
					rs1 = stmt2.executeQuery(sql);
					String planeType = "";
					if(rs1.next()){
						planeType = rs1.getString("plane_type");
					}
					else{
						continue;
					}
					sql = "Select plane_capacity FROM plane WHERE plane_type = '" + planeType +"'";
					rs1 = stmt2.executeQuery(sql);
					int capacity = 0;
					if(rs1.next()){
						capacity = rs1.getInt("plane_capacity");
					}
					else{
						continue;
					}
					sql = "Select count(*) as passengerCount FROM reservation_detail WHERE flight_date = " + date + " AND flight_number = '" + fn +"'";
					rs1 = stmt.executeQuery(sql);
					int passengerCount = 0;
					if(rs1.next()){
						passengerCount = rs1.getInt("passengerCount");
					}
					else{
						continue;
					}
					if(passengerCount < capacity){
						System.out.println("Flight no: "+fn);
						System.out.println("Departs " + dc + " at " + dt);
						System.out.println("Arrives at " + ac + " at " + at + "\n");
					}
					else{
						continue;
					}
				}
				else{
					continue;
				}
				
			}
			System.out.println("Non-direct routes:\n");
		
			sql = "SELECT * FROM flight WHERE departure_city = '" + ca + "' AND arrival_city != '" + cb +"'";
			rs = stmt.executeQuery(sql);
			while(rs.next()){
				String fn  = rs.getString("flight_number");
				String aCity = rs.getString("arrival_city");
				String dTime = rs.getString("departure_time");
				String aTime = rs.getString("arrival_time");
				String schedule = rs.getString("weekely_schedule");
				sql = "SELECT * FROM reservation_detail WHERE flight_date = " + date + " AND flight_number = '" + fn +"'";
				rs1 = stmt2.executeQuery(sql);
				if(rs1.next()){
					sql = "Select plane_type FROM flight WHERE flight_number = '" + fn +"'";
					rs1 = stmt2.executeQuery(sql);
					String planeType = "";
					if(rs1.next()){
						planeType = rs1.getString("plane_type");
					}
					else{
						continue;
					}
					sql = "Select plane_capacity FROM plane WHERE plane_type = '" + planeType +"'";
					rs1 = stmt2.executeQuery(sql);
					int capacity = 0;
					if(rs1.next()){
						capacity = rs1.getInt("plane_capacity");
					}
					else{
						continue;
					}
					sql = "Select count(*) as passengerCount FROM reservation_detail WHERE flight_date = " + date + " AND flight_number = '" + fn +"'";
					rs1 = stmt2.executeQuery(sql);
					int passengerCount = 0;
					if(rs1.next()){
						passengerCount = rs1.getInt("passengerCount");
					}
					else{
						continue;
					}
					if(passengerCount < capacity){
						ResultSet rs2 = null;
						sql = "SELECT * FROM flight WHERE departure_city = '" + aCity + "' AND arrival_city = '" + cb +"'";
						rs2 = stmt3.executeQuery(sql);
						while(rs2.next()){
							String flight_no2 = rs2.getString("flight_number");
							String aTime2 = rs2.getString("arrival_time");
							String dTime2 = rs2.getString("departure_time");
							String schedule2 = rs2.getString("weekely_schedule");
							
							int f1arrival_time = Integer.parseInt(aTime);
							int f2departure_time = Integer.parseInt(dTime2);
							if(f1arrival_time >= 100){
								if(f1arrival_time < f2departure_time - 100){}
								else{
									continue;
								}
							}
							else{
								f1arrival_time = f1arrival_time + 2400;
								if(f1arrival_time > f2departure_time - 100){}
								else{
									continue;
								}
							}
							String[] days = schedule.split("-");
							boolean sameday = false;
							int j = 0;
							if(sameday != true && j < days.length){
								if(schedule2.contains(days[j])){
									sameday = true;
								}
							}
							if(sameday == false){
								continue;
							}
							sql = "Select plane_type FROM flight WHERE flight_number = '" + fn +"'";
							rs1 = stmt2.executeQuery(sql);
							planeType = "";
							if(rs1.next()){
								planeType = rs1.getString("plane_type");
							}
							else{
								continue;
							}
							sql = "Select plane_capacity FROM plane WHERE plane_type = '" + planeType +"'";
							rs1 = stmt2.executeQuery(sql);
							int capacity2 = 0;
							if(rs1.next()){
								capacity2 = rs1.getInt("plane_capacity");
							}
							else{
								continue;
							}
							sql = "Select count(*) as passengerCount FROM reservation_detail WHERE flight_date = " + date + " AND flight_number = '" + fn +"'";
							rs1 = stmt2.executeQuery(sql);
							int passengerCount2 = 0;
							if(rs1.next()){
								passengerCount2 = rs1.getInt("passengerCount");
							}
							else{
								continue;
							}
							if(passengerCount2 < capacity2){
								System.out.println("Flight no: "+fn);
								System.out.println("Departs " + ca + " at " + dTime);
								System.out.println("Arrives at " + aCity + " at " + aTime + "");
								System.out.println("Flight no: "+flight_no2);
								System.out.println("Departs " + aCity + " at " + dTime2);
								System.out.println("Arrives at " + cb + " at " + aTime2 + "\n");
							}
							else{
								continue;
							}
						}
					}
				}
				else{
					continue;
				}
			}
		}catch(SQLException se){
				se.printStackTrace();
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	public static void stFindRoutesWithSeats(){
		System.out.println("------------------------------------------");
		System.out.println("----STRESS TEST FIND ROUTES WITH SEATS----");
		System.out.println("------------------------------------------");
		System.out.println("---PIT to DCA on 11/15/2016");
		findRoutesWithSeats("PIT","DCA","11/15/2016");
		System.out.println("---DCA to PIT on 10/15/2016");
		findRoutesWithSeats("DCA","PIT","10/15/2016");
		System.out.println("---SFA to DCA on 11/6/2016");
		findRoutesWithSeats("SFA","DCA","11/6/2016");
		System.out.println("---SFA to PIT on 11/1/2016");
		findRoutesWithSeats("SFA","PIT","11/1/2016");
		System.out.println("---PIT to DCA on 11/1/2016");
		findRoutesWithSeats("PIT","DCA","11/1/2016");
		System.out.println("---PIT to DCA on 11/14/2016");
		findRoutesWithSeats("PIT","DCA","11/14/2016");
		System.out.println("---DCA to SFA on 12/4/2016");
		findRoutesWithSeats("DCA","SFA","12/4/2016");
	}
	public static void findRoutesWithSeatsByAirline(String ca, String cb, String date, String aln){
		String sql = "";
		String aid = "";
		int i = 0;
		date = "to_date('"+date+"','mm/dd/yyyy')";
		try{
			sql = "SELECT aid FROM airline WHERE name = '" + aln+ "'";
			ResultSet rs = stmt.executeQuery(sql);
			if(rs.next()){
				aid = rs.getString("aid");
			}
			else{
				System.out.println("Airline not found. Returning to menu");
				return;
			}
			
			sql = "SELECT * FROM flight WHERE departure_city = '" + ca + "' AND arrival_city = '" + cb +"' AND airline_id = '"+aid+"'";
			rs = stmt.executeQuery(sql);
			ResultSet rs1 = null;
			System.out.println("Direct routes: \n");
			while(rs.next()){
				String fn  = rs.getString("flight_number");
				String dc  = rs.getString("departure_city");
				String dt  = rs.getString("departure_time");
				String ac  = rs.getString("arrival_city");
				String at  = rs.getString("arrival_time");
				sql = "SELECT * FROM reservation_detail WHERE flight_date = " + date + " AND flight_number = '" + fn +"'";
				rs1 = stmt2.executeQuery(sql);
				if(rs1.next()){
					sql = "Select plane_type FROM flight WHERE flight_number = '" + fn +"'";
					rs1 = stmt2.executeQuery(sql);
					String planeType = "";
					if(rs1.next()){
						planeType = rs1.getString("plane_type");
					}
					else{
						continue;
					}
					sql = "Select plane_capacity FROM plane WHERE plane_type = '" + planeType +"'";
					rs1 = stmt2.executeQuery(sql);
					int capacity = 0;
					if(rs1.next()){
						capacity = rs1.getInt("plane_capacity");
					}
					else{
						continue;
					}
					sql = "Select count(*) as passengerCount FROM reservation_detail WHERE flight_date = " + date + " AND flight_number = '" + fn +"'";
					rs1 = stmt.executeQuery(sql);
					int passengerCount = 0;
					if(rs1.next()){
						passengerCount = rs1.getInt("passengerCount");
					}
					else{
						continue;
					}
					if(passengerCount < capacity){
						System.out.println("Flight no: "+fn);
						System.out.println("Departs " + dc + " at " + dt);
						System.out.println("Arrives at " + ac + " at " + at + "\n");
					}
					else{
						continue;
					}
				}
				else{
					continue;
				}
				
			}
			
			System.out.println("Non-direct routes:\n");
		
			sql = "SELECT * FROM flight WHERE departure_city = '" + ca + "' AND arrival_city != '" + cb +"'";
			rs = stmt.executeQuery(sql);
			while(rs.next()){
				String fn  = rs.getString("flight_number");
				String aCity = rs.getString("arrival_city");
				String dTime = rs.getString("departure_time");
				String aTime = rs.getString("arrival_time");
				String schedule = rs.getString("weekely_schedule");
				sql = "SELECT * FROM reservation_detail WHERE flight_date = " + date + " AND flight_number = '" + fn +"'";
				rs1 = stmt2.executeQuery(sql);
				if(rs1.next()){
					sql = "Select plane_type FROM flight WHERE flight_number = '" + fn +"'";
					rs1 = stmt2.executeQuery(sql);
					String planeType = "";
					if(rs1.next()){
						planeType = rs1.getString("plane_type");
					}
					else{
						continue;
					}
					sql = "Select plane_capacity FROM plane WHERE plane_type = '" + planeType +"'";
					rs1 = stmt2.executeQuery(sql);
					int capacity = 0;
					if(rs1.next()){
						capacity = rs1.getInt("plane_capacity");
					}
					else{
						continue;
					}
					sql = "Select count(*) as passengerCount FROM reservation_detail WHERE flight_date = " + date + " AND flight_number = '" + fn +"'";
					rs1 = stmt2.executeQuery(sql);
					int passengerCount = 0;
					if(rs1.next()){
						passengerCount = rs1.getInt("passengerCount");
					}
					else{
						continue;
					}
					if(passengerCount < capacity){
						ResultSet rs2 = null;
						sql = "SELECT * FROM flight WHERE departure_city = '" + aCity + "' AND arrival_city = '" + cb +"' AND airline_id = '"+aid+"'";
						rs2 = stmt3.executeQuery(sql);
						while(rs2.next()){
							String flight_no2 = rs2.getString("flight_number");
							String aTime2 = rs2.getString("arrival_time");
							String dTime2 = rs2.getString("departure_time");
							String schedule2 = rs2.getString("weekely_schedule");
							
							int f1arrival_time = Integer.parseInt(aTime);
							int f2departure_time = Integer.parseInt(dTime2);
							if(f1arrival_time >= 100){
								if(f1arrival_time < f2departure_time - 100){}
								else{
									continue;
								}
							}
							else{
								f1arrival_time = f1arrival_time + 2400;
								if(f1arrival_time > f2departure_time - 100){}
								else{
									continue;
								}
							}
							String[] days = schedule.split("-");
							boolean sameday = false;
							int j = 0;
							if(sameday != true && j < days.length){
								if(schedule2.contains(days[j])){
									sameday = true;
								}
							}
							if(sameday == false){
								continue;
							}
							sql = "Select plane_type FROM flight WHERE flight_number = '" + fn +"'";
							rs1 = stmt2.executeQuery(sql);
							planeType = "";
							if(rs1.next()){
								planeType = rs1.getString("plane_type");
							}
							else{
								continue;
							}
							sql = "Select plane_capacity FROM plane WHERE plane_type = '" + planeType +"'";
							rs1 = stmt2.executeQuery(sql);
							int capacity2 = 0;
							if(rs1.next()){
								capacity2 = rs1.getInt("plane_capacity");
							}
							else{
								continue;
							}
							sql = "Select count(*) as passengerCount FROM reservation_detail WHERE flight_date = " + date + " AND flight_number = '" + fn +"'";
							rs1 = stmt2.executeQuery(sql);
							int passengerCount2 = 0;
							if(rs1.next()){
								passengerCount2 = rs1.getInt("passengerCount");
							}
							else{
								continue;
							}
							if(passengerCount2 < capacity2){
								System.out.println("Flight no: "+fn);
								System.out.println("Departs " + ca + " at " + dTime);
								System.out.println("Arrives at " + aCity + " at " + aTime + "");
								System.out.println("Flight no: "+flight_no2);
								System.out.println("Departs " + aCity + " at " + dTime2);
								System.out.println("Arrives at " + cb + " at " + aTime2 + "\n");
							}
							else{
								continue;
							}
						}
					}
				}
				else{
					continue;
				}
			}
		}catch(SQLException se){
				se.printStackTrace();
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	public static void stFindRoutesWithSeatsByAirline(){
		System.out.println("-----------------------------------------------------");
		System.out.println("----STRESS TEST FIND ROUTES WITH SEATS BY AIRLINE----");
		System.out.println("-----------------------------------------------------");
		System.out.println("---PIT to DCA on 11/15/2016 on airline United Airlines");
		findRoutesWithSeats("PIT","DCA","11/15/2016","United Airlines");
		System.out.println("---DCA to PIT on 10/15/2016 on airline Lufthansa");
		findRoutesWithSeats("DCA","PIT","10/15/2016","Lufthansa");
		System.out.println("---SFA to DCA on 11/6/2016 on airline United Airlines");
		findRoutesWithSeats("SFA","DCA","11/6/2016","United Airlines");
		System.out.println("---SFA to PIT on 11/1/2016 on airline British Airways");
		findRoutesWithSeats("SFA","PIT","11/1/2016","British Airways");
		System.out.println("---PIT to DCA on 11/1/2016 on airline United Airlines");
		findRoutesWithSeats("PIT","DCA","11/1/2016","United Airlines");
		System.out.println("---PIT to DCA on 11/14/2016 on airline United Airlines");
		findRoutesWithSeats("PIT","DCA","11/14/2016","United Airlines");
		System.out.println("---DCA to SFA on 12/4/2016 on airline United Airlines"");
		findRoutesWithSeats("DCA","SFA","12/4/2016","United Airlines");
	}
	
	public static void showReservationInfo(String r_no){
		String sql;
		try{
			sql = "SELECT * FROM reservation_detail WHERE  reservation_number = '" +r_no +"'";
			ResultSet rs = stmt.executeQuery(sql);
			boolean found = false;
			while(rs.next()){
				String flight_no = rs.getString("flight_number");
				String date = rs.getString("flight_date");
				int leg = rs.getInt("leg");
				System.out.println("leg: "+leg+" flight number: "+flight_no+ " date: " + date+"");
				
				found = true;
			}
			if(found == false){
				System.out.println("Reservation not found");
			}
			rs.close();
		}catch(SQLException se){
			se.printStackTrace();
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	public static void stShowReservationInfo(){
		System.out.println("-----------------------------------------");
		System.out.println("----STRESS TEST SHOW RESERVATION INFO----");
		System.out.println("-----------------------------------------");
		for(int i = 50; i < 100; i++){
			String input = String.valueOf(i);
			showReservationInfo(input);
		}
		for(int i = 300; i < 320; i++){
			String input = String.valueOf(i);
			showReservationInfo(input);
		}
		System.out.println("None existant reservations will not be found:");
		showReservationInfo("0");
		showReservationInfo("-1");
		showReservationInfo("9999");
	}
	public static void buyTicket(String r_no){
		String sql;
		try{
			sql = "SELECT ticketed FROM reservation WHERE reservation_number = '" +r_no+ "'";
			ResultSet rs = stmt.executeQuery(sql);
			if(rs.next()){
				int ticketed = rs.getInt("ticketed");
				if(ticketed == 0){
					sql = "UPDATE reservation SET ticketed = 1 WHERE reservation_number = '" +r_no+ "'";
					int succcess = stmt.executeUpdate(sql);
				}
				else{
					System.out.println("Ticket already issued");
				}
			}
			else{
				System.out.println("Invalid reservation number");
			}
			rs.close();
		}catch(SQLException se){
			se.printStackTrace();
		}catch(Exception e){
			e.printStackTrace();
		}
	}
	public static void stBuyTicket(){
		System.out.println("------------------------------");
		System.out.println("----STRESS TEST BUY TICKET----");
		System.out.println("------------------------------");
		for(int i = 50; i < 100; i++){
			String input = String.valueOf(i);
			showReservationInfo(input);
		}
		System.out.println("Reservations that have already been ticketed:");
		for(int i = 300; i < 310; i++){
			String input = String.valueOf(i);
			showReservationInfo(input);
		}
		System.out.println("None existant reservations will not be found:");
		showReservationInfo("0");
		showReservationInfo("-1");
		showReservationInfo("9999");
	}
}
