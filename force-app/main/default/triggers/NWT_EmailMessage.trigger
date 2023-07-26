trigger NWT_EmailMessage on EmailMessage(before insert, after insert, before update, after update, before delete, after delete, after unDelete) {
    NWT_EmailMessageTriggerHandler hundler = new NWT_EmailMessageTriggerHandler();

    switch on Trigger.operationType {
        // when BEFORE_INSERT {
        //     hundler.beforeInsert(trigger.new);
        // }
        when AFTER_INSERT {
             hundler.afterInsert(trigger.new, trigger.newMap);
        }
        when BEFORE_UPDATE {
            hundler.beforeUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
        }
        // when AFTER_UPDATE {
        //     hundler.afterUpdate(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
        // }
        when BEFORE_DELETE {
            hundler.beforeDelete(trigger.old, trigger.oldMap);
        }
        // when AFTER_DELETE {
        //     hundler.afterDelete(trigger.old, trigger.oldMap);
        // }
        when AFTER_UNDELETE {
            hundler.afterUnDelete(trigger.new, trigger.newMap);
        }
    }
}