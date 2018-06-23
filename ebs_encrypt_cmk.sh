#!/bin/bash

#------------------------------------------------------------------------------------------------------------------------------------------
# Desciption:
# Shell script to create AWS KMS Customer Master Key
# Reference Doc:
# https://docs.aws.amazon.com/kms/latest/developerguide/importing-keys-create-cmk.html
# man openssl
#------------------------------------------------------------------------------------------------------------------------------------------

# Exit script  when non-zero return code
set -e

# debug mode
#set -x

# Variables
PROFILE=aws_profile_name
REGION=us-east-1
DESCRIPTION=ENTER_KEY_NAME
AWS=$(which aws)
SSL=$(which openssl)
JQ=$(which jq)
TR=$(which tr)

# Generating KMS key
export KEY_ID="$($AWS kms create-key --description $DESCRIPTION \
            --region $REGION --profile $PROFILE --origin EXTERNAL \
            | $JQ .KeyMetadata.KeyId | $TR -d '"')"
echo "The Key id is "
echo $KEY_ID

export KEY_PARAMETERS="$($AWS kms --region $REGION get-parameters-for-import\
                      --key-id $KEY_ID --wrapping-algorithm RSAES_OAEP_SHA_1 \
                      --wrapping-key-spec RSA_2048 --profile $PROFILE)"

# base64 encode the keys
echo $KEY_PARAMETERS | $JQ .PublicKey   | $TR -d '"'  > PublicKey.b64
echo $KEY_PARAMETERS | $JQ .ImportToken | $TR -d '"'  > ImportToken.b64

# # Generating CMK using openssl utility
$SSL enc -d -base64 -A -in PublicKey.b64 -out PublicKey.bin
$SSL enc -d -base64 -A -in ImportToken.b64 -out ImportToken.bin
$SSL rand -out PlaintextKeyMaterial.bin 32
$SSL  rsautl -encrypt -in PlaintextKeyMaterial.bin -oaep -inkey PublicKey.bin -pubin -keyform DER -out EncryptedKeyMaterial.bin


# Importing encrypted CMK Key Material to AWS
# To Expired the key repliace KEY_MATERIAL_DOES_NOT_EXPIRE with
# KEY_MATERIAL_EXPIRES --valid-to yyyy-mm-ddT12:00:00-00:00
$AWS kms --region $REGION --profile $PROFILE import-key-material \
--key-id $KEY_ID --encrypted-key-material \
fileb://EncryptedKeyMaterial.bin  \
--import-token fileb://ImportToken.bin \
--expiration-model KEY_MATERIAL_DOES_NOT_EXPIRE


export KEY_STATE="$($AWS kms --region $REGION \
                    --profile $PROFILE describe-key \
                    --key-id $KEY_ID  \
                    | jq .KeyMetadata.KeyState)"


echo "Key Status : "
echo $KEY_STATE
export KEY_ARN="$($AWS kms --region $REGION \
                describe-key --profile $PROFILE \
                --key-id $KEY_ID \
                | jq .KeyMetadata.Arn | tr -d '"')"
