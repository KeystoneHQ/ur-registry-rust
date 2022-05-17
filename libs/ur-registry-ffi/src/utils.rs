use crate::types::{PtrString, PtrU32};
use std::ffi::{c_void, CString};

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

pub fn u32_to_ptr_u32(value: u32) -> PtrU32 {
    Box::into_raw(Box::new(value))
}
