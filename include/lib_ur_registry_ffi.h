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

PtrResponse crypto_hd_key_get_source_fingerprint(void *crypto_hdkey);

PtrResponse crypto_hd_key_get_account_index(void *crypto_hdkey, uint32_t level);

PtrResponse crypto_hd_key_get_depth(void *crypto_hdkey);

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

PtrResponse ur_decoder_new(void);

PtrResponse ur_decoder_receive(void *decoder, void *ur);

PtrResponse ur_decoder_is_complete(void *decoder);

PtrResponse ur_decoder_result(void *decoder);

PtrResponse ur_decoder_resolve(void *decoder, void *target_type);

void utils_free(void *any_ptr);

PtrResponse ur_encoder_next_part(void *ur_encoder);
