public class CustomFieldTracker {
    
    public List<CustomField> getRecentCustomFields() {
        DateTime thirtyDaysAgo = DateTime.now().addDays(-30);
        String query = 'SELECT Id, DeveloperName, EntityDefinition.DeveloperName, CreatedBy.Name, LastModifiedBy.Name ' +
                       'FROM CustomField ' +
                       'WHERE (LastModifiedDate >= ' + thirtyDaysAgo.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ' OR CreatedDate >= ' + thirtyDaysAgo.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'') + ') ' +
                       'AND ManageableState = \'unmanaged\'';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Url.getOrgDomainUrl().toExternalForm() + '/services/data/v59.0/tooling/query?q=' + EncodingUtil.urlEncode(query, 'UTF-8'));
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        req.setHeader('Content-Type', 'application/json');
        
        Http http = new Http();
        HttpResponse res;
        
        try {
            res = http.send(req);
            
            system.debug('RESULT: '+res.getBody());
            Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        	List<Object> records1 = (List<Object>) jsonData.get('records');
        
        	for (Object record : records1) {
            	Map<String, Object> fieldData = (Map<String, Object>) record;
            	String developerName = (String) fieldData.get('DeveloperName');
            
            	Map<String, Object> entityDefinition = (Map<String, Object>) fieldData.get('EntityDefinition');
            	String entityDeveloperName = (String) entityDefinition.get('DeveloperName');
            
            	System.debug('Custom Field: ' + developerName + ', Object: ' + entityDeveloperName);
        	}
            
            if (res.getStatusCode() == 200) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                List<Object> records = (List<Object>) result.get('records');
                
                List<CustomField> customFields = new List<CustomField>();
                for (Object record : records) {
                    Map<String, Object> fieldData = (Map<String, Object>) record;
                    CustomField cf = new CustomField();
                    cf.id = (String) fieldData.get('Id');
                    cf.name = (String) fieldData.get('DeveloperName');
                    cf.obj = (String) fieldData.get('TableEnumOrId');
                    cf.createdDate = DateTime.valueOf((String) fieldData.get('CreatedDate'));
                    cf.lastModifiedDate = DateTime.valueOf((String) fieldData.get('LastModifiedDate'));
                    cf.createdById = (String) fieldData.get('CreatedById');
                    cf.lastModifiedById = (String) fieldData.get('LastModifiedById');
                    customFields.add(cf);
                }
                
                return customFields;
            } else {
                System.debug('Error: ' + res.getStatusCode() + ' ' + res.getStatus());
                System.debug('Response body: ' + res.getBody());
                return new List<CustomField>();
            }
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            return new List<CustomField>();
        }
    }
    
    public class CustomField {
        public String id;
        public String name;
        public String obj;
        public DateTime createdDate;
        public DateTime lastModifiedDate;
        public String createdById;
        public String lastModifiedById;
    }
}