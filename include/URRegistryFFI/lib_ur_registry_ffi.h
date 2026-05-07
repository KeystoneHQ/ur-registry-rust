// NOTE: Append the lines below to ios/Classes/GreeterPlugin.h

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

#define SUCCESS 0

#define ERROR 1

typedef char *PtrString;

typedef void *PtrVoid;

typedef union Value {
    PtrVoid _object;
    bool _boolean;
    uint32_t _uint32;
    PtrString _string;
    PtrVoid _null;
} Value;

typedef struct Response {
    uint32_t status_code;
    PtrString error_message;
    PtrString value_type;
    union Value value;
} Response;

typedef struct Response *PtrResponse;

PtrResponse crypto_hd_key_get_key_data(void *crypto_hdkey);

PtrResponse crypto_hd_key_get_uncompressed_key_data(void *compressed_key);

PtrResponse crypto_hd_key_get_chain_code(void *crypto_hdkey);

PtrResponse crypto_hd_key_get_name(void *crypto_hdkey);

PtrResponse crypto_hd_key_get_path(void *crypto_hdkey);

PtrResponse crypto_hd_key_get_children_path(void *crypto_hdkey);

PtrResponse crypto_hd_key_get_source_fingerprint(void *crypto_hdkey);

PtrResponse crypto_hd_key_get_account_index(void *crypto_hdkey, uint32_t level);

PtrResponse crypto_hd_key_get_depth(void *crypto_hdkey);

PtrResponse crypto_hd_key_get_note(void *crypto_hdkey);

PtrResponse crypto_hd_key_get_bip32_xpub(void *crypto_hdkey);

PtrResponse crypto_account_get_accounts_len(void *crypto_account);

PtrResponse crypto_account_get_account(void *crypto_account, uint32_t index);

PtrResponse crypto_account_get_master_fingerprint(void *crypto_account);

PtrResponse crypto_output_get_hd_key(void *crypto_output);

PtrResponse solana_crypto_multi_accounts_get_master_fingerprint(void *crypto_multi_accounts);

PtrResponse solana_crypto_multi_accounts_get_device(void *crypto_multi_accounts);

PtrResponse solana_crypto_multi_accounts_get_keys_len(void *crypto_multi_accounts);

PtrResponse solana_crypto_multi_accounts_get_key(void *crypto_multi_accounts,
                                                 uint32_t index);

PtrResponse solana_sign_request_new(void);

PtrResponse solana_sign_request_construct(void *request_id,
                                          void *sign_data,
                                          void *path,
                                          uint32_t xfp,
                                          void *address,
                                          void *origin,
                                          uint32_t sign_type);

PtrResponse solana_sign_request_get_ur_encoder(void *sol_sign_request);

PtrResponse solana_sign_request_get_request_id(void *sol_sign_request);

PtrResponse solana_signature_get_signature(void *solana_signarure);

PtrResponse solana_signature_get_request_id(void *solana_signature);

PtrResponse eth_sign_request_new(void);

PtrResponse eth_sign_request_construct(void *request_id,
                                       void *sign_data,
                                       uint32_t data_type,
                                       uint32_t chain_id,
                                       void *path,
                                       uint32_t xfp,
                                       void *address,
                                       void *origin);

PtrResponse eth_sign_request_get_ur_encoder(void *eth_sign_request);

PtrResponse eth_sign_request_get_request_id(void *eth_sign_request);

PtrResponse eth_signature_get_signature(void *eth_signarure);

PtrResponse eth_signature_get_request_id(void *eth_signature);

PtrResponse cardano_sign_request_new(void);

PtrResponse cardano_sign_request_construct(void *request_id,
                                           void *sign_data,
                                           void *utxos,
                                           void *cert_keys,
                                           void *origin);

PtrResponse cardano_sign_request_get_ur_encoder(void *cardano_sign_request);

PtrResponse cardano_sign_request_get_request_id(void *cardano_sign_request);

PtrResponse cardano_signature_get_witness_set(void *cardano_signature);

PtrResponse cardano_signature_get_request_id(void *cardano_signature);

PtrResponse cardano_sign_data_request_new(void);

PtrResponse cardano_sign_data_request_construct(void *request_id,
                                                void *mfp,
                                                void *sign_data,
                                                void *derivation_path,
                                                void *origin,
                                                void *xpub);

PtrResponse cardano_sign_data_request_get_ur_encoder(void *cardano_sign_data_request);

PtrResponse cardano_sign_data_request_get_request_id(void *cardano_sign_data_request);

PtrResponse cardano_sign_data_signature_new(void);

PtrResponse cardano_sign_data_signature_construct(void *request_id,
                                                  void *signature,
                                                  void *public_key);

PtrResponse cardano_sign_data_signature_get_request_id(void *signature);

PtrResponse cardano_sign_data_signature_get_signature(void *signature);

PtrResponse cardano_sign_data_signature_get_public_key(void *signature);

PtrResponse cardano_sign_cip8_data_request_new(void);

PtrResponse cardano_sign_cip8_data_request_construct(void *request_id,
                                                     void *mfp,
                                                     void *sign_data,
                                                     void *derivation_path,
                                                     void *xpub,
                                                     void *origin,
                                                     bool hash_payload,
                                                     void *address_bench32,
                                                     uint32_t address_type);

PtrResponse cardano_sign_cip8_data_request_get_ur_encoder(void *cardano_sign_cip8_data_request);

PtrResponse cardano_sign_cip8_data_request_get_request_id(void *cardano_sign_cip8_data_request);

PtrResponse cardano_sign_cip8_data_signature_new(void);

PtrResponse cardano_sign_cip8_data_signature_construct(void *request_id,
                                                       void *signature,
                                                       void *public_key,
                                                       void *address_field);

PtrResponse cardano_sign_cip8_data_signature_get_request_id(void *signature);

PtrResponse cardano_sign_cip8_data_signature_get_signature(void *signature);

PtrResponse cardano_sign_cip8_data_signature_get_public_key(void *signature);

PtrResponse cardano_sign_cip8_data_signature_get_address_field(void *signature);

PtrResponse cardano_catalyst_voting_registration_new(void);

PtrResponse cardano_catalyst_voting_registration_construct(void *request_id,
                                                           void *mfp,
                                                           void *delegations,
                                                           void *stake_pub,
                                                           void *payment_address,
                                                           void *nonce,
                                                           uint8_t voting_purpose,
                                                           void *derivation_path,
                                                           void *origin,
                                                           uint8_t sign_type);

PtrResponse cardano_catalyst_voting_registration_get_ur_encoder(void *cardano_catalyst_voting_registration);

PtrResponse cardano_catalyst_voting_registration_get_request_id(void *cardano_catalyst_voting_registration);

PtrResponse cardano_catalyst_signature_new(void);

PtrResponse cardano_catalyst_signature_construct(void *request_id,
                                                 void *signature);

PtrResponse cardano_catalyst_signature_get_request_id(void *catalyst_signature);

PtrResponse cardano_catalyst_signature_get_signature(void *catalyst_signature);

PtrResponse cardano_sign_tx_hash_request_construct(void *request_id,
                                                   void *tx_hash,
                                                   void *paths,
                                                   void *origin,
                                                   void *address_list);

PtrResponse cardano_sign_tx_hash_request_get_ur_encoder(void *cardano_sign_tx_hash_request);

PtrResponse cardano_sign_tx_hash_request_get_request_id(void *cardano_sign_tx_hash_request);

PtrResponse ur_decoder_new(void);

PtrResponse ur_decoder_receive(void *decoder, void *ur);

PtrResponse ur_decoder_is_complete(void *decoder);

PtrResponse ur_decoder_result(void *decoder);

PtrResponse ur_decoder_resolve(void *decoder, void *target_type);

void utils_free(void *any_ptr);

PtrResponse ur_encoder_next_part(void *ur_encoder);
