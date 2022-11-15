use crate::response::{PtrResponse, Response};
use crate::types::PtrString;
use crate::types::PtrVoid;
use secp256k1::{Parity, XOnlyPublicKey};
use std::ffi::CStr;
use ur_registry::crypto_hd_key::CryptoHDKey;
use ur_registry::traits::From;

pub fn resolve(data: Vec<u8>) -> PtrResponse {
    match ur_registry::crypto_hd_key::CryptoHDKey::from_bytes(data) {
        Ok(result) => Response::success_object(Box::into_raw(Box::new(result)) as PtrVoid).c_ptr(),
        Err(error) => Response::error(error.to_string()).c_ptr(),
    }
}

#[no_mangle]
pub extern "C" fn crypto_hd_key_get_key_data(crypto_hdkey: &mut CryptoHDKey) -> PtrResponse {
    Response::success_string(hex::encode(crypto_hdkey.get_key())).c_ptr()
}

#[no_mangle]
pub extern "C" fn crypto_hd_key_get_uncompressed_key_data(
    compressed_key: PtrString,
) -> PtrResponse {
    let key_cstr = unsafe { CStr::from_ptr(compressed_key) };
    let key_string = match key_cstr.to_str() {
        Ok(value) => value.to_string(),
        Err(error) => return Response::error(error.to_string()).c_ptr(),
    };

    let slice = &key_string.clone()[2..];
    let decoded_slice = hex::decode(slice).unwrap();

    let result = match XOnlyPublicKey::from_slice(&decoded_slice) {
        Ok(res) => res,
        Err(error) => return Response::error(error.to_string()).c_ptr(),
    };

    let prefix = &key_string[..2];
    let parity = if prefix.eq("02") {
        Parity::Even
    } else {
        Parity::Odd
    };

    let uncompressed_key = result.public_key(parity).serialize_uncompressed();
    Response::success_string(hex::encode(uncompressed_key)).c_ptr()
}

#[no_mangle]
pub extern "C" fn crypto_hd_key_get_chain_code(crypto_hdkey: &mut CryptoHDKey) -> PtrResponse {
    match crypto_hdkey.get_chain_code() {
        Some(chain_code) => Response::success_string(hex::encode(chain_code)),
        None => Response::success_null(),
    }
    .c_ptr()
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

#[no_mangle]
pub extern "C" fn crypto_hd_key_get_note(crypto_hdkey: &mut CryptoHDKey) -> PtrResponse {
    crypto_hdkey
        .get_note()
        .map_or(Response::success_null(), |v| Response::success_string(v))
        .c_ptr()
}

#[no_mangle]
pub extern "C" fn crypto_hd_key_get_bip32_xpub(crypto_hdkey: &mut CryptoHDKey) -> PtrResponse {
    Response::success_string(crypto_hdkey.get_bip32_key()).c_ptr()
}
