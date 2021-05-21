codeunit 50000 "SIMC Pur Quote Subscribers"
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

    // Get's the default template for the purchase quote
    local procedure GetDefaultTemplate(DocType: Enum "SIMC AEM Document Type"): Code[20]
    var
        EmailTemplate: Record "SIMC AEM Email Template";
        TemplateNotExistErrLbl: label 'Default Email Template for %1 does not exist';
    begin
        EmailTemplate.SetRange("Document Type", DocType);
        EmailTemplate.SetRange(Default, true);
        if not EmailTemplate.FindSet() then
            Error(TemplateNotExistErrLbl, DocType);
        exit(EmailTemplate.Code);
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
        // Get RecRef for Purchase Quote. RecRef is used to print the purchase quote to PDF
        if DocType = DocType::PurchaseQuote then begin
            PurchHeader.Get(PurchHeader."Document Type"::Quote, AutoEmailLog."Document No.");
            PurchHeader.SetRange("Document Type", PurchHeader."Document Type"::Quote);
            PurchHeader.SetRange("No.", AutoEmailLog."Document No.");
            RecRef.GETTABLE(PurchHeader);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SIMC AEM Log Email Meth", 'OnBeforeLoadingMergeFields', '', true, true)]
    local procedure OnBeforeLoadingMergeFields(DocType: Enum "SIMC AEM Document Type";
                                           DocNo: Code[50];
                                           EmailTemplate: Record "SIMC AEM Email Template";
                                           var BodyText: Text;
                                           var Subject: Text[250]);
    var
        PurchHeader: Record "Purchase Header";
    begin
        // Add mergefields 3, 4 and 5 to BodyText and add one additional merge field to Subject. Mergefields 1 and 2 are done by standard Auto Email.
        if DocType = DocType::PurchaseQuote then begin
            PurchHeader.Get(PurchHeader."Document Type"::Quote, DocNo);
            // At this point BodyText has already %1 and %2 merged, so they will not be changed anymore. So we just pass empty string to them
            BodyText := StrSubstNo(BodyText, '', '', PurchHeader."Payment Method Code", PurchHeader."Location Code", PurchHeader."Ship-to Name");
            Subject := StrSubstNo(Subject, '', '', PurchHeader."Reason Code");
            // Done merging and this is sent back to Auto Email to be logged
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SIMC AEM Log Email Meth", 'OnAfterSetupEmail', '', true, true)]
    local procedure OnAfterSetupEmail(Type: Enum "SIMC AEM Log Account Type";
                                          DocNo: Code[50];
                                          "No.": Code[20];
                                          DocType: Enum "SIMC AEM Document Type";
                                          var EmailTo: Text;
                                          var ccEmailTo: Text;
                                          var bccEmailTo: Text)
    var
        PH: Record "Purchase Header";
        Vendor: Record Vendor;
    begin
        // We get the vendor and add the email in front of the email Auto Email inserted
        if DocType = DocType::PurchaseQuote then begin
            PH.Get(PH."Document Type"::Quote, DocNo);
            Vendor.Get(PH."Pay-to Vendor No.");
            EmailTo := Vendor."E-Mail" + ';' + EmailTo;
            // Done changing emails
        end;
    end;
}