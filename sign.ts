import Eth from "@ledgerhq/hw-app-eth";
import TransportNodeHid from "@ledgerhq/hw-transport-node-hid";

async function signMessage(path: string, domainHashHex: string, messageHashHex: string): Promise<void> {
  try {
    console.log("Open transport")
    const transport = await TransportNodeHid.create();

    console.log("Initialize eth")
    const eth = new Eth(transport);

    console.log("Sign message")
    const result = await eth.signEIP712HashedMessage(
      path,
      domainHashHex,
      messageHashHex
    );

    let v = result.v - 27;
    const vHex = v.toString(16).padStart(2, "0");
    console.log("Signature 0x" + result.r + result.s + vHex);

    await transport.close();
  } catch (error) {
    console.error("Error:", error);
    process.exit(1);
  }
}

const args = process.argv.slice(2);
if (args.length < 3) {
  console.error('Usage: npx ts-node sign.ts "path" "domainHashHex" "messageHashHex"');
  process.exit(1);
}

const [path, domainHashHex, messageHashHex] = args;
signMessage(path, domainHashHex, messageHashHex);
