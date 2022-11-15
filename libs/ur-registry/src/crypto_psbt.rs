use serde_cbor::{from_slice, to_vec, Value};

use crate::{
    cbor_value::CborValue,
    registry_types::{RegistryType, CRYPTO_PSBT},
    traits::{From, RegistryItem, To},
    types::Bytes,
};

#[derive(Debug, Clone, Default)]
pub struct CryptoPSBT {
    psbt: Bytes,
}

impl CryptoPSBT {
    pub fn new(psbt: Bytes) -> Self {
        CryptoPSBT { psbt }
    }

    pub fn get_psbt(&self) -> Bytes {
        self.psbt.clone()
    }

    pub fn set_psbt(&mut self, psbt: Bytes) {
        self.psbt = psbt;
    }
}

impl RegistryItem for CryptoPSBT {
    fn get_registry_type() -> RegistryType<'static> {
        CRYPTO_PSBT
    }
}

impl To for CryptoPSBT {
    fn to_cbor(&self) -> Value {
        Value::Bytes(self.get_psbt())
    }

    fn to_bytes(&self) -> Vec<u8> {
        let value = self.to_cbor();
        //TODO: remove unwrap
        to_vec(&value).unwrap()
    }
}

impl From<CryptoPSBT> for CryptoPSBT {
    fn from_cbor(cbor: Value) -> Result<CryptoPSBT, String> {
        let value = CborValue::new(cbor);
        let bytes = value.get_bytes()?;
        Ok(CryptoPSBT { psbt: bytes })
    }

    fn from_bytes(bytes: Vec<u8>) -> Result<CryptoPSBT, String> {
        let value: Value = match from_slice(bytes.as_slice()) {
            Ok(x) => x,
            Err(e) => return Err(e.to_string()),
        };
        CryptoPSBT::from_cbor(value)
    }
}
