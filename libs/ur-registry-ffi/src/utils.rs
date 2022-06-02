use crate::types::PtrString;
use hex::FromHex;
use std::ffi::{c_void, CStr, CString};

#[no_mangle]
pub extern "C" fn utils_free(any_ptr: *mut c_void) {
    if any_ptr.is_null() {
        return;
    }
    unsafe {
        Box::from_raw(any_ptr);
    }
}

pub fn str_to_ptr_c_char(str: String) -> PtrString {
    CString::new(str).unwrap().into_raw()
}

pub fn parse_ptr_string_to_bytes(str: PtrString) -> Result<Vec<u8>, String> {
    unsafe {
        CStr::from_ptr(str)
            .to_str()
            .map_err(|e| e.to_string())
            .and_then(|v| Vec::from_hex(v.to_string()).map_err(|e| e.to_string()))
    }
}

pub fn convert_ptr_string_to_string(str: PtrString) -> Result<String, String> {
    unsafe {
        CStr::from_ptr(str)
            .to_str()
            .map_err(|e| e.to_string())
            .map(|v| v.to_string())
    }
}
