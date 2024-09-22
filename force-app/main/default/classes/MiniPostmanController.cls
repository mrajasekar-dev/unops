public with sharing class MiniPostmanController {

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
        // Generate a dynamic class name in PascalCase and ending with _API
        String className = createClassNameFromUrl(endpoint); // Generate dynamic class name
        String classContent = '';
        String metaContent = '';
        String anonymousCode = '';

        // Generate dynamic Request class based on user-provided JSON
        classContent += 'public with sharing class ' + className + ' {\n';

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
        
        // Add callout logic
        classContent += '        HttpRequest req = new HttpRequest();\n';
        classContent += '        req.setEndpoint(\'' + endpoint + '\');\n';
        classContent += '        req.setMethod(\'' + method + '\');\n';

        // Set headers
        if (String.isNotBlank(headers)) {
            classContent += '        req.setHeader(\'Content-Type\', header.Content_Type);\n';
            classContent += '        req.setHeader(\'API-Subscription-Key\', header.API_Subscription_Key);\n';
        }

        // Set body for non-GET methods
        if (method != 'GET') {
            classContent += '        req.setBody(requestBody);\n';
        }

        classContent += '        Http http = new Http();\n';
        classContent += '        HttpResponse res = http.send(req);\n';
        classContent += '        System.debug(\'Response: \' + res.getBody());\n';
        classContent += '    }\n';

        classContent += '}\n';

        // Meta XML content for deployment
        metaContent += '<?xml version="1.0" encoding="UTF-8"?>\n';
        metaContent += '<ApexClass xmlns="http://soap.sforce.com/2006/04/metadata">\n';
        metaContent += '    <apiVersion>57.0</apiVersion>\n';
        metaContent += '    <status>Active</status>\n';
        metaContent += '</ApexClass>\n';

        // Generate anonymous code (no class definitions, only execution)
        anonymousCode += 'System.debug(\'Executing Anonymous Code for ' + className + '\');\n';
        anonymousCode += className + '.makeCallout();\n';
        anonymousCode += 'System.debug(\'Execution Finished for ' + className + '\');\n';

        // Return class content, meta content, and anonymous code
        Map<String, String> result = new Map<String, String>();
        result.put('classContent', classContent);
        result.put('metaContent', metaContent);
        result.put('anonymousCode', anonymousCode); // Add the anonymous code here
        result.put('className', className);  // Return the className so the LWC can use the same name
        return result;
    }

    // Helper method to create a class name from the URL (Pascal Case and ending with _API)
    private static String createClassNameFromUrl(String endpoint) {
        String domain = endpoint.replaceAll('https?://', '').split('/')[0]; // Get domain part of the URL
        domain = domain.replace('.', ' '); // Replace dots with spaces for PascalCase conversion
        String[] words = domain.split(' ');
        String pascalCaseName = '';

        // Manually convert each word to Pascal Case
        for (String word : words) {
            if (word.length() > 0) {
                pascalCaseName += word.substring(0, 1).toUpperCase() + word.substring(1).toLowerCase();
            }
        }

        return pascalCaseName + '_API'; // Append _API to the PascalCase name
    }

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
            return 'List<Object>';
        } else if (value instanceof Map<String, Object>) {
            return 'Map<String, Object>';
        } else {
            return 'Object';
        }
    }
}
