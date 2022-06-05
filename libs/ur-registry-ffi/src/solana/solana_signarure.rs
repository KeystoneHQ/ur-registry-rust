use ur_registry::solana::sol_signature::SolSignature;
use ur_registry::traits::From;
use crate::response::{PtrResponse, Response};
use crate::types::PtrVoid;

pub fn resolve(data: Vec<u8>) -> PtrResponse {
    match SolSignature::from_bytes(data) {
        Ok(result) => Response::success_object(Box::into_raw(Box::new(result)) as PtrVoid).c_ptr(),
        Err(error) => Response::error(error.to_string()).c_ptr(),
    }
}

#[no_mangle]
pub extern "C" fn solana_signature_get_signature(solana_signarure: &mut SolSignature) -> PtrResponse {
    Response::success_string(hex::encode(solana_signarure.get_signature())).c_ptr()
}

#[no_mangle]
pub extern "C" fn solana_signature_get_request_id(solana_signature: &mut SolSignature) -> PtrResponse {
    match solana_signature.get_request_id() {
        Some(v) => Response::success_string(hex::encode(v)).c_ptr(),
        None => Response::error(format!("No request id supplied")).c_ptr()
    }
}