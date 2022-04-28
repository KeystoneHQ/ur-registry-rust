use std::collections::BTreeMap;
use serde_cbor::Value;

pub type Bytes = Vec<u8>;
pub type Fingerprint = [u8; 4];
pub type CborMap = BTreeMap<Value, Value>;