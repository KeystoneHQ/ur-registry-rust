use ur::Encoder;
use crate::response::{PtrResponse, Response};

#[no_mangle]
pub extern "C" fn ur_encoder_next_part(ur_encoder: &mut Encoder) -> PtrResponse {
    match ur_encoder.next_part() {
        Ok(v) => Response::success_string(v),
        Err(e) => Response::error(e.to_string()),
    }.c_ptr()
}