trigger ContactTrigger on Contact(after insert, after update) {
  ContactTriggerHandler.handlerTrigger(Trigger.new);
}
