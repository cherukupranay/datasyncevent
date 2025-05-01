/**
 * @description       : 
 * @author            : MTX Group Inc
 * @group             : 
 * @last modified on  : 05-09-2024
 * @last modified by  : MTX Group Inc
**/
public with sharing class CC_DataSyncEventTriggerHelper {

    /**
    * @description : run sync for events assuming all events are having to same Souce and Target Object
    * @author MTX Group Inc | 05-01-2024 
    * @param newEvents 
    **/
    public static void handleDataSync(List<CC_DataSyncEvent__e> newEvents){
        Map<id,String> sourceIdsToTargetIdsMap = new Map<id,String>();
        for(CC_DataSyncEvent__e evt : newEvents){
            sourceIdsToTargetIdsMap.put(evt.CC_Source_Record_Id__c,evt.CC_Target_Record_Id__c);
        }
        CC_DataSyncController dcCtx=new CC_DataSyncController(
            newEvents[0].CC_Source_Object__c,
            newEvents[0].CC_Target_Object__c,
            sourceIdsToTargetIdsMap); 
        dcCtx.execute();
    }
}