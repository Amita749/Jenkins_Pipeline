@isTest
public with sharing class MathTest {
     @IsTest
    static void testAddNumbers() {
        Integer result = Math.addNumbers(5, 10);
        System.assertEquals(15, result, '5 + 10 should equal 15');
}
     @IsTest
    static void testAddNum() {
        Integer result = Math.addNum(5, 10,2);
        System.assertEquals(17, result, '5 + 10+2 should equal 17');
}
     @IsTest
    static void testaddFour() {
        Integer result = Math.addFour(5, 10, 2, 5);
        System.assertEquals(22, result, '5 + 10+2+5 should equal 22');
}

}