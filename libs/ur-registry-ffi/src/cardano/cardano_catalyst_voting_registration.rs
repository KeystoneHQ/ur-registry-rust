use crate::response::{PtrResponse, Response};
use crate::types::{PtrString, PtrVoid};
use crate::utils::{convert_ptr_string_to_string, remove_prefix_0x};
use serde::Deserialize;
use serde_json::json;
use ur_registry::cardano::cardano_catalyst_voting_registration::CardanoCatalystVotingRegistrationRequest;
use ur_registry::cardano::cardano_delegation::CardanoDelegation;
use ur_registry::crypto_key_path::CryptoKeyPath;
use ur_registry::traits::{RegistryItem, To};
use uuid::Uuid;

#[no_mangle]
pub extern "C" fn cardano_catalyst_voting_registration_new() -> PtrResponse {
    Response::success_object(Box::into_raw(Box::new(
        CardanoCatalystVotingRegistrationRequest::default(),
    )) as PtrVoid)
    .c_ptr()
}

#[derive(Deserialize)]
struct Delegation {
    pub_key: String,
    width: u8,
}

// request_id: Option<Bytes>,
// delegations: Vec<CardanoDelegation>,
// stake_pub: Bytes,
// payment_address: Bytes,
// nonce: u64,
// voting_purpose: u8,
// derivation_path: CryptoKeyPath,
// origin: Option<String>,
// sign_type: u8

#[no_mangle]
pub extern "C" fn cardano_catalyst_voting_registration_construct(
    request_id: PtrString,
    mfp: PtrString,
    delegations: PtrString,
    stake_pub: PtrString,
    payment_address: PtrString,
    nonce: PtrString,
    voting_purpose: u8,
    derivation_path: PtrString,
    origin: PtrString,
    sign_type: u8,
) -> PtrResponse {
    let request_id = convert_ptr_string_to_string(request_id).unwrap();
    let request_id = match Uuid::parse_str(&request_id) {
        Ok(v) => v,
        Err(_) => return Response::error(json!({"error": "uuid is invalid"}).to_string()).c_ptr(),
    }
    .as_bytes()
    .to_vec();

    let mfp = convert_ptr_string_to_string(mfp).unwrap();
    let mfp = match hex::decode(remove_prefix_0x(&mfp)) {
        Ok(v) => v,
        Err(_) => return Response::error(json!({"error": "mfp is invalid"}).to_string()).c_ptr(),
    };

    if mfp.len() != 4 {
        return Response::error(json!({"error": "mfp is invalid"}).to_string()).c_ptr();
    }

    let delegations = convert_ptr_string_to_string(delegations).unwrap();
    let delegations: Vec<CardanoDelegation> = serde_json::from_str::<Vec<Delegation>>(&delegations)
        .unwrap()
        .into_iter()
        .map(|d| {
            CardanoDelegation::new(
                hex::decode(remove_prefix_0x(&d.pub_key))
                    .unwrap()
                    .as_slice()
                    .to_vec(),
                d.width,
            )
        })
        .collect();

    let stake_pub = convert_ptr_string_to_string(stake_pub).unwrap();
    let stake_pub_bytes = match hex::decode(remove_prefix_0x(&stake_pub)) {
        Ok(v) => v,
        Err(_) => {
            return Response::error(json!({"error": "stake pub is invalid"}).to_string()).c_ptr()
        }
    };

    let payment_address = convert_ptr_string_to_string(payment_address).unwrap();
    let payment_address_bytes = match hex::decode(remove_prefix_0x(&payment_address)) {
        Ok(v) => v,
        Err(_) => {
            return Response::error(json!({"error": "payment address is invalid"}).to_string())
                .c_ptr()
        }
    };

    let nonce = convert_ptr_string_to_string(nonce).unwrap();
    let nonce = match nonce.parse::<u64>() {
        Ok(v) => v,
        Err(_) => return Response::error(json!({"error": "nonce is invalid"}).to_string()).c_ptr(),
    };

    let derivation_path = convert_ptr_string_to_string(derivation_path).unwrap();
    let derivation_path = match CryptoKeyPath::from_path(
        derivation_path,
        Some(mfp.as_slice().try_into().ok().unwrap()),
    ) {
        Ok(v) => v,
        Err(_) => {
            return Response::error(json!({"error": "derivation path is invalid"}).to_string())
                .c_ptr()
        }
    };

    let origin = convert_ptr_string_to_string(origin).unwrap();
    let origin = if origin.len() == 0 {
        None
    } else {
        Some(origin.to_string())
    };

    let request = CardanoCatalystVotingRegistrationRequest::new(
        Some(request_id),
        delegations,
        stake_pub_bytes,
        payment_address_bytes,
        nonce,
        voting_purpose,
        derivation_path,
        origin,
        sign_type,
    );

    Response::success_object(Box::into_raw(Box::new(request)) as PtrVoid).c_ptr()
}

#[no_mangle]
pub extern "C" fn cardano_catalyst_voting_registration_get_ur_encoder(
    cardano_catalyst_voting_registration: &mut CardanoCatalystVotingRegistrationRequest,
) -> PtrResponse {
    let message = cardano_catalyst_voting_registration.to_bytes().unwrap();
    let ur_encoder = ur::Encoder::new(
        message.as_slice(),
        200,
        CardanoCatalystVotingRegistrationRequest::get_registry_type().get_type(),
    )
    .unwrap();
    Response::success_object(Box::into_raw(Box::new(ur_encoder)) as PtrVoid).c_ptr()
}

#[no_mangle]
pub extern "C" fn cardano_catalyst_voting_registration_get_request_id(
    cardano_catalyst_voting_registration: &mut CardanoCatalystVotingRegistrationRequest,
) -> PtrResponse {
    cardano_catalyst_voting_registration
        .get_request_id()
        .map_or(Response::success_null().c_ptr(), |id| {
            Response::success_string(hex::encode(id)).c_ptr()
        })
}
