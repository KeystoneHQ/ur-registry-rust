use crate::response::{PtrResponse, Response};
use ur::Encoder;

#[no_mangle]
pub extern "C" fn ur_encoder_next_part(ur_encoder: &mut Encoder) -> PtrResponse {
    if ur_encoder.fragment_count() == 1 {
        return Response::success_string(ur_encoder.get_single_part().unwrap()).c_ptr();
    }

    match ur_encoder.next_part() {
        Ok(v) => Response::success_string(v),
        Err(e) => Response::error(e.to_string()),
    }
    .c_ptr()
}

#[no_mangle]
pub extern "C" fn ur_encoder_is_single(ur_encoder: &mut Encoder) -> PtrResponse {
    Response::success_boolean(ur_encoder.fragment_count() == 1).c_ptr()
}