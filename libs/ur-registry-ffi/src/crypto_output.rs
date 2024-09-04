use ur_registry::crypto_output::CryptoOutput;
use crate::response::{PtrResponse, Response};
use crate::types::PtrVoid;

pub fn resolve(data: Vec<u8>) -> PtrResponse {
    match ur_registry::crypto_output::CryptoOutput::try_from(data) {
        Ok(result) => Response::success_object(Box::into_raw(Box::new(result)) as PtrVoid).c_ptr(),
        Err(error) => Response::error(error.to_string()).c_ptr(),
    }
}

#[no_mangle]
pub extern "C" fn crypto_output_get_hd_key(crypto_output: &mut CryptoOutput) -> PtrResponse {
    Response::success_object(Box::into_raw(Box::new(crypto_output.get_hd_key().unwrap())) as PtrVoid).c_ptr()
}