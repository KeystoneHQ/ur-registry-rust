use std::ffi::{c_void, CString};
use std::os::raw::c_uint;
use std::ptr::null_mut;
use crate::types::{PtrString, PtrU32, PtrVoid};

#[repr(C)]
pub struct Response<T> {
    pub status_code: u32,
    pub error_message: PtrString,
    pub data: T,
}

pub type PtrResponse<T> = *mut Response<T>;

impl Response<T> {
    pub fn c_ptr(self) -> PtrResponse<T> {
        Box::into_raw(Box::new(self))
    }

    pub fn success(data: T) -> Self<T> {
        Response {
            status_code: SUCCESS,
            error_message: null_mut(),
            data,
        }
    }

    pub fn error(error_message: String) -> Self {
        Response {
            status_code: ERROR,
            error_message: CString::new(error_message).unwrap().into_raw(),
            data: null_mut()
        }
    }
}

pub const SUCCESS: u32 = 0;
pub const ERROR: u32 = 1;

pub fn response_to_ptr_c_void<T>(response: &mut Response<T>) -> PtrVoid {
    response as *mut _ as *mut c_void
}
