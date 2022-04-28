use std::collections::BTreeMap;
use serde_cbor::{from_slice, to_vec, Value};
use serde_cbor::value::from_value;
use crate::traits::{To, From, RegistryItem};
use crate::registry_types::{CRYPTO_ECKEY, RegistryType};

const CURVE: i128 = 1;
const PRIVATE: i128 = 2;
const DATA: i128 = 3;

#[derive(Default)]
pub struct CryptoECKey {
    curve: Option<i128>,
    is_private_key: Option<bool>,
    data: Vec<u8>,
}

impl CryptoECKey {
    pub fn get_curve(&self) -> i128 {
        match self.curve {
            Some(x) => x,
            None => 0,
        }
    }

    pub fn get_is_private_key(&self) -> bool {
        match self.is_private_key {
            Some(x) => x,
            None => false,
        }
    }

    pub fn get_data(&self) -> Vec<u8> {
        self.data.clone()
    }
}

impl RegistryItem for CryptoECKey {
    fn get_registry_type() -> RegistryType<'static> {
        CRYPTO_ECKEY
    }
}

impl To for CryptoECKey {
    fn to_cbor(&self) -> Value {
        let mut map = BTreeMap::<Value, Value>::new();
        match self.curve {
            Some(x) => {
                map.insert(Value::Integer(CURVE), Value::Integer(x));
            }
            None => {}
        }
        match self.is_private_key {
            Some(x) => {
                map.insert(Value::Integer(PRIVATE), Value::Bool(x));
            }
            None => {}
        }
        map.insert(Value::Integer(DATA), Value::Bytes(self.data.clone()));
        Value::Map(map)
    }

    fn to_bytes(&self) -> Vec<u8> {
        let value = self.to_cbor();
        to_vec(&value).unwrap()
    }
}

impl From<CryptoECKey> for CryptoECKey {
    fn from_cbor(value: Value) -> Result<CryptoECKey, String> {
        let map: BTreeMap<Value, Value> = match from_value(value) {
            Ok(t) => t,
            Err(e) => return Err(e.to_string()),
        };
        let curve = match map.get(&Value::Integer(CURVE)).map(|v| from_value::<i128>(v.clone())) {
            Some(x) => match x {
                Ok(x) => Some(x),
                Err(e) => return Err(e.to_string())
            },
            None => None
        };
        let is_private_key = match map.get(&Value::Integer(PRIVATE)).map(|v| from_value::<bool>(v.clone())) {
            Some(x) => match x {
                Ok(x) => Some(x),
                Err(e) => return Err(e.to_string())
            },
            None => None,
        };
        let data = match map.get(&Value::Integer(DATA)).map(|v| match from_value(v.clone()) {
            Ok(Value::Bytes(x)) => Ok(x),
            Ok(_) => Err("Unexpected value when parsing crypto_ec_key.data".to_string()),
            Err(e) => Err(e.to_string())
        }) {
            Some(Ok(x)) => x,
            None => vec![],
            Some(Err(e)) => return Err(e)
        };
        Ok(CryptoECKey { curve, is_private_key, data })
    }

    fn from_bytes(bytes: Vec<u8>) -> Result<CryptoECKey, String> {
        let value: Value = match from_slice(bytes.as_slice()) {
            Ok(x) => x,
            Err(e) => return Err(e.to_string()),
        };
        CryptoECKey::from_cbor(value)
    }
}

#[cfg(test)]
mod tests {
    use hex::FromHex;
    use crate::crypto_ec_key::CryptoECKey;
    use crate::traits::{From, To, UR};

    #[test]
    fn test_encode() {
        let crypto_ec_key = CryptoECKey {
            is_private_key: Some(true),
            data: Vec::from_hex("8c05c4b4f3e88840a4f4b5f155cfd69473ea169f3d0431b7a6787a23777f08aa").unwrap(),
            ..Default::default()
        };
        assert_eq!("A202F50358208C05C4B4F3E88840A4F4B5F155CFD69473EA169F3D0431B7A6787A23777F08AA", hex::encode(crypto_ec_key.to_bytes()).to_uppercase());

        let mut encoder = crypto_ec_key.to_ur_encoder(1000);
        let ur = encoder.next_part().unwrap();
        assert_eq!(ur, "ur:crypto-eckey/oeaoykaxhdcxlkahssqzwfvslofzoxwkrewngotktbmwjkwdcmnefsaaehrlolkskncnktlbaypkrphsmyid");
    }

    #[test]
    fn test_decode() {
        let bytes = Vec::from_hex("A202F50358208C05C4B4F3E88840A4F4B5F155CFD69473EA169F3D0431B7A6787A23777F08AA").unwrap();
        let crypto_ec_key = CryptoECKey::from_bytes(bytes).unwrap();
        assert_eq!(crypto_ec_key.get_curve(), 0);
        assert_eq!(crypto_ec_key.get_is_private_key(), true);
        assert_eq!(crypto_ec_key.get_data(), Vec::from_hex("8c05c4b4f3e88840a4f4b5f155cfd69473ea169f3d0431b7a6787a23777f08aa").unwrap());
    }
}