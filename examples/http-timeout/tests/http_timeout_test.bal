import ballerina/test;
import ballerina/http;

@test:Config {}
function testFunc() {
    http:Client httpEndpoint = checkpanic new("http://localhost:9090");

    // Send a GET request to the specified endpoint
    http:Response|error response = httpEndpoint->get("/timeout");
    if (response is http:Response) {
        var result = response.getTextPayload();
        if (result is string) {
            test:assertEquals(result, "Request timed out. Please try again in sometime.");
        } else {
            test:assertFail(msg = "Invalid response message");
        }
    } else {
        test:assertFail(msg = "Failed to call the endpoint");
    }
}
