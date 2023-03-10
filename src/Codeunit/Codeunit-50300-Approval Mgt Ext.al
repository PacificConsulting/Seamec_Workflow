codeunit 50300 "Approval Mgmt Ext."
{
    trigger OnRun()
    begin

    end;

    [integrationEvent(False, false)]
    procedure OnSendRFQForApproval(Var RFQ: record "RFQ Header")
    begin

    end;

    [integrationEvent(False, false)]
    procedure OnCancelRFQForApproval(Var RFQ: record "RFQ Header")
    begin

    end;

    procedure CheckRFQApprovalWorkflowEnable(var RFQ: Record "RFQ Header"): Boolean
    var
    begin
        IF Not IsRFQDocApprovalsWorkflowEnable(RFQ) then
            Error(NoworkFlowEnableErr);
        exit(true);
    end;

    procedure IsRFQDocApprovalsWorkflowEnable(var RFQ: Record "RFQ Header"): Boolean
    Begin
        IF RFQ."Approval Status" <> RFQ."Approval Status"::Open then
            exit(false);
        exit(WorkflowManagement.CanExecuteWorkflow(RFQ, WorkFlowEventHandlingCust.RunWorkflowOnSendRFQForApprovalCode));

    End;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Approvals Mgmt.", 'OnPopulateApprovalEntryArgument', '', true, true)]
    local procedure OnPopulateApprovalEntryArgument(var RecRef: RecordRef; var ApprovalEntryArgument: Record "Approval Entry";
                    WorkflowStepInstance: Record "Workflow Step Instance")
    var
        RFQ: record "RFQ Header";
    begin
        case RecRef.Number of
            database::"RFQ Header":
                begin
                    RecRef.SetTable(RFQ);
                    ApprovalEntryArgument."Document No." := RFQ."No.";
                end;

        end;
    end;

    var
        NoworkFlowEnableErr: TextConst ENU = 'No approval workflow for this record type is enabled.';
        WorkflowManagement: Codeunit 1501;
        WorkFlowEventHandlingCust: Codeunit 50301;
}
