use ur_registry::ethereum::eth_signature::EthSignature;
use ur_registry::traits::From;
use crate::response::{PtrResponse, Response};
use crate::types::PtrVoid;

pub fn resolve(data: Vec<u8>) -> PtrResponse {
    match EthSignature::from_bytes(data) {
        Ok(result) => Response::success_object(Box::into_raw(Box::new(result)) as PtrVoid).c_ptr(),
        Err(error) => Response::error(error.to_string()).c_ptr(),
    }
}

#[no_mangle]
pub extern "C" fn eth_signature_get_signature(eth_signature: &mut EthSignature) -> PtrResponse {
    Response::success_string(hex::encode(eth_signature.get_signature())).c_ptr()
}

#[no_mangle]
pub extern "C" fn eth_signature_get_request_id(eth_signature: &mut EthSignature) -> PtrResponse {
    match eth_signature.get_request_id() {
        Some(v) => Response::success_string(hex::encode(v)).c_ptr(),
        None => Response::error(format!("No request id supplied")).c_ptr()
    }
}