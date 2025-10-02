use crate::{response::{PtrResponse, Response}, types::{PtrString, PtrVoid}};
use serde_json::json;
use uuid::Uuid;
use crate::utils::{convert_ptr_string_to_string, remove_prefix_0x};
use ur_registry::cardano::cardano_sign_cip8_data_signature::CardanoSignCip8DataSignature;

pub fn resolve(data: Vec<u8>) -> PtrResponse {
    match CardanoSignCip8DataSignature::try_from(data) {
        Ok(result) => Response::success_object(Box::into_raw(Box::new(result)) as PtrVoid).c_ptr(),
        Err(error) => Response::error(error.to_string()).c_ptr(),
    }
}

#[no_mangle]
    pub extern "C" fn cardano_sign_cip8_data_signature_new() -> PtrResponse {
    Response::success_object(Box::into_raw(Box::new(CardanoSignCip8DataSignature::default())) as PtrVoid).c_ptr()
}
//request_id: Option<Bytes>,
// signature: Bytes,
// public_key: Bytes,
// address_field:Bytes
#[no_mangle]
pub extern "C" fn cardano_sign_cip8_data_signature_construct(
    request_id: PtrString,
    signature: PtrString,
    public_key: PtrString,
    address_field: PtrString,
) -> PtrResponse {
    let request_id = convert_ptr_string_to_string(request_id).unwrap();
    let request_id = match Uuid::parse_str(&request_id) {
        Ok(v) => v,
        Err(_) => return Response::error(json!({"error": "uuid is invalid"}).to_string()).c_ptr(),
    }.as_bytes().to_vec();
    
    let signature = convert_ptr_string_to_string(signature).unwrap();
    let signature_bytes = match hex::decode(remove_prefix_0x(&signature)) {
        Ok(v) => v,
        Err(_) => return Response::error(json!({"error": "signature is invalid"}).to_string()).c_ptr(),
    };

    let public_key = convert_ptr_string_to_string(public_key).unwrap();
    let public_key_bytes = match hex::decode(remove_prefix_0x(&public_key)) {
        Ok(v) => v,
        Err(_) => return Response::error(json!({"error": "public key is invalid"}).to_string()).c_ptr(),
    };

    let address_field = convert_ptr_string_to_string(address_field).unwrap();
    let address_field_bytes = match hex::decode(remove_prefix_0x(&address_field)) {
        Ok(v) => v,
        Err(_) => return Response::error(json!({"error": "address field is invalid"}).to_string()).c_ptr(),
    };
    
    let request = CardanoSignCip8DataSignature::new(
        Some(request_id),
        signature_bytes,
        public_key_bytes,
        address_field_bytes,
    );

    Response::success_object(Box::into_raw(Box::new(request)) as PtrVoid).c_ptr()
}

#[no_mangle]
pub extern "C" fn cardano_sign_cip8_data_signature_get_request_id(signature: &mut CardanoSignCip8DataSignature) -> PtrResponse {
    match signature.get_request_id() {
        Some(v) => Response::success_string(hex::encode(v)).c_ptr(),
        None => Response::error(format!("No request id supplied")).c_ptr()
    }
}

#[no_mangle]
pub extern "C" fn cardano_sign_cip8_data_signature_get_signature(signature: &mut CardanoSignCip8DataSignature) -> PtrResponse {
    Response::success_string(hex::encode(signature.get_signature())).c_ptr()
}

#[no_mangle]
pub extern "C" fn cardano_sign_cip8_data_signature_get_public_key(signature: &mut CardanoSignCip8DataSignature) -> PtrResponse {
    Response::success_string(hex::encode(signature.get_public_key())).c_ptr()
}

#[no_mangle]
pub extern "C" fn cardano_sign_cip8_data_signature_get_address_field(signature: &mut CardanoSignCip8DataSignature) -> PtrResponse {
    Response::success_string(hex::encode(signature.get_address_field())).c_ptr()
}
