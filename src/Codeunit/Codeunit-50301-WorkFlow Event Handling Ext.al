codeunit 50301 "Workflow Event Handling Ext"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventsToLibrary', '', true, true)]
    local procedure OnAddWorkflowEventsToLibrary()
    var
    begin
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnSendRFQForApprovalCode, Database::"RFQ Header", RFQSendForApprovalEventDescTxt, 0, false);
        WorkflowEventHandling.AddEventToLibrary(RunWorkflowOnCancelRFQApprovalCode, Database::"RFQ Header", RFQApprovalRequestCancelEventDescTxt, 0, false);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Event Handling", 'OnAddWorkflowEventPredecessorsToLibrary', '', true, true)]
    local procedure OnAddWorkflowEventPredecessorsToLibrary(EventFunctionName: Code[128])
    var
        myInt: Integer;
    begin
        case EventFunctionName of
            RunWorkflowOnCancelRFQApprovalCode:
                WorkflowEventHandling.AddEventPredecessor(RunWorkflowOnCancelRFQApprovalCode, RunWorkflowOnSendRFQForApprovalCode);
            WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode:
                WorkflowEventHandling.AddEventPredecessor(WorkflowEventHandling.RunWorkflowOnApproveApprovalRequestCode, RunWorkflowOnSendRFQForApprovalCode);


        end;
    end;




    procedure RunWorkflowOnSendRFQForApprovalCode(): Code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnSendRFQForApproval'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt Ext.", 'OnSendRFQForApproval', '', true, true)]
    local procedure RunWorkflowOnSendRFQForApproval(var RFQ: Record "RFQ Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnSendRFQForApprovalCode, RFQ);
    end;

    procedure RunWorkflowOnCancelRFQApprovalCode(): Code[128]
    var
    begin
        exit(UpperCase('RunWorkflowOnCancelRFQApproval'));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approval Mgmt Ext.", 'OnCancelRFQForApproval', '', true, true)]
    local procedure RunWorkflowOnCancelRFQApproval(var RFQ: Record "RFQ Header")
    begin
        WorkflowManagement.HandleEvent(RunWorkflowOnCancelRFQApprovalCode, RFQ);
    end;



    var
        WorkflowManagement: Codeunit 1501;
        WorkflowEventHandling: Codeunit 1520;
        RFQSendForApprovalEventDescTxt: TextConst ENU = 'Approval of a RFQ document is requested';
        RFQApprovalRequestCancelEventDescTxt: TextConst ENU = 'Approval of a RFQ document is cancel';
}