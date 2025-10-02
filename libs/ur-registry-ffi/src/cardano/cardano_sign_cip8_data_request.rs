use crate::response::{PtrResponse, Response};
use crate::types::{PtrString, PtrVoid};
use crate::utils::convert_ptr_string_to_string;
use crate::utils::remove_prefix_0x;
use serde_json::json;
use ur_registry::cardano::cardano_sign_cip8_data_request::{
    CardanoSignCip8DataRequest, Cip8AddressType,
};
use ur_registry::crypto_key_path::CryptoKeyPath;
use ur_registry::traits::{RegistryItem, To};
use uuid::Uuid;

#[no_mangle]
pub extern "C" fn cardano_sign_cip8_data_request_new() -> PtrResponse {
    Response::success_object(
        Box::into_raw(Box::new(CardanoSignCip8DataRequest::default())) as PtrVoid,
    )
    .c_ptr()
}

// request_id: Option<Bytes>,
// sign_data: Bytes,
// derivation_path: CryptoKeyPath,
// origin: Option<String>,
// xpub: Bytes,
// hash_payload: bool,
// address_bench32: Option<String>,
// address_type: Cip8AddressType

#[no_mangle]
pub extern "C" fn cardano_sign_cip8_data_request_construct(
    request_id: PtrString,
    mfp: PtrString,
    sign_data: PtrString,
    derivation_path: PtrString,
    xpub: PtrString,
    origin: PtrString,
    hash_payload: bool,
    address_bench32: PtrString,
    address_type: u32,
) -> PtrResponse {
    let mfp = convert_ptr_string_to_string(mfp).unwrap();
    let mfp = match hex::decode(remove_prefix_0x(&mfp)) {
        Ok(v) => v,
        Err(_) => return Response::error(json!({"error": "mfp is invalid"}).to_string()).c_ptr(),
    };

    if mfp.len() != 4 {
        return Response::error(json!({"error": "mfp is invalid"}).to_string()).c_ptr();
    }

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

    let request_id = convert_ptr_string_to_string(request_id).unwrap();
    let request_id = match Uuid::parse_str(&request_id) {
        Ok(v) => v,
        Err(_) => return Response::error(json!({"error": "uuid is invalid"}).to_string()).c_ptr(),
    }
    .as_bytes()
    .to_vec();

    let sign_data = convert_ptr_string_to_string(sign_data).unwrap();
    let sign_data_bytes = match hex::decode(remove_prefix_0x(&sign_data)) {
        Ok(v) => v,
        Err(_) => {
            return Response::error(json!({"error": "sign data is invalid"}).to_string()).c_ptr()
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

    let address_bench32 = convert_ptr_string_to_string(address_bench32).unwrap();
    let address_bench32 = if address_bench32.len() == 0 {
        None
    } else {
        Some(address_bench32.to_string())
    };

    let address_type = match address_type {
        0 => Cip8AddressType::Address,
        1 => Cip8AddressType::KeyHash,
        _ => {
            return Response::error(json!({"error": "address type is invalid"}).to_string()).c_ptr()
        }
    };

    let request = CardanoSignCip8DataRequest::new(
        Some(request_id),
        sign_data_bytes,
        derivation_path,
        origin,
        xpub_bytes,
        hash_payload,
        address_bench32,
        address_type,
    );

    Response::success_object(Box::into_raw(Box::new(request)) as PtrVoid).c_ptr()
}

#[no_mangle]
pub extern "C" fn cardano_sign_cip8_data_request_get_ur_encoder(
    cardano_sign_cip8_data_request: &mut CardanoSignCip8DataRequest,
) -> PtrResponse {
    let message = cardano_sign_cip8_data_request.to_bytes().unwrap();
    let ur_encoder = ur::Encoder::new(
        message.as_slice(),
        200,
        CardanoSignCip8DataRequest::get_registry_type().get_type(),
    )
    .unwrap();
    Response::success_object(Box::into_raw(Box::new(ur_encoder)) as PtrVoid).c_ptr()
}

#[no_mangle]
pub extern "C" fn cardano_sign_cip8_data_request_get_request_id(
    cardano_sign_cip8_data_request: &mut CardanoSignCip8DataRequest,
) -> PtrResponse {
    cardano_sign_cip8_data_request
        .get_request_id()
        .map_or(Response::success_null().c_ptr(), |id| {
            Response::success_string(hex::encode(id)).c_ptr()
        })
}
