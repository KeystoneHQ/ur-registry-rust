use std::ffi::c_void;
use std::os::raw::c_char;

pub type PtrVoid = *mut c_void;
pub type PtrString = *mut c_char;
