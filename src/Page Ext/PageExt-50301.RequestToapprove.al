pageextension 50301 "Request To Approve_ext" extends "Requests to Approve"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
        //PCPL-25/240323
        modify(Approve)
        {
            trigger OnAfterAction()
            var
                RecRFQ: Record "RFQ Header";
                AppEntr: Record "Approval Entry";
            begin
                AppEntr.Reset();
                AppEntr.SetRange("Document No.", Rec."Document No.");
                AppEntr.SetRange("Table ID", 50020);
                AppEntr.SetRange(Status, AppEntr.Status::Approved);
                IF AppEntr.FindLast then begin
                    RecRFQ.Reset();
                    RecRFQ.SetRange("No.", AppEntr."Document No.");
                    RecRFQ.SetRange("Approval Status", RecRFQ."Approval Status"::"Pending Approval");
                    IF RecRFQ.FindFirst() then begin
                        RecRFQ."Approval Status" := RecRFQ."Approval Status"::Released;
                        RecRFQ.Modify();
                    end;
                end;

            end;
        }
        //PCPL-25/240323
    }

    var
        myInt: Integer;
}