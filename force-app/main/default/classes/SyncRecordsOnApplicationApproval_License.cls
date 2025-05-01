public class SyncRecordsOnApplicationApproval_License {
    
    public static Set<String> childObjectsList = new Set<String>();
    
    public static void handleDataSyncOnApproval(String parentObjectName , String applicationType , String flowType){
        Set<Id> recordIds = new Set<Id>{'0f0cn000000OyavAAC'};
            String filedApiNameIdentifier = 'Sync_Object_';
        // Map<String,String> objectToRelationShipFieldMap = new  Map<String,String>();
        Set<Id> objectMappindMetadataRecId = new Set<Id>();
        Map<String,String> objectToRelationShipFieldMap = objectToRelationShipFieldMap;
        Map<String,Map<Boolean,Set<String>>> objectNameToFieldsToQueryMap = new Map<String,Map<Boolean,Set<String>>>();// Map of Source Object name and if that is the parent object or not to the list of the fields that needs to be queried for the Source Object
        Map<Id,Approval_Amend_Renwal_App_Data_Sync__mdt> objectToMapOnApproval = new Map<Id,Approval_Amend_Renwal_App_Data_Sync__mdt>();// Map of selected records Sync Object metatdata record Id and the Metadata recordMap
        List<Approval_Amend_Renwal_App_Data_Sync__mdt > getApprovalSyncMapping = [SELECT Id,DeveloperName,Facility_Application_Type__c,Flow_Type__c,Parent_Object__c,Sync_Object__r.CC_Source_Object__c,Child_Relationship_Field_Name_1__c,Application_Specification_to_Consider__c, 
                                                                                  Sync_Object_2__r.CC_Source_Object__c,Child_Relationship_Field_Name_2__c,Sync_Object_3__r.CC_Source_Object__c,Child_Relationship_Field_Name_3__c From Approval_Amend_Renwal_App_Data_Sync__mdt where Flow_Type__c =: flowType AND Facility_Application_Type__c =: applicationType AND Parent_Object__c =: parentObjectName ];
        
        
        for(Approval_Amend_Renwal_App_Data_Sync__mdt selectedRec : getApprovalSyncMapping){
            
            Map<String,Object> fieldValue = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(selectedRec));// Map if field name and value set eg. {'Sycn_object__c':'ID of CC_DataSyncObjectMapping__mdt'}
            system.debug('fieldValue :: ' + fieldValue);
            for(String fieldName : fieldValue.keySet()){
                if(fieldName.startsWith(filedApiNameIdentifier) && !(fieldName.endsWith('__r') || fieldName.endsWith('__R') )){
                    // objectMappindMetadataRecId.add((ID)fieldValue.get(fieldName));
                    objectToMapOnApproval.put((ID)fieldValue.get(fieldName),selectedRec);
                }
            }
        }		
        system.debug('objectToMapOnApproval :: ' + objectToMapOnApproval);
        
        if(objectToMapOnApproval.keySet() != null) {
            List<CC_DataSyncObjectMapping__mdt> getDataSyncMapping =  [Select id ,CC_Relationship_Api_Name__c,CC_Sync_Identifier__c,CC_Source_Object__c,CC_Target_Object__c,Relationship_Field_in_Apex__c, (select id,CC_Source_Field__c,CC_Target_Field__c,CC_Is_Static_Value__c,CC_Field_Type__c From CC_DataSyncFieldMapping__r where CC_Is_Active__c = true ) 
                                                                       From CC_DataSyncObjectMapping__mdt WHERE Id IN:objectToMapOnApproval.keySet() And CC_Is_Active__c = true With User_Mode Limit 500];
            
            
            for(CC_DataSyncObjectMapping__mdt selectedRec : getDataSyncMapping){
                Boolean isParent = false;
                Map<Boolean,Set<String>> isparentToListOfFieldsMap = new  Map<Boolean,Set<String>>();
                Set<String> fieldNames = new Set<String>(); //List of the Source filed on the source Object
                if(selectedRec.CC_Source_Object__c  == parentObjectName)
                    isParent = true;
                
                if(selectedRec.CC_Relationship_Api_Name__c != null){
                    fieldNames.add(selectedRec.CC_Relationship_Api_Name__c);                 
                }
                system.debug('objectToRelationShipFieldMap :: ' + objectToRelationShipFieldMap);
                system.debug('Source Object :: ' + selectedRec.CC_Source_Object__c + '  ' + objectToRelationShipFieldMap.containsKey(selectedRec.CC_Source_Object__c));
                if(selectedRec.Relationship_Field_in_Apex__c == true && objectToRelationShipFieldMap.containsKey(selectedRec.CC_Source_Object__c) && selectedRec.CC_Relationship_Api_Name__c == null){
                    system.debug('fieldNames :: ' + objectToRelationShipFieldMap.get(selectedRec.CC_Source_Object__c).split(','));
                    fieldNames.addAll( new Set<String>(objectToRelationShipFieldMap.get(selectedRec.CC_Source_Object__c).split(',')));                 
                }
                
                for(CC_DataSyncFieldMapping__mdt fieldMapping : selectedRec.CC_DataSyncFieldMapping__r){
                    fieldNames.add(fieldMapping.CC_Source_Field__c);
                }
                isparentToListOfFieldsMap.put(isParent,fieldNames);
                objectNameToFieldsToQueryMap.put(selectedRec.CC_Source_Object__c,isparentToListOfFieldsMap);
            }
            system.debug('objectNameToFieldsToQueryMap :: ' +  objectNameToFieldsToQueryMap);
            
            String dynamicQuery = buildDynamicQuery(parentObjectName,objectNameToFieldsToQueryMap);
            List<Sobject> recordQueriedData = fetchSourceRecords(dynamicQuery,recordIds);
            system.debug('recordQueried ::' + recordQueriedData);
            dataToLoad(recordQueriedData,getDataSyncMapping,parentObjectName);
        }
        
    } 
    
    public static void dataToLoad(List<Sobject> recordQueriedData, List<CC_DataSyncObjectMapping__mdt> getDataSyncMapping, String parentObjectName){
         Boolean isParent = false; //variable to track in the deserialized data if its a parent based on the attribute type
        
        String serializedData = JSON.serialize(recordQueriedData);
        
        List<Object> rawRecordsData = (List<Object>) JSON.deserializeUntyped(serializedData);
        
        List<SObject> parentRecords = new List<SObject>();
        Map<String, List<SObject>> childRecordsMap = new Map<String, List<SObject>>();
        
        for (Object rawRecord : rawRecordsData) {
            system.debug('rawRecord :: ' + rawRecord);
             Map<String, Object> recordData = (Map<String, Object>) rawRecord;
            system.debug('recordData :: ' + recordData);
            String objectName = (String) ((Map<String, Object>) recordData.get('attributes')).get('type');
            system.debug('objectName :: ' + objectName);
            
            system.debug('childObjectsList :: ' + childObjectsList);
            // Convert Parent Record
            if(parentObjectName == objectName){
                isParent = true;
            }
                 SObject parentRecord = convertMapToSObject(recordData, objectName,isParent,childObjectsList);
                 system.debug('parentRecord :: ' + parentRecord);
            
           
        }
        
    }
    
    // Helper Method to Convert Map to SObject
    public static SObject convertMapToSObject(Map<String, Object> recordData, String objectName , Boolean isParent, Set<String> childObjectsList) {
        if (String.isEmpty(objectName)) return null;
        
        SObject newRecord = Schema.getGlobalDescribe().get(objectName).newSObject();
        
        for (String fieldName : recordData.keySet()) {
            if (!fieldName.equals('attributes')) { // Skip metadata fields
                try {
                    if(isParent && !childObjectsList.contains(fieldName)){
                          newRecord.put(fieldName, recordData.get(fieldName));
                    }else{
                       // newRecord.put(fieldName, recordData.get(fieldName));
                    }
                    
                } catch (Exception e) {
                    System.debug('Error setting field: ' + fieldName + ' Error: ' + e.getMessage());
                }
            }
        }
        return newRecord;
    }
    
    private static List<SObject> fetchSourceRecords(String query , Set<Id>recordIds){
        query +=  ' WHERE Id IN :recordIds';
        return Database.query(query,AccessLevel.SYSTEM_MODE); 
    }
    
    
    
    
    public static void getAllRecorsToSync(String recordId) {
        if(recordId!= null && !String.isBlank(recordId)){
            String objectName = String.valueOf(Id.valueOf(recordId).getSObjectType());
            // String query = buildDynamicQuery(accountId, childObjectFieldSets);
        }
        /* CC_DataSyncEvent__e d= new CC_DataSyncEvent__e();
d.CC_Source_Record_Id__c= '001cn00000Atn5eAAB';
d.CC_Target_Record_Id__c= '0f0cn000000OlLxAAK';
d.CC_Source_Object__c='BusinessLicenseApplication';
d.CC_Target_Object__c='Account';
EventBus.publish(d);*/
    }
    
    // Method to fetch Parent and its related records dynamically
    // Param :  Map<String,Map<Boolean,List<String>>> // Map of the Source Object and If that source Object is Parent Or not i.e if the source object is BLA for the BLA application then true
    //          and if the source Object is PAP for the BLA application then isParent is false and list of all the fields of the source object
    public static String buildDynamicQuery(String parentObjectName, Map<String,Map<Boolean,Set<String>>> objectNameToFieldsToQueryMap) {
        
        String query = 'SELECT ID,';
        
        for(String sourceObjectName : objectNameToFieldsToQueryMap.keySet()){
            Map<Boolean,Set<String>> isparentToListOfFieldsMap = new  Map<Boolean,Set<String>>();
            isparentToListOfFieldsMap = objectNameToFieldsToQueryMap.get(sourceObjectName);
            if(isparentToListOfFieldsMap.containsKey(true)){
                query = removeCommaFromSting(query);
                String accountFieldQuery = (isparentToListOfFieldsMap.get(true).isEmpty()) ? ' ' : ', ' + String.join(isparentToListOfFieldsMap.get(true), ',');
                query += accountFieldQuery ;
            }else if (isparentToListOfFieldsMap.containsKey(false)){
                query = removeCommaFromSting(query);
                String childObjectName = getChildRelationshipName(parentObjectName,sourceObjectName);
                childObjectsList.add(childObjectName);
                String accountFieldQuery = (isparentToListOfFieldsMap.get(false).isEmpty()) ? 'ID' : 'ID, ' + String.join(isparentToListOfFieldsMap.get(false), ',');
                query += ', (SELECT ' + accountFieldQuery + ' FROM ' + childObjectName + '),';
            }
        }
        
        if(query.endsWith(',')){
            query = removeCommaFromSting(query) ;
        }
        query += ' FROM ' + parentObjectName ;
        //String.join(accountFields, ','
        // String accountFieldQuery = (accountFields.isEmpty()) ? 'Id' : String.join(accountFields, ',');
        system.debug('query :: ' + query);
        // system.debug('query data :: ' + Database.query(query,AccessLevel.SYSTEM_MODE));
        //Database.query(query,AccessLevel.SYSTEM_MODE);
        return query;
    }
    
    
    public static String removeCommaFromSting(String stringWithComma){
        
        if(stringWithComma.endsWith(',')){
            stringWithComma = stringWithComma.substring(0,stringWithComma.length() - 1);
            return stringWithComma;
        }
        return stringWithComma;
    }
    
    
    // Helper to get the child relationship name dynamically
    public static String getChildRelationshipName(String objectName, String childObjectName) {
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        if (schemaMap.containsKey(childObjectName)) {
            List<Schema.ChildRelationship> relationships = Schema.getGlobalDescribe().get(objectName).getDescribe().getChildRelationships();
            for (Schema.ChildRelationship rel : relationships) {
                if (String.valueOf(rel.getChildSObject()) == childObjectName) {
                    return rel.getRelationshipName();
                }
            }
        }
        return null;
    }
    
    //Creating Map to store reaaltion between Source Object to Target Object if the Dependency is on more than one object
    public static Map<String,String> objectToRelationShipFieldMap
    {
        get
        {
            if (objectToRelationShipFieldMap == null)
            {
                objectToRelationShipFieldMap = new map<String,string>();
                objectToRelationShipFieldMap.put('CC_Application_Specification__c','CC_Public_Application_Participant__c,Person_Account_Id__c,CC_BusinessLicenseApplication__c,CC_Individual_Application__c');
            }
            return objectToRelationShipFieldMap;
        }
        set;
    }
        
}