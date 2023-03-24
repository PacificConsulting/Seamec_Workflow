pageextension 50300 RFQ_Card_Ext extends "RFQ Card"
{
    layout
    {

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
                action(Release)
                {
                    ApplicationArea = All;
                    Caption = 'Release';
                    Image = ReleaseDoc;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;
                    trigger OnAction()
                    var
                        RecRFQ: Record "RFQ Header";
                        WorKflow: Record Workflow;
                    begin

                        IF WorKflow.Get('RFQ') then begin
                            IF WorKflow.Enabled = true then
                                Error(NoworkFlowEnableErr);

                            RecRFQ.Reset();
                            RecRFQ.SetRange("No.", rec."No.");
                            RecRFQ.SetRange("Approval Status", RecRFQ."Approval Status"::Open);
                            IF RecRFQ.FindFirst() then begin
                                RecRFQ."Approval Status" := RecRFQ."Approval Status"::Released;
                                RecRFQ.Modify();
                            end;
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
                        AppEntr: Record "Approval Entry";
                    begin
                        if ApprovalsMgmtCut.CheckRFQApprovalWorkflowEnable(Rec) then
                            ApprovalsMgmtCut.OnSendRFQForApproval(Rec);
                        //
                        //  IF rec."Approval Status" = rec."Approval Status"::"Pending Approval" then begin
                        // AppEntr.Reset();
                        // AppEntr.SetRange("Document No.", Rec."No.");
                        // IF AppEntr.FindSet() then
                        //     repeat
                        //         Rec.CalcFields("Total Amount");
                        //         AppEntr.Amount := Rec."Total Amount";
                        //         AppEntr."Amount (LCY)" := rec."Total Amount";
                        //         AppEntr.Modify();
                        //     until AppEntr.Next() = 0;
                        // end;
                    end;
                }
                action(CancelApprovalRequest)
                {
                    ApplicationArea = All;
                    Caption = 'Cancel A&pproval Request';
                    Enabled = CancelAppEnable;//CanCancelApprovalForRecord AND CanCancelApprovalForFlow;
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

        IF (rec."Approval Status" = rec."Approval Status"::"Pending Approval") then begin
            CancelAppEnable := true;
        end;
        if (rec."Approval Status" = rec."Approval Status"::Released) then begin
            CancelAppEnable := false;
        end;
    end;

    trigger OnOpenPage()
    begin
        IF (rec."Approval Status" = rec."Approval Status"::"Pending Approval") then begin
            CancelAppEnable := true;
        end;
        if (rec."Approval Status" = rec."Approval Status"::Released) then begin
            CancelAppEnable := false;
        end;

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
        NoworkFlowEnableErr: Label 'Workflow is enabled you can not release the order.';
        CancelAppEnable: Boolean;


}