pageextension 50300 RFQ_Card_Ext extends "RFQ Card"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addfirst(Processing)
        {
            group("Request Approval")
            {
                action(Approve)
                {
                    Visible = true;
                    image = Approval;
                    Promoted = true;
                    PromotedCategory = process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.ApproveRecordApprovalRequest(RecordID);
                    end;
                }
                action(SendApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Send A&pproval Request';
                    Enabled = NOT OpenApprovalEntriesExist AND CanRequestApproavlForFlow;
                    Image = SendApprovalRequest;
                    ToolTip = 'Request approval of the document.';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                    begin
                        if ApprovalsMgmtCut.CheckRFQApprovalWorkflowEnable(Rec) then
                            ApprovalsMgmtCut.OnSendRFQForApproval(Rec);
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Cancel A&pproval Request';
                    Enabled = NOT OpenApprovalEntriesExist AND CanRequestApproavlForFlow;
                    Image = CancelApprovalRequest;
                    ToolTip = 'Request approval of the document.';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                    begin
                        ApprovalsMgmtCut.OnSendRFQForApproval(Rec);
                    end;
                }
            }
        }

    }
    trigger OnAfterGetRecord()
    begin
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(RecordID);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(RecordID);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(RecordID);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(RecordID, CanRequestApproavlForFlow, CanCancelApprovalForFlow);
    end;

    var
        ApprovalsMgmt: Codeunit 1535;
        ApprovalsMgmtCut: Codeunit 50300;
        WorkflowWebhookMgt: Codeunit 1543;
        OpenApprovalEntriesExistForCurrUser: Boolean;
        OpenApprovalEntriesExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        CanCancelApprovalForFlow: Boolean;
        CanRequestApproavlForFlow: Boolean;

        RecordID: RecordId;
}