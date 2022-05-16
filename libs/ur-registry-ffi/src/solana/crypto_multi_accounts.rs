use ur_registry::traits::From;
use crate::response::{PtrResponse, Response};
use crate::types::PtrVoid;

pub fn resolve(data: Vec<u8>) -> PtrResponse<PtrVoid> {
    match ur_registry::solana::crypto_multi_accounts::CryptoMultiAccounts::from_bytes(data) {
        Ok(result) => {
            Response::success(Box::into_raw(Box::new(result))).c_ptr()
        },
        Err(error) => {
            Response::error(error.to_string()).c_ptr()
        }
    }
}