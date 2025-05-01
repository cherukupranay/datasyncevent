/**
 * @description       : 
 * @author            : 
 * @group             : 
 * @last modified on  : 02-12-2025
 * @last modified by  : pranay
**/
public with sharing class CC_DataSyncController {
    @TestVisible private String sourceObj;
    @TestVisible private String targetObj;
    @TestVisible private CC_DataSyncObjectMapping__mdt mapping;
    @TestVisible private Map<id,String> sourceToTargetIds = new Map<id,String>();
    @TestVisible private List<SObject> inputData=new List<SObject>();

    public CC_DataSyncController( String sourceObj, String targetObj, Map<id,String> sourceToTargetIds){
        this.sourceObj=sourceObj;
        this.targetObj=targetObj;
        this.mapping=this.fetchMapping();
        this.sourceToTargetIds=sourceToTargetIds;
        this.inputData=this.fetchSourceRecords(sourceToTargetIds.keySet());
    }

    /**
    * @description : fetch FieldMappings
    * @author MTX Group Inc | 05-01-2024 
    * @return CC_DataSyncObjectMapping__mdt 
    **/
    @TestVisible
    private CC_DataSyncObjectMapping__mdt fetchMapping(){
        return CC_CustomMetadataDAO.getDataSyncMapping(this.sourceObj ,this.targetObj)[0];
    }

    /**
    * @description : Fetch all the records with fields to sync
    * @author MTX Group Inc | 05-01-2024 
    * @param recordIds 
    * @return List<SObject> 
    **/
    @TestVisible
    private List<SObject> fetchSourceRecords(set<id> recordIds){
        String selectQuery = 'SELECT Id,';
        for(CC_DataSyncFieldMapping__mdt fieldMapping:this.mapping.CC_DataSyncFieldMapping__r){
            if(fieldMapping.CC_Is_Static_Value__c) {continue;}
            selectQuery += fieldMapping.CC_Source_Field__c + ',';
        }
        selectQuery = selectQuery.removeEnd(',');
        selectQuery += ' FROM ' + this.sourceObj;
        selectQuery += ' WHERE Id IN :recordIds' ;
        return Database.query(selectQuery,AccessLevel.SYSTEM_MODE); // running in system mode as it is invoked by Automated User
    }

    /**
    * @description : Sync the objects and update , if lookup blank then create new Record and update lookup
    * @author MTX Group Inc | 05-01-2024 
    **/
    public void execute(){
        this.syncTarget();
    }

    /**
    * @description Sync the objects and update ,if lookup blank then create new Record
    * @author MTX Group Inc | 05-01-2024 
    * @return List<SObject> 
    **/
    @TestVisible
    private void syncTarget(){
        List<SObject> recToUpsert = new List<SObject>();
        string syncFieldApiName = this.mapping.CC_Sync_Identifier__c;
        for(SObject inp:this.inputData){
            String relationshipName = this.mapping.CC_Relationship_Api_Name__c;
            String targetId = this.sourceToTargetIds.get((id)inp.get('id'));

            Schema.SObjectType objType = Schema.getGlobalDescribe().get(this.targetObj);
            SObject outputObj = objType.newSObject();

            for(CC_DataSyncFieldMapping__mdt fieldMap: this.mapping.CC_DataSyncFieldMapping__r){
                if(fieldMap.CC_Is_Static_Value__c){
                    this.assignStaticValue(fieldMap.CC_Field_Type__c,outputObj,fieldMap);
                }else{
                    if(CC_CommonUtility.getFieldValue(inp,fieldMap.CC_Source_Field__c.split('\\.')) != null )
                    outputObj.put(fieldMap.CC_Target_Field__c,CC_CommonUtility.getFieldValue(inp,fieldMap.CC_Source_Field__c.split('\\.')));
                }
            }
            if(String.isNotBlank(relationshipName) && (inp.get('Id') != null)){ outputObj.put(relationshipName,(string) inp.get('Id')); }
            if(String.isNotBlank(syncFieldApiName)){ outputObj.put(syncFieldApiName,Datetime.now()); }
            if(String.isNotBlank(targetId)) { outputObj.put('id',targetId); }
            recToUpsert.add(outputObj);
        }
        CC_NoSharing_Utility.noSharingUpsert(recToUpsert,true);
    }

    /**
    * @description : if static value then assing value to target field
    * @author MTX Group Inc | 05-15-2024 
    * @param fType 
    * @param outputObj 
    * @param fieldMap 
    **/
    @TestVisible
    private void assignStaticValue(string fType,SObject outputObj,CC_DataSyncFieldMapping__mdt fieldMap ){
        String targetField = fieldMap.CC_Target_Field__c;
        String sourceValue = fieldMap.CC_Source_Field__c;
        if( fType == 'Text'){ outputObj.put(targetField,String.valueOf(sourceValue)); }
        else if(fType == 'Number'){ outputObj.put(targetField,decimal.valueOf(sourceValue));}
        else if(fType == 'Boolean'){ outputObj.put(targetField,Boolean.valueOf(sourceValue)); }
        else if(fType == 'Date'){ outputObj.put(targetField,date.valueOf(sourceValue)); }
        else if(fType == 'DateTime'){ outputObj.put(targetField,dateTime.valueOf(sourceValue)); }
        else if(fType == 'Expr'){
            if(sourceValue.equalsIgnoreCase('Now()')) { outputObj.put(targetField,Datetime.now()); }
            if(sourceValue.equalsIgnoreCase('Today()')) { outputObj.put(targetField,Date.today()); }
        }
    }
}