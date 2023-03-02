codeunit 50304 "Page Management Ext"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Page Management", 'OnAfterGetPageID', '', true, true)]
    local procedure OnAfterGetPageID(RecordRef: RecordRef; var PageID: Integer)
    begin
        if PageID = 0 then
            PageID := GetConditionalCardPageID(RecordRef)
    end;


    local procedure GetConditionalCardPageID(RecordRef: RecordRef): integer
    var
    begin
        case RecordRef.Number of
            database::"RFQ Header":
                Exit(Page::"RFQ Card");

        end;
    end;

    var
        myInt: Integer;
}