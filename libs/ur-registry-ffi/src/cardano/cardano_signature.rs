use hex;
use ur_registry::cardano::cardano_signature::CardanoSignature;
use crate::response::{PtrResponse, Response};
use crate::types::PtrVoid;

pub fn resolve(data: Vec<u8>) -> PtrResponse {
  match CardanoSignature::try_from(data) {
      Ok(result) => Response::success_object(Box::into_raw(Box::new(result)) as PtrVoid).c_ptr(),
      Err(error) => Response::error(error.to_string()).c_ptr(),
  }
}

#[no_mangle]
pub extern "C" fn cardano_signature_get_witness_set(eth_signature: &mut CardanoSignature) -> PtrResponse {
  Response::success_string(hex::encode(eth_signature.get_witness_set())).c_ptr()
}

#[no_mangle]
pub extern "C" fn cardano_signature_get_request_id(eth_signature: &mut CardanoSignature) -> PtrResponse {
  match eth_signature.get_request_id() {
    Some(v) => Response::success_string(hex::encode(v)).c_ptr(),
    None => Response::error(format!("No request id supplied")).c_ptr()
  }
}
