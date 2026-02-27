// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:convert/convert.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ur_registry_flutter/native_object.dart';
import 'package:ur_registry_flutter/registries/crypto_account.dart';
import 'package:ur_registry_flutter/registries/crypto_hd_key.dart';
import 'package:ur_registry_flutter/registries/crypto_psbt.dart';
import 'package:ur_registry_flutter/registries/ethereum/eth_signature.dart';
import 'package:ur_registry_flutter/registries/extend/crypto_multi_accounts.dart';
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

  test("collect sol signature", () async {
    String ur =
        "UR:SOL-SIGNATURE/OEADTPDAGDNDCAWMGTFRKIGRPMNDUTDNBTKGFSSBJNAOHDFZTYWTOSRFTAHPRDCTRKBEGYLOGDGHJKBAFHFLAMFWLOHGHTPSSEAOZORSIMNYBBTNNBIYNLCKENBTFMEEAMSABNAEOXASJKWSWFKEKIIECKHPECCKSSPTNDZELNWFECYLDRCYHKWS";
    URDecoder urDecoder = URDecoder();
    while (!urDecoder.isComplete()) {
      urDecoder.receive(ur);
    }
    NativeObject nativeObject = urDecoder.resolve(SupportedType.solSignature);
    nativeObject as SolSignature;
    String requestId = nativeObject
        .getRequestId(); // get request id, check it with sign request if you need;
    List<int> signature = nativeObject.getSignature(); // get sigature
  });

  test("collect btc accounts", () async {
    String ur =
        "UR:CRYPTO-ACCOUNT/OEADCYEMREWYTYAOLNTAADMUTAADDLOXAXHDCLAXWMFMDEIAMECSDSEMGTVSJZCNCYGRKOWTRONTZSCHGEZOKSTSWKKSCFMKLRTAUTEYAAHDCXIEHFONURDPPFYNTAPEJPPROYPEGRDAWKGMAEWEJLSFDTSRFYBDEHCAFLMTRLBDHPAMTAADDYOYADLNCSDWYKAEYKAEYKAYCYNLYTSNYLTAADMHTAADMWTAADDLOXAXHDCLAOSTVELFEMDYYNWYDWYAIEVOSRGMAMBKLOVABDGYPDGLLDVESPSTHYSADAMHPMJEINAAHDCXNTDLLNAAEYKOYTDACYGEGWHGJSIYONPYWMCMRPWPHSVODSREROZSBYAXLUZCOXDPAMTAADDYOYADLNCSEHYKAEYKAEYKAYCYPDBSKEUYTAADMWTAADDLOXAXHDCLAXZCFXEEGDRPMOGRGWKBZCTLTTWEADKIENGRWLHTPRREMOUOLUUTQDPFBNCEDKYNFHAAHDCXJPWEVDEOGTHTTKMESWZCOLCPSAAHCFNSHKHTEHYTCLMNTEATMOTEADTLWYNNFTLOAMTAADDYOYADLNCSGHYKAEYKAEYKAYCYBTHLVYTSTAADMHTAADDLOXAXHDCLAXHHSNHDRPFTDWUOCNTILYDIBEHNECMOVDFEKPJKCLCSLASBHKPAWSADDMCMMNAHNYAAHDCXLOTEDTNDFYMYLTCLHLMTPFSADSCNHTZTAOLBNNKISTAEDEGWFMMEDREETNWMCYCNAMTAADDYOYADLFCSDPYKAYCYEMREWYTYTAADMHTAADMETAADDLOXAXHDCLAXDWKSWMZTPYTNSWTSECNBLFBAYAJKDLDECLQZZOLRSNHLJEDSGMINETYTBNAHATBYAAHDCXKKGUWSVYIMJKVWTEYTWZTYSWVENDTPMNCPASFRRYLPRNHTKBLNDRGRMKOYJTBKRPAMTAADDYOYADLOCSDYYKAEYKAEYKADYKAYCYHKRPNDDRTAADMETAADDLOXAXHDCLAOHNHFFMVSBNDSLRFGCLPFJEJYATBDPEBACNZOKOTOFXNTAOEMVSKPAOWMRYFNOTFGAAHDCXDLNBVECENTSSFSSSGYLNHKRSTOYTECRDLYADREKIRFAYBGLAHLTALSRFCAEEROBWAMTAADDYOYADLOCSDYYKAEYKAEYKAOYKAYCYHKRPNDDRGDAOGYKB";
    URDecoder urDecoder = URDecoder();
    while (!urDecoder.isComplete()) {
      urDecoder.receive(ur);
    }
    NativeObject nativeObject = urDecoder.resolve(SupportedType.cryptoAccount);
    nativeObject as CryptoAccount;
    List<CryptoHDKey> keys = nativeObject.getKeys();
    String masterFingerprint = nativeObject.getMasterFingerprint();
  });

  test("receive psbt", () async {
    String ur =
        "UR:CRYPTO-PSBT/HDOSJOJKIDJYZMADAENYAOAEAEAEAOHDVSKNCLREJNPEBNCNRNMNJOJOFEJZEOJLKERDONSPKPKKDKYKFELOKGPRPYUTKPAEAEAEAEAEZMZMZMZMLSLGAADITIWPIHBKISPKFGRKBDASLEWDFYCPRTJSPRSGKSECDRATKKHKTIKEWDCAADAEAEAEAEZMZMZMZMAOJOPKWTAYAEAEAEAECMAEBBTPHHDNJSTIAMBDASSOLOIMWMLYHYGDNLCATNBGGTAEVYYKAHAEAEAEAECMAEBBAEPLPTOEVWWTYAKOONLOURGOFGVSJYDPCALTAEMYAEAEAEAEAEAEAEAEAEBKGDCARH";
    URDecoder urDecoder = URDecoder();
    while (!urDecoder.isComplete()) {
      urDecoder.receive(ur);
    }
    NativeObject nativeObject = urDecoder.resolve(SupportedType.cryptoPSBT);
    nativeObject as CryptoPSBT;
    String data = nativeObject.getData();
    List<int> psbt = hex.decode(data);
  });

  test("connect eth", () async {
    String ur =
        "UR:CRYPTO-HDKEY/OXAXHDCLAOWDVEROKOPDINHSEEROISYALKSAYKCTJSHEDPRNUYJYFGROVAWEWFTYGHCEGLRPKGAAHDCXTPLFJSLUKNFWLAISAXWYPALBJYLSWZAMCXHSCYUYLOZTMWFNLDLGSKPYPTGSDECFAMTAADDYOEADLNCSDWYKCSFNYKAEYKAOCYWLCSCEWFAYCYTEDMFEAYGHLPTNIN";
    URDecoder urDecoder = URDecoder();
    while (!urDecoder.isComplete()) {
      urDecoder.receive(ur);
    }
    NativeObject key = urDecoder.resolve(SupportedType.cryptoHDKey);
    key as CryptoHDKey;
    key.getKeyData(); // publickey
    key.getChainCode(); //chain code
    key.getBip32Xpub(); //get extended public key
    key.getSourceFingerprint(); //get master fingerprint
  });

  test("get eth signature", () async {
    String ur =
        "UR:ETH-SIGNATURE/OEADTPDAGDNDCAWMGTFRKIGRPMNDUTDNBTKGFSSBJNAOHDFPTYWTOSRFTAHPRDCTRKBEGYLOGDGHJKBAFHFLAMFWLOHGHTPSSEAOZORSIMNYBBTNNBIYNLCKENBTFMEEAMSABNAEOXASJKWSWFKEKIIECKHPECCKSSPTNDZELNWFECYLBWDLSGVAZT";
    URDecoder urDecoder = URDecoder();
    while (!urDecoder.isComplete()) {
      urDecoder.receive(ur);
    }
    NativeObject signature = urDecoder.resolve(SupportedType.ethSignature);
    signature as EthSignature;
    signature.getRequestId(); // uuid
    signature.getSignature(); // signature as [r, s, v]
  });

  test("decode single-part UR with assertions", () async {
    // This UR uses the old single-part format (ur:type/body without part index).
    // The decoder must handle this format for backwards compatibility with
    // existing QR codes from older apps and hardware wallets.
    String ur =
        "UR:CRYPTO-PSBT/HDOSJOJKIDJYZMADAENYAOAEAEAEAOHDVSKNCLREJNPEBNCNRNMNJOJOFEJZEOJLKERDONSPKPKKDKYKFELOKGPRPYUTKPAEAEAEAEAEZMZMZMZMLSLGAADITIWPIHBKISPKFGRKBDASLEWDFYCPRTJSPRSGKSECDRATKKHKTIKEWDCAADAEAEAEAEZMZMZMZMAOJOPKWTAYAEAEAEAECMAEBBTPHHDNJSTIAMBDASSOLOIMWMLYHYGDNLCATNBGGTAEVYYKAHAEAEAEAECMAEBBAEPLPTOEVWWTYAKOONLOURGOFGVSJYDPCALTAEMYAEAEAEAEAEAEAEAEAEBKGDCARH";

    URDecoder urDecoder = URDecoder();
    expect(urDecoder.isComplete(), isFalse);

    urDecoder.receive(ur);
    expect(urDecoder.isComplete(), isTrue);

    NativeObject nativeObject = urDecoder.resolve(SupportedType.cryptoPSBT);
    nativeObject as CryptoPSBT;
    String data = nativeObject.getData();

    // Verify the decoded data matches the known PSBT hex
    expect(
        data,
        equals(
            '70736274ff01009a020000000258e87a21b56daf0c23be8e7070456c336f7cbaa5c8757924f545887bb2abdd750000000000ffffffff838d0427d0ec650a68aa46bb0b098aea4422c071b2ca78352a077959d07cea1d0100000000ffffffff0270aaf00800000000160014d85c2b71d0060b09c9886aeb815e50991dda124d00e1f5050000000016001400aea9a2e5f0f876a588df5546e8742d1d87008f000000000000000000'));
  });

  test("single-part PSBT encode-decode round-trip", () async {
    String psbtHex =
        '70736274ff01009a020000000258e87a21b56daf0c23be8e7070456c336f7cbaa5c8757924f545887bb2abdd750000000000ffffffff838d0427d0ec650a68aa46bb0b098aea4422c071b2ca78352a077959d07cea1d0100000000ffffffff0270aaf00800000000160014d85c2b71d0060b09c9886aeb815e50991dda124d00e1f5050000000016001400aea9a2e5f0f876a588df5546e8742d1d87008f000000000000000000';

    // Encode
    CryptoPSBT cryptoPSBT = CryptoPSBT.factory(hex.decode(psbtHex));
    UREncoder urEncoder = cryptoPSBT.toUREncoder();

    // Decode (single part: one call to nextPart/receive should complete)
    URDecoder urDecoder = URDecoder();
    int partCount = 0;
    while (!urDecoder.isComplete()) {
      String part = urEncoder.nextPart();
      urDecoder.receive(part);
      partCount++;
    }
    expect(partCount, equals(1));

    // Verify round-trip
    NativeObject nativeObject = urDecoder.resolve(SupportedType.cryptoPSBT);
    nativeObject as CryptoPSBT;
    expect(nativeObject.getData(), equals(psbtHex));
  });

  test("multi-part PSBT encode-decode round-trip", () async {
    // Create a payload large enough to require multi-part UR encoding.
    // The encoder uses a 400-byte fragment size, so >400 bytes forces multiple parts.
    final largeData = List.generate(1200, (i) => i % 256);
    final inputHex = hex.encode(largeData);

    // Encode
    CryptoPSBT cryptoPSBT = CryptoPSBT.factory(largeData);
    UREncoder urEncoder = cryptoPSBT.toUREncoder();

    // Decode all parts
    URDecoder urDecoder = URDecoder();
    int partCount = 0;
    while (!urDecoder.isComplete()) {
      String part = urEncoder.nextPart();
      urDecoder.receive(part);
      partCount++;
    }

    // Verify we actually needed multiple parts
    expect(partCount, greaterThan(1));

    // Verify decoded data matches the original
    NativeObject nativeObject = urDecoder.resolve(SupportedType.cryptoPSBT);
    nativeObject as CryptoPSBT;
    expect(nativeObject.getData(), equals(inputHex));
  });
}
