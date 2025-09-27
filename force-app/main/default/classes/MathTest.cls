@isTest
public with sharing class MathTest {
     @IsTest
    static void testAddNumbers() {
        Integer result = Math.addNumbers(5, 10);
        System.assertEquals(15, result, '5 + 10 should equal 15');
}

}