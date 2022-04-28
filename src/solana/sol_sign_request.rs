use std::borrow::Borrow;
use std::collections::BTreeMap;
use std::f32::consts::E;
use serde_cbor::{from_slice, to_vec, Value};
use serde_cbor::value::from_value;
use crate::crypto_key_path::CryptoKeyPath;
use crate::registry_types::{RegistryType, SOL_SIGN_REQUEST, UUID};
use crate::traits::{RegistryItem, To, From};
use crate::types::{Bytes, CborMap};

const REQUEST_ID: i128 = 1;
const SIGN_DATA: i128 = 2;
const DERIVATION_PATH: i128 = 3;
const ADDRESS: i128 = 4;
const ORIGIN: i128 = 5;
const SIGN_TYPE: i128 = 6;

#[derive(Clone, Debug)]
pub enum SignType {
    Transaction = 1,
    Message,
}

#[derive(Clone, Debug)]
pub struct SolSignRequest {
    request_id: Option<Bytes>,
    sign_data: Bytes,
    derivation_path: CryptoKeyPath,
    address: Option<Bytes>,
    origin: Option<String>,
    sign_type: Option<SignType>,
}

impl SolSignRequest {
    pub fn new(request_id: Option<Bytes>,
               sign_data: Bytes,
               derivation_path: CryptoKeyPath,
               address: Option<Bytes>,
               origin: Option<String>,
               sign_type: Option<SignType>, ) -> SolSignRequest {
        SolSignRequest { request_id, sign_data, derivation_path, address, origin, sign_type }
    }
    pub fn get_request_id(&self) -> Option<Bytes> {
        self.request_id.clone()
    }
    pub fn get_sign_data(&self) -> Bytes {
        self.sign_data.clone()
    }
    pub fn get_derivation_path(&self) -> CryptoKeyPath {
        self.derivation_path.clone()
    }
    pub fn get_address(&self) -> Option<Bytes> {
        self.address.clone()
    }
    pub fn get_origin(&self) -> Option<String> {
        self.origin.clone()
    }
    pub fn get_sign_type(&self) -> Option<SignType> {
        self.sign_type.clone()
    }
    pub fn get_canonical_sign_type(&self) -> SignType {
        self.get_sign_type().unwrap_or(SignType::Transaction)
    }
}

impl RegistryItem for SolSignRequest {
    fn get_registry_type() -> RegistryType<'static> {
        SOL_SIGN_REQUEST
    }
}

impl To for SolSignRequest {
    fn to_cbor(&self) -> Value {
        let mut map: BTreeMap<Value, Value> = BTreeMap::new();
        self.get_request_id().and_then(
            |id| map.insert(
                Value::Integer(REQUEST_ID),
                Value::Tag(UUID.get_tag() as u64, Box::new(Value::Bytes(id))),
            )
        );
        map.insert(Value::Integer(SIGN_DATA), Value::Bytes(self.get_sign_data()));
        map.insert(
            Value::Integer(DERIVATION_PATH),
            Value::Tag(CryptoKeyPath::get_registry_type().get_tag() as u64, Box::new(self.get_derivation_path().to_cbor())),
        );
        self.get_address().and_then(
            |address| map.insert(Value::Integer(ADDRESS), Value::Bytes(address)));
        self.get_origin().and_then(|origin| map.insert(Value::Integer(ORIGIN), Value::Text(origin)));
        self.get_sign_type().and_then(|sign_type| map.insert(Value::Integer(SIGN_TYPE), Value::Integer(sign_type as i128)));
        Value::Map(map)
    }

    fn to_bytes(&self) -> Vec<u8> {
        let value = self.to_cbor();
        to_vec(&value).unwrap()
    }
}

impl From<SolSignRequest> for SolSignRequest {
    fn from_cbor(cbor: Value) -> Result<SolSignRequest, String> {
        let map: CborMap = match from_value(cbor) {
            Ok(x) => x,
            Err(e) => return Err(e.to_string())
        };
        let request_id = match map.get(&Value::Integer(REQUEST_ID)) {
            Some(Value::Tag(37, value)) => {
                match *value.clone() {
                    Value::Bytes(x) => Some(x),
                    _ => return Err("[ur-registry-rust][sol-sign-request][from_cbor]Unexpected value when parsing request_id".to_string())
                }
            }
            Some(_) => {
                return Err("[ur-registry-rust][sol-sign-request][from_cbor]Unexpected value when parsing request_id".to_string());
            }
            None => None,
        };
        let sign_data = match map.get(&Value::Integer(SIGN_DATA)) {
            Some(Value::Bytes(x)) => x.clone(),
            Some(_) => return Err("[ur-registry-rust][sol-sign-request][from_cbor]Unexpected value when parsing sign_data".to_string()),
            None => return Err("[ur-registry-rust][sol-sign-request][from_cbor]sign_data is required for sol-sign-request".to_string())
        };
        let derivation_path = match map.get(&Value::Integer(DERIVATION_PATH)) {
            Some(Value::Tag(_, value)) => {
                match CryptoKeyPath::from_cbor(*value.clone()) {
                    Ok(x) => x,
                    Err(e) => return Err(e),
                }
            }
            Some(_) => return Err("invalid type".to_string()),
            None => return Err("derivation_path is required".to_string()),
        };
        let address = match map.get(&Value::Integer(ADDRESS)) {
            Some(Value::Bytes(x)) => Some(x.clone()),
            Some(_) => return Err("invalid type".to_string()),
            None => None,
        };
        let origin = match map.get(&Value::Integer(ORIGIN)) {
            Some(Value::Text(x)) => Some(x.clone()),
            Some(_) => return Err("invalid type".to_string()),
            None => None,
        };
        let sign_type = match map.get(&Value::Integer(SIGN_TYPE)) {
            Some(Value::Integer(x)) => match x {
                1 => Some(SignType::Transaction),
                2 => Some(SignType::Message),
                _ => return Err("invalid sign type".to_string()),
            },
            Some(_) => return Err("invalid type".to_string()),
            None => None,
        };
        Ok(SolSignRequest { request_id, sign_data, derivation_path, address, origin, sign_type })
    }

    fn from_bytes(bytes: Vec<u8>) -> Result<SolSignRequest, String> {
        let value: Value = match from_slice(bytes.as_slice()) {
            Ok(x) => x,
            Err(e) => return Err(e.to_string()),
        };
        SolSignRequest::from_cbor(value)
    }
}
