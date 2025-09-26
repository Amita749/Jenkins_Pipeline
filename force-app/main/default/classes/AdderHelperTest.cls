@isTest
public with sharing class AdderHelperTest {

    @IsTest
    static void testAddNumbers() {
        Integer result = AdderHelper.addNumbers(5, 10);
        System.assertEquals(15, result, '5 + 10 should equal 15');
}
}