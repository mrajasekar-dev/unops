public with sharing class MiniPostmanController {

    // Ensure this method is annotated with @AuraEnabled
    @AuraEnabled
    public static String makeCallout(String endpoint, String method, String headers, String requestBody) {
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setEndpoint(endpoint);
        req.setMethod(method);
        
        // Handle Headers
        if (String.isNotBlank(headers)) {
            try {
                Map<String, Object> headersMap = (Map<String, Object>) JSON.deserializeUntyped(headers);
                for (String key : headersMap.keySet()) {
                    req.setHeader(key, String.valueOf(headersMap.get(key)));
                }
            } catch (Exception e) {
                throw new AuraHandledException('Invalid headers JSON: ' + e.getMessage());
            }
        }
        
        // Handle Request Body
        if (method != 'GET' && String.isNotBlank(requestBody)) {
            try {
                req.setBody(requestBody);
            } catch (Exception e) {
                throw new AuraHandledException('Invalid request body JSON: ' + e.getMessage());
            }
        }
        
        HttpResponse res;
        try {
            res = http.send(req);
            return res.getBody();
        } catch (Exception e) {
            throw new AuraHandledException('Error making callout: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, String> generateApexClass(String endpoint, String method, String headers, String requestBody) {
        String classContent = '';
        String metaContent = '';

        // Generate dynamic Request class based on user-provided JSON
        classContent += 'public with sharing class GeneratedApexClass {\n';

        // Generate Header Class
        if (String.isNotBlank(headers)) {
            classContent += '    public class Header {\n';
            classContent += generateClassFromJSON(headers);
            classContent += '    }\n\n';
        }

        // Generate Request Class
        if (String.isNotBlank(requestBody)) {
            classContent += '    public class Request {\n';
            classContent += generateClassFromJSON(requestBody);
            classContent += '    }\n\n';
        }

        // Static Method to make callout
        classContent += '    public static void makeCallout() {\n';
        
        // Instantiate and set values for Header
        if (String.isNotBlank(headers)) {
            classContent += '        Header header = new Header();\n';
            classContent += generateAssignStatementsFromJSON('header', headers);
        }
        
        // Instantiate and set values for Request
        if (String.isNotBlank(requestBody)) {
            classContent += '        Request reqObj = new Request();\n';
            classContent += generateAssignStatementsFromJSON('reqObj', requestBody);
        }

        // Serialize the request body
        classContent += '        String requestBody = JSON.serialize(reqObj);\n';
        classContent += '        System.debug(\'Serialized Request: \' + requestBody);\n';
        classContent += '        // Add callout logic here\n';
        classContent += '    }\n';

        classContent += '}\n';

        // Meta XML content
        metaContent += '<?xml version="1.0" encoding="UTF-8"?>\n';
        metaContent += '<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">\n';
        metaContent += '    <apiVersion>57.0</apiVersion>\n';
        metaContent += '    <status>Active</status>\n';
        metaContent += '</ApexClass>\n';

        // Return both class content and meta content
        Map<String, String> result = new Map<String, String>();
        result.put('classContent', classContent);
        result.put('metaContent', metaContent);
        return result;
    }

    // Helper method to dynamically generate Apex class fields from JSON structure
    private static String generateClassFromJSON(String jsonString) {
        String classFields = '';
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        
        for (String key : jsonMap.keySet()) {
            Object value = jsonMap.get(key);
            String fieldType = determineFieldType(value);
            classFields += '        public ' + fieldType + ' ' + key + ';\n';
        }

        return classFields;
    }

    // Helper method to generate Apex statements for assigning values to class fields
    private static String generateAssignStatementsFromJSON(String objectName, String jsonString) {
        String assignmentStatements = '';
        Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);

        for (String key : jsonMap.keySet()) {
            Object value = jsonMap.get(key);
            String fieldType = determineFieldType(value);

            if (value instanceof String) {
                assignmentStatements += '        ' + objectName + '.' + key + ' = \'' + String.valueOf(value).replace('\'', '\\\'') + '\';\n';
            } else {
                assignmentStatements += '        ' + objectName + '.' + key + ' = ' + String.valueOf(value) + ';\n';
            }
        }

        return assignmentStatements;
    }

    // Helper method to determine the Apex field type based on the value type
    private static String determineFieldType(Object value) {
        if (value instanceof String) {
            return 'String';
        } else if (value instanceof Integer) {
            return 'Integer';
        } else if (value instanceof Double) {
            return 'Decimal';
        } else if (value instanceof Boolean) {
            return 'Boolean';
        } else if (value instanceof List<Object>) {
            return 'List<Object>'; // You can improve this by checking the type of the elements in the list
        } else if (value instanceof Map<String, Object>) {
            return 'Map<String, Object>';
        } else {
            return 'Object';
        }
    }
}