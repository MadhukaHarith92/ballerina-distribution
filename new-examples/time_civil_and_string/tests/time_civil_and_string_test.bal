import ballerina/io;
import ballerina/test;

string[] outputs = [];
int counter = 0;

// This is the mock function, which will replace the real function.
@test:Mock {
    moduleName: "ballerina/io",
    functionName: "println"
}
test:MockFunction mock_printLn = new ();

public function mockPrint(io:Printable... s) {
    string outstr = "";
    foreach io:Printable str in s {
        outstr = outstr + new PrintableClassImpl(str).toString();
    }
    outputs[counter] = outstr;
    counter += 1;
}

// From ballerina/io module to mock io:println() with raw templates
class PrintableClassImpl {
    io:Printable printable;

    public isolated function init(io:Printable printable) {
        self.printable = printable;
    }
    public isolated function toString() returns string {
        io:Printable printable = self.printable;
        if printable is io:PrintableRawTemplate {
            return new PrintableRawTemplateImpl(printable).toString();
        } else if printable is error {
            return printable.toString();
        } else {
            return printable.toString();
        }
    }
}

class PrintableRawTemplateImpl {
    *object:RawTemplate;
    public io:Printable[] insertions;

    public isolated function init(io:PrintableRawTemplate printableRawTemplate) {
        self.strings = printableRawTemplate.strings;
        self.insertions = printableRawTemplate.insertions;
    }
    public isolated function toString() returns string {
        io:Printable[] templeteInsertions = self.insertions;
        string[] templeteStrings = self.strings;
        string templatedString = templeteStrings[0];
        foreach int i in 1 ..< (templeteStrings.length()) {
            io:Printable templateInsert = templeteInsertions[i - 1];
            if (templateInsert is io:PrintableRawTemplate) {
                templatedString += new PrintableRawTemplateImpl(templateInsert).toString() + templeteStrings[i];
            } else if (templateInsert is error) {
                templatedString += templateInsert.toString() + templeteStrings[i];
            } else {
                templatedString += templateInsert.toString() + templeteStrings[i];
            }
        }
        return templatedString;
    }
}

@test:Config {}
function testFunc() returns error? {
    test:when(mock_printLn).call("mockPrint");

    // Invoking the main function
    check main();

    test:assertEquals(outputs[0], 
    "Converted civil value: {\"utcOffset\":{\"hours\":5,\"minutes\":30},\"timeAbbrev\":\"Asia/Colombo\",\"dayOfWeek\":1,\"year\":2021,\"month\":4,\"day\":12,\"hour\":23,\"minute\":20,\"second\":50.52}");
    test:assertEquals(outputs[1], "Civil string representation: 2021-04-12T17:50:50.520Z");
}
