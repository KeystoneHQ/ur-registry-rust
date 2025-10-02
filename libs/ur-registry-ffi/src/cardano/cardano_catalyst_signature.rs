use crate::{response::{PtrResponse, Response}, types::{PtrString, PtrVoid}};
use serde_json::json;
use uuid::Uuid;
use crate::utils::{convert_ptr_string_to_string, remove_prefix_0x};
use ur_registry::cardano::cardano_catalyst_signature::CardanoCatalystSignature;

pub fn resolve(data: Vec<u8>) -> PtrResponse {
    match CardanoCatalystSignature::try_from(data) {
        Ok(result) => Response::success_object(Box::into_raw(Box::new(result)) as PtrVoid).c_ptr(),
        Err(error) => Response::error(error.to_string()).c_ptr(),
    }
  }

#[no_mangle]
pub extern "C" fn cardano_catalyst_signature_new() -> PtrResponse {
    Response::success_object(Box::into_raw(Box::new(CardanoCatalystSignature::default())) as PtrVoid).c_ptr()
}   

#[no_mangle]
pub extern "C" fn cardano_catalyst_signature_construct(
    request_id: PtrString,
    signature: PtrString,
) -> PtrResponse {
    let request_id = convert_ptr_string_to_string(request_id).unwrap();
    let request_id = match Uuid::parse_str(&request_id) {
        Ok(v) => v,
        Err(_) => return Response::error(json!({"error": "uuid is invalid"}).to_string()).c_ptr(),
    };

    let signature = convert_ptr_string_to_string(signature).unwrap();
    let signature_bytes = match hex::decode(remove_prefix_0x(&signature)) {
        Ok(v) => v,
        Err(_) => return Response::error(json!({"error": "signature is invalid"}).to_string()).c_ptr(),
    };

    let signature = CardanoCatalystSignature::new(
        Some(request_id.as_bytes().to_vec()),
        signature_bytes,
    );

    Response::success_object(Box::into_raw(Box::new(signature)) as PtrVoid).c_ptr()
}

#[no_mangle]
pub extern "C" fn cardano_catalyst_signature_get_request_id(catalyst_signature: &mut CardanoCatalystSignature) -> PtrResponse {
  match catalyst_signature.get_request_id() {
    Some(v) => Response::success_string(hex::encode(v)).c_ptr(),
    None => Response::error(format!("No request id supplied")).c_ptr()
  }
}

#[no_mangle]
pub extern "C" fn cardano_catalyst_signature_get_signature(catalyst_signature: &mut CardanoCatalystSignature) -> PtrResponse {
    Response::success_string(hex::encode(catalyst_signature.get_signature())).c_ptr()
}
