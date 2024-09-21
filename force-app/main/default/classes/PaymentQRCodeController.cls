public class PaymentQRCodeController {
    @AuraEnabled(cacheable=true)
    public static String generateQRCode(Id paymentId) {
        Payment__c payment = [SELECT Id, Branch__c, Amount__c, Payment_Date__c, Name FROM Payment__c WHERE Id = :paymentId LIMIT 1];

        String qrData = 'Hello World!';

        // Create the data string for the QR code
        String encodedQrData = EncodingUtil.urlEncode(qrData, 'UTF-8');

        // Use an external service to generate the QR code
        String qrCodeUrl = 'https://quickchart.io/qr?text=' + encodedQrData + '&size=300';
        
        return qrCodeUrl;
    }
}