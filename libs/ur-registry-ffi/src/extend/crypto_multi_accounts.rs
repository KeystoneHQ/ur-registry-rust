use crate::response::{PtrResponse, Response};
use crate::types::PtrVoid;
use ur_registry::extend::crypto_multi_accounts::CryptoMultiAccounts;
use ur_registry::traits::From;

pub fn resolve(data: Vec<u8>) -> PtrResponse {
    match CryptoMultiAccounts::from_bytes(data) {
        Ok(result) => Response::success_object(Box::into_raw(Box::new(result)) as PtrVoid).c_ptr(),
        Err(error) => Response::error(error.to_string()).c_ptr(),
    }
}

#[no_mangle]
pub extern "C" fn extend_crypto_multi_accounts_get_master_fingerprint(
    crypto_multi_accounts: &mut CryptoMultiAccounts,
) -> PtrResponse {
    Response::success_string(hex::encode(crypto_multi_accounts.get_master_fingerprint())).c_ptr()
}

#[no_mangle]
pub extern "C" fn extend_crypto_multi_accounts_get_device(
    crypto_multi_accounts: &mut CryptoMultiAccounts,
) -> PtrResponse {
    Response::success_string(crypto_multi_accounts.get_device().unwrap_or("".to_string())).c_ptr()
}

#[no_mangle]
pub extern "C" fn extend_crypto_multi_accounts_get_keys_len(
    crypto_multi_accounts: &mut CryptoMultiAccounts,
) -> PtrResponse {
    Response::success_uint32(crypto_multi_accounts.get_keys().len() as u32).c_ptr()
}

#[no_mangle]
pub extern "C" fn extend_crypto_multi_accounts_get_key(
    crypto_multi_accounts: &mut CryptoMultiAccounts,
    index: u32,
) -> PtrResponse {
    match crypto_multi_accounts.get_keys().get(index as usize) {
        Some(key) => {
            Response::success_object(Box::into_raw(Box::new(key.clone())) as PtrVoid).c_ptr()
        }
        None => Response::error(format!("No key for index {} was found", index)).c_ptr(),
    }
}
