pageextension 50000 "Purchase Quote Ext" extends "Purchase Quote" // 49
{
    actions
    {
        // Add changes to page actions here
        addfirst(Processing)
        {
            action("Email Purchase Quote")
            {
                Caption = 'Email Purchase Quote';
                ApplicationArea = All;
                Image = SendEmailPDF;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    LogEmail.LogEmail(DocType::PurchaseQuote, "No.", true, true);
                end;
            }
            action("Show Email Log")
            {
                Caption = 'Show Email Log';
                ApplicationArea = All;
                Image = Log;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    LogEmail.ShowEmailLog(DocType::PurchaseQuote, "No.");
                end;
            }
        }
    }

    var
        LogEmail: Codeunit "SIMC AEM Log Email Meth";
        DocType: Enum "SIMC AEM Document Type";
}