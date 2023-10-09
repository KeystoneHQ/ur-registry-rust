import Flutter
import UIKit

public class SwiftUrRegistryFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "ur_registry_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftUrRegistryFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }

  public func dummyBundle() {
    //write this function to enforce compiling these functions.
    //these functions are not actually called here.
    let anyPointer = UnsafeMutableRawPointer.allocate(byteCount: 4, alignment: 1);

    crypto_hd_key_get_key_data(anyPointer);
    crypto_hd_key_get_name(anyPointer);
    crypto_hd_key_get_path(anyPointer);
    crypto_hd_key_get_source_fingerprint(anyPointer);
    crypto_hd_key_get_account_index(anyPointer, 1);
    crypto_hd_key_get_depth(anyPointer);

    crypto_account_get_accounts_len(anyPointer);
    crypto_account_get_account(anyPointer, 1);
    crypto_account_get_master_fingerprint(anyPointer);

    crypto_output_get_hd_key(anyPointer);

    crypto_psbt_get_data(anyPointer);
    crypto_psbt_construct(anyPointer);
    crypto_psbt_get_ur_encoder(anyPointer);

    solana_sign_request_new();
    solana_sign_request_construct(anyPointer, anyPointer, anyPointer, 1, anyPointer, anyPointer, 1);
    solana_sign_request_get_ur_encoder(anyPointer);

    solana_signature_get_signature(anyPointer);
    solana_signature_get_request_id(anyPointer);

    eth_sign_request_new();
    eth_sign_request_construct(anyPointer, anyPointer, 0, 0, anyPointer, 0, anyPointer, anyPointer);
    eth_sign_request_get_ur_encoder(anyPointer);
    eth_sign_request_get_request_id(anyPointer);

    eth_signature_get_signature(anyPointer);
    eth_signature_get_request_id(anyPointer);

    extend_crypto_multi_accounts_get_master_fingerprint(anyPointer);
    extend_crypto_multi_accounts_get_device(anyPointer);
    extend_crypto_multi_accounts_get_keys_len(anyPointer);
    extend_crypto_multi_accounts_get_key(anyPointer, 0);

    ur_decoder_new();
    ur_decoder_receive(anyPointer, anyPointer);
    ur_decoder_is_complete(anyPointer);
    ur_decoder_result(anyPointer)
    ur_decoder_resolve(anyPointer, anyPointer)

    utils_free(anyPointer)

    ur_encoder_next_part(anyPointer)
  }
}
