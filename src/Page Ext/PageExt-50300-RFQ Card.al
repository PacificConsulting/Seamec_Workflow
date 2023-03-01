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
                    //Enabled = NOT OpenApprovalEntriesExist AND CanRequestApprovalForFlow;
                    Image = SendApprovalRequest;
                    ToolTip = 'Request approval of the document.';

                    trigger OnAction()
                    var
                        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
                    begin
                        //         if ApprovalsMgmt.check
                        //           ApprovalsMgmt.OnSendSalesDocForApproval(Rec);
                    end;
                }
            }
        }
    }

    var
        ApprovalsMgmt: Codeunit 1535;
        RecordID: RecordId;
}