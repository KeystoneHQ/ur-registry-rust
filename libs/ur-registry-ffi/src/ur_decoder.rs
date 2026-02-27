use crate::response::{PtrResponse, Response};
use crate::types::PtrString;
use hex::encode;
use std::ffi::{c_void, CStr};
use ur::Decoder;

pub struct URDecoderWrapper {
    decoder: Decoder,
    single_part_result: Option<Vec<u8>>,
}

impl URDecoderWrapper {
    fn new() -> Self {
        Self {
            decoder: Decoder::default(),
            single_part_result: None,
        }
    }

    fn receive(&mut self, ur_str: &str) -> Result<(), String> {
        match ur::ur::decode(ur_str) {
            Ok((kind, data)) => match kind {
                ur::ur::Kind::SinglePart => {
                    self.single_part_result = Some(data);
                    Ok(())
                }
                ur::ur::Kind::MultiPart => {
                    self.decoder.receive(ur_str).map_err(|e| e.to_string())
                }
            },
            Err(e) => Err(e.to_string()),
        }
    }

    fn complete(&self) -> bool {
        self.single_part_result.is_some() || self.decoder.complete()
    }

    fn message(&self) -> Result<Option<Vec<u8>>, String> {
        if let Some(ref data) = self.single_part_result {
            return Ok(Some(data.clone()));
        }
        self.decoder.message().map_err(|e| e.to_string())
    }
}

#[no_mangle]
pub extern "C" fn ur_decoder_new() -> PtrResponse {
    Response::success_object(Box::into_raw(Box::new(URDecoderWrapper::new())) as *mut c_void).c_ptr()
}

#[no_mangle]
pub extern "C" fn ur_decoder_receive(decoder: &mut URDecoderWrapper, ur: PtrString) -> PtrResponse {
    let ur_str = match unsafe { CStr::from_ptr(ur) }.to_str() {
        Ok(value) => value.to_lowercase(),
        Err(error) => return Response::error(error.to_string()).c_ptr(),
    };
    match decoder.receive(ur_str.as_str()) {
        Err(error) => Response::error(error.to_string()).c_ptr(),
        _ => Response::success_null().c_ptr(),
    }
}

#[no_mangle]
pub extern "C" fn ur_decoder_is_complete(decoder: &mut URDecoderWrapper) -> PtrResponse {
    Response::success_boolean(decoder.complete()).c_ptr()
}

fn get_result(decoder: &mut URDecoderWrapper) -> Result<Vec<u8>, String> {
    match decoder.message() {
        Ok(m) => match m {
            Some(message) => Ok(message),
            None => Err(format!("No data received before get result")),
        },
        Err(error) => Err(error),
    }
}

#[no_mangle]
pub extern "C" fn ur_decoder_result(decoder: &mut URDecoderWrapper) -> PtrResponse {
    match get_result(decoder) {
        Ok(message) => Response::success_string(encode(message)).c_ptr(),
        Err(error) => Response::error(error).c_ptr(),
    }
}

#[no_mangle]
pub extern "C" fn ur_decoder_resolve(decoder: &mut URDecoderWrapper, target_type: PtrString) -> PtrResponse {
    let result = match get_result(decoder) {
        Ok(res) => res,
        Err(error) => return Response::error(error.to_string()).c_ptr(),
    };
    let target = unsafe { CStr::from_ptr(target_type) }.to_str().unwrap();
    match target {
        "crypto-multi-accounts" => crate::extend::crypto_multi_accounts::resolve(result),
        "crypto-hdkey" => crate::crypto_hd_key::resolve(result),
        "crypto-account" => crate::crypto_account::resolve(result),
        "crypto-output" => crate::crypto_output::resolve(result),
        "crypto-psbt" => crate::crypto_psbt::resolve(result),
        "sol-signature" => crate::solana::solana_signarure::resolve(result),
        "sol-sign-request" => crate::solana::solana_sign_request::resolve(result),
        "eth-signature" => crate::ethereum::eth_signarure::resolve(result),
        "eth-sign-request" => crate::ethereum::eth_sign_request::resolve(result),
        "cardano-signature" => crate::cardano::cardano_signature::resolve(result),
        "cardano-catalyst-signature" => crate::cardano::cardano_catalyst_signature::resolve(result),
        "cardano-sign-cip8-data-signature" => crate::cardano::cardano_sign_cip8_data_signature::resolve(result),
        "cardano-sign-data-signature" => crate::cardano::cardano_sign_data_signature::resolve(result),
        t => Response::error(format!("type {} is not supported yet", t)).c_ptr(),
    }
}
