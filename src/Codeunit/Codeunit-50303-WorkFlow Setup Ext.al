codeunit 50303 "Workflow Setup Ext"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAddWorkflowCategoriesToLibrary', '', true, true)]
    local procedure OnAddWorkflowCategoriesToLibrary()
    begin
        WorkflowSetup.InsertWorkflowCategory(RFQworkflowCategoryTxt, RFQworkflowCategoryDescTxt);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnAfterInsertApprovalsTableRelations', '', true, true)]
    local procedure OnAfterInsertApprovalsTableRelations()
    var
        ApprovalEntry: Record 454;
    begin
        WorkflowSetup.InsertTableRelation(Database::"RFQ Header", 0, Database::"Approval Entry", ApprovalEntry.FieldNo("Record ID to Approve"));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Workflow Setup", 'OnInsertWorkflowTemplates', '', true, true)]
    local procedure OnInsertWorkflowTemplates()
    var
    begin
        InsertRFQApprovalWorkflowTemplate();
    end;

    local procedure InsertRFQApprovalWorkflowTemplate()
    var
        Workflow: Record 1501;
    begin
        WorkflowSetup.InsertWorkflowTemplate(Workflow, RFQApprovalWorkflowCodeTxt, RFQApprovalWorkflowCodeDescTxt, RFQWorkflowCategoryTxt);
        InsertRFQApprovalWorkflowDetails(Workflow);
        WorkflowSetup.MarkWorkflowAsTemplate(Workflow);
    end;

    local procedure InsertRFQApprovalWorkflowDetails(var Workflow: Record 1501)
    var
        WorkflowStepArgument: Record 1523;
        BlankDateFormula: DateFormula;
        WorkflowEventHandlingCust: Codeunit 50301;
        WorkflowResponseHandling: Codeunit 1521;
        RFQ: Record "RFQ Header";
    begin
        /* Below Functin PopulateWorkflowStepArgument is now removal from older BC 18 onwards. new Function Add InitWorkflowStepArgument now.
        WorkflowSetup.PopulateWorkflowStepArgument(WorkflowStepArgument, WorkflowStepArgument."Approver Type"::Approver,
                            WorkflowStepArgument."Approver Limit Type"::"Direct Approver", 0, '', BlankDateFormula, true);
        */

        //New Function Ass BC Suggested temp Commnented
        WorkflowSetup.InitWorkflowStepArgument(WorkflowStepArgument, WorkflowStepArgument."Approver Type"::Approver,
                            WorkflowStepArgument."Approver Limit Type"::"Direct Approver", 0, '', BlankDateFormula, true);



        WorkflowSetup.InsertDocApprovalWorkflowSteps(
            Workflow,
            BuildRFQTypeConditions(RFQ."Approval Status"::Open),
            WorkflowEventHandlingCust.RunWorkflowOnSendRFQForApprovalCode(),
            BuildRFQTypeConditions(RFQ."Approval Status"::"Pending Approval"),
            WorkflowEventHandlingCust.RunWorkflowOnCancelRFQApprovalCode(),
            WorkflowStepArgument,
            true);



    end;

    local procedure BuildRFQTypeConditions(Status: Integer): text
    var
        RFQ: record "RFQ Header";
    begin
        RFQ.SetRange("Approval Status", Status);
        Exit(StrSubstNo(RFQTypeCondTxt, WorkflowSetup.Encode(RFQ.GetView(false))));
    end;

    var
        WorkflowSetup: Codeunit 1502;
        RFQWorkflowCategoryTxt: TextConst ENU = 'RDW';
        RFQWorkflowCategoryDescTxt: TextConst ENU = 'RFQ Document';
        RFQApprovalWorkflowCodeTxt: TextConst ENU = 'RAPW';
        RFQApprovalWorkflowCodeDescTxt: TextConst ENU = 'RFQ Approval Workflow';
        RFQTypeCondTxt: TextConst ENU = '‘<?xml version = “1.0” encoding=”utf-8” standalone=”yes”?><ReportParameters><DataItems><DataItem name=”RFQ”>%1</DataItem></DataItems></ReportParameters>';
}