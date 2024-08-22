use crate::response::{PtrResponse, Response};
use serde::Deserialize;
use serde_json::json;
use crate::types::{PtrString, PtrVoid};
use crate::utils::convert_ptr_string_to_string;
use ur_registry::crypto_key_path::CryptoKeyPath;
use ur_registry::cardano::cardano_sign_request::CardanoSignRequest;
use ur_registry::cardano::cardano_cert_key::CardanoCertKey;
use ur_registry::cardano::cardano_utxo::CardanoUTXO;
use ur_registry::traits::{RegistryItem, To};
use uuid::Uuid;

#[derive(Deserialize)]
struct Utxo {
    transaction_hash: String,
    index: u32,
    amount: String,
    xfp: String,
    hd_path: String,
    address: String,
}

#[derive(Deserialize)]
struct CertKey {
    key_hash: String,
    xfp: String,
    key_path: String,
}

pub fn remove_prefix<'a>(s: &'a str, prefix: &str) -> &'a str {
    match s.strip_prefix(prefix) {
        Some(s) => s,
        None => s,
    }
}

pub fn remove_prefix_0x(s: &str) -> &str {
    remove_prefix(s, "0x")
}

#[no_mangle]
pub extern "C" fn cardano_sign_request_new() -> PtrResponse {
    Response::success_object(Box::into_raw(Box::new(CardanoSignRequest::default())) as PtrVoid).c_ptr()
}

#[no_mangle]
pub extern "C" fn cardano_sign_request_construct(
    request_id: PtrString,
    sign_data: PtrString,
    utxos: PtrString,
    cert_keys: PtrString,
    origin: PtrString,
) -> PtrResponse {
    let mut args_err_msg = "";
    let utxos = convert_ptr_string_to_string(utxos).unwrap();
    let utxos: Vec<CardanoUTXO> = match serde_json::from_str::<Vec<Utxo>>(&utxos) {
        Ok(v) => v,
        Err(e) => return Response::error(json!({"error": format!("utxos is invalid: {}", e.to_string())}).to_string()).c_ptr(),
    }.iter().map(|utxo| {
        let xfp = match hex::decode(utxo.xfp.clone()) {
            Ok(v) => Some(v),
            Err(_) => {
                args_err_msg = "xfp in utxos is invalid";
                None
            },
        };
        if xfp.is_some() && xfp.as_ref().unwrap().len() != 4 {
            args_err_msg = "xfp in utxos is invalid";
            return None
        }
        let key_path = match CryptoKeyPath::from_path(utxo.hd_path.clone(), xfp.map(|v| v.as_slice().try_into().ok()).flatten()) {
            Ok(v) => Some(v),
            Err(_) => {
                args_err_msg = "hd path in utxos is invalid";
                return None
            }
        };
        let tx_hash = match hex::decode(utxo.transaction_hash.clone()) {
            Ok(v) => Some(v),
            Err(_) => {
                args_err_msg = "transaction hash in utxos is invalid";
                return None
            }
        };

        Some(CardanoUTXO::new(
            tx_hash.unwrap_or_default(),
            utxo.index,
            utxo.amount.clone(),
            key_path.unwrap_or_default(),
            utxo.address.clone(),
        ))
    }).filter_map(|x| x).collect();
    if args_err_msg != "" {
        return Response::error(json!({"error": args_err_msg}).to_string()).c_ptr();
    }

    let cert_keys = convert_ptr_string_to_string(cert_keys).unwrap();
    let cert_keys: Vec<CardanoCertKey> = match serde_json::from_str::<Vec<CertKey>>(&cert_keys) {
        Ok(v) => v,
        Err(_) => return Response::error(json!({"error": "cert keys is invalid"}).to_string()).c_ptr(),
    }.iter().map(|cert_key| {
        let xfp = match hex::decode(cert_key.xfp.clone()) {
            Ok(v) => Some(v),
            Err(_) => {
                args_err_msg = "hd path in cert keys is invalid";
                None
            },
        };
        if xfp.is_some() && xfp.as_ref().unwrap().len() != 4 {
            args_err_msg = "xfp in cert keys is invalid";
            return None
        }
        let key_hash = match hex::decode(cert_key.key_hash.clone()) {
            Ok(v) => Some(v),
            Err(_) => {
                args_err_msg = "key hash in cert key is invalid";
                None
            }
        };
        let key_path = match CryptoKeyPath::from_path(cert_key.key_path.clone(), xfp.map(|v| v.as_slice().try_into().ok()).flatten()) {
            Ok(v) => Some(v),
            Err(_) => {
                args_err_msg = "hd path in cert keys is invalid";
                None
            }
        };

        if key_hash.is_none() || key_path.is_none() {
            return None
        }
        Some(CardanoCertKey::new(
            key_hash.unwrap_or_default(),
            key_path.unwrap_or_default()
        ))
    }).filter_map(|x| x).collect();
    if args_err_msg != "" {
        return Response::error(json!({"error": args_err_msg}).to_string()).c_ptr();
    }

    let request_id = convert_ptr_string_to_string(request_id).unwrap();
    let request_id = match Uuid::parse_str(&request_id) {
        Ok(v) => v,
        Err(_) => return Response::error(json!({"error": "uuid is invalid"}).to_string()).c_ptr(),
    }.as_bytes().to_vec();

    let sign_data = convert_ptr_string_to_string(sign_data).unwrap();
    let sign_data_bytes = match hex::decode(remove_prefix_0x(&sign_data)) {
        Ok(v) => v,
        Err(_) => return Response::error(json!({"error": "sign data is invalid"}).to_string()).c_ptr(),
    };

    let origin = convert_ptr_string_to_string(origin).unwrap();
    let origin = if origin.len() == 0 { None } else { Some(origin.to_string()) };

    let request = CardanoSignRequest::new(
        Some(request_id),
        sign_data_bytes,
        utxos,
        cert_keys,
        origin
    );

    Response::success_object(Box::into_raw(Box::new(request)) as PtrVoid).c_ptr()
}

#[no_mangle]
pub extern "C" fn cardano_sign_request_get_ur_encoder(cardano_sign_request: &mut CardanoSignRequest) -> PtrResponse {
    let message = cardano_sign_request.to_bytes().unwrap();
    let ur_encoder = ur::Encoder::new(
        message.as_slice(),
        400,
        CardanoSignRequest::get_registry_type().get_type(),
    )
    .unwrap();
    Response::success_object(Box::into_raw(Box::new(ur_encoder)) as PtrVoid).c_ptr()
}

#[no_mangle]
pub extern "C" fn cardano_sign_request_get_request_id(cardano_sign_request: &mut CardanoSignRequest) -> PtrResponse {
    cardano_sign_request.get_request_id().map_or(Response::success_null().c_ptr(), |id| {
        Response::success_string(hex::encode(id)).c_ptr()
    })
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::utils::str_to_ptr_c_char;

    #[test]
    fn test_cardano_sign_request_construct() {
    let request_id = "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d";
    let sign_data = "84a400828258204e3a6e7fdcb0d0efa17bf79c13aed2b4cb9baf37fb1aa2e39553d5bd720c5c99038258204e3a6e7fdcb0d0efa17bf79c13aed2b4cb9baf37fb1aa2e39553d5bd720c5c99040182a200581d6179df4c75f7616d7d1fd39cbc1a6ea6b40a0d7b89fea62fc0909b6c370119c350a200581d61c9b0c9761fd1dc0404abd55efc895026628b5035ac623c614fbad0310119c35002198ecb0300a0f5f6";
    let utxos = r#"[
            {
                "transaction_hash": "4e3a6e7fdcb0d0efa17bf79c13aed2b4cb9baf37fb1aa2e39553d5bd720c5c99",
                "index": 3,
                "amount": "10000000",
                "xfp": "73c5da0a",
                "hd_path": "m/1852'/1815'/0'/0/0",
                "address": "addr1qy8ac7qqy0vtulyl7wntmsxc6wex80gvcyjy33qffrhm7sh927ysx5sftuw0dlft05dz3c7revpf7jx0xnlcjz3g69mq4afdhv"
            },
            {
                "transaction_hash": "4e3a6e7fdcb0d0efa17bf79c13aed2b4cb9baf37fb1aa2e39553d5bd720c5c99",
                "index": 4,
                "amount": "18020000",
                "xfp": "73c5da0a",
                "hd_path": "m/1852'/1815'/0'/0/1",
                "address": "addr1qyz85693g4fr8c55mfyxhae8j2u04pydxrgqr73vmwpx3azv4dgkyrgylj5yl2m0jlpdpeswyyzjs0vhwvnl6xg9f7ssrxkz90"
            }
        ]"#;
    let cert_keys = r#"[
            {
                "key_hash": "e557890352095f1cf6fd2b7d1a28e3c3cb029f48cf34ff890a28d176",
                "xfp": "73c5da0a",
                "key_path": "m/1852'/1815'/0'/2/0"
            }
        ]"#;
    let origin = "cardano-wallet";

    let response = cardano_sign_request_construct(
        str_to_ptr_c_char(request_id.to_string()),
        str_to_ptr_c_char(sign_data.to_string()),
        str_to_ptr_c_char(utxos.to_string()),
        str_to_ptr_c_char(cert_keys.to_string()),
        str_to_ptr_c_char(origin.to_string()),
        );
    let response = unsafe { Response::from_ptr(response) };

    let result = response.value.get_object();
    let result = unsafe { Box::from_raw(result as *mut CardanoSignRequest) };

    let cbor: Vec<u8> = (*result).try_into().unwrap();
    let cbor = hex::encode(cbor);

    assert_eq!(cbor, "a501d825509b1deb4d3b7d4bad9bdd2b0d7b3dcb6d0258a184a400828258204e3a6e7fdcb0d0efa17bf79c13aed2b4cb9baf37fb1aa2e39553d5bd720c5c99038258204e3a6e7fdcb0d0efa17bf79c13aed2b4cb9baf37fb1aa2e39553d5bd720c5c99040182a200581d6179df4c75f7616d7d1fd39cbc1a6ea6b40a0d7b89fea62fc0909b6c370119c350a200581d61c9b0c9761fd1dc0404abd55efc895026628b5035ac623c614fbad0310119c35002198ecb0300a0f5f60382d90899a50158204e3a6e7fdcb0d0efa17bf79c13aed2b4cb9baf37fb1aa2e39553d5bd720c5c9902030368313030303030303004d90130a2018a19073cf5190717f500f500f400f4021a73c5da0a0578676164647231717938616337717179307674756c796c37776e746d737863367765783830677663796a79333371666672686d37736839323779737835736674757730646c66743035647a3363377265767066376a7830786e6c636a7a336736396d71346166646876d90899a50158204e3a6e7fdcb0d0efa17bf79c13aed2b4cb9baf37fb1aa2e39553d5bd720c5c9902040368313830323030303004d90130a2018a19073cf5190717f500f500f401f4021a73c5da0a057867616464723171797a383536393367346672386335356d667978686165386a3275303470796478726771723733766d77707833617a763464676b797267796c6a35796c326d306a6c70647065737779797a6a7330766877766e6c367867396637737372786b7a39300481d9089ca201581ce557890352095f1cf6fd2b7d1a28e3c3cb029f48cf34ff890a28d17602d90130a2018a19073cf5190717f500f502f400f4021a73c5da0a056e63617264616e6f2d77616c6c6574".to_string());
    }
}