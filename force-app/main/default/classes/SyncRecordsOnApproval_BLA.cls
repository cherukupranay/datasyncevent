public with sharing class SyncRecordsOnApproval_BLA {
 
    public static void SyncRecordsOnApproval_BLA(String parentObjectName , String applicationType , String flowType,  Set<Id> recordIds ) {

        recordIds = new Set<Id>{'0f0cn000000OyavAAC'};
        String filedApiNameIdentifier = 'Sync_Object_';
        Set<Id> dataSyncRecordsIdForMapping = new Set<Id>();
        String dynamicQuery = '';
        Map<String, Map<String, Object>> metadataMap = new Map<String, Map<String, Object>>();

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

        if(!dataSyncRecordsIdForMapping.isEmpty()) {
            List<CC_DataSyncObjectMapping__mdt> getDataSyncMapping = getObjectFieldMappings(dataSyncRecordsIdForMapping);
            metadataMap = processMeatdataRecords(parentObjectName, getDataSyncMapping);
           if(metadataMap != null){
            dynamicQuery = buildDynamicQueryFromMetadata(parentObjectName,metadataMap);
           // system.debug('dynamicQuery ::' + dynamicQuery);
           }
        }
        if(!String.isBlank(dynamicQuery)){
            List<Sobject> recordQueriedData = fetchSourceRecords(dynamicQuery,recordIds);
          //  system.debug('recordQueried ::' + recordQueriedData);
            syncData(recordQueriedData,parentObjectName,metadataMap);
        }

    }

    public static void syncData( List<Sobject> recordQueriedData , String parentObjectName , Map<String, Map<String, Object>> metadataMap){
        List<SObject> parentObjectsToInsert = new List<SObject>();
        List<SObject> recordsToInsert = new List<SObject>();
        Map<String, List<SObject>> childObjectsToInsert = new Map<String, List<SObject>>();
        if (recordQueriedData == null || recordQueriedData.isEmpty()) {
            System.debug('No data to process.');
            return;
        }

        for (SObject record : recordQueriedData) {
          //  System.debug('recordQueriedData :: ' + record);
            parentObjectsToInsert.add(record); 
            for (String relationshipName : metadataMap.keySet()) {
                if (relationshipName != parentObjectName) {
                   // System.debug('relationshipName ::' + relationshipName);
                    List<SObject> childRecords = (List<SObject>) record.getSObjects(relationshipName);
                 //  System.debug('childRecords ::' + childRecords);
                    if (childRecords != null && !childRecords.isEmpty()) {
                        if (!childObjectsToInsert.containsKey(relationshipName)) {
                            childObjectsToInsert.put(relationshipName, new List<SObject>());
                        }
                        childObjectsToInsert.get(relationshipName).addAll(childRecords);
                    }
                }
            }
        }

          // Process and insert parent objects
          if (!parentObjectsToInsert.isEmpty()) {
            recordsToInsert.addAll(prepareParentSobjectRecors(parentObjectsToInsert, metadataMap.get(parentObjectName),parentObjectName));
        }

        // Process and insert child objects
        for (String relationshipName : childObjectsToInsert.keySet()) {
            recordsToInsert.addAll(prepareChildSobjectRecors(childObjectsToInsert.get(relationshipName), metadataMap.get(relationshipName)));
        }
       // system.debug('recordsToInsert :: ' + recordsToInsert);
    }

    public static List<SObject> prepareParentSobjectRecors(List<SObject> records, Map<String, Object> metadata ,String parentObjectName) {
        List<SObject> recordsToInsert = new List<SObject>();
        for (SObject sourceRecord : records) {
            if((String) metadata.get('CC_Source_Object__c') == parentObjectName){
                SObject targetRecord = Schema.getGlobalDescribe().get( (String) metadata.get('CC_Target_Object__c')).newSObject();
                mapSobjectFieldHelper(sourceRecord, targetRecord, metadata);
                recordsToInsert.add(targetRecord);
            }

        }
        return recordsToInsert;
       
    }

    public static List<SObject>  prepareChildSobjectRecors(List<SObject> records, Map<String, Object> metadata ) {
        List<SObject> recordsToInsert = new List<SObject>();
        for (SObject sourceRecord : records) {
            SObject targetRecord = Schema.getGlobalDescribe().get( (String) metadata.get('CC_Target_Object__c')).newSObject();
            mapSobjectFieldHelper(sourceRecord, targetRecord, metadata);
            recordsToInsert.add(targetRecord);
        } 
        return recordsToInsert;
    }

    private static void mapSobjectFieldHelper(SObject sourceRecord, SObject targetRecord, Map<String, Object> metadata) {
        List<Map<String, Object>> fieldMappings = (List<Map<String, Object>>) metadata.get('FieldMappingsDetail');
        if (fieldMappings != null) {
            for (Map<String, Object> fieldMapping : fieldMappings) {
                if((Boolean)  fieldMapping.get('CC_Not_for_mapping__c') == false ){
                    String sourceField = (String) fieldMapping.get('CC_Source_Field__c');
                    String targetField = (String) fieldMapping.get('CC_Target_Field__c');
                   
                        Schema.DisplayType fieldType = getFieldType((String) metadata.get('CC_Target_Object__c'), targetField);
                        if (fieldType == null) {
                            targetRecord.put(targetField, String.valueOf(sourceRecord.get(sourceField))); // Default to String
                            return;
                        }
    
                        try {
                            if(!String.isBlank(String.valueOf(sourceRecord.get(sourceField)))){
                                switch on fieldType {
                                    when DATE {
                                        targetRecord.put(targetField, Date.valueOf(sourceRecord.get(sourceField)));
                                    }
                                    when DATETIME {
                                        targetRecord.put(targetField, DateTime.valueOf(sourceRecord.get(sourceField)));
                                    }
                                    when DOUBLE {
                                        targetRecord.put(targetField, Double.valueOf(sourceRecord.get(sourceField)));
                                    }
                                    when BOOLEAN {
                                        targetRecord.put(targetField, Boolean.valueOf(sourceRecord.get(sourceField)));
                                    }
                                    when TIME {
                                        String[] strTimeSplit = String.valueOf(sourceRecord.get(sourceField)).split(':');
                                        Time timeChange = Time.newInstance( Integer.valueOf(strTimeSplit[0]),Integer.valueOf(strTimeSplit[1]),0 ,0);
                                        targetRecord.put(targetField, timeChange);
                                    } when else {
                                        targetRecord.put(targetField, String.valueOf(sourceRecord.get(sourceField)));
                                    }
                                }
                            }
                         
                        } catch (Exception e) {
                            System.debug('Error setting field ' + targetField + ': ' + e.getMessage());
                            // Handle the exception appropriately (e.g., log, throw a custom exception)
                        }
                    
                  

                   // targetRecord.put(targetField, sourceRecord.get(sourceField));
                }
            }
        }
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

     // Helper to get the child relationship name dynamically
     public static  Map<String, Map<String, Object>> processMeatdataRecords(String parentObjectName, List<CC_DataSyncObjectMapping__mdt> getDataSyncMapping ) {
        Map<String, Map<String, Object>> metadataMap = new Map<String, Map<String, Object>>();
       
        for (CC_DataSyncObjectMapping__mdt mappingRecord :getDataSyncMapping) {
            Map<String, Object> objectData = new Map<String, Object>();
            String childRelationshipName = getChildRelationshipName(parentObjectName, mappingRecord.CC_Source_Object__c);
            objectData.put('CC_Source_Object__c',mappingRecord.CC_Source_Object__c);
            objectData.put('CC_Target_Object__c',mappingRecord.CC_Target_Object__c);
            objectData.put('Child_RelationshipName',childRelationshipName);
            // Add child object fields to a list within the inner map.
            List<Map<String, Object>> fieldMappings = new List<Map<String, Object>>();
            for(CC_DataSyncFieldMapping__mdt fieldMapping : mappingRecord.CC_DataSyncFieldMapping__r){
                Map<String, Object> fieldData = new Map<String, Object>();
                fieldData.put('CC_Source_Field__c', fieldMapping.CC_Source_Field__c);
                fieldData.put('CC_Target_Field__c', fieldMapping.CC_Target_Field__c);
                fieldData.put('CC_Not_for_mapping__c', fieldMapping.CC_Not_for_mapping__c);
                fieldData.put('ChildMetadata', fieldMapping);
                fieldMappings.add(fieldData);
            }
            objectData.put('FieldMappingsDetail', fieldMappings);
            if (childRelationshipName != null) {
                metadataMap.put(childRelationshipName, objectData);
            }else if (childRelationshipName == null && mappingRecord.CC_Source_Object__c == parentObjectName) {
                metadataMap.put(parentObjectName, objectData);
            }
           
        }
        return metadataMap;
     }

     public static String buildDynamicQueryFromMetadata(String parentObjectName, Map<String, Map<String, Object>> metadataMap) {
        List<String> selectFields = new List<String>{ 'ID' }; 
         // Add parent object fields
    if (metadataMap.containsKey(parentObjectName)) {
        List<Map<String, Object>> fieldMappings = (List<Map<String, Object>>) metadataMap.get(parentObjectName).get('FieldMappingsDetail');
        if (fieldMappings != null) {
            for (Map<String, Object> fieldMapping : fieldMappings) {
                selectFields.add((String) fieldMapping.get('CC_Source_Field__c'));
            }
        }
    }

    // child object subqueries
    for (String relationshipName : metadataMap.keySet()) {
        if (relationshipName != parentObjectName) {
            Map<String, Object> objectData = metadataMap.get(relationshipName);
            String childRelationshipName = (String) objectData.get('Child_RelationshipName');
            if (childRelationshipName != null) {
                List<Map<String, Object>> childFieldMappings = (List<Map<String, Object>>) objectData.get('FieldMappingsDetail');
                if (childFieldMappings != null && !childFieldMappings.isEmpty()) {
                    Set<String> childFields = new Set<String>(); // Changed to Set from List - to avoid duplicate field names CC_Email__c
                    for (Map<String, Object> fieldMapping : childFieldMappings) {
                            childFields.add((String) fieldMapping.get('CC_Source_Field__c'));
                    }
                    if (!childFields.isEmpty()) {
                        selectFields.add('(SELECT ID, ' + String.join(childFields, ', ') + ' FROM ' + childRelationshipName + ')');
                    }
                }
            }
        }
    }

    String query = 'SELECT ' + String.join(selectFields, ', ') + ' FROM ' + parentObjectName;
    
    return query;
     }

     private static List<SObject> fetchSourceRecords(String query , Set<Id>recordIds){
        query +=  ' WHERE Id IN :recordIds';
        return Database.query(query,AccessLevel.SYSTEM_MODE); 
    }
    
    public static Schema.DisplayType getFieldType(String objectName, String fieldName) {
        SObjectType sObjectType = Schema.getGlobalDescribe().get(objectName);
        if (sObjectType == null) {
            return null; // Or throw an exception
        }
        Map<String, Schema.SObjectField> sObjectFieldMap = sObjectType.getDescribe().fields.getMap();
        if (sObjectFieldMap.containsKey(fieldName)) {
            return sObjectFieldMap.get(fieldName).getDescribe().getType();
        } else {
            return null; // throw an exception: throw new MyCustomException('Field not found: ' + objectName + '.' + fieldName);
        }
    }
}