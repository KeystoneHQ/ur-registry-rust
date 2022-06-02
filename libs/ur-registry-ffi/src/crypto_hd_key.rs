use crate::response::{PtrResponse, Response, Value};
use ur_registry::crypto_hd_key::CryptoHDKey;

#[no_mangle]
pub extern "C" fn crypto_hd_key_get_key_data(crypto_hdkey: &mut CryptoHDKey) -> PtrResponse {
    Response::success_string(hex::encode(crypto_hdkey.get_key())).c_ptr()
}

#[no_mangle]
pub extern "C" fn crypto_hd_key_get_name(crypto_hdkey: &mut CryptoHDKey) -> PtrResponse {
    crypto_hdkey
        .get_name()
        .map_or(Response::success_null(), |v| Response::success_string(v))
        .c_ptr()
}

#[no_mangle]
pub extern "C" fn crypto_hd_key_get_path(crypto_hdkey: &mut CryptoHDKey) -> PtrResponse {
    match crypto_hdkey.get_origin() {
        Some(v) => match v.get_path() {
            Some(s) => Response::success_string(s),
            None => Response::success_null(),
        },
        None => Response::success_null(),
    }
    .c_ptr()
}

#[no_mangle]
pub extern "C" fn crypto_hd_key_get_source_fingerprint(
    crypto_hdkey: &mut CryptoHDKey,
) -> PtrResponse {
    match crypto_hdkey.get_origin() {
        Some(o) => match o.get_source_fingerprint() {
            Some(f) => Response::success_string(hex::encode(f)),
            None => Response::success_null(),
        },
        None => Response::success_null(),
    }
    .c_ptr()
}

#[no_mangle]
pub extern "C" fn crypto_hd_key_get_account_index(
    crypto_hdkey: &mut CryptoHDKey,
    level: u32,
) -> PtrResponse {
    crypto_hdkey
        .get_account_index(level)
        .map_or(Response::success_null(), |v| Response::success_uint32(v))
        .c_ptr()
}

#[no_mangle]
pub extern "C" fn crypto_hd_key_get_depth(crypto_hdkey: &mut CryptoHDKey) -> PtrResponse {
    crypto_hdkey
        .get_depth()
        .map_or(Response::success_null(), |v| Response::success_uint32(v))
        .c_ptr()
}
