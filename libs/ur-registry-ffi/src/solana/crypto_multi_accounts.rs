use crate::response::{PtrResponse, Response, Value};
use crate::types::PtrVoid;
use ur_registry::traits::From;

pub fn resolve(data: Vec<u8>) -> PtrResponse {
    match ur_registry::solana::crypto_multi_accounts::CryptoMultiAccounts::from_bytes(data) {
        Ok(result) => {
            Response::success(Value::object(Box::into_raw(Box::new(result)) as PtrVoid)).c_ptr()
        }
        Err(error) => Response::error(error.to_string()).c_ptr(),
    }
}
