use std::ffi::{c_void, CStr, CString};
use std::os::raw::{c_char, c_uint};
use std::ptr::null;
use std::str::Utf8Error;
use hex::encode;
use ur::{Decoder};
use ur_registry::traits::From;
use crate::types::{ErrorCallback, PtrString, PtrVoid};

fn str_to_ptr_c_char(str: String) -> PtrString {
    CString::new(str).unwrap().into_raw()
}

#[no_mangle]
pub extern "C" fn ur_decoder_new() -> *mut Decoder {
    Box::into_raw(Box::new(ur::Decoder::default()))
}

#[no_mangle]
pub extern "C" fn ur_decoder_free(decoder: *mut Decoder) {
    if decoder.is_null() {
        return;
    }
    unsafe {
        Box::from_raw(decoder);
    }
}

#[no_mangle]
pub extern "C" fn ur_decoder_receive(decoder: &mut Decoder, ur: *mut c_char) {
    let ur_str = match unsafe { CStr::from_ptr(ur) }.to_str() {
        Ok(value) => {
            println!("called from rust, {}", value);
            value
        }
        Err(error) => {
            panic!("meet error, {}", error);
        }
    };
    match decoder.receive(ur_str) {
        Err(error) => {
            panic!("meet error, {}", error);
        },
        _ => {}
    }
}

#[no_mangle]
pub extern "C" fn ur_decoder_is_complete(decoder: &mut Decoder) -> bool {
    decoder.complete()
}

#[no_mangle]
pub extern "C" fn ur_decoder_result(decoder: &mut Decoder) -> *mut c_char {
    CString::new(encode(decoder.message().unwrap().unwrap())).unwrap().into_raw()
}

#[no_mangle]
pub extern "C" fn ur_decoder_resolve(decoder: &mut Decoder, target_type: *mut c_char) -> *mut c_void {
    let result = decoder.message().unwrap().unwrap();
    let target = unsafe { CStr::from_ptr(target_type) }.to_str().unwrap();
    let mut ur_type: *mut c_void = match target {
        "crypto-multi-accounts" => {
            let mut cma = ur_registry::solana::crypto_multi_accounts::CryptoMultiAccounts::from_bytes(result).unwrap();
            let cma_ptr = &mut cma as *mut _ as *mut c_void;
            cma_ptr
        },
        t => {
            panic!("invalid type, {}", t);
        }
    };
    ur_type
}