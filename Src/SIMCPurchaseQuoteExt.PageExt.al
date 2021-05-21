pageextension 50000 "SIMC Purchase Quote Ext" extends "Purchase Quote"
{
    actions
    {
        addfirst(Processing)
        {
            // This will create the button to email the purchase quote
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
            // This will add a button to show the entries in the email log that have been submitted for this purchase quote
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