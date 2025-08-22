use crate::{response::{PtrResponse, Response}, types::{PtrString, PtrVoid}};
use serde_json::json;
use uuid::Uuid;
use crate::utils::{convert_ptr_string_to_string, remove_prefix_0x};
use ur_registry::cardano::cardano_sign_data_request::CardanoSignDataRequest;
use ur_registry::crypto_key_path::CryptoKeyPath;

#[no_mangle]
pub extern "C" fn cardano_sign_data_request_new() -> PtrResponse {
    Response::success_object(Box::into_raw(Box::new(CardanoSignDataRequest::default())) as PtrVoid).c_ptr()
}

// request_id: Option<Bytes>,
// sign_data: Bytes,
// derivation_path: CryptoKeyPath,
// origin: Option<String>,
// xpub: Bytes

#[no_mangle]
pub extern "C" fn cardano_sign_data_request_construct(
    request_id: PtrString,
    mfp: PtrString,
    sign_data: PtrString,
    derivation_path: PtrString,
    origin: PtrString,
    xpub: PtrString,
) -> PtrResponse {
    let request_id = convert_ptr_string_to_string(request_id).unwrap();
    let request_id = match Uuid::parse_str(&request_id) {
        Ok(v) => v,
        Err(_) => return Response::error(json!({"error": "uuid is invalid"}).to_string()).c_ptr(),
    }
    .as_bytes()
    .to_vec();

    let mfp = convert_ptr_string_to_string(mfp).unwrap();
    let mfp = match hex::decode(remove_prefix_0x(&mfp)) {
        Ok(v) => v,
        Err(_) => return Response::error(json!({"error": "mfp is invalid"}).to_string()).c_ptr(),
    };

    if mfp.len() != 4 {
        return Response::error(json!({"error": "mfp is invalid"}).to_string()).c_ptr();
    }

    let sign_data = convert_ptr_string_to_string(sign_data).unwrap();
    let sign_data_bytes = match hex::decode(remove_prefix_0x(&sign_data)) {
        Ok(v) => v,
        Err(_) => {
            return Response::error(json!({"error": "sign data is invalid"}).to_string()).c_ptr()
        }
    };

    let derivation_path = convert_ptr_string_to_string(derivation_path).unwrap();
    let derivation_path = match CryptoKeyPath::from_path(
        derivation_path,
        Some(mfp.as_slice().try_into().ok().unwrap()),
    ) {
        Ok(v) => v,
        Err(_) => {
            return Response::error(json!({"error": "derivation path is invalid"}).to_string())
                .c_ptr()
        }
    };

    let origin = convert_ptr_string_to_string(origin).unwrap();
    let origin = if origin.len() == 0 {
        None
    } else {
        Some(origin.to_string())
    };

    let xpub = convert_ptr_string_to_string(xpub).unwrap();
    let xpub_bytes = match hex::decode(remove_prefix_0x(&xpub)) {
        Ok(v) => v,
        Err(_) => return Response::error(json!({"error": "xpub is invalid"}).to_string()).c_ptr(),
    };

    let request = CardanoSignDataRequest::new(
        Some(request_id),
        sign_data_bytes,
        derivation_path,
        origin,
        xpub_bytes,
    );

    Response::success_object(Box::into_raw(Box::new(request)) as PtrVoid).c_ptr()
}
