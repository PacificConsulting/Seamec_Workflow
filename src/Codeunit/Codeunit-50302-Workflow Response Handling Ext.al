codeunit 50302 "Workflow Response Handling Ext"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnOpenDocument', '', true, true)]
    local procedure OnOpenDocument(RecRef: recordref; var Handled: Boolean)
    var
        RFQ: record "RFQ Header";
    begin
        case RecRef.Number of
            database::"RFQ Header":
                begin
                    RecRef.SetTable(RFQ);
                    RFQ."Approval Status" := RFQ."Approval Status"::Open;
                    RFQ.Modify();
                    Handled := true;
                end;

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnReleaseDocument', '', true, true)]
    local procedure OnReleaseDocument(RecRef: recordref; var Handled: Boolean)
    var
        RFQ: record "RFQ Header";
    begin
        case RecRef.Number of
            database::"RFQ Header":
                begin
                    RecRef.SetTable(RFQ);
                    RFQ."Approval Status" := RFQ."Approval Status"::Released;
                    RFQ.Modify();
                    Handled := true;
                end;

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnSetStatusToPendingApproval', '', true, true)]
    local procedure OnSetStatusToPendingApproval(RecRef: recordref; Var Variant: Variant; var IsHandled: Boolean)
    var
        RFQ: record "RFQ Header";
    begin
        case RecRef.Number of
            database::"RFQ Header":
                begin
                    RecRef.SetTable(RFQ);
                    RFQ."Approval Status" := RFQ."Approval Status"::"Pending Approval";
                    RFQ.Modify();
                    IsHandled := true;
                end;

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Response Handling", 'OnAddWorkflowResponsePredecessorsToLibrary', '', true, true)]
    local procedure OnAddWorkflowResponsePredecessorsToLibrary(ResponseFunctionName: Code[128])
    var
        WorkflowResponseHandling: Codeunit 1521;
        WorkflowEventHandlingCust: Codeunit 50301;
    begin
        case ResponseFunctionName of
            WorkflowResponseHandling.SetStatusToPendingApprovalCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SetStatusToPendingApprovalCode(),
                    WorkflowEventHandlingCust.RunWorkflowOnSendRFQForApprovalCode());

            WorkflowResponseHandling.SendApprovalRequestForApprovalCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.SendApprovalRequestForApprovalCode(),
                    WorkflowEventHandlingCust.RunWorkflowOnSendRFQForApprovalCode());

            WorkflowResponseHandling.CancelAllApprovalRequestsCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.CancelAllApprovalRequestsCode(),
                    WorkflowEventHandlingCust.RunWorkflowOnCancelRFQApprovalCode());

            WorkflowResponseHandling.OpenDocumentCode():
                WorkflowResponseHandling.AddResponsePredecessor(WorkflowResponseHandling.OpenDocumentCode(),
                    WorkflowEventHandlingCust.RunWorkflowOnCancelRFQApprovalCode());

        end;
    end;

    var
        myInt: Integer;
}