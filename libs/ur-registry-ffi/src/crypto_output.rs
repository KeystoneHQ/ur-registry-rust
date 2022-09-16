use ur_registry::crypto_output::CryptoOutput;
use crate::response::{PtrResponse, Response};
use crate::types::PtrVoid;

#[no_mangle]
pub extern "C" fn crypto_output_get_hd_key(crypto_output: &mut CryptoOutput) -> PtrResponse {
    Response::success_object(Box::into_raw(Box::new(crypto_output.get_crypto_key())) as PtrVoid).c_ptr()
}