use std::collections::BTreeMap;
use serde_cbor::{from_slice, to_vec, Value};
use serde_cbor::value::from_value;
use serde_cbor::Value::Map;
use crate::crypto_hd_key::CryptoHDKey;
use crate::registry_types::{CRYPTO_MULTI_ACCOUNTS, RegistryType};
use crate::traits::{RegistryItem, To, From};
use crate::types::Fingerprint;

const MASTER_FINGERPRINT: i128 = 1;
const KEYS: i128 = 2;
const DEVICE: i128 = 3;


pub struct CryptoMultiAccounts {
    master_fingerprint: Fingerprint,
    keys: Vec<CryptoHDKey>,
    device: Option<String>,
}

impl CryptoMultiAccounts {
    pub fn new(master_fingerprint: Fingerprint, keys: Vec<CryptoHDKey>, device: Option<String>) -> CryptoMultiAccounts {
        CryptoMultiAccounts { master_fingerprint, keys, device }
    }

    pub fn get_master_fingerprint(&self) -> Fingerprint {
        self.master_fingerprint.clone()
    }
    pub fn get_keys(&self) -> Vec<CryptoHDKey> {
        self.keys.clone()
    }
    pub fn get_device(&self) -> Option<String> {
        self.device.clone()
    }
}

impl RegistryItem for CryptoMultiAccounts {
    fn get_registry_type() -> RegistryType<'static> {
        CRYPTO_MULTI_ACCOUNTS
    }
}

impl To for CryptoMultiAccounts {
    fn to_cbor(&self) -> Value {
        let mut map: BTreeMap<Value, Value> = BTreeMap::new();
        map.insert(Value::Integer(MASTER_FINGERPRINT), Value::Integer(u32::from_be_bytes(self.get_master_fingerprint()) as i128));
        map.insert(
            Value::Integer(KEYS),
            Value::Array(self.get_keys().iter().map(
                |key| Value::Tag(CryptoHDKey::get_registry_type().get_tag() as u64, Box::new(key.to_cbor()))
            ).collect()
            ),
        );
        self.get_device().and_then(|device| map.insert(Value::Integer(DEVICE), Value::Text(device)));
        Value::Map(map)
    }

    fn to_bytes(&self) -> Vec<u8> {
        let value = self.to_cbor();
        to_vec(&value).unwrap()
    }
}

impl From<CryptoMultiAccounts> for CryptoMultiAccounts {
    fn from_cbor(cbor: Value) -> Result<CryptoMultiAccounts, String> {
        let map: BTreeMap<Value, Value> = match from_value(cbor) {
            Ok(x) => x,
            Err(e) => return Err(e.to_string())
        };
        let master_fingerprint = match map.get(&Value::Integer(MASTER_FINGERPRINT)) {
            Some(Value::Integer(x)) => (x.clone() as u32).clone().to_be_bytes(),
            Some(_) => return Err("[ur-registry-rust][crypto-multi-accounts][from_cbor]received unexpected value when parsing data to crypto-multi-accounts.master_fingerprint".to_string()),
            None => return Err("[ur-registry-rust][crypto-multi-accounts][from_cbor]master_fingerprint is required for crypto-multi-accounts".to_string()),
        };
        let keys: Result<Vec<CryptoHDKey>, String> = match map.get(&Value::Integer(KEYS)) {
            Some(Value::Array(x)) => {
                x.clone().iter().map(|value| match value {
                    Value::Tag(_, value) => {
                        CryptoHDKey::from_cbor(*value.clone())
                    }
                    _ => Err("[ur-registry-rust][crypto-multi-accounts][from_cbor]received unexpected value when parsing data to crypto-multi-accounts.keys".to_string()),
                }).collect()
            }
            Some(_) => return Err("[ur-registry-rust][crypto-multi-accounts][from_cbor]received unexpected value when parsing data to crypto-multi-accounts.keys".to_string()),
            None => return Err("[ur-registry-rust][crypto-multi-accounts][from_cbor]keys is required for crypto-multi-accounts".to_string()),
        };
        let device = match map.get(&Value::Integer(DEVICE)) {
            Some(Value::Text(x)) => Some(x.clone()),
            Some(_) => return Err("[ur-registry-rust][crypto-multi-accounts][from_cbor]received unexpected value when parsing data to crypto-multi-accounts.device".to_string()),
            None => None,
        };
        Ok(CryptoMultiAccounts { master_fingerprint, keys: keys?, device })
    }

    fn from_bytes(bytes: Vec<u8>) -> Result<CryptoMultiAccounts, String> {
        let value: Value = match from_slice(bytes.as_slice()) {
            Ok(x) => x,
            Err(e) => return Err(e.to_string()),
        };
        CryptoMultiAccounts::from_cbor(value)
    }
}

#[cfg(test)]
mod tests {
    use hex::FromHex;
    use crate::crypto_hd_key::CryptoHDKey;
    use crate::crypto_key_path::{CryptoKeyPath, PathComponent};
    use crate::solana::crypto_multi_accounts::CryptoMultiAccounts;
    use crate::traits::{From, To};

    #[test]
    fn test_encode() {
        let crypto_hdkey = CryptoHDKey::new_extended_key(
            None,
            Vec::from_hex("02eae4b876a8696134b868f88cc2f51f715f2dbedb7446b8e6edf3d4541c4eb67b").unwrap(),
            None,
            None,
            Some(CryptoKeyPath::new(
                vec![
                    PathComponent::new(Some(44), true).unwrap(),
                    PathComponent::new(Some(501), true).unwrap(),
                    PathComponent::new(Some(0), true).unwrap(),
                    PathComponent::new(Some(0), true).unwrap(),
                ],
                None,
                None,
            )),
            None,
            None,
            None,
            None,
        );
        let crypto_multi_accounts = CryptoMultiAccounts::new(
            [0xe9, 0x18, 0x1c, 0xf3],
            vec![crypto_hdkey],
            Some("keystone".to_string()),
        );
        assert_eq!("a3011ae9181cf30281d9012fa203582102eae4b876a8696134b868f88cc2f51f715f2dbedb7446b8e6edf3d4541c4eb67b06d90130a10188182cf51901f5f500f500f503686b657973746f6e65", hex::encode(crypto_multi_accounts.to_bytes()));
    }

    #[test]
    fn test_decode() {
        let crypto_multi_accounts = CryptoMultiAccounts::from_bytes(Vec::from_hex("a3011ae9181cf30281d9012fa203582102eae4b876a8696134b868f88cc2f51f715f2dbedb7446b8e6edf3d4541c4eb67b06d90130a10188182cf51901f5f500f500f503686b657973746f6e65").unwrap()).unwrap();
        assert_eq!(crypto_multi_accounts.master_fingerprint, [0xe9, 0x18, 0x1c, 0xf3]);
        assert_eq!(crypto_multi_accounts.device, Some("keystone".to_string()));
        assert_eq!(crypto_multi_accounts.keys.len(), 1);
    }
}
