/**
     * @description       :
     * @author            : Riya Johar
     * @group             :
     * @last modified on  : 04-29-2025
     * @last modified by  : pranay
     **/
    public without sharing class CC_ApplicationController {
        
        public static final  Integer QUERY_LIMIT = 1;
        public static final User currentUserDetails = CC_CommonUtility.getUserDetail();
        
        
        /**
         * @description
         * @author Rohan Rana | 05-23-2024
         * @param ratConfigId
         * @return RegAuthConfigWrapper
         **/
        @AuraEnabled
        public static RegAuthConfigWrapper fetchRegAuthConfigInstructions(String ratConfigId){
            try{
                ratConfigId = CC_CommonUtility.performDecryption(ratConfigId);
                RegAuthConfigWrapper regAuthConfig = new RegAuthConfigWrapper();
                CC_Regulatory_Auth_Type_Configs__c ratConfig = new CC_Regulatory_Auth_Type_Configs__c();
                if(!String.isBlank(ratConfigId)){
                    ratConfig = CC_NoSharing_DAO.fetchRatConfig(ratConfigId);
                }
                if(ratConfig!=null){
                    regAuthConfig.ratConfigId = ratConfig.Id;
                    regAuthConfig.appFlowInstructions = ratConfig.CC_License_App_Instructions_on_Flow__c;
                    regAuthConfig.instructionInfoOnFlow = ratConfig.CC_License_Application_Instruction_FlorP__c;
                    regAuthConfig.facilityTypeName = ratConfig?.CC_Regulatory_Authorization_Type__r?.CC_Facility_Type__c;
                    regAuthConfig.declarationInstruction = ratConfig.CC_Declaration_Instructions__c;
                }
                return regAuthConfig;
            }catch(Exception e){
                throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
            }
        }
        @AuraEnabled
        public static RegAuthConfigWrapper fetchRegAuthConfigInstructionsAmend(String facilityName,String amendType){
            try{
                // ratConfigId = CC_CommonUtility.performDecryption(ratConfigId);
                RegAuthConfigWrapper regAuthConfig = new RegAuthConfigWrapper();
                CC_Regulatory_Auth_Type_Configs__c ratConfig = new CC_Regulatory_Auth_Type_Configs__c();
                if((!String.isBlank(facilityName)) && (!String.isBlank(amendType))){
                    ratConfig = CC_NoSharing_DAO.fetchRatConfig(facilityName, amendType);
                }
                if(ratConfig!=null){
                    regAuthConfig.ratConfigId = ratConfig.Id;
                    regAuthConfig.appFlowInstructions = ratConfig.CC_License_App_Instructions_on_Flow__c;
                    regAuthConfig.instructionInfoOnFlow = ratConfig.CC_License_Application_Instruction_FlorP__c;
                    regAuthConfig.facilityTypeName = ratConfig?.CC_Regulatory_Authorization_Type__r?.CC_Facility_Type__c;
                    regAuthConfig.declarationInstruction = ratConfig.CC_Declaration_Instructions__c;
                }
                return regAuthConfig;
            }catch(Exception e){
                throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
            }
        }
        
        public class DeclarationWrapper{
            @AuraEnabled public String field_value {get; set;}
            @AuraEnabled public String field_key {get; set;}
        }
        
        @AuraEnabled
        public static Map<String, String> fetchDeclarationDetails(String encryptedRATCId){
            Map<String, String> decWrapperMap = new Map<String, String>();
            String ratConfigId = CC_CommonUtility.performDecryption(encryptedRATCId);
            CC_Regulatory_Auth_Type_Configs__c ratcRec = CC_RegulatoryAuthTypeConfigDAO.fetchRatConfig(ratConfigId);
            List<DeclarationWrapper> decWrapperLst = new List<DeclarationWrapper>();
            for(Declaration_Config__mdt decConfigMdtRec : CC_CustomMetadataDAO.fetchDeclarationConfigMdt(ratcRec.CC_Regulatory_Authorization_Type__r.Name, ratcRec.CC_Application_Type__c)){
                decWrapperMap.put(decConfigMdtRec.CC_Field_Key__c, decConfigMdtRec.Field_Value__c);
            }
            // System.debug('Wrapper Data: ' + JSON.serialize(decWrapperMap));
            return decWrapperMap;
        }
        
        @AuraEnabled
        public static RegAuthConfigWrapper fetchRegAuthConfigInfo(String ratConfigId){
            try{
                ratConfigId = CC_CommonUtility.performDecryption(ratConfigId);
                RegAuthConfigWrapper regAuthConfig = new RegAuthConfigWrapper();
                CC_Regulatory_Auth_Type_Configs__c ratConfig = new CC_Regulatory_Auth_Type_Configs__c();
                if(!String.isBlank(ratConfigId)){
                    ratConfig = CC_NoSharing_DAO.fetchRatConfig(ratConfigId);
                }
                if(ratConfig!=null){
                    regAuthConfig.ratName = ratConfig?.CC_Regulatory_Authorization_Type__r?.Name;
                    regAuthConfig.facilityTypeName = ratConfig?.CC_Regulatory_Authorization_Type__r?.CC_Facility_Type__c;
                    regAuthConfig.appFlowInstructions = ratConfig.CC_License_App_Instructions_on_Flow__c;
                    regAuthConfig.instructionInfoOnFlow = ratConfig.CC_License_Application_Instruction_FlorP__c;
                    regAuthConfig.declarationInstruction = ratConfig.CC_Declaration_Instructions__c;
                }
                return regAuthConfig;
            }catch(Exception e){
                throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
            }
        }
        
        /**
         * @description
         * @author Rohan Rana | 05-23-2024
         * @param applicationId
         * @return AppThankYouPageWrapper
         **/
        @AuraEnabled
        public static AppThankYouPageWrapper fetchApplicationDataThankYouPage(String applicationId){
            try {
                applicationId = CC_CommonUtility.performDecryption(applicationId);
                List<BusinessLicenseApplication> applicationInformation = CC_BusinessLicenseApplicationDao.fetchBLAByParIdTyPage(applicationId);
                //  List<RegulatoryTrxnFee> regList = CC_RegulatoryTrxnFeeDAO.fetchRegulatoryTrxnFees(applicationId);
                if(!applicationInformation.isEmpty()){
                    AppThankYouPageWrapper appTyPgWrpr = new AppThankYouPageWrapper();
                    appTyPgWrpr.appId  = CC_CommonUtility.performEncryption(applicationInformation[0].Id);
                    appTyPgWrpr.appName = applicationInformation[0].Name;
                    appTyPgWrpr.ratName = applicationInformation[0].LicenseType.Name;
                    appTyPgWrpr.ratCategory = applicationInformation[0].LicenseType.RegulatoryAuthCategory;
                    appTyPgWrpr.appType = applicationInformation[0].ApplicationType;
                    appTyPgWrpr.facilityTypeName = applicationInformation[0].LicenseType.CC_Facility_Type__c;
                    if(applicationInformation[0].SavedApplicationRef.CC_Amendment_Type__c!=null){
                        appTyPgWrpr.amendmentType = applicationInformation[0].SavedApplicationRef.CC_Amendment_Type__c;
                    }
                    // appTyPgWrpr.paymentName = regList.isEmpty() ? '-' : regList[0].Name ;
                    // appTyPgWrpr.paymentId = regList.isEmpty() ? '' : CC_CommonUtility.performEncryption(regList[0].Id) ;
                    // appTyPgWrpr.showPayment = (!regList.isEmpty());
                    return appTyPgWrpr;
                }
                return null;
            } catch(Exception e){
                throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
            }
        }
        
        /**
         * @description
         * @author Rohan Rana | 05-23-2024
         * @param applicationId
         * @return AppThankYouPageWrapper
         **/
        
        
        @AuraEnabled
        public static String saveDirectorsInformation(String obj) {
            //  try {
                System.debug('accountId----:');
                
                List<CC_Application_Specification__c> appSpecList     = new List<CC_Application_Specification__c>();
                Map<String, Object> degreePersonEducationInformation   =   (Map<String, Object>) JSON.deserializeUntyped(obj);
                
                String  applicationId  = CC_CommonUtility.performDecryption((String)degreePersonEducationInformation.get('applicationId'));
                
                CC_Application_Specification__c appSpec  = new CC_Application_Specification__c();
                if(degreePersonEducationInformation.containsKey('degreeId')){
                    appSpec.Id = degreePersonEducationInformation.get('degreeId')!= null  ?  CC_CommonUtility.performDecryption((String)degreePersonEducationInformation.get('degreeId')) : null;
                }
                // if(degreePersonEducationInformation !==null){
                    appSpec.CC_PreliminaryApplicationRef__c = applicationId;
                    appSpec.CC_Specification_Type__c  = 'Degree';
                    appSpec.Specification_Name__c = (String)degreePersonEducationInformation.get('highestLevelOfEducationPersonEducationD');
                    appSpec.CC_Degree__c = (String)degreePersonEducationInformation.get('degreeOrDiplomaPersonEducationD');
                    appSpec.CC_Major__c = (String)degreePersonEducationInformation.get('majorFieldOfStudyPersonEducationD');
                    appSpecList.add(appSpec);
                // }
                
                if(appSpecList.size()>0){
                    
                    CC_DML.doUpsert(appSpecList, true);
                }
                return appSpecList[0].Id;
            // } catch(Exception e){
                //     throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
            // }
        }
        
        @AuraEnabled
        public static ID deleteFloorPlanRecord(String recId, String spaceType) {
            Id recordId = CC_CommonUtility.performDecryption(recId);
            List<CC_Application_Specification__c> appSpecList = new List<CC_Application_Specification__c>{new CC_Application_Specification__c(Id =recordId)};
            CC_Application_Specification__c appSpec = [SELECT Id, CC_Default_Name_Check__c FROM CC_Application_Specification__c WHERE Id = :recordId LIMIT 1];
            if (appSpec != null && appSpec.CC_Default_Name_Check__c == false) {
                CC_DML.doDelete(new List<CC_Application_Specification__c>{appSpec}, false);
            } else {
                throw new AuraHandledException('Record cannot be deleted because defaultCheck is true');
            }
            return recordId;
        }
        
        @AuraEnabled
        public static void deleteAppSpecRecord(String recId) {
            List<CC_Application_Specification__c> appSpecList = new List<CC_Application_Specification__c>{new CC_Application_Specification__c(Id =recId, is_Deleted__c =true)};
            if(!appSpecList.isEmpty()){
                CC_DML.doUpdate(appSpecList,false);
            }
        }
        
        @AuraEnabled
        public static String saveAppSpecProfessionalCredential(String applicationId,String obj) {
            try {
                Date issuedDate;
                Date expirationDate;
                
                applicationId                                       = CC_CommonUtility.performDecryption(applicationId);
                List<CC_Application_Specification__c> listofAppSpec     = new List<CC_Application_Specification__c>();
                Map<String, Object> directorInformationDetail   =   (Map<String, Object>) JSON.deserializeUntyped(obj);
                String issuedDateStr = (String) directorInformationDetail.get('issuedDate');
                String expirationDateStr = (String) directorInformationDetail.get('expirationDate');
                
                CC_Application_Specification__c appSpec           = new CC_Application_Specification__c();
                if(directorInformationDetail.containsKey('recordId')){
                    appSpec.Id = directorInformationDetail.get('recordId')!= null  ? (String)directorInformationDetail.get('recordId') : null;
                    
                }
                appSpec.CC_Specification_Type__c = 'Professional Credential';
                appSpec.CC_PreliminaryApplicationRef__c  = applicationId;
                appSpec.Specification_Name__c                      = (String)directorInformationDetail.get('certificateOrTrainingName');
                appSpec.CC_Issuer_Organisation__c = (String)directorInformationDetail.get('issuerOrganisation');
                if (String.isNotBlank(issuedDateStr)) {
                    issuedDate = Date.valueOf(issuedDateStr);
                    appSpec.CC_Issuance_Date__c      = Date.valueOf(issuedDateStr);
                }
                if (String.isNotBlank(expirationDateStr)) {
                    expirationDate = Date.valueOf(expiratioNDateStr);
                    appSpec.CC_Expiration_Date__c    = Date.valueOf(expirationDateStr);
                }
                appSpec.CC_Never_Expires__c        = directorInformationDetail.get('neveExpires') != null? Boolean.valueOf(directorInformationDetail.get('neveExpires')) : false;
                
                listofAppSpec.add(appSpec);
                
                if(listofAppSpec.size()>0){
                    
                    CC_DML.doUpsert(listofAppSpec, true);
                }
                return listofAppSpec[0].Id;
            }catch (AuraHandledException e) {
                // Catch the AuraHandledException and propagate the error message
                throw new AuraHandledException('Date error: ' + e.getMessage());
            }
            catch (Exception e) {
                throw new AuraHandledException('Error saving record: ' + e.getMessage());
            }
        }
        
        @AuraEnabled
        public static String saveAppSpecEmployment(String applicationId,String obj) {
            try {
                
                applicationId = CC_CommonUtility.performDecryption(applicationId);
                List<CC_Application_Specification__c> listofAppSpec  = new List<CC_Application_Specification__c>();
                Map<String, Object> directordirectorExpirencesDetail   =   (Map<String, Object>) JSON.deserializeUntyped(obj);
                String empEndDateStr = (String) directordirectorExpirencesDetail.get('empEndDate');
                String empStartedateDateStr = (String) directordirectorExpirencesDetail.get('empStartedate');
                System.debug('Start Date: '+ empStartedateDateStr);
                
                CC_Application_Specification__c appSpec = new CC_Application_Specification__c();
                if(directordirectorExpirencesDetail !=null){
                    if(directordirectorExpirencesDetail.containsKey('recordId')){
                        appSpec.Id = directordirectorExpirencesDetail.get('recordId')!= null  ? (String)directordirectorExpirencesDetail.get('recordId') : null;
                        
                    }
                    appSpec.CC_Specification_Type__c = 'Employment';
                    appSpec.CC_PreliminaryApplicationRef__c = applicationId;
                    appSpec.Specification_Name__c = directordirectorExpirencesDetail.get('employerName') != null? (String)directordirectorExpirencesDetail.get('employerName') : '';
                    
                    appSpec.CC_Position__c = (String)directordirectorExpirencesDetail.get('position');
                    if (String.isNotBlank(empEndDateStr)) {
                        appSpec.CC_End_Date__c                = Date.valueOf(empEndDateStr);
                    }
                    if (String.isNotBlank(empStartedateDateStr)) {
                        appSpec.CC_Start_Date__c                  = Date.valueOf(empStartedateDateStr);
                    }
                    appSpec.CC_Address__Street__s           = (String)directordirectorExpirencesDetail.get('employerStreet') != null?(String)directordirectorExpirencesDetail.get('employerStreet') :null;
                    appSpec.CC_Address__CountryCode__s          = (String)directordirectorExpirencesDetail.get('employerCountry') != null?(String)directordirectorExpirencesDetail.get('employerCountry') :null;
                    appSpec.CC_Address__StateCode__s        = (String)directordirectorExpirencesDetail.get('employerState') != null?(String)directordirectorExpirencesDetail.get('employerState') :null;
                    appSpec.CC_Address__City__s             = (String)directordirectorExpirencesDetail.get('employerCity') != null?(String)directordirectorExpirencesDetail.get('employerCity') :null;
                    appSpec.CC_Address__PostalCode__s       = (String)directordirectorExpirencesDetail.get('employerPostalCode') != null?(String)directordirectorExpirencesDetail.get('employerPostalCode') :null;
                    appSpec.CC_Billing_Apt_Suite__c = (String)directordirectorExpirencesDetail.get('suit') != null?  (String)directordirectorExpirencesDetail.get('suit') :null;
                    appSpec.CC_Billing_County__c = (String)directordirectorExpirencesDetail.get('county') != null?  (String)directordirectorExpirencesDetail.get('county') :null;
                    
                    listofAppSpec.add(appSpec);
                }
                
                if(listofAppSpec.size()>0){
                    CC_DML.doUpsert(listofAppSpec, true);
                }
                return listofAppSpec[0].Id;
            } catch (Exception e) {
                throw new AuraHandledException('Error saving record: ' + e.getMessage());
            }
        }
    
    public class AppThankYouPageWrapper{
        @AuraEnabled public String appName {get;set;}
        @AuraEnabled public String ratName {get;set;}
        @AuraEnabled public String ratCategory {get;set;}
        @AuraEnabled public String appType {get;set;}
        @AuraEnabled public String appId {get;set;}
        @AuraEnabled public String amendmentType {get;set;}
        @AuraEnabled public String paymentName {get;set;}
        @AuraEnabled public String paymentId {get;set;}
        @AuraEnabled public Boolean showPayment {get;set;}
        @AuraEnabled public String facilityTypeName {get;set;}
    }
    public class AppIdWrapper{
        @AuraEnabled public String appId {get;set;}
        @AuraEnabled public String ratId {get;set;}
    }
    
    /**
     * @description
     * @author Rohan Rana | 05-23-2024
     * @param facilityId
     * @param ratConfigId
     * @return AppIdWrapper
     **/
    @AuraEnabled
    public static AppIdWrapper createApplication(String facilityId, String ratConfigId, Boolean isRenewalFlow, String encryptedBLId) {
        Savepoint sp = Database.setSavepoint();
        try {
            if(isRenewalFlow){
                return CC_ApplicationController.cloneAndInsertRecordsForRenewal(encryptedBLId);
            }else{
                ratConfigId = CC_CommonUtility.performDecryption(ratConfigId);
                Id userContactId = CC_UserDAO.getCurrentUserContactId();
                string blId='';
                string changeType='';
                CC_Regulatory_Auth_Type_Configs__c ratConfigRecord = CC_NoSharing_DAO.fetchRatConfig(ratConfigId);
                String regAuthTypeId = ratConfigRecord.CC_Regulatory_Authorization_Type__c;
                List<String> existingStatuses = new List<String>{
                    CC_Constants.APPLICATION_STATUS_DRAFT,
                    CC_Constants.APPLICATION_STATUS_ASSIGNED,
                    CC_Constants.APPLICATION_STATUS_SUBMITTED,
                    CC_Constants.APPLICATION_STATUS_REQUEST_FOR_INFORMATION,
                    CC_Constants.APPLICATION_STATUS_UNDER_REVIEW,
                    CC_Constants.APPLICATION_STATUS_ADDITIONAL_INFORMATION_SUBMITTED,
                    CC_Constants.APPLICATION_STATUS_CERTIFIED_PENDING_AUTHORIZATION,
                    CC_Constants.APPLICATION_STATUS_CERTIFIED_AUTHORIZED_TO_PROVIDER,
                    CC_Constants.APPLICATION_STATUS_AUTHORIZED_TO_PROVIDER,
                    CC_Constants.APPLICATION_STATUS_REJECTED,
                    CC_Constants.APPLICATION_STATUS_PENDING_RECERTIFICATION,
                    CC_Constants.APPLICATION_STATUS_CASE_CLOSED_EXPIRED,
                    CC_Constants.APPLICATION_STATUS_PENDING_EVERIFICATION_OR_VNTD,
                    //CC_Constants.APPLICATION_STATUS_DENIED,
                    CC_Constants.APPLICATION_STATUS_CONTRACTED,
                    CC_Constants.APPLICATION_STATUS_INSPECTION_REQUESTED,
                    CC_Constants.APPLICATION_STATUS_PENDING_RENEWAL,
                    CC_Constants.APPLICATION_STATUS_ONSITE_VISIT_REQUESTED,
                    CC_Constants.APPLICATION_STATUS_TERMINATED
                };
                facilityId = CC_CommonUtility.performDecryption(facilityId);
                
                List<PreliminaryApplicationRef> existingAppList = new List<PreliminaryApplicationRef>();
                if(ratConfigRecord.CC_Application_Type__c==CC_Constants.APPLICATION_TYPE_AMENDMENT){
                    blId = CC_CommonUtility.performDecryption(encryptedBLId);
                    changeType=ratConfigRecord.CC_Type_of_Amendment__c;
                    existingAppList=CC_PreliminaryApplicationRefDAO.fetchPARByBLIdAndAmendType(blId,changeType,CC_Constants.APPLICATION_STATUS_DRAFT);
                }
                else{
                    existingAppList=CC_PreliminaryApplicationRefDAO.fetchExistingPar(facilityId,regAuthTypeId,CC_Constants.APPLICATION_TYPE_NEW,existingStatuses);
                }
                
                if(existingAppList.isEmpty()){
                    List<RegulatoryAuthorizationType> ratConfig = CC_NoSharing_DAO.fetchRAT(new Set<String>{regAuthTypeId});
                    
                    if (ratConfig[0] != null) {
                        PreliminaryApplicationRef newApplication = new PreliminaryApplicationRef();
                        newApplication.CC_Regulatory_Authorization_Type__c = ratConfig[0].Id;
                        if(ratConfig[0].CC_Authorisation_Type__c == 'Business'){
                            newApplication.ApplicationType ='BusinessLicenseApplication';
                        }else if(ratConfig[0].CC_Authorisation_Type__c == 'Individual'){
                            newApplication.ApplicationType ='IndividualApplication';
                        }
                        newApplication.CC_Active_Application_Step__c = 2;
                        newApplication.CC_Application_Status__c = CC_Constants.APPLICATION_STATUS_DRAFT;
                        newApplication.CC_Application_Type__c = ratConfigRecord.CC_Application_Type__c; //CC_Constants.APPLICATION_TYPE_NEW;
                        if(blId!='' && blId!=null){
                            newApplication.CC_Business_License__c=blId;
                        }
                        newApplication.CC_Amendment_Type__c=changeType;
                        newApplication.BusinessAccountNameId = facilityId;
                        newApplication.CC_Contact__c = userContactId;
                        newApplication.SavedApplicationUrl= url.getOrgDomainUrl().toString();
                        populateApplicationFieldsFromAccount(newApplication);
                        //newApplication.ApplicationName='PAR-00001';
                        Id newRecordId = CC_DML.doInsert(newApplication,false).Id;
                        //Added by vardhan for cloning person education & employment to application specification
                        if(newApplication.CC_Application_Type__c == CC_Constants.APPLICATION_TYPE_NEW) {
                            migratePersonEducationEmploymentToAppSpec(newRecordId, facilityId);
                        }
                        //Added by vardhan for cloning appspec from acc for amendments
                        else if(newApplication.CC_Application_Type__c == CC_Constants.APPLICATION_TYPE_AMENDMENT) {
                            cloneApplicationSpecFromAccountForAmendments(newApplication);
                        }
                        AppIdWrapper appIdwrpr = new AppIdWrapper();
                        appIdwrpr.appId = CC_CommonUtility.performEncryption(newRecordId);
                        appIdwrpr.ratId = CC_CommonUtility.performEncryption(newApplication.CC_Regulatory_Authorization_Type__c);
                        return appIdwrpr;
                    } else {
                        throw new CC_Exception('Application Configuration not found.');
                    }
                }
                else{
                    AppIdWrapper appIdwrpr = new AppIdWrapper();
                    appIdwrpr.appId = CC_CommonUtility.performEncryption(existingAppList[0].Id);
                    appIdwrpr.ratId = CC_CommonUtility.performEncryption(existingAppList[0].CC_Regulatory_Authorization_Type__c);
                    return appIdwrpr;
                }
            }
        }
        catch(Exception e){
            Database.rollback(sp);
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
    }
    
    private static AppIdWrapper cloneAndInsertRecordsForRenewal(String encryptedBLId){
        AppIdWrapper appIdwrpr = new AppIdWrapper();
        String blId = CC_CommonUtility.performDecryption(encryptedBLId);
        
        List<PreliminaryApplicationRef> existingAppList = CC_PreliminaryApplicationRefDAO.fetchLatestPARByBLIdAndStatus(blId, new set<String>{CC_Constants.APPLICATION_STATUS_DRAFT});
        if(!existingAppList.isEmpty()){
            appIdwrpr.appId = CC_CommonUtility.performEncryption(existingAppList[0].Id);
            appIdwrpr.ratId = CC_CommonUtility.performEncryption(existingAppList[0].CC_Regulatory_Authorization_Type__c);
        }else{
            BusinessLicense bl = new BusinessLicense(Id = blId, CC_Is_In_Renewal__c = true);
            CC_DML.doUpdate(bl, false);
            
            List<BusinessLicenseApplication> blaRecsLst = CC_BusinessLicenseApplicationDAO.getRecentBLAsByBLId(new Set<String>{blId});
            if(!blaRecsLst.isEmpty()){
                PreliminaryApplicationRef renewalPARRecord = CC_ApplicationController.cloneAndInsertPARRecord(blaRecsLst[0].SavedApplicationRefId, blId);
                appIdwrpr.ratId = CC_CommonUtility.performEncryption(renewalPARRecord.CC_Regulatory_Authorization_Type__c);
                appIdwrpr.appId = CC_CommonUtility.performEncryption(renewalPARRecord.Id);

                // if(String.isNotBlank(renewalPARRecord.Id) && String.isNotBlank(blaRecsLst[0].LicenseType.RegulatoryAuthCategory) && blaRecsLst[0].LicenseType.RegulatoryAuthCategory == 'License'){
                //     appIdwrpr.appId = CC_CommonUtility.performEncryption(renewalPARRecord.Id);
                //     CC_ApplicationController.cloneAndInsertAppContactRecords(blaRecsLst[0].SavedApplicationRefId, renewalPARRecord.Id);
                //     CC_ApplicationController.cloneAndInsertAppSpecRecords(blaRecsLst[0].SavedApplicationRefId, renewalPARRecord.Id);
                // }
                // else if(String.isNotBlank(renewalPARRecord.Id) && String.isNotBlank(blaRecsLst[0].LicenseType.RegulatoryAuthCategory) && blaRecsLst[0].LicenseType.RegulatoryAuthCategory == 'Subsidy'){
                //     appIdwrpr.appId = CC_CommonUtility.performEncryption(renewalPARRecord.Id);
                //     CC_ApplicationController.cloneAndInsertAppSpecRecords(blaRecsLst[0].SavedApplicationRefId, renewalPARRecord.Id);
                // }
            }
        }
        return appIdwrpr;
    }
    
    private static PreliminaryApplicationRef cloneAndInsertPARRecord(String oldPARId, String blId){
        PreliminaryApplicationRef parRecord = CC_PreliminaryApplicationRefDAO.fetchPARById(oldPARId)[0];
        PreliminaryApplicationRef renewalPARRecord = parRecord.clone(false, true, false, false);
        renewalPARRecord.CC_Application_Type__c = CC_Constants.APPLICATION_TYPE_RENEWAL;
        renewalPARRecord.CC_Application_Status__c = CC_Constants.APPLICATION_STATUS_DRAFT;
        renewalPARRecord.SavedApplicationUrl= url.getOrgDomainUrl().toString();
        renewalPARRecord.CC_Business_License__c = blId;
        renewalPARRecord.CC_Active_Application_Step__c = 2;
        populateApplicationFieldsFromAccount(renewalPARRecord);
        renewalPARRecord = (PreliminaryApplicationRef)CC_DML.doInsert(renewalPARRecord, false);
        migratePersonEducationEmploymentToAppSpec(renewalPARRecord.Id, renewalPARRecord.BusinessAccountNameId);

        return renewalPARRecord;
    }
    //VK Commented the method for deleting the existing fields from CC_Application_Contact__c
    /*private static List<CC_Application_Contact__c> cloneAndInsertAppContactRecords(String oldPARId, String renewalPARRecordId){
        List<CC_Application_Contact__c> appConLstForRenewalPAR = new List<CC_Application_Contact__c>();
        
        for(CC_Application_Contact__c appCon : CC_ApplicationContactDAO.fetchApplicationContactByPARId(oldPARId)){
            CC_Application_Contact__c appConForRenewalPAR = appCon.clone(false, true, false, false);
            appConForRenewalPAR.CC_Preliminary_Application_Reference__c = renewalPARRecordId;
            appConLstForRenewalPAR.add(appConForRenewalPAR);
        }
        
        if(!appConLstForRenewalPAR.isEmpty()){
            Copy_CC_NoSharing_DAO.doInsert(appConLstForRenewalPAR, true);
        }
        return appConLstForRenewalPAR;
    }*/
    
    private static List<CC_Application_Specification__c> cloneAndInsertAppSpecRecords(String oldPARId, String renewalPARRecordId){
        List<CC_Application_Specification__c> appSpecLstForRenewalPAR = new List<CC_Application_Specification__c>();
        
        for(CC_Application_Specification__c appSpec : CC_ApplicationSpecificationDAO.fetchAppSpecByPARIdExceptGivenSpecType(oldPARId, new List<String>{CC_Constants.APPLICATION_SPECIFICATION_TYPE_ADDITIONAL_INFORMATION})){
            CC_Application_Specification__c appSpecForRenewalPAR = appSpec.clone(false, true, false, false);
            appSpecForRenewalPAR.CC_PreliminaryApplicationRef__c = renewalPARRecordId;
            if(appSpec.CC_Specification_Type__c == CC_Constants.APPLICATION_SPECIFICATION_TYPE_PROVIDER_BELOW_MARKET_RATES){
                appSpecForRenewalPAR.CC_Provider_Below_Market_Rate_Status__c = CC_Constants.STATUS_DRAFT;
                appSpecForRenewalPAR.CC_Expiration_Date__c = null;
                appSpecForRenewalPAR.CC_Start_Date__c = null;
            }
            appSpecLstForRenewalPAR.add(appSpecForRenewalPAR);
        }
        
        if(!appSpecLstForRenewalPAR.isEmpty()){
            CC_DML.doInsert(appSpecLstForRenewalPAR, false);
        }
        return appSpecLstForRenewalPAR;
    }
    
    
    @AuraEnabled
    public static  CC_ApplicationWrapper.FloorPlan fetchSpaceData(String appSpecType, String appId){
        try{
            
            CC_ApplicationWrapper.FloorPlan floorPlanWrapper = new  CC_ApplicationWrapper.FloorPlan();
            List<CC_ApplicationWrapper.FloorSpaceDataWrapper> floorSpaceWrapper = new List<CC_ApplicationWrapper.FloorSpaceDataWrapper>();
            
            if(appId != null){
                appId = CC_CommonUtility.performDecryption(appId);
                List<PreliminaryApplicationRef> fetched_par = CC_PreliminaryApplicationRefDAO.fetchPARByAppId(appId);
                
                
                PreliminaryApplicationRef appToUpdate = fetched_par[0];
                Id parId = appToUpdate.Id;
                floorPlanWrapper.dateOfMeasurement = appToUpdate.CC_Date_of_Measurement__c != null ? appToUpdate.CC_Date_of_Measurement__c: null;
                List<CC_Application_Specification__c> spaceList = CC_ApplicationSpecificationDAO.fetchSpaceDataByAppSpecId(appSpecType, appId);
                
                for(CC_Application_Specification__c space : spaceList){
                    CC_ApplicationWrapper.FloorSpaceDataWrapper wrapper = new CC_ApplicationWrapper.FloorSpaceDataWrapper();
                    wrapper.spaceType = space.CC_Space_Type__c;
                    wrapper.areaName = space.CC_Name_of_Area__c;
                    wrapper.roomWidth = space.CC_Width_of_Room__c;
                    wrapper.roomLength = space.CC_Length_of_Room__c;
                    wrapper.appSpecId = CC_CommonUtility.performEncryption(space.Id);
                    wrapper.squareFeetOfRoom = space.CC_Square_Feet_of_Room__c;
                    wrapper.capacity = space.CC_Capacity_of_Room__c;
                    wrapper.defaultCheck = space.CC_Default_Name_Check__c;
                    floorSpaceWrapper.add(wrapper);
                }
                floorPlanWrapper.floorSpaceDataWrapper = floorSpaceWrapper;
                return floorPlanWrapper;
            }
            return null;
            
        }catch(Exception e){
            throw new AuraHandledException('Error fetching space data: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static CC_ApplicationWrapper.FloorSpaceDataWrapper saveFloorSpaceData(Map<String, Object> spaceData, String appId ,String spaceDataObj) {
        try {
            
            appId = CC_CommonUtility.performDecryption(appId);
            
            List<PreliminaryApplicationRef> appToUpdateList = CC_PreliminaryApplicationRefDAO.fetchPARByAppId(appId);
            
            CC_ApplicationWrapper.FloorSpaceDataWrapper floorPlanData = (CC_ApplicationWrapper.FloorSpaceDataWrapper)JSON.deserialize(spaceDataObj,CC_ApplicationWrapper.FloorSpaceDataWrapper.class);
            CC_Application_Specification__c appSpec = new CC_Application_Specification__c();
            if(floorPlanData !=null){
                
                appSpec.CC_Space_Type__c = floorPlanData.spaceType;
                appSpec.CC_Name_of_Area__c = floorPlanData.areaName;
                appSpec.CC_Width_of_Room__c = floorPlanData.roomWidth;
                appSpec.CC_Length_of_Room__c = floorPlanData.roomLength;
                appSpec.CC_PreliminaryApplicationRef__c = appToUpdateList[0].Id;
                appSpec.CC_Square_Feet_of_Room__c = floorPlanData.squareFeetOfRoom;
                appSpec.CC_Capacity_of_Room__c =floorPlanData.capacity;
                appSpec.CC_Default_Name_Check__c = floorPlanData.defaultCheck != null? floorPlanData.defaultCheck:false;
                System.debug('App Spec Details:' + appSpec.CC_Default_Name_Check__c);
                appSpec.CC_Specification_Type__c = 'Floor Plan';
                appSpec.Id = !String.isBlank(floorPlanData.appSpecId)  ? CC_CommonUtility.performDecryption(floorPlanData.appSpecId) :  null;
                
            }
            
            
            CC_DML.doUpsert(appSpec, false);
            
            
            floorPlanData.appSpecId = !String.isBlank(floorPlanData.appSpecId) ? floorPlanData.appSpecId : CC_CommonUtility.performEncryption(appSpec.Id); //appSpec.Id;
            System.debug('Wrapper values; '+floorPlanData);
            return floorPlanData;
            
        } catch (Exception e) {
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
    }
    
    
    /**
     * This method fetches the application data for a given application ID.
     * It retrieves various information related to the application, such as application details, facility administration information, capacity information, operation information, indoor/outdoor information, license status and capacity information, involvement and professional experience information, background information, and current application step number.
     *
     * @param applicationId The ID of the application for which to fetch the data.
     * @return The application data wrapper containing all the fetched information.
     * @throws CC_Exception If an error occurs during the data retrieval process.
     */
    @AuraEnabled
    public static CC_ApplicationWrapper.ApplicationDataWrapper fetchApplicationData(String applicationId){
        
        
        
        try {
            CC_ApplicationWrapper.ApplicationDataWrapper applicationDetails                                         = new CC_ApplicationWrapper.ApplicationDataWrapper();
            CC_ApplicationWrapper.ProviderLicenseLargeGroupInformation providerLicenseLargeGroupInformationRecord   = new CC_ApplicationWrapper.ProviderLicenseLargeGroupInformation();
            CC_ApplicationWrapper.DirectorInformationWrapper directorInformationWrapperRecord                       = new CC_ApplicationWrapper.DirectorInformationWrapper();
            CC_ApplicationWrapper.DirectorExpirences addrInfo                                                       = new CC_ApplicationWrapper.DirectorExpirences();
            CC_ApplicationWrapper.CapacityInformation capacityInformationWrapperRecord                              = new CC_ApplicationWrapper.CapacityInformation();
            CC_ApplicationWrapper.OperationInformationWrapper operationInformationWrapperRecord                     = new CC_ApplicationWrapper.OperationInformationWrapper();
            CC_ApplicationWrapper.IndoorOutdoorInformationWrapper indoorOutdoorInformationWrapperRecord             = new CC_ApplicationWrapper.IndoorOutdoorInformationWrapper();
            CC_ApplicationWrapper.LicenseStatusCapacityWrapper licenseStatusCapacityWrapperRecord                   = new CC_ApplicationWrapper.LicenseStatusCapacityWrapper();
            CC_ApplicationWrapper.InvolvementProfessionalExperienceWrapper involvementProfessionalExperienceWrapperRecord = new CC_ApplicationWrapper.InvolvementProfessionalExperienceWrapper();
            CC_ApplicationWrapper.BackgroundInformationWrapper backgroundInformationWrapperRecord                   = new CC_ApplicationWrapper.BackgroundInformationWrapper();
            CC_ApplicationWrapper.DeclartionParInfoWrapper declartionParInfoWrapperRecord                   = new CC_ApplicationWrapper.DeclartionParInfoWrapper();
            //CC_ApplicationWrapper.ProviderRolesandResponsibilityWrapper ProviderRolesandResponsibilityWrapperRecord   = new CC_ApplicationWrapper.ProviderRolesandResponsibilityWrapper();

            Id userAccountId                                        = CC_UserDAO.getCurrentUserAccountId();
            Account userAccount                                     = CC_AccountDAO.getCurrentUserAccount(userAccountId);
            List<Account> toBeUpdatedAccountRecordList              =new List<Account>();
            applicationId                                           = CC_CommonUtility.performDecryption(applicationId);
            
            List<PreliminaryApplicationRef> applicationInformation  = CC_PreliminaryApplicationRefDAO.fetchParList(applicationId);
            List<Account> accountList ;
            if (applicationInformation != null || !applicationInformation.isEmpty()) {
                accountList   = CC_NoSharing_DAO.getAccountDetails(applicationInformation[0].BusinessAccountNameId);
            }
            
            // Upendra Dubey Start   // S-76681
            List<CC_Contact_Role_Relationship__c> contactRoleRFetched = CC_NoSharing_DAO.getFacilityOwnerCoOwnerAcr(applicationInformation[0].BusinessAccountNameId);
            
              //providerrolesandresponsibilities
              //ProviderRolesandResponsibilityWrapperRecord.providerRights=applicationInformation[0].CC_Provider_Rights_Check__c;
              //ProviderRolesandResponsibilityWrapperRecord.providerResponsibilites=applicationInformation[0].CC_Provider_Responsibilites_Check__c;
              //ProviderRolesandResponsibilityWrapperRecord.providerUnderstanding=applicationInformation[0].CC_Provider_Understanding_Check__c;
              //applicationDetails.providerRolesandResponsibility = ProviderRolesandResponsibilityWrapperRecord;

            
            if(accountList.size()>0){
                String addressString;
                //providerrolesandresponsibilities
                // ProviderRolesandResponsibilityWrapperRecord.providerRights=applicationInformation[0].CC_Provider_Rights_Check__c;
                // ProviderRolesandResponsibilityWrapperRecord.providerResponsibilites=applicationInformation[0].CC_Provider_Responsibilites_Check__c;
                // ProviderRolesandResponsibilityWrapperRecord.providerUnderstanding=applicationInformation[0].CC_Provider_Understanding_Check__c;
                // applicationDetails.providerRolesandResponsibility = ProviderRolesandResponsibilityWrapperRecord;

                providerLicenseLargeGroupInformationRecord.ownershipType=accountList[0].CC_Ownership_Type__c;
                providerLicenseLargeGroupInformationRecord.facilityName=accountList[0].parent.CC_Business_Admin__c;
                providerLicenseLargeGroupInformationRecord.facilityType=applicationInformation[0].CC_Facility_Type__c; // Upendra
                // do you know
                providerLicenseLargeGroupInformationRecord.doYouPicklistValueInFacility = accountList[0].CC_Do_you__c;
                providerLicenseLargeGroupInformationRecord.doYouOtherInFacility = accountList[0].CC_Other_Do_You__c;
                
                //providerLicenseLargeGroupInformationRecord.fictitiousName=accountList[0].parent.CC_Fictitious_Name__c; // Upendra
                providerLicenseLargeGroupInformationRecord.fictitiousName=applicationInformation[0].CC_Doing_Business_As__c;
                providerLicenseLargeGroupInformationRecord.facilityUIN=applicationInformation[0]?.FEIN__c;
                providerLicenseLargeGroupInformationRecord.facilitySSN=applicationInformation[0]?.SSN__c;
                providerLicenseLargeGroupInformationRecord.facilityDirectorName=accountList[0].CC_Facility_Director__c;
                providerLicenseLargeGroupInformationRecord.programName=applicationInformation[0].CC_Facility_Name__c;
                providerLicenseLargeGroupInformationRecord.whereIsCareProvided=accountList[0].CC_Where_is_care_going_to_be_provided__c;
                providerLicenseLargeGroupInformationRecord.programStreet=applicationInformation[0].CC_Facility_Physical_Address__Street__s;
                providerLicenseLargeGroupInformationRecord.programCity=applicationInformation[0].CC_Facility_Physical_Address__City__s;
                providerLicenseLargeGroupInformationRecord.programState=applicationInformation[0].CC_Facility_Physical_Address__StateCode__s;
                providerLicenseLargeGroupInformationRecord.programZipCode=applicationInformation[0].CC_Facility_Physical_Address__PostalCode__s;
                providerLicenseLargeGroupInformationRecord.programCountry=applicationInformation[0].CC_Facility_Physical_Address__CountryCode__s;
                providerLicenseLargeGroupInformationRecord.firstName = userAccount.FirstName;
                providerLicenseLargeGroupInformationRecord.lastName = userAccount.LastName;
                providerLicenseLargeGroupInformationRecord.emailAddress = userAccount.PersonEmail;
                providerLicenseLargeGroupInformationRecord.phoneNumber = userAccount.Phone;
                providerLicenseLargeGroupInformationRecord.mailingAddressSame=applicationInformation[0].CC_Facility_Mailing_Same_As_Billing__c;
                // facility address
                providerLicenseLargeGroupInformationRecord.programapartmentSuiteFacility=applicationInformation[0].CC_Facility_Physical_Apt_Suit__c;
                providerLicenseLargeGroupInformationRecord.programCountyFacility=applicationInformation[0].CC_Facility_Physical_County__c;
                
                // end
                providerLicenseLargeGroupInformationRecord.mailingStreet = applicationInformation[0].CC_Facility_Mailing_Address__Street__s;
                providerLicenseLargeGroupInformationRecord.mailingCity = applicationInformation[0].CC_Facility_Mailing_Address__City__s;
                providerLicenseLargeGroupInformationRecord.mailingState = applicationInformation[0].CC_Facility_Mailing_Address__StateCode__s;
                providerLicenseLargeGroupInformationRecord.mailingZipCode = applicationInformation[0].CC_Facility_Mailing_Address__PostalCode__s;
                providerLicenseLargeGroupInformationRecord.mailingCountry = applicationInformation[0].CC_Facility_Mailing_Address__CountryCode__s;
                providerLicenseLargeGroupInformationRecord.mailingCountyFacility=applicationInformation[0].CC_Facility_Mailing_County__c;
                providerLicenseLargeGroupInformationRecord.mailingapartmentSuiteFacility=applicationInformation[0].CC_Facility_Mailing_Apt_Suit__c;
                
                // end
                providerLicenseLargeGroupInformationRecord.facilityEmail=applicationInformation[0].CC_Facility_Email__c;
                providerLicenseLargeGroupInformationRecord.facilityPhone=applicationInformation[0].CC_Facility_Phone_Number__c;
                providerLicenseLargeGroupInformationRecord.facilityDirector = accountList[0].CC_Facility_Director__c;
                providerLicenseLargeGroupInformationRecord.alternatePhoneNumber = accountList[0].CC_Alternate_Phone_Number__c;
                // providerLicenseLargeGroupInformationRecord.alternatePhoneType = accountList[0].CC_Alternate_Phone_Type__c;
                providerLicenseLargeGroupInformationRecord.fax = accountList[0].Fax;
                providerLicenseLargeGroupInformationRecord.businessAdmin = accountList[0].parent.CC_Business_Admin__c;
                providerLicenseLargeGroupInformationRecord.businessFEIN = accountList[0].parent.CC_FIEN__c;
                providerLicenseLargeGroupInformationRecord.accountFEIN = accountList[0].CC_FIEN__c;
                providerLicenseLargeGroupInformationRecord.accountSSN = accountList[0].CC_SSN__c;
                providerLicenseLargeGroupInformationRecord.doesBusinessHasAFictitiousName = accountList[0].parent.CC_Does_business_use_fictitious_name__c;
                // Owner Co Owner
                providerLicenseLargeGroupInformationRecord.ownerCoOwnerPresentInFacility = applicationInformation[0].CC_Owner_Co_Owner_Present_In_Facility__c;
                
                //
                
                
                
                providerLicenseLargeGroupInformationRecord.businessType = accountList[0].parent.CC_BusinessType__c;
                providerLicenseLargeGroupInformationRecord.isBusinessRegisteredSOS = accountList[0].parent.CC_BusinessRegisteredWithSoS__c;
                providerLicenseLargeGroupInformationRecord.fictitiousNameOptionsRegisteredWithSOS  = accountList[0].parent.CC_Is_fictitious_name_registered_wit_SOS__c;
                providerLicenseLargeGroupInformationRecord.dateofIncorporation=applicationInformation[0].CC_Date_of_Incorporation__c;
                providerLicenseLargeGroupInformationRecord.placeofIncorporation=applicationInformation[0].CC_Place_of_Incorporation__c;
                providerLicenseLargeGroupInformationRecord.preferredCommunicationLanguage=applicationInformation[0].CC_Preferred_Communication_Language__c;
                providerLicenseLargeGroupInformationRecord.canYouCommunicateEnglish=applicationInformation[0].CC_Can_you_Communicate_in_English__c;
                providerLicenseLargeGroupInformationRecord.professionalQualificationRegisteredNumber=applicationInformation[0].CC_Professional_Qualification_Number__c;
                providerLicenseLargeGroupInformationRecord.professionalQualificationExpirationDate=applicationInformation[0].CC_Professional_Qualification_ExpiryDate__c;
                providerLicenseLargeGroupInformationRecord.dateCompletedPPTPart1=applicationInformation[0].CC_Date_Completed_PPT_Part_1__c;
                providerLicenseLargeGroupInformationRecord.dateCompletedPPTPart2=applicationInformation[0].CC_Date_Completed_PPT_Part_2__c;
                involvementProfessionalExperienceWrapperRecord.homeState=accountList[0].BillingState;
                // upendra  // S-76681
                // List<CC_ApplicationWrapper.ContactRoleRelationWrapper> listoFContactRoleRelation = new List<CC_ApplicationWrapper.ContactRoleRelationWrapper>();
                CC_ApplicationWrapper.ContactRoleRelationWrapper ownerInfo = new CC_ApplicationWrapper.ContactRoleRelationWrapper();
                CC_ApplicationWrapper.ContactRoleRelationWrapper coOwnerInfo = new CC_ApplicationWrapper.ContactRoleRelationWrapper();
                CC_ApplicationWrapper.ContactRoleRelationWrapper directorInfo = new CC_ApplicationWrapper.ContactRoleRelationWrapper();
                CC_ApplicationWrapper.DirectorInformationWrapper directorCredential = new CC_ApplicationWrapper.DirectorInformationWrapper();
                List<CC_ApplicationWrapper.DirectorInformationWrapper> directorInformationWrapperDetails = new List<CC_ApplicationWrapper.DirectorInformationWrapper>();
                
                CC_ApplicationWrapper.AddressDetails directorAddressDetail = new CC_ApplicationWrapper.AddressDetails();
                // list<CC_Contact_Role_Relationship__c> contactRoleRecords= Copy_CC_NoSharing_DAO.fetchCrrListByFacilityId(applicationInformation[0].BusinessAccountNameId);
                
                // for(CC_Contact_Role_Relationship__c itccr : contactRoleRFetched) {
                //     if(itccr.CC_Role__c == CC_Constants.CONTCAT_OWNER_ROLE){
                        
                //         ownerInfo.crrRole = itccr.CC_Role__c !=null?itccr.CC_Role__c:'';
                //         ownerInfo.crrFirstName = itccr.CC_Contact__r?.FirstName !=null ? itccr.CC_Contact__r.FirstName:'';
                //         ownerInfo.crrLastname = itccr.CC_Contact__r?.LastName !=null ? itccr.CC_Contact__r.LastName:'';
                //         // ownerInfo.crrJobType = itccr?.lastname !=null ? itccr.lastname;:'';
                //         ownerInfo.crrEmail = itccr.CC_Contact__r?.Email !=null ? itccr.CC_Contact__r.Email:'';
                //         ownerInfo.crrMiddleName = itccr.CC_Contact__r?.MiddleName !=null ? itccr.CC_Contact__r.MiddleName:'';
                //         ownerInfo.crrPhone = itccr.CC_Contact__r?.Phone !=null ? itccr.CC_Contact__r.Phone:'';
                //         ownerInfo.otherPhone = itccr.CC_Contact__r?.OtherPhone !=null ? itccr.CC_Contact__r.OtherPhone:'';
                //         ownerInfo.alternatePhone = itccr.CC_Contact__r.Account?.CC_Alternate_Phone_Number__c !=null? itccr.CC_Contact__r.Account.CC_Alternate_Phone_Number__c:'';
                //     }
                //     if(itccr.CC_Role__c == CC_Constants.CONTCAT_CO_OWNER_ROLE){
                        
                //         coOwnerInfo.crrRole = itccr.CC_Role__c !=null?itccr.CC_Role__c:'';
                //         coOwnerInfo.crrFirstName = itccr.CC_Contact__r?.FirstName !=null? itccr.CC_Contact__r.FirstName:'';
                //         coOwnerInfo.crrLastname = itccr.CC_Contact__r?.LastName !=null? itccr.CC_Contact__r.LastName:'';
                //         // coOwnerInfo.crrJobType = itccr?.lastname !=null? itccr.lastname:'';
                //         coOwnerInfo.crrEmail = itccr.CC_Contact__r?.Email !=null? itccr.CC_Contact__r.Email:'';
                //         coOwnerInfo.crrMiddleName = itccr.CC_Contact__r?.MiddleName !=null? itccr.CC_Contact__r.MiddleName:'';
                //         coOwnerInfo.crrPhone = itccr.CC_Contact__r?.Phone !=null? itccr.CC_Contact__r.Phone:'';
                //         coOwnerInfo.otherPhone = itccr.CC_Contact__r?.OtherPhone !=null? itccr.CC_Contact__r.OtherPhone:'';
                //         coOwnerInfo.alternatePhone = itccr.CC_Contact__r.Account?.CC_Alternate_Phone_Number__c !=null? itccr.CC_Contact__r.Account.CC_Alternate_Phone_Number__c:'';
                        
                //     }
                //     if(itccr.CC_Role__c == CC_Constants.CONTCAT_FACILITY_OWNER_ROLE){
                        
                //         directorInformationWrapperRecord.directorRecId = CC_CommonUtility.performEncryption(itccr.CC_Contact__r.AccountId);
                //         // directorInformationWrapperRecord.degreeOrDiploma = itccr.CC_Contact__r?.Diploma_Degree__c !=null? itccr.CC_Contact__r.Diploma_Degree__c:'';
                //         // directorInformationWrapperRecord.highestLevelOfEducation = itccr.CC_Contact__r?.Higest_Level_of_Education__c !=null? itccr.CC_Contact__r.Higest_Level_of_Education__c:'';
                //         // directorInformationWrapperRecord.majorFieldOfStudy = itccr.CC_Contact__r?.Major_Field_of_Study__c !=null? itccr.CC_Contact__r.Major_Field_of_Study__c:'';
                //         directorInfo.crrFirstName = itccr.CC_Contact__r?.FirstName !=null? itccr.CC_Contact__r.FirstName:'';
                //         directorInfo.crrLastname = itccr.CC_Contact__r?.LastName !=null? itccr.CC_Contact__r.LastName:'';
                //         // coOwnerInfo.crrJobType = itccr?.lastname !=null? itccr.lastname:'';
                //         directorInfo.crrEmail = itccr.CC_Contact__r?.Email !=null? itccr.CC_Contact__r.Email:'';
                //         directorInfo.crrMiddleName = itccr.CC_Contact__r?.MiddleName !=null? itccr.CC_Contact__r.MiddleName:'';
                //         directorInfo.crrPhone = itccr.CC_Contact__r?.Phone !=null? itccr.CC_Contact__r.Phone:'';
                //         directorInfo.otherPhone = itccr.CC_Contact__r?.OtherPhone !=null? itccr.CC_Contact__r.OtherPhone:'';
                //         directorInfo.suffix = itccr.CC_Contact__r?.CC_Suffix__c !=null? itccr.CC_Contact__r.CC_Suffix__c:'';
                //         directorInfo.alternatePhone = itccr.CC_Contact__r.Account?.CC_Alternate_Phone_Number__c !=null? itccr.CC_Contact__r.Account.CC_Alternate_Phone_Number__c:'';
                //         // add new field
                //         //directorInfo.crrBusinessEmail = itccr.CC_Contact__r?.Business_Email__c !=null? itccr.CC_Contact__r.Business_Email__c:'';
                //         //  directorInfo.crrPersonalEmail = itccr.CC_Contact__r?.Personal_Email__c !=null? itccr.CC_Contact__r.Personal_Email__c:'';
                //         // directorInfo.crrCellPhone = itccr.CC_Contact__r?.Cell_Phone__c !=null? itccr.CC_Contact__r.Cell_Phone__c:'';
                //         // directorInfo.crrHomePhone = itccr.CC_Contact__r?.Home_Phone__c !=null? itccr.CC_Contact__r.Home_Phone__c:'';
                //         // directorInfo.crrWokephone = itccr.CC_Contact__r?.Work_Phone__c !=null? itccr.CC_Contact__r.Work_Phone__c:'';
                //         directorInfo.crrPhoneType = itccr.CC_Contact__r?.Phone_Type__c !=null? itccr.CC_Contact__r.Phone_Type__c:'';
                //         directorInfo.crrEmailType = itccr.CC_Contact__r?.Email_Type__c !=null? itccr.CC_Contact__r.Email_Type__c:'';
                //         directorInfo.phoneNumber = directorInfo.crrPhoneType =='Home'?itccr.CC_Contact__r?.Phone
                //             : directorInfo.crrPhoneType =='Cell'?itccr.CC_Contact__r?.Phone
                //             :directorInfo.crrPhoneType =='Work'?itccr.CC_Contact__r?.Phone :'';
                //         directorInfo.emailAddresses   =   directorInfo.crrEmailType=='Business'?itccr.CC_Contact__r?.Email
                //             : directorInfo.crrEmailType=='Personal'?itccr.CC_Contact__r?.Email:'';
                //         directorAddressDetail.country   = itccr.CC_Contact__r.Account?.BillingCountryCode !=null? itccr.CC_Contact__r.Account.BillingCountryCode:'';
                        
                //         directorAddressDetail.street        = itccr.CC_Contact__r.Account?.BillingStreet !=null? itccr.CC_Contact__r.Account.BillingStreet:'';
                //         directorAddressDetail.zipCode       = itccr.CC_Contact__r.Account?.BillingPostalCode !=null? itccr.CC_Contact__r.Account.BillingPostalCode:'';
                //         directorAddressDetail.province      = itccr.CC_Contact__r.Account?.BillingStateCode !=null? itccr.CC_Contact__r.Account.BillingStateCode:'';
                //         directorAddressDetail.county        = itccr.CC_Contact__r.Account?.CC_County_Billing__c !=null? itccr.CC_Contact__r.Account.CC_County_Billing__c:'';
                //         directorAddressDetail.city          = itccr.CC_Contact__r.Account?.BillingCity !=null? itccr.CC_Contact__r.Account.BillingCity:'';
                //         directorAddressDetail.aptSuite = itccr.CC_Contact__r.account?.CC_Apt_Suite__c !=null? itccr.CC_Contact__r.account.CC_Apt_Suite__c:'';
                //     }
                //     providerLicenseLargeGroupInformationRecord.ownerInfo = ownerInfo;
                //     providerLicenseLargeGroupInformationRecord.coOwnerInfo = coOwnerInfo;
                // }
                // directorInformationWrapperRecord.directorInfo = directorInfo;
                directorInformationWrapperRecord.directorAddress = directorAddressDetail; 
                
                String directorAccId = CC_CommonUtility.performDecryption(directorInformationWrapperRecord.directorRecId);
                
                List<CC_Application_Specification__c> appSpecList = CC_ApplicationSpecificationDAO.fetchApplicationSpecificationsByTypes(applicationId, new List<String>{'Professional Credential', 'Degree', 'Employment'});
                List<CC_ApplicationWrapper.DirectorCredentials> credentialsList = new List<CC_ApplicationWrapper.DirectorCredentials>();
                List<CC_ApplicationWrapper.DirectorExpirences> experiencesList = new List<CC_ApplicationWrapper.DirectorExpirences>();
                
                for (CC_Application_Specification__c appSpec : appSpecList) {
                    if(appSpec.CC_Specification_Type__c == 'Degree'){
                        directorInformationWrapperRecord.highestLevelOfEducationPersonEducationD   = appSpec.Specification_Name__c;
                        directorInformationWrapperRecord.majorFieldOfStudyPersonEducationD         = appSpec.CC_Major__c != ''? appSpec.CC_Major__c:'';
                        directorInformationWrapperRecord.degreeOrDiplomaPersonEducationD           = appSpec.CC_Degree__c !=''? appSpec.CC_Degree__c:'';
                        directorInformationWrapperRecord.degreeId = CC_CommonUtility.performEncryption(appSpec.Id);
                    }
                    else if(appSpec.CC_Specification_Type__c == 'Professional Credential'){
                        CC_ApplicationWrapper.DirectorCredentials newCredential = new CC_ApplicationWrapper.DirectorCredentials();
                        newCredential.recordId                                  = appSpec.Id;
                        newCredential.certificateOrTrainingName                 = appSpec.Specification_Name__c;
                        newCredential.issuerOrganisation                        = appSpec.CC_Issuer_Organisation__c;
                        newCredential.expirationDate                            = appSpec.CC_Expiration_Date__c;
                        newCredential.issuedDate                                = appSpec.CC_Issuance_Date__c;
                        newCredential.neveExpires                               = appSpec.CC_Never_Expires__c;
                        credentialsList.add(newCredential);
                    }
                    else if(appSpec.CC_Specification_Type__c == 'Employment') {
                        CC_ApplicationWrapper.DirectorExpirences newExperience  = new CC_ApplicationWrapper.DirectorExpirences();
                        CC_ApplicationWrapper.AddressDetailsEmploye addr        = new CC_ApplicationWrapper.AddressDetailsEmploye();
                        newExperience.recordId = appSpec.Id;
                        newExperience.position      = appSpec.CC_Position__c;
                        newExperience.employerName  = appSpec.Specification_Name__c;
                        newExperience.empStartedate = appSpec.CC_Start_Date__c;
                        newExperience.empEndDate    = appSpec.CC_End_Date__c;
                        
                        newExperience.employerCity       = appSpec.CC_Address__City__s !=''? appSpec.CC_Address__City__s:'';
                        newExperience.employerCountry    = appSpec.CC_Address__CountryCode__s   !=''? appSpec.CC_Address__CountryCode__s:'';
                        newExperience.employerState           = appSpec.CC_Address__StateCode__s     !=''? appSpec.CC_Address__StateCode__s:'';
                        newExperience.employerStreet     = appSpec.CC_Address__Street__s    !=''? appSpec.CC_Address__Street__s:'';
                        newExperience.employerPostalCode            = appSpec.CC_Address__PostalCode__s !=''? appSpec.CC_Address__PostalCode__s:'';
                        newExperience.empStartedateSplit = String.valueOf(newExperience.empStartedate);
                        newExperience.empEndDateSplit = String.valueOf(newExperience.empEndDate);
                        newExperience.empEndAndStartDate = newExperience.empStartedateSplit.split(' ')[0] + ' - '+ newExperience.empEndDateSplit.split(' ')[0];
                        
                        newExperience.suit                   = appSpec.CC_Billing_Apt_Suite__c !=''? appSpec.CC_Billing_Apt_Suite__c:'';
                        newExperience.county                = appSpec.CC_Billing_County__c !=''? appSpec.CC_Billing_County__c:'';
                        
                        newExperience.employerAddressEmp = '';  // Initialize the employerAddressEmp
                        if (appSpec.CC_Address__c != null && appSpec.CC_Address__c.toString() != '') {
                            newExperience.employerAddressEmp = newExperience.employerStreet + ', ' +
                                newExperience.employerCity + ', ' +
                                newExperience.employerState;
                            if (newExperience.suit != null && newExperience.suit != '') {
                                newExperience.employerAddressEmp += ' ' + newExperience.suit;  // Adding Apt Suite
                            }
                            if (newExperience.county != null && newExperience.county != '') {
                                newExperience.employerAddressEmp += ' ' + newExperience.county;  // Adding County
                            }
                            newExperience.employerAddressEmp += ', ' +  newExperience.employerCountry;
                        }
                        experiencesList.add(newExperience); //
                    }
                }
                
                directorInformationWrapperRecord.directorCredentials = credentialsList;
                directorInformationWrapperRecord.directorExpirences = experiencesList;
                
            }
            if(applicationDetails!=null){
                applicationDetails.providerLicenseInformation=providerLicenseLargeGroupInformationRecord;
            }
            applicationDetails.facilityAdministrationInformation = new List<CC_ApplicationWrapper.FacilityAdministrationInformation>();
            if(applicationInformation.size()>0){
                //capacity information
                capacityInformationWrapperRecord.maximumAgeRequestedMonths = applicationInformation[0].CC_Maximum_Age_Limit_Requested_Years__c;
                capacityInformationWrapperRecord.maximumAgeRequestedYears = applicationInformation[0].CC_Maximum_Age_Limit_Requested_Years__c;
                capacityInformationWrapperRecord.minimumAgeRequestedMonths = applicationInformation[0].CC_Minimum_Age_Limit_Requested_Years__c;
                capacityInformationWrapperRecord.minimumAgeRequestedYears = applicationInformation[0].CC_Minimum_Age_Limit_Requested_Years__c;
                capacityInformationWrapperRecord.infantCapacity = applicationInformation[0].CC_Infant_Capacity__c;
                capacityInformationWrapperRecord.infantToddlerCapacity = applicationInformation[0].CC_Infant_Toddler_Capacity__c;
                capacityInformationWrapperRecord.toddlerCapacity = applicationInformation[0].CC_Toddler_Capacity__c;
                capacityInformationWrapperRecord.toddlerPreschoolCapacity = applicationInformation[0].CC_Toddler_Preschool_Capacity__c;
                capacityInformationWrapperRecord.preschoolCapacity = applicationInformation[0].CC_Preschool_Capacity__c;
                capacityInformationWrapperRecord.preschoolSchoolAgeCapacity = applicationInformation[0].CC_Preschool_SA_Capacity__c;
                capacityInformationWrapperRecord.schoolAgeCapacity = applicationInformation[0].CC_School_Age_Capacity__c;
                capacityInformationWrapperRecord.kindergartenCapacity = applicationInformation[0].CC_Kindergarten_Capacity__c;
                capacityInformationWrapperRecord.multiAgeGroupCapacity = applicationInformation[0].CC_Multi_Age_Group_Capacity__c;
                
                
                //operation information
                operationInformationWrapperRecord.operationType=applicationInformation[0].CC_Operation_Type__c;
                operationInformationWrapperRecord.dropInServiceProgramOption=applicationInformation[0].CC_Provide_Drop_In_Service__c;
                //operationInformationWrapperRecord.dropInServiceProgramDescription=applicationInformation[0]. CC_Drop_In_Service_Description__c;
                operationInformationWrapperRecord.eveningServiceOption=applicationInformation[0].CC_Provide_Evening_Service__c;
                operationInformationWrapperRecord.eveningServiceDescription=applicationInformation[0].CC_Evening_Service_Description__c;
                operationInformationWrapperRecord.summmerCampServiceOption=applicationInformation[0].CC_Provide_Summer_Camp_Service__c;
                operationInformationWrapperRecord.summmerCampServiceDescription=applicationInformation[0].CC_Summer_Camp_Service_Description__c;
                operationInformationWrapperRecord.dphSummerCampLicenseOption=applicationInformation[0].CC_DPH_Summer_Camp_License__c;
                
                //
                //Added By Gourav
                operationInformationWrapperRecord.facilityStartDate         =applicationInformation[0].Facility_Start_Date__c;
                operationInformationWrapperRecord.maxAge                    = Integer.valueOf(applicationInformation[0].CC_Maximum_Age_Limit_Requested_Years__c);
                operationInformationWrapperRecord.minimumAge                =  Integer.valueOf(applicationInformation[0].CC_Minimum_Age_Limit_Requested_Years__c);
                operationInformationWrapperRecord.numberOfInfants           =applicationInformation[0].CC_Infant_Capacity__c;
                operationInformationWrapperRecord.numberOfChilder           =applicationInformation[0].Number_of_children_for_who_care_provided__c;
                operationInformationWrapperRecord.numberOfYourOwnChildren   =applicationInformation[0].CC_Number_of_your_own_children__c;
                operationInformationWrapperRecord.specialNeedsExplanation   =applicationInformation[0].CC_Special_Needs_Explaination__c;
                
                //montana requirement
                operationInformationWrapperRecord.marshalCertficate = applicationInformation[0]?.CC_Do_you_have_Fire_Marshal_Certificate__c;
                operationInformationWrapperRecord.dateOfInspection = applicationInformation[0]?.CC_Date_of_Inspection_Fire_Marshal__c;
                operationInformationWrapperRecord.nameOfFireMarshal = applicationInformation[0]?.CC_Name_of_FireMarshal__c;
                operationInformationWrapperRecord.departmentCertification = applicationInformation[0]?.CC_Do_have_Health_Department_Certificate__c;
                operationInformationWrapperRecord.dateOfInspectionDep = applicationInformation[0]?.CC_Date_of_Inspection_Health_Cert__c;
                operationInformationWrapperRecord.nameOfFireMarshalDep = applicationInformation[0]?.CC_Name_of_FireMarshal_Health_Dept_Cert__c;
                
                //indoor outdoor information
                indoorOutdoorInformationWrapperRecord.indoorSquareFootOperations=applicationInformation[0].CC_Indoor_square_foot_for_operations__c;
                indoorOutdoorInformationWrapperRecord.numberOfToilets=applicationInformation[0].CC_Number_of_toilets__c;
                indoorOutdoorInformationWrapperRecord.numberOfSinks=applicationInformation[0].CC_Number_of_Sinks__c;
                
                indoorOutdoorInformationWrapperRecord.maximumBuildingCapacity=applicationInformation[0].CC_Maximum_Building_Capacity__c;
                
                
                //sixhome indoor outdoor information
                
                indoorOutdoorInformationWrapperRecord.technicalAssitanceDescription=applicationInformation[0].CC_Heating_Unit_Assitance_Description__c;
                
                
                //sixhome license status capacity Record information
                licenseStatusCapacityWrapperRecord.processOfFosterCareProvider=applicationInformation[0].CC_In_Process_to_a_Foster_Provider__c;
                licenseStatusCapacityWrapperRecord.operatedByYouOrOther=applicationInformation[0].CC_Business_operate_by_self_or_house_mem__c;
                licenseStatusCapacityWrapperRecord.operatedByYouOrOtherDesc=applicationInformation[0].CC_Business_operation_owner_Description__c;
                
                //sixhome license involvement record info
                involvementProfessionalExperienceWrapperRecord.previousInvolveDueToUnlicensedCare=applicationInformation[0].CC_Past_Involvement_Due_Unlicensed_Care__c;
                involvementProfessionalExperienceWrapperRecord.previousInvolveDueToUnlicensedCareDesc=applicationInformation[0].CC_Past_Involvement_Description__c;
                involvementProfessionalExperienceWrapperRecord.appliedOrIssuedCertByDEEC=applicationInformation[0].CC_Applied_Or_Issued_Certificate_by_DEEC__c;
                involvementProfessionalExperienceWrapperRecord.otherStateAppliedOrIssuedCert=applicationInformation[0].CC_Issued_Applied_Other_State_Certi__c;
                involvementProfessionalExperienceWrapperRecord.anyCertDeniedRevokeSuspend=applicationInformation[0].CC_License_Certificate_Denied_Revoked__c;
                involvementProfessionalExperienceWrapperRecord.anyCertDeniedRevokeSuspendDesc=applicationInformation[0].CC_Revoked_Certi_License_Description__c;
                involvementProfessionalExperienceWrapperRecord.employmentHistoryDesc=applicationInformation[0].CC_Employment_History_Description__c;
                
                
                //sixhome license background info
                backgroundInformationWrapperRecord.anyMemberArrested=applicationInformation[0].CC_Any_Member_Arrested_or_Charged__c;
                backgroundInformationWrapperRecord.anyMemberDealingWithChild=applicationInformation[0].CC_Any_member_Dealing_with_Child_Protect__c;
                backgroundInformationWrapperRecord.anyMemberDealingWithChildDesc=applicationInformation[0].CC_Member_Child_Protection_Description__c;
                backgroundInformationWrapperRecord.anyMemberResgisteredSxOffender=applicationInformation[0].CC_Any_Member_Registered_Sex_Offender__c;
                backgroundInformationWrapperRecord.anyMemberResgisteredSxOffenderDesc=applicationInformation[0].CC_Member_Registered_Sex_Offender_Desc__c;
                backgroundInformationWrapperRecord.anyMemberHadRestrainingOrder=applicationInformation[0].CC_Any_member_had_Restraining_Order__c;
                backgroundInformationWrapperRecord.anyMemberHadRestrainingOrderDesc=applicationInformation[0].CC_Member_Restraining_Order_Description__c;
                backgroundInformationWrapperRecord.useAlcoholOrDrugs=applicationInformation[0].CC_Use_Alcohol_Narcotics_or_Drugs__c;
                backgroundInformationWrapperRecord.useAlcoholOrDrugsDescription=applicationInformation[0].CC_Alcohol_Narcotics_Drugs_Description__c;
                backgroundInformationWrapperRecord.anyMemberAbusedOrNeglectedAChild=applicationInformation[0].CC_Any_member_Abused_Neglected_Child__c;
                backgroundInformationWrapperRecord.anyMemberAbusedOrNeglectedAChildDesc=applicationInformation[0].CC_Abused_Neglected_Child_Description__c;
                
                //child care and family care declartion step fields
                declartionParInfoWrapperRecord.montanaOrOtherRadioValue = applicationInformation[0].Have_you_been_licensed_to_care_for_child__c;
                //declartionParInfoWrapperRecord.licensedregistereddate = applicationInformation[0].When_were_you_licensed_or_registered__c!=null?applicationInformation[0].When_were_you_licensed_or_registered__c:null;
                declartionParInfoWrapperRecord.licensedregistereddate = applicationInformation[0].When_were_you_licensed_or_registered__c;
                
                declartionParInfoWrapperRecord.previousFacilityLoactionStreet = applicationInformation[0].Previous_Facility_Location__Street__s;
                declartionParInfoWrapperRecord.previousFacilityLoactionCity = applicationInformation[0].Previous_Facility_Location__City__s;
                declartionParInfoWrapperRecord.previousFacilityLoactionState = applicationInformation[0].Previous_Facility_Location__StateCode__s;
                declartionParInfoWrapperRecord.previousFacilityLoactionZip = applicationInformation[0].Previous_Facility_Location__PostalCode__s;
                declartionParInfoWrapperRecord.previousFacilityLoactionCountry = applicationInformation[0].Previous_Facility_Location__CountryCode__s;
                declartionParInfoWrapperRecord.previousFacilityLoactionCounty = applicationInformation[0].CC_Facility_Mailing_County__c;
                declartionParInfoWrapperRecord.previousFacilityLoactionApt = applicationInformation[0].CC_Facility_Mailing_Apt_Suit__c;
                
                declartionParInfoWrapperRecord.deniedLicenseRadioValue = applicationInformation[0].Denied_or_revoked_child_care_license__c;
                declartionParInfoWrapperRecord.childremovedRadioValue = applicationInformation[0].Have_you_or_your_Center_faced_abuse_inve__c;
                declartionParInfoWrapperRecord.convictedRadioValue = applicationInformation[0].Have_you_or_anyone_here_been_convicted__c;
                declartionParInfoWrapperRecord.felonyorRadioValue = applicationInformation[0].Have_you_or_anyone_convicted_to_felonyo__c;
                declartionParInfoWrapperRecord.perpetratorRadioValue = applicationInformation[0].Have_you_or_anyone_named_as_a_perpetrato__c;
                declartionParInfoWrapperRecord.abuseRadioValue = applicationInformation[0].Any_convictions_for_abuse_or_neglect__c;
                declartionParInfoWrapperRecord.residedRadioValue = applicationInformation[0].Have_you_lived_in_another_state_recently__c;
                declartionParInfoWrapperRecord.facilityName = applicationInformation[0].Facility_Name__c;
                declartionParInfoWrapperRecord.relationshipwithChild = applicationInformation[0].What_is_your_relationship_with_the_child__c;
                declartionParInfoWrapperRecord.whenWhereandWhy = applicationInformation[0].When_Where_and_Why__c;
                declartionParInfoWrapperRecord.whenandwherethisoccured = applicationInformation[0].Where_and_when_did_this_occur__c;
                declartionParInfoWrapperRecord.pleaseExplainone = applicationInformation[0].Please_Explain_One__c;
                declartionParInfoWrapperRecord.pleaseExplaintwo = applicationInformation[0].Please_Explain_Two__c;
                
                //family care declartion step fields
                declartionParInfoWrapperRecord.deniallicenserevocation = applicationInformation[0].Application_denial_or_license_revocation__c;
                declartionParInfoWrapperRecord.childremovedRadioValueCFS = applicationInformation[0].Have_you_ever_had_a_child_removed_by_CFS__c;
                declartionParInfoWrapperRecord.abuseorNeglectanAdultRadioValue = applicationInformation[0].Any_abuse_or_neglect_investigation__c;
                declartionParInfoWrapperRecord.whenandwheredatethisoccured = applicationInformation[0].Where_and_when_date_did_this_happen__c;
                //declartionParInfoWrapperRecord.chargesconvictedRadioValue = applicationInformation[0].Criminal_charges_against_family__c;
                declartionParInfoWrapperRecord.durgfelonyorRadioValue = applicationInformation[0].Drug_or_felony_conviction__c;
                declartionParInfoWrapperRecord.typeofRegistration = applicationInformation[0].What_type_of_regis_or_lic_did_you_have__c;
                
                /* groupFamilyDeclartionParInfoWrapperRecord.whenWhereandWhy = applicationInformation[0].Application_denial_or_license_revocation__c;
                groupFamilyDeclartionParInfoWrapperRecord.childremovedRadioValue = applicationInformation[0].Have_you_ever_had_a_child_removed_by_CFS__c;
                groupFamilyDeclartionParInfoWrapperRecord.abuseorNeglectanAdultRadioValue = applicationInformation[0].Any_abuse_or_neglect_investigation__c;
                groupFamilyDeclartionParInfoWrapperRecord.whenandwherethisoccured = applicationInformation[0].Where_and_when_date_did_this_happen__c;
                groupFamilyDeclartionParInfoWrapperRecord.convictedRadioValue = applicationInformation[0].Criminal_charges_against_family__c;
                groupFamilyDeclartionParInfoWrapperRecord.felonyorRadioValue = applicationInformation[0].Drug_or_felony_conviction__c;*/
                    
            }
            applicationDetails.applicationId = CC_CommonUtility.performEncryption(applicationId);
            applicationDetails.directorInformation = directorInformationWrapperRecord;
            applicationDetails.capacityInformation = capacityInformationWrapperRecord;
            applicationDetails.operationInformation=operationInformationWrapperRecord;
            applicationDetails.indoorOutdoorInformation=indoorOutdoorInformationWrapperRecord;
            applicationDetails.licenseStatusCapacityInformation=licenseStatusCapacityWrapperRecord;
            applicationDetails.involvementProfessionalExperienceInformation=involvementProfessionalExperienceWrapperRecord;
            applicationDetails.backgroundInformation=backgroundInformationWrapperRecord;
            applicationDetails.currentStepNumber = applicationInformation[0].CC_Active_Application_Step__c;
            applicationDetails.submittedBy = applicationInformation[0].CC_Submitted_By__c!=null?applicationInformation[0].CC_Submitted_By__c:null;
            applicationDetails.rejectionStatus = applicationInformation[0].CC_Rejection_Reason__c!=null?applicationInformation[0].CC_Rejection_Reason__c:'-';
            applicationDetails.ageGreaterOptedCare = applicationInformation[0].Anyone_age_18_Living_at_Care_Location__c!=null?applicationInformation[0].Anyone_age_18_Living_at_Care_Location__c:'-';
            
            //declartion step fields
            applicationDetails.declartionParInfo = declartionParInfoWrapperRecord;
            
            
            return applicationDetails;
        } catch(Exception e){
                throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
            
        }
    }
    
    /**
     * This is an Apex method named "saveApplicationData" that is annotated with "@AuraEnabled".
     * It takes a parameter "applicationDetails" of type String.
     * The method saves the application data by deserializing the "applicationDetails" parameter into an instance of the "CC_ApplicationWrapper.ApplicationDataWrapper" class.
     * It then updates various fields of the "PreliminaryApplicationRef" object based on the deserialized data.
     * The method also handles the insertion and deletion of related "CC_Application_Contact_Schedule__c" records.
     * If the "providerLicenseInformation" field of the deserialized data is not null, it updates the related "CC_Application_Contact__c" and "Account" records.
     * The method uses savepoints and handles exceptions by rolling back the transaction and throwing a custom exception.
     */
    @AuraEnabled
    public static void saveApplicationData(String applicationDetails){
        Savepoint sp = Database.setSavepoint();
        try {
            CC_ApplicationWrapper.ApplicationDataWrapper applicationWrapper = (CC_ApplicationWrapper.ApplicationDataWrapper)JSON.deserialize(applicationDetails,CC_ApplicationWrapper.ApplicationDataWrapper.class);
            
            
            String applicationId = CC_CommonUtility.performDecryption(applicationWrapper.applicationId);
            string accountId;
            List<PreliminaryApplicationRef> toBeUpdatedApplicationList = new List<PreliminaryApplicationRef>();
            List<Account> toBeUpdatedAccountList=new List <Account>();
            PreliminaryApplicationRef applicationRecord = CC_PreliminaryApplicationRefDAO.fetchApplicationRecord(applicationId);
            accountId=applicationRecord.BusinessAccountNameId;
            
            //saving capacity Information
            if(applicationWrapper.capacityInformation!=null){
                applicationRecord.CC_Maximum_Age_Limit_Requested_Years__c = applicationWrapper.capacityInformation.maximumAgeRequestedYears;
                applicationRecord.CC_Minimum_Age_Limit_Requested_Years__c = applicationWrapper.capacityInformation.minimumAgeRequestedYears;
                applicationRecord.CC_Infant_Toddler_Capacity__c = applicationWrapper.capacityInformation.infantToddlerCapacity;
                applicationRecord.CC_Toddler_Capacity__c = applicationWrapper.capacityInformation.toddlerCapacity;
                applicationRecord.CC_Toddler_Preschool_Capacity__c = applicationWrapper.capacityInformation.toddlerPreschoolCapacity;
                applicationRecord.CC_Preschool_Capacity__c = applicationWrapper.capacityInformation.preschoolCapacity;
                applicationRecord.CC_Preschool_SA_Capacity__c = applicationWrapper.capacityInformation.preschoolSchoolAgeCapacity;
                applicationRecord.CC_School_Age_Capacity__c = applicationWrapper.capacityInformation.schoolAgeCapacity;
                applicationRecord.CC_Kindergarten_Capacity__c = applicationWrapper.capacityInformation.kindergartenCapacity;
                applicationRecord.CC_Multi_Age_Group_Capacity__c = applicationWrapper.capacityInformation.multiAgeGroupCapacity;
                applicationRecord.CC_License_Capacity_Requested__c = applicationWrapper.capacityInformation.totalCapacityRequested;
            }
            
            //operation Information
            if(applicationWrapper.operationInformation!=null){
                applicationRecord.CC_Operation_Type__c = applicationWrapper.operationInformation.operationType;
                applicationRecord.CC_Provide_Drop_In_Service__c = applicationWrapper.operationInformation.dropInServiceProgramOption;
                applicationRecord.CC_Drop_In_Service_Description__c = applicationWrapper.operationInformation.dropInServiceProgramDescription;
                applicationRecord.CC_Provide_Evening_Service__c = applicationWrapper.operationInformation.eveningServiceOption;
                applicationRecord.CC_Evening_Service_Description__c = applicationWrapper.operationInformation.eveningServiceDescription;
                applicationRecord.CC_Provide_Summer_Camp_Service__c = applicationWrapper.operationInformation.summmerCampServiceOption;
                applicationRecord.CC_Summer_Camp_Service_Description__c = applicationWrapper.operationInformation.summmerCampServiceDescription;
                applicationRecord.CC_DPH_Summer_Camp_License__c = applicationWrapper.operationInformation.dphSummerCampLicenseOption;
                
                //montana requirement
                applicationRecord.CC_Do_you_have_Fire_Marshal_Certificate__c = applicationWrapper.operationInformation?.marshalCertficate;
                applicationRecord.CC_Date_of_Inspection_Fire_Marshal__c = applicationWrapper.operationInformation?.dateOfInspection;
                applicationRecord.CC_Name_of_FireMarshal__c = applicationWrapper.operationInformation?.nameOfFireMarshal;
                applicationRecord.CC_Do_have_Health_Department_Certificate__c = applicationWrapper.operationInformation?.departmentCertification;
                applicationRecord.CC_Date_of_Inspection_Health_Cert__c = applicationWrapper.operationInformation?.dateOfInspectionDep;
                applicationRecord.CC_Name_of_FireMarshal_Health_Dept_Cert__c = applicationWrapper.operationInformation?.nameOfFireMarshalDep;
                
                
                
                
                //CC_Infant_Capacity__c
                applicationRecord.Facility_Start_Date__c                        =applicationWrapper.operationInformation.facilityStartDate;
                applicationRecord.CC_Maximum_Age_Limit_Requested_Years__c      =applicationWrapper.operationInformation.maxAge;
                applicationRecord.CC_Minimum_Age_Limit_Requested_Years__c      =applicationWrapper.operationInformation.minimumAge;
                applicationRecord.Number_of_children_for_who_care_provided__c   =applicationWrapper.operationInformation.numberOfChilder;
                applicationRecord.CC_Infant_Capacity__c                         =applicationWrapper.operationInformation.numberOfInfants;
                applicationRecord.CC_Number_of_your_own_children__c             =applicationWrapper.operationInformation.numberOfYourOwnChildren;
                applicationRecord.CC_Special_Needs_Explaination__c               =applicationWrapper.operationInformation.specialNeedsExplanation;
                
                
                
                
                
                
                applicationRecord.CC_Camp_Permit_Number__c = applicationWrapper.operationInformation.campPermitNumber;
                applicationRecord.CC_Camp_Permit_Issue_Date__c = applicationWrapper.operationInformation.campPermitIssueDate;
                applicationRecord.CC_Ever_held_any_other_MTX_Licenses__c = applicationWrapper.operationInformation.heldOtherMtxLicensesOptions;
                applicationRecord.CC_Other_MTX_Licenses_Description__c = applicationWrapper.operationInformation.heldOtherMtxLicensesDescription;
                if(applicationWrapper.operationInformation.specificationType != null ){//&& applicationWrapper.operationInformation.schedulDaysTime != null
                    List<CC_ApplicationWrapper.ApplicationSpecificationsWrapper> newindividualschedulDaysTime = new List<CC_ApplicationWrapper.ApplicationSpecificationsWrapper>();
                    newindividualschedulDaysTime.add(applicationWrapper.operationInformation.individualschedulDaysTime);
                    
                    saveApplicationSpecifications(applicationWrapper.applicationId,newindividualschedulDaysTime, applicationWrapper.operationInformation.specificationType);
                }
            }
            
            //Indoor Outdoor Information + six home indoor outdoor information
            if(applicationWrapper.indoorOutdoorInformation!=null){
                applicationRecord.CC_Indoor_square_foot_for_operations__c = applicationWrapper.indoorOutdoorInformation.indoorSquareFootOperations;
                applicationRecord.CC_Number_of_toilets__c = applicationWrapper.indoorOutdoorInformation.numberOfToilets;
                applicationRecord.CC_Number_of_Sinks__c = applicationWrapper.indoorOutdoorInformation.numberOfSinks;
                applicationRecord.CC_Lead_Paint_Construction_built__c = applicationWrapper.indoorOutdoorInformation.leadPaintConstructionBuilt;
                applicationRecord.CC_Maximum_Building_Capacity__c = applicationWrapper.indoorOutdoorInformation.maximumBuildingCapacity;
                applicationRecord.CC_Building_Inspection_Expiration_Date__c = applicationWrapper.indoorOutdoorInformation.buildingInspectionExpirationDate;
                applicationRecord.CC_Health_Inspection_Expiration_Date__c = applicationWrapper.indoorOutdoorInformation.healthInspectionExpirationDate;
                applicationRecord.CC_Fire_Inspection_Issue_Date__c = applicationWrapper.indoorOutdoorInformation.fireInspectionIssueDate;
                applicationRecord.CC_Integrated_Pest_Management_Date__c = applicationWrapper.indoorOutdoorInformation.integratedPestManagementDate;
                applicationRecord.CC_Water_Supply_Source__c = applicationWrapper.indoorOutdoorInformation.waterSupplySource;
                applicationRecord.CC_Private_Water_Test_Date__c = applicationWrapper.indoorOutdoorInformation.privateWaterTestDate;
                applicationRecord.CC_PWS_Number__c = applicationWrapper.indoorOutdoorInformation.pwsNumber;
                applicationRecord.CC_Outdoor_Sq_Footage_for_Operations__c = applicationWrapper.indoorOutdoorInformation.outdoorSquareFootForOperations;
                applicationRecord.CC_have_a_pool__c = applicationWrapper.indoorOutdoorInformation.haveAPool;
                applicationRecord.CC_Offsite_Outdoor_Play_Location__c = applicationWrapper.indoorOutdoorInformation.offsiteOutdoorPlayLocation;
                applicationRecord.CC_Provide_Transportation__c = applicationWrapper.indoorOutdoorInformation.provideTransportation;
                applicationRecord.CC_Pool_Inspection_Date__c = applicationWrapper.indoorOutdoorInformation.poolInspectionDate;
                applicationRecord.CC_Is_this_an_Indoor_Pool__c = applicationWrapper.indoorOutdoorInformation.indoorPool;
                applicationRecord.CC_Latest_Pool_Roof_Inspection_Date__c = applicationWrapper.indoorOutdoorInformation.latestPoolRoofInspectionDate;
                applicationRecord.CC_Transport_means_to_Offsite_location__c = applicationWrapper.indoorOutdoorInformation.howGoThere;
                applicationRecord.CC_Transportation_Type__c = applicationWrapper.indoorOutdoorInformation.transportationType;
                applicationRecord.CC_Additional_Space_Req_Description__c = applicationWrapper.indoorOutdoorInformation.additionalSpaceRequirementDescription;
                applicationRecord.CC_Approval_for_additional_space__c = applicationWrapper.indoorOutdoorInformation.approvalForAdditionalSpace;
                
                //six home fields
                applicationRecord.CC_Residence_Description__c = applicationWrapper.indoorOutdoorInformation.indoorOutdoorDescription;
                applicationRecord.CC_Contains_atleast_Two_Exits__c = applicationWrapper.indoorOutdoorInformation.containTwoExits;
                applicationRecord.CC_Primary_Secondry_Exit_Description__c = applicationWrapper.indoorOutdoorInformation.twoExitsDescription;
                applicationRecord.CC_Use_Burning_Stoves_During_Child_Care__c = applicationWrapper.indoorOutdoorInformation.useBurningStoves;
                applicationRecord.CC_Burning_Stoves_Description__c = applicationWrapper.indoorOutdoorInformation.burningStoveDescription;
                applicationRecord.CC_Tech_Assist_Required_Heating_Unit__c = applicationWrapper.indoorOutdoorInformation.needTechnicalAssitance;
                applicationRecord.CC_Heating_Unit_Assitance_Description__c = applicationWrapper.indoorOutdoorInformation.technicalAssitanceDescription;
                if(applicationWrapper.indoorOutdoorInformation.specificationType != null && !(applicationWrapper.indoorOutdoorInformation.roomsInformation.isEmpty())){
                    saveApplicationSpecifications(applicationWrapper.applicationId, applicationWrapper.indoorOutdoorInformation.roomsInformation, applicationWrapper.indoorOutdoorInformation.specificationType);
                }
            }
            
            //Six Home License Status Capacity Information
            // Commented by Himani - Discussed with Pranay we are not using this on Montana
            // if(applicationWrapper.licenseStatusCapacityInformation!=null){
            //     applicationRecord.CC_Caring_For_Unrelated_Children__c = applicationWrapper.licenseStatusCapacityInformation.caringForUnrelatedChildren;
            //     applicationRecord.CC_Provide_Eve_Overnight_Weekend_Care__c = applicationWrapper.licenseStatusCapacityInformation.provideEveNightWeekendCare;
            //     applicationRecord.CC_Eve_Overnight_Weekend_Care_Desc__c = applicationWrapper.licenseStatusCapacityInformation.eveNightWeekendCareDesc;
            //     applicationRecord.CC_Any_children_Home_Schooled__c = applicationWrapper.licenseStatusCapacityInformation.anyHomeSchoolChildren;
            //     applicationRecord.CC_Any_children_Home_Schooled_Desc__c = applicationWrapper.licenseStatusCapacityInformation.homeSchoolChildrenDesc;
            //     applicationRecord.CC_Approved_Foster_care_Provider__c = applicationWrapper.licenseStatusCapacityInformation.approvedFosterCareProvider;
            //     applicationRecord.CC_Approved_Foster_care_Provider_Desc__c = applicationWrapper.licenseStatusCapacityInformation.approvedFosterCareProviderDesc;
            //     applicationRecord.CC_In_Process_to_a_Foster_Provider__c = applicationWrapper.licenseStatusCapacityInformation.processOfFosterCareProvider;
            //     applicationRecord.CC_Process_for_Foster_Provider_Desc__c = applicationWrapper.licenseStatusCapacityInformation.processOfFosterCareProviderDesc;
            //     applicationRecord.CC_Business_operate_by_self_or_house_mem__c = applicationWrapper.licenseStatusCapacityInformation.operatedByYouOrOther;
            //     applicationRecord.CC_Business_operation_owner_Description__c = applicationWrapper.licenseStatusCapacityInformation.operatedByYouOrOtherDesc;
                
            //     if(applicationWrapper.licenseStatusCapacityInformation.memberType != null && !applicationWrapper.licenseStatusCapacityInformation.childrenUnderCareInfo.isEmpty()){
            //         saveApplicationContacts(applicationWrapper.applicationId, applicationWrapper.licenseStatusCapacityInformation.childrenUnderCareInfo, applicationWrapper.licenseStatusCapacityInformation.memberType);
            //     }
            // }
            
            //Six Home involvement Professional Experience Information
            if(applicationWrapper.involvementProfessionalExperienceInformation!=null){
                applicationRecord.CC_Past_Involvement_Due_Unlicensed_Care__c = applicationWrapper.involvementProfessionalExperienceInformation.previousInvolveDueToUnlicensedCare;
                applicationRecord.CC_Past_Involvement_Description__c = applicationWrapper.involvementProfessionalExperienceInformation.previousInvolveDueToUnlicensedCareDesc;
                applicationRecord.CC_Applied_Or_Issued_Certificate_by_DEEC__c = applicationWrapper.involvementProfessionalExperienceInformation.appliedOrIssuedCertByDEEC;
                applicationRecord.CC_Issued_Applied_Other_State_Certi__c = applicationWrapper.involvementProfessionalExperienceInformation.otherStateAppliedOrIssuedCert;
                applicationRecord.CC_License_Certificate_Denied_Revoked__c = applicationWrapper.involvementProfessionalExperienceInformation.anyCertDeniedRevokeSuspend;
                applicationRecord.CC_Revoked_Certi_License_Description__c = applicationWrapper.involvementProfessionalExperienceInformation.anyCertDeniedRevokeSuspendDesc;
                applicationRecord.CC_Employment_History_Description__c = applicationWrapper.involvementProfessionalExperienceInformation.employmentHistoryDesc;
                
                if(applicationWrapper.involvementProfessionalExperienceInformation.specificationType != null && !applicationWrapper.involvementProfessionalExperienceInformation.licenseCertifications.isEmpty()){
                    saveApplicationSpecifications(applicationWrapper.applicationId, applicationWrapper.involvementProfessionalExperienceInformation.licenseCertifications, applicationWrapper.involvementProfessionalExperienceInformation.specificationType);
                }
            }
            
            
            //Six Home background Information Information
            if(applicationWrapper.backgroundInformation!=null){
                applicationRecord.CC_Any_Member_Arrested_or_Charged__c = applicationWrapper.backgroundInformation.anyMemberArrested;
                applicationRecord.CC_Any_member_Dealing_with_Child_Protect__c = applicationWrapper.backgroundInformation.anyMemberDealingWithChild;
                applicationRecord.CC_Member_Child_Protection_Description__c = applicationWrapper.backgroundInformation.anyMemberDealingWithChildDesc;
                applicationRecord.CC_Any_Member_Registered_Sex_Offender__c = applicationWrapper.backgroundInformation.anyMemberResgisteredSxOffender;
                applicationRecord.CC_Member_Registered_Sex_Offender_Desc__c = applicationWrapper.backgroundInformation.anyMemberResgisteredSxOffenderDesc;
                applicationRecord.CC_Any_member_had_Restraining_Order__c = applicationWrapper.backgroundInformation.anyMemberHadRestrainingOrder;
                applicationRecord.CC_Member_Restraining_Order_Description__c = applicationWrapper.backgroundInformation.anyMemberHadRestrainingOrderDesc;
                applicationRecord.CC_Use_Alcohol_Narcotics_or_Drugs__c = applicationWrapper.backgroundInformation.useAlcoholOrDrugs;
                applicationRecord.CC_Alcohol_Narcotics_Drugs_Description__c = applicationWrapper.backgroundInformation.useAlcoholOrDrugsDescription;
                applicationRecord.CC_Any_member_Abused_Neglected_Child__c = applicationWrapper.backgroundInformation.anyMemberAbusedOrNeglectedAChild;
                applicationRecord.CC_Abused_Neglected_Child_Description__c = applicationWrapper.backgroundInformation.anyMemberAbusedOrNeglectedAChildDesc;
                if(applicationWrapper.backgroundInformation.specificationType != null && !applicationWrapper.backgroundInformation.chargesInformation.isEmpty()){
                    saveApplicationSpecifications(applicationWrapper.applicationId, applicationWrapper.backgroundInformation.chargesInformation, applicationWrapper.backgroundInformation.specificationType);
                }
            }
            
            if(applicationWrapper.providerLicenseInformation!=null){
                applicationRecord.CC_Date_of_Incorporation__c = applicationWrapper.providerLicenseInformation.dateofIncorporation;
                applicationRecord.CC_Place_of_Incorporation__c = applicationWrapper.providerLicenseInformation.placeofIncorporation !=null?applicationWrapper.providerLicenseInformation.placeofIncorporation:'';
                applicationRecord.CC_Preferred_Communication_Language__c=applicationWrapper.providerLicenseInformation.preferredCommunicationLanguage;
                applicationRecord.CC_Can_you_Communicate_in_English__c=applicationWrapper.providerLicenseInformation.canYouCommunicateEnglish;
                applicationRecord.CC_Professional_Qualification_Number__c=applicationWrapper.providerLicenseInformation.professionalQualificationRegisteredNumber;
                applicationRecord.CC_Professional_Qualification_ExpiryDate__c=applicationWrapper.providerLicenseInformation.professionalQualificationExpirationDate;
                applicationRecord.CC_Date_Completed_PPT_Part_2__c=applicationWrapper.providerLicenseInformation.dateCompletedPPTPart2;
                applicationRecord.CC_Date_Completed_PPT_Part_1__c=applicationWrapper.providerLicenseInformation.dateCompletedPPTPart1;
                applicationRecord.CC_Owner_Co_Owner_Present_In_Facility__c = applicationWrapper.providerLicenseInformation.ownerCoOwnerPresentInFacility; //Payal
                // Commented by Himani - Discussed with Pranay we are not using this on Montana
                // if(applicationWrapper.providerLicenseInformation.memberType != null && !applicationWrapper.providerLicenseInformation.applicationContactInfo.isEmpty()){
                //     saveApplicationContacts(applicationWrapper.applicationId, applicationWrapper.providerLicenseInformation.applicationContactInfo, applicationWrapper.providerLicenseInformation.memberType);
                // }
            }
            
            if(applicationWrapper.declartionParInfo!=null){
                applicationRecord.Have_you_been_licensed_to_care_for_child__c = String.isNotBlank(applicationWrapper?.declartionParInfo?.montanaOrOtherRadioValue)?applicationWrapper?.declartionParInfo?.montanaOrOtherRadioValue:null;
                //applicationRecord.When_were_you_licensed_or_registered__c = applicationWrapper.declartionParInfo.licensedregistereddate!=null? Date.valueOf(applicationWrapper.declartionParInfo.licensedregistereddate) : null;
                applicationRecord.When_were_you_licensed_or_registered__c = applicationWrapper.declartionParInfo.licensedregistereddate;
                
                applicationRecord.Previous_Facility_Location__Street__s = String.isNotBlank(applicationWrapper.declartionParInfo.previousFacilityLoactionStreet)?applicationWrapper.declartionParInfo.previousFacilityLoactionStreet:null;
                applicationRecord.Previous_Facility_Location__City__s = String.isNotBlank(applicationWrapper.declartionParInfo.previousFacilityLoactionCity)?applicationWrapper.declartionParInfo.previousFacilityLoactionCity:null;
                applicationRecord.Previous_Facility_Location__StateCode__s = String.isNotBlank(applicationWrapper.declartionParInfo.previousFacilityLoactionState)?applicationWrapper.declartionParInfo.previousFacilityLoactionState:null;
                applicationRecord.Previous_Facility_Location__PostalCode__s = String.isNotBlank(applicationWrapper.declartionParInfo.previousFacilityLoactionZip)?applicationWrapper.declartionParInfo.previousFacilityLoactionZip:null;
                applicationRecord.CC_Facility_Mailing_County__c = String.isNotBlank(applicationWrapper.declartionParInfo.previousFacilityLoactionCounty)?applicationWrapper.declartionParInfo.previousFacilityLoactionCounty:null;
                applicationRecord.CC_Facility_Mailing_Apt_Suit__c = String.isNotBlank(applicationWrapper.declartionParInfo.previousFacilityLoactionApt)?applicationWrapper.declartionParInfo.previousFacilityLoactionApt:null;
                
                applicationRecord.Previous_Facility_Location__CountryCode__s = String.isNotBlank(applicationWrapper.declartionParInfo.previousFacilityLoactionCountry)?applicationWrapper.declartionParInfo.previousFacilityLoactionCountry:null;
                applicationRecord.Denied_or_revoked_child_care_license__c = String.isNotBlank(applicationWrapper.declartionParInfo.deniedLicenseRadioValue)?applicationWrapper.declartionParInfo.deniedLicenseRadioValue:null;
                applicationRecord.Have_you_or_your_Center_faced_abuse_inve__c = String.isNotBlank(applicationWrapper.declartionParInfo.childremovedRadioValue)?applicationWrapper.declartionParInfo.childremovedRadioValue:null;
                applicationRecord.Have_you_or_anyone_here_been_convicted__c = String.isNotBlank(applicationWrapper.declartionParInfo.convictedRadioValue)?applicationWrapper.declartionParInfo.convictedRadioValue:null;
                applicationRecord.Have_you_or_anyone_convicted_to_felonyo__c = String.isNotBlank(applicationWrapper.declartionParInfo.felonyorRadioValue)?applicationWrapper.declartionParInfo.felonyorRadioValue:null;
                applicationRecord.Have_you_or_anyone_named_as_a_perpetrato__c = String.isNotBlank(applicationWrapper.declartionParInfo.perpetratorRadioValue)?applicationWrapper.declartionParInfo.perpetratorRadioValue:null;
                applicationRecord.Any_convictions_for_abuse_or_neglect__c = String.isNotBlank(applicationWrapper.declartionParInfo.abuseRadioValue)?applicationWrapper.declartionParInfo.abuseRadioValue:null;
                applicationRecord.Have_you_lived_in_another_state_recently__c = String.isNotBlank(applicationWrapper.declartionParInfo.residedRadioValue)?applicationWrapper.declartionParInfo.residedRadioValue:null;
                applicationRecord.Facility_Name__c = String.isNotBlank(applicationWrapper.declartionParInfo.facilityName)?applicationWrapper.declartionParInfo.facilityName:null;
                applicationRecord.What_is_your_relationship_with_the_child__c = String.isNotBlank(applicationWrapper.declartionParInfo.relationshipwithChild)?applicationWrapper.declartionParInfo.relationshipwithChild:null;
                applicationRecord.When_Where_and_Why__c = String.isNotBlank(applicationWrapper.declartionParInfo.whenWhereandWhy)?applicationWrapper.declartionParInfo.whenWhereandWhy:null;
                applicationRecord.Where_and_when_did_this_occur__c = String.isNotBlank(applicationWrapper.declartionParInfo.whenandwherethisoccured)?applicationWrapper.declartionParInfo.whenandwherethisoccured:null;
                applicationRecord.Please_Explain_One__c = String.isNotBlank(applicationWrapper.declartionParInfo.pleaseExplainone)?applicationWrapper.declartionParInfo.pleaseExplainone:null;
                applicationRecord.Please_Explain_Two__c = String.isNotBlank(applicationWrapper.declartionParInfo.pleaseExplaintwo)?applicationWrapper.declartionParInfo.pleaseExplaintwo:null;
                
                applicationRecord.Application_denial_or_license_revocation__c = String.isNotBlank(applicationWrapper.declartionParInfo.deniallicenserevocation)?applicationWrapper.declartionParInfo.deniallicenserevocation:null;
                applicationRecord.Have_you_ever_had_a_child_removed_by_CFS__c = String.isNotBlank(applicationWrapper.declartionParInfo.childremovedRadioValueCFS)?applicationWrapper.declartionParInfo.childremovedRadioValueCFS:null;
                applicationRecord.Any_abuse_or_neglect_investigation__c = String.isNotBlank(applicationWrapper.declartionParInfo.abuseorNeglectanAdultRadioValue)?applicationWrapper.declartionParInfo.abuseorNeglectanAdultRadioValue:null;
                applicationRecord.Where_and_when_date_did_this_happen__c = String.isNotBlank(applicationWrapper.declartionParInfo.whenandwheredatethisoccured)?applicationWrapper.declartionParInfo.whenandwheredatethisoccured:null;
                //applicationRecord.Criminal_charges_against_family__c = String.isNotBlank(applicationWrapper.declartionParInfo.whenandwheredatethisoccured)?applicationWrapper.declartionParInfo.whenandwheredatethisoccured:null;
                applicationRecord.Drug_or_felony_conviction__c = String.isNotBlank(applicationWrapper.declartionParInfo.durgfelonyorRadioValue)?applicationWrapper.declartionParInfo.durgfelonyorRadioValue:null;
                applicationRecord.What_type_of_regis_or_lic_did_you_have__c = String.isNotBlank(applicationWrapper.declartionParInfo.typeofRegistration)?applicationWrapper.declartionParInfo.typeofRegistration:null;
                
            }
            if(applicationWrapper.ageGreaterOptedCare != null){
                applicationRecord.Anyone_age_18_Living_at_Care_Location__c = String.isNotBlank(applicationWrapper.ageGreaterOptedCare) ?applicationWrapper.ageGreaterOptedCare:null;
            }
            if(applicationWrapper.floorPlanInfromation != null){
                applicationRecord.CC_Date_of_Measurement__c = applicationWrapper.floorPlanInfromation.dateOfMeasurement != null ? Date.valueOf(applicationWrapper.floorPlanInfromation.dateOfMeasurement) : null;
                system.debug('mesurment' + applicationRecord.CC_Date_of_Measurement__c);
            }
            
            toBeUpdatedApplicationList.add(applicationRecord);
            if(toBeUpdatedApplicationList.size()>0){
                CC_DML.doUpdate(toBeUpdatedApplicationList, false);
            }
        }catch(Exception e){
            // System.assert(false,'Message----->' +e.getMessage()+ 'Line ----->' +e.getlinenumber());
            Database.rollback(sp);
            String errMsg = e.getMessage();
            // if (errMsg.contains('STRING_TOO_LONG')) {
            //     errMsg = CC_Constants.STRING_TOO_LONG;
                
            // }
            
                throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
    }
    
    /**
     * @description
     * @author Rohan Rana | 05-23-2024
     * @param encryptedAppId
     * @return Map<String, Object>
     **/
    @AuraEnabled
    public static Map<String,Object> getRecordTypeCorrectPage(String encryptedAppId){
        try {
            Map<String,Object> result = new Map<String,Object>();
            String applicationId;
            List<PreliminaryApplicationRef> appList = new List<PreliminaryApplicationRef>();
            Integer expiryInDays;
            
            applicationId = CC_CommonUtility.performDecryption(encryptedAppId);
            if(encryptedAppId!=null){
                result.put('ApplicationId',CC_CommonUtility.performEncryption(applicationId));
                appList = CC_PreliminaryApplicationRefDAO.fetchPARByAppId(applicationId);
                if(!appList.isEmpty()){
                    Integer stepNumber = appList[0].CC_Active_Application_Step__c!= null?Integer.valueOf(appList[0].CC_Active_Application_Step__c):null;
                    result.put('stepNumber',stepNumber);
                    result.put('ratName', CC_PreliminaryApplicationRefDAO.fetchRATName(applicationId)[0].CC_Regulatory_Authorization_Type__r.Name);
                }
                if((!appList.isEmpty()) && appList[0].CC_Application_Status__c != null ){
                    if(appList[0].CC_Application_Status__c == CC_Constants.APPLICATION_STATUS_SUBMITTED){
                        if(!appList[0].BusinessLicenseApplicationSavedRef.isEmpty()){
                            result.put('Status',appList[0].BusinessLicenseApplicationSavedRef[0].CC_Application_External_Status__c);
                        }else if(!appList[0].IndividualApplicationAppRef.isEmpty()){
                            result.put('Status',appList[0].IndividualApplicationAppRef[0].CC_Application_External_Status__c);
                        }
                    }
                    else{
                        result.put('Status',appList[0].CC_Application_Status__c);
                    }
                }
            }
            return result;
        } catch(Exception e){
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
    }
    
    /**
     * This method submits an application for processing.
     *
     * @param appId The ID of the application to be submitted.
     * @param step The current step of the application.
     * @param signBy The name of the person who signed the application.
     * @param signDate The date when the application was signed.
     * @param action The action to be performed on the application.
     * @return The name of the submitted application.
     * @throws CC_Exception If there is an error during the submission process.
     */
    @AuraEnabled
    public static String submitApplication(String appId,Integer step,Integer finalStep) {
        Savepoint sp = Database.setSavepoint();
        try{
            if(appId != null ){
                appId = CC_CommonUtility.performDecryption(appId);
                Set<Id> appConId = new Set<Id>();
                List<PreliminaryApplicationRef> appToUpdateList = CC_PreliminaryApplicationRefDAO.fetchPARByAppId(appId);
                PreliminaryApplicationRef appToUpdate = appToUpdateList[0];
                appToUpdate.CC_Active_Application_Step__c = step;
                //Integer finalStep = 10;
                if(finalStep == (step-1)){
                    appToUpdate.CC_Submitted_Date__c = System.now();
                    appToUpdate.CC_Active_Application_Step__c = 1;
                    if(appToUpdate.CC_Application_Status__c == CC_Constants.APPLICATION_STATUS_DRAFT){
                        appToUpdate.CC_Application_Status__c = CC_Constants.APPLICATION_STATUS_SUBMITTED;
                        handleBLACreation(appId);
                    }else if(appToUpdate.CC_Application_Status__c == CC_Constants.APPLICATION_STATUS_SUBMITTED){
                        if(appToUpdate.ApplicationType == CC_Constants.APP_TYPE_BLA &&
                            !appToUpdate.BusinessLicenseApplicationSavedRef.isEmpty() &&
                        appToUpdate?.BusinessLicenseApplicationSavedRef[0].CC_Application_External_Status__c == CC_Constants.APPLICATION_STATUS_NEED_MORE_INFO){
                            handleAdditionalInfoRequest(appId);
                            processMemberListMain(appToUpdate.BusinessLicenseApplicationSavedRef[0], appToUpdate);
                            
                        }
                    }
                    
                }
                CC_DML.doUpdate(appToUpdate,false);
                
                return appToUpdate.Name;
                
            }
            return null;
        }catch(Exception e){
            Database.rollback(sp);
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
    }
    
    /**
     * @description
     * @author MTX Group Inc. | 06-11-2024
     * @param appId
     **/
    public static void handleAdditionalInfoRequest(String appId){
        List<CC_Application_Specification__c> additionalInfoRequestedRecord = CC_ApplicationSpecificationDAO.fetchInfoReqApplicationSpecificationsByParId(appId);
        List<CC_Document_Item__c> additionalInfoRequestedDoc = new List<CC_Document_Item__c>();
        if(!additionalInfoRequestedRecord.isEmpty()){
            List<CC_Application_Specification__c> updateAdditionalInfoRequestedRecordList = new List<CC_Application_Specification__c>();
            for(CC_Application_Specification__c inforReqRec : additionalInfoRequestedRecord){
                CC_Application_Specification__c appSpecRec = new CC_Application_Specification__c();
                appSpecRec.Id = inforReqRec.Id;
                appSpecRec.CC_Additional_Information_Status__c = CC_Constants.APPLICATION_SPECIFICATION_ADDITIONAL_INFO_STATUS_RESPONDED;
                
                if(inforReqRec?.Document_Items__r !=null && !inforReqRec.Document_Items__r.isEmpty()){
                    for(CC_Document_Item__c doc : inforReqRec.Document_Items__r){
                        if( doc.CC_Return_For_Revision_Requested__c){
                            additionalInfoRequestedDoc.add(new CC_Document_Item__c(
                                Id = doc.Id,
                            CC_Return_For_Revision_Requested__c = false
                                ));
                        }
                    }
                }
                updateAdditionalInfoRequestedRecordList.add(appSpecRec);
            }
            if(!updateAdditionalInfoRequestedRecordList.isEmpty()){
                CC_DML.doUpdate(updateAdditionalInfoRequestedRecordList,false);
            }
            if(!additionalInfoRequestedDoc.isEmpty()){
                CC_DML.doUpdate(additionalInfoRequestedDoc,false);
            }
        }
    }
    
    /**
     * @description : used to createBLA,update child records and fire DataSync Event
     * @author MTX Group Inc | 05-22-2024
     * @param appId
     **/
    public static BusinessLicenseApplication handleBLACreation(string appId){
        try{
            PreliminaryApplicationRef parRec = CC_PreliminaryApplicationRefDAO.fetchPARANDChildBYId(appId)[0];
            BusinessLicenseApplication bla = createBLARecord(parRec);
            handleBLAPostProcessing(appId,bla.Id);
            return bla;
        }catch(Exception e){
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
        
    }
    
    /**
     * @description
     * @author Rohan Rana | 06-12-2024
     * @param appId
     * @param blaId
     **/
    @future
    public static void handleBLAPostProcessing(Id appId, Id blaId) {
        try {
            BusinessLicenseApplication blaRecord = CC_BusinessLicenseApplicationDao.getBusinessLicenseAppDetailsById(blaId)[0];
            PreliminaryApplicationRef parRec = CC_PreliminaryApplicationRefDAO.fetchPARANDChildBYId(appId)[0];
            processMemberListMain(blaRecord, parRec);
            
            updateChildBLALookup(parRec, blaId);
            
            fireDataSyncEvent(parRec.Id, blaId);
            
            if (parRec.CC_Apply_for_Rate_Enhancement__c) {
                CC_Request__c request = new CC_Request__c(
                    CC_Accreditation_Type__c = parRec.CC_Accreditation_Type__c,
                CC_Request_Status__c = CC_Constants.REQUEST_STATUS_SUBMITTED,
                CC_Provider__c = parRec.BusinessAccountNameId,
                CC_Accrediting_Organisation_Name__c = parRec.CC_Accrediting_Organisation_Name__c,
                CC_Accreditation_Begin_Date__c = parRec.CC_Accreditation_Begin_Date__c,
                CC_Accreditation_Expiration_Date__c = parRec.CC_Accreditation_Expiration_Date__c,
                CC_BusinessLicenseApplication__c = blaId,
                CC_ACRD_Percentage__c = 20
                    );
                
                if (request.CC_Accreditation_Type__c == CC_Constants.REQUEST_ACCREDITATION_TYPE_DISP) {
                    request.CC_DISP_Percentage__c = 10;
                } else if (request.CC_Accreditation_Type__c == CC_Constants.REQUEST_ACCREDITATION_TYPE_ACRD) {
                    request.CC_DISP_Percentage__c = 0;
                }
                
                request = (CC_Request__c) CC_DML.doInsert(request, false);
            }
        } catch (Exception e) {
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
    }
    
    
    public static void processMemberListMain(BusinessLicenseApplication blaRecord , PreliminaryApplicationRef parRec){
        String blaLicenseRecordTypeId = Schema.SObjectType.BusinessLicenseApplication.getRecordTypeInfosByDeveloperName().get(CC_Constants.LICENSE_RECORD_TYPE_NAME).getRecordTypeId();
        String blaSubsidyRecordTypeId = Schema.SObjectType.BusinessLicenseApplication.getRecordTypeInfosByDeveloperName().get(CC_Constants.SUBSIDY_RECORD_TYPE_NAME).getRecordTypeId();
        if (blaLicenseRecordTypeId == blaRecord.RecordTypeId) {
            String applicationJSON = CC_ApplicationController.fetchJsonFileData(CC_CommonUtility.performEncryption(parRec.Id), 'Draft');
            Map<String, Object> applicationJsonMap = (Map<String, Object>)JSON.deserializeUntyped(applicationJSON);
            
            if (applicationJsonMap.containsKey('contactRoleRelationInfo')) {
                Map<String, Object> contactRoleRelationInfo = (Map<String, Object>) applicationJsonMap.get('contactRoleRelationInfo');
                if (contactRoleRelationInfo.containsKey('contactRoleRelationList')) {
                    
                    applicationJsonMap = processMemberList(blaRecord, parRec.Id, parRec.BusinessAccountNameId, applicationJsonMap);
                    
                    String docTitle = 'draft'+parRec.Id;
                    List<ContentDocumentLink> contentDocumentLinks =CC_ContentDocumentLinkDAO.fetchContentDocIdByLinkedId(parRec.Id);
                    List<ContentDocument> conDocList = new List<ContentDocument>();
                    for(ContentDocumentLink iterRecords : contentDocumentLinks){
                        ContentDocument initailizeRecord = new ContentDocument();
                        initailizeRecord.Id = iterRecords.ContentDocumentId;
                        conDocList.add(initailizeRecord);
                    }
                    if(!conDocList.isEmpty()){
                        CC_DML.doDelete(conDocList,false);
                    }
                    String networkId =CC_NetworkDAO.getNetworkByName('Child Care').Id;
                    ContentVersion conVer = new ContentVersion();
                    conVer.Title = docTitle;
                    conVer.VersionData = Blob.valueOf(JSON.serialize(applicationJsonMap));
                    conVer.PathOnClient = 'myJSON.json';
                    conVer.FirstPublishLocationId = parRec.Id;
                    conVer.NetworkId = networkId;
                    conVer = (ContentVersion)CC_NoSharing_Utility.noSharingInsert(conVer, true);
                    
                    List<ContentDocumentLink> conDocLinkLst =  CC_ContentDocumentLinkDAO.fetchContentDocIdByContentDocumentTitle(parRec.Id,docTitle);
                    for(ContentDocumentLink conDocLink : conDocLinkLst){
                        conDocLink.Visibility = 'AllUsers';
                    }
                    if(!conDocLinkLst.isEmpty()){
                        CC_NoSharing_Utility.noSharingUpdate(conDocLinkLst, true);
                    }
                    
                }
            }
        }
        if (blaSubsidyRecordTypeId == blaRecord.RecordTypeId  && (parRec.CC_Application_Type__c == CC_Constants.APPLICATION_TYPE_RENEWAL || parRec.CC_Application_Type__c == CC_Constants.APPLICATION_TYPE_NEW)) {
            //commented by pranay - not in use yet
            //processMemberListSubsidy(blaRecord.Id, parRec.Id, parRec.BusinessAccountNameId);
        }
    }
    
    /**
     * @description : BLA record creation, the value assigned are only becoz they are required , they may overwritten by Platform event
     * @author MTX Group Inc | 05-22-2024
     * @param parRec
     * @return BusinessLicenseApplication
     **/
    public static BusinessLicenseApplication createBLARecord(PreliminaryApplicationRef parRec){
        try{
            Id userContactId = CC_UserDAO.getCurrentUserContactId();
            BusinessLicenseApplication bla=new BusinessLicenseApplication();
            bla.LicenseTypeId =parRec.CC_Regulatory_Authorization_Type__c;
            bla.AppliedDate=Date.today();
            bla.Category=parRec.CC_Regulatory_Authorization_Type__r.RegulatoryAuthCategory;
            bla.SavedApplicationRefId=parRec.Id;
            bla.ApplicationType=parRec.CC_Application_Type__c;
            bla.PrimaryOwnerId = userContactId;
            bla.ApplicantId = userContactId;
            bla.AccountId = parRec.BusinessAccountNameId;
            bla.LicensePermitNameId = parRec?.CC_Business_License__c;
            if(String.isNotBlank(parRec.CC_Regulatory_Authorization_Type__r.RegulatoryAuthCategory)){
                bla.RecordTypeId = Schema.SObjectType.BusinessLicenseApplication.getRecordTypeInfosByName().get(parRec.CC_Regulatory_Authorization_Type__r.RegulatoryAuthCategory).getRecordTypeId();
            }
            return (BusinessLicenseApplication)CC_DML.doInsert(bla, false);
        }catch(Exception e){
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
        
    }
    
    
    /**
     * @description : update BLA lookup on child records
     * @author MTX Group Inc | 05-22-2024
     * @param parRec
     * @param blaId
     **/
    public static void updateChildBLALookup(PreliminaryApplicationRef parRec,string blaId){
        List<SObject> lstSObject = new List<SObject>();
        for(CC_Application_Contact__c appCon : parRec.Application_Contacts__r){
            lstSObject.add(new CC_Application_Contact__c(id=appCon.id,CC_Business_License_Application__c=blaId));
        }
        
        for(CC_Application_Specification__c appSp : parRec.Application_Specifications__r){
            lstSObject.add(new CC_Application_Specification__c(id=appSp.id,CC_BusinessLicenseApplication__c=blaId));
        }
        
        for(CC_Document_Item__c docItem : parRec.Document_Items__r){
            lstSObject.add(new CC_Document_Item__c(id=docItem.id,CC_Business_License_Application__c=blaId));
        }
        
        /*   for(RegulatoryTrxnFee regTrx : parRec.Regulatory_Transaction_Fees__r){
            if (!Schema.sObjectType.RegulatoryTrxnFee.isUpdateable()) {continue;}
            lstSObject.add(new RegulatoryTrxnFee(id=regTrx.id,ParentRecordId = blaId));
        }*/
        
        CC_DML.doUpdate(lstSObject, false);
        
    }
    
    /**
     * @description : fire DataSync event for Mapping PAR/BLA
     * @author MTX Group Inc | 05-22-2024
     * @param parId
     * @param blaId
     **/
    public static void fireDataSyncEvent(string parId,string blaId){
        CC_DataSyncEvent__e d= new CC_DataSyncEvent__e();
        d.CC_Source_Record_Id__c=parId;
        d.CC_Target_Record_Id__c=blaId;
        d.CC_Source_Object__c='PreliminaryApplicationRef';
        d.CC_Target_Object__c='BusinessLicenseApplication';
        EventBus.publish(d);
    }
    
    
    public class RegAuthConfigWrapper{
        @AuraEnabled public String ratConfigId{get;set;}
        @AuraEnabled public String appFlowInstructions{get;set;}
        @AuraEnabled public String instructionInfoOnFlow{get;set;}
        @AuraEnabled public String facilityTypeName{get;set;}
        @AuraEnabled public String ratName{get;set;}
        @AuraEnabled public String declarationInstruction{get;set;}
        
    }
    /**
     * @description
     * @author Rohan Rana | 05-23-2024
     * @param accountId
     * @return List<CC_ApplicationWrapper.ContactRoleWrapper>
     **/
    @AuraEnabled
    public static List<CC_ApplicationWrapper.ContactRoleWrapper> getContactRoles(String accountId) {
        if(String.isNotBlank(accountId)){
            accountId = CC_CommonUtility.performDecryption(accountId);
        }
        List<CC_ApplicationWrapper.ContactRoleWrapper> roles = new List<CC_ApplicationWrapper.ContactRoleWrapper>();
        
        List<CC_Contact_Role_Relationship__c> contactRoles = CC_NoSharing_DAO.fetchContactRoles(accountId);
        for (CC_Contact_Role_Relationship__c roleRecord : contactRoles) {
            CC_ApplicationWrapper.ContactRoleWrapper roleWrapper = new CC_ApplicationWrapper.ContactRoleWrapper();
            roleWrapper.role = roleRecord.CC_Role__c;
            roleWrapper.accountId = roleRecord.CC_Account__c;
            roleWrapper.startDate = roleRecord.CC_Start_Date__c;
            roleWrapper.contactName = roleRecord.CC_Contact__r.Name;
            roleWrapper.contactEmail = roleRecord.CC_Contact__r.Email;
            roleWrapper.contactFirstName = roleRecord.CC_Contact__r.FirstName;
            roleWrapper.contactLastName = roleRecord.CC_Contact__r.LastName;
            roleWrapper.contactMiddleName = roleRecord.CC_Contact__r.MiddleName;
            roleWrapper.contactId = roleRecord.CC_Contact__c;
            roles.add(roleWrapper);
        }
        return roles;
    }
    
    /**
     * @description
     * @author Rohan Rana | 05-23-2024
     * @param applicationId
     * @param applicationContactDataList
     * @param memberType
     **/
    
    // Commented by Himani - Discussed with Pranay we are not using this on Montana
    /*@AuraEnabled
    public static void saveApplicationContacts(String applicationId, List<CC_ApplicationWrapper.ApplicationContactWrapper> applicationContactDataList,  String memberType ){
        Savepoint sp = Database.setSavepoint();
        try {
            applicationId = CC_CommonUtility.performDecryption(applicationId);
            List<CC_Application_Contact__c> applicationContactsRecordsToDelete = CC_ApplicationContactDAO.fetchApplicationContactList(applicationId,memberType);
            if(applicationContactsRecordsToDelete.size()>0){
                CC_DML.doDelete(applicationContactsRecordsToDelete, false);
            }
            
            List<CC_Application_Contact__c> appContactRecords = new List<CC_Application_Contact__c>();
            for (CC_ApplicationWrapper.ApplicationContactWrapper contactWrapper : applicationContactDataList) {
                CC_Application_Contact__c appContact = new CC_Application_Contact__c();
                appContact.CC_First_Name__c  = contactWrapper.firstName;
                appContact.CC_Last_Name__c = contactWrapper.lastName;
                appContact.CC_Middle_Name__c = contactWrapper.middleName;
                appContact.CC_Date_of_Birth__c = contactWrapper.dateOfBirth;
                appContact.CC_Preliminary_Application_Reference__c = applicationId;
                appContact.CC_Effective_Start_Date__c=contactWrapper.startDate;
                appContact.CC_Phone_Number__c=contactWrapper.phoneNumber;
                appContact.CC_Role_Type__c=contactWrapper.roleType;
                appContact.CC_Member_Type__c = memberType;
                appContact.CC_Email__c=contactWrapper.emailAddress;
                if(memberType=='Household'){
                    appContact.CC_Current_Household_Member__c = contactWrapper.currentHouseholdMember;
                    appContact.CC_House_Hold_Member_Relationship__c = contactWrapper.relationshipToHouseholdMember;
                    appContact.CC_Total_Requested_hours__c = contactWrapper.averageNumberOfHours;
                }
                
                appContactRecords.add(appContact);
            }
            if(appContactRecords.size()>0){
                CC_DML.doUpsert(appContactRecords, false);
            }
            
        } catch(Exception e){
            Database.rollback(sp);
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
    }*/
    
    /**
     * @description
     * @author Rohan Rana | 05-23-2024
     * @param applicationId
     * @param memberType
     * @return List<CC_ApplicationWrapper.ApplicationContactWrapper>
     **/
    //VK Commented the line for deleting the existing fields from CC_Application_Contact__c
    /*@AuraEnabled
    public static List<CC_ApplicationWrapper.ApplicationContactWrapper> fetchApplicationContact(String applicationId, String memberType){
        try {
            List<CC_ApplicationWrapper.ApplicationContactWrapper> appContactWrapperList = new List<CC_ApplicationWrapper.ApplicationContactWrapper>();
            
            Integer index=0;
            applicationId = CC_CommonUtility.performDecryption(applicationId);
            List<CC_Application_Contact__c> applicationContactList = CC_ApplicationContactDAO.fetchApplicationContactList(applicationId,memberType);
            for(CC_Application_Contact__c appContact : applicationContactList) {
                CC_ApplicationWrapper.ApplicationContactWrapper wrapper = new CC_ApplicationWrapper.ApplicationContactWrapper();
                
                wrapper.Id = appContact.Id;
                wrapper.index = index++;
                wrapper.firstName = appContact.CC_First_Name__c;
                wrapper.lastName = appContact.CC_Last_Name__c;
                wrapper.middleName = appContact.CC_Middle_Name__c;
                wrapper.dateOfBirth = appContact.CC_Date_of_Birth__c;
                wrapper.phoneNumber=appContact.CC_Phone_Number__c;
                wrapper.emailAddress=appContact.CC_Email__c;
                wrapper.roleType=appContact.CC_Role_Type__c;
                wrapper.startDate=appContact.CC_Effective_Start_Date__c;
                //VK Commented the line for deleting the existing fields from CC_Application_Contact__c
                //wrapper.currentHouseholdMember=appContact.CC_Current_Household_Member__c;
                wrapper.relationshipToHouseholdMember=appContact.CC_House_Hold_Member_Relationship__c;
                wrapper.averageNumberOfHours=appContact.CC_Total_Requested_hours__c;
                
                
                appContactWrapperList.add(wrapper);
            }
            return appContactWrapperList;
        } catch(Exception e){
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
    }*/
    
    
    
    
    
    
    /**
     * This method fetches the application specifications based on the provided application ID and record type.
     *
     * @param applicationId The ID of the application.
     * @param recordType The record type of the application specifications.
     * @return List<CC_ApplicationWrapper.ApplicationSpecificationsWrapper> The list of application specification wrappers.
     * @throws CC_Exception If an exception occurs during the execution of the method.
     */
    @AuraEnabled
    public static CC_ApplicationWrapper.ApplicationSpecificationsWrapper  fetchApplicationSpecifications(String applicationId, String specificationType){
        
        try {
            
            List<SelectedDay> selectedDays = new List<SelectedDay>();
            applicationId                  = CC_CommonUtility.performDecryption(applicationId);
            CC_ApplicationWrapper.ApplicationSpecificationsWrapper appSpecificationWrapperInfo= new CC_ApplicationWrapper.ApplicationSpecificationsWrapper();
            
            if(specificationType!=null){
                List<CC_Application_Specification__c> appSpecificationInfoList = CC_ApplicationSpecificationDAO.fetchApplicationSpecifications(applicationId,specificationType);
                if(appSpecificationInfoList.isEmpty()){
                    return null;
                }
                CC_Application_Specification__c appSpecificationInfo = appSpecificationInfoList[0];
                
                
                appSpecificationWrapperInfo.Id = appSpecificationInfo.Id;
                
                //charges info
                appSpecificationWrapperInfo.chargesDate = appSpecificationInfo.CC_Charges_Date__c;
                appSpecificationWrapperInfo.chargesState = appSpecificationInfo.CC_Charges_State__c;
                appSpecificationWrapperInfo.description = appSpecificationInfo.CC_Description__c;
                
                //room info
                appSpecificationWrapperInfo.roomFloorLevel = appSpecificationInfo.CC_Floor_Level__c;
                appSpecificationWrapperInfo.roomNumber = appSpecificationInfo.CC_Room_Number__c;
                appSpecificationWrapperInfo.roomUse = appSpecificationInfo.CC_Room_Use__c;
                appSpecificationWrapperInfo.roomStatus = appSpecificationInfo.CC_Room_Status__c;
                appSpecificationWrapperInfo.roomName = appSpecificationInfo.CC_Room_Name__c;
                
                
                //license info
                appSpecificationWrapperInfo.typeOfCare = appSpecificationInfo.CC_Type_of_Care__c;
                appSpecificationWrapperInfo.licenseNumber = appSpecificationInfo.CC_License_Number__c;
                appSpecificationWrapperInfo.issuanceState = appSpecificationInfo.CC_Issuance_State__c;
                appSpecificationWrapperInfo.issuanceDate = appSpecificationInfo.CC_Issuance_Date__c;
                appSpecificationWrapperInfo.expirationDate = appSpecificationInfo.CC_Expiration_Date__c;
                appSpecificationWrapperInfo.roleType = appSpecificationInfo.CC_Role_Type__c;
                appSpecificationWrapperInfo.isOtherStateCertificate = appSpecificationInfo.CC_Other_State_Certificate__c;
                appSpecificationWrapperInfo.neverExpires = appSpecificationInfo.CC_License_Never_Expires__c;
                
                //schedule info
                
                if(appSpecificationInfo.CC_To_Monday__c != null && appSpecificationInfo.CC_From_Monday__c != null){
                    SelectedDay monday = new SelectedDay('Mon', String.valueOf(appSpecificationInfo.CC_From_Monday__c), String.valueOf(appSpecificationInfo.CC_To_Monday__c), true, 'Monday');
                    selectedDays.add(monday);
                }
                if(appSpecificationInfo.CC_From_Tuesday__c != null && appSpecificationInfo.CC_To_Tuesday__c != null){
                    SelectedDay tuesday = new SelectedDay('Tue',  String.valueOf(appSpecificationInfo.CC_From_Tuesday__c),  String.valueOf(appSpecificationInfo.CC_To_Tuesday__c), false, 'Tuesday');
                    selectedDays.add(tuesday);
                }
                if(appSpecificationInfo.CC_From_Wednesday__c != null && appSpecificationInfo.CC_To_Wednesday__c != null){
                    SelectedDay wednesday = new SelectedDay('Wed',  String.valueOf(appSpecificationInfo.CC_From_Wednesday__c),  String.valueOf(appSpecificationInfo.CC_To_Wednesday__c), false, 'Wednesday');
                    selectedDays.add(wednesday);
                }
                if(appSpecificationInfo.CC_From_Thursday__c != null && appSpecificationInfo.CC_To_Thursday__c != null){
                    SelectedDay thursday = new SelectedDay('Thu',  String.valueOf(appSpecificationInfo.CC_From_Thursday__c),  String.valueOf(appSpecificationInfo.CC_To_Thursday__c), false, 'Thursday');
                    selectedDays.add(thursday);
                }
                if(appSpecificationInfo.CC_From_Friday__c != null && appSpecificationInfo.CC_To_Friday__c != null){
                    SelectedDay friday = new SelectedDay('Fri',String.valueOf(appSpecificationInfo.CC_From_Friday__c), String.valueOf(appSpecificationInfo.CC_To_Friday__c), false, 'Friday');
                    selectedDays.add(friday);
                }
                if(appSpecificationInfo.CC_From_Saturday__c != null && appSpecificationInfo.CC_To_Saturday__c != null){
                    SelectedDay saturday = new SelectedDay('Sat',  String.valueOf(appSpecificationInfo.CC_From_Saturday__c) ,  String.valueOf(appSpecificationInfo.CC_To_Saturday__c) , false, 'Saturday');
                    selectedDays.add(saturday);
                }
                if(appSpecificationInfo.CC_From_Sunday__c != null && appSpecificationInfo.CC_To_Sunday__c != null){
                    SelectedDay sunday = new SelectedDay('Sun',  String.valueOf(appSpecificationInfo.CC_From_Sunday__c),  String.valueOf(appSpecificationInfo.CC_To_Sunday__c), false, 'Sunday');
                    selectedDays.add(sunday);
                }
                appSpecificationWrapperInfo.selectedDays = selectedDays;
                // appSpecificationWrapperInfo.day = appSpecificationInfo.CC_Day__c;
                // appSpecificationWrapperInfo.startTime = String.valueOf(appSpecificationInfo.CC_Start_Time__c) ;
                // appSpecificationWrapperInfo.endTime = String.valueOf(appSpecificationInfo.CC_End_Time__c);
                // appSpecificationWrapperInfo.formattedStartTime = appSpecificationInfo.CC_Day__c + ' ' + appSpecificationInfo.CC_Start_Time__c != '' || appSpecificationInfo.CC_Start_Time__c != null  ? CC_ApplicationController.formatTime(appSpecificationWrapperInfo.startTime) : '';
                // appSpecificationWrapperInfo.formattedEndTime = appSpecificationInfo.CC_Day__c + ' '+ appSpecificationInfo.CC_End_Time__c != '' || appSpecificationInfo.CC_End_Time__c != null ? CC_ApplicationController.formatTime(appSpecificationWrapperInfo.endTime) : '';
                
            }
            return appSpecificationWrapperInfo;
        } catch(Exception e){
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
    }
    
    
    
    /**
     * Saves the application specifications for a given application.
     *
     * @param applicationId The ID of the application.
     * @param applicationSpecificationData The JSON string containing the application specification data.
     * @param recordType The record type of the application specification.
     * @throws CC_Exception If there is an error during the save operation.
     */
    @AuraEnabled
    public static void saveApplicationSpecifications(String applicationId,  List<CC_ApplicationWrapper.ApplicationSpecificationsWrapper> applicationSpecificationDataList, String specificationType){
        Savepoint sp = Database.setSavepoint();
        try {
            applicationId = CC_CommonUtility.performDecryption(applicationId);
            String applicationSpecificationRecordType;
            List<CC_Application_Specification__c> applicationSpecificationRecordsToDelete = CC_ApplicationSpecificationDAO.fetchApplicationSpecifications(applicationId,specificationType);
            if(applicationSpecificationRecordsToDelete.size()>0){
                CC_DML.doDelete(applicationSpecificationRecordsToDelete, false);
                // SObjectAccessDecision appDecision = CC_SecurityLibrary.getAccessibleData('CC_Application_Specification__c', applicationSpecificationRecordsToDelete, 'update', true);
                // delete appDecision.getRecords();
            }
            List<CC_Application_Specification__c> applicationSpecificationRecords = new List<CC_Application_Specification__c>();
            for (CC_ApplicationWrapper.ApplicationSpecificationsWrapper applicationSpecificationWrapper : applicationSpecificationDataList) {
                CC_Application_Specification__c appSpecificationInfo = new CC_Application_Specification__c();
                
                //charges field
                if(specificationType == 'Charges'){
                    appSpecificationInfo.CC_Charges_Date__c  = applicationSpecificationWrapper.chargesDate;
                    appSpecificationInfo.CC_Charges_State__c = applicationSpecificationWrapper.chargesState;
                    appSpecificationInfo.CC_Description__c = applicationSpecificationWrapper.description;
                }
                //room field
                else if(specificationType == 'Rooms'){
                    appSpecificationInfo.CC_Room_Number__c   = applicationSpecificationWrapper.roomNumber;
                    appSpecificationInfo.CC_Floor_Level__c = applicationSpecificationWrapper.roomFloorLevel;
                    appSpecificationInfo.CC_Room_Use__c = applicationSpecificationWrapper.roomUse;
                    appSpecificationInfo.CC_Room_Status__c = applicationSpecificationWrapper.roomStatus;
                    appSpecificationInfo.CC_Room_Name__c = applicationSpecificationWrapper.roomName;
                }
                
                //licenseField
                else if(specificationType == 'License'){
                    appSpecificationInfo.CC_Type_of_Care__c     = applicationSpecificationWrapper.typeOfCare;
                    appSpecificationInfo.CC_License_Number__c   = applicationSpecificationWrapper.licenseNumber;
                    appSpecificationInfo.CC_Issuance_State__c   = applicationSpecificationWrapper.issuanceState;
                    appSpecificationInfo.CC_Issuance_Date__c    = applicationSpecificationWrapper.issuanceDate;
                    appSpecificationInfo.CC_Expiration_Date__c  = applicationSpecificationWrapper.expirationDate;
                    appSpecificationInfo.CC_Role_Type__c        = applicationSpecificationWrapper.roleType;
                    appSpecificationInfo.CC_Other_State_Certificate__c = applicationSpecificationWrapper.isOtherStateCertificate;
                    appSpecificationInfo.CC_License_Never_Expires__c = false;
                    if(applicationSpecificationWrapper.neverExpires!=null){
                        appSpecificationInfo.CC_License_Never_Expires__c = applicationSpecificationWrapper.neverExpires;
                    }
                    
                }
                
                //schedule info
                else if(specificationType == 'Schedule'){
                    
                    //daySelected
                    
                    appSpecificationInfo.CC_From_Monday__c      = applicationSpecificationWrapper.monStarttime;
                    appSpecificationInfo.CC_To_Monday__c        = applicationSpecificationWrapper.monEndtime;
                    appSpecificationInfo.CC_From_Tuesday__c     = applicationSpecificationWrapper.tueStarttime;
                    appSpecificationInfo.CC_To_Tuesday__c       = applicationSpecificationWrapper.tueEndtime;
                    appSpecificationInfo.CC_From_Wednesday__c   = applicationSpecificationWrapper.wedStarttime;
                    appSpecificationInfo.CC_To_Wednesday__c     = applicationSpecificationWrapper.wedEndtime;
                    appSpecificationInfo.CC_From_Thursday__c    = applicationSpecificationWrapper.thuStarttime;
                    appSpecificationInfo.CC_To_Thursday__c      = applicationSpecificationWrapper.thuEndtime;
                    appSpecificationInfo.CC_From_Friday__c      = applicationSpecificationWrapper.friStarttime;
                    appSpecificationInfo.CC_To_Friday__c        = applicationSpecificationWrapper.friEndtime;
                    appSpecificationInfo.CC_To_Thursday__c      = applicationSpecificationWrapper.satStarttime;
                    appSpecificationInfo.CC_To_Saturday__c      = applicationSpecificationWrapper.satEndtime;
                    appSpecificationInfo.CC_From_Sunday__c      = applicationSpecificationWrapper.sunStarttime;
                    appSpecificationInfo.CC_To_Sunday__c        = applicationSpecificationWrapper.sunEndtime;
                    
                }
                
                //specification type
                appSpecificationInfo.CC_Specification_Type__c        = specificationType;
                appSpecificationInfo.CC_PreliminaryApplicationRef__c = applicationId;
                applicationSpecificationRecords.add(appSpecificationInfo);
            }
            if(applicationSpecificationRecords.size()>0){
                CC_DML.doUpsert(applicationSpecificationRecords, false);
            }
            
        } catch(Exception e){
            Database.rollback(sp);
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
    }
    
    /**
     * @description
     * @author Rohan Rana | 05-23-2024
     * @param timeData
     * @return String
     **/
    public Static String formatTime(String timeData){
        String myDate;
        if(timeData !=null){
            String startTime = timeData;
            Integer hour = Integer.valueOf(startTime.left(2));
            Integer minute = Integer.valueOf(startTime.substringBetween(':',':'));
            
            DateTime myDT = DateTime.newInstance(Date.today(), Time.newInstance(hour, minute, 0, 0));
            myDate = myDT.format('h:mm a');
        }
        
        return myDate;
    }
    
    /**
     * @description Creates a JSON file for an application.
     * @author MTX Group Inc | 02-28-2024
     * @param applicationId
     * @param completeJs
     * @param statusValue
     * @return String
     **/
    @AuraEnabled
    public static String createJsonFile(String applicationId,Object completeJs,String statusValue){
        try{
            applicationId = CC_CommonUtility.performDecryption(applicationId);
            String docTitle = statusValue+applicationId;
            List<ContentDocumentLink> contentDocumentLinks =CC_ContentDocumentLinkDAO.fetchContentDocIdByLinkedId(applicationId);
            if(!contentDocumentLinks.isEmpty()){
                CC_DML.doDelete(contentDocumentLinks,false);
            }
            ContentVersion conVer = new ContentVersion();
            conVer.Title = docTitle; // The title of the content
            conVer.VersionData = Blob.valueOf(JSON.serialize(completeJs)); // Convert the JSON string to Blob
            conVer.PathOnClient = 'myJSON.json'; // The file name with .json extension
            conVer.FirstPublishLocationId = applicationId;
            
            // insert conVer;
            conVer = (ContentVersion)CC_DML.doInsert(conVer,false);
            
            
            List<ContentDocumentLink> conDocLinkLst =  CC_ContentDocumentLinkDAO.fetchContentDocIdByContentDocumentTitle(applicationId,docTitle);
            for(ContentDocumentLink conDocLink : conDocLinkLst){
                conDocLink.Visibility = 'AllUsers';
            }
            if(!conDocLinkLst.isEmpty()){
                CC_DML.doUpdate(conDocLinkLst,true);
            }
            return conVer.Id;
        }
        catch(exception e){
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
    }
    /**
     * @description Fetches JSON file data based on application ID and status value.
     * @author Pranav Parakh | 02-28-2024
     * @param appId
     * @param statusVal
     * @return String
     **/
    @AuraEnabled
    public static String fetchJsonFileData(String appId, String statusVal){
        appId = CC_CommonUtility.performDecryption(appId);
        
        if(statusVal == 'Draft'){
            List<ContentDocumentLink> cv = CC_ContentDocumentLinkDAO.fetchContentDocIdByContentDocumentFileType(appId);
            if(!cv.isEmpty()){
                Blob jsonDataBlob = cv[0].ContentDocument.LatestPublishedVersion.VersionData;
                String base64Data = EncodingUtil.base64Encode(jsonDataBlob);
                String jsonDataString = EncodingUtil.base64Decode(base64Data).toString();
                return jsonDataString;
            }
        }
        return null;
    }
    
    /**
     * @description Fetches JSON file data based on application ID and status value.
     * @author Pranav Parakh | 02-28-2024
     * @param appId
     * @param statusVal
     * @return String
     **/
    @AuraEnabled(cacheable=true)
    public static List<MetadataWrapper> getMetadata() {
        List<MetadataWrapper> metadata = new List<MetadataWrapper>();
        
        // Add your logic to retrieve and construct the metadata list
        metadata.add(new MetadataWrapper('Page', 'FirstPage', '1'));
        metadata.add(new MetadataWrapper('Section', 'SecOne', '1.1'));
        metadata.add(new MetadataWrapper('Field', 'FieOne', '1.1.2'));
        metadata.add(new MetadataWrapper('Field', 'FieTwo', '1.1.3'));
        metadata.add(new MetadataWrapper('Section', 'Sec2', '1.2'));
        metadata.add(new MetadataWrapper('Section', 'Sec3', '1.3'));
        metadata.add(new MetadataWrapper('Page', 'SecondPage', '2'));
        metadata.add(new MetadataWrapper('Page', 'ThirdPage', '3'));
        metadata.add(new MetadataWrapper('Page', 'ForthPage', '4'));
        
        return metadata;
    }
    
    public class MetadataWrapper {
        @AuraEnabled public String Type { get; set; }
        @AuraEnabled public String Label { get; set; }
        @AuraEnabled public String Sequence { get; set; }
        
        public MetadataWrapper(String type, String label, String sequence) {
            this.Type = type;
            this.Label = label;
            this.Sequence = sequence;
        }
    }
    /**
     * @description
     * @author Rohan Rana | 05-23-2024
     * @param applicationId
     * @param ratId
     * @param accountId
     * @return list<CC_ApplicationWrapper.FeeItemWrapper>
     **/
    @AuraEnabled
    public static list<CC_ApplicationWrapper.FeeItemWrapper> fetchFeeItems(string applicationId , string ratId ,string accountId, Boolean isRenewalFlow, Boolean isAmmendFlow){
        try{
            if (Schema.sObjectType.RegulatoryTrxnFee.isCreateable()) {
                return fetchFeeItemsWithAccess(applicationId,ratId,accountId,isRenewalFlow,isAmmendFlow);
            }else{
                return fetchFeeItemsWOAccess(applicationId,ratId,accountId,isRenewalFlow,isAmmendFlow);
            }
        }
        catch(exception e){
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
        
        
    }
    
    /**
     * @description : this method will return wrapper by creating RegTrxFee Data
     * @author MTX Group Inc | 11-29-2024
     * @param applicationId
     * @param ratId
     * @param accountId
     * @param isRenewalFlow
     * @param isAmmendFlow
     * @return list<CC_ApplicationWrapper.FeeItemWrapper>
     **/
    public static list<CC_ApplicationWrapper.FeeItemWrapper> fetchFeeItemsWithAccess(string applicationId , string ratId ,string accountId, Boolean isRenewalFlow, Boolean isAmmendFlow){
        try{
            applicationId = CC_CommonUtility.performDecryption(applicationId);
            ratId = CC_CommonUtility.performDecryption(ratId);
            accountId = CC_CommonUtility.performDecryption(accountId);
            PreliminaryApplicationRef currentApp= CC_PreliminaryApplicationRefDAO.fetchPARGivenFieldsById(new List<string>{'CC_Amendment_Type__c'}, applicationId)[0];
            
            list<CC_ApplicationWrapper.FeeItemWrapper> feeItemList = new list<CC_ApplicationWrapper.FeeItemWrapper>();
            /* List<RegulatoryTrxnFee> existingFeeRecords = CC_RegulatoryTrxnFeeDAO.fetchRegulatoryTrxnFeeList(applicationId);
            if(!existingFeeRecords.isEmpty()){
                List<RegulatoryTrxnFeeItem> FeeItems = CC_RegulatoryTrxnFeeItemDAO.fetchRegulatoryTrxnFeeItem(existingFeeRecords[0].Id);
                
                for(RegulatoryTrxnFeeItem feeItemRecord : FeeItems){
                    CC_ApplicationWrapper.FeeItemWrapper feeItem =new CC_ApplicationWrapper.FeeItemWrapper();
                    feeItem.feeItemId = CC_CommonUtility.performEncryption(feeItemRecord.Id);
                    feeItem.name = feeItemRecord.Name;
                    feeItem.amount = feeItemRecord.FeeAmount;
                    feeItemList.add(feeItem);
                }
            }else{
                List<RegulatoryTrxnFee> newFeeRecords = new List<RegulatoryTrxnFee>();
                List<RegulatoryTrxnFeeItem> newFeeItemRecords = new List<RegulatoryTrxnFeeItem>();
                String appType = isAmmendFlow ? CC_Constants.APPLICATION_TYPE_AMENDMENT : (isRenewalFlow ? CC_Constants.APPLICATION_TYPE_RENEWAL  : CC_Constants.APPLICATION_TYPE_NEW);
                List<CC_Regulatory_Auth_Type_Configs__c> regAuthConfigs = Copy_CC_NoSharing_DAO.fetchRegFeeConfig(ratId, appType,currentApp.CC_Amendment_Type__c);
                if(!regAuthConfigs.isEmpty()){
                    RegulatoryTrxnFee newFeeRecord = new RegulatoryTrxnFee();
                    newFeeRecord.CC_Preliminary_Application_Reference__c = applicationId;
                    newFeeRecord.AccountId = accountId;
                    newFeeRecord.Status = 'Due';
                    newFeeRecords.add(newFeeRecord);
                    if (!newFeeRecords.isEmpty()) {
                        CC_DML.doInsert(newFeeRecords, false);
                    }
                }
                RegulatoryTrxnFee insertedFeeRecord = CC_RegulatoryTrxnFeeDAO.fetchRegulatoryTrxnFee(applicationId);
                Boolean lateFeesApplicable = false;
                
                if(isRenewalFlow){
                    String appStatus = CC_PreliminaryApplicationRefDAO.fetchBLDetailsByPARId(applicationId)[0].CC_Business_License__r.Status;
                    lateFeesApplicable = appStatus == CC_Constants.MY_LICENSE_STATUS_OVERDUE ? true : false;
                }
                
                if(insertedFeeRecord != null){
                    for(CC_Regulatory_Auth_Type_Configs__c regAuthItem : regAuthConfigs){
                        if(!lateFeesApplicable && regAuthItem.CC_Is_Late_Renewal__c){
                            continue;
                        }
                        
                        RegulatoryTrxnFeeItem feeItem =new RegulatoryTrxnFeeItem();
                        feeItem.Name = regAuthItem.CC_Fee_Name__c;
                        feeItem.FeeAmount = regAuthItem.CC_Fee_Amount__c;
                        feeItem.RegulatoryTrxnFeeId = insertedFeeRecord.Id;
                        newFeeItemRecords.add(feeItem);
                    }
                    if(!newFeeItemRecords.isEmpty()){
                        CC_DML.doInsert(newFeeItemRecords, false);
                    }
                }
                List<RegulatoryTrxnFeeItem> FeeItems = CC_RegulatoryTrxnFeeItemDAO.fetchRegulatoryTrxnFeeItem(insertedFeeRecord.Id);
                
                for(RegulatoryTrxnFeeItem feeItemRecord : FeeItems){
                    CC_ApplicationWrapper.FeeItemWrapper feeItem =new CC_ApplicationWrapper.FeeItemWrapper();
                    feeItem.feeItemId = CC_CommonUtility.performEncryption(feeItemRecord.Id);
                    feeItem.name = feeItemRecord.Name;
                    feeItem.amount = feeItemRecord.FeeAmount;
                    feeItemList.add(feeItem);
                }
            }*/
            return null;
        }
        catch(exception e){
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
    }
    
    /**
     * @description : this method will return wrapper object access is not present by fetching data from RATC and not creating RegTrxFee Data
     * @author MTX Group Inc | 11-29-2024
     * @param applicationId
     * @param ratId
     * @param accountId
     * @param isRenewalFlow
     * @param isAmmendFlow
     * @return list<CC_ApplicationWrapper.FeeItemWrapper>
     **/
    public static list<CC_ApplicationWrapper.FeeItemWrapper> fetchFeeItemsWOAccess(string applicationId , string ratId ,string accountId, Boolean isRenewalFlow, Boolean isAmmendFlow){
        applicationId = CC_CommonUtility.performDecryption(applicationId);
        ratId = CC_CommonUtility.performDecryption(ratId);
        accountId = CC_CommonUtility.performDecryption(accountId);
        list<CC_ApplicationWrapper.FeeItemWrapper> feeItemList = new list<CC_ApplicationWrapper.FeeItemWrapper>();
        List<RegulatoryTrxnFee> newFeeRecords = new List<RegulatoryTrxnFee>();
        List<RegulatoryTrxnFeeItem> newFeeItemRecords = new List<RegulatoryTrxnFeeItem>();
        String appType = isAmmendFlow ? CC_Constants.APPLICATION_TYPE_AMENDMENT : (isRenewalFlow ? CC_Constants.APPLICATION_TYPE_RENEWAL  : CC_Constants.APPLICATION_TYPE_NEW);
        PreliminaryApplicationRef currentApp= CC_PreliminaryApplicationRefDAO.fetchPARGivenFieldsById(new List<string>{'CC_Amendment_Type__c'}, applicationId)[0];
        List<CC_Regulatory_Auth_Type_Configs__c> regAuthConfigs = CC_NoSharing_DAO.fetchRegFeeConfig(ratId, appType,currentApp.CC_Amendment_Type__c);
        for(CC_Regulatory_Auth_Type_Configs__c regAuthItem : regAuthConfigs){
            CC_ApplicationWrapper.FeeItemWrapper feeItem =new CC_ApplicationWrapper.FeeItemWrapper();
            //feeItem.feeItemId = CC_CommonUtility.performEncryption(feeItemRecord.Id);
            feeItem.name = regAuthItem.CC_Fee_Name__c;
            feeItem.amount = regAuthItem.CC_Fee_Amount__c;
            feeItemList.add(feeItem);
        }
        return feeItemList;
    }
    
    /**
     * @description
     * @author Rohan Rana | 05-23-2024
     * @param applicationId
     * @param status
     **/
    @AuraEnabled
    public static void updateRegTrxnFee(string applicationId, string status){
        try {
            if (!Schema.sObjectType.RegulatoryTrxnFee.isUpdateable()) {return;}
            applicationId = CC_CommonUtility.performDecryption(applicationId);
            RegulatoryTrxnFee existingFeeRecords = CC_RegulatoryTrxnFeeDAO.fetchRegulatoryTrxnFee(applicationId);
            
            if(existingFeeRecords!=null){
                existingFeeRecords.Status = status;
            }
            CC_DML.doUpdate(existingFeeRecords, false) ;
            return;
        } catch (exception e) {
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
        
    }
    
    
    
    
    
    
    @AuraEnabled
    public static List<ContactWrapper> searchContactsByWorkforceId(String workforceId) {
        String searchQuery = '%' + workforceId + '%';
        Set<Id> allIdsHavingACRAlready  = new Set<Id>();
        Set<Id> allUsersContactIds = new Set<Id>();
        for (User userRecord : CC_NoSharing_DAO.allUsersWS()) {
            if (userRecord.ContactId != null) {
                allUsersContactIds.add(userRecord.ContactId);
            }
        }
        List<ContactWrapper> conWrapList = new List<ContactWrapper>();
        List<Contact> conList = CC_NoSharing_DAO.allContactsBasedOnWorkforceIdSearchWS(searchQuery,allUsersContactIds);
        for(Contact wrapContact : conList){
            ContactWrapper conWrap = new ContactWrapper();
            conWrap.contactId = CC_CommonUtility.performEncryption(wrapContact.Id);
            conWrap.accountId = wrapContact.AccountId;
            conWrap.employerName = (String.isBlank(wrapContact.FirstName) ? '' : wrapContact.FirstName + ' ') +
                (String.isBlank(wrapContact.middleName) ? '' : wrapContact.middleName + ' ') +
                (String.isBlank(wrapContact.LastName) ? '' : wrapContact.LastName + ' ');
            conWrap.firstName = wrapContact.FirstName;
            conWrap.lastName = wrapContact.LastName;
            conWrap.middleName = wrapContact.middleName;
            conWrap.workforceId = wrapContact.Account?.CC_Person_ID__c;
            conWrap.emailAddress = wrapContact.Email;
            conWrap.dateOfBirth = String.valueOf(wrapContact.Birthdate);
            String ssnValue = wrapContact?.Account?.CC_Decrypted_SSN__c;
            conWrap.ssn = wrapContact?.Account?.CC_SSN__c;//ssnValue != null && ssnValue.length() >= 5 ? ssnValue.substring(ssnValue.length() - 5) : ssnValue;
            conWrap.gender = wrapContact?.GenderIdentity;
            conWrap.race = wrapContact?.CC_Race_Origin__c;
            
            conWrap.streetMailing = wrapContact?.Account?.ShippingStreet;
            conWrap.cityMailing = wrapContact?.Account?.ShippingCity;
            conWrap.countryMailing = wrapContact?.Account?.ShippingCountryCode;
            conWrap.stateMailing = wrapContact?.Account?.ShippingStateCode;
            conWrap.zipCodeMailing = wrapContact?.Account?.ShippingPostalCode;
            conWrap.mailingCounty = wrapContact?.Account?.CC_County_Mailing__c;
            conWrap.mailingcountyOther = wrapContact?.Account?.CC_Shipping_County_Other__c;
            
            conWrap.streetBilling = wrapContact?.Account?.BillingStreet;
            conWrap.cityBilling = wrapContact?.Account?.BillingCity;
            conWrap.countryBilling = wrapContact?.Account?.BillingCountry;
            conWrap.stateBilling = wrapContact?.Account?.BillingStateCode;
            conWrap.zipCodeBilling = wrapContact?.Account?.BillingPostalCode;
            conWrap.billingCounty = wrapContact?.Account?.CC_County_Billing__c;
            conWrap.billingcountyOther = wrapContact?.Account?.CC_Billing_County_Other__c;
            
            conWrap.mailingSameAsPhysical = wrapContact?.Account?.CC_Mailing_Address_Same__c;
            conWrapList.add(conWrap);
        }
        
        return conWrapList;
    }
    
    @AuraEnabled
    public static List<ContactWrapper> searchMembersDemographicInputs(String tobeSearchedContact) {
        try {
            if(tobeSearchedContact.length() < 3){
                throw new CC_Exception('Please input aleast 3 letters for proper search');
            }
            tobeSearchedContact = '%' + tobeSearchedContact + '%';
            Set<Id> allIdsHavingACRAlready  = new Set<Id>();
            Set<Id> allUsersContactIds = new Set<Id>();
            for (User userRecord : CC_NoSharing_DAO.allUsersWS()) {
                if (userRecord.ContactId != null) {
                    allUsersContactIds.add(userRecord.ContactId);
                }
            }
            List<ContactWrapper> conWrapList = new List<ContactWrapper>();
            List<Contact> conList = CC_NoSharing_DAO.allContactsBasedOnInfoSearchWS(tobeSearchedContact,allUsersContactIds);
            for(Contact wrapContact : conList){
                ContactWrapper conWrap = new ContactWrapper();
                conWrap.contactId = CC_CommonUtility.performEncryption(wrapContact.Id);
                conWrap.accountId = wrapContact.AccountId;
                conWrap.employerName = (String.isBlank(wrapContact.FirstName) ? '' : wrapContact.FirstName + ' ') +
                    (String.isBlank(wrapContact.middleName) ? '' : wrapContact.middleName + ' ') +
                    (String.isBlank(wrapContact.LastName) ? '' : wrapContact.LastName + ' ');
                conWrap.firstName = wrapContact.FirstName;
                conWrap.lastName = wrapContact.LastName;
                conWrap.middleName = wrapContact.middleName;
                conWrap.workforceId = wrapContact.Account?.CC_Person_ID__c;
                conWrap.emailAddress = wrapContact.Email;
                conWrap.dateOfBirth = String.valueOf(wrapContact.Birthdate);
                String ssnValue = wrapContact?.Account?.CC_Decrypted_SSN__c;
                conWrap.decryptedSsn = ssnValue;
                conWrap.ssn = wrapContact?.Account?.CC_SSN__c;// ssnValue != null? ssnValue : ssnValue;
                //conWrap.ssn = ssnValue != null && ssnValue.length() >= 5 ? ssnValue.substring(ssnValue.length() - 5) : ssnValue;
                conWrap.gender = wrapContact?.Account?.PersonGenderIdentity;
                conWrap.race = wrapContact?.Account?.CC_Race_Origin__pc;
                conWrap.ethnicity = wrapContact?.Account?.CC_Ethnicity__c;
                conWrap.phoneNum = wrapContact?.Account?.Phone;
                
                conWrap.streetMailing = wrapContact?.Account?.ShippingStreet;
                conWrap.cityMailing = wrapContact?.Account?.ShippingCity;
                conWrap.countryMailing = wrapContact?.Account?.ShippingCountryCode;
                // conWrap.countryMailing = wrapContact?.Account?.ShippingCountry;
                conWrap.stateMailing = wrapContact?.Account?.ShippingStateCode;
                // conWrap.stateMailing = wrapContact?.Account?.ShippingState;
                conWrap.zipCodeMailing = wrapContact?.Account?.ShippingPostalCode;
                conWrap.mailingCounty = wrapContact?.Account?.CC_County_Mailing__c;
                conWrap.mailingcountyOther = wrapContact?.Account?.CC_Shipping_County_Other__c;
                
                conWrap.streetBilling = wrapContact?.Account?.BillingStreet;
                conWrap.cityBilling = wrapContact?.Account?.BillingCity;
                conWrap.countryBilling = wrapContact?.Account?.BillingCountryCode;
                //conWrap.countryBilling = wrapContact?.Account?.BillingCountry;
                conWrap.stateBilling = wrapContact?.Account?.BillingStateCode;
                conWrap.zipCodeBilling = wrapContact?.Account?.BillingPostalCode;
                conWrap.billingCounty = wrapContact?.Account?.CC_County_Billing__c;
                conWrap.billingcountyOther = wrapContact?.Account?.CC_Billing_County_Other__c;
                
                conWrap.mailingSameAsPhysical = wrapContact?.Account?.CC_Mailing_Address_Same__c;
                conWrapList.add(conWrap);
            }
            
            return conWrapList;
        } catch (Exception e) {
            if(e.getMessage().contains('Please input aleast 3 letters for proper search')){
                throw new CC_Exception('Please input aleast 3 letters for proper search');
            }
            else{throw new CC_Exception(CC_Constants.SOMETHING_WENT_WRONG_MSG +  e.getlinenumber());}
        }
    }
    @AuraEnabled
    public static boolean checkFacilityAccess(String accountId) {
        try {
            List<CC_Contact_Role_Relationship__c> conAcr = CC_DAO_ContactRoleRelationship.getAcrForRolesAndPermWS(currentUserDetails.ContactId , CC_CommonUtility.performDecryption(accountId) , null);
            if(conAcr.isEmpty() || (conAcr[0]?.CC_Role__c != CC_Constants.FACILITY_DIRECTOR_ROLE) && (conAcr[0]?.CC_Role__c != CC_Constants.BUSINESS_ADMIN_ROLE) || (conAcr[0]?.CC_Role__c == null)){
                return false;
            }
            return true;
        } catch (Exception e) {
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
    }
    
    public static Map<String, Object> processMemberList(BusinessLicenseApplication blaRecord , String parId, String providerAccId, Map<String, Object> applicationJsonMap) {
        try {
            Map<String, Object> contactRoleRelationInfo = (Map<String, Object>) applicationJsonMap.get('contactRoleRelationInfo');
            String extractedNode = JSON.serialize(contactRoleRelationInfo.get('contactRoleRelationList'));
            
            Map<String, Object> declarationStepInfo = new Map<String, Object>();
            if(contactRoleRelationInfo.containsKey('declarationStepInfo')) {
                declarationStepInfo = (Map<String, Object>) contactRoleRelationInfo.get('declarationStepInfo');
                System.debug('declarationStepInfo======='+declarationStepInfo);
            }
            List<ContactRoleRelationWrapper> membersList = (List<ContactRoleRelationWrapper>)JSON.deserialize(extractedNode, List<ContactRoleRelationWrapper>.class);
            
            String recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
            List<CC_Application_Contact__c> papRecords = new List<CC_Application_Contact__c>();
            List<CC_Application_Specification__c> appSpecificRecords = new List<CC_Application_Specification__c>();
            List<String> appSpecificationType = new List<String>{'Professional Credential', 'Employment', 'Degree'};
            List<CC_Application_Specification__c> newPAPIdAppSpecRecords = CC_ApplicationSpecificationDAO.fetchApplicationSpecificationsByTypes(parId,appSpecificationType);
            System.debug('app Spec 2341 ' + newPAPIdAppSpecRecords);
            // List<Account> personAccRecords = new List<Account>();
            Map<String,Id> newAccEmailToIdMap = new Map<String,Id>();
            Map<String,Id> newAccIdPAPIdMap = new Map<String,Id>();
            Map<String,Id> newPAPIdScheduleIdMap = new Map<String,Id>();
            Map<String,Id> newEmailPapIdMap = new Map<String,Id>();
            for(ContactRoleRelationWrapper conWrap : membersList){
                // if(conWrap.curentlyEnrolled == 'No'){
                    //     Account newAccount = new Account();
                    //     newAccount.RecordTypeId = recTypeId;
                    //     newAccount.FirstName = conWrap.firstName;
                    //     newAccount.LastName = conWrap.lastName;
                    //     newAccount.PersonEmail = conWrap.emailAddress;
                    //     newAccount.MiddleName  = conWrap.middleName;
                    //     newAccount.PersonBirthdate  = String.isNotBlank(conWrap.dateOfBirth)? Date.valueOf(conWrap.dateOfBirth) : null;
                    //     if(String.isNotBlank(conWrap.memberAccountId)){
                        //         newAccount.Id = conWrap.memberAccountId;
                    //     }
                    //     personAccRecords.add(newAccount);
                // }
                if(String.isNotBlank(conWrap.selectedAccountId)){
                    newAccEmailToIdMap.put(conWrap.emailAddress,  conWrap.selectedAccountId);
                }
            }
            // if(!personAccRecords.isEmpty()){
            //     personAccRecords =  (List<Account>)CC_DML.doUpsert(personAccRecords, false);
            //     for(Account iterAcc : personAccRecords){
            //         newAccEmailToIdMap.put(iterAcc.PersonEmail,  iterAcc.id);
            //     }
            // }
            String blaLicenseRecordTypeId = Schema.SObjectType.BusinessLicenseApplication.getRecordTypeInfosByDeveloperName().get(CC_Constants.LICENSE_RECORD_TYPE_NAME).getRecordTypeId();
            // boolean ifLgc = (blaLicenseRecordTypeId == blaRecord.RecordTypeId) ;
            // Map<String, Map<String, String>> resultMap = new Map<String, Map<String, String>>();
            // if(ifLgc){
                //     resultMap = mapDesignationsToPicklistValues(applicationJsonMap);
            // }
            String providerStaffRecTypeId = Schema.SObjectType.CC_Application_Contact__c.getRecordTypeInfosByDeveloperName().get('Provider_Staff').getRecordTypeId();
            String familyHouseholdRecTypeId = Schema.SObjectType.CC_Application_Contact__c.getRecordTypeInfosByDeveloperName().get('CC_Family_Household').getRecordTypeId();
            for(ContactRoleRelationWrapper conWrap : membersList){
                // if(conWrap.curentlyEnrolled == 'No'){
                    //else{
                        CC_Application_Contact__c newPAP = new CC_Application_Contact__c();
                        newPAP.CC_Currently_Enrolled__c  = conWrap.curentlyEnrolled == 'Yes';
                        newPAP.CC_Status__c = 'Inactive';
                        newPAP.CC_Current_Staff_Status__c='Active';
                        if(conWrap.isActive!=null && conWrap.isActive==false ){
                            // newPAP.CC_End_Date__c = String.isNotBlank(conWrap.endDate)? Date.valueOf(conWrap.endDate) : null;
                            newPAP.CC_Current_Staff_Status__c='Inactive';
                        }
                        newPAP.CC_Business_License_Application__c = blaRecord.Id;
                        newPAP.CC_Preliminary_Application_Reference__c  = parId;
                        newPAP.CC_Applicant__c = currentUserDetails.AccountId;
                        newPAP.CC_Participant__c = newAccEmailToIdMap.get(conWrap.emailAddress) != null ? newAccEmailToIdMap.get(conWrap.emailAddress):null; 
                        newPAP.RecordTypeId = providerStaffRecTypeId;
                        // newPAP.CC_Multi_Location_Staff__c  = conWrap.otherRole == 'Yes';
                        // newPAP.CC_Member_Role__c  = conWrap.selectedRole;
                        newPAP.CC_Role__c  = conWrap.selectedRoleType;
                        // newPAP.CC_Licensee__c  = conWrap.isLicensee == 'Yes';
                        newPAP.CC_Provider_Account__c  = providerAccId;
                        newPAP.CC_BRC_Required__c  = true;
                        if(newPAP.CC_Current_Staff_Status__c=='Inactive' || (conWrap.brcStatus!=null && conWrap.brcStatus=='Active')){
                            newPAP.CC_BRC_Required__c  = false;
                            // if(conWrap.brcStatus=='Active'){
                                //     newPAP.CC_BRC_Status__c = conWrap.brcStatus;
                            // }
                        }
                        newPAP.CC_Date_of_Birth__c  = String.isNotBlank(conWrap.dateOfBirth)? Date.valueOf(conWrap.dateOfBirth) : null;
                        newPAP.CC_Start_Date__c  = String.isNotBlank(conWrap.startDate)?Date.valueOf(conWrap.startDate) : null;
                        newPAP.CC_First_Name__c  = conWrap.firstName;
                        newPAP.CC_Last_Name__c  = conWrap.lastName;
                        newPAP.CC_Middle_Name__c  = conWrap.middleName;
                        newPAP.CC_Email__c  = conWrap.emailAddress;
                        //Addition by Payal
                        newPAP.CC_Suffix__c = String.isNotBlank(conWrap.suffix) ? conWrap.suffix : null;
                        newPAP.CC_Email_Type__c =  String.isNotBlank(conWrap.emailType) ? conWrap.emailType : null;
                        System.debug('Email Type: ' + newPAP.CC_Email_Type__c);
                        System.debug('Email CRR: ' + conWrap.emailType);
                        newPAP.CC_Phone_Type__c = String.isNotBlank(conWrap.phoneType)? conWrap.phoneType : null;
                        newPAP.CC_Phone__c = String.isNotBlank(conWrap.phoneNum) ? conWrap.phoneNum : null;
                        newPAP.CC_Alternate_Phone__c = String.isNotBlank(conWrap.alternatePhoneNum) ? conWrap.alternatePhoneNum : null;
                        newPAP.CC_Alternate_Phone_Type__c =  String.isNotBlank(conWrap.alternatePhoneType) ? conWrap.alternatePhoneType : null;
                        // newPAP.CC_Alternate_Phone__c = conWrap.alternatePhone;
                        // newPAP.CC_Totals_Hours_Requested__c  = conWrap.numberOfHours;
                        newPAP.CC_Gender__c = conWrap.gender;
                        newPAP.CC_Suffix__c = conWrap.suffix; 
                        newPAP.CC_Other_Names__c = conWrap.otherName;
                        newPAP.CC_Race_Origin__c = conWrap.race;
                        newPAP.CC_SSN__c = conWrap.decryptedSsn;
                        newPAP.CC_Decrypted_SSN__c = conWrap.decryptedSsn;
                        newPAP.CC_Medication_Administration_Attestation__c = conWrap.medAdminAttestationCheck != null? conWrap.medAdminAttestationCheck : false;
                        
                        if(conWrap.memberType != 'household'){
                            newPAP.CC_Mailing_Address__Street__s  = conWrap?.streetMailing != null? conWrap?.streetMailing : null;
                            newPAP.CC_Mailing_Address__City__s  = conWrap?.cityMailing != null? conWrap?.cityMailing : null;
                            newPAP.CC_Mailing_Address__CountryCode__s  = conWrap?.countryMailing != null? conWrap?.countryMailing : null;
                            newPAP.CC_Mailing_Address__StateCode__s  = conWrap?.stateMailing != null? conWrap?.stateMailing : null;
                            newPAP.CC_Mailing_Address__PostalCode__s  = conWrap?.zipCodeMailing != null? conWrap?.zipCodeMailing : null;
                            newPAP.CC_Shipping_County__c  = conWrap?.mailingCounty != null? conWrap?.mailingCounty : null;
                            newPAP.CC_Shipping_County_Other__c  = conWrap?.mailingcountyOther != null? conWrap?.mailingcountyOther : null;
                            newPAP.CC_Shipping_Apt_Suite__c  = conWrap?.mailingapartmentSuite != null? conWrap?.mailingapartmentSuite : null;
                            newPAP.CC_Billing_Address__Street__s  = conWrap?.streetBilling != null? conWrap?.streetBilling : null;
                            newPAP.CC_Billing_Address__City__s  = conWrap?.cityBilling != null? conWrap?.cityBilling : null;
                            newPAP.CC_Billing_Address__CountryCode__s  = conWrap?.countryBilling != null? conWrap?.countryBilling : null;
                            newPAP.CC_Billing_Address__StateCode__s  = conWrap?.stateBilling != null? conWrap?.stateBilling : null;
                            newPAP.CC_Billing_Address__PostalCode__s  = conWrap?.zipCodeBilling != null? conWrap?.zipCodeBilling : null;
                            newPAP.CC_County_Billing__c  = conWrap?.billingCounty != null? conWrap?.billingCounty : null;
                            newPAP.CC_Billing_County_Other__c  = conWrap?.billingcountyOther != null? conWrap?.billingcountyOther : null;
                            newPAP.CC_Apt_Suite__c  = conWrap?.billingapartmentSuite != null? conWrap?.billingapartmentSuite : null;
                            
                            newPAP.CC_Is_Mailing_Same_as_Billing__c  = conWrap.mailingSameAsPhysical != null? conWrap.mailingSameAsPhysical:false;
                            
                            newPAP.CC_Date_Of_Hire__c  = String.isNotBlank(conWrap.dateOfHire)? Date.valueOf(conWrap.dateOfHire) : null;
                        }
                        if(conWrap.memberType == 'household'){
                            newPAP.CC_Role__c  = '';
                            newPAP.RecordTypeId = familyHouseholdRecTypeId;
                            newPAP.CC_Relationship_Type__c  = conWrap.relationShip;
                        }
                        
                        // if(ifLgc){
                            //     Map<String, String> tempMap = (Map<String, String>)resultMap.get(conWrap.emailAddress);
                            //     if(tempMap != null){
                                //         newPAP.CC_Business_Management_Record_Info__c = tempMap.get('CC_Business_Management_Record_Info__c');
                                //         newPAP.CC_Development_Maintenance_of_Programs__c = tempMap.get('CC_Development_Maintenance_of_Programs__c');
                                //         newPAP.CC_Other_Responsibilities__c = tempMap.get('CC_Other_Responsibilities__c');
                            //     }
                        // }
                        if (newAccEmailToIdMap.containsKey(conWrap.emailAddress)) {
                            conWrap.memberAccountId = newAccEmailToIdMap.get(conWrap.emailAddress);
                        }
                        // uncomment after testing***********
                        // if(String.isNotBlank(conWrap.memberPapId)){
                            //     newPAP.Id = conWrap.memberPapId;
                        // }
                        
                        papRecords.add(newPAP);
                    //}
                    
                // }
            }
            String directorId = '';
            if(!papRecords.isEmpty()){
                
                List<Id> papRecordIds = new List<Id>();
                papRecords =  (List<CC_Application_Contact__c>)CC_NoSharing_Utility.noSharingUpsert(papRecords,true);
                for(CC_Application_Contact__c iterPap : papRecords){
                    if(iterPap.CC_Role__c == 'Director'){
                        directorId = iterPap.Id;
                    }
                    if(iterPap.CC_Applicant__c != null){
                        newAccIdPAPIdMap.put(iterPap.CC_Applicant__c,  iterPap.id);
                    }
                    newEmailPapIdMap.put(iterPap.CC_Email__c,  iterPap.id);
                    papRecordIds.add(iterPap.id);
                }
                for(ContactRoleRelationWrapper conWrap : membersList){
                    if (newAccIdPAPIdMap.containsKey(conWrap.memberAccountId)) {
                        conWrap.memberPapId = newAccIdPAPIdMap.get(conWrap.memberAccountId);
                    }
                }
                // if(!papRecordIds.isEmpty()){
                //     sendBRCEmail(papRecordIds);
                // }
            }
            List<CC_Application_Specification__c> appSpecList = new List<CC_Application_Specification__c>();
            for(CC_Application_Specification__c appSpec: newPAPIdAppSpecRecords){
                System.debug('2499 app spec ' + directorId);
                //SM - Commenting this line as new field is in place (CC_Application_Contact__c)
                //appSpec.CC_Public_Application_Participant__c = directorId;
                appSpec.CC_Application_Contact__c = directorId;
                appSpecList.add(appSpec);
            }

            if(!appSpecList.isEmpty()){
                appSpecList =  (List<CC_Application_Specification__c>)CC_NoSharing_Utility.noSharingUpsert(appSpecList,true);
            }
            List<Object> trackValues = new List<Object>();
            
            for (Object value : declarationStepInfo.values()) {
                if (value instanceof List<Object>) {
                    trackValues.addAll((List<Object>)value);
                     System.debug('trackValues2482======='+trackValues);
                } else {
                    trackValues.add(value);
                }
            }
            
            for (Object appSpecific : trackValues) {
                CC_Application_Specification__c newAppSpecific = new CC_Application_Specification__c();
                Map<String, Object> appSpecificMap = (Map<String, Object>) appSpecific;
                newAppSpecific.CC_Provider__c = providerAccId;
                newAppSpecific.CC_BusinessLicenseApplication__c = blaRecord.Id;
                newAppSpecific.CC_PreliminaryApplicationRef__c = parId;
                
                if (appSpecificMap.containsKey('selectedPerson')) {
                    //SM - Commenting this line as new field is in place (CC_Application_Contact__c)
                    //newAppSpecific.CC_Public_Application_Participant__c = newEmailPapIdMap.get((String) appSpecificMap.get('selectedPerson'));
                    newAppSpecific.CC_Application_Contact__c = newEmailPapIdMap.get((String) appSpecificMap.get('selectedPerson'));
                    
                    newAppSpecific.CC_Charges_Date__c = appSpecificMap.containsKey('chargesDate') && String.isNotBlank((String) appSpecificMap.get('chargesDate'))
                        ? Date.valueOf((String) appSpecificMap.get('chargesDate'))
                        : null;
                    newAppSpecific.CC_Charges_State__c = appSpecificMap.containsKey('stateInWhichCharged') && String.isNotBlank((String) appSpecificMap.get('stateInWhichCharged'))
                        ? (String) appSpecificMap.get('stateInWhichCharged')
                        : null;
                    newAppSpecific.CC_Conviction_and_Disposition_Date__c = appSpecificMap.containsKey('convictionDate') && String.isNotBlank((String) appSpecificMap.get('convictionDate'))
                        ? Date.valueOf((String) appSpecificMap.get('convictionDate'))
                        : null;
                    newAppSpecific.CC_Specification_Type__c = (String) appSpecificMap.get('typeOfAppSpec');
                    newAppSpecific.CC_Nature_of_Conviction_and_Disposition__c = (String) appSpecificMap.get('natureOfConviction');
                    newAppSpecific.CC_Place_of_Conviction_and_Disposition__c = (String) appSpecificMap.get('convictionPlace');
                    newAppSpecific.CC_State_Resided_From__c = appSpecificMap.containsKey('dateLivedFrom') && String.isNotBlank((String) appSpecificMap.get('dateLivedFrom'))
                        ? Date.valueOf((String) appSpecificMap.get('dateLivedFrom'))
                        : null;
                    newAppSpecific.CC_State_Resided_To__c = appSpecificMap.containsKey('dateLivedTo') && String.isNotBlank((String) appSpecificMap.get('dateLivedTo'))
                        ? Date.valueOf((String) appSpecificMap.get('dateLivedTo'))
                        : null;
                    newAppSpecific.CC_Type_of_Charges__c = (String) appSpecificMap.get('typeOfCharges');
                    newAppSpecific.CC_State_Resided__c = (String) appSpecificMap.get('stateLivedIn');
                }
                
                if (appSpecificMap.containsKey('memberScheduleId')) {
                    newAppSpecific.Id = (String) appSpecificMap.get('memberScheduleId');
                }
                
                appSpecificRecords.add(newAppSpecific);
            }
            
            if (!appSpecificRecords.isEmpty()) {
                appSpecificRecords = (List<CC_Application_Specification__c>) CC_DML.doUpsert(appSpecificRecords, false);
                
                for (CC_Application_Specification__c iterAppSpec : appSpecificRecords) {
                    //SM - Commenting this line as new field is in place (CC_Application_Contact__c)
                    //newPAPIdScheduleIdMap.put(iterAppSpec.CC_Public_Application_Participant__c, iterAppSpec.Id);
                    newPAPIdScheduleIdMap.put(iterAppSpec.CC_Application_Contact__c, iterAppSpec.Id);
                }
                
                for (String key : declarationStepInfo.keySet()) {
                    List<Object> records = (List<Object>)declarationStepInfo.get(key);
                    for (Integer i = 0; i < records.size(); i++) {
                        Map<String, Object> recordMap = (Map<String, Object>) records[i];
                        if (newEmailPapIdMap.containsKey((String) recordMap.get('selectedPerson'))) {
                            recordMap.put('memberscheduleId', newPAPIdScheduleIdMap.get(newEmailPapIdMap.get((String) recordMap.get('selectedPerson'))));
                        }
                        records[i] = recordMap;
                    }
                    
                    System.debug('records[i]--------2541'+ records);
                    declarationStepInfo.put(key, records);
                }
            }
            
            contactRoleRelationInfo.put('contactRoleRelationList', membersList);
            contactRoleRelationInfo.put('declarationStepInfo', declarationStepInfo);
            applicationJsonMap.put('contactRoleRelationInfo', contactRoleRelationInfo);
            

            // Deserialize the JSON string into a Map for familyAssociationStep
            if(applicationJsonMap.containsKey('familyAssociationStepInfo')) {
                List<Object> familyAssociationStepInfo = (List<Object>) applicationJsonMap.get('familyAssociationStepInfo');
                if(!familyAssociationStepInfo.isEmpty()){
                    List<CC_Family_Association__c> familiesToInsert = new List<CC_Family_Association__c>();
                    List<CC_Application_Contact__c> childrenToInsert = new List<CC_Application_Contact__c>();
                    List<CC_Application_Contact__c> familyParticipantsToInsert = new List<CC_Application_Contact__c>();
            
                    // Step 1: Prepare families to insert
                    for (Object familyObj : familyAssociationStepInfo) {
                        Map<String, Object> familyMap = (Map<String, Object>) familyObj;
            
                        CC_Family_Association__c newFamily = new CC_Family_Association__c(
                            CC_Parent_First_Name__c = familyMap.get('parentFirstName') != null ? (String) familyMap.get('parentFirstName') : null,
                            CC_Parent_Middle_Name__c = familyMap.get('parentMiddleName') != null ? (String) familyMap.get('parentMiddleName') : null,
                            CC_Parent_Last_Name__c = familyMap.get('parentLastName') != null ? (String) familyMap.get('parentLastName') : null,
                            CC_Phone_Number__c = familyMap.get('parentPhone') != null ? (String) familyMap.get('parentPhone') : null,
                            CC_Email_ID__c = familyMap.get('email') != null ? (String) familyMap.get('email') : null,
                            CC_Are_the_children_a_sibling_group__c = familyMap.get('siblingGroup') != null ? (String) familyMap.get('siblingGroup') : null,
                            CC_Included_in_Parent_s_TANF_grant__c = familyMap.get('includedParentTanf') != null ? (String) familyMap.get('includedParentTanf') : null,
                            CC_Parent_Address__Street__s = familyMap.get('streetBilling') != null ? (String) familyMap.get('streetBilling') : null,
                            CC_Parent_Address__City__s = familyMap.get('cityBilling') != null ? (String) familyMap.get('cityBilling') : null,
                            CC_Parent_Address__CountryCode__s = familyMap.get('countryBilling') != null ? (String) familyMap.get('countryBilling') : null,
                            CC_Parent_Address__StateCode__s = familyMap.get('stateBilling') != null ? (String) familyMap.get('stateBilling') : null,
                            CC_Parent_Address__PostalCode__s = familyMap.get('zipCodeBilling') != null ? (String) familyMap.get('zipCodeBilling') : null,
                            CC_County_Billing__c = familyMap.get('billingCounty') != null ? (String) familyMap.get('billingCounty') : null,
                            CC_Apt_Suite__c = familyMap.get('billingapartmentSuite') != null ? (String) familyMap.get('billingapartmentSuite') : null,
                            CC_Preliminary_Application_Reference__c = parId,
                            CC_Business_License_Application__c = blaRecord.Id,
                            CC_Benefit_Case_Number__c = familyMap.get('benefitCaseNum') != null ? (String) familyMap.get('benefitCaseNum') : null
                        );
                        familiesToInsert.add(newFamily);
                    }
            
                    // Step 2: Insert families and get their IDs
                    if(!familiesToInsert.isEmpty()){
                        familiesToInsert = (List<CC_Family_Association__c>)CC_DML.doUpsert(familiesToInsert, true);
                    }
            
                    // Step 3: Prepare children to insert
                    for (Integer i = 0; i < familyAssociationStepInfo.size(); i++) {
                        Map<String, Object> familyMap = (Map<String, Object>) familyAssociationStepInfo[i];
                        CC_Family_Association__c currentFamily = familiesToInsert[i]; // Get the corresponding Family record
            
                        List<Object> children = (List<Object>) familyMap.get('children');
                        if (children != null && !children.isEmpty()) {
                            for (Object childObj : children) {
                                Map<String, Object> childMap = (Map<String, Object>) childObj;
            
                                CC_Application_Contact__c newChild = new CC_Application_Contact__c(
                                    CC_First_Name__c = childMap.get('childFirstName') != null ? (String) childMap.get('childFirstName') : null,
                                    CC_Middle_Name__c = childMap.get('childMiddleName') != null ? (String) childMap.get('childMiddleName') : null,
                                    CC_Last_Name__c = childMap.get('childLastName') != null ? (String) childMap.get('childLastName') : null,
                                    CC_Date_of_Birth__c = childMap.get('childDob') != null ? Date.valueOf((String) childMap.get('childDob')) : null,
                                    CC_Child_Age__c = childMap.get('childAge') != null ? (Decimal) childMap.get('childAge') : null,
                                    CC_Relationship_to_Provider__c = childMap.get('childRelationship') != null ? (String) childMap.get('childRelationship') : null,
                                    CC_Foster_Placement__c = childMap.get('fosterPlacement') != null ? (String) childMap.get('fosterPlacement') : null,
                                    CC_Family_Association__c = currentFamily.Id,
                                    CC_Applicant__c  = currentUserDetails.AccountId,
                                    CC_Business_License_Application__c = blaRecord.Id,
                                    CC_Preliminary_Application_Reference__c = parId,
                                    CC_Immunization_Attestation__c = childMap.get('immunAttestationCheck') != null ? (Boolean) childMap.get('immunAttestationCheck') : false,
                                    CC_Child_Information_Does_not_Matched__c = childMap.get('childInfoNotMatched') != null ? (Boolean) childMap.get('childInfoNotMatched') : false,
                                    CC_Family_Association_Type__c = 'Child',
                                    RecordTypeId = Schema.SObjectType.CC_Application_Contact__c.getRecordTypeInfosByDeveloperName().get(CC_Constants.PAP_FAMILY_MEMBER_RECORD_TYPE).getRecordTypeId()
                                );
                                childrenToInsert.add(newChild);
                            }
                        }
                    }
            
                    // Step 4: Insert children and get their IDs
                    if(!childrenToInsert.isEmpty()){
                        childrenToInsert = (List<CC_Application_Contact__c>)CC_NoSharing_Utility.noSharingUpsert(childrenToInsert, true);
                    }
            
                    // Step 5: Create Application Contact records for families
                    for (CC_Family_Association__c forPap : familiesToInsert) {
                        CC_Application_Contact__c newFamilyPap = new CC_Application_Contact__c(
                            CC_First_Name__c = forPap?.CC_Parent_First_Name__c,
                            CC_Middle_Name__c = forPap?.CC_Parent_Middle_Name__c,
                            CC_Last_Name__c = forPap?.CC_Parent_Last_Name__c,
                            CC_Phone__c = forPap?.CC_Phone_Number__c,
                            CC_Email__c = forPap?.CC_Email_ID__c,
                            CC_Are_the_children_a_sibling_group__c = forPap?.CC_Are_the_children_a_sibling_group__c,
                            CC_Included_in_Parent_s_TANF_grant__c = forPap?.CC_Included_in_Parent_s_TANF_grant__c,
                            CC_Billing_Address__Street__s = forPap?.CC_Parent_Address__Street__s,
                            CC_Billing_Address__City__s = forPap?.CC_Parent_Address__City__s,
                            CC_Billing_Address__CountryCode__s = forPap?.CC_Parent_Address__CountryCode__s,
                            CC_Billing_Address__StateCode__s = forPap?.CC_Parent_Address__StateCode__s,
                            CC_Billing_Address__PostalCode__s = forPap?.CC_Parent_Address__PostalCode__s,
                            CC_County_Billing__c = forPap?.CC_County_Billing__c,
                            CC_Apt_Suite__c = forPap?.CC_Apt_Suite__c,
                            CC_Preliminary_Application_Reference__c = forPap?.CC_Preliminary_Application_Reference__c,
                            CC_Business_License_Application__c = forPap?.CC_Business_License_Application__c,
                            CC_Family_Association__c = forPap.Id,
                            CC_Applicant__c = currentUserDetails.AccountId,
                            RecordTypeId = Schema.SObjectType.CC_Application_Contact__c.getRecordTypeInfosByDeveloperName().get(CC_Constants.PAP_FAMILY_MEMBER_RECORD_TYPE).getRecordTypeId(),
                            CC_Family_Association_Type__c = 'Parent'
                        );
                        familyParticipantsToInsert.add(newFamilyPap);
                    }
            
                    // Step 6: Insert family participants and get their IDs
                    if(!familyParticipantsToInsert.isEmpty()){
                        familyParticipantsToInsert = (List<CC_Application_Contact__c>)CC_NoSharing_Utility.noSharingUpsert(familyParticipantsToInsert, true);
                    }
            
                    // Step 7: Create a Map for child IDs for quick lookup
                    Map<String, Id> childIdMap = new Map<String, Id>();
                    for (CC_Application_Contact__c child : childrenToInsert) {
                        childIdMap.put(child.CC_Family_Association__c + '-' + child.CC_First_Name__c + '-' + child.CC_Last_Name__c, child.Id);
                    }
            
                    // Step 8: Update familyAssociationStepInfo with new IDs
                    for (Integer i = 0; i < familyAssociationStepInfo.size(); i++) {
                        Map<String, Object> familyMap = (Map<String, Object>) familyAssociationStepInfo[i];
                        CC_Family_Association__c currentFamily = familiesToInsert[i]; // Get the corresponding Family record
            
                        // Update family record ID
                        familyMap.put('familyRecordId', CC_CommonUtility.performEncryption(currentFamily.Id));
            
                        // Update FamilyPapRecordId
                        if (i < familyParticipantsToInsert.size()) {
                            CC_Application_Contact__c familyPap = familyParticipantsToInsert[i];
                            familyMap.put('familyPapRecordId', CC_CommonUtility.performEncryption(familyPap.Id));
                        }
            
                        // Update childRecordId for each child in the family
                        List<Object> children = (List<Object>) familyMap.get('children');
                        if (children != null && !children.isEmpty()) {
                            for (Object childObj : children) {
                                Map<String, Object> childMap = (Map<String, Object>) childObj;
                                String childKey = currentFamily.Id + '-' + childMap.get('childFirstName') + '-' + childMap.get('childLastName');
                                if (childIdMap.containsKey(childKey)) {
                                    // Update child record ID
                                    childMap.put('childRecordId', CC_CommonUtility.performEncryption(childIdMap.get(childKey)));
                                }
                            }
                        }
                    }
            
                    // Optionally, you can update the familyAssociationStepInfo back to the applicationJsonMap if needed
                    applicationJsonMap.put('familyAssociationStepInfo', familyAssociationStepInfo);
                }
            }
            if(contactRoleRelationInfo.containsKey('deletedMemberList') && contactRoleRelationInfo.get('deletedMemberList') != null && !((List<Object>)contactRoleRelationInfo.get('deletedMemberList')).isEmpty()) {
                
                List<DeletedMembers> deletedMemberList = (List<DeletedMembers>)JSON.deserialize(
                    JSON.serialize(contactRoleRelationInfo.get('deletedMemberList')),
                List<DeletedMembers>.class
                    );
                List<SObject> listTobedeleted = new List<SObject>();
                
                for(DeletedMembers iterList : deletedMemberList) {
                    if(String.isNotBlank(iterList.memberScheduleId)) {
                        listTobedeleted.add(new CC_Application_Specification__c(Id = iterList.memberScheduleId)); // Replace CustomObject__c with actual object type
                    }
                    if(String.isNotBlank(iterList.memberPapId)) {
                        listTobedeleted.add(new CC_Application_Contact__c(Id = iterList.memberPapId)); // Replace CustomObject__c with actual object type
                    }
                    if(iterList.isCurrentlyEnrolled == 'No' && String.isNotBlank(iterList.memberAccountId)) {
                        listTobedeleted.add(new Account(Id = iterList.memberAccountId)); // Example with Account object
                    }
                }
                
                if(!listTobedeleted.isEmpty()) {
                    CC_NoSharing_Utility.noSharingDelete(listTobedeleted, true);
                }
            }

            return applicationJsonMap;
            
            
        } catch (Exception e) {
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
        
    }
    
    
    
    
    public class ContactWrapper
    {
        @AuraEnabled public String accountId {get;set;}
        @AuraEnabled public String employerName {get;set;}
        @AuraEnabled public String workforceId {get;set;}
        @AuraEnabled public String emailAddress {get;set;}
        @AuraEnabled public String firstName {get;set;}
        @AuraEnabled public String lastName {get;set;}
        @AuraEnabled public String middleName {get;set;}
        @AuraEnabled public String dateOfBirth {get;set;}
        @AuraEnabled public Date startDate {get;set;}
        @AuraEnabled public String formatedDob {get;set;}
        @AuraEnabled public String ssn {get;set;}
        @AuraEnabled public String decryptedSsn {get;set;}
        @AuraEnabled public String gender {get;set;}
        @AuraEnabled public String suffix {get;set;}
        @AuraEnabled public String otherName {get;set;}
        @AuraEnabled public String race {get;set;}
        @AuraEnabled public String contactId {get;set;}
        @AuraEnabled public String ethnicity {get;set;}
        @AuraEnabled public String phoneNum {get;set;}
        
        @AuraEnabled public String streetMailing {get;set;}
        @AuraEnabled public String cityMailing {get;set;}
        @AuraEnabled public String countryMailing {get;set;}
        @AuraEnabled public String stateMailing {get;set;}
        @AuraEnabled public String zipCodeMailing {get;set;}
        @AuraEnabled public String mailingCounty {get;set;}
        @AuraEnabled public String mailingcountyOther {get;set;}
        
        @AuraEnabled public String streetBilling {get;set;}
        @AuraEnabled public String cityBilling {get;set;}
        @AuraEnabled public String countryBilling {get;set;}
        @AuraEnabled public String stateBilling {get;set;}
        @AuraEnabled public String zipCodeBilling {get;set;}
        @AuraEnabled public String billingCounty {get;set;}
        @AuraEnabled public String billingcountyOther {get;set;}
        
        @AuraEnabled public Boolean mailingSameAsPhysical {get;set;}        
        
        public ContactWrapper(){}
        public ContactWrapper(String accountId, String employerName, String workforceId, String emailAddress, String formatedDob,String firstName,String lastName,String middleName,String dateOfBirth,Date startDate) {
            this.accountId = (accountId != null) ? accountId : '';
            this.employerName = (employerName != null) ? employerName : '';
            this.workforceId = (workforceId != null) ? workforceId : '';
            this.emailAddress = (emailAddress != null) ? emailAddress : '';
            this.firstName = (firstName != null) ? firstName : '';
            this.lastName = (lastName != null) ? lastName : '';
            this.middleName = (middleName != null) ? middleName : '';
            this.employerName = (employerName != null) ? employerName : '';
            this.dateOfBirth = (dateOfBirth != null) ? dateOfBirth : '';
            this.startDate = startDate;
            this.formatedDob = formatedDob;
        }
    }
    
    public class ContactRoleRelationWrapper {
        @AuraEnabled public String recordId {get;set;}
        @AuraEnabled public String typeOfMember {get;set;}
        @AuraEnabled public String startDate {get;set;}
        // @AuraEnabled public String selectedRole {get;set;}
        @AuraEnabled public String selectedRoleType {get;set;}
        // @AuraEnabled public String isLicensee {get;set;}
        // @AuraEnabled public String otherRole {get;set;}
        @AuraEnabled public String dateOfBirth {get;set;}
        @AuraEnabled public String requestedDate {get;set;}

        //Added by Payal:
        @AuraEnabled public String providingChildcareIn {get;set;}
        
        
        @AuraEnabled public String endDate {get;set;}
        // @AuraEnabled public Decimal numberOfHours {get;set;}
        // @AuraEnabled public String householdRelation {get;set;}
        @AuraEnabled public String emailAddress {get;set;}
        @AuraEnabled public String employerName {get;set;}
        @AuraEnabled public String workforceId {get;set;}
        @AuraEnabled public String curentlyEnrolled {get;set;}
        @AuraEnabled public String selectedAccountId {get;set;}
        @AuraEnabled public Boolean chooseExisting {get;set;}
        @AuraEnabled public Boolean chooseNew {get;set;}
        @AuraEnabled public String firstName {get;set;}
        @AuraEnabled public String lastName {get;set;}
        @AuraEnabled public String middleName {get;set;}
        @AuraEnabled public String providerAccId {get;set;}
        @AuraEnabled public String status {get;set;}
        @AuraEnabled public Boolean isActive {get;set;}
        @AuraEnabled public Boolean isOldMember {get;set;}
        @AuraEnabled public List<SelectedDay> selectedDays {get;set;}
        
        //brc related fields
        @AuraEnabled public String brcStatus {get;set;}
        @AuraEnabled public String brcConsentStatus {get;set;}
        @AuraEnabled public Date brcFingerprintingScanDate {get;set;}
        @AuraEnabled public Date brcRenewalDate {get;set;}
        @AuraEnabled public Date brcFingerprintingResultDate {get;set;}
        @AuraEnabled public Date brcExpirationDate {get;set;}
        
        //wrapper additional elements for additional info flow
        @AuraEnabled public String formatedDob {get;set;}
        @AuraEnabled public String workforceSearch {get;set;}
        @AuraEnabled public String searchByValue {get;set;}
        @AuraEnabled public List<ContactWrapper> contactList {get;set;}
        @AuraEnabled public Boolean searchByInfo {get;set;}
        @AuraEnabled public Boolean searchByWorkforce {get;set;}
        @AuraEnabled public Boolean selectedValue {get;set;}
        @AuraEnabled public String memberScheduleId {get;set;}
        @AuraEnabled public String memberPapId {get;set;}
        @AuraEnabled public String memberAccountId {get;set;}
        
        @AuraEnabled public String streetMailing {get;set;}
        @AuraEnabled public String cityMailing {get;set;}
        @AuraEnabled public String countryMailing {get;set;}
        @AuraEnabled public String stateMailing {get;set;}
        @AuraEnabled public String zipCodeMailing {get;set;}
        @AuraEnabled public String mailingCounty {get;set;}
        @AuraEnabled public String mailingcountyOther {get;set;}
        
        @AuraEnabled public String streetBilling {get;set;}
        @AuraEnabled public String cityBilling {get;set;}
        @AuraEnabled public String countryBilling {get;set;}
        @AuraEnabled public String stateBilling {get;set;}
        @AuraEnabled public String zipCodeBilling {get;set;}
        @AuraEnabled public String billingCounty {get;set;}
        @AuraEnabled public String billingcountyOther {get;set;}
         @AuraEnabled public String papId {get;set;}

        
        @AuraEnabled public Boolean mailingSameAsPhysical {get;set;}
        
        @AuraEnabled public String ssn {get;set;}
        @AuraEnabled public String decryptedSsn {get;set;}
        @AuraEnabled public String gender {get;set;}
        //@AuraEnabled public String suffix {get;set;}
        @AuraEnabled public String otherName {get;set;}
        @AuraEnabled public String ethnicity {get;set;}
        @AuraEnabled public String race {get;set;}
        @AuraEnabled public String phoneNum {get;set;}
        @AuraEnabled public String alternatePhoneNum {get;set;}
        @AuraEnabled public String alternatePhoneType {get;set;}
        @AuraEnabled public String dateOfHire {get;set;}
        
        @AuraEnabled public Boolean typeEdit {get;set;}
        @AuraEnabled public String memberType {get;set;}
        @AuraEnabled public String relationShip {get;set;}
        @AuraEnabled public String mailingapartmentSuite {get;set;}
        @AuraEnabled public String billingapartmentSuite {get;set;}
        
        @AuraEnabled public Boolean selfHhMember {get;set;}
        @AuraEnabled public String suffix {get;set;}
        @AuraEnabled public String emailType {get;set;}
        @AuraEnabled public String phoneType {get;set;}
        @AuraEnabled public String terminationDate {get;set;}
         @AuraEnabled public String workingHours {get;set;}  
        @AuraEnabled public Boolean medAdminAttestationCheck {get;set;}
        
        
        public ContactRoleRelationWrapper() {}
        
        public ContactRoleRelationWrapper(String typeOfMember, String startDate, List<SelectedDay> selectedDays,
        String selectedRoleType, String dateOfBirth, String emailAddress,
        String employerName, String workforceId, String curentlyEnrolled, String selectedAccountId,String endDate,
        Boolean chooseExisting, Boolean chooseNew, String firstName, String lastName, String middleName, String providerAccId,
        String formatedDob,String workforceSearch,String searchByValue,Boolean searchByInfo,Boolean searchByWorkforce,List<ContactWrapper> contactList,
        Boolean selectedValue,String memberScheduleId,String memberPapId,String memberAccountId, String phoneType) {
            this.typeOfMember = typeOfMember != null ? typeOfMember : '';
            this.startDate = startDate != null ? startDate : '';
            this.endDate = endDate != null ? endDate : '';
            // this.selectedRole = selectedRole != null ? selectedRole : '';
            this.selectedRoleType = selectedRoleType != null ? selectedRoleType : '';
            // this.isLicensee = isLicensee != null? isLicensee : '';
            this.dateOfBirth = dateOfBirth != null ? dateOfBirth : null;
            this.emailAddress = emailAddress != null ? emailAddress : '';
            this.employerName = employerName != null ? employerName : '';
            this.workforceId = workforceId != null ? workforceId : '';
            this.curentlyEnrolled = curentlyEnrolled != null ? curentlyEnrolled : '';
            this.selectedAccountId = selectedAccountId != null ? selectedAccountId : '';
            this.chooseExisting = chooseExisting != null ? chooseExisting : false;
            this.chooseNew = chooseNew != null ? chooseNew : false;
            this.firstName = firstName != null ? firstName : '';
            this.lastName = lastName != null ? lastName : '';
            this.middleName = middleName != null ? middleName : '';
            this.providerAccId = providerAccId != null ? providerAccId : '';
            this.status = status != null ? status : '';
            this.phoneType = phoneType != null ? phoneType : '';
            // this.householdRelation = householdRelation != null ? householdRelation : '';
            // this.numberOfHours = numberOfHours != null ? numberOfHours : 0.0;
            this.formatedDob = formatedDob;
            this.workforceSearch = workforceSearch;
            this.searchByValue = searchByValue;
            this.contactList = contactList != null? contactList : new List<ContactWrapper>();
            this.searchByInfo = searchByInfo;
            this.searchByWorkforce = searchByWorkforce;
            this.chooseNew = chooseNew;
            this.chooseExisting = chooseExisting;
            this.selectedValue = selectedValue;
            this.memberScheduleId = memberScheduleId;
            this.memberPapId = memberPapId;
            this.memberAccountId = memberAccountId;
        }
    }
    
    
    public class SelectedDay {
        @AuraEnabled public String formattedEndTime {get;set;}
        @AuraEnabled public String formattedStartTime {get;set;}
        @AuraEnabled public Boolean copyToAll {get;set;}
        @AuraEnabled public String day {get;set;}
        @AuraEnabled public String endTime {get;set;}
        @AuraEnabled public String startTime {get;set;}
        @AuraEnabled public String className {get;set;}
        @AuraEnabled public String value {get;set;}
        @AuraEnabled public String label {get;set;}
        
        public SelectedDay() {}
        
        public SelectedDay(String day, String startTime, String endTime, Boolean copyToAll, String label) {
            this.day = day != null ? day : null;
            this.startTime = startTime != null ? startTime : null ;
            this.endTime = endTime != null ? endTime : null;
            this.formattedStartTime = formatTime(startTime) != null ? formatTime(startTime) : null;
            this.formattedEndTime = formatTime(endTime) != null ? formatTime(endTime) : null;
            this.copyToAll = copyToAll != null ?  copyToAll : false;
            this.className = 'base-link-btn-no-icon slds-badge slds-theme_info day-badge-active';
            this.value = day  != null ? day : null;
            this.label = label != null ? label : null;
        }
    }

    public class DeclarationRecords {
        @AuraEnabled public String typeOfAppSpec {get;set;}
        @AuraEnabled public String typeOfCharges {get;set;}
        @AuraEnabled public String chargesDate {get;set;}
        @AuraEnabled public String stateInWhichCharged {get;set;}
        @AuraEnabled public String convictionPlace {get;set;}
        @AuraEnabled public String natureOfConviction {get;set;}
        @AuraEnabled public String convictionDate {get;set;}
        @AuraEnabled public String dateLivedTo {get;set;}
        @AuraEnabled public String dateLivedFrom {get;set;}
        @AuraEnabled public String stateLivedIn {get;set;}
        @AuraEnabled public String selectedPerson {get;set;}
        @AuraEnabled public String selectedPersonLabel {get;set;}
        @AuraEnabled public String uniqueKey {get;set;}
        @AuraEnabled public String memberscheduleId {get;set;}
    }
    
    
    public class DeletedMembers{
        @AuraEnabled public String memberScheduleId{get; set;}
        @AuraEnabled public String memberPapId{get; set;}
        @AuraEnabled public String memberAccountId{get; set;}
        @AuraEnabled public String isCurrentlyEnrolled{get; set;}
        public DeletedMembers(String memberScheduleId,String memberPapId,String memberAccountId,String isCurrentlyEnrolled){
            this.memberScheduleId = memberScheduleId;
            this.memberPapId = memberPapId;
            this.memberAccountId = memberAccountId;
            this.isCurrentlyEnrolled = isCurrentlyEnrolled;
        }
    }
    
    
    
    // private static Map<String, List<String>> getMultiplePicklistValues() {
        //     List<String> fieldApiNames = new List<String>{
            //         'CC_Business_Management_Record_Info__c',
            //         'CC_Development_Maintenance_of_Programs__c',
            //         'CC_Other_Responsibilities__c'
        //     };
        
        //     Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get('PublicApplicationParticipant').getDescribe();
        //     Map<String, Schema.RecordTypeInfo> recordTypes = objectDescribe.getRecordTypeInfosByName();
        //     Schema.RecordTypeInfo recordTypeInfo = recordTypes.get('Provider Staff');
        
        //     if (recordTypeInfo == null) {
            //         return null;
        //     }
        
        //     Map<String, List<String>> picklistValuesMap = new Map<String, List<String>>();
        
        
        //     for (Integer i = 0; i < fieldApiNames.size(); i++) {
            //         String fieldApiName = fieldApiNames[i];
            //         Schema.DescribeFieldResult fieldDescribe = objectDescribe.fields.getMap().get(fieldApiName).getDescribe();
            //         List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();
            
            //         List<String> picklistOptions = new List<String>();
            //         for (Integer j = 0; j < picklistEntries.size(); j++) {
                //             Schema.PicklistEntry entry = picklistEntries[j];
                //             picklistOptions.add(entry.getValue());
            //         }
            
            //         picklistValuesMap.put(fieldApiName, picklistOptions);
        //     }
        
        //     return picklistValuesMap;
    // }
    // private static Map<String, Map<String, String>> mapDesignationsToPicklistValues(Map<String, Object>  applicationJsonMap) {
        //     Map<String, Map<String, String>> resultMap = new Map<String, Map<String, String>>();
        //     if(applicationJsonMap.get('designationMap') != null){
            //         Map<String, Object> designationMap = (Map<String, Object>) applicationJsonMap.get('designationMap');
            //         Map<String, List<String>> mapOfPicklistValues = getMultiplePicklistValues();
            
            
            //         // Populate the resultMap
            //         for (String email : designationMap.keySet()) {
                //             List<String> selectedValues = ((String)designationMap.get(email)).split(';');
                //             Map<String, String> emailMapping = new Map<String, String>();
                
                //             // Construct the mapping for each field
                //             emailMapping.put('CC_Business_Management_Record_Info__c', getMatchingValues(mapOfPicklistValues.get('CC_Business_Management_Record_Info__c'), selectedValues));
                //             emailMapping.put('CC_Development_Maintenance_of_Programs__c', getMatchingValues(mapOfPicklistValues.get('CC_Development_Maintenance_of_Programs__c'), selectedValues));
                //             emailMapping.put('CC_Other_Responsibilities__c', getMatchingValues(mapOfPicklistValues.get('CC_Other_Responsibilities__c'), selectedValues));
                
                //             resultMap.put(email, emailMapping);
            //         }
        //     }
        
        //     return resultMap;
    // }
    
    // private static String getMatchingValues(List<String> picklistValues, List<String> selectedValues) {
        //     List<String> matchingValues = new List<String>();
        
        //     for (String value : picklistValues) {
            //         if (selectedValues.contains(value)) {
                //             matchingValues.add(value);
            //         }
        //     }
        //     if(matchingValues.isEmpty()){
            //         return null;
        //     }
        //     return String.join(matchingValues, ';');
    // }
    
    //UnComment the method after changing the class name 
    @AuraEnabled
    public static String checkForDuplicateStaff(ContactWrapper tobeSearchedContact) {
        /*try {
            List<Contact> dupCheckList =  Copy_Copy_CC_NoSharing_DAO.contactsDuplicates(tobeSearchedContact);
            if(dupCheckList.size()>0){
                return 'Member account already exists with same details in the system';
            }else{
                return 'No Duplicate';
            }
        } catch (Exception e) {
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }*/
        return null;
    }
    
    
    @AuraEnabled
    public static Map<String,Object> fetchExistingMembers(String facilityId) {
        try {
            Map<String,Object> resultMap = new Map<String,Object>();
            facilityId = CC_CommonUtility.performDecryption(facilityId);
            List<ContactRoleRelationWrapper> wrapperList = new List<ContactRoleRelationWrapper>();
            list<CC_Contact_Role_Relationship__c> contactRoleRecords= CC_NoSharing_DAO.fetchCrrListByFacilityId(facilityId);
            Set<Id> crrIds = new Set<Id>();
            // Map<Id,Id> crrToAppSpecificMap = new Map<Id,Id>();
            for(CC_Contact_Role_Relationship__c crrRec : contactRoleRecords){
                crrIds.add(crrRec.Id);
            }

            Map<String,List<DeclarationRecords>> appSpecificIdToRecordMap = new Map<String,List<DeclarationRecords>>();
            for(CC_Application_Specification__c appSepRec : CC_ApplicationSpecificationDAO.fetchScheduleDetailsById(crrIds)){
                DeclarationRecords declarationRecords = new DeclarationRecords();
                declarationRecords.typeOfAppSpec = appSepRec?.CC_Specification_Type__c;
                declarationRecords.typeOfCharges = appSepRec?.CC_Type_of_Charges__c;
                declarationRecords.chargesDate = String.valueOf(appSepRec?.CC_Charges_Date__c);
                declarationRecords.stateInWhichCharged = String.valueOf(appSepRec?.CC_Charges_State__c);
                declarationRecords.convictionPlace = appSepRec?.CC_Place_of_Conviction_and_Disposition__c;
                declarationRecords.natureOfConviction = appSepRec?.CC_Nature_of_Conviction_and_Disposition__c;
                declarationRecords.convictionDate = String.valueOf(appSepRec?.CC_Conviction_and_Disposition_Date__c);
                declarationRecords.dateLivedTo = String.valueOf(appSepRec?.CC_State_Resided_To__c);
                declarationRecords.dateLivedFrom = String.valueOf(appSepRec?.CC_State_Resided_From__c);
                declarationRecords.stateLivedIn = appSepRec?.CC_State_Resided__c;
                declarationRecords.selectedPerson = appSepRec?.CC_Contact_Role_Relationship__r?.CC_Email__c;
                declarationRecords.selectedPersonLabel = appSepRec?.CC_Contact_Role_Relationship__r.CC_Contact__r.Name;
                declarationRecords.uniqueKey = CC_CommonUtility.performEncryption(appSepRec?.Id);
                if(appSpecificIdToRecordMap.containsKey(appSepRec?.CC_Contact_Role_Relationship__r?.CC_Email__c)){
                    appSpecificIdToRecordMap.get(appSepRec?.CC_Contact_Role_Relationship__r?.CC_Email__c).add(declarationRecords);
                }
                else{
                    appSpecificIdToRecordMap.put(appSepRec?.CC_Contact_Role_Relationship__r?.CC_Email__c,new List<DeclarationRecords>{declarationRecords});
                }
            }

            List<String> restrictedRolesOrRelationship = new List<String>{CC_Constants.CONTCAT_OWNER_ROLE,CC_Constants.CONTCAT_FACILITY_OWNER_ROLE,CC_Constants.CONTCAT_CO_OWNER_ROLE , CC_Constants.CRR_RELATIONSHIP_SELF};
            
            List<Id> trackUser = new List<Id>();
            for(CC_Contact_Role_Relationship__c crrRec : contactRoleRecords) {
                ContactRoleRelationWrapper wrapper = new ContactRoleRelationWrapper();
                wrapper.recordId = crrRec.Id;
                // wrapper.selectedRole = crrRec.CC_Job_Type__c ;
                wrapper.selectedRoleType = crrRec.CC_Role__c;
                // wrapper.isLicensee = crrRec.CC_Licensee__c? 'Yes' : 'No';
                wrapper.providerAccId = CC_CommonUtility.performEncryption(crrRec.CC_Account__c);
                // wrapper.otherRole = crrRec.CC_Multi_Location_Staff__c == true ? 'Yes': 'No';
                wrapper.startDate = String.valueOf(crrRec.CC_Start_Date__c);
                wrapper.firstName = crrRec.CC_First_Name__c;
                wrapper.lastName = crrRec.CC_Last_Name__c;
                wrapper.middleName = crrRec.CC_Middle_Name__c;
                wrapper.emailAddress = crrRec.CC_Email__c;
                wrapper.selectedAccountId =  crrRec.CC_Contact__r.AccountId;
                wrapper.curentlyEnrolled = 'Yes';
                wrapper.dateOfBirth = String.valueOf(crrRec.CC_Date_of_Birth__c);
                wrapper.dateOfHire = String.valueOf(crrRec.CC_Date_Of_Hire__c);
                // wrapper.dateOfHire = CC_CommonUtility.dateMMddYYYY(Date.valueOf(crrRec.CC_Date_Of_Hire__c));
                wrapper.status = crrRec.CC_Association_Status__c;
                wrapper.workforceId = crrRec.CC_Contact__r.Account?.CC_Person_ID__c;
                wrapper.employerName = crrRec.CC_First_Name__c +' '+ crrRec.CC_Last_Name__c;
                if(crrRec.CC_Middle_Name__c!=null){
                    wrapper.employerName = crrRec.CC_First_Name__c +' '+crrRec.CC_Middle_Name__c+' '+ crrRec.CC_Last_Name__c;
                }
                wrapper.isActive = true;
                wrapper.isOldMember = true;
                wrapper.brcStatus = crrRec.CC_BRC_Status__c ;
                wrapper.brcConsentStatus = crrRec.CC_BRC_Consent_Status__c ;
                wrapper.brcFingerprintingScanDate = crrRec.CC_Fingerprinting_Scan_Date__c ;
                wrapper.brcRenewalDate = crrRec.CC_BRC_Renewal_Date__c ;
                wrapper.brcFingerprintingResultDate = crrRec.CC_Fingerprinting_Result_Date__c ;
                wrapper.brcExpirationDate = crrRec.CC_BRC_Expiration_Date__c ;
                wrapper.typeEdit = false;
                String ssnValue = crrRec?.CC_Contact__r?.Account?.CC_Decrypted_SSN__c;
                wrapper.decryptedSsn = ssnValue;
                wrapper.ssn = crrRec?.CC_Contact__r?.Account?.CC_SSN__c;//ssnValue != null && ssnValue.length() >= 5 ? ssnValue.substring(ssnValue.length() - 5) : ssnValue;
                wrapper.gender = crrRec?.CC_Contact__r?.Account?.PersonGenderIdentity;
                wrapper.race = crrRec?.CC_Contact__r?.Account?.CC_Race_Origin__pc;
                wrapper.ethnicity = crrRec?.CC_Contact__r?.Account?.CC_Ethnicity__c;
                wrapper.phoneNum = crrRec?.CC_Contact__r?.Account?.Phone;
                wrapper.alternatePhoneNum = crrRec?.CC_Contact__r?.Account?.CC_Alternate_Phone_Number__c;
                
                wrapper.streetMailing = crrRec?.CC_Contact__r?.Account?.ShippingStreet;
                wrapper.cityMailing = crrRec?.CC_Contact__r?.Account?.ShippingCity;
                wrapper.countryMailing = crrRec?.CC_Contact__r?.Account?.ShippingCountryCode;
                wrapper.stateMailing = crrRec?.CC_Contact__r?.Account?.ShippingStateCode;
                wrapper.zipCodeMailing = crrRec?.CC_Contact__r?.Account?.ShippingPostalCode;
                wrapper.mailingCounty = crrRec?.CC_Contact__r?.Account?.CC_County_Mailing__c;
                wrapper.mailingcountyOther = crrRec?.CC_Contact__r?.Account?.CC_Shipping_County_Other__c;
                wrapper.mailingapartmentSuite = crrRec?.CC_Contact__r?.Account?.CC_Shipping_Apt_Suite__c;
                
                wrapper.streetBilling = crrRec?.CC_Contact__r?.Account?.BillingStreet;
                wrapper.cityBilling = crrRec?.CC_Contact__r?.Account?.BillingCity;
                wrapper.countryBilling = crrRec?.CC_Contact__r?.Account?.BillingCountryCode;
                wrapper.stateBilling = crrRec?.CC_Contact__r?.Account?.BillingStateCode;
                wrapper.zipCodeBilling = crrRec?.CC_Contact__r?.Account?.BillingPostalCode;
                wrapper.billingCounty = crrRec?.CC_Contact__r?.Account?.CC_County_Billing__c;
                wrapper.billingcountyOther = crrRec?.CC_Contact__r?.Account?.CC_Billing_County_Other__c;
                wrapper.billingapartmentSuite = crrRec?.CC_Contact__r?.Account?.CC_Apt_Suite__c;
                wrapper.mailingSameAsPhysical  = crrRec?.CC_Contact__r?.Account?.CC_Mailing_Address_Same__c;

                wrapper.suffix = crrRec?.CC_Contact__r?.Account?.Suffix;
                wrapper.emailType = crrRec?.CC_Contact__r?.Account?.CC_Email_Type__c;
                wrapper.phoneType = crrRec?.CC_Contact__r?.Account?.CC_Phone_Type__c;
                wrapper.alternatePhoneType = crrRec?.CC_Contact__r?.Account?.CC_Alternate_Phone_Type__c;
                
                wrapper.selfHhMember = false;
                wrapper.relationShip = crrRec.CC_Relationship__c;
                wrapper.memberType = crrRec.Type_Of_Member__c == 'Household'?'household':crrRec.Type_Of_Member__c;
                if((crrRec.CC_Contact__c == currentUserDetails.ContactId) && !trackUser.contains(crrRec.CC_Contact__c)){
                    wrapper.selfHhMember = true;
                    wrapper.relationShip = 'Self';
                    wrapper.memberType = 'household';
                    trackUser.add(crrRec.CC_Contact__c);
                }
                if(!restrictedRolesOrRelationship.contains(crrRec.CC_Role__c)){
                    wrapper.typeEdit = true;
                }
                
                // if(pap.Status=='Active'){
                    //     wrapper.isActive = true;
                // }
                wrapperList.add(wrapper);
            }
            // wrapperList.declarationStepInfo = appSpecificIdToRecordMap;
            resultMap.put('contactRoleRelationList', wrapperList);
            resultMap.put('declarationStepInfo', appSpecificIdToRecordMap);
            return resultMap;
        } catch(Exception e) {
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
    }
    
    @AuraEnabled
    public static Map<String,Object> fetchExistingMembersGeneric(String facilityId,String facilityType) {

        try {
            Map<String,Object> resultMap = new Map<String,Object>();
            facilityId = CC_CommonUtility.performDecryption(facilityId);
            List<ContactRoleRelationWrapper> wrapperList = new List<ContactRoleRelationWrapper>();
            List<ContactRoleRelationWrapper> staffList = new List<ContactRoleRelationWrapper>();
            List<ContactRoleRelationWrapper> householdList = new List<ContactRoleRelationWrapper>();
            list<CC_Contact_Role_Relationship__c> contactRoleRecords= CC_NoSharing_DAO.fetchCrrListByFacilityId(facilityId);
            Set<Id> crrIds = new Set<Id>();
            // Map<Id,Id> crrToAppSpecificMap = new Map<Id,Id>();
            for(CC_Contact_Role_Relationship__c crrRec : contactRoleRecords){
                crrIds.add(crrRec.Id);
            }

            Map<String,List<DeclarationRecords>> appSpecificIdToRecordMap = new Map<String,List<DeclarationRecords>>();
            for(CC_Application_Specification__c appSepRec : CC_ApplicationSpecificationDAO.fetchScheduleDetailsById(crrIds)){
                DeclarationRecords declarationRecords = new DeclarationRecords();
                declarationRecords.typeOfAppSpec = appSepRec?.CC_Specification_Type__c;
                declarationRecords.typeOfCharges = appSepRec?.CC_Type_of_Charges__c;
                declarationRecords.chargesDate = String.valueOf(appSepRec?.CC_Charges_Date__c);
                declarationRecords.stateInWhichCharged = String.valueOf(appSepRec?.CC_Charges_State__c);
                declarationRecords.convictionPlace = appSepRec?.CC_Place_of_Conviction_and_Disposition__c;
                declarationRecords.natureOfConviction = appSepRec?.CC_Nature_of_Conviction_and_Disposition__c;
                declarationRecords.convictionDate = String.valueOf(appSepRec?.CC_Conviction_and_Disposition_Date__c);
                declarationRecords.dateLivedTo = String.valueOf(appSepRec?.CC_State_Resided_To__c);
                declarationRecords.dateLivedFrom = String.valueOf(appSepRec?.CC_State_Resided_From__c);
                declarationRecords.stateLivedIn = appSepRec?.CC_State_Resided__c;
                declarationRecords.selectedPerson = appSepRec?.CC_Contact_Role_Relationship__r?.CC_Email__c;
                declarationRecords.selectedPersonLabel = appSepRec?.CC_Contact_Role_Relationship__r.CC_Contact__r.Name;
                declarationRecords.uniqueKey = CC_CommonUtility.performEncryption(appSepRec?.Id);
                if(appSpecificIdToRecordMap.containsKey(appSepRec?.CC_Contact_Role_Relationship__r?.CC_Email__c)){
                    appSpecificIdToRecordMap.get(appSepRec?.CC_Contact_Role_Relationship__r?.CC_Email__c).add(declarationRecords);
                }
                else{
                    appSpecificIdToRecordMap.put(appSepRec?.CC_Contact_Role_Relationship__r?.CC_Email__c,new List<DeclarationRecords>{declarationRecords});
                }
            }

            List<String> restrictedRolesOrRelationship = new List<String>{CC_Constants.CONTCAT_OWNER_ROLE,CC_Constants.CONTCAT_FACILITY_OWNER_ROLE,CC_Constants.CONTCAT_CO_OWNER_ROLE , CC_Constants.CRR_RELATIONSHIP_SELF};
            
            List<Id> trackUser = new List<Id>();
            for(CC_Contact_Role_Relationship__c crrRec : contactRoleRecords) {
                ContactRoleRelationWrapper wrapper = new ContactRoleRelationWrapper();
                Account accRecord = crrRec?.CC_Contact__r?.Account;
                wrapper.recordId = crrRec.Id;
                // wrapper.selectedRole = crrRec.CC_Job_Type__c ;
                wrapper.selectedRoleType = crrRec.CC_Role__c;
                // wrapper.isLicensee = crrRec.CC_Licensee__c? 'Yes' : 'No';
                wrapper.providerAccId = CC_CommonUtility.performEncryption(crrRec.CC_Account__c);
                // wrapper.otherRole = crrRec.CC_Multi_Location_Staff__c == true ? 'Yes': 'No';
                wrapper.startDate = String.valueOf(crrRec.CC_Start_Date__c);
                wrapper.firstName = accRecord.FirstName;
                wrapper.lastName = accRecord.LastName;
                wrapper.middleName = accRecord.MiddleName;
                wrapper.emailAddress = accRecord.CC_Email__c;
                wrapper.selectedAccountId =  crrRec?.CC_Contact__r?.AccountId;
                wrapper.curentlyEnrolled = 'Yes';
                wrapper.dateOfBirth = String.valueOf(crrRec.CC_Date_of_Birth__c);
                wrapper.dateOfHire = String.valueOf(crrRec.CC_Date_Of_Hire__c);
                // wrapper.dateOfHire = CC_CommonUtility.dateMMddYYYY(Date.valueOf(crrRec.CC_Date_Of_Hire__c));
                wrapper.status = crrRec.CC_Association_Status__c;
                wrapper.workforceId = accRecord.CC_Person_ID__c;
                wrapper.employerName = accRecord.FirstName +' '+ accRecord.LastName;
                if(accRecord.MiddleName!=null){
                    wrapper.employerName = accRecord.FirstName +' '+accRecord.MiddleName+' '+ accRecord.LastName;
                }
                wrapper.isActive = true;
                wrapper.isOldMember = true;
                wrapper.brcStatus = crrRec.CC_BRC_Status__c ;
                wrapper.brcConsentStatus = crrRec.CC_BRC_Consent_Status__c ;
                wrapper.brcFingerprintingScanDate = crrRec.CC_Fingerprinting_Scan_Date__c ;
                wrapper.brcRenewalDate = crrRec.CC_BRC_Renewal_Date__c ;
                wrapper.brcFingerprintingResultDate = crrRec.CC_Fingerprinting_Result_Date__c ;
                wrapper.brcExpirationDate = crrRec.CC_BRC_Expiration_Date__c ;
                wrapper.typeEdit = false;
                String ssnValue = accRecord.CC_Decrypted_SSN__c;
                wrapper.decryptedSsn = ssnValue;
                wrapper.ssn = accRecord.CC_SSN__c;//ssnValue != null && ssnValue.length() >= 5 ? ssnValue.substring(ssnValue.length() - 5) : ssnValue;
                wrapper.gender = accRecord.PersonGenderIdentity;
                wrapper.race = accRecord.CC_Race_Origin__pc;
                wrapper.ethnicity = accRecord.CC_Ethnicity__c;
                wrapper.phoneNum = accRecord.Phone;
                wrapper.alternatePhoneNum = accRecord.CC_Alternate_Phone_Number__c;
                wrapper.alternatePhoneType = accRecord.CC_Alternate_Phone_Type__c;
                
                wrapper.streetMailing = accRecord.ShippingStreet;
                wrapper.cityMailing = accRecord.ShippingCity;
                wrapper.countryMailing = accRecord.ShippingCountryCode;
                wrapper.stateMailing = accRecord.ShippingStateCode;
                wrapper.zipCodeMailing = accRecord.ShippingPostalCode;
                wrapper.mailingCounty = accRecord.CC_County_Mailing__c;
                wrapper.mailingcountyOther = accRecord.CC_Shipping_County_Other__c;
                wrapper.mailingapartmentSuite = accRecord.CC_Shipping_Apt_Suite__c;
                
                wrapper.streetBilling = accRecord.BillingStreet;
                wrapper.cityBilling = accRecord.BillingCity;
                wrapper.countryBilling = accRecord.BillingCountryCode;
                wrapper.stateBilling = accRecord.BillingStateCode;
                wrapper.zipCodeBilling = accRecord.BillingPostalCode;
                wrapper.billingCounty = accRecord.CC_County_Billing__c;
                wrapper.billingcountyOther = accRecord.CC_Billing_County_Other__c;
                wrapper.billingapartmentSuite = accRecord.CC_Apt_Suite__c;
                wrapper.mailingSameAsPhysical  = accRecord.CC_Mailing_Address_Same__c;

                wrapper.suffix = accRecord.Suffix;
                wrapper.emailType = accRecord.CC_Email_Type__c;
                wrapper.phoneType = accRecord.CC_Phone_Type__c;
                
                wrapper.selfHhMember = false;
                wrapper.relationShip = crrRec.CC_Relationship__c;
                wrapper.memberType = crrRec.Type_Of_Member__c == 'Household'?'household':crrRec.Type_Of_Member__c;
                if((crrRec.CC_Contact__c == currentUserDetails.ContactId) && !trackUser.contains(crrRec.CC_Contact__c)){
                    wrapper.selfHhMember = true;
                    wrapper.relationShip = 'Self';
                    trackUser.add(crrRec.CC_Contact__c);
                    householdList.add(wrapper);
                }
                if(!restrictedRolesOrRelationship.contains(crrRec.CC_Role__c)){
                    wrapper.typeEdit = true;
                }
                
                // if(pap.Status=='Active'){
                    //     wrapper.isActive = true;
                // }

                if(crrRec.Type_Of_Member__c == 'Household' && wrapper.relationShip != 'Self'){
                    householdList.add(wrapper);
                }
                else if(crrRec.Type_Of_Member__c == 'Staff' || crrRec.Type_Of_Member__c != 'Household'){
                    staffList.add(wrapper);
                    
                }
            }
            // wrapperList.declarationStepInfo = appSpecificIdToRecordMap;
            resultMap.put('contactRoleRelationList', wrapperList);
            resultMap.put('householdRecords', householdList);
            resultMap.put('staffRecords', staffList);
            resultMap.put('declarationStepInfo', appSpecificIdToRecordMap);
            return resultMap;
        } catch(Exception e) {
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
    }
    /*
    //commented by pranay - not in use yet
    public static void processMemberListSubsidy(String blaId , String parRecId, String providerAccId) {
        try {
            List<CC_Contact_Role_Relationship__c> crrRecords = Copy_CC_NoSharing_DAO.fetchCrrListByFacilityId(providerAccId);
            List<CC_Application_Contact__c> papRecordsNew = new List<CC_Application_Contact__c>();
            List<CC_Application_Specification__c> appSpecNew = new List<CC_Application_Specification__c>();
            Set<Id> appSpecificIds = new Set<Id>();
            Map<Id,Id> mapAppSpecCrrIds = new Map<Id,Id>();
            String providerStaffRecTypeId = Schema.SObjectType.CC_Application_Contact__c.getRecordTypeInfosByDeveloperName().get('Provider_Staff').getRecordTypeId();
            for(CC_Contact_Role_Relationship__c iterCrr : crrRecords){
                CC_Application_Contact__c newPAP = new CC_Application_Contact__c();
                newPAP.CC_Preliminary_Application_Reference__c = parRecId;
                newPAP.CC_Business_License_Application__c = blaId;
                newPAP.CC_Applicant__c = iterCrr.CC_Contact__r.AccountId;
                newPAP.RecordTypeId = providerStaffRecTypeId;
                newPAP.CC_Multi_Location_Staff__c = iterCrr.CC_Multi_Location_Staff__c;
                if(iterCrr.CC_Schedule_Detail__c != null){
                    appSpecificIds.add(iterCrr.CC_Schedule_Detail__c);
                    mapAppSpecCrrIds.put(iterCrr.CC_Schedule_Detail__c , iterCrr.Id);
                }
                // newPAP.CC_Member_Role__c  = iterCrr.CC_Job_Type__c;
                newPAP.CC_Role__c  = iterCrr.CC_Role__c;
                newPAP.CC_Provider_Account__c  = iterCrr.CC_Account__c;
                // newPAP.CC_BRC_Required__c  = true;
                // newPAP.CC_Licensee__c  = iterCrr.CC_Licensee__c;
                newPAP.CC_Date_of_Birth__c  = iterCrr.CC_Date_of_Birth__c;
                newPAP.CC_Date_Of_Hire__c  = iterCrr.CC_Date_Of_Hire__c;
                newPAP.CC_Start_Date__c  = iterCrr.CC_Start_Date__c;
                newPAP.CC_First_Name__c  = iterCrr.CC_First_Name__c;
                newPAP.CC_Last_Name__c  = iterCrr.CC_Last_Name__c;
                newPAP.CC_Middle_Name__c  = iterCrr.CC_Middle_Name__c;
                newPAP.CC_Email__c  = iterCrr.CC_Email__c;
                papRecordsNew.add(newPAP);
            }
            Map<Id,Id> mapCrrAppSpecIds = new Map<Id,Id>();
            
            
            if(!papRecordsNew.isEmpty()){
                CC_NoSharing_Utility.noSharingInsert(papRecordsNew,true);
                for(Integer i =0 ; i < crrRecords.size() ; i++){
                    mapCrrAppSpecIds.put(crrRecords[i].Id,papRecordsNew[i].Id);
                }
            }
            List<CC_Application_Specification__c> appSpecifications = CC_ApplicationSpecificationDAO.fetchScheduleDetailsById(appSpecificIds);
            for(CC_Application_Specification__c iterAppSpec : appSpecifications){
                CC_Application_Specification__c newAppSpecific = iterAppSpec.clone(false, true, false, false);
                newAppSpecific.CC_PreliminaryApplicationRef__c = parRecId;
                newAppSpecific.CC_BusinessLicenseApplication__c = blaId;
                //SM - Commenting this line as new field is in place (CC_Application_Contact__c)
                //newAppSpecific.CC_Public_Application_Participant__c = mapCrrAppSpecIds.get(mapAppSpecCrrIds.get(iterAppSpec.Id));
                newAppSpecific.CC_Application_Contact__c = mapCrrAppSpecIds.get(mapAppSpecCrrIds.get(iterAppSpec.Id));
                appSpecNew.add(newAppSpecific);
            }
            if(!appSpecNew.isEmpty()){
                appSpecNew =  (List<CC_Application_Specification__c>)CC_DML.doInsert(appSpecNew, false);
            }
            
            
        } catch (Exception e) {
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
        
    }*/

    @AuraEnabled
    public static void updateParRecordWithReason(String appId, List<String> selReason) {
        try {
            appId = CC_CommonUtility.performDecryption(appId);
            String reasons = String.join(selReason, ';');
            PreliminaryApplicationRef parRec = new PreliminaryApplicationRef();
            parRec.Id = appId;
            parRec.CC_Reason_for_Staff_Amendment__c = reasons;
            CC_DML.doUpdate(parRec, true);
        } catch (Exception e) {
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
    }
    
    
    public static void migratePersonEducationEmploymentToAppSpec(String applicationId, String facilityId) {
        try {
            // Fetch existing PersonEducation records
            List<CC_Contact_Role_Relationship__c> contactRoles = CC_NoSharing_DAO.getFacilityDirector(facilityId);
            if(contactRoles.size() == 0) {
                return;
            }
            
            List<CC_Person_Education__c> personEducationFetch = CC_NoSharing_DAO.getPersonEducation(contactRoles[0].CC_Contact__r.AccountId);
            List<CC_Person_Employment__c> personEmployeFetch = CC_NoSharing_DAO.getPersonEmployer(contactRoles[0].CC_Contact__r.AccountId);
            List<CC_Application_Specification__c> listOfAppSpec = new List<CC_Application_Specification__c>();
            RecordType recordType   = [SELECT Id FROM RecordType WHERE DeveloperName = 'Degree' AND SObjectType = 'CC_Person_Education__c' LIMIT 1];
            
            for (CC_Person_Education__c education : personEducationFetch) {
                CC_Application_Specification__c appSpec = new CC_Application_Specification__c();
                appSpec.CC_PreliminaryApplicationRef__c = applicationId;
                appSpec.CC_ExternalId__c = education.CC_ExternalId__c;
                if(recordType.Id != education.RecordTypeId){
                    appSpec.Specification_Name__c = education.Name;
                    appSpec.CC_Issuer_Organisation__c = education.CC_Issuer_Organisation__c;
                    appSpec.CC_Issuance_Date__c = education.CC_Issuance_Date__c;
                    appSpec.CC_Expiration_Date__c = education.CC_Expiration_Date__c;
                    appSpec.CC_Never_Expires__c = education.CC_NeverExpires__c;
                    appSpec.CC_Specification_Type__c = 'Professional Credential';
                }else{
                    appSpec.Specification_Name__c = education.CC_Highest_Level_of_Education__c;
                    appSpec.CC_Major__c = education.CC_Major__c;
                    appSpec.CC_Degree__c = education.CC_Degree_Or_Diploma__c;
                    appSpec.CC_Specification_Type__c = 'Degree';
                }
                
                listOfAppSpec.add(appSpec);
            }
            
            for (CC_Person_Employment__c employment : personEmployeFetch) {
                CC_Application_Specification__c appSpec = new CC_Application_Specification__c();
                appSpec.CC_PreliminaryApplicationRef__c = applicationId;
                appSpec.CC_ExternalId__c = employment.CC_ExternalId__c;
                appSpec.Specification_Name__c = employment.Name;
                appSpec.CC_Position__c = employment.CC_Position__c;
                appSpec.CC_Start_Date__c = employment.CC_Start_Date__c;
                appSpec.CC_End_Date__c = employment.CC_End_Date__c;
                appSpec.CC_Address__Street__s = employment.CC_Employer_Address__Street__s;
                appSpec.CC_Address__CountryCode__s = employment.CC_Employer_Address__CountryCode__s;
                appSpec.CC_Address__StateCode__s = employment.CC_Employer_Address__StateCode__s;
                appSpec.CC_Address__City__s = employment.CC_Employer_Address__City__s;
                appSpec.CC_Address__PostalCode__s = employment.CC_Employer_Address__PostalCode__s;
                appSpec.CC_Billing_Apt_Suite__c = employment.CC_Employer_Apt_Suite__c;
                appSpec.CC_Billing_County__c = employment.CC_Employer_County__c;
                appSpec.CC_Specification_Type__c = 'Employment';
                listOfAppSpec.add(appSpec);
            }
            
            // Upsert the created records
            if (listOfAppSpec.size() > 0) {
                CC_DML.doUpsert(listOfAppSpec, true);
            }
        } catch (Exception e) {
            throw new CC_Exception( e.getStackTraceString() + ' ' + e.getMessage() + ' ' + e.getCause() );
        }
    }

    /**
    * @description 
    * @author Sai Vardhan Kandukuri | 01-30-2025 
    * @param PreliminaryApplicationRef newApplication 
    **/
    private static void cloneApplicationSpecFromAccountForAmendments(PreliminaryApplicationRef newApplication) {
        if(newApplication.CC_Amendment_Type__c == CC_Constants.AMENDMENT_TYPE_OVERLAP_CARE ||
           newApplication.CC_Amendment_Type__c == 'Change of Address/ Change of Facility Type') {
            createApplicationSpecificationRecords(newApplication, new List<String>{CC_Constants.APPLICATION_SPECIFICATION_TYPE_FLOOR_PLAN});
        }

        if(newApplication.CC_Amendment_Type__c == CC_Constants.AMENDMENT_TYPE_CHANGE_OF_FACILITY_DETAILS){
            createApplicationSpecificationRecords(newApplication, new List<String>{CC_Constants.APPLICATION_SPECIFICATION_TYPE_SCHEDULE});
        }
    }

    /**
    * @description 
    * @author Sai Vardhan Kandukuri | 01-30-2025 
    * @param PreliminaryApplicationRef newApplication 
    * @param List<String> specificationType 
    **/
    private static void createApplicationSpecificationRecords(PreliminaryApplicationRef newApplication, List<String> specificationType) {
        List<CC_Application_Specification__c> appSpecLstForAmendment = new List<CC_Application_Specification__c>();
        for(CC_Application_Specification__c appSpec : CC_ApplicationSpecificationDAO.fetchApplicationSpecifications(newApplication.BusinessAccountNameId, specificationType)){
            CC_Application_Specification__c appSpecForAmendment = appSpec.clone(false, true, false, false);
            appSpecForAmendment.CC_PreliminaryApplicationRef__c = newApplication.Id;
            appSpecLstForAmendment.add(appSpecForAmendment);
        }
        
        if(!appSpecLstForAmendment.isEmpty()){
            CC_DML.doInsert(appSpecLstForAmendment, false);
        }
    }


    /**
    * @description 
    * @author Sai Vardhan Kandukuri | 01-21-2025 
    * @param PreliminaryApplicationRef newApplication 
    **/
    private static void populateApplicationFieldsFromAccount(PreliminaryApplicationRef newApplication) {
        if(newApplication.CC_Application_Type__c == CC_Constants.APPLICATION_TYPE_NEW) {
            populateNewApplicationFieldsFromAccount(newApplication);
        }else if(newApplication.CC_Application_Type__c == CC_Constants.APPLICATION_TYPE_RENEWAL) {
            populateNewApplicationFieldsFromAccount(newApplication);
        }else if(newApplication.CC_Application_Type__c == CC_Constants.APPLICATION_TYPE_AMENDMENT) {
            populateApplicationAmendmentFieldsFromAccount(newApplication);
        }
    }

    /**
    * @description 
    * @author Sai Vardhan Kandukuri | 01-21-2025 
    * @param PreliminaryApplicationRef newApplication 
    **/
    private static void populateNewApplicationFieldsFromAccount(PreliminaryApplicationRef newApplication) {
        List<Account> acc = CC_AccountDAO.getFacilityFields(newApplication.BusinessAccountNameId);
        if(acc != null) {
            newApplication.CC_Facility_Type__c = acc[0].CC_Facility_Type__c; 
            newApplication.CC_Facility_Name__c = acc[0].Name;
            newApplication.CC_Facility_Email__c = acc[0].CC_Email__c;
            newApplication.CC_Facility_Phone_Number__c = acc[0].CC_Facility_Phone_Number__c;
            newApplication.FEIN__c = acc[0].CC_FIEN__c;
            newApplication.SSN__c = acc[0].CC_SSN__c;
            System.debug('SSN'+newApplication.SSN__c);
            newApplication.CC_Doing_Business_As__c = acc[0].CC_Doing_Business_As__c;
            
            newApplication.CC_Facility_Physical_Address__Street__s = acc[0].BillingStreet;
            newApplication.CC_Facility_Physical_Address__City__s = acc[0].BillingCity;
            newApplication.CC_Facility_Physical_Address__StateCode__s = acc[0].BillingStateCode;
            newApplication.CC_Facility_Physical_Address__CountryCode__s = acc[0].BillingCountryCode;
            newApplication.CC_Facility_Physical_Address__PostalCode__s = acc[0].BillingPostalCode;
            newApplication.CC_Facility_Physical_County__c = acc[0].CC_County_Billing__c;
            newApplication.CC_Facility_Physical_Apt_Suit__c = acc[0].CC_Apt_Suite__c;
            
            newApplication.CC_Facility_Mailing_Same_As_Billing__c = acc[0].CC_Mailing_Address_Same__c;

            newApplication.CC_Facility_Mailing_Address__Street__s = acc[0].ShippingStreet;
            newApplication.CC_Facility_Mailing_Address__City__s = acc[0].ShippingCity;
            newApplication.CC_Facility_Mailing_Address__StateCode__s = acc[0].ShippingStateCode;
            newApplication.CC_Facility_Mailing_Address__CountryCode__s = acc[0].ShippingCountryCode;
            newApplication.CC_Facility_Mailing_Address__PostalCode__s = acc[0].ShippingPostalCode;
            newApplication.CC_Facility_Mailing_County__c = acc[0].CC_County_Mailing__c;
            newApplication.CC_Facility_Mailing_Apt_Suit__c = acc[0].CC_Shipping_Apt_Suite__c;


            //renewal fields
            newApplication.CC_Maximum_Age_Limit_Requested_Years__c = acc[0]?.CC_Maximum_Age_Limit_Requested_Years__c;
            newApplication.CC_Minimum_Age_Limit_Requested_Years__c = acc[0]?.CC_Minimum_Age_Limit_Requested_Years__c;
            newApplication.CC_Date__c = acc[0]?.CC_Date__c;
            newApplication.CC_Date_of_Inspection_Fire_Marshal__c = acc[0]?.CC_Date_of_Inspection_Fire_Marshal__c;
            newApplication.CC_Date_of_Inspection_Health_Cert__c = acc[0]?.CC_Date_of_Inspection_Health_Cert__c;
            newApplication.CC_Date_of_Measurement__c = acc[0]?.CC_Date_of_Measurement__c;
            newApplication.CC_Do_have_Health_Department_Certificate__c = acc[0]?.CC_Do_have_Health_Department_Certificate__c;
            newApplication.CC_Do_you_have_Fire_Marshal_Certificate__c = acc[0]?.CC_Do_you_have_Fire_Marshal_Certificate__c;
            newApplication.CC_Have_you_been_approved_provide_care__c = acc[0]?.CC_Have_you_been_approved_provide_care__c;
            newApplication.CC_I_will_be_providing_child_care_in__c = acc[0]?.CC_I_will_be_providing_child_care_in__c;
            newApplication.CC_In_the_past_have_you_been_Registered__c = acc[0]?.CC_In_the_past_have_you_been_Registered__c;
            newApplication.CC_Infant_Capacity__c = acc[0]?.CC_Infant_Capacity__c;
            newApplication.CC_Name_of_FireMarshal_Health_Dept_Cert__c = acc[0]?.CC_Name_of_FireMarshal_Health_Dept_Cert__c;
            newApplication.CC_Name_of_FireMarshal__c = acc[0]?.CC_Name_of_FireMarshal__c;
            newApplication.CC_Number_of_your_own_children__c = acc[0]?.CC_Number_of_your_own_children__c;
            newApplication.CC_Owner_Co_Owner_Present_In_Facility__c = acc[0]?.CC_Owner_Co_Owner_Present_In_Facility__c;
            newApplication.CC_What_type__c = acc[0]?.CC_What_type__c;
            newApplication.Number_of_children_for_who_care_provided__c = acc[0]?.Number_of_children_for_who_care_provided__c;

        }
    }

    /**
    * @description 
    * @author Sai Vardhan Kandukuri | 01-21-2025 
    * @param PreliminaryApplicationRef newApplication 
    **/
    private static void populateApplicationAmendmentFieldsFromAccount(PreliminaryApplicationRef newApplication) {
        List<Account> acc = CC_AccountDAO.getFacilityFields(newApplication.BusinessAccountNameId);
        if(acc != null) {
            if(newApplication.CC_Amendment_Type__c == CC_Constants.AMENDMENT_TYPE_CHANGE_OF_FACILITY_DETAILS) {
                newApplication.CC_Facility_Name__c = acc[0].Name;
                newApplication.CC_Facility_Type__c = acc[0].CC_Facility_Type__c; 
                newApplication.CC_Facility_Name_Old__c = acc[0].Name;
                newApplication.CC_Facility_Email_Old__c = acc[0].CC_Email__c;
                newApplication.CC_Facility_Phone_Old__c = acc[0].CC_Facility_Phone_Number__c;
                newApplication.CC_Director_Name_Old__c = acc[0].CC_Facility_Director__c;
                newApplication.CC_Maximum_Age_Limit_Requested_Years_Old__c = acc[0].CC_Maximum_Age_Limit_Requested_Years__c;
                newApplication.CC_Minimum_Age_Limit_Requested_Years_Old__c = acc[0].CC_Minimum_Age_Limit_Requested_Years__c;
                newApplication.Children_for_who_care_provided_Old__c = acc[0].Number_of_children_for_who_care_provided__c;
            }
            else if(newApplication.CC_Amendment_Type__c == CC_Constants.AMENDMENT_TYPE_ARM_RULE_WAIVER) {
                newApplication.CC_Facility_Name__c = acc[0].Name; 
            }
            else if(newApplication.CC_Amendment_Type__c == CC_Constants.AMENDMENT_TYPE_OVERLAP_CARE) {
                newApplication.CC_Facility_Name__c = acc[0].Name;
                newApplication.CC_Director_Name__c = acc[0].CC_Facility_Director__c;
                newApplication.CC_Facility_Phone_Number__c = acc[0].CC_Facility_Phone_Number__c;
                newApplication.CC_Facility_Physical_Address__Street__s = acc[0].BillingStreet;
                newApplication.CC_Facility_Physical_Address__City__s = acc[0].BillingCity;
                newApplication.CC_Facility_Physical_Address__StateCode__s = acc[0].BillingStateCode;
                newApplication.CC_Facility_Physical_Address__CountryCode__s = acc[0].BillingCountryCode;
                newApplication.CC_Facility_Physical_Address__PostalCode__s = acc[0].BillingPostalCode;
                newApplication.CC_Facility_Physical_County__c = acc[0].CC_County_Billing__c;
                newApplication.CC_Facility_Physical_Apt_Suit__c = acc[0].CC_Apt_Suite__c;
                newApplication.CC_Date_of_Measurement__c = acc[0].CC_Date_of_Measurement__c;
            }
            else if(newApplication.CC_Amendment_Type__c == 'Family Association') {
                newApplication.CC_Parents_always_have_access_to_kids__c = acc[0].CC_Parents_always_have_access_to_kids__c;
                newApplication.CC_Is_the_provider_in_good_health__c = acc[0].CC_Is_the_provider_in_good_health__c;
                newApplication.CC_Provider_has_trained_in_health_safe__c = acc[0].CC_Provider_has_trained_in_health_safe__c;
                newApplication.CC_Knowledgeable_in_child_development__c = acc[0].CC_Knowledgeable_in_child_development__c;
                newApplication.CC_Provider_wash_hands_thoroughly__c = acc[0].CC_Provider_wash_hands_thoroughly__c;
                newApplication.CC_Washes_hands_before_food_prep__c = acc[0].CC_Washes_hands_before_food_prep__c;
                newApplication.CC_Provider_has_childproofing_guidelines__c = acc[0].CC_Provider_has_childproofing_guidelines__c;
                newApplication.CC_Provider_communicate_meet_kid_s_needs__c = acc[0].CC_Provider_communicate_meet_kid_s_needs__c;
                newApplication.CC_Environment_foster_trust_happiness__c = acc[0].CC_Environment_foster_trust_happiness__c;
                newApplication.CC_Provider_offer_learning_opportunities__c = acc[0].CC_Provider_offer_learning_opportunities__c;
                newApplication.CC_Are_children_s_immunizations_current__c = acc[0].CC_Are_children_s_immunizations_current__c;
                newApplication.CC_Are_emergency_parent_numbers_posted__c = acc[0].CC_Are_emergency_parent_numbers_posted__c;
                newApplication.CC_Provider_trained_in_First_Aid_and_CPR__c = acc[0].CC_Provider_trained_in_First_Aid_and_CPR__c;
                newApplication.CC_Emergency_medical_authorization_sign__c = acc[0].CC_Emergency_medical_authorization_sign__c;
                newApplication.CC_Is_a_first_aid_kit_available__c = acc[0].CC_Is_a_first_aid_kit_available__c;
                newApplication.CC_Are_meals_and_snacks_nutritious__c = acc[0].CC_Are_meals_and_snacks_nutritious__c;
                newApplication.CC_Is_there_a_quiet_comfy_place_for_naps__c = acc[0].CC_Is_there_a_quiet_comfy_place_for_naps__c;
                newApplication.CC_Is_the_play_equipment_safe__c = acc[0].CC_Is_the_play_equipment_safe__c;
                newApplication.CC_Is_the_homeclean__c = acc[0].CC_Is_the_homeclean__c;
                newApplication.CC_Are_the_children_exposed_to_smoking__c = acc[0].CC_Are_the_children_exposed_to_smoking__c;
                newApplication.CC_Are_hazards_out_of_reach_for_children__c = acc[0].CC_Are_hazards_out_of_reach_for_children__c;
                newApplication.CC_Are_electrical_outlets_covered__c = acc[0].CC_Are_electrical_outlets_covered__c;
                newApplication.CC_Are_heaters_ventilated_and_screened__c = acc[0].CC_Are_heaters_ventilated_and_screened__c;
                newApplication.CC_Are_poisons_out_of_children_s_reach__c = acc[0].CC_Are_poisons_out_of_children_s_reach__c;
                newApplication.CC_Smoke_detectors_installed_and_working__c = acc[0].CC_Smoke_detectors_installed_and_working__c;
                newApplication.CC_Is_a_fire_extinguisher_available__c = acc[0].CC_Is_a_fire_extinguisher_available__c;
                newApplication.CC_Are_firearms_locked_and_inaccessible__c = acc[0].CC_Are_firearms_locked_and_inaccessible__c;
                newApplication.CC_Proper_car_seats_and_restraints_used__c = acc[0].CC_Proper_car_seats_and_restraints_used__c;
                newApplication.CC_One_or_more_of_the_above_criteria_met__c = acc[0].CC_One_or_more_of_the_above_criteria_met__c;
                newApplication.CC_I_will_be_providing_child_care_in__c = acc[0].CC_I_will_be_providing_child_care_in__c;

            }
            else if(newApplication.CC_Amendment_Type__c == 'Change of Address/ Change of Facility Type') {
                newApplication.CC_Facility_Name__c = acc[0].Name;
                newApplication.CC_Facility_Phone_Number__c = acc[0].CC_Facility_Phone_Number__c;
                newApplication.CC_Facility_Email__c = acc[0].CC_Email__c;
                newApplication.CC_Old_Facility_Physical_Address__Street__s = acc[0].BillingStreet;
                newApplication.CC_Old_Facility_Physical_Address__City__s = acc[0].BillingCity;
                newApplication.CC_Old_Facility_Physical_Address__StateCode__s = acc[0].BillingStateCode;
                newApplication.CC_Old_Facility_Physical_Address__CountryCode__s = acc[0].BillingCountryCode;
                newApplication.CC_Old_Facility_Physical_Address__PostalCode__s = acc[0].BillingPostalCode;
                newApplication.CC_Old_Facility_Physical_County__c = acc[0].CC_County_Billing__c;
                newApplication.CC_Old_Facility_Physical_Apt_Suit__c = acc[0].CC_Apt_Suite__c;
                newApplication.CC_Old_Facility_Mailing_Address__Street__s = acc[0].ShippingStreet;
                newApplication.CC_Old_Facility_Mailing_Address__City__s = acc[0].ShippingCity;
                newApplication.CC_Old_Facility_Mailing_Address__StateCode__s = acc[0].ShippingStateCode;
                newApplication.CC_Old_Facility_Mailing_Address__CountryCode__s = acc[0].ShippingCountryCode;
                newApplication.CC_Old_Facility_Mailing_Address__PostalCode__s = acc[0].ShippingPostalCode;
                newApplication.CC_Old_Facility_Mailing_County__c = acc[0].CC_County_Mailing__c;
                newApplication.CC_Old_Facility_Mailing_Apt_Suit__c = acc[0].CC_Shipping_Apt_Suite__c;
                newApplication.Anyone_age_18_Living_at_Care_Location__c = acc[0].Anyone_age_18_Living_at_Care_Location__c;
                newApplication.CC_Date_of_Measurement__c = acc[0].CC_Date_of_Measurement__c;
                
            }

        }

    
    }
    /*@AuraEnabled
    public static CC_ApplicationWrapper.ProviderRolesandResponsibilityWrapper fetchRolesandResponsibilities(String PARId){
        //system.assert(false,'fail' +PARId);
        CC_ApplicationWrapper.ProviderRolesandResponsibilityWrapper ProviderRolesandResponsibilityWrapperRecord   = new CC_ApplicationWrapper.ProviderRolesandResponsibilityWrapper();

        try{
        String appliactionId = CC_CommonUtility.performDecryption(PARId); 
       // system.assert(false,'fail' +appliactionId);


        List<PreliminaryApplicationRef> applicationInformation  = CC_PreliminaryApplicationRefDAO.fetchParList(appliactionId);
        //CC_ApplicationWrapper.ProviderRolesandResponsibilityWrapper ProviderRolesandResponsibilityWrapperRecord   = new CC_ApplicationWrapper.ProviderRolesandResponsibilityWrapper();

              //providerrolesandresponsibilities
              ProviderRolesandResponsibilityWrapperRecord.providerRights=applicationInformation[0].CC_Provider_Rights_Check__c;
              ProviderRolesandResponsibilityWrapperRecord.providerResponsibilites=applicationInformation[0].CC_Provider_Responsibilites_Check__c;
              ProviderRolesandResponsibilityWrapperRecord.providerUnderstanding=applicationInformation[0].CC_Provider_Understanding_Check__c;
        
        // return ProviderRolesandResponsibilityWrapperRecord;
        //system.assert(false,'fail123' +ProviderRolesandResponsibilityWrapperRecord);

        }catch(exception e){
            system.assert(false,'fail' +e.getMessage() +e.getlinenumber());
        }
        return ProviderRolesandResponsibilityWrapperRecord;

    }*/
    
}