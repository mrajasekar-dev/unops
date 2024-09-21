public with sharing class GeneratedApexClass {
    public static void makeCallout() {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.sarvam.ai/translate');
        req.setMethod('POST');
        // Headers
        req.setHeader('Content-Type', 'application/json');
        req.setBody('{ "input": "I slapped someone", "source_language_code": "en-IN", "target_language_code": "ta-IN", "speaker_gender": "Male", "mode": "formal", "model": "mayura:v1", "enable_preprocessing": true}');
        try {
            HttpResponse res = http.send(req);
            System.debug('Response: ' + res.getBody());
        } catch (Exception e) {
            System.debug('Callout failed: ' + e.getMessage());
        }
    }
}