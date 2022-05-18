use ur_registry::crypto_hd_key::CryptoHDKey;
use crate::response::{PtrResponse, Response, Value};

#[no_mangle]
pub extern "C" fn crypto_hd_key_get_key_data(crypto_hdkey: &mut CryptoHDKey) -> PtrResponse {
    Response::success(Value::string(hex::encode(crypto_hdkey.get_key()))).c_ptr()
}