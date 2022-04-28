use serde_cbor::{from_slice, to_vec, Value};
use serde_cbor::value::from_value;
use crate::registry_types::{RegistryType, SOL_SIGNATURE};
use crate::traits::{RegistryItem, To, From};
use crate::types::{Bytes, CborMap};

const REQUEST_ID: i128 = 1;
const SIGNATURE: i128 = 2;

#[derive(Clone, Debug, Default)]
pub struct SolSignature {
    request_id: Option<Bytes>,
    signature: Bytes,
}

impl SolSignature {
    pub fn get_request_id(&self) -> Option<Bytes> {
        self.request_id.clone()
    }
    pub fn get_signature(&self) -> Bytes {
        self.signature.clone()
    }
}

impl RegistryItem for SolSignature {
    fn get_registry_type() -> RegistryType<'static> {
        SOL_SIGNATURE
    }
}

impl To for SolSignature {
    fn to_cbor(&self) -> Value {
        let mut map: CborMap = CborMap::new();
        self.get_request_id().and_then(
            |request_id| map.insert(
                Value::Integer(REQUEST_ID),
                Value::Tag(37, Box::new(Value::Bytes(request_id))),
            )
        );
        map.insert(Value::Integer(SIGNATURE), Value::Bytes(self.get_signature()));
        Value::Map(map)
    }

    fn to_bytes(&self) -> Vec<u8> {
        let value = self.to_cbor();
        to_vec(&value).unwrap()
    }
}

impl From<SolSignature> for SolSignature {
    fn from_cbor(cbor: Value) -> Result<SolSignature, String> {
        let map: CborMap = match from_value(cbor) {
            Ok(x) => x,
            Err(e) => return Err(e.to_string())
        };
        let request_id = match map.get(&Value::Integer(REQUEST_ID)) {
            Some(Value::Tag(37, value)) => {
                match *value.clone() {
                    Value::Bytes(x) => Some(x),
                    _ => return Err("[ur-registry-rust][sol-signature][from_cbor]Unexpected value when parsing request_id".to_string())
                }
            }
            Some(_) => {
                return Err("[ur-registry-rust][sol-signature][from_cbor]Unexpected value when parsing request_id".to_string());
            }
            None => None,
        };
        let signature = match map.get(&Value::Integer(SIGNATURE)) {
            Some(Value::Bytes(x)) => x.clone(),
            Some(_) => return Err("[ur-registry-rust][sol-signature][from_cbor]Unexpected value when parsing signature".to_string()),
            None => return Err("[ur-registry-rust][sol-signature][from_cbor]signature is required for sol-signature".to_string())
        };
        Ok(SolSignature { request_id, signature })
    }

    fn from_bytes(bytes: Vec<u8>) -> Result<SolSignature, String> {
        let value: Value = match from_slice(bytes.as_slice()) {
            Ok(x) => x,
            Err(e) => return Err(e.to_string()),
        };
        SolSignature::from_cbor(value)
    }
}
