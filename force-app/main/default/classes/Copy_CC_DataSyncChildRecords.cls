/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-30-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class Copy_CC_DataSyncChildRecords {
    
    public static void handleDataSync(Map<Id, Id> recordMap) {
        String personEducationRecordTypesLabel = Label.Person_Education_Record_Types;
        List<String> personEducationRecordTypesNames = personEducationRecordTypesLabel.split(',');
        Map<String, Id> personRecordTypeMap = new Map<String, Id>();
        Id recordType;
        for(String personRecordTypeName : personEducationRecordTypesNames){
            System.debug('name ' + personRecordTypeName);
            recordType = Schema.SObjectType.PersonEducation.getRecordTypeInfosByDeveloperName().get(personRecordTypeName).getRecordTypeId();
            personRecordTypeMap.put(personRecordTypeName, recordType);
        }
        String backgroundRecordTypesLabel = Label.Background_Check_Consent_Record_Types;
        List<String> backgroundRecordTypesNames = backgroundRecordTypesLabel.split(',');

        Map<String, Id> backgroundRecordTypeMap = new Map<String, Id>();
        for(String backgroundRecord : backgroundRecordTypesNames){
             recordType = Schema.SObjectType.CC_Background_Check_Consent__c.getRecordTypeInfosByDeveloperName().get(backgroundRecord).getRecordTypeId();
             backgroundRecordTypeMap.put(backgroundRecord, recordType);
        }
        // System.debug('bc recordType ' + backgroundRecordTypesNames);
    
        Set<Id> parentRecordIds = recordMap.keySet();
        Set<Id> childRecordIds = new Set<Id>(recordMap.values());

        system.debug('childRecordIds ' + childRecordIds);

      /*  List<PublicApplicationParticipant> allChildData = [Select Id, Name, ApplicationId, CC_Participant__c,
                (SELECT ID, Related_Record_Reference_Id__c, CC_BRC_Status__c, Type__c, CC_Business_License_Application__c, Source__c, Check_Based_On__c, Begin_Date__c, End_Date__c, Meets_Criteria__c, FBI_ROI_Received__c, Review_needed__c, Comments__c FROM Background_Checks__r),
                (SELECT ID, Name, CC_Immunisation_Type__c, CC_Immunization_Date__c, CC_Verification_Date__c ,CC_Verification__c,Related_Record_Reference_Id__c, CC_Business_License_Application__c, CC_Individual_Application__c FROM Vaccination_Information_s__r WHERE RecordType.DeveloperName = 'Immunisation'),
                (SELECT ID, Name, Status, RecordType.DeveloperName, CC_Business_License_Application__c, CC_Individual_Application__c, CC_Registry_Level__c, CC_Submission_Date__c, CC_Expiration_Date__c, CC_Source__c, CC_Certification_Type__c, CC_Completion_Date__c, CC_Scheduled_Date__c, CC_Issued_Date__c, CC_Training_Orientation_Courses_Type__c, CC_Hours__c, Related_Record_Reference_Id__c FROM Person_Educations__r WHERE RecordType.DeveloperName IN:personEducationRecordTypesNames),
                (SELECT Id, CC_Received_Date__c,CC_Received_Online__c , RecordType.DeveloperName, CC_Comment__c, CC_Business_License_Application__c, CC_Individual_Application__c, CC_Out_Of_State__c, Related_Record_Reference_Id__c FROM Background_Check_Consents__r WHERE RecordType.DeveloperName IN:backgroundRecordTypesNames)
            FROM PublicApplicationParticipant
            WHERE Id IN :childRecordIds AND CC_Background_Check_Required__c = true
            WITH USER_MODE
        ];*/
        
        List<CC_Application_Contact__c> allChildData = [Select Id, CC_Business_License_Application__c,CC_Individual_Application__c, CC_Participant__c,
                (SELECT ID, Related_Record_Reference_Id__c, CC_BRC_Status__c, Type__c, CC_Business_License_Application__c, CC_Individual_Application__c,  Source__c, Check_Based_On__c, Begin_Date__c, End_Date__c, Meets_Criteria__c, FBI_ROI_Received__c, Review_needed__c, Comments__c FROM Background_Checks__r),
                (SELECT ID, Name, CC_Immunisation_Type__c, CC_Immunization_Date__c, CC_Verification_Date__c ,CC_Verification__c,Related_Record_Reference_Id__c, CC_Business_License_Application__c, CC_Individual_Application__c FROM Vaccination_Information_s__r WHERE RecordType.DeveloperName = 'Immunisation'),
                (SELECT ID, Name, RecordType.DeveloperName, CC_License_Application__c , CC_Registry_Level__c, CC_Submission_Date__c, CC_Expiration_Date__c, CC_Source__c, CC_Certification_Type__c, CC_Completion_Date__c, CC_Scheduled_Date__c, CC_Issued_Date__c, CC_Training_Orientation_Courses_Type__c, CC_Hours__c, CC_Related_Record_Reference_Id__c FROM Person_Educations__r WHERE RecordType.DeveloperName IN:personEducationRecordTypesNames),
                (SELECT Id, CC_Received_Date__c,CC_Received_Online__c , RecordType.DeveloperName, CC_Comment__c, CC_Business_License_Application__c, CC_Individual_Application__c, CC_Out_Of_State__c, Related_Record_Reference_Id__c FROM Background_Check_Consents__r WHERE RecordType.DeveloperName IN:backgroundRecordTypesNames)
            FROM CC_Application_Contact__c
            WHERE Id IN :childRecordIds AND CC_Background_Check_Required__c = true
            WITH USER_MODE
        ];
        


        //system.debug('allChildData ' + allChildData[0].Person_Educations__r[0].RecordType.DeveloperName);
        //Creating List of Account Id associated with the PAP whose Bachkground Check is required 
        List<Id> filteredAccountId = new List<Id>();
       for(CC_Application_Contact__c child : allChildData){
            if(child.CC_Participant__c != null){
                filteredAccountId.add(child.CC_Participant__c);
            }
        }
    
        system.debug('filteredAccount ' + filteredAccountId);
        List<Account> allParentData = [SELECT Id, Name, 
                (SELECT ID, Related_Record_Reference_Id__c, CC_BRC_Status__c, CC_Business_License_Application__c, Type__c, Source__c, Check_Based_On__c, Begin_Date__c, End_Date__c, Meets_Criteria__c, FBI_ROI_Received__c, Review_needed__c, Comments__c FROM Background_Checks__r),
                (SELECT ID, Name, CC_Verification_Date__c, CC_Immunization_Date__c, CC_Verification__c, CC_Immunisation_Type__c, Related_Record_Reference_Id__c, CC_Business_License_Application__c FROM Vaccination_Information_s__r WHERE RecordType.DeveloperName = 'Immunisation'),
                (SELECT ID, Name, CC_Registry_Level__c,RecordType.DeveloperName,  CC_Submission_Date__c,  CC_Expiration_Date__c, CC_Source__c, CC_Certification_Type__c, CC_Completion_Date__c, CC_Scheduled_Date__c, CC_Issued_Date__c, CC_Training_Orientation_Courses_Type__c, CC_Hours__c, CC_Related_Record_Reference_Id__c FROM PersonEducations__r WHERE RecordType.DeveloperName IN:personEducationRecordTypesNames),
                (SELECT Id, CC_Received_Date__c, CC_Received_Online__c , CC_Comment__c, RecordType.DeveloperName, CC_Business_License_Application__c, CC_Out_Of_State__c, Related_Record_Reference_Id__c FROM Background_Check_Consents__r WHERE RecordType.DeveloperName IN:backgroundRecordTypesNames)
            FROM Account
            WHERE Id IN :filteredAccountId
            WITH USER_MODE
        ];
    
        System.debug('allParentData ' + allParentData);
    
        
        // Build a map of existing PAP child records using Related_Record_Reference_Id__c
        Map<String, Id> existingPAPRecords = new Map<String, Id>();
        
        for(CC_Application_Contact__c childRecord : allChildData){
            if(childRecord.Background_Checks__r.size() > 0){
                for (CC_Background_Check__c  child : childRecord.Background_Checks__r) {

                    existingPAPRecords.put(child.Related_Record_Reference_Id__c, child.Id);
                }
            }
            if(childRecord.Vaccination_Information_s__r.size() > 0){ 
                for (CC_Vaccination_Information__c child : childRecord.Vaccination_Information_s__r) {
                    existingPAPRecords.put(child.Related_Record_Reference_Id__c, child.Id);
                }
            }
            if(childRecord.Person_Educations__r.size() > 0){ 
                System.debug('hello');
                for (CC_Person_Education__c child : childRecord.Person_Educations__r) {
                    existingPAPRecords.put(child.CC_Related_Record_Reference_Id__c, child.Id);
                }
            }
            if(childRecord.Background_Check_Consents__r.size() > 0){ 
                System.debug('hi');
                for (CC_Background_Check_Consent__c child : childRecord.Background_Check_Consents__r) {
                    existingPAPRecords.put(child.Related_Record_Reference_Id__c, child.Id);
                }
            }
        }


        Map<Id, String> papAssociatedBla = new Map<Id, Id>();
        for (CC_Application_Contact__c pap : allChildData) {

            if(pap.CC_Business_License_Application__c != null){
                papAssociatedBLA.put(pap.Id, pap.CC_Business_License_Application__c);
            }
           
        }
        Map<Id, String> papAssociatedIa = new Map<Id, Id>();
        for (CC_Application_Contact__c pap : allChildData) {
            if(pap.CC_Individual_Application__c != null){
                papAssociatedIa.put(pap.Id, pap.CC_Individual_Application__c);
            }
        }
        
        
        //Prepare records for Insert/Update
        List<SObject> recordsToUpsert = new List<SObject>();
        for(Account parent : allParentData ){
            if(parent.Background_Checks__r.size() > 0){
                for(CC_Background_Check__c parentChild : parent.Background_Checks__r){
       
                    CC_Background_Check__c newChild = new CC_Background_Check__c();
                    if(recordMap.containsKey(parent.Id)){
                        //SM - Commenting this line as new field is in place (CC_Application_Contact__c)
                        // newChild.CC_Public_Application_Participant__c =recordMap.get(parent.Id);
                        newChild.CC_Application_Contact__c =recordMap.get(parent.Id);
                    }
                    if(papAssociatedBLA.containsKey(recordMap.get(parent.Id))){
                         newChild.CC_Business_License_Application__c = papAssociatedBLA.get(recordMap.get(parent.Id));  
                    }
                    if(papAssociatedIa.containsKey(recordMap.get(parent.Id))){
                         newChild.CC_Individual_Application__c = papAssociatedIa.get(recordMap.get(parent.Id));
                    }
                    // if(papAssociatedApplication.containsKey(recordMap.get(parent.Id))){
                    //     newChild.ApplicationId = papAssociatedApplication.get(recordMap.get(parent.Id));
                    // }
                    newChild.Type__c = parentChild.Type__c;
                    newChild.Source__c = parentChild.Source__c;
                    newChild.Check_Based_On__c = parentChild.Check_Based_On__c;
                    newChild.Begin_Date__c = parentChild.Begin_Date__c;
                    newChild.End_Date__c = parentChild.End_Date__c;
                    newChild.Meets_Criteria__c = parentChild.Meets_Criteria__c;
                    newChild.FBI_ROI_Received__c = parentChild.FBI_ROI_Received__c;
                    newChild.Review_needed__c = parentChild.Review_needed__c;
                    newChild.Comments__c = parentChild.Comments__c;
                    newChild.Related_Record_Reference_Id__c = parentChild.Id;
                    newChild.CC_BRC_Status__c = parentChild.CC_BRC_Status__c;
                    
                    if (existingPAPRecords.containsKey(parentChild.Id)) {
                        newChild.Id = existingPAPRecords.get(parentChild.Id); // Update existing
                    }
                    recordsToUpsert.add(newChild);
                }
            }
        
            if(parent.Vaccination_Information_s__r.size() > 0){
                for (CC_Vaccination_Information__c parentChild : parent.Vaccination_Information_s__r) {
                    CC_Vaccination_Information__c newChild = new CC_Vaccination_Information__c();
                    if(recordMap.containsKey(parent.Id)){
                        //SM - Commenting this line as new field is in place (CC_Application_Contact__c)
                        // newChild.Public_Application_Participant__c =recordMap.get(parent.Id);
                        newChild.CC_Application_Contact__c =recordMap.get(parent.Id);
                    }
                    if(papAssociatedBLA.containsKey(recordMap.get(parent.Id))){
                         newChild.CC_Business_License_Application__c = papAssociatedBLA.get(recordMap.get(parent.Id));  
                    }
                    if(papAssociatedIa.containsKey(recordMap.get(parent.Id))){
                         newChild.CC_Individual_Application__c = papAssociatedIa.get(recordMap.get(parent.Id));
                    }
                    //newChild.Public_Application_Participant__c   = allChildData.Id;
                    newChild.Related_Record_Reference_Id__c = parentChild.Id;
                    newChild.CC_Immunisation_Type__c = parentChild.CC_Immunisation_Type__c;
                    newChild.CC_Immunisation_Type__c = parentChild.CC_Immunisation_Type__c;
                    newChild.CC_Verification_Date__c = parentChild.CC_Verification_Date__c;
                    newChild.CC_Verification__c = parentChild.CC_Verification__c;
                    newChild.CC_Immunization_Date__c = parentChild.CC_Immunization_Date__c;

                                
                    if (existingPAPRecords.containsKey(parentChild.Id)) {
                        newChild.Id = existingPAPRecords.get(parentChild.Id); // Update existing
                    }
                    recordsToUpsert.add(newChild);
                }
            }
            
            if(parent.PersonEducations__r.size() > 0) {
                for (CC_Person_Education__c parentChild : parent.PersonEducations__r) {
                    CC_Person_Education__c newChild = new CC_Person_Education__c();

                    newChild.Name   = parentChild.Name;
                    if(recordMap.containsKey(parent.Id)){
                        //SM - Commenting this line as new field is in place (CC_Application_Contact__c)
                        // newChild.Public_Application_Participant__c =recordMap.get(parent.Id);
                        newChild.CC_Application_Contact__c =recordMap.get(parent.Id);
                    }
                    if(papAssociatedBLA.containsKey(recordMap.get(parent.Id))){
                         newChild.CC_License_Application__c = papAssociatedBLA.get(recordMap.get(parent.Id));  
                    }
                    /*if(papAssociatedIa.containsKey(recordMap.get(parent.Id))){
                         newChild.CC_Individual_Application__c = papAssociatedIa.get(recordMap.get(parent.Id));
                    }*/

                    if(personRecordTypeMap.containsKey(parentChild.RecordType.DeveloperName)){
                        newChild.RecordTypeId = personRecordTypeMap.get(parentChild.RecordType.DeveloperName);
                    }
                    //newChild.Public_Application_Participant__c   = allChildData.Id;
                    newChild.CC_Related_Record_Reference_Id__c = parentChild.Id;
                    //newChild.Status = parentChild.Status;
                    newChild.CC_Registry_Level__c = parentChild.CC_Registry_Level__c;
                    newChild.CC_Submission_Date__c = parentChild.CC_Submission_Date__c;
                    newChild.CC_Expiration_Date__c = parentChild.CC_Expiration_Date__c;
                    newChild.CC_Source__c = parentChild.CC_Source__c;
                    newChild.CC_Certification_Type__c = parentChild.CC_Certification_Type__c;
                    newChild.CC_Completion_Date__c = parentChild.CC_Completion_Date__c;
                    newChild.CC_Scheduled_Date__c = parentChild.CC_Scheduled_Date__c;
                    newChild.CC_Issued_Date__c = parentChild.CC_Issued_Date__c;
                    newChild.CC_Training_Orientation_Courses_Type__c = parentChild.CC_Training_Orientation_Courses_Type__c;
                    newChild.CC_Hours__c = parentChild.CC_Hours__c;

                    
                    if (existingPAPRecords.containsKey(parentChild.Id)) {
                        newChild.Id = existingPAPRecords.get(parentChild.Id); // Update existing
                    }
                    recordsToUpsert.add(newChild);
                }
            }

            if(parent.Background_Check_Consents__r.size() > 0){
                for(CC_Background_Check_Consent__c parentConsent : parent.Background_Check_Consents__r){
                    CC_Background_Check_Consent__c newChild = new CC_Background_Check_Consent__c();
                    if(recordMap.containsKey(parent.Id)){
                        //SM - Commenting this line as new field is in place (CC_Application_Contact__c)
                        // newChild.CC_Public_Application_Participant__c = recordMap.get(parent.Id);
                        newChild.CC_Application_Contact__c = recordMap.get(parent.Id);
                    }
                    if(papAssociatedBLA.containsKey(recordMap.get(parent.Id))){
                         newChild.CC_Business_License_Application__c = papAssociatedBLA.get(recordMap.get(parent.Id));  
                    }
                    if(papAssociatedIa.containsKey(recordMap.get(parent.Id))){
                         newChild.CC_Individual_Application__c = papAssociatedIa.get(recordMap.get(parent.Id));
                    }
                    if(backgroundRecordTypeMap.containsKey(parentConsent.RecordType.DeveloperName)){
                        newChild.RecordTypeId = backgroundRecordTypeMap.get(parentConsent.RecordType.DeveloperName);
                    }
                    newChild.Related_Record_Reference_Id__c = parentConsent.Id;
                    newChild.CC_Received_Date__c = parentConsent.CC_Received_Date__c;
                    newChild.CC_Out_Of_State__c = parentConsent.CC_Out_Of_State__c;
                    newChild.CC_Received_Online__c = parentConsent.CC_Received_Online__c;
                    newChild.CC_Comment__c = parentConsent.CC_Comment__c;
    
                    if (existingPAPRecords.containsKey(parentConsent.Id)) {
                        newChild.Id = existingPAPRecords.get(parentConsent.Id);
                    }
                    recordsToUpsert.add(newChild);
                }
            }
            
            System.debug('recordtopsert ' + recordsToUpsert);
            if (!recordsToUpsert.isEmpty()) {
                CC_DML.doUpsert(recordsToUpsert, false);
            }
        }
    }
    
    public static void handleDataSyncOnApproval(String parentObjectName , String applicationType , String licenceType){
        
        List<Approval_Amend_Renwal_App_Data_Sync__mdt > getApprovalSyncMapping = [SELECT ID,Parent_Object__c,Facility_Application_Type__c,Flow_Type__c,Sync_Object__c,Sync_Object__r.Label,Child_Relationship_Field_Name_1__c,Sync_Object_2__c,Sync_Object_2__r.Label,Child_Relationship_Field_Name_2__c,
                                                                                  Sync_Object_3__c,Sync_Object_3__r.Label,Child_Relationship_Field_Name_3__c From Approval_Amend_Renwal_App_Data_Sync__mdt where Flow_Type__c =: applicationType AND Facility_Application_Type__c =: applicationType AND Parent_Object__c =: parentObjectName ];
    }
    
}