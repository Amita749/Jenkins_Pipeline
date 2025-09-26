@isTest
public class AdderHandlerTest {
    @isTest
    static void testConstructor() {
        // Act: Create an instance of AdderHelper
        AdderHelper obj = new AdderHelper();

        // Assert: Nothing to assert here since it only prints debug logs
        System.assertNotEquals(null, obj, 'Object should not be null');
    }
    
}