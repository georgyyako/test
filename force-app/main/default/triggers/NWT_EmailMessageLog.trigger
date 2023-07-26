trigger NWT_EmailMessageLog on EmailMessageLog__c (before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    NWT_EmailMessageLogTriggerHandler handler = new NWT_EmailMessageLogTriggerHandler();

    switch on Trigger.operationType {
        // when BEFORE_INSERT {
        //     handler.beforeInsert(trigger.new);
        // }
        when AFTER_INSERT {
             handler.afterInsert(trigger.new, trigger.newMap);
        }
        // when BEFORE_UPDATE {
        //     handler.beforeUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
        // }
        // when AFTER_UPDATE {
        //     handler.afterUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
        // }
        // when BEFORE_DELETE {
        //     handler.beforeDelete(trigger.old, trigger.oldMap);
        // }
        // when AFTER_DELETE {
        //     handler.afterDelete(trigger.old, trigger.oldMap);
        // }
        // when AFTER_UNDELETE {
        //    handler.afterUnDelete(trigger.new, trigger.newMap);
        // }
    }
}