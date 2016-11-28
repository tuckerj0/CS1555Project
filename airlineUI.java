import java.util.*;
import java.io.*;
import java.sql.*;
import oracle.jdbc.driver.*;

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
			System.out.println("7. Quit");
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
			System.out.println("11. Exit");
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
}