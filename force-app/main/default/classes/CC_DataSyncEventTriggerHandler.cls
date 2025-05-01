/**
 * @description       : 
 * @author            : MTX Group Inc
 * @group             : 
 * @last modified on  : 05-01-2024
 * @last modified by  : MTX Group Inc
**/
public with sharing class CC_DataSyncEventTriggerHandler extends CC_TriggerFramework{


    /*
    Method Name: afterInsert
    Description: Used in Event after insert trigger
    */
    protected override void afterInsert(List<Sobject> newEvents) {
        CC_DataSyncEventTriggerHelper.handleDataSync((List<CC_DataSyncEvent__e>)newEvents);   
    }                                               

}