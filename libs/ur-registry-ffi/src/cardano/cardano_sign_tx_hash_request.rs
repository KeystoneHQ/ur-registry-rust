use serde::Deserialize;
use serde_json::json;
use ur_registry::cardano::cardano_sign_tx_hash_request::CardanoSignTxHashRequest;
use ur_registry::crypto_key_path::CryptoKeyPath;
use ur_registry::traits::RegistryItem;
use ur_registry::traits::To;
use uuid::Uuid;

use crate::{
    response::{PtrResponse, Response},
    types::{PtrString, PtrVoid},
    utils::convert_ptr_string_to_string,
};

// request_id: Option<Bytes>,
// tx_hash: String,
// paths: Vec<CryptoKeyPath>,
// origin: Option<String>,
// address_list: Vec<String>

#[derive(Deserialize)]
struct Path {
    xfp: String,
    key_path: String,
}

#[no_mangle]
pub extern "C" fn cardano_sign_tx_hash_request_construct(
    request_id: PtrString,
    tx_hash: PtrString,
    paths: PtrString,
    origin: PtrString,
    address_list: PtrString,
) -> PtrResponse {
    let request_id = convert_ptr_string_to_string(request_id).unwrap();
    let request_id = match Uuid::parse_str(&request_id) {
        Ok(v) => v,
        Err(_) => return Response::error(json!({"error": "uuid is invalid"}).to_string()).c_ptr(),
    }
    .as_bytes()
    .to_vec();
    let tx_hash = convert_ptr_string_to_string(tx_hash).unwrap();
    let paths = convert_ptr_string_to_string(paths).unwrap();

    let mut err_msg = "";

    let paths = match serde_json::from_str::<Vec<Path>>(&paths) {
        Ok(v) => v,
        Err(_) => return Response::error(json!({"error": "paths is invalid"}).to_string()).c_ptr(),
    }
    .iter()
    .map(|path| {
        let xfp = hex::decode(path.xfp.clone()).unwrap();
        let path = CryptoKeyPath::from_path(
            path.key_path.clone(),
            Some(xfp.as_slice().try_into().unwrap()),
        );
        match path {
            Ok(v) => Some(v),
            Err(_) => {
                err_msg = "path is invalid";
                None
            }
        }
    }).filter_map(|v| v)
    .collect();

    if err_msg.len() > 0 {
        return Response::error(json!({"error": err_msg}).to_string()).c_ptr()
    }

    let origin = convert_ptr_string_to_string(origin).unwrap();
    let origin = match origin.is_empty() {
        true => None,
        false => Some(origin),
    };
    let address_list = convert_ptr_string_to_string(address_list).unwrap();
    let address_list = match serde_json::from_str::<Vec<String>>(&address_list) {
        Ok(v) => v,
        Err(_) => {
            return Response::error(json!({"error": "address list is invalid"}).to_string()).c_ptr()
        }
    };
    let cardano_sign_tx_hash_request =
        CardanoSignTxHashRequest::new(Some(request_id), tx_hash, paths, origin, address_list);
    Response::success_object(Box::into_raw(Box::new(cardano_sign_tx_hash_request)) as PtrVoid)
        .c_ptr()
}

#[no_mangle]
pub extern "C" fn cardano_sign_tx_hash_request_get_ur_encoder(cardano_sign_tx_hash_request: &mut CardanoSignTxHashRequest) -> PtrResponse {
    let message = cardano_sign_tx_hash_request.to_bytes().unwrap();
    let ur_encoder = ur::Encoder::new(
        message.as_slice(),
        200,
        CardanoSignTxHashRequest::get_registry_type().get_type(),
    )
    .unwrap();
    Response::success_object(Box::into_raw(Box::new(ur_encoder)) as PtrVoid).c_ptr()
}

#[no_mangle]
pub extern "C" fn cardano_sign_tx_hash_request_get_request_id(cardano_sign_tx_hash_request: &mut CardanoSignTxHashRequest) -> PtrResponse {
    cardano_sign_tx_hash_request.get_request_id().map_or(Response::success_null().c_ptr(), |id| {
        Response::success_string(hex::encode(id)).c_ptr()
    })
}