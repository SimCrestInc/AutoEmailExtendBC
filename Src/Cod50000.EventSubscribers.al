codeunit 50000 "Event Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SIMC AEM Log Email Meth", 'OnBeforeLogSpecialDocType', '', true, true)]
    local procedure OnBeforeLogSpecialDocType(DocType: Enum "SIMC AEM Document Type";
                                              var DocNo: code[50];
                                              var EmailTo: Text;
                                              var ccEmailTo: Text;
                                              var bccEmailTo: Text;
                                              var TriggerError: Boolean;
                                              var EmailTemplate: Record "SIMC AEM Email Template";
                                              var AutoEmailLog: Record "SIMC Auto Email Log";
                                              var MergeField1: Text;
                                              var MergeField2: Text);

    var
        PurchHeader: Record "Purchase Header";
        Vendor: Record Vendor;
    begin
        // We need to catch all custom document types
        // Here we get all relevant information for the puchase quote to be logged.
        if DocType = DocType::PurchaseQuote then begin
            PurchHeader.GET(PurchHeader."Document Type"::Quote, DocNo);
            Vendor.Get(PurchHeader."Buy-from Vendor No.");
            EmailTo := Vendor."SIMC Email To";
            ccEmailTo := Vendor."SIMC ccEmail To";
            bccEmailTo := Vendor."SIMC bccEmail To";
            EmailTemplate.Get(GetDefaultTemplate(DocType));
            AutoEmailLog."Email Template" := EmailTemplate.Code;
            AutoEmailLog.Subject := StrSubstNo(EmailTemplate."Email Subject", DocNo);
            MergeField1 := PurchHeader."No.";
            MergeField2 := PurchHeader."Buy-from Vendor Name";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SIMC AEM Create and Mail Meth", 'OnBeforeCustomDocEmailed', '', true, true)]
    local procedure OnProcessDocument(DocType: Enum "SIMC AEM Document Type";
                                        var RecRef: RecordRef;
                                        var AutoEmailLog: Record "SIMC Auto Email Log";
                                        var EmailTemplate: Record "SIMC AEM Email Template";
                                        var DocumentName: Text)
    var
        PurchHeader: Record "Purchase Header";
    begin
        // Get RecRef for Purchase Quote. Get Merge Fields
        if DocType = DocType::PurchaseQuote then begin
            PurchHeader.Get(PurchHeader."Document Type"::Quote, AutoEmailLog."Document No.");
            PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Quote);
            PurchHeader.SetRange("No.", AutoEmailLog."Document No.");
            RecRef.GETTABLE(PurchHeader);
        end;
    end;

    local procedure GetDefaultTemplate(DocType: Enum "SIMC AEM Document Type"): Code[20]
    var
        EmailTemplate: Record "SIMC AEM Email Template";
        TemplateNotExistErrLbl: label 'Default Email Template for %1 does not exist';
    begin
        EmailTemplate.SetRange("Document Type", DocType);
        EmailTemplate.SetRange(Default, true);
        if not EmailTemplate.FindSet() then
            Error(TemplateNotExistErrLbl, DocType);
        Exit(EmailTemplate.Code);
    end;
}