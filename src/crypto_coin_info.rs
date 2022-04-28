use std::collections::BTreeMap;
use serde_cbor::{from_slice, to_vec, Value};
use serde_cbor::value::from_value;
use crate::registry_types::{CRYPTO_COIN_INFO, RegistryType};
use crate::traits::{RegistryItem, To, From};

const COIN_TYPE: i128 = 1;
const NETWORK: i128 = 2;

#[derive(Clone, Debug, PartialEq)]
pub enum CoinType {
    Bitcoin = 0,
}

#[derive(Clone, Debug, PartialEq)]
pub enum Network {
    MainNet = 0,
    TestNet = 1,
}

#[derive(Clone, Debug)]
pub struct CryptoCoinInfo {
    coin_type: Option<CoinType>,
    network: Option<Network>,
}

impl CryptoCoinInfo {
    pub fn new(coin_type: Option<CoinType>, network: Option<Network>) -> CryptoCoinInfo {
        CryptoCoinInfo { coin_type, network }
    }
    pub fn get_coin_type(&self) -> CoinType {
        self.coin_type.clone().unwrap_or(CoinType::Bitcoin)
    }
    pub fn get_network(&self) -> Network {
        self.network.clone().unwrap_or(Network::MainNet)
    }
}

impl To for CryptoCoinInfo {
    fn to_cbor(&self) -> Value {
        let mut map = BTreeMap::<Value, Value>::new();
        self.coin_type.clone().and_then(|x| map.insert(Value::Integer(COIN_TYPE), Value::Integer(x as i128)));
        self.network.clone().and_then(|x| map.insert(Value::Integer(NETWORK), Value::Integer(x as i128)));
        Value::Map(map)
    }

    fn to_bytes(&self) -> Vec<u8> {
        let value = self.to_cbor();
        to_vec(&value).unwrap()
    }
}

impl RegistryItem for CryptoCoinInfo {
    fn get_registry_type() -> RegistryType<'static> {
        CRYPTO_COIN_INFO
    }
}

impl From<CryptoCoinInfo> for CryptoCoinInfo {
    fn from_cbor(cbor: Value) -> Result<CryptoCoinInfo, String> {
        let map: BTreeMap<Value, Value> = match from_value(cbor) {
            Ok(x) => x,
            Err(e) => return Err(e.to_string())
        };
        let coin_type = match map.get(&Value::Integer(COIN_TYPE)) {
            Some(Value::Integer(x)) => Some(match x {
                0 => CoinType::Bitcoin,
                _ => CoinType::Bitcoin
            }),
            Some(_) => return Err("[ur-registry-rust][crypto-coin-info][from_cbor]Unexpected value when parsing components".to_string()),
            None => None,
        };
        let network = match map.get(&Value::Integer(NETWORK)) {
            Some(Value::Integer(x)) => Some(match x {
                0 => Network::MainNet,
                1 => Network::TestNet,
                _ => Network::MainNet
            }),
            Some(_) => return Err("[ur-registry-rust][crypto-coin-info][from_cbor]Unexpected value when parsing components".to_string()),
            None => None,
        };
        Ok(CryptoCoinInfo { coin_type, network })
    }

    fn from_bytes(bytes: Vec<u8>) -> Result<CryptoCoinInfo, String> {
        let value: Value = match from_slice(bytes.as_slice()) {
            Ok(x) => x,
            Err(e) => return Err(e.to_string()),
        };
        CryptoCoinInfo::from_cbor(value)
    }
}
