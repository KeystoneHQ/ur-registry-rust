use ur_registry::crypto_account::CryptoAccount;
use ur_registry::traits::From;
use crate::response::{PtrResponse, Response};
use crate::types::PtrVoid;

pub fn resolve(data: Vec<u8>) -> PtrResponse {
    match ur_registry::crypto_account::CryptoAccount::from_bytes(data) {
        Ok(result) => Response::success_object(Box::into_raw(Box::new(result)) as PtrVoid).c_ptr(),
        Err(error) => Response::error(error.to_string()).c_ptr(),
    }
}

#[no_mangle]
pub extern "C" fn crypto_account_get_accounts_len(crypto_account: &mut CryptoAccount) -> PtrResponse {
    Response::success_uint32(crypto_account.get_output_descriptors().len() as u32).c_ptr()
}

pub extern "C" fn crypto_account_get_account(crypto_account: &mut CryptoAccount, index: u32) -> PtrResponse {
    match crypto_account.get_output_descriptors().get(index as usize) {
        Some(crypto_output) => {
            Response::success_object(Box::into_raw(Box::new(crypto_output.clone())) as PtrVoid)
        }
        None => Response::error(format!("No account for index {} was found", index))
    }.c_ptr()
}

#[no_mangle]
pub extern "C" fn crypto_account_get_master_fingerprint(
    crypto_account: &mut CryptoAccount,
) -> PtrResponse {
    Response::success_string(hex::encode(crypto_account.get_master_fingerprint())).c_ptr()
}