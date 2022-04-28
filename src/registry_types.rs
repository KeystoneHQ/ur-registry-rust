pub struct RegistryType<'a> (&'a str, u32);

impl<'a> RegistryType<'_> {
    pub fn get_type(&self) -> String {
        self.0.to_string()
    }
    pub fn get_tag(&self) -> u32 {
        self.1
    }
}

pub const UUID: RegistryType = RegistryType("uuid", 37);
pub const CRYPTO_HDKEY: RegistryType = RegistryType("crypto-hdkey", 303);
pub const CRYPTO_KEYPATH: RegistryType = RegistryType("crypto-keypath", 304);
pub const CRYPTO_COIN_INFO: RegistryType = RegistryType("crypto-coin-info", 305);
pub const CRYPTO_ECKEY: RegistryType = RegistryType("crypto-eckey", 306);

