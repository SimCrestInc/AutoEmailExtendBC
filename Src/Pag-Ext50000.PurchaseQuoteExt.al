pageextension 50000 "Purchase Quote Ext" extends "Purchase Quote"
{
    actions
    {
        // Add changes to page actions here
        addfirst(Processing)
        {
            action("SIMC Email Purchase Quote")
            {
                Caption = 'Email Purchase Quote';
                ApplicationArea = All;
                Image = SendEmailPDF;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    SIMCLogEmail.LogEmail(SIMCDocType::PurchaseQuote, "No.", true, true);
                end;
            }
            action("SIMC Show Email Log")
            {
                Caption = 'Show Email Log';
                ApplicationArea = All;
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    SIMCLogEmail.ShowEmailLog(SIMCDocType::PurchaseQuote, "No.");
                end;
            }
        }
    }

    var
        SIMCLogEmail: Codeunit "SIMC AEM Log Email Meth";
        SIMCDocType: Enum "SIMC AEM Document Type";
}