public class Adder {

    // Method to add two numbers
    public static Integer addNumbers(Integer a, Integer b) {
        return a + b;
    }
    // Method to subtract two numbers
    public static Integer subtractNumbers(Integer a, Integer b) {
        return a - b;
    }
    // QA: changed multiply logic to include debug log
    public static Integer multiplyNumbers(Integer a, Integer b) {
        System.debug('Multiplying numbers in QA branch');
        return a * b;
    }
  
 // Method to two divide two numbers
    public static Integer divnum(Integer a, Integer b){
        return a/b;
    }
}