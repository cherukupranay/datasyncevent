public class SyncRecordsOnApplicationApproval_Copy {
    
    public static void handleDataSyncOnApproval(String parentObjectName , String applicationType , String flowType){
        Set<Id> recordIds = new Set<Id>{'0f0cn000000SZfZAAW'};
            Set<Id> dataSyncRecordsIdForMapping = new Set<Id>();
        String filedApiNameIdentifier = 'Sync_Object_';
        Map<String, Map<String, String>> sourceToSource_Target_fieldsMap = new Map<String, Map<String, String>>();//map of <Source Object> , <Source Field, Target Filed> , Eg :  {BusinessLicenseApplication={CC_Date_of_Inspection_Fire_Marshal__c=CC_Date_of_Inspection_Fire_Marshal__c, CC_Date_of_Inspection_Health_Cert__c=CC_Date_of_Inspection_Health_Cert__c, CC_Date_of_Measurement__c=CC_Date_of_Measurement__c}}
        Map<String, CC_DataSyncObjectMapping__mdt> sourceObjToMetadataRecMap = new Map<String, CC_DataSyncObjectMapping__mdt>(); //map of <Source Object> , metadata record
        Map<String,String> sourceObjectToSourceChildRelationshipName = new  Map<String,String>(); // map od source to source child relationship name eg. : {PublicApplicationParticipant  = Applications }
        List<Approval_Amend_Renwal_App_Data_Sync__mdt > getApprovalSyncMapping = [SELECT Id,DeveloperName,Facility_Application_Type__c,Flow_Type__c,Parent_Object__c,Sync_Object__r.CC_Source_Object__c,Child_Relationship_Field_Name_1__c,Application_Specification_to_Consider__c, 
                                                                                  Sync_Object_2__r.CC_Source_Object__c,Child_Relationship_Field_Name_2__c,Sync_Object_3__r.CC_Source_Object__c,Child_Relationship_Field_Name_3__c From Approval_Amend_Renwal_App_Data_Sync__mdt where Flow_Type__c =: flowType AND Facility_Application_Type__c =: applicationType AND Parent_Object__c =: parentObjectName ];
        
        for(Approval_Amend_Renwal_App_Data_Sync__mdt selectedRec : getApprovalSyncMapping){
            Map<String,Object> fieldValue = (Map<String,Object>) JSON.deserializeUntyped(JSON.serialize(selectedRec));// Map if field name and value set eg. {'Sycn_object__c':'ID of CC_DataSyncObjectMapping__mdt'}
            for(String fieldName : fieldValue.keySet()){
                if(fieldName.startsWith(filedApiNameIdentifier) && !(fieldName.endsWith('__r') || fieldName.endsWith('__R') ) ){
                    dataSyncRecordsIdForMapping.add(((ID)fieldValue.get(fieldName)));
                }
            }
        }
        
        //creating map of <Source Object> , <Source Field, Target Filed> , Eg :  {BusinessLicenseApplication={CC_Date_of_Inspection_Fire_Marshal__c=CC_Date_of_Inspection_Fire_Marshal__c, CC_Date_of_Inspection_Health_Cert__c=CC_Date_of_Inspection_Health_Cert__c, CC_Date_of_Measurement__c=CC_Date_of_Measurement__c}}
        if(!dataSyncRecordsIdForMapping.isEmpty()) {
            List<CC_DataSyncObjectMapping__mdt> getDataSyncMapping = getObjectFieldMappings(dataSyncRecordsIdForMapping);
            
            for (CC_DataSyncObjectMapping__mdt mappingRecord :getDataSyncMapping) {
                
                sourceObjToMetadataRecMap.put(mappingRecord.CC_Source_Object__c,mappingRecord );
                
                if(!sourceObjectToSourceChildRelationshipName.containsKey(mappingRecord.CC_Source_Object__c)){
                    String childRelationshipName = (mappingRecord.CC_Source_Object__c == parentObjectName) ? '' : getChildRelationshipName(parentObjectName, mappingRecord.CC_Source_Object__c);
                    sourceObjectToSourceChildRelationshipName.put(mappingRecord.CC_Source_Object__c, childRelationshipName);
                    
                }
                
                if (!sourceToSource_Target_fieldsMap.containsKey(mappingRecord.CC_Source_Object__c)) {
                    sourceToSource_Target_fieldsMap.put(mappingRecord.CC_Source_Object__c, new Map<String, String>());
                }
                
                for(CC_DataSyncFieldMapping__mdt fieldMapping : mappingRecord.CC_DataSyncFieldMapping__r){
                    if(!fieldMapping.CC_Not_for_mapping__c )//need to remove
                        sourceToSource_Target_fieldsMap.get(mappingRecord.CC_Source_Object__c).put(fieldMapping.CC_Source_Field__c, fieldMapping.CC_Target_Field__c);
                }
            }
        }
        System.debug('sourceObjectToSourceChildRelationshipName :: ' + sourceObjectToSourceChildRelationshipName);
        System.debug('sourceObjToMetadataRecMap :: ' + sourceObjToMetadataRecMap);
        System.debug('sourceToSource_Target_fieldsMap :: ' + sourceToSource_Target_fieldsMap);
        String dynamicQuery =  buildDynamicQuery(parentObjectName,sourceToSource_Target_fieldsMap,sourceObjectToSourceChildRelationshipName);
        system.debug('dynamicQuery ::' + dynamicQuery);
        List<Sobject> recordQueriedData = fetchSourceRecords(dynamicQuery,recordIds);
        system.debug('recordQueried ::' + recordQueriedData);
        dataToLoad(parentObjectName,recordQueriedData,sourceToSource_Target_fieldsMap,sourceObjectToSourceChildRelationshipName,sourceObjToMetadataRecMap);
    }
    
    public static String buildDynamicQuery(String parentObjectName, Map<String, Map<String, String>> sourceToSource_Target_fieldsMap , Map<String,String> sourceObjectToSourceChildRelationshipName){
        List<String> selectFields = new List<String>{ 'ID' }; 
            
            // Add parent object fields
            if (sourceToSource_Target_fieldsMap.containsKey(parentObjectName)) {
                for (String parentField : sourceToSource_Target_fieldsMap.get(parentObjectName).keySet()) {
                    selectFields.add(parentField);
                }
            }
        // Add child object subqueries
        for (String childObjectName : sourceObjectToSourceChildRelationshipName.keySet()) {
            if (childObjectName != parentObjectName) {
                String childRelationshipName = sourceObjectToSourceChildRelationshipName.get(childObjectName);
                if (sourceToSource_Target_fieldsMap.containsKey(childObjectName)) {
                    List<String> childFields = new List<String>();
                    for (String childField : sourceToSource_Target_fieldsMap.get(childObjectName).keySet()) {
                        childFields.add(childField);
                    }
                    if (!childFields.isEmpty()) {
                        selectFields.add('(SELECT ID, ' + String.join(childFields, ', ') + ' FROM ' + childRelationshipName + ')');
                    }
                }
            }
        }
        
        String query = 'SELECT ' + String.join(selectFields, ', ') + ' FROM ' + parentObjectName;
        System.debug('query :: ' + query);
        
        return query;
    }
    
    private static List<SObject> fetchSourceRecords(String query , Set<Id>recordIds){
        query +=  ' WHERE Id IN :recordIds';
        return Database.query(query,AccessLevel.SYSTEM_MODE); 
    }
    
    public static void dataToLoad(String parentObjectName, List<Sobject> recordQueriedData, Map<String, Map<String, String>> sourceToSource_Target_fieldsMap , Map<String,String> sourceObjectToSourceChildRelationshipName, Map<String, CC_DataSyncObjectMapping__mdt> sourceObjToMetadataRecMap){
        List<SObject> recordsToUpsert = new List<SObject>();
        String serializedData = JSON.serialize(recordQueriedData);
        system.debug('serializedData :: ' + serializedData);
        List<Object> dataToProcess = (List<Object>) JSON.deserializeUntyped(serializedData);
        for (Object rawRecord : dataToProcess) {
            Map<String, Object> recordData = (Map<String, Object>) rawRecord;
            String parentObject = (String) ((Map<String, Object>) recordData.get('attributes')).get('type');
            
            if(parentObject == parentObjectName){
                // SObjectType accountType = Schema.getGlobalDescribe().get(sourceObjToMetadataRecMap.get(parentObjectName).CC_Target_Object__c);
                //  Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
                //  Map<String,Schema.SObjectField> sObjectfieldsMap  =  Schema.getGlobalDescribe().get(parentObject).getSobjectType().getDescribe().fields.getMap();
                SObject newRecord = Schema.getGlobalDescribe().get(sourceObjToMetadataRecMap.get(parentObjectName).CC_Target_Object__c).newSObject();
                for(String sourceObjectTargetFileds : sourceToSource_Target_fieldsMap.get(parentObject).keySet()){
                    String targetField = sourceToSource_Target_fieldsMap.get(parentObject).get(sourceObjectTargetFileds);
                    String type_of_field =  getParsedValue(parentObjectName,targetField);
                    if(String.valueOf(recordData.get(sourceObjectTargetFileds)) != null && !String.isBlank(String.valueOf(recordData.get(sourceObjectTargetFileds)))){
                        if(type_of_field == 'DATE'){
                            newRecord.put(targetField, date.valueOf(String.valueOf(recordData.get(sourceObjectTargetFileds))));
                        }else if(type_of_field == 'DATETIME'){
                            newRecord.put(targetField, DateTime.parse(String.valueOf(recordData.get(sourceObjectTargetFileds))));
                        }else if(type_of_field == 'DOUBLE'){
                            newRecord.put(targetField, Double.valueOf(String.valueOf(recordData.get(sourceObjectTargetFileds))));
                        }else if(type_of_field == 'BOOLEAN'){
                            newRecord.put(targetField, Boolean.valueOf(String.valueOf(recordData.get(sourceObjectTargetFileds))));
                        }else{
                            newRecord.put(targetField, String.valueOf(recordData.get(sourceObjectTargetFileds)));
                        }
                    }
                    
                    
                }
                system.debug('newRecord :: ' + newRecord);
                recordsToUpsert.add(newRecord);
            }
        }
        
        //for child processing
        
        for (Object childData : dataToProcess) {
            Map<String, Object> childDataToProcess = (Map<String, Object>) childData;
            for(String childRelationShipName : sourceObjectToSourceChildRelationshipName.keySet()){
                system.debug('childRelationShipName :: ' + childRelationShipName + ' relation name ' + sourceObjectToSourceChildRelationshipName.get(childRelationShipName) + ' containss ' +  childDataToProcess.containsKey(sourceObjectToSourceChildRelationshipName.get(childRelationShipName)));
                if(childDataToProcess.containsKey(sourceObjectToSourceChildRelationshipName.get(childRelationShipName))){
                    Map<String, Object>  childDetails = ( Map<String, Object> )  childDataToProcess.get(sourceObjectToSourceChildRelationshipName.get(childRelationShipName));
                    system.debug('childDetails :: ' + childDetails);
                    if(childDetails != null){
                        List<Object> listOfChildRecord = (List<Object>) childDetails.get('records');
                        for(Object selectedRec : listOfChildRecord){
                            SObject newRecord = Schema.getGlobalDescribe().get(sourceObjToMetadataRecMap.get(childRelationShipName).CC_Target_Object__c).newSObject();
                            Map<String, Object>  records = ( Map<String, Object> ) selectedRec;
                            for(String sourceObjectTargetFileds : sourceToSource_Target_fieldsMap.get(childRelationShipName).keySet()){
                                system.debug('sourceObjectTargetFileds :: ' + sourceObjectTargetFileds);
                                String targetField = sourceToSource_Target_fieldsMap.get(childRelationShipName).get(sourceObjectTargetFileds);
                                system.debug('targetField :: ' + sourceToSource_Target_fieldsMap.get(childRelationShipName).get(sourceObjectTargetFileds));
                                system.debug('sourceObjToMetadataRecMap :: ' + sourceObjToMetadataRecMap.get(childRelationShipName).CC_Target_Object__c);
                                String type_of_field =  getParsedValue(sourceObjToMetadataRecMap.get(childRelationShipName).CC_Target_Object__c,targetField);
                                
                                if(String.valueOf(records.get(sourceObjectTargetFileds)) != null && !String.isBlank(String.valueOf(records.get(sourceObjectTargetFileds)))){
                                    if(type_of_field == 'DATE'){
                                        newRecord.put(targetField, date.valueOf(String.valueOf(records.get(sourceObjectTargetFileds))));
                                    }else if(type_of_field == 'DATETIME'){
                                        newRecord.put(targetField, DateTime.parse(String.valueOf(records.get(sourceObjectTargetFileds))));
                                    }else if(type_of_field == 'DOUBLE'){
                                        newRecord.put(targetField, Double.valueOf(String.valueOf(records.get(sourceObjectTargetFileds))));
                                    }else if(type_of_field == 'BOOLEAN'){
                                        newRecord.put(targetField, Boolean.valueOf(String.valueOf(records.get(sourceObjectTargetFileds))));
                                    }
                                    else if(type_of_field == 'TIME'){
                                        String[] strTimeSplit = String.valueOf(records.get(sourceObjectTargetFileds)).split(':');
                                        Time timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]),Integer.valueOf(strTimeSplit[1]),0 ,0);
                                        newRecord.put(targetField,timeChange );
                                    }else{
                                        newRecord.put(targetField, String.valueOf(records.get(sourceObjectTargetFileds)));
                                    }
                                    
                                }
                                
                            }
                            system.debug('newRecord child:: ' + newRecord);
                            if(newRecord != null){
                                recordsToUpsert.add(newRecord);
                            }
                        }
                        
                    }
                }                    
            }
        }
        
        system.debug('newRecord all to upsert:: ' + recordsToUpsert);
    }
    
    private static  List<CC_DataSyncObjectMapping__mdt> getObjectFieldMappings(Set<Id> dataSyncRecordsIdForMapping) {
        Map<String, Map<String, String>> mapping = new Map<String, Map<String, String>>();
        List<CC_DataSyncObjectMapping__mdt> getDataSyncMapping =  [Select id ,CC_Relationship_Api_Name__c,CC_Sync_Identifier__c,CC_Source_Object__c,CC_Target_Object__c,Relationship_Field_in_Apex__c, (select id,CC_Source_Field__c,CC_Target_Field__c,CC_Is_Static_Value__c,CC_Field_Type__c,CC_Not_for_mapping__c  From CC_DataSyncFieldMapping__r where CC_Is_Active__c = true ) 
                                                                   From CC_DataSyncObjectMapping__mdt WHERE Id IN:dataSyncRecordsIdForMapping And CC_Is_Active__c = true With User_Mode Limit 500];
        
        return getDataSyncMapping;
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
    
    public static String removeCommaFromSting(String stringWithComma){
        
        if(stringWithComma.endsWith(',')){
            stringWithComma = stringWithComma.substring(0,stringWithComma.length() - 1);
            return stringWithComma;
        }
        return stringWithComma;
    }
    
    public static String getParsedValue(String objectname , String fieldName){
        String type_of_field = '';
        SObjectType accountType = Schema.getGlobalDescribe().get(objectname);
        Map<String,Schema.SObjectField> sObjectfieldsMap = accountType.getDescribe().fields.getMap();
        if(sObjectfieldsMap.containsKey(fieldName)){
            Schema.DescribeFieldResult fieldApi = sObjectfieldsMap.get(fieldName).getDescribe();
            system.debug('fieldApi' + fieldApi);
            system.debug('fieldApi Type' + fieldApi.Type);
            if(fieldApi.Type == schema.DisplayType.DATE){
                // date.parse(String.valueOf(valueToParse));
                type_of_field = 'DATE';
            }
            if(fieldApi.Type == schema.DisplayType.DATETIME){
                // DateTime.parse(String.valueOf(valueToParse));
                type_of_field = 'DATETIME';
            }
            if(fieldApi.Type == schema.DisplayType.DOUBLE){
                // DateTime.parse(String.valueOf(valueToParse));
                type_of_field = 'DOUBLE';
            }
            if(fieldApi.Type == schema.DisplayType.BOOLEAN){
                // DateTime.parse(String.valueOf(valueToParse));
                type_of_field = 'BOOLEAN';
            }
            if(fieldApi.Type == schema.DisplayType.TIME){
                // DateTime.parse(String.valueOf(valueToParse));
                type_of_field = 'TIME';
            }
        }
        
        return type_of_field;
    }
    
    
}