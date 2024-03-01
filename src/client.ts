import { createPromiseClient } from "@connectrpc/connect";
import { GreetService } from "./gen/greet/v1/greet_connect";
import { createConnectTransport } from "@connectrpc/connect-node";

const transport = createConnectTransport({
    baseUrl: "http://localhost:8080",
    httpVersion: "1.1"
});

async function main() {
    const client = createPromiseClient(GreetService, transport);
    const res = await client.createUser({ "user": { email: "email" } })
    console.log(res.user);
}
void main();
