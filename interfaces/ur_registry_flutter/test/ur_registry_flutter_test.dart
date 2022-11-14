import 'dart:ffi';

import 'package:convert/convert.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/registries/crypto_hd_key.dart';
import 'package:ur_registry_flutter/registries/solana/crypto_multi_accounts.dart';
import 'package:ur_registry_flutter/registries/solana/sol_sign_request.dart';
import 'package:ur_registry_flutter/registries/solana/sol_signature.dart';
import 'package:ur_registry_flutter/ur_decoder.dart';
import 'package:ur_registry_flutter/ur_encoder.dart';
import 'package:ur_registry_flutter/ur_registry_flutter.dart';

void main() {
  const MethodChannel channel = MethodChannel('ur_registry_flutter');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await UrRegistryFlutter.platformVersion, '42');
  });

  test('test', () async {
    String ur =
        "UR:CRYPTO-MULTI-ACCOUNTS/OTADCYWLCSCEWFAOLYTAADDLOEAXHDCLAOWDVEROKOPDINHSEEROISYALKSAYKCTJSHEDPRNUYJYFGROVAWEWFTYGHCEGLRPKGAMTAADDYOYADLOCSDWYKCFADYKYKAEYKAEYKAXISJEIHKKJKJYJLJTIHEOKKKGKT";
    URDecoder urDecoder = URDecoder();
    while (!urDecoder.isComplete()) {
      urDecoder.receive(ur);
    }

    NativeObject nativeObject =
        urDecoder.resolve(SupportedType.cryptoMultiAccounts);
    nativeObject as CryptoMultiAccounts;
    List<CryptoHDKey> cryptoKeys = nativeObject.getKeys();
    String masterFingerprint = nativeObject.getMasterFingerprint();
    for (var key in cryptoKeys) {
      key.getKeyData(); // publickey
      key.getPath(); // bip44 derivation path
      key.getAccountIndex(3); //get number of each bip44 level component
    }
  });

  test("generate solana transaction", () async {

    List<int> signData = List.from(hex.decoder.convert("01020304"));
    String path = "M/44'/501'/0'/0/1";
    String xfp = "01020304";
    List<int> pubkey = List.from(hex.decoder.convert("010203040506"));
    String origin = "BitKeep";
    int signType = 1; // 1: Transaction, 2: Message
    SolSignRequest solSignRequest = SolSignRequest.factory(signData, path, xfp, pubkey, origin, signType);
    UREncoder urEncoder = solSignRequest.toUREncoder();
    String requestId = solSignRequest.uuid; //get request id;
    while(true) {
      renderQR(urEncoder.nextPart());
    }
  });

  test("collect sol signature", () async {
    String ur = "UR:SOL-SIGNATURE/OEADTPDAGDNDCAWMGTFRKIGRPMNDUTDNBTKGFSSBJNAOHDFZTYWTOSRFTAHPRDCTRKBEGYLOGDGHJKBAFHFLAMFWLOHGHTPSSEAOZORSIMNYBBTNNBIYNLCKENBTFMEEAMSABNAEOXASJKWSWFKEKIIECKHPECCKSSPTNDZELNWFECYLDRCYHKWS";
    URDecoder urDecoder = URDecoder();
    while (!urDecoder.isComplete()) {
      urDecoder.receive(ur);
    }
    NativeObject nativeObject =
        urDecoder.resolve(SupportedType.solSignature);
    nativeObject as SolSignature;
    String requestId = nativeObject.getRequestId(); // get request id, check it with sign request if you need;
    List<int> signature = nativeObject.getSignature(); // get sigature
  })
}
