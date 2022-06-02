use crate::response::{PtrResponse, Response};
use crate::types::{PtrString, PtrVoid};
use crate::utils::{convert_ptr_string_to_string, parse_ptr_string_to_bytes};
use hex::FromHex;
use std::ffi::CStr;
use ur_registry::crypto_key_path::CryptoKeyPath;
use ur_registry::solana::sol_sign_request::{SignType, SolSignRequest};
use ur_registry::traits::From;

pub fn resolve(data: Vec<u8>) -> PtrResponse {
    match SolSignRequest::from_bytes(data) {
        Ok(result) => Response::success_object(Box::into_raw(Box::new(result)) as PtrVoid).c_ptr(),
        Err(error) => Response::error(error.to_string()).c_ptr(),
    }
}

#[no_mangle]
pub extern "C" fn solana_sign_request_new(
    request_id: PtrString,
    sign_data: PtrString,
    derivation_path: &mut CryptoKeyPath,
    address: PtrString,
    origin: PtrString,
    sign_type: u32,
) -> PtrResponse {
    let request_id = match parse_ptr_string_to_bytes(request_id).map_err(|e| Response::error(e)) {
        Ok(v) => v,
        Err(e) => return e.c_ptr(),
    };
    let sign_data = match parse_ptr_string_to_bytes(sign_data).map_err(|e| Response::error(e)) {
        Ok(v) => v,
        Err(e) => return e.c_ptr(),
    };
    let address = match parse_ptr_string_to_bytes(address).map_err(|e| Response::error(e)) {
        Ok(v) => v,
        Err(e) => return e.c_ptr(),
    };
    let origin = match convert_ptr_string_to_string(origin).map_err(|e| Response::error(e)) {
        Ok(v) => v,
        Err(e) => return e.c_ptr(),
    };
    let sign_type = match SignType::from_u32(sign_type).map_err(|e| Response::error(e)) {
        Ok(v) => v,
        Err(e) => return e.c_ptr(),
    };
    let derivation_path = (*derivation_path).clone();
    let request = SolSignRequest::new(
        Some(request_id),
        sign_data,
        derivation_path,
        Some(address),
        Some(origin),
        sign_type,
    );
    Response::success_object(Box::into_raw(Box::new(request)) as PtrVoid).c_ptr()
}