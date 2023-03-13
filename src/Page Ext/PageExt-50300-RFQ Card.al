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
                    ApplicationArea = All;
                    trigger OnAction()
                    begin
                        ApprovalsMgmt.ApproveRecordApprovalRequest(Rec.RecordId);
                    end;
                }
                action(Reopen)
                {
                    ApplicationArea = All;
                    Caption = 'Reopen';
                    Image = ReOpen;
                    // ToolTip = 'Request approval of the document.';
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    trigger OnAction()
                    var
                        RecRFQ: Record "RFQ Header";
                    begin
                        RecRFQ.Reset();
                        RecRFQ.SetRange("No.", rec."No.");
                        RecRFQ.SetRange("Approval Status", RecRFQ."Approval Status"::Released);
                        IF RecRFQ.FindFirst() then begin
                            RecRFQ."Approval Status" := RecRFQ."Approval Status"::Open;
                            RecRFQ.Modify();
                        end;
                    end;
                }
                action(SendApprovalRequest)
                {
                    ApplicationArea = All;
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
                    ApplicationArea = All;
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
                        ApprovalsMgmtCut.OnCancelRFQForApproval(rec);
                    end;
                }
            }
        }

    }
    trigger OnAfterGetRecord()
    begin
        OpenApprovalEntriesExistForCurrUser := ApprovalsMgmt.HasOpenApprovalEntriesForCurrentUser(Rec.RecordId);
        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);
        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        WorkflowWebhookMgt.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApproavlForFlow, CanCancelApprovalForFlow);
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
    //  RecordID: RecordId;

}