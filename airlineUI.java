import java.util.*;
import java.io.*;

public class airlineUI{
	public static void main(String args[]){
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
				System.exit(0);
			}
			else{
				System.out.println("Invalid input\n");
			}
		}
	}
}