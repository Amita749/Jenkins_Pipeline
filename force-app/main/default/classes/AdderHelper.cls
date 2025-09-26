public with sharing class AdderHelper {
    public AdderHelper() {
  System.debug('new class');
        System.debug('new line added');
    }
     // Method to add two numbers
    public static Integer addNumbers(Integer a, Integer b) {
        return a + b;
    }
}