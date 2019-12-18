codeunit 50000 "Event Subscribers"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SIMC AEM Log Email Meth", 'OnBeforeLogSpecialDocType', '', true, true)]
    local procedure OnBeforeLogSpecialDocType(DocType: Enum "SIMC AEM Document Type";
                                              var DocNo: code[20];
                                              var EmailTo: Text;
                                              var ccEmailTo: Text;
                                              var bccEmailTo: Text;
                                              var TriggerError: Boolean;
                                              var EmailTemplate: Record "SIMC AEM Email Template";
                                              var AutoEmailLog: Record "SIMC Auto Email Log");

    var
        PurchHeader: Record "Purchase Header";
        Vendor: Record Vendor;
    begin
        // We need to catch all custom document types
        // Here we get all relevant information for the puchase invoice to be logged.
        if DocType = DocType::PurchaseQuote then begin
            PurchHeader.GET(PurchHeader."Document Type"::Quote, DocNo);
            Vendor.Get(PurchHeader."Buy-from Vendor No.");
            EmailTo := Vendor."SIMC Email To";
            EmailTemplate.Get(GetDefaultTemplate(DocType));
            AutoEmailLog."Email Template" := EmailTemplate.Code;
            AutoEmailLog.Subject := StrSubstNo(EmailTemplate."Email Subject", DocNo);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SIMC AEM Create and Mail Meth", 'OnBeforeCustomDocEmailed', '', true, true)]
    local procedure OnProcessDocument(DocType: Enum "SIMC AEM Document Type";
                                        var RecRef: RecordRef;
                                        var AutoEmailLog: Record "SIMC Auto Email Log";
                                        var EmailTemplate: Record "SIMC AEM Email Template";
                                        var DocumentName: Text;
                                        var MergeField1: Text;
                                        var MergeField2: Text)
    var
        PurchHeader: Record "Purchase Header";
    begin
        // Get RecRef for Purchase Quote. Get Merge Fields
        if DocType = DocType::PurchaseQuote then begin
            with PurchHeader do begin
                Get("Document Type"::Quote, AutoEmailLog."Document No.");
                SetRange("Document Type", "Document Type"::Quote);
                SetRange("No.", AutoEmailLog."Document No.");
                RecRef.GETTABLE(PurchHeader);
                MergeField1 := "No.";
                MergeField2 := "Buy-from Vendor Name";
            end;
        END;
    end;

    local procedure GetDefaultTemplate(DocType: Enum "SIMC AEM Document Type"): Code[20]
    var
        EmailTemplate: Record "SIMC AEM Email Template";
        TemplateNotExistErrLbl: label 'Default Email Template for %1 does not exist';
    begin
        with EmailTemplate do begin
            SetRange("Document Type", DocType);
            SetRange(Default, true);
            if not FindSet() then
                Error(TemplateNotExistErrLbl, DocType);
            Exit(Code);
        end;
    end;
}