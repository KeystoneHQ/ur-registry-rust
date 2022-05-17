use crate::response::{PtrResponse, Response, Value, ERROR, SUCCESS};
use crate::types::{ErrorCallback, PtrString, PtrVoid};
use crate::utils::{str_to_ptr_c_char, u32_to_ptr_u32};
use hex::encode;
use std::ffi::{c_void, CStr, CString};
use std::fmt::format;
use std::os::raw::{c_char, c_uint};
use std::ptr::{null, null_mut};
use std::str::Utf8Error;
use ur::Decoder;
use ur_registry::traits::From;

#[no_mangle]
pub extern "C" fn ur_decoder_new() -> PtrResponse {
    Response::success(Value::object(
        Box::into_raw(Box::new(ur::Decoder::default())) as *mut c_void,
    ))
    .c_ptr()
}

#[no_mangle]
pub extern "C" fn ur_decoder_receive(decoder: &mut Decoder, ur: PtrString) -> PtrResponse {
    let ur_str = match unsafe { CStr::from_ptr(ur) }.to_str() {
        Ok(value) => value.to_lowercase(),
        Err(error) => return Response::error(error.to_string()).c_ptr(),
    };
    match decoder.receive(ur_str.as_str()) {
        Err(error) => Response::error(error.to_string()).c_ptr(),
        _ => Response::success(Value::null()).c_ptr(),
    }
}

#[no_mangle]
pub extern "C" fn ur_decoder_is_complete(decoder: &mut Decoder) -> PtrResponse {
    Response::success(Value::boolean(decoder.complete())).c_ptr()
}

fn get_result(decoder: &mut Decoder) -> Result<Vec<u8>, String> {
    match decoder.message() {
        Ok(m) => match m {
            Some(message) => Ok(message),
            None => Err(format!("No data received before get result")),
        },
        Err(error) => Err(error.to_string()),
    }
}

#[no_mangle]
pub extern "C" fn ur_decoder_result(decoder: &mut Decoder) -> PtrResponse {
    match get_result(decoder) {
        Ok(message) => Response::success(Value::string(encode(message))).c_ptr(),
        Err(error) => Response::error(error).c_ptr(),
    }
}

#[no_mangle]
pub extern "C" fn ur_decoder_resolve(decoder: &mut Decoder, target_type: PtrString) -> PtrResponse {
    let result = match get_result(decoder) {
        Ok(res) => res,
        Err(error) => return Response::error(error.to_string()).c_ptr(),
    };
    let target = unsafe { CStr::from_ptr(target_type) }.to_str().unwrap();
    match target {
        "crypto-multi-accounts" => crate::solana::crypto_multi_accounts::resolve(result),
        t => Response::error(format!("type {} is not supported yet", t)).c_ptr(),
    }
}
